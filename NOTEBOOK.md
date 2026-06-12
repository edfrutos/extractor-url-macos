# NOTEBOOK.md — extractor-url

Estado técnico, decisiones y prioridades del proyecto.

Última revisión: 9 de junio de 2026.

## 1. Objetivo actual

`extractor-url` es una utilidad local en Python para descargar una URL y
devolver contenido como texto limpio, HTML o Markdown.

La prioridad vigente es **estabilizar el extractor y su CLI** antes de abordar
empaquetado para macOS o una interfaz SwiftUI. La visión de una aplicación
nativa se mantiene como evolución futura, no como siguiente fase inmediata.

## 2. Arquitectura actual

| Módulo | Responsabilidad |
|---|---|
| `core.py` | Descarga HTTP, reintentos, caché, limpieza DOM y conversión. |
| `extractor_url.py` | Punto de entrada, CLI `argparse` y controlador GUI `tkinter`. |
| `tests/test_converter.py` | Pruebas del conversor sobre fixtures locales. |
| `tests/fixtures/` | HTML determinista para pruebas sin red real. |

El proyecto no es un paquete instalable. Los módulos Python viven en la raíz.

### Flujo de extracción

1. `_fetch_raw()` normaliza la URL, consulta la caché y descarga mediante una
   `requests.Session` con `urllib3.Retry`.
2. `_fetch_soup()` construye `BeautifulSoup` con fallback de `lxml` a
   `html.parser`.
3. `extract_formatted_content()` entrega texto, HTML, `BeautifulSoup` o delega
   la conversión Markdown.
4. `extract_html_structure_to_markdown()` usa `trafilatura` y hace fallback a
   `markdownify` sobre contenido limpio.

La caché se guarda en `~/.cache/extractor-url`.

## 3. Funcionalidad implementada

- Extracción como texto, HTML y Markdown.
- Selector CSS opcional mediante `--selector`.
- Timeout configurable mediante `--timeout`.
- Caché activa por defecto y desactivable mediante `--no-cache`.
- Reintentos HTTP para estados `429`, `500`, `502`, `503` y `504`.
- Salida JSON estructurada mediante `--json`.
- Escritura a archivo mediante `-o/--output`.
- Errores explícitos para selector CSS inválido y fallo de escritura.
- GUI `tkinter`; puede abrirse con `--gui` o sin URL posicional.
- Controlador `_ExtractorGui` con construcción y callbacks separados.
- Extracción de la GUI en un hilo para no bloquear la interfaz.
- Tests deterministas con fixtures HTML locales.

Dependencias de ejecución actuales:

```text
beautifulsoup4
lxml
markdownify
requests
trafilatura
```

## 4. Estado de verificación

Comandos ejecutados durante la revisión del 9 de junio de 2026:

```bash
pytest tests/ -q
python -m py_compile extractor_url.py core.py tests/test_converter.py tests/test_cli.py tests/conftest.py
PYLINTHOME=/tmp/extractor-url-pylint .venv/bin/pylint extractor_url.py core.py
```

Resultados:

- `pytest`: **14 passed**.
- `py_compile`: correcto.
- `pylint` de módulos de producción: **10.00/10**.
- `pylint` ya está instalado en `.venv` (`pylint 4.0.5`).

No quedan avisos de `pylint` en `extractor_url.py` ni `core.py`.

La suite cubre limpieza DOM, detección de contenido principal, normalización
Markdown, selector CSS, URLs relativas, fallback de conversión y los contratos
principales de la CLI.

## 5. Riesgos y gaps activos

### Gaps activos

1. La caché no tiene política de expiración ni comando de limpieza.
2. La GUI no dispone de tests automatizados de interacción con widgets.

### Trabajo diferido

- Renderizado de páginas JavaScript con `playwright`.
- Flags `--no-images`, `--no-links` y `--clipboard`.
- Empaquetado `.app`, firma y notarización.
- Interfaz nativa SwiftUI.

## 6. Roadmap vigente

La fuente de verdad detallada es `.planning/ROADMAP.md`.

### Fase 1 — Validación automática del conversor

Estado: **completada**.

- Fixtures HTML locales.
- Pruebas deterministas del pipeline Markdown.
- Ejecución de `pytest tests/` desde la raíz.
- Documentación técnica alineada con el conversor.

### Fase 2 — Robustez CLI y manejo explícito de errores

Estado: **completada**.

Objetivos:

- `--gui` funciona sin URL posicional.
- Los fallos de guardado terminan con exit code distinto de cero.
- Los selectores CSS inexistentes o mal formados fallan explícitamente.
- La interfaz pública CLI y sus caminos de error principales tienen tests.

## 7. Criterios de implementación

- Mantener `core.py` independiente de CLI y GUI.
- No realizar peticiones reales en tests unitarios.
- Mockear `_fetch_raw`, `_HTTP_SESSION.get` o la frontera equivalente.
- Mantener `stdout` reservado para contenido o JSON; enviar errores a
  `stderr`.
- Añadir tests al cambiar contratos públicos o comportamiento de errores.
- No iniciar el frontend SwiftUI hasta estabilizar la CLI que actuará como
  puente.

## 8. Comandos habituales

```bash
source .venv/bin/activate
pip install -r requirements.txt

python extractor_url.py https://example.com --type markdown
python extractor_url.py https://example.com --json --no-cache
python extractor_url.py --gui

pytest tests/
.venv/bin/pylint extractor_url.py core.py
python -m py_compile extractor_url.py core.py
```
