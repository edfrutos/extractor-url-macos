# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Idioma

Comunícate siempre en **español de España**. Mantén en inglés: nombres de librerías, comandos, errores literales y términos técnicos estándar.

## Arquitectura

Herramienta de un solo archivo (`extractor_url.py`) sin paquete ni carpeta `tests/`. Tres capas:

1. **`_fetch_soup(url)`** — descarga la URL y devuelve un `BeautifulSoup`. Maneja `https://` implícito, `User-Agent` de navegador, y fallback `lxml → html.parser`.
2. **`extract_formatted_content(url, return_type)`** — API pública. `return_type` acepta `"text"`, `"html_string"`, `"soup_object"` o `"markdown_structure"` (esta última delega a `extract_html_structure_to_markdown`).
3. **`_run_gui()`** + **`main()`** — GUI tkinter y CLI argparse. El punto de entrada `__main__` arranca la GUI si no hay argumentos CLI.

## Entorno

```bash
source .venv/bin/activate        # activar venv existente
pip install requests beautifulsoup4 lxml   # instalar dependencias
```

## Ejecución

```bash
python extractor_url.py https://example.com                  # texto limpio (stdout)
python extractor_url.py https://example.com --type html      # HTML completo
python extractor_url.py https://example.com --type markdown  # estructura Markdown
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

No hay directorio `tests/` aún. Cuando se creen, usar mocks de `requests.get` (no webs reales):

```bash
pytest tests/ -k nombre_del_test -v
pytest tests/ --cov=extractor_url
```

## Estilo de código

- Python 3, `from __future__ import annotations`, línea máx. 88 caracteres.
- Imports: stdlib → terceros → locales, separados por línea en blanco.
- Tipado completo en funciones públicas: `Optional[T]`, `Union[A, B]`.
- Errores en `sys.stderr`, retornar `None` en fallo, `sys.exit(1)` en CLI.
- Capturar excepciones específicas primero; `except Exception` solo en frontera CLI con `# pylint: disable=broad-exception-caught`.
- Commits: mensajes breves e imperativos en español (`Añade pruebas para extracción de URLs`).
