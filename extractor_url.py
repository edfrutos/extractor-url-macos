"""Punto de entrada para la CLI y GUI del Extractor de contenido web.

Este script proporciona una interfaz de línea de comandos (CLI) y una
interfaz gráfica de usuario (GUI) para interactuar con la lógica de
extracción definida en el módulo `core`.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import threading
import tkinter as tk
from datetime import datetime, timezone
from tkinter import filedialog, messagebox, ttk
from typing import Any, Optional, Union

from bs4 import BeautifulSoup, FeatureNotFound

from core import (
    extract_formatted_content,
    _fetch_raw,
    _extract_title,
    record_history_entry,
    PlaywrightSession,
)

# Traduce el --type de la CLI (nombres cortos) al return_type de core.py.
_CONTENT_TYPE_MAP = {
    "text": "text",
    "html": "html_string",
    "markdown": "markdown_structure",
}

# Mensaje de error uniforme cuando extract_formatted_content devuelve None.
_EXTRACTION_ERROR_MESSAGE = "No se pudo extraer el contenido de la URL."


def _lookup_title(
    url: str,
    timeout: int,
    use_cache: bool,
    js_mode: str = "auto",
    session: Optional[PlaywrightSession] = None,
) -> Optional[str]:
    """Extrae el <title> de una URL ya descargada (segunda llamada = hit de caché)."""
    raw_result = _fetch_raw(
        url, timeout=timeout, use_cache=use_cache, js_mode=js_mode, session=session,
    )
    if raw_result is None:
        return None
    html_text, _ = raw_result
    try:
        title_soup = BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        title_soup = BeautifulSoup(html_text, "html.parser")
    return _extract_title(title_soup, html_text)


def _resolve_js_mode(args: argparse.Namespace) -> str:
    """Traduce los flags --js/--no-js (mutuamente excluyentes) a js_mode."""
    if args.js:
        return "force"
    if args.no_js:
        return "off"
    return "auto"


def _copy_to_clipboard(text: str) -> None:
    """Copia `text` al portapapeles del sistema (macOS, vía `pbcopy`).

    Falla explícito (sys.exit(1)) si `pbcopy` no existe (plataforma no
    macOS) o si la copia falla — mismo principio de "fallar explícito" ya
    establecido en el proyecto (selector CSS inválido, --batch sin --json).
    """
    try:
        subprocess.run(["pbcopy"], input=text.encode("utf-8"), check=True)
    except FileNotFoundError:
        print(
            "Error: 'pbcopy' no está disponible — --clipboard requiere macOS.",
            file=sys.stderr,
        )
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error al copiar al portapapeles: {e}", file=sys.stderr)
        sys.exit(1)


def _history_entry(  # pylint: disable=too-many-arguments
    url: str,
    output_type: Optional[str],
    selector: Optional[str],
    status: str,
    *,
    char_count: Optional[int] = None,
    title: Optional[str] = None,
    error_message: Optional[str] = None,
) -> dict:
    """Construye una entrada de historial (sin el contenido extraído)."""
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "url": url,
        "output_type": output_type,
        "selector": selector,
        "status": status,
        "char_count": char_count,
        "title": title,
        "error_message": error_message,
    }


# ---------------------------------------------------------------------------
# Interfaz gráfica (tkinter)
# ---------------------------------------------------------------------------

class _ExtractorGui:  # pylint: disable=too-few-public-methods
    """Controla los widgets y acciones de la interfaz gráfica."""

    def __init__(self) -> None:
        self.root = tk.Tk()
        self.root.title("Extractor de contenido web")
        self.root.geometry("900x700")
        self.root.minsize(700, 520)

        self.url_var = tk.StringVar()
        self.selector_var = tk.StringVar()
        self.type_var = tk.StringVar(value="text")
        self.status_var = tk.StringVar(value="Listo")
        self.text_result: tk.Text
        self.extract_button: ttk.Button

        self._build_url_input()
        self._build_selector_input()
        self._build_type_options()
        self._build_action_bar()
        self.text_result = self._build_result_area()
        self.root.bind("<Return>", lambda _event: self._extract())
        self.root.bind("<Control-s>", lambda _event: self._save())

    def _build_url_input(self) -> None:
        """Construye el campo de URL."""
        frame = ttk.Frame(self.root, padding=10)
        frame.pack(fill=tk.X)
        ttk.Label(frame, text="URL:").pack(side=tk.LEFT)
        entry = ttk.Entry(frame, textvariable=self.url_var, width=60)
        entry.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        entry.focus()

    def _build_selector_input(self) -> None:
        """Construye el campo de selector CSS."""
        frame = ttk.Frame(self.root, padding=(10, 0, 10, 4))
        frame.pack(fill=tk.X)
        ttk.Label(frame, text="Selector CSS:").pack(side=tk.LEFT)
        ttk.Entry(frame, textvariable=self.selector_var, width=28).pack(
            side=tk.LEFT, padx=5
        )
        ttk.Label(
            frame,
            text="(opcional — ej: article, #content, .post-body)",
            foreground="gray",
        ).pack(side=tk.LEFT)

    def _build_type_options(self) -> None:
        """Construye las opciones de tipo de extracción."""
        frame = ttk.Frame(self.root, padding=(10, 0, 10, 8))
        frame.pack(fill=tk.X)
        ttk.Label(frame, text="Tipo:").pack(side=tk.LEFT)
        for label, value in (
            ("Texto limpio", "text"),
            ("HTML completo", "html_string"),
            ("Markdown", "markdown_structure"),
        ):
            ttk.Radiobutton(
                frame, text=label, variable=self.type_var, value=value
            ).pack(side=tk.LEFT, padx=5)

    def _build_action_bar(self) -> None:
        """Construye los botones y el indicador de estado."""
        frame = ttk.Frame(self.root, padding=(10, 0, 10, 10))
        frame.pack(fill=tk.X)
        self.extract_button = ttk.Button(
            frame, text="Extraer", command=self._extract
        )
        self.extract_button.pack(side=tk.LEFT, padx=5)
        ttk.Button(frame, text="Guardar…", command=self._save).pack(
            side=tk.LEFT, padx=5
        )
        ttk.Button(frame, text="Limpiar", command=self._clear).pack(
            side=tk.LEFT, padx=5
        )
        ttk.Label(frame, textvariable=self.status_var).pack(side=tk.RIGHT, padx=5)

    def _build_result_area(self) -> tk.Text:
        """Construye el área desplazable de resultado."""
        frame = ttk.Frame(self.root, padding=10)
        frame.pack(fill=tk.BOTH, expand=True)
        scrollbar = ttk.Scrollbar(frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        text_result = tk.Text(
            frame,
            wrap=tk.WORD,
            yscrollcommand=scrollbar.set,
            font=("Menlo", 10),
        )
        text_result.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=text_result.yview)
        return text_result

    def _on_result(self, result: Optional[Union[str, BeautifulSoup]]) -> None:
        """Actualiza la UI tras la extracción desde el hilo principal."""
        self.extract_button.config(state=tk.NORMAL)
        if result is None:
            self.status_var.set("Error al extraer")
            messagebox.showerror("Error", "No se pudo extraer el contenido de la URL.")
            return
        result_text = result if isinstance(result, str) else str(result)
        self.text_result.delete("1.0", tk.END)
        self.text_result.insert("1.0", result_text)
        self.status_var.set(f"Extraído — {len(result_text):,} caracteres")

    def _extract(self) -> None:
        """Inicia una extracción sin bloquear la interfaz."""
        url = self.url_var.get().strip()
        if not url:
            messagebox.showwarning("Aviso", "Introduce una URL válida.")
            return

        selector = self.selector_var.get().strip() or None
        return_type = self.type_var.get()
        self.extract_button.config(state=tk.DISABLED)
        self.status_var.set("Extrayendo…")

        def _worker() -> None:
            result = extract_formatted_content(
                url,
                return_type=return_type,
                selector=selector,
                timeout=30,
                use_cache=True,
            )
            if result is None:
                record_history_entry(
                    _history_entry(
                        url, return_type, selector, "error",
                        error_message="No se pudo extraer el contenido de la URL.",
                    )
                )
            else:
                result_text = result if isinstance(result, str) else str(result)
                record_history_entry(
                    _history_entry(
                        url, return_type, selector, "success",
                        char_count=len(result_text),
                    )
                )
            self.root.after(0, lambda: self._on_result(result))

        threading.Thread(target=_worker, daemon=True).start()

    def _save(self) -> None:
        """Guarda el resultado mostrado en un archivo."""
        content = self.text_result.get("1.0", tk.END).strip()
        if not content:
            messagebox.showwarning("Aviso", "No hay contenido para guardar.")
            return

        extensions = {
            "text": ".txt",
            "html_string": ".html",
            "markdown_structure": ".md",
        }
        ext = extensions.get(self.type_var.get(), ".txt")
        file_path = filedialog.asksaveasfilename(
            defaultextension=ext,
            filetypes=[("Archivos de texto", "*.*")],
        )
        if not file_path:
            return

        try:
            with open(file_path, "w", encoding="utf-8") as output_file:
                output_file.write(content)
            self.status_var.set(f"Guardado en {file_path}")
        except OSError as error:
            messagebox.showerror("Error", f"No se pudo guardar: {error}")

    def _clear(self) -> None:
        """Limpia el resultado mostrado."""
        self.text_result.delete("1.0", tk.END)
        self.status_var.set("Listo")

    def run(self) -> None:
        """Ejecuta el bucle principal de tkinter."""
        self.root.mainloop()


def _run_gui() -> None:
    """Inicia la interfaz gráfica tkinter."""
    _ExtractorGui().run()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _print_json_output(data: dict[str, Any]) -> None:
    """Imprime la salida en formato JSON y termina."""
    print(json.dumps(data, indent=2, ensure_ascii=False))
    sys.exit(0 if data.get("status") == "success" else 1)


def _success_payload(  # pylint: disable=too-many-arguments,too-many-positional-arguments
    url: str,
    selector: Optional[str],
    output_type: Optional[str],
    result_str: str,
    page_title: Optional[str],
) -> dict[str, Any]:
    """Construye el payload JSON de una extracción exitosa (--json/--batch)."""
    return {
        "status": "success",
        "url": url,
        "selector": selector,
        "output_type": output_type,
        "char_count": len(result_str),
        "content": result_str,
        "title": page_title,
    }


def _error_payload(url: str) -> dict[str, Any]:
    """Construye el payload JSON de una extracción fallida (--json/--batch)."""
    return {
        "status": "error",
        "url": url,
        "error_message": _EXTRACTION_ERROR_MESSAGE,
    }


def _build_parser() -> argparse.ArgumentParser:
    """Construye el parser de argumentos de la CLI."""
    parser = argparse.ArgumentParser(description="Extractor de contenido web")
    parser.add_argument(
        "url",
        nargs="?",
        default=None,
        help="URL de la página web (opcional si se usa --gui)",
    )
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
        "--timeout",
        type=int,
        default=15,
        help="Tiempo de espera para la petición en segundos (defecto: 15)",
    )
    parser.add_argument(
        "--no-cache",
        action="store_false",
        dest="use_cache",
        help="No utilizar la caché para esta petición",
    )
    js_group = parser.add_mutually_exclusive_group()
    js_group.add_argument(
        "--js",
        action="store_true",
        help=(
            "Fuerza el render con Playwright (Chromium headless), aunque "
            "la heurística automática no lo active"
        ),
    )
    js_group.add_argument(
        "--no-js",
        action="store_true",
        dest="no_js",
        help=(
            "Desactiva el fallback Playwright, aunque la heurística "
            "automática sí lo activaría"
        ),
    )
    parser.add_argument(
        "--no-images",
        action="store_true",
        help="Elimina las imágenes del contenido extraído",
    )
    parser.add_argument(
        "--no-links",
        action="store_true",
        help="Aplana los enlaces del contenido extraído (conserva el texto, sin URL)",
    )
    parser.add_argument(
        "--clipboard",
        action="store_true",
        help="Copia el resultado extraído al portapapeles del sistema (macOS, vía pbcopy)",
    )
    parser.add_argument(
        "--gui",
        action="store_true",
        help="Abrir interfaz gráfica",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Devolver la salida en formato JSON estructurado",
    )
    parser.add_argument(
        "--batch",
        metavar="ARCHIVO",
        help="Archivo con una URL por línea; procesa todas secuencialmente (requiere --json)",
    )
    parser.set_defaults(use_cache=True)
    return parser


def main() -> None:
    """Punto de entrada CLI."""
    args = _build_parser().parse_args()

    if args.batch:
        if not args.json:
            print("Error: --batch requiere --json.", file=sys.stderr)
            sys.exit(2)
        _run_batch(args)
        return

    if args.gui or args.url is None:
        _run_gui()
        return

    content_type = _CONTENT_TYPE_MAP.get(args.type, "text")
    js_mode = _resolve_js_mode(args)

    with PlaywrightSession() as session:
        # Llamada a la función importada desde core.py
        result = extract_formatted_content(
            args.url,
            return_type=content_type,
            selector=args.selector,
            timeout=args.timeout,
            use_cache=args.use_cache,
            js_mode=js_mode,
            no_images=args.no_images,
            no_links=args.no_links,
            session=session,
        )

        if result is None:
            record_history_entry(
                _history_entry(
                    args.url, args.type, args.selector, "error",
                    error_message=_EXTRACTION_ERROR_MESSAGE,
                )
            )
            if args.json:
                _print_json_output(_error_payload(args.url))
            sys.exit(1)

        result_str = result if isinstance(result, str) else str(result)

        if args.clipboard:
            _copy_to_clipboard(result_str)

        if args.json:
            page_title = _lookup_title(
                args.url, args.timeout, args.use_cache, js_mode=js_mode, session=session,
            )
            record_history_entry(
                _history_entry(
                    args.url, args.type, args.selector, "success",
                    char_count=len(result_str), title=page_title,
                )
            )
            _print_json_output(
                _success_payload(args.url, args.selector, args.type, result_str, page_title)
            )
            return

    record_history_entry(
        _history_entry(
            args.url, args.type, args.selector, "success",
            char_count=len(result_str),
        )
    )

    if args.output:
        try:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(result_str)
            print(f"Contenido guardado en: {args.output}")
        except OSError as e:
            print(f"Error al guardar archivo: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print(result_str)


def _run_batch(args: argparse.Namespace) -> None:
    """Procesa varias URLs desde un archivo, una por línea (requiere --json).

    Imprime un objeto JSON por línea (NDJSON) — uno por URL, en el mismo
    orden que aparecen en el archivo. Cada URL se procesa de forma
    independiente: si una falla, su línea refleja status "error" y el
    bucle continúa con la siguiente (nunca aborta las restantes).
    """
    content_type = _CONTENT_TYPE_MAP.get(args.type, "text")
    js_mode = _resolve_js_mode(args)

    try:
        with open(args.batch, "r", encoding="utf-8") as f:
            urls = [line.strip() for line in f if line.strip()]
    except OSError as e:
        print(f"Error al leer {args.batch}: {e}", file=sys.stderr)
        sys.exit(1)

    # Un único Chromium compartido entre todas las URLs del batch — evita
    # relanzarlo por cada SPA que necesite el fallback Playwright.
    with PlaywrightSession() as session:
        for url in urls:
            result = extract_formatted_content(
                url,
                return_type=content_type,
                selector=args.selector,
                timeout=args.timeout,
                use_cache=args.use_cache,
                js_mode=js_mode,
                no_images=args.no_images,
                no_links=args.no_links,
                session=session,
            )

            if result is None:
                record_history_entry(
                    _history_entry(
                        url, args.type, args.selector, "error",
                        error_message=_EXTRACTION_ERROR_MESSAGE,
                    )
                )
                print(json.dumps(_error_payload(url), ensure_ascii=False))
                continue

            result_str = result if isinstance(result, str) else str(result)

            if args.clipboard:
                _copy_to_clipboard(result_str)

            page_title = _lookup_title(
                url, args.timeout, args.use_cache, js_mode=js_mode, session=session,
            )

            record_history_entry(
                _history_entry(
                    url, args.type, args.selector, "success",
                    char_count=len(result_str), title=page_title,
                )
            )
            print(json.dumps(
                _success_payload(url, args.selector, args.type, result_str, page_title),
                ensure_ascii=False,
            ))


if __name__ == "__main__":
    main()
