"""Extractor de contenido web a partir de una URL.

Proporciona funciones utilitarias para obtener texto limpio, HTML completo,
Markdown fiel y una interfaz gráfica con tkinter.
"""

from __future__ import annotations

import argparse
import re
import sys
import threading
import tkinter as tk
import unicodedata
from tkinter import filedialog, messagebox, ttk
from typing import Optional, Union
from urllib.parse import urljoin

import requests
import trafilatura
from bs4 import BeautifulSoup, Comment, FeatureNotFound, Tag
from markdownify import markdownify as md_convert

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


# ---------------------------------------------------------------------------
# Descarga
# ---------------------------------------------------------------------------

def _fetch_raw(url: str) -> Optional[tuple[str, str]]:
    """Descarga una URL y devuelve (html_text, url_final).

    Args:
        url: URL de la página web. Se añade https:// si falta el esquema.

    Returns:
        Tupla (html, url_final tras redirecciones) o None si falla.
    """
    if not url.startswith(("http://", "https://")):
        url = "https://" + url

    try:
        response = requests.get(
            url,
            headers={"User-Agent": _USER_AGENT},
            timeout=15,
        )
        response.raise_for_status()
        response.encoding = response.apparent_encoding
        return response.text, response.url

    except requests.exceptions.RequestException as e:
        print(f"Error al acceder a la URL '{url}': {e}", file=sys.stderr)
        return None
    except Exception as e:  # pylint: disable=broad-exception-caught
        print(f"Error inesperado: {e}", file=sys.stderr)
        return None


def _fetch_soup(url: str) -> Optional[BeautifulSoup]:
    """Descarga una URL y devuelve un objeto BeautifulSoup.

    Args:
        url: URL de la página web.

    Returns:
        Objeto BeautifulSoup o None si falla la petición.
    """
    raw = _fetch_raw(url)
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
    """Elimina tags de ruido, comentarios HTML y resuelve URLs relativas.

    Args:
        soup: Árbol BeautifulSoup a limpiar (se modifica en sitio).
        base_url: URL base para resolver hrefs y srcs relativos.

    Returns:
        El mismo objeto soup ya limpio.
    """
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
    """Localiza el elemento de contenido principal del documento.

    Prueba los selectores de _MAIN_SELECTORS en orden y devuelve el primero
    que encuentre. Fallback a <body> y, si no existe, al propio soup.

    Args:
        soup: Árbol BeautifulSoup ya limpio.

    Returns:
        Tag con el contenido principal o el soup completo como último recurso.
    """
    for selector in _MAIN_SELECTORS:
        found = soup.select_one(selector)
        if found and isinstance(found, Tag):
            return found

    body = soup.find("body")
    return body if isinstance(body, Tag) else soup


def _apply_selector(
    soup: BeautifulSoup, selector: str
) -> Union[Tag, BeautifulSoup]:
    """Aplica un selector CSS para acotar el contenido extraído.

    Args:
        soup: Árbol BeautifulSoup (limpio o no).
        selector: Selector CSS, p.ej. 'article', '#content', '.post-body'.

    Returns:
        El Tag encontrado, o el soup completo con aviso si no coincide.
    """
    found = soup.select_one(selector)
    if found and isinstance(found, Tag):
        return found
    print(
        f"Selector '{selector}' no encontró ningún elemento; usando documento completo.",
        file=sys.stderr,
    )
    return soup


def _post_process_markdown(text: str) -> str:
    """Normaliza Unicode, elimina ruido residual y limpia el Markdown.

    Args:
        text: Cadena Markdown cruda.

    Returns:
        Markdown limpio y listo para usar.
    """
    # Normalizar combinaciones Unicode (evita caracteres compuestos duplicados)
    text = unicodedata.normalize("NFC", text)
    # Máximo dos líneas vacías consecutivas
    text = re.sub(r"\n{3,}", "\n\n", text)
    # Eliminar espacios al final de cada línea
    text = "\n".join(line.rstrip() for line in text.splitlines())
    # Eliminar líneas que sean solo separadores de navegación (-----, /////)
    text = re.sub(r"^\s*[-|/\\]{4,}\s*$", "", text, flags=re.MULTILINE)
    # Segunda pasada de líneas vacías excesivas tras el filtrado anterior
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


# ---------------------------------------------------------------------------
# API pública
# ---------------------------------------------------------------------------

def extract_formatted_content(
    url: str,
    return_type: str = "text",
    selector: Optional[str] = None,
) -> Optional[Union[str, BeautifulSoup]]:
    """Extrae contenido formateado de una página web.

    Args:
        url: URL de la página web.
        return_type: Tipo de contenido ('text', 'html_string', 'soup_object',
                     'markdown_structure').
        selector: Selector CSS opcional para acotar el contenido, p.ej.
                  'article', '#content', '.post-body'. None = auto-detección.

    Returns:
        Contenido extraído (str, BeautifulSoup) o None.
    """
    if return_type == "markdown_structure":
        return extract_html_structure_to_markdown(url, selector=selector)

    soup = _fetch_soup(url)
    if soup is None:
        return None

    if return_type == "soup_object":
        return soup

    if return_type == "html_string":
        target = _apply_selector(soup, selector) if selector else soup
        return str(target)

    if return_type == "text":
        for tag in soup(_NOISE_TAGS):
            tag.decompose()
        target = _apply_selector(soup, selector) if selector else soup
        text = target.get_text(separator="\n", strip=True)
        lines = [line.strip() for line in text.splitlines() if line.strip()]
        return "\n".join(lines)

    return None


def extract_html_structure_to_markdown(
    url: str, selector: Optional[str] = None
) -> Optional[str]:
    """Convierte el contenido principal de una URL a Markdown fiel.

    Pipeline adaptativo:
    - Con selector: markdownify directo sobre el elemento seleccionado.
      trafilatura se omite porque el usuario ya delimita el contenido.
    - Sin selector: trafilatura primero (óptimo para artículos); markdownify
      como fallback con auto-detección de main/article/body.

    Args:
        url: URL de la página web.
        selector: Selector CSS opcional, p.ej. 'article', '.post-body'.
                  None = auto-detección.

    Returns:
        Cadena Markdown o None si la descarga falla.
    """
    raw = _fetch_raw(url)
    if raw is None:
        return None

    html_text, final_url = raw

    try:
        soup = BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        soup = BeautifulSoup(html_text, "html.parser")

    soup = _clean_soup(soup, final_url)

    # --- Ruta con selector explícito: markdownify directo ---
    if selector:
        content = _apply_selector(soup, selector)
        markdown = md_convert(
            str(content),
            heading_style="ATX",
            bullets="-",
            strip=["script", "style"],
        )
        return _post_process_markdown(markdown)

    # --- Sin selector: trafilatura primero (óptimo para artículos) ---
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

    # --- Fallback: markdownify con auto-detección ---
    content = _main_content(soup)
    markdown = md_convert(
        str(content),
        heading_style="ATX",
        bullets="-",
        strip=["script", "style"],
    )
    return _post_process_markdown(markdown)


# ---------------------------------------------------------------------------
# Interfaz gráfica (tkinter)
# ---------------------------------------------------------------------------

def _run_gui() -> None:
    """Inicia la interfaz gráfica tkinter."""
    root = tk.Tk()
    root.title("Extractor de contenido web")
    root.geometry("900x700")
    root.minsize(700, 520)

    # --- URL ---
    frame_input = ttk.Frame(root, padding=10)
    frame_input.pack(fill=tk.X)

    ttk.Label(frame_input, text="URL:").pack(side=tk.LEFT)
    url_var = tk.StringVar()
    entry_url = ttk.Entry(frame_input, textvariable=url_var, width=60)
    entry_url.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
    entry_url.focus()

    # --- Selector CSS ---
    frame_selector = ttk.Frame(root, padding=(10, 0, 10, 4))
    frame_selector.pack(fill=tk.X)

    ttk.Label(frame_selector, text="Selector CSS:").pack(side=tk.LEFT)
    selector_var = tk.StringVar()
    ttk.Entry(frame_selector, textvariable=selector_var, width=28).pack(
        side=tk.LEFT, padx=5
    )
    ttk.Label(
        frame_selector,
        text="(opcional — ej: article, #content, .post-body)",
        foreground="gray",
    ).pack(side=tk.LEFT)

    # --- Tipo de extracción ---
    frame_options = ttk.Frame(root, padding=(10, 0, 10, 8))
    frame_options.pack(fill=tk.X)

    ttk.Label(frame_options, text="Tipo:").pack(side=tk.LEFT)
    type_var = tk.StringVar(value="text")
    for label, value in (
        ("Texto limpio", "text"),
        ("HTML completo", "html_string"),
        ("Markdown", "markdown_structure"),
    ):
        ttk.Radiobutton(
            frame_options, text=label, variable=type_var, value=value
        ).pack(side=tk.LEFT, padx=5)

    # --- Botones y estado ---
    frame_buttons = ttk.Frame(root, padding=(10, 0, 10, 10))
    frame_buttons.pack(fill=tk.X)

    status_var = tk.StringVar(value="Listo")

    # Los handlers se definen antes que los botones; Python resuelve los
    # nombres capturados en el cierre en tiempo de llamada, no de definición.

    def _on_result(result: Optional[Union[str, BeautifulSoup]]) -> None:
        """Actualiza la UI tras la extracción — siempre se llama en el hilo principal."""
        btn_extract.config(state=tk.NORMAL)
        if result is None:
            status_var.set("Error al extraer")
            messagebox.showerror("Error", "No se pudo extraer el contenido de la URL.")
            return
        result_text = result if isinstance(result, str) else str(result)
        text_result.delete("1.0", tk.END)
        text_result.insert("1.0", result_text)
        status_var.set(f"Extraído — {len(result_text):,} caracteres")

    def _extract() -> None:
        url = url_var.get().strip()
        if not url:
            messagebox.showwarning("Aviso", "Introduce una URL válida.")
            return

        selector = selector_var.get().strip() or None
        return_type = type_var.get()

        btn_extract.config(state=tk.DISABLED)
        status_var.set("Extrayendo…")

        def _worker() -> None:
            result = extract_formatted_content(url, return_type=return_type, selector=selector)
            # root.after garantiza que _on_result corre en el hilo de tkinter
            root.after(0, lambda: _on_result(result))

        threading.Thread(target=_worker, daemon=True).start()

    def _save() -> None:
        content = text_result.get("1.0", tk.END).strip()
        if not content:
            messagebox.showwarning("Aviso", "No hay contenido para guardar.")
            return

        extensions = {
            "text": ".txt",
            "html_string": ".html",
            "markdown_structure": ".md",
        }
        ext = extensions.get(type_var.get(), ".txt")
        file_path = filedialog.asksaveasfilename(
            defaultextension=ext,
            filetypes=[("Archivos de texto", "*.*")],
        )
        if not file_path:
            return

        try:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
            status_var.set(f"Guardado en {file_path}")
        except OSError as e:
            messagebox.showerror("Error", f"No se pudo guardar: {e}")

    def _clear() -> None:
        text_result.delete("1.0", tk.END)
        status_var.set("Listo")

    btn_extract = ttk.Button(frame_buttons, text="Extraer", command=_extract)
    btn_extract.pack(side=tk.LEFT, padx=5)
    ttk.Button(frame_buttons, text="Guardar…", command=_save).pack(side=tk.LEFT, padx=5)
    ttk.Button(frame_buttons, text="Limpiar", command=_clear).pack(side=tk.LEFT, padx=5)
    ttk.Label(frame_buttons, textvariable=status_var).pack(side=tk.RIGHT, padx=5)

    # --- Área de resultado ---
    frame_result = ttk.Frame(root, padding=10)
    frame_result.pack(fill=tk.BOTH, expand=True)

    scrollbar = ttk.Scrollbar(frame_result)
    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

    text_result = tk.Text(
        frame_result,
        wrap=tk.WORD,
        yscrollcommand=scrollbar.set,
        font=("Menlo", 10),
    )
    text_result.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
    scrollbar.config(command=text_result.yview)

    root.bind("<Return>", lambda _e: _extract())
    root.bind("<Control-s>", lambda _e: _save())

    root.mainloop()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    """Punto de entrada CLI."""
    parser = argparse.ArgumentParser(description="Extractor de contenido web")
    parser.add_argument("url", help="URL de la página web")
    parser.add_argument(
        "-t",
        "--type",
        choices=["text", "html", "markdown"],
        default="text",
        help="Tipo de salida (defecto: text)",
    )
    parser.add_argument("-o", "--output", help="Archivo de salida (opcional)")
    parser.add_argument(
        "-s",
        "--selector",
        metavar="CSS",
        default=None,
        help="Selector CSS para acotar el contenido (ej: 'article', '#content', '.post-body')",
    )
    parser.add_argument(
        "--gui",
        action="store_true",
        help="Abrir interfaz gráfica",
    )

    args = parser.parse_args()

    if args.gui:
        _run_gui()
        return

    content_type_map = {
        "text": "text",
        "html": "html_string",
        "markdown": "markdown_structure",
    }
    content_type = content_type_map.get(args.type, "text")
    result = extract_formatted_content(
        args.url, return_type=content_type, selector=args.selector
    )

    if result is None:
        sys.exit(1)

    result_str = result if isinstance(result, str) else str(result)

    if args.output:
        try:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(result_str)
            print(f"Contenido guardado en: {args.output}")
        except OSError as e:
            print(f"Error al guardar archivo: {e}", file=sys.stderr)
    else:
        print(result_str)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
    else:
        _run_gui()
