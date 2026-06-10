# Stack Research: SwiftUI macOS App

**Project:** extractor-url v2.0 — SwiftUI layer over Python CLI  
**Researched:** 2026-06-10  
**Confidence overall:** HIGH (all APIs verified against Apple official docs via Context7)

---

## Core Apple Frameworks

### 1. Foundation — `Process` (subprocess bridge)

**Confidence:** HIGH — verified via Context7 + developer.apple.com

| API | Signature | Notes |
|-----|-----------|-------|
| `Process()` | `class Process` | Replaces deprecated `NSTask` |
| `executableURL` | `var executableURL: URL?` | Prefer over deprecated `launchPath` |
| `arguments` | `var arguments: [String]?` | CLI args array |
| `environment` | `var environment: [String:String]?` | Inherit or override env vars |
| `standardOutput` | `var standardOutput: Any?` | Assign a `Pipe` instance |
| `standardError` | `var standardError: Any?` | Assign a `Pipe` instance |
| `run()` throws | `func run() throws` | Launches process (non-blocking) |
| `waitUntilExit()` | `func waitUntilExit()` | Blocks current thread until exit |
| `terminationStatus` | `var terminationStatus: Int32` | Exit code after termination |

**Usage pattern for this project:**

```swift
import Foundation

func runPythonCLI(pythonPath: String, scriptPath: String, url: String, type: String) async throws -> ExtractionResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: pythonPath)
    process.arguments = [scriptPath, url, "--type", type, "--json"]

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    try process.run()
    // Run on background task to avoid blocking main actor
    let data = await Task.detached(priority: .userInitiated) {
        process.waitUntilExit()
        return stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    }.value

    guard process.terminationStatus == 0 else {
        let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        throw ExtractionError.processFailed(String(data: errData, encoding: .utf8) ?? "")
    }
    return try JSONDecoder().decode(ExtractionResult.self, from: data)
}
```

**Minimum version:** macOS 10.13 (`executableURL`). macOS 10.0 (`launchPath`, deprecated).

**Critical constraint — App Sandbox:** Un app con sandbox activado NO puede lanzar ejecutables
desde rutas arbitrarias del sistema. Para esta app, que llama a `/usr/bin/python3` o un venv
del usuario, la solución es **desactivar el App Sandbox** en el entitlement file. Esto implica
que la app NO puede distribuirse en el Mac App Store, lo cual es aceptable para uso personal.
Alternativa si se quisiera sandbox: bundlear un Python embebido dentro del `.app`, pero añade
complejidad enorme y no encaja con el objetivo del proyecto.

---

### 2. WebKit — `WKWebView` (preview HTML + export PDF)

**Confidence:** HIGH — verificado en Context7, fuente: developer.apple.com/documentation/webkit

Para integrar `WKWebView` en SwiftUI se usa `NSViewRepresentable` (macOS, AppKit bridge).
No existe un componente SwiftUI nativo para WKWebView — el wrapper es obligatorio.

**NSViewRepresentable protocol:**

```swift
@MainActor @preconcurrency
protocol NSViewRepresentable : View where Self.Body == Never
```

Disponible desde macOS 10.15. Requiere implementar `makeNSView(context:)` y
`updateNSView(_:context:)`.

**PDF export APIs en WKWebView:**

| Método | Firma | macOS mínimo | Notas |
|--------|-------|--------------|-------|
| `pdf(configuration:)` | `async func pdf(configuration: WKPDFConfiguration = .init()) throws -> Data` | **macOS 12.0+** | Moderno, async/await, retorna `Data` directamente |
| `createPDF(configuration:completionHandler:)` | `func createPDF(configuration:completionHandler:)` | macOS 11.0+ | Callback-based, alternativa si se baja el deployment target |
| `printOperation(with:)` | `func printOperation(with printInfo: NSPrintInfo) -> NSPrintOperation` | macOS 11.0+ | Para imprimir o guardar PDF vía NSPrintOperation, más control sobre layout |

**Recomendación:** Usar `pdf(configuration:)` (async) como primera opción. Deployment target
macOS 12 lo hace disponible en todos los equipos con Apple Silicon (M1 mínimo = macOS 11, pero
macOS 12 fue la primera actualización universal). Mantener `createPDF` como fallback solo si
se baja el target a 11.

**WKPDFConfiguration:** clase de configuración para `pdf(configuration:)`. Permite especificar
el `rect` de captura (nil = página completa). Es la opción mínima; pasar `WKPDFConfiguration()`
por defecto es suficiente para la mayoría de los casos.

**Pattern completo para guardar PDF:**

```swift
// Dentro del NSViewRepresentable coordinator o en un @MainActor async context
let pdfData = try await webView.pdf()
// pdfData es Data — guardar con NSSavePanel
```

---

### 3. AppKit — `NSSavePanel` (export a archivo)

**Confidence:** HIGH — verificado developer.apple.com

Para las tres rutas de exportación (PDF, Markdown, HTML) se usa `NSSavePanel` directamente
desde AppKit. SwiftUI ofrece `.fileExporter(...)` como alternativa más declarativa.

**NSSavePanel (AppKit, imperativo):**

| API | Tipo | Notas |
|-----|------|-------|
| `NSSavePanel()` | init | Crea el panel |
| `allowedContentTypes` | `[UTType]` | macOS 11+. Usar `UTType.pdf`, `UTType.plainText`, `UTType.html` |
| `nameFieldStringValue` | `String` | Nombre de archivo por defecto |
| `directoryURL` | `URL?` | Directorio inicial |
| `begin(completionHandler:)` | `(NSApplication.ModalResponse) -> Void` | Abre el panel asíncronamente |
| `url` | `URL?` | URL seleccionada tras confirmación |

**SwiftUI `.fileExporter(...)` (alternativa declarativa):**

```swift
.fileExporter(
    isPresented: $showExporter,
    document: myDocument,  // debe conformar FileDocument o Transferable
    contentTypes: [.pdf],
    defaultFilename: "extraccion"
) { result in
    // result: Result<URL, Error>
}
```

**Recomendación:** Para PDF (que es `Data` raw de WKWebView) usar `NSSavePanel` directamente,
ya que `.fileExporter` requiere un `FileDocument` o `Transferable`. Para Markdown y HTML
(que son `String`), `.fileExporter` con un `FileDocument` conforming type es más limpio.
Ambos enfoques son válidos; mezclarlos es habitual.

**UTType importantes para este proyecto:**
- PDF: `UTType.pdf` — `com.adobe.pdf`
- Markdown: `UTType(filenameExtension: "md")` o `UTType.plainText` (md no tiene UTType estándar built-in en versiones < macOS 14)
- HTML: `UTType.html` — `public.html`

---

### 4. SwiftUI — App structure, Settings, AppStorage

**Confidence:** HIGH — verificado Context7, fuente: developer.apple.com/documentation/swiftui

**Estructura de la app (single-window, no document-based):**

```swift
@main
struct ExtractorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        Settings {
            PreferencesView()
        }
        #endif
    }
}
```

`WindowGroup` es la elección correcta para una app con una sola ventana principal. 
`DocumentGroup` no aplica porque el concepto de "documento" no es el modelo del extractor.
`Settings {}` escena proporciona automáticamente el ítem "Preferencias..." en el menú de la
app y abre la ventana de preferencias con Cmd+, .

**AppStorage para preferencias de paths:**

```swift
struct PreferencesView: View {
    @AppStorage("pythonPath") private var pythonPath: String = "/usr/bin/python3"
    @AppStorage("scriptPath") private var scriptPath: String = ""
    @AppStorage("defaultTimeout") private var defaultTimeout: Double = 30.0

    var body: some View {
        Form {
            TextField("Python interpreter", text: $pythonPath)
            TextField("Script path", text: $scriptPath)
            Slider(value: $defaultTimeout, in: 5...120) {
                Text("Timeout (\(Int(defaultTimeout))s)")
            }
        }
        .padding()
        .frame(minWidth: 400)
    }
}
```

`@AppStorage` sincroniza automáticamente con `UserDefaults.standard`. Los valores persisten
entre sesiones sin código adicional. Para paths de archivos, considerar complementar con
`@AppStorage` + un botón de selección de archivo (usando `NSOpenPanel`) para validar que la
ruta existe.

**Estado compartido entre vistas:** Usar `@StateObject` / `@ObservableObject` (macOS 12-) o
`@Observable` macro (macOS 14+). Para el deployment target recomendado (macOS 13), usar
`@StateObject` + `ObservableObject`.

---

### 5. Swift Concurrency — subprocess sin bloquear UI

**Confidence:** HIGH — verificado Context7

`Foundation.Process.waitUntilExit()` es bloqueante. Para no congelar el main actor (hilo UI):

```swift
// Patrón recomendado
func runExtraction() async {
    isLoading = true
    defer { isLoading = false }
    do {
        result = try await Task.detached(priority: .userInitiated) {
            try runPythonCLI(...)  // bloquea este background thread
        }.value
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

`Task.detached` ejecuta en un thread del pool de Swift concurrency, fuera del main actor.
`await` devuelve el control al main actor cuando termina, actualizando UI de forma segura.

---

## Third-party Swift Packages

**Ninguno necesario.** Todas las funcionalidades requeridas están cubiertas por frameworks Apple:

| Necesidad | Framework Apple | Versión requerida |
|-----------|----------------|-------------------|
| Subprocess | `Foundation.Process` | macOS 10.13+ |
| Web preview | `WebKit.WKWebView` via `NSViewRepresentable` | macOS 10.15+ |
| PDF export | `WKWebView.pdf(configuration:)` | macOS 12.0+ |
| File save dialog | `AppKit.NSSavePanel` | macOS 10.0+ |
| Preferences storage | `SwiftUI.AppStorage` / `Foundation.UserDefaults` | macOS 11+ |
| Settings window | `SwiftUI.Settings` scene | macOS 11+ |
| Async execution | Swift Concurrency (`Task`, `async/await`) | macOS 12+ (backported partial a 10.15) |
| JSON parsing | `Foundation.JSONDecoder` | macOS 10.10+ |

**Nota sobre swift-foundation Subprocess:** Existe una propuesta `0007-swift-subprocess.md`
para un API de subprocess moderno y async-native en swift-foundation. A fecha de investigación
(junio 2026) es una propuesta — **no está en stdlib estable**. Usar `Foundation.Process` clásico.

---

## Xcode Project Settings

### Universal Binary (arm64 + x86_64)

En `Build Settings` del target principal:

| Setting | Valor |
|---------|-------|
| `ARCHS` | `$(ARCHS_STANDARD)` (por defecto incluye arm64 + x86_64 para macOS < 27 deployment target) |
| `MACOSX_DEPLOYMENT_TARGET` | `13.0` |
| `EXCLUDED_ARCHS` | vacío (no excluir ninguna arquitectura) |

**Nota importante de los release notes de Xcode 27 (verificado Context7):** A partir de un
deployment target de macOS 27.0, `ARCHS_STANDARD` excluye x86_64 por defecto. Para targets
macOS 13–15, `ARCHS_STANDARD` sigue incluyendo ambas arquitecturas automáticamente. Para
macOS 13 no es necesario forzar `ARCHS = arm64 x86_64` explícitamente.

Para verificar el resultado:
```bash
lipo -info ExtractorUrl.app/Contents/MacOS/ExtractorUrl
# debe mostrar: arm64 x86_64
```

Al compilar, seleccionar destino "Any Mac (Apple Silicon, Intel)" en Xcode o:
```bash
xcodebuild -scheme ExtractorUrl -destination "generic/platform=macOS"
```

### Deployment Target

**Recomendación: macOS 13.0 (Ventura)**

Justificación:
- `WKWebView.pdf(configuration:)` requiere macOS 12.0+ (HIGH confidence, Context7)
- `NSSavePanel.allowedContentTypes` requiere macOS 11.0+
- `Settings {}` scene requiere macOS 11.0+
- `WindowGroup` base requiere macOS 11.0+
- macOS 13 asegura Swift Concurrency completo sin limitaciones de backport
- macOS 13 es el mínimo razonable en 2026 para no excluir usuarios con equipos de 2-3 años

**Alternativa macOS 12.0:** Viable si se quiere cubrir más Macs Intel de 2017-2019.
La diferencia funcional para este proyecto es mínima — macOS 12 ya tiene `pdf(configuration:)`.

### Entitlements

Para distribución directa (fuera del Mac App Store):

```xml
<!-- ExtractorUrl.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ...>
<plist version="1.0">
<dict>
    <!-- App Sandbox DESACTIVADO para permitir Process() con ejecutables arbitrarios -->
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <!-- Permitir conexiones de red salientes (para que el Python descargue URLs) -->
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

**Por qué desactivar sandbox:** La app llama a `python3` (o un intérprete configurable por el
usuario en cualquier path) vía `Foundation.Process`. El App Sandbox impide lanzar ejecutables
fuera del bundle. Dado que esta app es para distribución personal (no Mac App Store), desactivar
sandbox es la solución correcta y documentada por Apple para herramientas de desarrollador.

**Implicación:** Sin sandbox, la app no puede publicarse en el Mac App Store. Compatible con
distribución directa (.dmg), Homebrew Cask, o firma y notarización estándar para Gatekeeper.

### Code Signing (para notarización fuera del App Store)

```
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = [Tu Team ID de Apple Developer]
CODE_SIGN_IDENTITY = Apple Development (Debug) / Developer ID Application (Release)
```

Para distribución pública: firmar con "Developer ID Application" y notarizar con
`notarytool` antes de distribuir el .dmg.

### Otras configuraciones relevantes

```
SWIFT_VERSION = 5.9  (o 5.10, usar la versión del Xcode instalado)
PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.extractor-url
PRODUCT_NAME = ExtractorUrl
INFOPLIST_KEY_NSHumanReadableCopyright = © 2026 edefrutos
```

En `Info.plist` añadir:
```xml
<!-- Descripción de uso de red (no requerida en macOS, pero buena práctica) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

## What NOT to Include

### 1. Swift Subprocess proposal (swift-foundation 0007/0037)
**Por qué no:** Es una propuesta de evolución de Swift, no una API estable en stdlib.
Usar `Foundation.Process` + `Pipe` + `Task.detached`. Estable, documentado, macOS 10.13+.

### 2. Electron / Tauri / WebView wrappers
**Por qué no:** El objetivo es una app nativa SwiftUI. Añadir runtime de Node o Rust
contrarresta exactamente el beneficio de la app nativa.

### 3. Combine framework para el subprocess bridge
**Por qué no:** Swift Concurrency (async/await + Task) es el modelo moderno. Combine añade
complejidad de Publishers/Subscribers para un caso de uso que `async/await` resuelve más
limpiamente. Si el proyecto ya usa Combine por otra razón, puede integrarse, pero no vale
la pena introducirlo solo para esto.

### 4. DocumentGroup scene
**Por qué no:** El extractor no es un editor de documentos. `WindowGroup` es correcto.
`DocumentGroup` obligaría a modelar cada extracción como un "documento" con gestión de
archivos recientes, autosave, etc. — overhead innecesario para el caso de uso.

### 5. NSPrintOperation para PDF en lugar de WKWebView.pdf()
**Por qué no:** `NSPrintOperation` vía `WKWebView.printOperation(with:)` abre el diálogo
de impresión del sistema (incluyendo "Guardar como PDF" de macOS), pero no produce un archivo
PDF programáticamente de forma directa. Para exportación silenciosa a archivo PDF sin diálogo
de impresión, `WKWebView.pdf(configuration:)` es la API correcta.

### 6. URLSession para las peticiones HTTP desde Swift
**Por qué no:** El extractor Python ya gestiona las peticiones HTTP con `requests` + lógica
de trafilatura. Duplicar eso en Swift añade superficie de bugs y divergencia de comportamiento.
El bridge subprocess es el diseño correcto: Swift es la UI, Python es el motor.

### 7. Core Data para persistencia de historial
**Por qué no:** El scope de v2.0 no incluye historial de extracciones. Si se añade en futuras
fases, UserDefaults + un array codificable o un archivo JSON simple serán suficientes para
volúmenes de uso personal. Core Data es overhead de modelo gestionado para este volumen.

### 8. SwiftUI `.webView` o similar de terceros
**Por qué no:** No existe un componente WebView nativo en SwiftUI. El `NSViewRepresentable`
wrapper sobre `WKWebView` es la solución oficial y tiene ~10 líneas de código. No hay ninguna
librería de terceros que justifique una dependencia.

---

## Dependency Summary

```
SwiftUI (macOS 13.0+)
├── Foundation.Process + Pipe               — subprocess bridge
├── WebKit.WKWebView via NSViewRepresentable — HTML preview
│   └── WKWebView.pdf(configuration:)       — PDF export (macOS 12.0+)
├── AppKit.NSSavePanel                      — file save dialogs
├── SwiftUI.AppStorage / UserDefaults       — preferences persistence
├── SwiftUI.Settings scene                  — preferences window
└── Swift Concurrency (Task.detached)       — background subprocess

Third-party packages: NONE
```

---

## Sources

- [Foundation.Process — Apple Developer](https://developer.apple.com/documentation/foundation/process) — HIGH confidence (Context7 + WebFetch)
- [WKWebView.pdf(configuration:) — Apple Developer](https://developer.apple.com/documentation/webkit/wkwebview/pdf%28configuration%3A%29) — HIGH confidence (Context7)
- [WKWebView.printOperation(with:) — Apple Developer](https://developer.apple.com/documentation/webkit/wkwebview/printoperation%28with%3A%29) — HIGH confidence (Context7)
- [NSViewRepresentable — Apple Developer](https://developer.apple.com/documentation/swiftui/nsviewrepresentable) — HIGH confidence (Context7)
- [NSSavePanel — Apple Developer](https://developer.apple.com/documentation/appkit/nssavepanel) — HIGH confidence (WebFetch)
- [AppStorage — Apple Developer](https://developer.apple.com/documentation/swiftui/persistent-storage) — HIGH confidence (Context7)
- [Settings scene — Apple Developer](https://developer.apple.com/documentation/swiftui/settings) — HIGH confidence (Context7)
- [fileExporter — Apple Developer](https://developer.apple.com/documentation/swiftui/modal-presentations) — HIGH confidence (Context7)
- [Xcode universal binary build settings — Apple Developer](https://developer.apple.com/documentation/xcode/embedding-a-helper-tool-in-a-sandboxed-app) — HIGH confidence (Context7)
- [Xcode 27 release notes — ARCHS_STANDARD x86_64 deprecation](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) — HIGH confidence (Context7)
- [Swift Foundation Subprocess proposal 0007](https://github.com/swiftlang/swift-foundation/blob/main/Proposals/0007-swift-subprocess.md) — MEDIUM confidence (propuesta, no API estable)
