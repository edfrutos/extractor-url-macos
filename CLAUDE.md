# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Idioma

Comunícate siempre en **español de España**. Mantén en inglés: nombres de librerías, comandos, errores literales y términos técnicos estándar.

## Arquitectura

Herramienta modular con `core.py`, `extractor_url.py` y carpeta `tests/` para validación automatizada local. Tres capas:

1. **Descarga y parseo (`core.py`)** — `_fetch_raw(url)` devuelve `(html_text, url_final)` y `_fetch_soup(url)` construye `BeautifulSoup` con fallback `lxml → html.parser`.
2. **Extracción y conversión (`core.py`)** — `extract_formatted_content(url, return_type, selector)` expone texto, HTML, `BeautifulSoup` o Markdown. El flujo Markdown usa `trafilatura` como primera opción y `markdownify` como fallback sobre `_clean_soup()` + `_main_content()`. Un selector CSS explícito inexistente o mal formado falla sin ampliar el contenido.
3. **Interfaces (`extractor_url.py`)** — `_ExtractorGui` + `main()` cubren GUI tkinter y CLI argparse. La GUI usa `threading.Thread` para no bloquear la ventana durante la extracción.

## Entorno

```bash
source .venv/bin/activate        # activar venv existente
pip install requests beautifulsoup4 lxml markdownify trafilatura pytest
```

## Ejecución

```bash
python extractor_url.py https://example.com                  # texto limpio (stdout)
python extractor_url.py https://example.com --type html      # HTML completo
python extractor_url.py https://example.com --type markdown  # estructura Markdown
python extractor_url.py https://example.com --type markdown --selector article
python extractor_url.py https://example.com -o salida.txt    # guardar en archivo
python extractor_url.py                                      # GUI tkinter
python extractor_url.py --gui                                # GUI tkinter (explícito)
```

## Linting y tipado

```bash
pylint extractor_url.py core.py    # usa .pylintrc local
mypy extractor_url.py core.py      # verificación de tipos
```

## Tests

La base de pruebas vive en `tests/test_converter.py` y `tests/test_cli.py`, con fixtures HTML locales en `tests/fixtures/`. Valida el conversor, selectores CSS, contratos JSON, apertura de GUI y caminos de error CLI sin depender de webs reales.

```bash
pytest tests/
pytest tests/ -k nombre_del_test -v
pytest tests/ --cov=extractor_url
```

Prioridad inmediata: ampliar esta base de tests antes de introducir nuevas mejoras funcionales en el extractor.

## Estilo de código

- Python 3, `from __future__ import annotations`, línea máx. 88 caracteres.
- Imports: stdlib → terceros → locales, separados por línea en blanco.
- Tipado completo en funciones públicas: `Optional[T]`, `Union[A, B]`.
- Errores en `sys.stderr`, retornar `None` en fallo, `sys.exit(1)` en CLI.
- Capturar excepciones específicas primero; `except Exception` solo en frontera CLI con `# pylint: disable=broad-exception-caught`.
- Commits: mensajes breves e imperativos en español (`Añade pruebas para extracción de URLs`).
