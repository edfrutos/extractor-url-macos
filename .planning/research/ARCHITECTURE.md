# Architecture Research: SwiftUI + Python CLI Integration

**Project:** extractor-url v2.0 SwiftUI Native App
**Researched:** 2026-06-10
**Confidence:** HIGH (Python contract verified from source; SwiftUI patterns from official Apple docs via Context7)

---

## Project Structure

```
extractor-url/                          ← monorepo root (existing)
├── core.py                             ← motor Python (sin cambios)
├── extractor_url.py                    ← CLI/GUI Python (sin cambios en v2.0)
├── tests/                              ← suite pytest (sin cambios)
├── .venv/                              ← virtualenv Python
│   └── bin/python
├── ExtractorApp/                       ← nuevo directorio Xcode (sibling de core.py)
│   ├── ExtractorApp.xcodeproj/
│   ├── ExtractorApp/
│   │   ├── ExtractorApp.swift          ← @main App entry point
│   │   ├── ContentView.swift           ← vista raíz
│   │   ├── ExtractionViewModel.swift   ← @Observable ViewModel
│   │   ├── PythonBridge.swift          ← Process() wrapper async
│   │   ├── Models/
│   │   │   └── ExtractionResult.swift  ← Codable model del JSON
│   │   ├── Views/
│   │   │   ├── InputView.swift         ← campo URL + opciones
│   │   │   ├── PreviewView.swift       ← render del contenido extraído
│   │   │   └── ExportView.swift        ← botones export
│   │   ├── Settings/
│   │   │   └── SettingsView.swift      ← preferencias (ruta Python)
│   │   └── Resources/
│   │       └── ExtractorApp.entitlements
│   └── ExtractorAppTests/
│       └── PythonBridgeTests.swift     ← tests del bridge con mock
├── .planning/
└── README.md
```

**Rationale de ubicación:** `ExtractorApp/` como sibling directo de `core.py` en la raíz del repo. Esto mantiene el monorepo cohesionado, permite a Xcode usar rutas relativas al repo, y no contamina el espacio Python con assets Swift ni viceversa. El proyecto Xcode no necesita estar dentro de ningún subdirectorio especial de macOS.

---

## Python Path Strategy

**Recomendación: Ruta configurable en preferencias con auto-detección en primer arranque.**

El enfoque de ruta hardcodeada al `.venv` del repo es frágil (falla si el usuario mueve el repo). Bundling del intérprete Python es innecesariamente complejo para uso personal sin App Store. La estrategia óptima es:

### Orden de resolución en primer arranque

```
1. UserDefaults["pythonPath"] → usar si existe y es ejecutable
2. <app-bundle>/../../../.venv/bin/python → relativo al bundle dentro del repo
3. ~/.pyenv/shims/python → pyenv si instalado
4. /usr/local/bin/python3 → Homebrew Intel
5. /opt/homebrew/bin/python3 → Homebrew Apple Silicon
6. /usr/bin/python3 → Python del sistema (macOS 12.3+)
```

Si ninguno es válido: mostrar `SettingsView` forzosamente con alerta explicativa.

### Implementación en `PythonBridge.swift`

```swift
static func resolvePythonPath() -> URL? {
    // 1. UserDefaults persistido
    if let saved = UserDefaults.standard.string(forKey: "pythonPath"),
       FileManager.default.isExecutableFile(atPath: saved) {
        return URL(fileURLWithPath: saved)
    }
    // 2. .venv relativo al bundle (repo local)
    let bundleURL = Bundle.main.bundleURL
    // ExtractorApp.app está en ExtractorApp/build/… → subir hasta la raíz del repo
    let candidates: [URL] = [
        bundleURL.deletingLastPathComponent()
                 .deletingLastPathComponent()
                 .deletingLastPathComponent()
                 .appendingPathComponent(".venv/bin/python"),
        URL(fileURLWithPath: "/opt/homebrew/bin/python3"),
        URL(fileURLWithPath: "/usr/local/bin/python3"),
        URL(fileURLWithPath: "/usr/bin/python3"),
    ]
    return candidates.first {
        FileManager.default.isExecutableFile(atPath: $0.path)
    }
}
```

El `SettingsView` expone un campo de texto + botón "Seleccionar…" (NSOpenPanel) que persiste en `@AppStorage("pythonPath")`. El path resuelto se valida ejecutando `python --version` antes de aceptarlo.

**Nota sobre sandbox:** Esta app NO va a App Store, por tanto el sandbox de macOS no es obligatorio. Se recomienda explícitamente NO habilitar la App Sandbox en las entitlements, lo que permite llamar a `Process()` sin restricciones sobre rutas de ejecutables. Para notarización (distribución con Developer ID) se requiere Hardened Runtime pero no sandbox.

---

## Data Flow

```
[SwiftUI View]
     │ usuario pulsa "Extraer"
     ▼
[ExtractionViewModel.extract(url:type:selector:)]
     │ @Observable, corre en Task { } → se ejecuta en background
     ▼
[PythonBridge.run(pythonPath:scriptPath:args:)] → async throws
     │
     ├─ Process()
     │   ├── executableURL = pythonPath          (URL)
     │   ├── arguments = [scriptPath, url,
     │   │                "--type", type,
     │   │                "--json",
     │   │                "--selector", selector] (si existe)
     │   ├── standardOutput = Pipe()
     │   └── standardError  = Pipe()
     │
     ├─ process.launch()  → async via withCheckedThrowingContinuation
     ├─ process.waitUntilExit()                  (en Task background)
     │
     ├─ stdout Data → String(UTF-8)
     └─ stderr Data → String(UTF-8)  (para diagnóstico de errores)
          │
          ▼
    JSONDecoder().decode(ExtractionResult.self, from: stdoutData)
          │
          ▼  (back on @MainActor)
[ExtractionViewModel.result: ExtractionResult?]
          │
          ▼
[PreviewView, ExportView] → re-render automático vía @Observable
```

### Tipos Swift

```swift
// Models/ExtractionResult.swift
struct ExtractionResult: Codable {
    let status: String          // "success" | "error"
    let url: String
    let selector: String?
    let outputType: String      // "text" | "html" | "markdown"
    let charCount: Int?
    let content: String?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case status, url, selector
        case outputType   = "output_type"
        case charCount    = "char_count"
        case content
        case errorMessage = "error_message"
    }
}

// Contrato verificado del JSON Python actual (extractor_url.py líneas 281-297):
// SUCCESS: { "status": "success", "url", "selector", "output_type",
//            "char_count", "content" }
// ERROR:   { "status": "error", "url", "error_message" }
```

### Estado del ViewModel

```swift
@Observable
class ExtractionViewModel {
    var url: String = ""
    var outputType: OutputType = .markdown
    var selector: String = ""
    var isLoading: Bool = false
    var result: ExtractionResult? = nil
    var errorState: ExtractionError? = nil

    func extract() async { ... }
}
```

---

## Error States

Cuatro estados de error distintos con superficies de UI diferentes:

| Error | Causa | Detección | Surface en UI |
|-------|-------|-----------|---------------|
| **PythonNotFound** | `resolvePythonPath()` devuelve nil | Al arrancar la app o al pulsar Extraer | Alert modal + abre SettingsView automáticamente |
| **ScriptNotFound** | `extractor_url.py` no encontrado en la ruta esperada | `FileManager.fileExists` antes de `Process.launch()` | Alert con ruta esperada y botón para seleccionar manualmente |
| **ExtractionFailure** | Python retorna exit code 1, stderr no vacío | `process.terminationStatus != 0` | Mensaje de error inline bajo el campo URL, con texto de stderr formateado |
| **JSONParseError** | stdout no es JSON válido (p.ej. excepción Python sin capturar) | `JSONDecoder` lanza | Alert con dump de stdout raw (truncado a 500 chars) para diagnóstico |

```swift
enum ExtractionError: LocalizedError {
    case pythonNotFound
    case scriptNotFound(expectedPath: String)
    case extractionFailed(exitCode: Int32, stderr: String)
    case jsonParseFailed(rawOutput: String)

    var errorDescription: String? {
        switch self {
        case .pythonNotFound:
            return "No se encontró el intérprete Python. Configura la ruta en Preferencias."
        case .scriptNotFound(let path):
            return "No se encontró el script en: \(path)"
        case .extractionFailed(let code, let stderr):
            return "Error de extracción (código \(code)): \(stderr.prefix(200))"
        case .jsonParseFailed(let raw):
            return "Respuesta inesperada del script: \(raw.prefix(500))"
        }
    }
}
```

**Manejo de stderr:** Capturar siempre en un `Pipe` separado. No mostrar stderr en la UI a menos que `terminationStatus != 0`. Guardar en log de diagnóstico (`os_log`) siempre.

---

## SwiftUI Architecture

**Recomendación: `@Observable` + `@State` local. No usar ObservableObject.**

Justificación basada en docs Apple actuales (macOS 14+ / Swift 5.9+, verificado vía Context7):

- `@Observable` (macro) elimina la necesidad de `@Published` en cada propiedad. SwiftUI solo re-renderiza las vistas que leen propiedades que realmente cambian.
- `ObservableObject` + `@StateObject` es el patrón legacy. La migración de `ObservableObject` a `@Observable` es la dirección oficial de Apple.
- MVVM ligero: un `ExtractionViewModel` por escena es suficiente. No se necesita arquitectura compleja (coordinadores, routers) para una app de una sola ventana.
- La concurrencia usa `Task { }` lanzado desde SwiftUI + `@MainActor` para las actualizaciones de estado, que es el patrón moderno recomendado sobre `DispatchQueue.main.async`.

```swift
// Patrón recomendado
@Observable
class ExtractionViewModel { ... }

struct ContentView: View {
    @State private var viewModel = ExtractionViewModel()

    var body: some View {
        InputView(viewModel: viewModel)
        if viewModel.isLoading { ProgressView() }
        if let result = viewModel.result { PreviewView(result: result) }
    }
}

// Llamada async desde botón
Button("Extraer") {
    Task {
        await viewModel.extract()
    }
}
```

**Settings** usa `@AppStorage` directamente en `SettingsView`, sin pasar por el ViewModel. Los valores se persisten automáticamente en `UserDefaults`.

```swift
struct SettingsView: View {
    @AppStorage("pythonPath") private var pythonPath: String = ""
    // NSOpenPanel para seleccionar ruta
}
```

**Una ventana, sin NavigationSplitView:** Para esta app (una sola tarea) basta con un layout vertical lineal. No se justifica la complejidad de NavigationStack/SplitView.

---

## New Components

Todos los ficheros siguientes son creaciones nuevas (no existen en el proyecto actual):

| Componente | Tipo | Responsabilidad |
|------------|------|-----------------|
| `ExtractorApp/ExtractorApp.xcodeproj` | Proyecto Xcode | Configuración build, targets, entitlements |
| `ExtractorApp/ExtractorApp/ExtractorApp.swift` | Swift | `@main` App struct, `Settings {}` scene |
| `ExtractorApp/ExtractorApp/ContentView.swift` | SwiftUI View | Layout raíz: inputs + preview + export |
| `ExtractorApp/ExtractorApp/ExtractionViewModel.swift` | `@Observable` | Estado global: url, tipo, resultado, errores, loading |
| `ExtractorApp/ExtractorApp/PythonBridge.swift` | Swift actor | `Process()` async wrapper, path resolution, stdout/stderr capture |
| `ExtractorApp/ExtractorApp/Models/ExtractionResult.swift` | Codable struct | Modelo del contrato JSON del CLI Python |
| `ExtractorApp/ExtractorApp/Views/InputView.swift` | SwiftUI View | Campo URL, selector CSS, tipo, botón Extraer |
| `ExtractorApp/ExtractorApp/Views/PreviewView.swift` | SwiftUI View | ScrollView con el contenido extraído |
| `ExtractorApp/ExtractorApp/Views/ExportView.swift` | SwiftUI View | Botones export Markdown/HTML/PDF con `.fileExporter` |
| `ExtractorApp/ExtractorApp/Settings/SettingsView.swift` | SwiftUI View | Preferencias: ruta Python, timeout, caché |
| `ExtractorApp/ExtractorApp/Resources/ExtractorApp.entitlements` | plist | Hardened Runtime SIN sandbox; `com.apple.security.cs.allow-unsigned-executable-memory` si necesario |
| `ExtractorApp/ExtractorAppTests/PythonBridgeTests.swift` | XCTest | Tests del bridge usando mock de Process (sin red real) |

---

## Modified Components

**Componentes Python existentes que necesitan cambios mínimos:**

| Componente | Cambio requerido | Motivo |
|------------|-----------------|--------|
| `extractor_url.py` | **Ninguno** | El contrato JSON `--json` ya está implementado y verificado en líneas 280-297. La CLI acepta todos los args necesarios. |
| `core.py` | **Ninguno** | El motor de extracción no necesita modificaciones para el bridge. |
| `tests/test_converter.py` | **Ninguno** | Tests existentes no se ven afectados. |
| `tests/test_cli.py` | **Posible extensión** | Añadir test que valide el schema JSON completo (campo `selector` puede ser null, `char_count` puede ser null en error). Recomendado pero no bloqueante. |

**No se toca Python en las fases SwiftUI.** El puente es unidireccional: Swift llama a Python, nunca al revés.

---

## Phase Build Order

Las fases son dependientes en cadena estricta. No hay paralelismo útil entre ellas.

### Fase 2.1 — JSON Bridge + Path Resolution (BLOQUEANTE para todo lo demás)

**Qué construir:** `PythonBridge.swift`, `ExtractionResult.swift`, `ExtractionViewModel.swift` (solo extract + error states), tests de bridge con mock.

**Dependencias:** El contrato JSON del CLI Python YA existe y está verificado. Esta fase puede comenzar inmediatamente.

**Criterio de éxito:** `PythonBridge.run(...)` devuelve un `ExtractionResult` válido o lanza `ExtractionError` tipado en cada escenario (Python no encontrado, exit code 1, JSON inválido).

**Por qué es bloqueante:** Sin un bridge que funcione, ninguna vista puede mostrar datos reales. El preview y todos los exports dependen de `ExtractionResult.content`.

---

### Fase 2.2 — UI de extracción (depende de 2.1)

**Qué construir:** `ContentView`, `InputView`, `PreviewView`, `SettingsView`, integración `@Observable` completa.

**Dependencias:** `ExtractionViewModel` de 2.1 con el tipo `ExtractionResult` estabilizado.

**Criterio de éxito:** El usuario puede introducir una URL, pulsar Extraer, ver el contenido en `PreviewView`, y recibir mensajes de error descriptivos para cada `ExtractionError`.

---

### Fase 2.3 — Export Markdown y HTML (depende de 2.2)

**Qué construir:** `ExportView` con `.fileExporter` para `.md` y `.html`. El HTML autocontenido requiere generar un template con CSS inline a partir de `result.content`.

**Dependencias:** `ExtractionResult.content` no nil (usuario ha extraído algo). El `.fileExporter` de SwiftUI maneja `NSSavePanel` internamente — no es necesario usar AppKit directamente.

**Criterio de éxito:** Los botones "Exportar Markdown" y "Exportar HTML" abren el selector de archivo del sistema y guardan contenido correcto.

**Nota sobre HTML autocontenido:** Requiere un template Swift (string literal) que envuelve `result.content` con `<html>`, `<head>` con CSS inline básico, y `<body>`. No depende de WebKit.

---

### Fase 2.4 — Export PDF (depende de 2.3, más complejo)

**Qué construir:** Export PDF vía `WKWebView` → `NSPrintOperation` o vía `ImageRenderer` + `CGContext`.

**Dependencias:** El HTML autocontenido de 2.3 (la fuente más fidedigna para PDF de texto enriquecido). Alternativamente, `ImageRenderer` puede renderizar una SwiftUI View directamente a PDF sin WebKit.

**Recomendación:** Usar `ImageRenderer.render { size, renderer in ... CGContext PDF ... }` (patrón verificado en docs Apple, Context7) para contenido simple de texto. Si se necesita layout HTML complejo, usar `WKWebView` + `NSPrintOperation`. Para MVP: `ImageRenderer` primero, `WKWebView` como mejora posterior.

**Criterio de éxito:** El botón "Exportar PDF" genera un archivo PDF legible con el contenido extraído.

**Por qué va al final:** Es la ruta de código más compleja (implica WebKit o ImageRenderer, configuración de página, aspectos de impresión) y no desbloquea ninguna otra funcionalidad. Es seguro diferirla.

---

### Resumen de dependencias

```
2.1 JSON Bridge ──► 2.2 UI + Preview ──► 2.3 Export MD/HTML ──► 2.4 Export PDF
     (fundación)       (funcionalidad       (valor añadido)        (complemento)
                        completa)
```

---

## Sandbox y Distribución

**Configuración recomendada para `ExtractorApp.entitlements`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- NO App Sandbox: permite Process() sin restricciones de ruta -->
    <!-- com.apple.security.app-sandbox → ausente intencionalmente -->

    <!-- Hardened Runtime: requerido para notarización con Developer ID -->
    <key>com.apple.security.hardened-runtime</key>
    <true/>

    <!-- Si Python usa JIT o modifica memoria ejecutable (trafilatura/regex) -->
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
</dict>
</plist>
```

**Implicaciones:**
- Sin sandbox → `Process()` puede llamar a cualquier ejecutable del sistema incluyendo `.venv/bin/python`.
- Hardened Runtime habilitado → apto para notarización (distribución mediante DMG o zip con Developer ID).
- `allow-unsigned-executable-memory` → algunas dependencias Python (regex con compilación JIT) lo requieren cuando Hardened Runtime está activo. Añadir si el proceso Python falla con `SIGKILL` o errores de permisos de memoria.
- Universal binary (fat binary x86_64 + arm64) → configurar en Xcode: Build Settings → Architectures → `$(ARCHS_STANDARD)` (valor por defecto desde Xcode 12, genera fat binary automáticamente).

---

## Sources

- SwiftUI `@Observable` macro: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app (Context7, HIGH confidence)
- SwiftUI `@AppStorage`: https://developer.apple.com/documentation/swiftui/appstorage (Context7, HIGH confidence)
- SwiftUI `.fileExporter`: https://developer.apple.com/documentation/swiftui/view/fileexporter (Context7, HIGH confidence)
- SwiftUI `ImageRenderer` → PDF: https://developer.apple.com/documentation/swiftui/imagerenderer (Context7, HIGH confidence)
- Swift `Process()` + `Pipe` async pattern: https://github.com/swiftlang/swift-foundation/blob/main/Proposals/0007-swift-subprocess.md (Context7, HIGH confidence)
- JSON contract Python CLI: verificado directamente de `extractor_url.py` líneas 280-297 (HIGH confidence, source)
- App Sandbox para non-App Store: no requerido — verificado con múltiples fuentes (MEDIUM confidence, consistente con comportamiento conocido de macOS)
- Hardened Runtime para notarización: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution (MEDIUM confidence, páginas Apple no devolvieron cuerpo completo pero la política es bien conocida y consistente)
