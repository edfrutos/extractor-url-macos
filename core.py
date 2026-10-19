"""Módulo principal de extracción de contenido web.

Este módulo proporciona funciones para descargar, limpiar y convertir
contenido web a diferentes formatos (texto, HTML, Markdown).
No contiene código de interfaz de usuario.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
import time
import unicodedata
from pathlib import Path
from typing import Optional, Union
from urllib.parse import urljoin, urlparse
from urllib.request import url2pathname

import requests
import trafilatura
from bs4 import BeautifulSoup, Comment, FeatureNotFound, Tag, UnicodeDammit
from markdownify import markdownify as md_convert
from requests.adapters import HTTPAdapter
from soupsieve import SelectorSyntaxError
from urllib3.util.retry import Retry

# Tags que aportan ruido de navegación y deben eliminarse antes de convertir
_NOISE_TAGS = [
    "script", "style", "nav", "header", "footer",
    "aside", "form", "noscript", "iframe",
]

_USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36"
)

# Cabeceras de un navegador real: un User-Agent aislado (y antiguo) es una
# señal típica de bot para las protecciones tipo Akamai/Cloudflare.
_REQUEST_HEADERS = {
    "User-Agent": _USER_AGENT,
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;q=0.9,"
        "image/avif,image/webp,*/*;q=0.8"
    ),
    "Accept-Language": "es-ES,es;q=0.9,en;q=0.8",
}

# Códigos con los que un sitio suele bloquear clientes HTTP "no navegador".
# Ante ellos se reintenta con Chromium headless (salvo js_mode="off").
_BLOCKED_STATUS_CODES = frozenset({401, 403})

# Selectores CSS para detectar el contenido principal, por orden de prioridad
_MAIN_SELECTORS = [
    "main",
    "article",
    '[role="main"]',
    "#content",
    "#main",
    ".content",
    ".post-content",
    ".entry-content",
    ".article-body",
    ".post-body",
]

# Umbral de caracteres de texto visible bajo el cual se considera que la
# extracción estática no capturó contenido real (posible SPA sin hidratar).
# 100 deja margen bajo el contenido real más corto de la suite de tests
# (145 caracteres en tests/fixtures/edefrutos_me.html) sin dejar de detectar
# una SPA vacía (0 caracteres tras quitar ruido).
_MIN_VISIBLE_TEXT_LENGTH = 100

# --- Configuración de Caché y Sesión HTTP ---

_CACHE_DIR = Path.home() / ".cache" / "extractor-url"

# HTML cacheado más viejo que esto se trata como cache miss (y se borra al
# detectarlo) — evita crecimiento indefinido de ~/.cache con páginas obsoletas.
_CACHE_TTL_SECONDS = 7 * 24 * 3600

# --- Historial de extracciones ---

_HISTORY_FILE = _CACHE_DIR / "history.jsonl"

# Tope de líneas conservadas en el historial — se trunca a las más recientes
# tras cada escritura para que el archivo no crezca sin límite.
_HISTORY_MAX_ENTRIES = 500


def record_history_entry(entry: dict) -> None:
    """Añade una entrada al historial (best-effort, nunca lanza)."""
    try:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        with _HISTORY_FILE.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        _trim_history_file()
    except OSError:
        pass


def _trim_history_file() -> None:
    """Recorta el historial a las últimas _HISTORY_MAX_ENTRIES líneas."""
    try:
        with _HISTORY_FILE.open("r", encoding="utf-8") as f:
            lines = f.readlines()
        if len(lines) > _HISTORY_MAX_ENTRIES:
            with _HISTORY_FILE.open("w", encoding="utf-8") as f:
                f.writelines(lines[-_HISTORY_MAX_ENTRIES:])
    except OSError:
        pass


def load_history(limit: Optional[int] = None) -> list[dict]:
    """Devuelve las entradas del historial, más reciente primero."""
    if not _HISTORY_FILE.exists():
        return []
    entries = []
    with _HISTORY_FILE.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    entries.reverse()
    return entries[:limit] if limit else entries


def _create_retry_session() -> requests.Session:
    """Crea una sesión de requests con una estrategia de reintentos."""
    session = requests.Session()
    retry_strategy = Retry(
        total=3,
        status_forcelist=[429, 500, 502, 503, 504],
        backoff_factor=1,
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session

_HTTP_SESSION = _create_retry_session()


# ---------------------------------------------------------------------------
# Descarga
# ---------------------------------------------------------------------------

_EXPLICIT_SCHEME_RE = re.compile(r"^([A-Za-z][A-Za-z0-9+.-]*)://")


def url_scheme_error(url: str) -> Optional[str]:
    """Devuelve un mensaje de error si la URL declara un esquema no soportado.

    Sin esquema explícito (``example.com``) no es un error: _fetch_raw()
    antepone ``https://``. Con un esquema distinto de http/https (p. ej. la
    errata ``httpd://``) se falla explícito en vez de pedir
    ``https://httpd://...``, que acaba en un error de red confuso.
    """
    match = _EXPLICIT_SCHEME_RE.match(url.strip())
    if match is None or match.group(1).lower() in ("http", "https", "file"):
        return None
    return (
        f"Esquema de URL no soportado: '{match.group(1)}://'. "
        "Usa http://, https:// o file:// (archivo HTML local)."
    )


# Comentario que añaden Chrome/Safari/Edge al "Guardar página como…".
_SAVED_FROM_RE = re.compile(r"<!--\s*saved from url=\(\d+\)(\S+?)\s*-->", re.IGNORECASE)


def _original_page_url(html_text: str) -> Optional[str]:
    """URL original de una página guardada en disco, si el HTML la declara.

    Se usa como base para resolver enlaces e imágenes relativos: con la
    ruta file:// apuntarían al disco en vez de a la web de origen.
    """
    soup = _parse_html(html_text)
    candidates = [
        soup.find("link", rel="canonical"),
        soup.find("meta", attrs={"property": "og:url"}),
    ]
    for tag in candidates:
        if isinstance(tag, Tag):
            value = tag.get("href") or tag.get("content")
            if isinstance(value, str) and value.startswith(("http://", "https://")):
                return value
    match = _SAVED_FROM_RE.search(html_text)
    if match and match.group(1).startswith(("http://", "https://")):
        return match.group(1)
    return None


def _read_local_html(file_uri: str) -> Optional[tuple[str, str]]:
    """Lee un archivo HTML local (URI file://) y devuelve (html_text, url_base).

    La codificación se detecta como haría un navegador (meta charset, BOM…)
    para no romper páginas guardadas en Latin-1 u otras codificaciones.
    """
    path = Path(url2pathname(urlparse(file_uri).path))
    try:
        data = path.read_bytes()
    except OSError as error:
        print(f"No se pudo leer el archivo '{path}': {error}", file=sys.stderr)
        return None
    html_text = UnicodeDammit(data, is_html=True).unicode_markup
    if html_text is None:
        html_text = data.decode("utf-8", errors="replace")
    return html_text, _original_page_url(html_text) or file_uri


def _normalize_url(url: str) -> Optional[str]:
    """Antepone ``https://`` si falta el esquema; None (con aviso) si es inválido."""
    scheme_error = url_scheme_error(url)
    if scheme_error is not None:
        print(scheme_error, file=sys.stderr)
        return None
    if not url.lower().startswith(("http://", "https://")):
        return "https://" + url
    return url


def _fetch_raw(
    url: str,
    timeout: int = 15,
    use_cache: bool = True,
    js_mode: str = "auto",
    session: Optional["PlaywrightSession"] = None,
) -> Optional[tuple[str, str]]:
    """Descarga una URL (con caché opcional) y devuelve (html_text, url_final).

    js_mode controla el fallback Playwright (Fase 11/15):
    - "auto" (defecto): heurística _looks_insufficient() decide, igual que v4.0.
    - "force": renderiza siempre con Playwright, ignorando la heurística.
    - "off": nunca renderiza con Playwright, ignorando la heurística.

    Un js_mode distinto de "auto" salta la LECTURA de la caché (una URL ya
    cacheada de una ejecución anterior no debe anular el efecto explícito
    del flag) pero conserva la escritura al final, igual que siempre.
    """
    if url.lower().startswith("file://"):
        # Archivo local: sin red, caché ni Playwright (una página guardada
        # ya es el HTML final).
        return _read_local_html(url)

    normalized_url = _normalize_url(url)
    if normalized_url is None:
        return None
    url = normalized_url

    # Lógica de caché
    cache_key = hashlib.sha256(url.encode()).hexdigest()
    cache_file = _CACHE_DIR / f"{cache_key}.json"

    if use_cache:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        if js_mode == "auto" and cache_file.exists():
            try:
                if time.time() - cache_file.stat().st_mtime > _CACHE_TTL_SECONDS:
                    cache_file.unlink(missing_ok=True)
                else:
                    with cache_file.open("r", encoding="utf-8") as f:
                        cached_data = json.load(f)
                        return cached_data["html"], cached_data["final_url"]
            except (IOError, OSError, json.JSONDecodeError):
                # Si hay un error al leer/borrar la caché, se ignora y se procede a la descarga
                pass

    # Lógica de descarga
    try:
        html_text, final_url = _download(url, timeout, js_mode, session)

        # Guardar en caché si la descarga fue exitosa. Solo en js_mode="auto":
        # "force"/"off" no deben poder envenenar la caché que lee el modo
        # automático con un resultado que ignoró deliberadamente la heurística.
        if use_cache and js_mode == "auto":
            try:
                with cache_file.open("w", encoding="utf-8") as f:
                    json.dump({"html": html_text, "final_url": final_url}, f)
            except IOError:
                # Si no se puede escribir en la caché, no es un error crítico
                pass

        return html_text, final_url

    except requests.exceptions.RequestException as e:
        print(f"Error al acceder a la URL '{url}': {e}", file=sys.stderr)
        return None
    except Exception as e:  # pylint: disable=broad-exception-caught
        print(f"Error inesperado: {e}", file=sys.stderr)
        return None


def _download(
    url: str,
    timeout: int,
    js_mode: str,
    session: Optional["PlaywrightSession"],
) -> tuple[str, str]:
    """Descarga `url` y devuelve (html_text, url_final), con fallback a Chromium.

    Fallback JS (Fase 11) + control manual (Fase 15): "force" renderiza
    siempre, "off" nunca, "auto" deja decidir a la heurística. Además, si la
    descarga directa recibe un 401/403 (bloqueo anti-bots), se reintenta con
    Chromium headless salvo en "off". Propaga RequestException si no hay
    forma de obtener la página.
    """
    try:
        response = _HTTP_SESSION.get(url, headers=_REQUEST_HEADERS, timeout=timeout)
        response.raise_for_status()
    except requests.exceptions.HTTPError as error:
        status = error.response.status_code if error.response is not None else None
        if js_mode == "off" or status not in _BLOCKED_STATUS_CODES:
            raise
        print(
            f"HTTP {status} en la descarga directa de '{url}'; "
            "reintentando con navegador headless.",
            file=sys.stderr,
        )
        rendered = _fetch_via_playwright(url, timeout, session=session)
        if rendered is None:
            raise
        return rendered, url

    response.encoding = response.apparent_encoding
    html_text = response.text
    if js_mode == "force" or (js_mode != "off" and _looks_insufficient(html_text)):
        rendered = _fetch_via_playwright(url, timeout, session=session)
        if rendered is not None:
            html_text = rendered
    return html_text, response.url


def _parse_html(html_text: str) -> BeautifulSoup:
    """Parsea HTML con lxml, con fallback a html.parser si lxml no está instalado."""
    try:
        return BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        return BeautifulSoup(html_text, "html.parser")


def _fetch_soup(
    url: str, timeout: int = 15, use_cache: bool = True, js_mode: str = "auto",
    session: Optional["PlaywrightSession"] = None,
) -> Optional[BeautifulSoup]:
    """Descarga una URL y devuelve un objeto BeautifulSoup."""
    raw = _fetch_raw(
        url, timeout=timeout, use_cache=use_cache, js_mode=js_mode, session=session,
    )
    if raw is None:
        return None
    html_text, _ = raw
    return _parse_html(html_text)


def _looks_insufficient(html_text: str) -> bool:
    """Heurística: ¿el HTML estático tiene contenido visible real?

    Best-effort, no exacta: un documento vacío o casi vacío (típico de una
    SPA sin hidratar) da menos de _MIN_VISIBLE_TEXT_LENGTH caracteres de
    texto visible tras quitar _NOISE_TAGS.
    """
    soup = _parse_html(html_text)
    for tag in soup(_NOISE_TAGS):
        tag.decompose()
    body = soup.find("body") or soup
    visible_text = body.get_text(strip=True)
    return len(visible_text) < _MIN_VISIBLE_TEXT_LENGTH


class PlaywrightSession:
    """Chromium headless reutilizable entre varias llamadas a _fetch_via_playwright.

    Lanza el browser de forma perezosa en el primer uso (una sola vez) y lo
    mantiene abierto hasta close()/__exit__ — evita relanzar Chromium por
    cada URL de un --batch con varias SPA. Uso: `with PlaywrightSession() as
    session:` y pasar `session=session` a extract_formatted_content().
    """

    def __init__(self) -> None:
        self._playwright = None
        self._browser = None
        self._launch_failed = False

    def _ensure_browser(self):
        if self._browser is not None:
            return self._browser
        if self._launch_failed:
            # Ya falló una vez: no reintentar el lanzamiento en cada URL del batch.
            return None
        try:
            from playwright.sync_api import sync_playwright  # pylint: disable=import-outside-toplevel
        except ImportError:
            return None
        if self._playwright is None:
            self._playwright = sync_playwright().start()
        try:
            self._browser = self._playwright.chromium.launch()
        except Exception:
            self._launch_failed = True
            raise
        return self._browser

    def new_page(self):
        """Crea una página en el browser compartido, o None si no disponible."""
        browser = self._ensure_browser()
        if browser is None:
            return None
        return browser.new_page(user_agent=_USER_AGENT)

    def close(self) -> None:
        """Cierra el browser y detiene Playwright, si se llegaron a lanzar."""
        if self._browser is not None:
            self._browser.close()
        if self._playwright is not None:
            self._playwright.stop()

    def __enter__(self) -> "PlaywrightSession":
        return self

    def __exit__(self, *_exc_info: object) -> None:
        self.close()


def _render_page(page, url: str, timeout: int) -> Optional[str]:
    """Navega a `url` y devuelve el HTML; None si el servidor responde con error.

    Sin comprobar el estado, una página de bloqueo ("Access Denied", 403) se
    devolvería como si fuera el contenido de la web.
    """
    response = page.goto(url, timeout=timeout * 1000, wait_until="networkidle")
    if response is not None and response.status >= 400:
        print(
            f"El navegador headless también recibió HTTP {response.status} de '{url}'.",
            file=sys.stderr,
        )
        return None
    return page.content()


def _fetch_via_playwright(
    url: str, timeout: int, session: Optional[PlaywrightSession] = None,
) -> Optional[str]:
    """Renderiza `url` con Chromium headless y devuelve el HTML final.

    Devuelve None si Playwright no está instalado (paquete pip ausente) o
    si los binarios del browser no están instalados (`playwright install
    chromium` nunca ejecutado) — ambos casos degradan, no son fatales.

    Si se pasa `session` (PlaywrightSession), reutiliza su browser en vez de
    lanzar uno nuevo — pensado para --batch con varias URLs consecutivas.
    """
    try:
        from playwright.sync_api import Error as PlaywrightError  # type: ignore[import-not-found]  # pylint: disable=import-outside-toplevel
        from playwright.sync_api import sync_playwright  # type: ignore[import-not-found]  # pylint: disable=import-outside-toplevel
    except ImportError:
        return None

    if session is not None:
        page = None
        try:
            # new_page() lanza Chromium en el primer uso: si el binario falta o
            # no arranca, debe degradar igual que un fallo de render, no abortar.
            page = session.new_page()
            if page is None:
                return None
            return _render_page(page, url, timeout)
        except PlaywrightError as e:
            print(
                f"Playwright no disponible o falló el render de '{url}': {e}",
                file=sys.stderr,
            )
            return None
        finally:
            if page is not None:
                page.close()

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            try:
                page = browser.new_page(user_agent=_USER_AGENT)
                return _render_page(page, url, timeout)
            finally:
                browser.close()
    except PlaywrightError as e:
        print(
            f"Playwright no disponible o falló el render de '{url}': {e}",
            file=sys.stderr,
        )
        return None


# ---------------------------------------------------------------------------
# Limpieza y utilidades para Markdown
# ---------------------------------------------------------------------------

def _clean_soup(soup: BeautifulSoup, base_url: str) -> BeautifulSoup:
    """Elimina tags de ruido, comentarios HTML y resuelve URLs relativas."""
    for tag in soup(_NOISE_TAGS):
        tag.decompose()

    for comment in soup.find_all(string=lambda t: isinstance(t, Comment)):
        comment.extract()

    for a_tag in soup.find_all("a", href=True):
        a_tag["href"] = urljoin(base_url, str(a_tag["href"]))

    for img_tag in soup.find_all("img", src=True):
        img_tag["src"] = urljoin(base_url, str(img_tag["src"]))

    return soup


def _strip_images(soup: Union[Tag, BeautifulSoup]) -> None:
    """Elimina in situ todas las etiquetas <img> del árbol (--no-images)."""
    for img_tag in soup.find_all("img"):
        img_tag.decompose()


def _strip_links(soup: Union[Tag, BeautifulSoup]) -> None:
    """Aplana in situ los enlaces: conserva el texto, quita la etiqueta <a> (--no-links)."""
    for a_tag in soup.find_all("a"):
        a_tag.unwrap()


def _main_content(soup: BeautifulSoup) -> Union[Tag, BeautifulSoup]:
    """Localiza el elemento de contenido principal del documento."""
    for selector in _MAIN_SELECTORS:
        found = soup.select_one(selector)
        if found and isinstance(found, Tag):
            return found

    body = soup.find("body")
    return body if isinstance(body, Tag) else soup


def _apply_selector(
    soup: BeautifulSoup, selector: str
) -> Optional[Tag]:
    """Aplica un selector CSS para acotar el contenido extraído."""
    try:
        found = soup.select_one(selector)
    except SelectorSyntaxError as error:
        print(f"Selector CSS inválido '{selector}': {error}", file=sys.stderr)
        return None

    if found and isinstance(found, Tag):
        return found
    print(f"Selector '{selector}' no encontró ningún elemento.", file=sys.stderr)
    return None


def _post_process_markdown(text: str) -> str:
    """Normaliza Unicode, elimina ruido residual y limpia el Markdown."""
    text = unicodedata.normalize("NFC", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = "\n".join(line.rstrip() for line in text.splitlines())
    text = re.sub(r"^\s*[-|/\\]{4,}\s*$", "", text, flags=re.MULTILINE)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def _extract_title(
    soup: BeautifulSoup,
    html_text: Optional[str] = None,
) -> Optional[str]:
    """Extrae el <title> de la página. Fallback a trafilatura metadata.

    Camino 1: BeautifulSoup — guard doble para evitar AttributeError
    cuando soup.title existe pero title.string es None (Pitfall #5).
    Camino 2: trafilatura.extract_metadata — cubre og:title, twitter:title, etc.
    Si ninguno produce título, devuelve None.
    """
    # Camino 1: BeautifulSoup (guard doble — Pitfall #5 de RESEARCH.md)
    if soup.title and soup.title.string:
        title = soup.title.string.strip()
        if title:
            return title
    # Camino 2: trafilatura metadata (fallback para og:title, etc.)
    if html_text is not None:
        try:
            meta = trafilatura.extract_metadata(html_text)
            if meta and meta.title:
                return meta.title.strip()
        except Exception as e:  # pylint: disable=broad-exception-caught
            print(
                f"Aviso: fallo al leer metadata con trafilatura: {e}",
                file=sys.stderr,
            )
    return None


def _format_soup_content(
    soup: BeautifulSoup,
    return_type: str,
    selector: Optional[str],
    no_images: bool = False,
    no_links: bool = False,
) -> Optional[Union[str, BeautifulSoup]]:
    """Formatea un documento parseado según el tipo de retorno solicitado."""
    if no_images:
        _strip_images(soup)
    if no_links:
        _strip_links(soup)

    if return_type == "soup_object":
        return soup

    if return_type not in ("html_string", "text"):
        return None

    if return_type == "text":
        for tag in soup(_NOISE_TAGS):
            tag.decompose()

    target: Union[Tag, BeautifulSoup] = soup
    if selector:
        selected = _apply_selector(soup, selector)
        if selected is None:
            return None
        target = selected

    if return_type == "html_string":
        return str(target)

    text = target.get_text(separator="\n", strip=True)
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

def extract_formatted_content(  # pylint: disable=too-many-arguments,too-many-positional-arguments
    url: str,
    return_type: str = "text",
    selector: Optional[str] = None,
    timeout: int = 15,
    use_cache: bool = True,
    js_mode: str = "auto",
    no_images: bool = False,
    no_links: bool = False,
    session: Optional["PlaywrightSession"] = None,
) -> Optional[Union[str, BeautifulSoup]]:
    """Extrae contenido formateado de una página web."""
    if return_type == "markdown_structure":
        return extract_html_structure_to_markdown(
            url, selector=selector, timeout=timeout, use_cache=use_cache, js_mode=js_mode,
            no_images=no_images, no_links=no_links, session=session,
        )

    soup = _fetch_soup(
        url, timeout=timeout, use_cache=use_cache, js_mode=js_mode, session=session,
    )
    if soup is None:
        return None

    return _format_soup_content(soup, return_type, selector, no_images, no_links)


def extract_html_structure_to_markdown(  # pylint: disable=too-many-arguments,too-many-positional-arguments
    url: str,
    selector: Optional[str] = None,
    timeout: int = 15,
    use_cache: bool = True,
    js_mode: str = "auto",
    no_images: bool = False,
    no_links: bool = False,
    session: Optional["PlaywrightSession"] = None,
) -> Optional[str]:
    """Convierte el contenido principal de una URL a Markdown fiel."""
    raw = _fetch_raw(
        url, timeout=timeout, use_cache=use_cache, js_mode=js_mode, session=session,
    )
    if raw is None:
        return None

    html_text, final_url = raw

    soup = _parse_html(html_text)
    soup = _clean_soup(soup, final_url)
    if no_images:
        _strip_images(soup)
    if no_links:
        _strip_links(soup)

    if selector:
        content = _apply_selector(soup, selector)
        if content is None:
            return None
        markdown = md_convert(
            str(content),
            heading_style="ATX",
            bullets="-",
            strip=["script", "style"],
        )
        return _post_process_markdown(markdown)

    trafilatura_result = trafilatura.extract(
        html_text,
        url=final_url,
        output_format="markdown",
        include_images=not no_images,
        include_links=not no_links,
        favor_recall=True,
        no_fallback=False,
    )
    if trafilatura_result and len(trafilatura_result.strip()) > 150:
        return _post_process_markdown(trafilatura_result)

    content = _main_content(soup)
    markdown = md_convert(
        str(content),
        heading_style="ATX",
        bullets="-",
        strip=["script", "style"],
    )
    return _post_process_markdown(markdown)

# End of file
