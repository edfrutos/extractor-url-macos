# AGENTS.md — extractor-url

Utilidad Python con CLI y GUI `tkinter` para extraer contenido legible desde
una URL como texto, HTML o Markdown.

## Idioma

Comunícate siempre en **español de España** en este repositorio, salvo que el
usuario pida otro idioma. Mantén en inglés nombres técnicos, comandos,
librerías, errores literales y términos estándar como `pytest`, `pylint`,
`requests`, `BeautifulSoup` y `pull request`.

## Arquitectura

El proyecto no es un paquete instalable. Los módulos viven en la raíz:

```text
extractor_url.py          # punto de entrada CLI y GUI
core.py                   # descarga, caché, limpieza y conversión
tests/                    # pruebas pytest de conversor/CLI y fixtures locales
.pylintrc                 # configuración local de Pylint
requirements.txt          # dependencias de ejecución
DESIGN.md                 # notas de diseño
extractor contenido url.md  # referencia histórica de implementación
```

Responsabilidades principales:

- `extractor_url.py`: parsea argumentos, presenta resultados, guarda archivos
  y ejecuta la GUI. Debe delegar la extracción en `core.py`.
- `core.py`: contiene la lógica reutilizable. `_fetch_raw()` descarga y
  gestiona caché; `extract_formatted_content()` es la API pública principal;
  `extract_html_structure_to_markdown()` usa `trafilatura` y hace fallback a
  `markdownify`.
- `tests/`: usa fixtures locales y `monkeypatch`. `test_converter.py` cubre el
  núcleo y `test_cli.py` cubre contratos CLI. No debe depender de webs reales.

La caché de ejecución se guarda en `~/.cache/extractor-url`. Evita que las
pruebas escriban allí: usa `use_cache=False`, `tmp_path` o mocks.

## Entorno

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install pytest pylint mypy
```

Dependencias de ejecución actuales: `requests`, `beautifulsoup4`, `lxml`,
`markdownify` y `trafilatura`.

## Ejecución

```bash
python extractor_url.py https://example.com
python extractor_url.py https://example.com --type html
python extractor_url.py https://example.com --type markdown
python extractor_url.py https://example.com --type markdown --selector article
python extractor_url.py https://example.com --timeout 30 --no-cache
python extractor_url.py https://example.com --json
python extractor_url.py https://example.com -o salida.txt
python extractor_url.py
python extractor_url.py --gui
```

## Verificación

```bash
pytest tests/
pytest tests/test_converter.py
pytest tests/test_cli.py
pytest tests/ -k nombre_del_test -v
pylint extractor_url.py core.py
mypy extractor_url.py core.py
python -m py_compile extractor_url.py core.py
```

Usa mocks de `_HTTP_SESSION.get`, `_fetch_raw` o funciones equivalentes para
pruebas deterministas. No hagas peticiones reales en pruebas unitarias.

## Estilo de código

- Python 3, indentación de 4 espacios y línea máxima de 88 caracteres.
- Usa `from __future__ import annotations` en todos los archivos Python nuevos.
- Ordena imports por stdlib, terceros y locales, separados por una línea.
- Usa `snake_case` para módulos, funciones y variables; `UPPER_CASE` para
  constantes; `PascalCase` para clases.
- Anota todas las funciones públicas. Sigue el estilo existente con
  `Optional[T]` y `Union[A, B]`.
- Usa docstrings con triple comilla doble en funciones públicas.
- Añade comentarios solo cuando expliquen una decisión no evidente.
- Mantén la lógica de extracción fuera de la CLI y la GUI.

## Errores y salida

- Captura excepciones específicas antes que genéricas.
- Imprime errores en `sys.stderr`, nunca en `stdout`.
- Las funciones de extracción retornan `None` cuando no pueden producir
  contenido.
- La CLI termina con código distinto de cero ante errores.
- Conserva `stdout` limpio para contenido y salida JSON.
- Mensajes de usuario, ayudas CLI y documentación deben estar en español de
  España.

## Cambios y commits

- Mantén los cambios acotados y no reviertas modificaciones locales ajenas.
- Añade o ajusta tests cuando cambie el comportamiento de `core.py` o la CLI.
- Un cambio lógico por commit.
- Usa mensajes breves e imperativos en español, por ejemplo:
  `Añade pruebas para extracción de URLs`.
