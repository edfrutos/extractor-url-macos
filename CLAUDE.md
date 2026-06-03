# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Idioma

Comunícate siempre en **español de España**. Mantén en inglés: nombres de librerías, comandos, errores literales y términos técnicos estándar.

## Arquitectura

Herramienta de un solo archivo (`extractor_url.py`) con carpeta `tests/` para validación automatizada local. Tres capas:

1. **Descarga y parseo** — `_fetch_raw(url)` devuelve `(html_text, url_final)` y `_fetch_soup(url)` construye `BeautifulSoup` con fallback `lxml → html.parser`.
2. **Extracción y conversión** — `extract_formatted_content(url, return_type, selector)` expone texto, HTML, `BeautifulSoup` o Markdown. El flujo Markdown usa `trafilatura` como primera opción y `markdownify` como fallback sobre `_clean_soup()` + `_main_content()`. También soporta `selector` CSS explícito.
3. **Interfaces** — `_run_gui()` + `main()` cubren GUI tkinter y CLI argparse. La GUI usa `threading.Thread` para no bloquear la ventana durante la extracción.

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
pylint extractor_url.py    # usa .pylintrc local (ignora ficheros kilo-format-temp-*)
mypy extractor_url.py      # verificación de tipos
```

## Tests

La base de pruebas actual vive en `tests/test_converter.py` con fixtures HTML locales en `tests/fixtures/`. Las pruebas validan limpieza DOM, detección de contenido principal, postprocesado Markdown y el flujo con `selector` CSS sin depender de webs reales.

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
