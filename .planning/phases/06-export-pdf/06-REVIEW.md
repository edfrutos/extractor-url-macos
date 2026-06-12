---
status: issues
phase: 06-export-pdf
depth: standard
reviewed: 2026-06-12
files_reviewed: 9
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
reviewer: inline (orchestrator — subagent quota exhausted)
---

# Code Review — Phase 06: Export PDF

**Ámbito:** diff `236e301..HEAD` — core.py, extractor_url.py, ContentView.swift,
ExtractionResult.swift, ExtractionViewModel.swift, WebPreviewView.swift,
ViewModelTests.swift, tests/test_cli.py, tests/test_extract_title.py.

**Veredicto global:** sin hallazgos críticos. La implementación es correcta y
verificada por humano (PDF con imágenes, texto seleccionable, modo claro). Dos
avisos de robustez/fidelidad y tres notas menores.

## Findings

### WR-01 — Doble fetch para extraer el título en el path `--json`

**Archivo:** extractor_url.py:291-301
**Severidad:** Warning

`main()` llama a `_fetch_raw(args.url, ...)` una segunda vez solo para extraer
el título. El comentario asume hit de caché, pero si el usuario invoca con la
caché desactivada se produce una segunda petición de red completa, y existe una
ventana de carrera en la que el HTML de la segunda descarga puede no coincidir
con el contenido ya extraído (título inconsistente con el contenido).

**Sugerencia:** propagar el `html_text` de la extracción original (o devolver el
título desde `extract_formatted_content`) en lugar de re-descargar.
**Impacto:** bajo en la práctica (la app Swift usa caché por defecto); corregir
cuando se toque de nuevo el contrato JSON.

### WR-02 — `baseURL: https://localhost` no resuelve URLs root-relative

**Archivo:** WebPreviewView.swift:34-39
**Severidad:** Warning

El fix de imágenes usa `https://localhost` como base, lo que resuelve URLs
protocol-relative (`//cdn/img.png`) pero rompe las root-relative
(`/img/foo.png` → `https://localhost/img/foo.png`, 404). No es regresión (con
`baseURL: nil` tampoco cargaban), pero usar la URL original de la página
extraída como `baseURL` daría fidelidad completa.

**Sugerencia:** `webView.loadHTMLString(html, baseURL: URL(string: vm.urlString))`
(con fallback a `https://localhost` si la URL no parsea).

### IN-01 — Import de símbolos privados entre módulos

**Archivo:** extractor_url.py:20
**Severidad:** Info

`from core import extract_formatted_content, _fetch_raw, _extract_title`
importa dos símbolos con prefijo de privado. Funciona y es el patrón ya usado
en los tests, pero si `_extract_title` forma parte del contrato público del
CLI, merece nombre público (`extract_title`) en una futura limpieza.

### IN-02 — `suggestedFilename` puede dejar guiones en los extremos

**Archivo:** ExtractionViewModel.swift (suggestedFilename, rama title)
**Severidad:** Info

La rama del título recorta espacios pero no guiones tras sustituir caracteres,
de modo que un título como `Hola: mundo!` produce `Hola--mundo-.pdf`. Cosmético;
la rama de fallback sí recorta guiones.

### IN-03 — `except Exception` en core._extract_title

**Archivo:** core.py (camino 2 de _extract_title)
**Severidad:** Info

El estilo del proyecto reserva `except Exception` para la frontera CLI. Aquí
está justificado (trafilatura puede lanzar excepciones variadas) y lleva el
`pylint: disable` correspondiente, pero podría acotarse a las excepciones
documentadas de trafilatura si se conocen.

## Sin hallazgos en

- Gestión de memoria del closure `webViewProvider` (capture `[weak coordinator]` correcto, sin ciclo de retención).
- Restauración de apariencia con `defer` (cubre éxito y error).
- Sondeo JS de imágenes con timeout 5 s y fail-open razonable.
- Escritura atómica del PDF (`options: .atomic`).
- Retrocompatibilidad del modelo `ExtractionResult` (campo `title` opcional).
- Sanitización de path traversal en el nombre sugerido.
