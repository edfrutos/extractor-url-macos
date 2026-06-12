# Phase 6: Export PDF - Context

**Gathered:** 2026-06-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase habilita la opción PDF del Picker de exportación (visible y deshabilitada desde Phase 5) para exportar el contenido renderizado en el WKWebView del preview como PDF vectorial con texto seleccionable, vía `WKWebView.pdf(configuration:)` (async, macOS 13+) y `NSSavePanel`. Incluye la ampliación del contrato JSON del CLI Python con el campo `title` para derivar el nombre de archivo sugerido.

**Entrega concreta:**
- `extractor_url.py` / `core.py` — el modo `--json` incluye `title` (el `<title>` de la página) en la salida
- `Models/ExtractionResult.swift` — campo opcional `title: String?`
- `ExtractionViewModel.swift` — `exportPDF()` async, rama `"pdf"` de `export()` activada, `suggestedFilename` unificado con `title`
- `ContentView.swift` — quitar `.disabled(true)` de la opción PDF del Picker
- `WebPreviewView.swift` / acceso al WKWebView visible — mecanismo para que el export invoque `.pdf()` sobre el webview del preview

**No pertenece a esta fase:** universal binary, firma y empaquetado (.dmg) — Phase 7. Paginado A4/imprimible — fuera de v2.0.

</domain>

<decisions>
## Implementation Decisions

### Origen del render (D-01, D-02)
- **D-01:** El PDF se genera desde el **WKWebView visible del preview** (no un webview offscreen dedicado). WYSIWYG real, `contentReady` ya protege el timing, sin render duplicado. Se necesita un mecanismo para que el ViewModel/export alcance el webview (el Coordinator ya guarda `weak var webView`).
- **D-02:** **WYSIWYG estricto**: el ancho del PDF sigue al ancho de la ventana en el momento de exportar. No se fuerza ancho mínimo de captura — la ventana ya tiene `minWidth: 500` y el CSS limita el texto a 800px.

### Formato y apariencia (D-03, D-04)
- **D-03:** **Página única continua** — comportamiento natural de `WKWebView.pdf()`: un PDF vectorial de una sola página con todo el contenido. Garantiza texto seleccionable y cero páginas en blanco (Success Criteria 2). No paginar A4 (exigiría NSPrintOperation, contradiciendo la decisión de milestone).
- **D-04:** **Forzar modo claro siempre** en el PDF: fondo blanco, texto negro, independientemente del tema del sistema. Implica override temporal de la apariencia del WKWebView visible durante la captura (p.ej. `appearance = NSAppearance(named: .aqua)` antes de `.pdf()` y restaurar después) — el mecanismo exacto lo determina el research.

### Nombre sugerido (D-05, D-06, D-07)
- **D-05:** **Añadir `title` al contrato JSON** del CLI Python: el modo `--json` incluye el `<title>` de la página; `ExtractionResult` gana el campo opcional `title: String?` (con `CodingKeys` si procede). Toca Python + Swift + tests de ambos lados.
- **D-06:** **Los tres formatos** (MD, HTML, PDF) usan el título como nombre sugerido: unificar `suggestedFilename()` para que prefiera `title` saneado.
- **D-07:** **Fallback** cuando no haya `<title>` o venga vacío: prefijo del contenido (primeros 50 chars sanitizados — heurística verificada de Phase 5); si también vacío, `"export"`.

### Feedback de errores (D-08, D-09)
- **D-08:** **Alerta visible (NSAlert)** si la generación o el guardado del PDF falla — un fallo silencioso significa perder un documento sin enterarse. MD/HTML mantienen su patrón `print()` de Phase 5 (no se tocan).
- **D-09:** **Sin indicador de progreso** durante la generación: `WKWebView.pdf()` sobre contenido ya renderizado es sub-segundo; el NSSavePanel ya marca el flujo.

### Claude's Discretion
- Mecanismo exacto para exponer el WKWebView del preview al flujo de export (referencia vía Coordinator, callback, o registro en el ViewModel) — elegir lo que menos acople añada.
- Detalle del override de apariencia para forzar modo claro (D-04) y su restauración segura.
- Estructura del NSAlert (título/mensaje) y wording exacto en español.
- Cómo extrae el `<title>` el lado Python (BeautifulSoup `soup.title` vs trafilatura metadata) — mantener compatibilidad con los dos caminos de extracción.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 5 — preview y export (dependencia directa)
- `.planning/phases/05-preview-y-export-md-html/05-CONTEXT.md` — Decisiones D-01..D-14 que Phase 6 extiende (NSSavePanel + withCheckedContinuation, exportFormat, contentReady)
- `ExtractorApp/ExtractorApp/ExtractorApp/Views/WebPreviewView.swift` — Coordinator con `weak var webView: WKWebView?` y señalización contentReady; punto de acceso al webview visible (D-01)
- `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift` — `export()` con rama "pdf" no-op a activar; `exportMarkdown()`/`exportHTML()` como patrón; `suggestedFilename()` a unificar (D-06)
- `ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift` — `Text("PDF").tag("pdf").disabled(true)` a habilitar

### Contrato JSON Python ↔ Swift (D-05)
- `extractor_url.py` — CLI con `--json`; añadir `title` a la salida
- `core.py` — motor de extracción; origen del `<title>`
- `ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionResult.swift` — struct Codable SIN campo title actualmente (verificado 2026-06-12)
- `tests/test_cli.py` — tests del contrato JSON a ampliar

### Requisitos y roadmap
- `.planning/REQUIREMENTS.md` — EXPORT-04 (único requisito de la fase)
- `.planning/ROADMAP.md` — Phase 6 goal y 3 success criteria

### Investigación previa
- `.planning/research/PITFALLS.md` — pitfalls de WKWebView timing y PDF data race
- `ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift` — suite existente (7 tests) a extender

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `exportMarkdown()`/`exportHTML()` — patrón completo NSSavePanel + `withCheckedContinuation` + escritura con do/catch; `exportPDF()` lo replica escribiendo `Data` en vez de `String`
- `WebPreviewView.Coordinator.webView` (weak) — referencia viva al WKWebView visible, candidata para D-01
- `suggestedFilename(from:extension:)` — heurística de fallback ya verificada (D-07)
- `ViewModelTests` + target `ExtractorAppTests` — infraestructura de tests lista

### Established Patterns
- `contentReady` vía `WKNavigationDelegate.didFinish` — el botón Exportar ya está gated; PDF hereda la protección sin trabajo extra (Success Criteria 1)
- Contrato JSON snake_case → CodingKeys (`output_type`, `char_count`) — `title` no necesita mapping pero sigue el mismo patrón
- Errores Python en `sys.stderr`, contrato JSON con `status`/`error_message`

### Integration Points
- `export()` switch: `case "pdf": await exportPDF()` reemplaza el `break`
- `ContentView` Picker: quitar `.disabled(true)` del tag "pdf"
- `PythonBridge` decodifica `ExtractionResult` — campo opcional `title` es retrocompatible (decode tolerante)
- El ViewModel necesita conservar `title` del último resultado (hoy solo guarda `result?.content`)

</code_context>

<specifics>
## Specific Ideas

- Comentario existente en `WebPreviewView.Coordinator.didFinish`: "Para preview no hace falta delay; Phase 6 (PDF) sí lo necesitará" — el research debe validar si se necesita delay/espera adicional antes de `.pdf()` para evitar PDFs en blanco (pitfall conocido).
- `NSSavePanel` para PDF: `allowedContentTypes = [.pdf]` (UTType.pdf sí existe en el SDK, a diferencia de markdown).

</specifics>

<deferred>
## Deferred Ideas

- Paginado A4 con márgenes para impresión — fuera de v2.0; la página única continua cubre el caso de archivo digital.
- Indicador de progreso / estado `isExporting` con botón deshabilitado durante export — descartado para v2.0 (D-09).
- Subir MD/HTML a alerta visible de error — se mantiene `print()`; reconsiderar si molesta en uso real.

</deferred>

---

*Phase: 06-export-pdf*
*Context gathered: 2026-06-12*
