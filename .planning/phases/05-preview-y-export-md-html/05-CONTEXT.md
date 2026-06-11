# Phase 5: Preview y Export MD/HTML — Context

**Gathered:** 2026-06-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase reemplaza el área de resultado `ScrollView { Text }` de Phase 4 por un `WKWebView` que renderiza el contenido extraído, y añade exportación a `.md` y `.html` autocontenido con selector de formato visible antes de exportar.

**Entrega concreta:**
- `Views/WebPreviewView.swift` — `NSViewRepresentable` con `Coordinator` (`WKNavigationDelegate`) que señaliza `contentReady`
- `ContentView.swift` modificado — reemplaza `ScrollView { Text }` por `WebPreviewView`, añade fila de exportación debajo del WKWebView
- `ExtractionViewModel.swift` ampliado — nuevas propiedades `contentReady: Bool` y `exportFormat: String`, funciones `exportMarkdown()` y `exportHTML()` async con `NSSavePanel` y `generateHTML(content:outputType:)` para el template

**No pertenece a esta fase:** export PDF (`WKWebView.pdf(configuration:)`) — Phase 6. PDF aparece en el selector pero deshabilitado.

</domain>

<decisions>
## Implementation Decisions

### WKWebView — arquitectura (D-01 a D-04)

- **D-01:** `Views/WebPreviewView.swift` — archivo separado, `NSViewRepresentable` con `Coordinator` interno. ContentView lo usa como componente. Reutilizable en Phase 6 para PDF sin modificar ContentView.
- **D-02:** `contentReady` se señaliza via `WKNavigationDelegate.webView(_:didFinish:)` implementado en el Coordinator. Es el método oficial de Apple; no usar polling ni evaluateJavaScript.
- **D-03:** `WebPreviewView` recibe `@Binding var contentReady: Bool`. El Coordinator escribe `parent.contentReady = true` en `didFinish`. ContentView pasa `$vm.contentReady`. Patrón estándar NSViewRepresentable — sin acoplamiento directo Coordinator→ViewModel.
- **D-04:** HTML se carga en `updateNSView` cuando SwiftUI re-renderiza con nuevo `htmlContent: String?`. Si `htmlContent` cambia a un valor no-nil, llamar `webView.loadHTMLString(htmlContent, baseURL: nil)`. Si cambia a nil (nueva extracción iniciada), cargar string vacío y resetear `contentReady = false` vía el Binding.

### Markdown → HTML para preview (D-05 a D-06)

- **D-05:** El ViewModel genera HTML a partir de `resultContent` según `outputType`:
  - `outputType == "text"` → envolver en `<pre>` con CSS monoespaciado
  - `outputType == "markdown"` → HTML con `marked.js` bundled inline (~50 KB minificado); el script ejecuta `document.body.innerHTML = marked.parse(content)` tras cargar
  - `outputType == "html"` → cargar directamente el HTML tal cual
  - Propiedad computada en ViewModel: `var htmlForPreview: String? { ... }` — devuelve nil si `resultContent == nil`
- **D-06:** WKWebView reemplaza `ScrollView { Text }` para los **3 tipos** de salida (text, markdown, html). No se mantiene ScrollView como alternativa condicional. Un único `WebPreviewView` gestiona todos los estados.

### Format selector + botón Exportar (D-07 a D-10)

- **D-07:** Nueva `HStack` al final del VStack, **debajo del WKWebView**, con:
  - `Picker("Formato", selection: $vm.exportFormat)` — opciones MD / HTML / PDF, estilo `.segmented`
  - `Button("Exportar")` con ícono `square.and.arrow.up`
  Fila separada de la fila de extracción (Picker tipo + Botón Extraer) que ya existe arriba.
- **D-08:** `.disabled(!vm.contentReady)` en el botón Exportar. Cubre todos los estados anteriores a contentReady: vacío, extrayendo, WKWebView cargando. Satisface UI-03.
- **D-09:** El Picker muestra las 3 opciones MD / HTML / PDF desde Phase 5. PDF aparece con `.disabled(true)` (o deshabilitado condicionalmente). La opción PDF se habilitará en Phase 6. No usar tooltips "próximamente" — solo deshabilitar visualmente.
- **D-10:** `vm.contentReady` se resetea a `false` en `extract()` (D-09 de Phase 4 ya limpia `resultContent = nil`; añadir `contentReady = false` en el mismo bloque de limpieza).

### API de exportación (D-11 a D-14)

- **D-11:** `NSSavePanel` para ambas exportaciones MD y HTML — consistente con Phase 6 donde PDF también usa NSSavePanel para guardar `Data`. No usar SwiftUI `.fileExporter` (requeriría tipos `FileDocument` y cambia en Phase 6).
- **D-12:** Las funciones de exportación son `async` en el ViewModel y envuelven `NSSavePanel.begin(completionHandler:)` en `withCheckedContinuation`. ContentView llama `Task { await vm.export() }`. Patrón consistente con `extract()`.
- **D-13:** `generateHTML(content: String, outputType: String) -> String` en el ViewModel genera el HTML autocontenido con:
  - `font-family: -apple-system, BlinkMacSystemFont, sans-serif`
  - `max-width: 800px; margin: 0 auto; padding: 1em`
  - `@media (prefers-color-scheme: dark) { body { background: #1e1e1e; color: #d4d4d4; } }`
  - `@media print { body { max-width: none; } }`
  - `marked.js` inline (solo si `outputType == "markdown"`)
  - Sin assets externos — completamente autocontenido (EXPORT-03)
- **D-14:** El ViewModel expone `@Published var exportFormat: String = "markdown"` para el Picker de formato. Valores: `"markdown"`, `"html"`, `"pdf"`. La función `export()` hace switch sobre `exportFormat` para despachar `exportMarkdown()` o `exportHTML()` (PDF: no-op con nota en Phase 5).

### Claude's Discretion

- Nombre exacto del archivo del template HTML y si `generateHTML` es método de instancia o estático en ViewModel — Claude elige según coherencia con el patrón existente.
- Nombre sugerido para el NSSavePanel (derivado del título de la página vs. nombre fijo "export.md") — Claude usa heurística simple: los primeros 50 chars de `resultContent` sanitizados.
- Si `WebPreviewView` necesita un `@State` o `@StateObject` separado para la instancia `WKWebView` o puede crearla en `makeNSView` directamente — Claude decide según documentación NSViewRepresentable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 4 — UI de extracción (dependencia directa)
- `.planning/phases/04-swiftui-ui-de-extraccion/04-CONTEXT.md` — Decisiones D-01..D-13 que Phase 5 extiende (layout VStack, @StateObject, ExtractionViewModel)
- `ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift` — Archivo a modificar: reemplazar `ScrollView { Text }` por `WebPreviewView`, añadir fila export
- `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift` — Archivo a extender: `contentReady`, `exportFormat`, `export()`, `generateHTML()`

### Phase 3 — Bridge (dependencia transitiva)
- `ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift` — No modificar. `resultContent` llega de aquí vía ViewModel.

### Modelos Swift
- `ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionResult.swift` — `content: String?` es el string que entra en `generateHTML()`

### Requisitos y roadmap
- `.planning/REQUIREMENTS.md` — Requisitos UI-02, EXPORT-01, EXPORT-02, EXPORT-03
- `.planning/ROADMAP.md` — Phase 5 goal y success criteria

### Investigación previa
- `.planning/research/PITFALLS.md` — Pitfalls 4–8+ cubren WKWebView timing, NSSavePanel async, PDF data race
- `.planning/research/SUMMARY.md` — Stack additions: `WebKit.WKWebView`, `AppKit.NSSavePanel`, `SwiftUI.fileExporter` (descartado), deployment target macOS 13

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets (Phase 4)
- `ExtractionViewModel.extract()` — patrón `Task.detached + MainActor.run` reutilizable para `export()` async
- `ExtractionViewModel.isPythonPathError: Bool` — patrón @Published Bool para señales de estado; replicar para `contentReady`
- ContentView VStack estructura — añadir fila export al final, antes de `.frame(minWidth:)`
- `SettingsView.swift` — patrón NSViewRepresentable no existe aún; WebPreviewView será el primer NSViewRepresentable del proyecto

### Integration Points
- `vm.resultContent: String?` → `vm.htmlForPreview: String?` (propiedad computada o @Published derivado) → `WebPreviewView(htmlContent: vm.htmlForPreview, contentReady: $vm.contentReady)`
- `vm.contentReady` se pone a `false` en `extract()` (mismo bloque que `resultContent = nil`)
- `vm.contentReady` se pone a `true` en `WebPreviewView.Coordinator.webView(_:didFinish:)` vía Binding

### Nuevo archivo a crear
- `ExtractorApp/ExtractorApp/ExtractorApp/Views/WebPreviewView.swift` — carpeta `Views/` no existe aún; usar PBXFileSystemSynchronizedRootGroup (Xcode 16+) al igual que `ViewModels/`

</code_context>

<specifics>
## Specific Ideas

- `marked.js` versión 14.x minificada (~50 KB) se puede obtener del CDN o bundlear como constante Swift `let markedJS = "..."`. Para Phase 5, hardcodear la versión en el template es suficiente.
- El NSSavePanel puede inicializarse con `allowedContentTypes: [.plainText]` para MD y `[.html]` para HTML, y `nameFieldStringValue` con nombre sugerido sanitizado.
- `WebPreviewView` puede usar `WKWebViewConfiguration()` por defecto — no se necesita `WKUserContentController` para marked.js inline.

</specifics>

<deferred>
## Deferred Ideas

- Export PDF (`WKWebView.pdf(configuration:)`) — Phase 6. El Picker muestra la opción PDF deshabilitada en Phase 5.
- Botón de cancelación de extracción — post-v2.0 (ya en STATE.md deferred).
- Zoom / ajuste de escala en WKWebView — innecesario para v2.0.
- Toggle vista rendered/raw en WKWebView — diferido; texto plano con ScrollView podría ser útil pero es nueva funcionalidad.

</deferred>

---

*Phase: 05-preview-y-export-md-html*
*Context gathered: 2026-06-11*
