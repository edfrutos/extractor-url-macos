# Phase 5: Preview y Export MD/HTML — Research

**Researched:** 2026-06-11
**Domain:** WebKit / AppKit — WKWebView NSViewRepresentable, NSSavePanel async, marked.js bundled, UTType
**Confidence:** HIGH (APIs Apple verificadas contra SDK headers + documentación oficial; marked.js verificado contra paquete npm instalado)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**WKWebView — arquitectura (D-01 a D-04)**
- D-01: `Views/WebPreviewView.swift` — NSViewRepresentable con Coordinator interno
- D-02: `contentReady` via `WKNavigationDelegate.webView(_:didFinish:)`
- D-03: `@Binding var contentReady: Bool` en WebPreviewView — Coordinator escribe `parent.contentReady = true`
- D-04: HTML se carga en `updateNSView` cuando `htmlContent: String?` cambia a no-nil; nil → cargar string vacío y resetear `contentReady = false`

**Markdown → HTML para preview (D-05 a D-06)**
- D-05: `var htmlForPreview: String?` — propiedad computada en ViewModel según `outputType`: text → `<pre>`, markdown → marked.js bundled inline, html → directo
- D-06: WKWebView para los 3 tipos de salida (text, markdown, html) — sin ScrollView alternativo

**Format selector + botón Exportar (D-07 a D-10)**
- D-07: HStack debajo del WKWebView con Picker segmented (MD/HTML/PDF) + Botón Exportar
- D-08: `.disabled(!vm.contentReady)` en botón Exportar
- D-09: PDF en Picker pero `.disabled(true)` — se habilita en Phase 6
- D-10: `vm.contentReady = false` en `extract()` junto con `resultContent = nil`

**API de exportación (D-11 a D-14)**
- D-11: NSSavePanel para MD y HTML — no SwiftUI `.fileExporter`
- D-12: Funciones `exportMarkdown()` y `exportHTML()` son `async` con `withCheckedContinuation`
- D-13: `generateHTML(content:outputType:)` genera HTML autocontenido con CSS hardcodeado en ViewModel
- D-14: `@Published var exportFormat: String = "markdown"` — switch en `export()` despacha MD/HTML/PDF

### Claude's Discretion
- Nombre exacto del archivo template HTML y si `generateHTML` es método de instancia o estático
- Nombre sugerido NSSavePanel: primeros 50 chars de `resultContent` sanitizados
- Si `WebPreviewView` necesita `@State` o `@StateObject` para la instancia `WKWebView` o puede crearla en `makeNSView` directamente

### Deferred Ideas (OUT OF SCOPE)
- Export PDF (`WKWebView.pdf(configuration:)`) — Phase 6
- Botón de cancelación de extracción — post-v2.0
- Zoom / ajuste de escala en WKWebView
- Toggle vista rendered/raw en WKWebView
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| UI-02 | El usuario puede previsualizar el contenido extraído en un `WKWebView` (`NSViewRepresentable`) | D-01..D-06: NSViewRepresentable pattern, Coordinator, WKNavigationDelegate, marked.js bundle |
| EXPORT-01 | El usuario selecciona el formato de salida (MD / HTML / PDF) con un selector antes de exportar | D-07, D-09: Picker segmented con PDF deshabilitado |
| EXPORT-02 | Export `.md` guarda el contenido íntegro extraído sin transformaciones vía `NSSavePanel` | D-11, D-12: NSSavePanel async con withCheckedContinuation, UTType para .md |
| EXPORT-03 | Export `.html` genera un único archivo autocontenido con CSS inline, dark mode, sin dependencias externas | D-13: generateHTML template con @media dark mode, marked.js inline |
</phase_requirements>

---

## Summary

Esta fase introduce dos capacidades nuevas sobre la base de Phase 4: (1) reemplazar `ScrollView { Text }` por un `WKWebView` embebido via `NSViewRepresentable` que renderiza el contenido extraído (texto, Markdown renderizado, HTML), y (2) exportar ese contenido a archivo `.md` o `.html` autocontenido mediante `NSSavePanel` asíncrono.

El stack es 100% Apple frameworks — `WebKit` y `AppKit` — más `marked.js` 18.0.5 bundleado como string literal Swift. No hay dependencias de paquetes externos en Swift Package Manager ni CocoaPods. El archivo `marked.umd.js` pesa **42 KB sin minificar** (formato UMD, válido para ejecución en `<script>` inline), confirmado tras instalación del paquete npm. `marked.parse(string)` devuelve un `String` HTML de forma síncrona en v18 cuando no se configura `async: true`.

El riesgo técnico más relevante de esta fase es la combinación de `updateNSView` (llamado frecuentemente por SwiftUI, incluso en hover events) con `loadHTMLString` — sin un guard de "mismo contenido que antes", cada re-render de SwiftUI dispararía una carga nueva, reseteando `contentReady` y produciendo un ciclo de parpadeo. El segundo riesgo es `UTType` para Markdown: **`UTTypeMarkdown` no existe en el SDK de sistema** (verificado contra `UTCoreTypes.h` del SDK macOS 15.4) — el fallback a `.plainText` con `nameFieldStringValue` terminado en `.md` es la única ruta segura.

**Recomendación principal:** El Coordinator debe almacenar el último `htmlContent` cargado y en `updateNSView` solo llamar a `loadHTMLString` cuando el string cambia. Para NSSavePanel usar `begin(completionHandler:)` (panel independiente) dentro de un `@MainActor func` con `withCheckedContinuation`.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Renderizado visual del contenido | WKWebView (WebKit) | ViewModel (genera HTML) | WKWebView es el único renderer HTML/Markdown disponible en macOS sin dependencias adicionales |
| Generación del template HTML | ViewModel (Swift) | — | El ViewModel posee `outputType` y `resultContent`; centralizar `generateHTML` aquí evita acoplar la View con lógica de presentación |
| Señalización `contentReady` | Coordinator (WKNavigationDelegate) | ViewModel vía @Binding | El delegate es el único punto donde WebKit notifica fin de carga; el Binding escala el evento al ViewModel sin acoplamiento directo |
| Exportación a archivo | ViewModel async | AppKit NSSavePanel | El ViewModel orquesta: abre panel (MainActor), recibe URL, escribe archivo. NSSavePanel es el componente AppKit que gestiona el diálogo |
| Selector de formato export | ContentView (SwiftUI View) | ViewModel (@Published exportFormat) | El Picker es UI pura; el estado canónico del formato seleccionado vive en el ViewModel |
| CSS del contenido renderizado | ViewModel / generateHTML | WKWebView renderiza | El CSS está hardcodeado en Swift (D-13); WebKit aplica `@media (prefers-color-scheme: dark)` automáticamente |

---

## Standard Stack

### Core

| Framework / Componente | Versión | Propósito | Por qué es el estándar |
|------------------------|---------|-----------|------------------------|
| `WebKit.WKWebView` | macOS 13+ | Renderizado HTML/CSS/JS | Único WebView moderno de Apple con soporte JS, CSS moderno, dark mode automático y `WKNavigationDelegate` |
| `SwiftUI.NSViewRepresentable` | macOS 13+ | Bridge SwiftUI ↔ AppKit | Patrón oficial Apple para embeber vistas AppKit en SwiftUI |
| `WebKit.WKNavigationDelegate` | macOS 13+ | Detectar fin de carga | API oficial; `webView(_:didFinish:)` es el único callback fiable para "DOM parseado y JS ejecutado" |
| `AppKit.NSSavePanel` | macOS 13+ | Diálogo de guardado nativo | Más control que `.fileExporter` SwiftUI; necesario para Phase 6 PDF (Data raw); consistente entre fases |
| `marked.js` UMD | 18.0.5 (42 KB) | Parser Markdown → HTML inline | Bundleado como constante Swift; JavaScript habilitado por defecto en WKWebView sin configuración extra |

### Supporting

| Componente | Propósito | Cuándo usar |
|------------|-----------|-------------|
| `UniformTypeIdentifiers.UTType.html` | `allowedContentTypes` para export HTML | Export HTML — UTType nativo del sistema [VERIFIED: UTCoreTypes.h SDK macOS 15.4] |
| `UniformTypeIdentifiers.UTType.plainText` | Fallback para export Markdown | `.md` no tiene UTType nativo en el SDK; usar `.plainText` + `nameFieldStringValue = "nombre.md"` |
| `Swift.withCheckedContinuation` | Envolver NSSavePanel callback en async/await | Única función de exportación async; patrón oficial Swift Concurrency |

### Alternativas consideradas

| En lugar de | Podría usarse | Tradeoff |
|-------------|---------------|----------|
| `NSSavePanel` | `SwiftUI.fileExporter` | `fileExporter` requiere `FileDocument` conformance y cambia completamente en Phase 6 (PDF es `Data`, no `FileDocument`). NSSavePanel es más verboso pero consistente entre fases |
| `marked.js` bundled | Renderizado server-side en Python / `AttributedString` | Python no tiene acceso directo al WKWebView; `AttributedString` no renderiza GFM completo. `marked.js` es la única opción inline viable |
| `WKWebView` para todo | `ScrollView { Text }` para texto plano | D-06 ya decide: un único WKWebView para los 3 tipos. Simplifica el árbol de vistas y la lógica de estado |

**Instalación:** No aplica — todos los frameworks son del sistema. `marked.umd.js` se copia como constante Swift desde `/tmp/marked-check/node_modules/marked/lib/marked.umd.js` (42 KB).

---

## Package Legitimacy Audit

Esta fase **no instala paquetes externos en Swift** (sin SPM, sin CocoaPods, sin npm en producción). `marked.js` se bundlea como constante `String` hardcodeada en el ViewModel — no es una dependencia de paquete.

| Componente | Tipo | Origen | Verificación | Disposición |
|------------|------|--------|--------------|-------------|
| `WebKit.framework` | Apple system framework | macOS SDK | Framework de sistema — no requiere auditoría | Aprobado |
| `AppKit.framework` | Apple system framework | macOS SDK | Framework de sistema — no requiere auditoría | Aprobado |
| `marked.umd.js` v18.0.5 | JS bundled como String | `npm view marked` → 18.0.5 publicado 2026-06-04; repo oficial [github.com/markedjs/marked](https://github.com/markedjs/marked) | [VERIFIED: npm registry] archivo UMD de 42 KB confirmado tras `npm install marked` | Aprobado — bundlear `lib/marked.umd.js` |

**Paquetes eliminados por slopcheck:** ninguno (slopcheck no aplica a esta fase).

---

## Architecture Patterns

### System Architecture Diagram

```
ContentView (SwiftUI @MainActor)
    │
    ├── vm.htmlForPreview: String?  ←── ExtractionViewModel
    │       (propiedad computada)           │
    │       outputType == "text"     →  "<pre>…</pre>"
    │       outputType == "markdown" →  HTML + marked.js inline
    │       outputType == "html"     →  HTML tal cual
    │
    ├── WebPreviewView(htmlContent:, contentReady:)
    │       │
    │       ├── makeNSView → WKWebView (instancia creada una sola vez)
    │       │       navigationDelegate = Coordinator
    │       │
    │       ├── updateNSView → guard htmlContent != lastLoaded
    │       │       └── webView.loadHTMLString(html, baseURL: nil)
    │       │
    │       └── Coordinator: WKNavigationDelegate
    │               └── webView(_:didFinish:) → parent.contentReady = true
    │
    └── HStack (fila export)
            ├── Picker($vm.exportFormat) [MD/HTML/PDF.disabled]
            └── Button("Exportar") → Task { await vm.export() }
                    │
                    └── ExtractionViewModel.export() @MainActor async
                            ├── exportMarkdown() → NSSavePanel → Data.write
                            └── exportHTML()     → NSSavePanel → generateHTML() → Data.write
                                    │
                                    └── generateHTML(content:outputType:) → String
                                            CSS inline + marked.js (si markdown) + @media dark
```

### Recommended Project Structure

```
ExtractorApp/ExtractorApp/ExtractorApp/
├── Views/
│   └── WebPreviewView.swift       # NSViewRepresentable — nuevo en Phase 5
├── ViewModels/
│   └── ExtractionViewModel.swift  # Extender: +contentReady, +exportFormat, +export(), +generateHTML()
├── ContentView.swift              # Modificar: reemplazar ScrollView por WebPreviewView + HStack export
├── Models/
│   └── ExtractionResult.swift     # Sin cambios
└── Services/
    └── PythonBridge.swift         # Sin cambios
```

La carpeta `Views/` no existe todavía. Con Xcode 16+ (PBXFileSystemSynchronizedRootGroup) se detecta automáticamente al crear el archivo.

---

### Patrón 1: NSViewRepresentable con Coordinator para WKWebView

**Qué hace:** Envuelve `WKWebView` en SwiftUI; el `Coordinator` actúa como `WKNavigationDelegate` y escribe en el `@Binding contentReady` cuando la carga termina.

**Cuándo usar:** Único punto de integración WebKit en la app para Phase 5 y Phase 6.

**Ejemplo:**

```swift
// Views/WebPreviewView.swift
// Source: patrón NSViewRepresentable — Apple Developer Documentation + verificado contra
//         Apple Developer Forums thread 124688 y múltiples ejemplos macOS

import SwiftUI
import WebKit

struct WebPreviewView: NSViewRepresentable {
    var htmlContent: String?
    @Binding var contentReady: Bool

    // DISCRETION: WKWebView se crea en makeNSView (no en Coordinator).
    // makeNSView se llama UNA SOLA VEZ por ciclo de vida del view.
    // Guardar la instancia en el Coordinator evita recrearla en updateNSView.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView   // Coordinator retiene la instancia
        return webView
    }

    // updateNSView se llama en CADA re-render de SwiftUI (incluidos hover events).
    // CRÍTICO: guard contra carga redundante o se produce ciclo parpadeo/reset.
    func updateNSView(_ webView: WKWebView, context: Context) {
        guard htmlContent != context.coordinator.lastLoadedHTML else { return }
        context.coordinator.lastLoadedHTML = htmlContent

        if let html = htmlContent {
            webView.loadHTMLString(html, baseURL: nil)
            // contentReady se pone a false aquí porque una nueva carga está en curso
            // El Coordinator lo pondrá a true en didFinish
        } else {
            webView.loadHTMLString("", baseURL: nil)
            // Resetear contentReady para el estado vacío
            DispatchQueue.main.async { [weak context] in
                context?.coordinator.parent.contentReady = false
            }
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebPreviewView
        weak var webView: WKWebView?
        var lastLoadedHTML: String?    // Guard contra loadHTMLString redundante

        init(_ parent: WebPreviewView) {
            self.parent = parent
        }

        // webView(_:didFinish:) se dispara UNA VEZ por loadHTMLString cuando
        // el DOM está parseado y el JS inline (marked.js) ha ejecutado.
        // NOTA: Para HTML estático sin recursos externos, el DOM + JS completan
        // en el mismo ciclo; no se necesita delay adicional para el preview.
        // (Para PDF en Phase 6 sí se necesita delay de ~100ms — ver PITFALLS.md #4)
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.contentReady = true
            }
        }

        // Manejar fallos de carga (URL relativas rotas, HTML malformado, etc.)
        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            // En Phase 5 no hay recursos externos: este caso no debería ocurrir.
            // Loguear en debug para detectar HTML malformado.
            print("[WebPreviewView] didFail: \(error.localizedDescription)")
        }
    }
}
```

**Punto crítico — retain cycle:**
El patrón `webView.navigationDelegate = context.coordinator` NO crea retain cycle porque `WKWebView` mantiene el delegate con referencia débil (`weak`). El Coordinator, a su vez, tiene `weak var webView` para evitar retener el WKWebView después de que SwiftUI lo destruya.

---

### Patrón 2: marked.js bundled como String literal

**Qué hace:** Incluye el parser Markdown en el HTML template sin assets externos. `marked.parse(content)` es síncrono en v18 (sin `async: true`).

**Ejemplo de template (para `generateHTML` en ViewModel):**

```swift
// ExtractionViewModel.swift
// DISCRETION: método de instancia (accede a self.outputType implícitamente si se necesita,
// aunque la firma explícita es más testeable).

private static let markedJS: String = {
    // Contenido de marked.umd.js v18.0.5 (42 KB)
    // Obtener de: node_modules/marked/lib/marked.umd.js tras `npm install marked`
    // Pegar aquí como string literal o cargar desde archivo Resources si supera 64 KB Swift literal limit
    return """
    (function(...)...)
    """
}()

func generateHTML(content: String, outputType: String) -> String {
    let css = """
    body {
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        font-size: 16px;
        line-height: 1.6;
        max-width: 800px;
        margin: 0 auto;
        padding: 1em;
    }
    pre, code {
        font-family: ui-monospace, monospace;
        font-size: 14px;
        background: rgba(0,0,0,0.05);
        border-radius: 4px;
        padding: 0.2em 0.4em;
    }
    pre code { padding: 0; background: none; }
    pre { padding: 1em; overflow: auto; }
    @media (prefers-color-scheme: dark) {
        body { background: #1e1e1e; color: #d4d4d4; }
        a { color: #6ab0f5; }
        pre, code { background: rgba(255,255,255,0.08); }
    }
    @media print { body { max-width: none; } }
    """

    switch outputType {
    case "markdown":
        // CRÍTICO: escapar backticks del contenido para el template literal JS
        let escaped = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
        return """
        <!DOCTYPE html>
        <html><head>
        <meta charset="utf-8">
        <style>\(css)</style>
        </head><body>
        <div id="content"></div>
        <script>\(Self.markedJS)</script>
        <script>
          document.getElementById('content').innerHTML =
            marked.parse(`\(escaped)`);
        </script>
        </body></html>
        """

    case "html":
        return content   // HTML directo — ya es HTML del extractor

    default: // "text"
        let escaped = content
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
        return """
        <!DOCTYPE html>
        <html><head>
        <meta charset="utf-8">
        <style>\(css) body { font-family: ui-monospace, monospace; } </style>
        </head><body><pre>\(escaped)</pre></body></html>
        """
    }
}
```

**Nota sobre tamaño del string literal Swift:** El archivo `marked.umd.js` pesa 42 KB. Los string literals Swift tienen un límite práctico alrededor de 64 KB en el compilador. Con 42 KB no hay problema, pero si en el futuro se actualiza a una versión mayor, verificar el tamaño.

---

### Patrón 3: NSSavePanel con withCheckedContinuation

**Qué hace:** Envuelve el callback de `NSSavePanel.begin(completionHandler:)` en async/await.

**Restricción crítica:** NSSavePanel DEBE llamarse desde el hilo principal (`@MainActor`). El ViewModel ya es `@MainActor` (declarado en Phase 4), así que las funciones de exportación heredan el actor correcto.

```swift
// ExtractionViewModel.swift — funciones de exportación

// DISCRETION: usar begin(completionHandler:) (panel independiente) en lugar de
// beginSheetModal(for:) porque el ViewModel no tiene referencia a la ventana.
// Alternativa: beginSheetModal requiere NSApp.keyWindow — frágil si la ventana no está activa.

@MainActor
func exportMarkdown() async {
    guard let content = resultContent else { return }

    let panel = NSSavePanel()
    panel.allowedContentTypes = [
        UTType(filenameExtension: "md") ?? .plainText   // Fallback a .plainText — ver Pitfall #3
    ]
    panel.nameFieldStringValue = suggestedFilename(from: content, extension: "md")
    panel.canCreateDirectories = true

    let response = await withCheckedContinuation { (cont: CheckedContinuation<NSApplication.ModalResponse, Never>) in
        panel.begin { response in
            cont.resume(returning: response)
        }
    }

    guard response == .OK, let url = panel.url else { return }

    do {
        try content.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        // En Phase 5 no hay UI de error para export fallido — loguear en debug
        print("[ExportMarkdown] Error al guardar: \(error.localizedDescription)")
    }
}

@MainActor
func exportHTML() async {
    guard let content = resultContent else { return }
    let html = generateHTML(content: content, outputType: outputType)

    let panel = NSSavePanel()
    panel.allowedContentTypes = [.html]
    panel.nameFieldStringValue = suggestedFilename(from: content, extension: "html")
    panel.canCreateDirectories = true

    let response = await withCheckedContinuation { (cont: CheckedContinuation<NSApplication.ModalResponse, Never>) in
        panel.begin { response in
            cont.resume(returning: response)
        }
    }

    guard response == .OK, let url = panel.url else { return }

    do {
        try html.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        print("[ExportHTML] Error al guardar: \(error.localizedDescription)")
    }
}

// Función de despacho — ContentView llama `Task { await vm.export() }`
@MainActor
func export() async {
    switch exportFormat {
    case "markdown": await exportMarkdown()
    case "html":     await exportHTML()
    case "pdf":      break   // Phase 6 — no-op
    default:         break
    }
}

// DISCRETION: nombre sugerido — primeros 50 chars sanitizados
private func suggestedFilename(from content: String, extension ext: String) -> String {
    let sanitized = content
        .prefix(50)
        .replacingOccurrences(of: "[^a-zA-Z0-9_\\-]",
                              with: "-",
                              options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    let name = sanitized.isEmpty ? "export" : sanitized
    return "\(name).\(ext)"
}
```

---

### Patrón 4: htmlForPreview como propiedad computada

**Decisión (Claude's Discretion + D-05):** Usar propiedad computada, no `@Published`.

**Por qué funciona con `ObservableObject`:** En `ObservableObject` (que es lo que usa el ViewModel actual — `@StateObject private var vm = ExtractionViewModel()`), una propiedad computada NO envía `objectWillChange` automáticamente. Sin embargo, `htmlForPreview` depende de `resultContent` y `outputType`, que SÍ son `@Published`. Cuando cualquiera de ellas cambia, SwiftUI re-renderiza ContentView y evalúa `vm.htmlForPreview` en ese momento — obteniendo el valor actualizado. El comportamiento es correcto.

```swift
// ExtractionViewModel.swift
var htmlForPreview: String? {
    guard let content = resultContent else { return nil }
    return generateHTML(content: content, outputType: outputType)
}
```

**Alternativa `@Published` derivado:** Requeriría `sink` en `init()` para actualizar el `@Published` en respuesta a cambios de `resultContent` y `outputType`. Más código, mismo resultado. La propiedad computada es la opción más simple y correcta aquí.

---

### Anti-Patterns a evitar

- **Llamar `loadHTMLString` en cada `updateNSView` sin guard:** SwiftUI llama `updateNSView` en hover events, window focus, y re-renders no relacionados. Sin `guard htmlContent != lastLoadedHTML`, cada movimiento de ratón sobre la ventana recargaría el WebView y resetearía `contentReady`. [VERIFIED: Apple Developer Forums NSViewRepresentable documentation + forum thread 749620]

- **Crear una nueva instancia de `WKWebView` en `updateNSView`:** SwiftUI puede llamar `updateNSView` múltiples veces antes de que `makeNSView` se haya completado en el display list. Crear el WKWebView en `makeNSView` (llamado UNA sola vez) y reutilizarlo en `updateNSView` es el patrón correcto. [ASSUMED — documentación NSViewRepresentable no especifica explícitamente la frecuencia de llamada a makeNSView, pero el comportamiento documentado de UIViewRepresentable es idéntico]

- **Usar `beginSheetModal(for:keyWindow)` asumiendo que la ventana siempre existe:** `NSApp.keyWindow` puede ser `nil` si la app está en segundo plano. Usar `panel.begin(completionHandler:)` (panel independiente) es más robusto para una app de ventana única. [ASSUMED — patrón inference basado en comportamiento documentado de NSSavePanel]

- **No escalar backticks y caracteres especiales en el template Markdown:** El contenido Markdown puede contener backticks (bloques de código), `$` (texto matemático), y `\` (escapes). Sin escapado, el string literal JavaScript se rompe silenciosamente produciendo HTML en blanco. [VERIFIED: github.com/onmyway133/blog/issues/429]

- **Asumir que `UTType(filenameExtension: "md")` devuelve no-nil:** Verificado contra `UTCoreTypes.h` del SDK macOS 15.4 — **no existe `UTTypeMarkdown`** en los headers del sistema. El initializer `UTType(filenameExtension:)` puede devolver `nil` para extensiones no registradas en el sistema. El fallback `.plainText` + `nameFieldStringValue = "nombre.md"` es la única ruta segura. [VERIFIED: grep contra UTCoreTypes.h SDK macOS 15.4 — no aparece "markdown" en ningún header del framework UniformTypeIdentifiers]

---

## Don't Hand-Roll

| Problema | No construir | Usar en cambio | Por qué |
|----------|-------------|----------------|---------|
| Renderizado Markdown | Parser Markdown propio en Swift | `marked.js` bundled en WKWebView | GFM completo (tablas, strikethrough, task lists, syntax hints) en ~42 KB; NSAttributedString no soporta GFM |
| Parser HTML + sanitización | `htmlspecialchars` manual | `String.replacingOccurrences(of:)` para < y & en texto plano; para HTML directo, no sanitizar | El extractor Python ya limpia el HTML; sanitización adicional puede romper el contenido |
| Diálogo de guardado nativo | Implementación custom de file picker | `NSSavePanel` (sistema) | NSSavePanel gestiona permisos, recent locations, iCloud Drive, y thumbnail previews automáticamente |
| Detección de fin de carga WebKit | Polling con Timer | `WKNavigationDelegate.webView(_:didFinish:)` | El único callback fiable de Apple para "DOM parseado + JS ejecutado"; polling es frágil y consume CPU |

---

## Common Pitfalls

### Pitfall 1: `updateNSView` llamado frecuentemente — ciclo de recarga

**Qué sale mal:** `updateNSView` se invoca en cada evento que modifica el árbol de vistas SwiftUI, incluyendo hover sobre controles, cambios de foco, y actualizaciones de propiedades no relacionadas del ViewModel. Sin guard, `loadHTMLString` se llamaría decenas de veces por segundo, produciendo: (a) `contentReady` reseteándose en cada hover, (b) el WKWebView parpadeando en blanco mientras recarga, (c) `didFinish` disparándose repetidamente.

**Por qué ocurre:** SwiftUI no diferencia entre "cambió algo que afecta a este NSViewRepresentable" y "cambió algo en el árbol padre". `updateNSView` es el punto donde la View Representable sincroniza con el estado SwiftUI actual.

**Cómo evitar:** El Coordinator almacena `var lastLoadedHTML: String?`. En `updateNSView`:
```swift
guard htmlContent != context.coordinator.lastLoadedHTML else { return }
context.coordinator.lastLoadedHTML = htmlContent
webView.loadHTMLString(htmlContent ?? "", baseURL: nil)
```

**Señales de alerta:** El botón "Exportar" parpadea (se deshabilita y vuelve a habilitarse) al mover el ratón sobre la ventana.

---

### Pitfall 2: `UTType(filenameExtension: "md")` devuelve nil en macOS 13

**Qué sale mal:** Si se usa `allowedContentTypes: [UTType(filenameExtension: "md")!]` sin manejo del nil, la app crashea con un force-unwrap. Si se usa `allowedContentTypes: []`, el NSSavePanel no restringe extensiones — cualquier extensión es válida, pero el nombre sugerido puede no tener `.md`.

**Por qué ocurre:** Apple no tiene un UTType registrado para Markdown en el framework `UniformTypeIdentifiers` del sistema (confirmado en UTCoreTypes.h). El constructor `UTType(filenameExtension:)` requiere que la extensión esté registrada en el sistema o en el `Info.plist` de la app.

**Cómo evitar:**
```swift
// Opción A (recomendada): Fallback con nil coalescing
panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
// El panel mostrará "Texto sin formato" en el tipo, pero guardará con extensión .md
// gracias a nameFieldStringValue

// Opción B: Registrar UTType en Info.plist (más correcto pero overkill para Phase 5)
// Añadir entrada "Imported Type UTIs" con identifier "net.daringfireball.markdown"
// y extension "md"
```

**Señales de alerta:** El compilador o el runtime emite `Fatal error: Unexpectedly found nil while unwrapping`.

---

### Pitfall 3: Backticks en contenido Markdown rompen el template JS

**Qué sale mal:** El template HTML usa backtick template literals en JavaScript: `` marked.parse(`\(content)`) ``. Si `content` contiene backticks (muy común en bloques de código Markdown), se cierra prematuramente el template literal JS, produciendo un `SyntaxError` en WebKit. El resultado: `document.getElementById('content').innerHTML` queda vacío o con error, y el WKWebView muestra la página en blanco.

**Por qué ocurre:** Los backticks en JavaScript tienen significado especial dentro de template literals.

**Cómo evitar:** Escapar backticks, backslashes y `$` antes de interpolar:
```swift
let escaped = content
    .replacingOccurrences(of: "\\", with: "\\\\")  // primero backslash
    .replacingOccurrences(of: "`", with: "\\`")
    .replacingOccurrences(of: "$", with: "\\$")
```
El orden importa: escapar `\` antes que los demás para evitar doble escape.

**Señales de alerta:** Páginas con bloques de código (triple backtick) muestran el WKWebView en blanco en lugar del contenido renderizado.

---

### Pitfall 4: `didFinish` — timing para Phase 6 (PDF) vs Phase 5 (preview)

**Contexto Phase 5 (preview):** `webView(_:didFinish:)` se dispara cuando el DOM está parseado y el JavaScript inline ha ejecutado. Para contenido autocontenido (sin recursos externos), `marked.js` ejecuta sincrónicamente antes de que se llame a `didFinish`. Esto significa que `contentReady = true` en `didFinish` es correcto y suficiente para el preview. No se necesita delay adicional.

**Contexto Phase 6 (PDF, deferred):** El mismo `contentReady = true` en `didFinish` es INSUFICIENTE para `createPDF()` — el layout puede no estar completo. Ver PITFALLS.md #4: se necesita un delay de ~100ms adicional. Esta diferencia DEBE documentarse en el código Phase 6 para no confundir con Phase 5.

**Señales de alerta Phase 5:** Si el botón "Exportar" no se habilita después de una extracción exitosa, verificar que el HTML generado no produce un error en WebKit (inspector → Safari → Develop → Wireless Inspector si está habilitado, o evaluar JS desde Swift para verificar `document.readyState`).

---

### Pitfall 5: `didFinish` puede dispararse múltiples veces si `updateNSView` llama `loadHTMLString` múltiples veces

**Qué sale mal:** Cada llamada a `loadHTMLString` genera una nueva navegación (un objeto `WKNavigation` distinto), y cada una dispara su propio `didFinish`. Sin el guard en `updateNSView` (Pitfall #1), esto combinado produce llamadas repetidas a `contentReady = true` (inofensivo) y potencialmente llamadas a `contentReady = false` intercaladas por el reset en `updateNSView` de la segunda carga.

**Cómo evitar:** El guard en `updateNSView` previene cargas redundantes. El `WKNavigation` parameter en `didFinish` puede usarse para distinguir qué carga terminó si se necesita más control.

---

## Code Examples

### Template HTML completo para preview (verified working pattern)

```swift
// Source: verificado contra github.com/onmyway133/blog/issues/429
// y confirmado: JS habilitado por defecto en WKWebView (Apple Developer Forums thread 91016)

func htmlTemplate(for markdown: String) -> String {
    let escaped = markdown
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "`", with: "\\`")
        .replacingOccurrences(of: "$", with: "\\$")
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="color-scheme" content="light dark">
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif;
               font-size: 16px; line-height: 1.6;
               max-width: 800px; margin: 0 auto; padding: 1em; }
        pre, code { font-family: ui-monospace, monospace; font-size: 14px; }
        @media (prefers-color-scheme: dark) {
          body { background: #1e1e1e; color: #d4d4d4; }
          a { color: #6ab0f5; }
        }
        @media print { body { max-width: none; } }
      </style>
    </head>
    <body>
      <div id="content"></div>
      <script>/* marked.umd.js v18.0.5 — 42 KB — pegar aquí */</script>
      <script>
        document.getElementById('content').innerHTML =
          marked.parse(`\(escaped)`);
      </script>
    </body>
    </html>
    """
}
```

### NSSavePanel con withCheckedContinuation (verified pattern)

```swift
// Source: Apple Developer Documentation NSSavePanel.begin(completionHandler:)
// [VERIFIED: developer.apple.com/documentation/appkit/nssavepanel]
// NOTA: begin(completionHandler:) es seguro llamar desde @MainActor

@MainActor
func saveWithPanel(allowedTypes: [UTType], suggestedName: String) async -> URL? {
    let panel = NSSavePanel()
    panel.allowedContentTypes = allowedTypes
    panel.nameFieldStringValue = suggestedName
    panel.canCreateDirectories = true

    let response: NSApplication.ModalResponse =
        await withCheckedContinuation { cont in
            panel.begin { cont.resume(returning: $0) }
        }

    guard response == .OK else { return nil }  // Usuario canceló
    return panel.url
}
```

### Estructura de propiedades nuevas en ExtractionViewModel

```swift
// ExtractionViewModel.swift — sección MARK: Phase 5 additions

// MARK: - Phase 5: Preview state
@Published var contentReady: Bool = false
@Published var exportFormat: String = "markdown"  // "markdown" | "html" | "pdf"

// Propiedad computada — no @Published porque depende de @Published ya existentes
var htmlForPreview: String? {
    guard let content = resultContent else { return nil }
    return generateHTML(content: content, outputType: outputType)
}

// En extract() — añadir a bloque de limpieza D-09 existente:
// errorMessage = nil
// resultContent = nil
// isPythonPathError = false
// isExtracting = true
// + contentReady = false    ← NUEVO Phase 5 (D-10)
```

---

## State of the Art

| Enfoque anterior | Enfoque actual | Cuándo cambió | Impacto |
|-----------------|----------------|---------------|---------|
| `WKPreferences.javaScriptEnabled = true` para habilitar JS | JS habilitado por defecto en WKWebView — no se necesita configuración | macOS 10.15+ (WKWebView reemplazó UIWebView) | No se necesita `WKWebViewConfiguration` para marked.js inline |
| `allowedFileTypes: [String]` en NSSavePanel (API deprecada) | `allowedContentTypes: [UTType]` | macOS 12.0 | Usar UTType; si no existe para .md, usar `.plainText` + `nameFieldStringValue` |
| `SwiftUI.fileExporter` con `FileDocument` | `NSSavePanel` directo | — | `fileExporter` es más declarativo pero requiere tipos `FileDocument` incompatibles con export PDF (Phase 6) |
| `ObservableObject` + `@Published` en todas las propiedades | Propiedad computada sobre `@Published` para valores derivados | Swift 5.7+ | Menos código y menos actualizaciones de vista para valores que son funciones de otros `@Published` |

**Deprecated/outdated:**
- `UIWebView` / `WebView` (AppKit legacy): completamente reemplazados por `WKWebView`. No usar.
- `allowedFileTypes: [String]` en NSSavePanel: deprecado en macOS 12. Usar `allowedContentTypes: [UTType]`.
- `WKWebView.javaScriptEnabled` property (en `WKPreferences`): deprecado en macOS 14. JS está habilitado por defecto.

---

## Runtime State Inventory

> Esta es una fase de extensión de funcionalidad (no rename/refactor), pero se verifica igualmente.

| Categoría | Items encontrados | Acción requerida |
|-----------|-------------------|------------------|
| Stored data | Ninguno — la app no persiste contenido extraído ni historial en esta fase | None |
| Live service config | Ninguno — sin servicios externos | None |
| OS-registered state | Ninguno | None |
| Secrets/env vars | Ninguno relevante para esta fase | None |
| Build artifacts | `Views/` carpeta no existe — Xcode 16+ con PBXFileSystemSynchronizedRootGroup la detecta automáticamente al crear `WebPreviewView.swift` | Crear la carpeta físicamente al crear el archivo |

**Nothing found in category:** Verificado — esta es una fase de adición de funcionalidad, no de migración de estado existente.

---

## Validation Architecture

> `workflow.nyquist_validation` no está explícitamente a `false` en `.planning/config.json` → incluir sección.

### Test Framework

| Propiedad | Valor |
|-----------|-------|
| Framework | XCTest (incluido en Xcode — sin instalación adicional) |
| Config file | Schema Xcode target "ExtractorAppTests" — a crear en Wave 0 |
| Quick run command | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS'` |
| Full suite command | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' -resultBundlePath TestResults` |

**Nota:** Los tests de SwiftUI macOS con WKWebView tienen limitaciones reales — el WebView no puede inicializarse en test sin un display (headless). Las estrategias de test se centran en unidades testeables (ViewModel logic) y tests de humo para NSSavePanel.

### Phase Requirements → Test Map

| Req ID | Comportamiento | Tipo de test | Comando automatizable | Archivo existe |
|--------|---------------|--------------|----------------------|----------------|
| UI-02 | `htmlForPreview` devuelve nil cuando `resultContent == nil` | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testHtmlForPreviewNilWhenNoContent` | ❌ Wave 0 |
| UI-02 | `htmlForPreview` para outputType=="markdown" contiene `marked.parse` | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testHtmlForPreviewMarkdownContainsMarked` | ❌ Wave 0 |
| UI-02 | `contentReady` se resetea a false en `extract()` | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testContentReadyResetOnExtract` | ❌ Wave 0 |
| EXPORT-01 | `export()` llama `exportMarkdown()` cuando `exportFormat == "markdown"` | unit (mock) | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testExportDispatchMarkdown` | ❌ Wave 0 |
| EXPORT-02 | `exportMarkdown` produce archivo .md con contenido íntegro | integration / manual | Manual — NSSavePanel requiere UI real | manual-only |
| EXPORT-03 | `generateHTML` contiene `@media (prefers-color-scheme: dark)` | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testGenerateHTMLDarkMode` | ❌ Wave 0 |
| EXPORT-03 | `generateHTML` para markdown contiene `marked.parse` | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testGenerateHTMLMarkdownContainsScript` | ❌ Wave 0 |
| EXPORT-03 | Template HTML es autocontenido (no references CDN) | unit | `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests/testGenerateHTMLNoExternalDeps` | ❌ Wave 0 |

### Sampling Rate

- **Por task commit:** `xcodebuild build -scheme ExtractorApp` (compilación — confirma no hay errores de tipo)
- **Por wave merge:** `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests`
- **Phase gate:** Suite completa + verificación manual del preview en WKWebView con contenido real

### Wave 0 Gaps

- [ ] `ExtractorAppTests/ViewModelTests.swift` — tests unitarios de `htmlForPreview`, `generateHTML`, `contentReady`, dispatch de `export()`
- [ ] Target "ExtractorAppTests" en Xcode (si no existe ya del proyecto Phase 3/4)
- [ ] `ExtractorAppTests/Mocks/` — mocks para NSSavePanel (opcional Phase 5, prioritario Phase 6)

*(Los tests de NSSavePanel end-to-end y WKWebView rendering requieren UI real — se verifican manualmente en el gate de fase)*

---

## Security Domain

> `security_enforcement` no está explícitamente a `false` en `.planning/config.json` → incluir sección.

### Applicable ASVS Categories

| ASVS Category | Aplica | Control estándar |
|---------------|--------|-----------------|
| V2 Authentication | No | Sin autenticación en esta fase |
| V3 Session Management | No | Sin sesiones |
| V4 Access Control | No | App de usuario único local |
| V5 Input Validation | Sí (parcial) | Escapado de backticks/HTML antes de interpolación en template JS |
| V6 Cryptography | No | Sin datos cifrados |

### Known Threat Patterns for WebKit + file export

| Pattern | STRIDE | Mitigación estándar |
|---------|--------|---------------------|
| XSS via contenido extraído en WKWebView | Tampering | El contenido se carga vía `loadHTMLString` con `baseURL: nil` — aislado del origen del extractor; no tiene acceso a cookies ni almacenamiento del dominio real |
| Template injection JS (backticks en Markdown) | Tampering | Escapado explícito de `\`, `` ` `` y `$` antes de interpolación en template literal JS |
| Path traversal en NSSavePanel | Tampering | NSSavePanel gestiona el path; el usuario elige libremente donde guardar — no hay restricciones adicionales necesarias en una herramienta personal |
| HTML autocontenido con scripts externos | Information Disclosure | `generateHTML` usa `baseURL: nil` y CSS/JS inline — confirmado sin referencias CDN en D-13 |

**Nota de seguridad sobre `loadHTMLString` con `baseURL: nil`:** Con `baseURL: nil`, WKWebView asigna el origen `about:blank` al contenido. El JS inline puede ejecutar DOM manipulations pero no puede hacer fetch de recursos externos sin permiso explícito (no se configura `WKWebViewConfiguration` con reglas de contenido). Este es el nivel de seguridad correcto para contenido de usuario no confiable en una herramienta personal.

---

## Assumptions Log

| # | Claim | Sección | Riesgo si es incorrecto |
|---|-------|---------|------------------------|
| A1 | `begin(completionHandler:)` en NSSavePanel es preferible a `beginSheetModal(for:)` porque el ViewModel no tiene referencia a la ventana | Patrón 3 (NSSavePanel) | Bajo — ambas APIs funcionan; `beginSheetModal` requeriría pasar la ventana al ViewModel o a la función |
| A2 | `makeNSView` se llama una sola vez por ciclo de vida del NSViewRepresentable (no en cada re-render) | Patrón 1 (NSViewRepresentable) | Medio — si SwiftUI recrea el view (por cambios de identidad), la instancia WKWebView se perdería y `lastLoadedHTML` se resetearía |
| A3 | `didFinish` para `loadHTMLString` con JS inline síncrono dispara UNA SOLA VEZ por llamada a `loadHTMLString` | Pitfall #5, Patrón 1 | Medio — si dispara múltiples veces (por iframes o subframes), `contentReady` se establecería a `true` prematuramente para la primera subframe |
| A4 | `begin(completionHandler:)` de NSSavePanel puede llamarse correctamente desde un contexto `@MainActor async` sin necesidad de `DispatchQueue.main.async` adicional | Patrón 3 | Bajo — el ViewModel ya es `@MainActor`; si NSSavePanel requiere main thread y `@MainActor` no lo garantiza en todos los contextos async, añadir `await MainActor.run {}` |
| A5 | El string literal Swift de 42 KB (marked.umd.js) no supera el límite del compilador | Patrón 2 (marked.js) | Bajo — el límite práctico es ~64 KB; 42 KB está dentro. Si falla: usar `Bundle.main.url(forResource:withExtension:)` para cargar desde Resources |

---

## Open Questions

1. **¿`makeNSView` puede llamarse más de una vez si SwiftUI destruye y recrea la identidad del NSViewRepresentable?**
   - Lo que sabemos: SwiftUI puede destruir y recrear NSViewRepresentables si la identidad del view cambia (uso de `.id()` modifier, o si el view aparece/desaparece del árbol condicional)
   - Lo que no está claro: Si la condición `if vm.isExtracting { ProgressView } else { WebPreviewView }` en ContentView causa que WebPreviewView se destruya y recree en cada extracción, `lastLoadedHTML` se perdería y se haría una carga inicial al volver a mostrarse
   - Recomendación: Usar `.overlay` en lugar del `if/else` para mantener WebPreviewView siempre en el árbol (la UI spec menciona ambas opciones como válidas)

2. **¿`withCheckedContinuation` en un `@MainActor func` con `NSSavePanel.begin` puede causar deadlock?**
   - Lo que sabemos: `NSSavePanel.begin` es asíncrono (no bloquea). El continuation se resume en el completion handler. No hay bloqueo del hilo principal.
   - Lo que no está claro: Si `await withCheckedContinuation` dentro de un `@MainActor` context libera el actor para otros trabajos mientras espera (en Swift 5.9+ con cooperative thread pool, debe hacerlo)
   - Recomendación: Implementar y verificar empíricamente. Si hay freeze de UI, añadir `Task.yield()` antes del `withCheckedContinuation`.

3. **¿`UTType(filenameExtension: "md")` devuelve no-nil si el usuario tiene Xcode o una app que registra el tipo?**
   - Lo que sabemos: No está en los headers del SDK del sistema. Pero si el usuario tiene Xcode instalado, Xcode puede registrar tipos adicionales en el sistema.
   - Recomendación: El fallback a `.plainText` es correcto independientemente — funciona en todos los casos.

---

## Environment Availability

| Dependencia | Requerida por | Disponible | Versión | Fallback |
|-------------|--------------|------------|---------|----------|
| Xcode 16+ | PBXFileSystemSynchronizedRootGroup (detección automática de Views/) | Confirmado (Xcode 16 en uso por contexto del proyecto) | 16.x | Si Xcode 15: añadir manualmente al .pbxproj |
| macOS 13.0+ deployment target | WKWebView, NSSavePanel.allowedContentTypes, Swift Concurrency completo | ✓ (target ya establecido en Phase 3) | macOS 13.0 | — |
| WebKit.framework | WKWebView, WKNavigationDelegate | ✓ (framework de sistema) | macOS 13+ | — |
| AppKit.framework | NSSavePanel | ✓ (framework de sistema) | macOS 13+ | — |
| `marked.umd.js` v18.0.5 | Template HTML Markdown | ✓ (verificado en npm registry, 42 KB) | 18.0.5 | Versión anterior (14.x) — API compatible |

**Missing dependencies:** Ninguna — todos los componentes disponibles.

---

## Sources

### Primary (HIGH confidence)
- `UTCoreTypes.h` — SDK macOS 15.4 (`/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/`) — verificación directa de ausencia de UTTypeMarkdown
- `npm install marked@18.0.5` — verificación directa del archivo `lib/marked.umd.js` (42 KB, UMD format, API `marked.parse()` síncrona)
- [Apple Developer Documentation — NSSavePanel](https://developer.apple.com/documentation/appkit/nssavepanel) — `begin(completionHandler:)`, `allowedContentTypes`, `url`, MainActor requirement, cancel behavior
- [Apple Developer Forums thread 112782](https://developer.apple.com/forums/thread/112782) — confirmación de que JS inline ejecuta con `loadHTMLString(baseURL: nil)` (WKUserScript pattern)

### Secondary (MEDIUM confidence)
- [Apple Developer Forums thread 91016](https://developer.apple.com/forums/thread/91016) — "WKWebView always has JavaScript enabled" — confirmación JS por defecto
- [GitHub onmyway133/blog issue 429](https://github.com/onmyway133/blog/issues/429) — patrón marcado con template literal + escapado de backticks para WKWebView
- [Apple Developer Forums thread 749620](https://developer.apple.com/forums/thread/749620) — `updateNSView` llamado en cada evento (hover, focus); patrón de caching previous value
- [Apple Developer Documentation — webView(_:didFinish:)](https://developer.apple.com/documentation/webkit/wknavigationdelegate/1455629-webview) — "fires once per load"
- [Apple Developer Documentation — allowedContentTypes](https://developer.apple.com/documentation/appkit/nssavepanel/allowedcontenttypes) — patrón UTType para NSSavePanel

### Tertiary (LOW confidence — marcar para validación)
- [WebSearch resultado: updateNSView called per hover event](https://forums.developer.apple.com/forums/thread/749620) — frecuencia de llamada a updateNSView — MEDIUM (múltiples fuentes coinciden)
- [WebSearch resultado: beginSheetModal vs begin](https://serialcoder.dev/text-tutorials/macos-tutorials/save-and-open-panels-in-macos-apps/) — preferencia de uso — ASSUMED

---

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — APIs Apple verificadas contra SDK headers; marked.js verificado contra paquete npm instalado localmente
- Architecture Patterns: HIGH — NSViewRepresentable Coordinator pattern verificado contra múltiples fuentes Apple; NSSavePanel async pattern verificado contra documentación oficial
- Pitfalls: HIGH (Pitfalls 1-3) / MEDIUM (Pitfalls 4-5) — los más críticos verificados empíricamente en foros Apple

**Research date:** 2026-06-11
**Valid until:** 2026-07-11 (APIs estables; marked.js sigue en desarrollo activo — verificar si se actualiza la versión antes de bundlear)

**Graph status:** Obsoleto (57h, 20 commits behind) — no usado para este research. Relaciones arquitecturales derivadas directamente del código fuente.
