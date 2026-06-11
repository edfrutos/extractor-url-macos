# Phase 5: Preview y Export MD/HTML — Pattern Map

**Mapped:** 2026-06-11
**Files analyzed:** 3 (1 nuevo, 2 modificados)
**Analogs found:** 3 / 3

---

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `Views/WebPreviewView.swift` | component (NSViewRepresentable) | request-response | `Views/SettingsView.swift` + `Services/PythonBridge.swift` | partial-match (SettingsView = SwiftUI View pura, no NSViewRepresentable; PythonBridge = patrón async/await con continuación) |
| `ViewModels/ExtractionViewModel.swift` | viewmodel | request-response + file-I/O | `ViewModels/ExtractionViewModel.swift` (misma clase) | exact — se extiende el archivo existente |
| `ContentView.swift` | component (root view) | request-response | `ContentView.swift` (mismo archivo) | exact — se modifica el archivo existente |

> **Nota sobre WebPreviewView:** No existe ningún `NSViewRepresentable` en el proyecto. El análogo más útil es la combinación de (a) `SettingsView.swift` para el patrón estructural SwiftUI View + `@ViewBuilder` y (b) `PythonBridge.swift` para el patrón `withCheckedContinuation` / async que se replica en exportación. Los fragmentos concretos se detallan abajo.

---

## Pattern Assignments

### `Views/WebPreviewView.swift` (component NSViewRepresentable — NUEVO)

**Análogo primario:** No existe NSViewRepresentable en el proyecto.
**Análogos parciales usados:** `SettingsView.swift` (estructura de archivo Swift), `PythonBridge.swift` (patrón async + continuación — aplicable a las funciones export del ViewModel)

**Imports pattern** — copiar de `SettingsView.swift` líneas 1-2, añadir WebKit:
```swift
import SwiftUI
import WebKit
```

**Estructura de archivo** — copiar convenio de `SettingsView.swift` (struct + body + métodos privados con `@ViewBuilder`):
- `struct WebPreviewView: NSViewRepresentable` en lugar de `: View`
- Coordinator como clase interna (reemplaza `@ViewBuilder private func validationIcon`)
- Sin `body` — en su lugar `makeNSView` + `updateNSView` + `makeCoordinator`

**Core NSViewRepresentable pattern** (no existe en codebase — usar RESEARCH.md Patrón 1 directamente):
```swift
// Views/WebPreviewView.swift
import SwiftUI
import WebKit

struct WebPreviewView: NSViewRepresentable {
    var htmlContent: String?
    @Binding var contentReady: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        return webView
    }

    // CRITICO: guard contra carga redundante (Pitfall #1 RESEARCH.md)
    func updateNSView(_ webView: WKWebView, context: Context) {
        guard htmlContent != context.coordinator.lastLoadedHTML else { return }
        context.coordinator.lastLoadedHTML = htmlContent
        if let html = htmlContent {
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            webView.loadHTMLString("", baseURL: nil)
            DispatchQueue.main.async { [weak context] in
                context?.coordinator.parent.contentReady = false
            }
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebPreviewView
        weak var webView: WKWebView?
        var lastLoadedHTML: String?

        init(_ parent: WebPreviewView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.contentReady = true
            }
        }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            print("[WebPreviewView] didFail: \(error.localizedDescription)")
        }
    }
}
```

**Convenciones de archivo a mantener** (de `SettingsView.swift`):
- Sin header de comentarios Xcode (el proyecto no los usa en archivos de fases nuevas)
- `// MARK: -` para separar secciones internas
- Propiedades primero, métodos después

---

### `ViewModels/ExtractionViewModel.swift` (viewmodel — MODIFICAR)

**Análogo exacto:** el propio archivo existente — se extienden las secciones `MARK`.

**Imports pattern** — `ExtractionViewModel.swift` líneas 1-3 (añadir `AppKit` y `UniformTypeIdentifiers`):
```swift
// EXISTENTE (líneas 1-3):
import Combine
import Foundation
import SwiftUI
// AÑADIR en Phase 5:
import AppKit
import UniformTypeIdentifiers
```

**Patrón @Published existente** — `ExtractionViewModel.swift` líneas 15-18 (replicar para nuevas propiedades):
```swift
// Existente (líneas 15-18) — patrón a replicar:
@Published var isExtracting: Bool = false
@Published var resultContent: String? = nil
@Published var errorMessage: String? = nil
@Published var isPythonPathError: Bool = false

// Nuevas propiedades Phase 5 (mismo patrón, añadir en sección MARK - Outputs):
@Published var contentReady: Bool = false
@Published var exportFormat: String = "markdown"  // "markdown" | "html" | "pdf"
```

**Propiedad computada** — no existe aún en el ViewModel; usar como modelo la propiedad `isSuccess` de `ExtractionResult.swift` línea 19:
```swift
// Modelo en ExtractionResult.swift línea 19:
var isSuccess: Bool { status == "success" }

// Replicar patrón para htmlForPreview en ExtractionViewModel:
var htmlForPreview: String? {
    guard let content = resultContent else { return nil }
    return generateHTML(content: content, outputType: outputType)
}
```

**Patrón de limpieza de estado en extract()** — `ExtractionViewModel.swift` líneas 29-33 (añadir `contentReady = false`):
```swift
// EXISTENTE (líneas 29-33) — bloque D-09 de limpieza:
errorMessage = nil
resultContent = nil
isPythonPathError = false
isExtracting = true

// MODIFICAR: añadir contentReady = false en el mismo bloque (D-10):
errorMessage = nil
resultContent = nil
isPythonPathError = false
contentReady = false   // ← NUEVO Phase 5
isExtracting = true
```

**Patrón async con Task.detached** — `ExtractionViewModel.swift` líneas 42-61 (modelo para funciones export async):
```swift
// EXISTENTE (líneas 42-61) — patrón Task.detached + MainActor.run:
Task.detached(priority: .userInitiated) { [weak self] in
    do {
        let result = try await self?.bridge.run(...)
        await MainActor.run {
            self?.resultContent = result?.content
            self?.isExtracting = false
        }
    } catch {
        await MainActor.run {
            self?.handleError(error)
            self?.isExtracting = false
        }
    }
}
```

**Patrón withCheckedContinuation** — `PythonBridge.swift` líneas 50-52 (modelo para envolver NSSavePanel):
```swift
// EXISTENTE en PythonBridge.swift (líneas 50-52) — async let con Task.detached:
async let outData: Data = Task.detached { stdoutPipe.fileHandleForReading.readDataToEndOfFile() }.value
async let errData: Data = Task.detached { stderrPipe.fileHandleForReading.readDataToEndOfFile() }.value
let (stdout, _) = try await (outData, errData)

// NUEVO en ExtractionViewModel — withCheckedContinuation para NSSavePanel:
// (no existe aún; copiar de RESEARCH.md Patrón 3)
let response = await withCheckedContinuation {
    (cont: CheckedContinuation<NSApplication.ModalResponse, Never>) in
    panel.begin { cont.resume(returning: $0) }
}
```

**Patrón error handling** — `ExtractionViewModel.swift` líneas 65-70 (modelo para errores de export):
```swift
// EXISTENTE (líneas 65-70):
private func handleError(_ error: Error) {
    errorMessage = error.localizedDescription
    if let e = error as? ExtractionError, case .pythonNotFound = e {
        isPythonPathError = true
    }
}
// En Phase 5 export: los errores de escritura se loguean con print() solamente
// (no hay UI de error para export en Phase 5 — ver CONTEXT.md D-11)
```

**Patrón switch sobre @Published String** — `ExtractionViewModel.swift` línea 27 (`guard !isExtracting`), y `ExtractionResult.swift` línea 19 (`isSuccess`). No hay switch sobre `outputType` aún. Modelo en RESEARCH.md Patrón 3:
```swift
// NUEVO — dispatch en export() según exportFormat:
@MainActor
func export() async {
    switch exportFormat {
    case "markdown": await exportMarkdown()
    case "html":     await exportHTML()
    case "pdf":      break   // Phase 6 — no-op
    default:         break
    }
}
```

---

### `ContentView.swift` (root view — MODIFICAR)

**Análogo exacto:** el propio archivo existente.

**Imports pattern** — `ContentView.swift` línea 1 (sin cambios necesarios):
```swift
import SwiftUI
// No añadir WebKit — WebPreviewView lo importa internamente
```

**Patrón HStack existente** — `ContentView.swift` líneas 18-35 (replicar estructura para la nueva fila de exportación):
```swift
// EXISTENTE (líneas 18-35) — fila Picker tipo + Botón Extraer:
HStack(spacing: 8) {
    Picker("Tipo", selection: $vm.outputType) {
        Text("Texto").tag("text")
        Text("HTML").tag("html")
        Text("Markdown").tag("markdown")
    }
    .pickerStyle(.segmented)
    .disabled(vm.isExtracting)

    Button {
        vm.extract()
    } label: {
        Label("Extraer", systemImage: "arrow.down.circle")
    }
    .buttonStyle(.borderedProminent)
    .accessibilityLabel("Extraer contenido de la URL")
    .disabled(vm.isExtracting || vm.urlString.isEmpty)
}

// NUEVA fila (mismo patrón HStack debajo del WKWebView):
HStack(spacing: 8) {
    Picker("Formato", selection: $vm.exportFormat) {
        Text("MD").tag("markdown")
        Text("HTML").tag("html")
        Text("PDF").tag("pdf")
            .disabled(true)   // Phase 6
    }
    .pickerStyle(.segmented)

    Button {
        Task { await vm.export() }
    } label: {
        Label("Exportar", systemImage: "square.and.arrow.up")
    }
    .disabled(!vm.contentReady)
}
```

**Patrón Group + condicional** — `ContentView.swift` líneas 62-92 (reemplazar el `ScrollView { Text }` del estado éxito por `WebPreviewView`):
```swift
// EXISTENTE (líneas 63-73) — estado éxito actual a REEMPLAZAR:
} else if let content = vm.resultContent {
    ScrollView {
        Text(content)
            .font(.system(.caption, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// NUEVO — reemplazar por WebPreviewView para los 3 tipos (D-06):
} else if vm.resultContent != nil {
    WebPreviewView(
        htmlContent: vm.htmlForPreview,
        contentReady: $vm.contentReady
    )
}
```

**Patrón .frame + .padding** — `ContentView.swift` líneas 93-97 (sin cambios):
```swift
// EXISTENTE (líneas 93-97) — mantener sin cambios:
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .padding()
    .frame(minWidth: 500, minHeight: 450)
}
```

**Patrón Divider entre secciones** — `ContentView.swift` líneas 15, 16, 37, 59 (añadir Divider antes de la nueva fila export):
```swift
// Convenio existente: Divider() entre cada sección funcional del VStack
// Añadir después del WebPreviewView y antes del HStack export
Divider()
```

---

## Shared Patterns

### @MainActor en clase ViewModel
**Source:** `ExtractionViewModel.swift` línea 5
**Apply to:** Todas las funciones nuevas en ExtractionViewModel (`export`, `exportMarkdown`, `exportHTML`, `generateHTML`, `suggestedFilename`)
```swift
@MainActor
final class ExtractionViewModel: ObservableObject {
```
Las funciones `async` que se añaden en Phase 5 heredan el actor `@MainActor` de la clase. No es necesario anotarlas individualmente, pero puede hacerse para claridad.

---

### Patrón @AppStorage para persistencia ligera
**Source:** `PythonBridge.swift` líneas 5-6, `SettingsView.swift` líneas 4-5
**Apply to:** `exportFormat` en ExtractionViewModel si se decide persistir la preferencia (Claude's Discretion — ver nota)
```swift
// Existente en PythonBridge.swift (líneas 5-6):
@AppStorage("pythonPath") var pythonPath: String = ""
@AppStorage("scriptPath") var scriptPath: String = ""
```
> **Nota:** CONTEXT.md D-14 usa `@Published var exportFormat`, no `@AppStorage`. Se documenta como patrón disponible pero la decisión canónica es `@Published`.

---

### Patrón guard + early return en funciones públicas
**Source:** `ExtractionViewModel.swift` línea 27, `PythonBridge.swift` líneas 14-19
**Apply to:** `exportMarkdown()`, `exportHTML()`, `export()`
```swift
// Existente en ExtractionViewModel.swift (línea 27):
guard !isExtracting, !urlString.isEmpty else { return }

// Existente en PythonBridge.swift (líneas 14-15):
guard !pythonPath.isEmpty, FileManager.default.isExecutableFile(atPath: pythonPath) else {
    throw ExtractionError.pythonNotFound(path: pythonPath)
}

// Replicar en funciones export:
guard let content = resultContent else { return }
```

---

### Patrón `// MARK: -` para secciones
**Source:** `ExtractionViewModel.swift` líneas 8, 14, 22, 64
**Apply to:** Nuevas secciones en ExtractionViewModel y en WebPreviewView Coordinator
```swift
// Existente:
// MARK: - Inputs (D-06)
// MARK: - Outputs (D-06)
// MARK: - Actions
// MARK: - Error formatting

// Nuevas secciones Phase 5 a añadir en ExtractionViewModel:
// MARK: - Phase 5: Preview state
// MARK: - Phase 5: Export
```

---

### Patrón `print()` para errores internos no-UI
**Source:** Sin instancias directas en el proyecto — convención inferida de la ausencia de logger externo
**Apply to:** `didFail` en Coordinator, bloques `catch` en exportación
```swift
// No existe logger dedicado en el proyecto — usar print() con prefijo de contexto:
print("[WebPreviewView] didFail: \(error.localizedDescription)")
print("[ExportMarkdown] Error al guardar: \(error.localizedDescription)")
print("[ExportHTML] Error al guardar: \(error.localizedDescription)")
```

---

## No Analog Found

| File / Sección | Role | Data Flow | Razón |
|----------------|------|-----------|-------|
| `Views/WebPreviewView.swift` (estructura NSViewRepresentable completa) | component | request-response | No existe ningún `NSViewRepresentable` en el proyecto. Usar RESEARCH.md Patrón 1 como referencia canónica. |
| `generateHTML(content:outputType:)` con marked.js inline | utility method | transform | No existe generación de HTML en el proyecto. Usar RESEARCH.md Patrón 2 completo. |
| `withCheckedContinuation` en NSSavePanel | async bridge | file-I/O | El proyecto usa `Task.detached` + `async let` (PythonBridge) pero no `withCheckedContinuation`. Usar RESEARCH.md Patrón 3. |
| `suggestedFilename(from:extension:)` | utility method | transform | Sin precedente en el proyecto. Implementar siguiendo convenciones de método privado + `String.prefix()`. |

---

## Dependency Map

```
WebPreviewView.swift
    ← importado en ContentView.swift
    ← recibe htmlContent: vm.htmlForPreview  (propiedad computada)
    ← recibe contentReady: $vm.contentReady  (@Binding → @Published)

ExtractionViewModel.swift (extensión Phase 5)
    ← usa resultContent: String? (ya existente, @Published)
    ← usa outputType: String (ya existente, @Published)
    → expone htmlForPreview: String? (nueva propiedad computada)
    → expone contentReady: Bool (nueva @Published)
    → expone exportFormat: String (nueva @Published)
    → expone export() async (nueva función @MainActor)

ContentView.swift (modificación Phase 5)
    ← vm: ExtractionViewModel (@StateObject, sin cambios)
    → reemplaza ScrollView { Text } por WebPreviewView
    → añade HStack export con Picker($vm.exportFormat) + Button
```

---

## Metadata

**Analog search scope:** `ExtractorApp/ExtractorApp/ExtractorApp/` (todos los archivos .swift)
**Files scanned:** 7 (ContentView, ExtractionViewModel, PythonBridge, SettingsView, ExtractionResult, ExtractionError, ExtractorAppApp)
**Pattern extraction date:** 2026-06-11
**NSViewRepresentable precedent:** NINGUNO en el codebase — WebPreviewView será el primer NSViewRepresentable del proyecto
**withCheckedContinuation precedent:** NINGUNO en el codebase — las funciones export serán el primer uso de continuaciones explícitas
