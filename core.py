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
import unicodedata
from pathlib import Path
from typing import Optional, Union
from urllib.parse import urljoin

import requests
import trafilatura
from bs4 import BeautifulSoup, Comment, FeatureNotFound, Tag
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
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
)

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

# --- Configuración de Caché y Sesión HTTP ---

_CACHE_DIR = Path.home() / ".cache" / "extractor-url"

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

def _fetch_raw(url: str, timeout: int = 15, use_cache: bool = True) -> Optional[tuple[str, str]]:
    """Descarga una URL (con caché opcional) y devuelve (html_text, url_final)."""
    if not url.startswith(("http://", "https://")):
        url = "https://" + url

    # Lógica de caché
    cache_key = hashlib.sha256(url.encode()).hexdigest()
    cache_file = _CACHE_DIR / f"{cache_key}.json"

    if use_cache:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        if cache_file.exists():
            try:
                with cache_file.open("r", encoding="utf-8") as f:
                    cached_data = json.load(f)
                    return cached_data["html"], cached_data["final_url"]
            except (IOError, json.JSONDecodeError):
                # Si hay un error al leer la caché, simplemente se ignora y se procede a la descarga
                pass

    # Lógica de descarga
    try:
        response = _HTTP_SESSION.get(
            url,
            headers={"User-Agent": _USER_AGENT},
            timeout=timeout,
        )
        response.raise_for_status()
        response.encoding = response.apparent_encoding
        html_text = response.text
        final_url = response.url

        # Guardar en caché si la descarga fue exitosa
        if use_cache:
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


def _fetch_soup(url: str, timeout: int = 15, use_cache: bool = True) -> Optional[BeautifulSoup]:
    """Descarga una URL y devuelve un objeto BeautifulSoup."""
    raw = _fetch_raw(url, timeout=timeout, use_cache=use_cache)
    if raw is None:
        return None
    html_text, _ = raw
    try:
        return BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        return BeautifulSoup(html_text, "html.parser")


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
        except Exception:  # pylint: disable=broad-exception-caught
            pass
    return None


def _format_soup_content(
    soup: BeautifulSoup,
    return_type: str,
    selector: Optional[str],
) -> Optional[Union[str, BeautifulSoup]]:
    """Formatea un documento parseado según el tipo de retorno solicitado."""
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

def extract_formatted_content(
    url: str,
    return_type: str = "text",
    selector: Optional[str] = None,
    timeout: int = 15,
    use_cache: bool = True,
) -> Optional[Union[str, BeautifulSoup]]:
    """Extrae contenido formateado de una página web."""
    if return_type == "markdown_structure":
        return extract_html_structure_to_markdown(
            url, selector=selector, timeout=timeout, use_cache=use_cache
        )

    soup = _fetch_soup(url, timeout=timeout, use_cache=use_cache)
    if soup is None:
        return None

    return _format_soup_content(soup, return_type, selector)


def extract_html_structure_to_markdown(
    url: str, selector: Optional[str] = None, timeout: int = 15, use_cache: bool = True,
) -> Optional[str]:
    """Convierte el contenido principal de una URL a Markdown fiel."""
    raw = _fetch_raw(url, timeout=timeout, use_cache=use_cache)
    if raw is None:
        return None

    html_text, final_url = raw

    try:
        soup = BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        soup = BeautifulSoup(html_text, "html.parser")

    soup = _clean_soup(soup, final_url)

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
        include_images=True,
        include_links=True,
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
