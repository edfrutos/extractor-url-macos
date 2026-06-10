# Phase 3 Research: Python Bridge y Preferencias

## 1. Contrato JSON verificado (extractor_url.py)

Lectura directa del código fuente confirma los campos exactos:

**Success:**
```json
{
  "status": "success",
  "url": "https://...",
  "selector": null,
  "output_type": "text|html|markdown",
  "char_count": 1234,
  "content": "..."
}
```

**Error:**
```json
{
  "status": "error",
  "url": "https://...",
  "error_message": "No se pudo extraer el contenido de la URL."
}
```

Nota: en error NO están presentes `selector`, `output_type`, `char_count`, `content`.
Codificación Swift recomendada: dos structs (`ExtractionSuccess`, `ExtractionFailure`) con un enum `ExtractionResponse` como discriminador, o un único struct con propiedades opcionales y `status`.

Mapeo de tipos CLI → `--type` argumento:
- `"text"` → extrae texto limpio
- `"html"` → HTML completo
- `"markdown"` → Markdown estructurado

## 2. @Observable en macOS 13.0 — Veredicto

**`@Observable` requiere macOS 14.0 / iOS 17.0.** No está disponible en runtime macOS 13.0 aunque compile con Xcode 15+. El framework `Observation` solo existe en macOS 14+.

**Solución para deployment target macOS 13.0:**
- Usar `ObservableObject + @Published` en toda la app (disponible desde macOS 11.0).
- No usar `@Observable` hasta subir el target mínimo a macOS 14.0.

```swift
// Patrón correcto para macOS 13.0:
final class ExtractionViewModel: ObservableObject {
    @Published var isExtracting = false
    @Published var result: ExtractionResult?
    @Published var error: ExtractionError?
}

// En la vista:
struct ContentView: View {
    @StateObject private var vm = ExtractionViewModel()
}
```

## 3. Foundation.Process + Pipe — Patrón Async Correcto

**Problema:** leer stdout hasta el final y luego stderr (o viceversa) causa deadlock cuando el proceso escribe más de ~64 KB en la pipe que no se está leyendo.

**Solución: dos `Task.detached` leyendo las pipes en paralelo:**

```swift
func callCLI(pythonPath: String, scriptPath: String,
             url: String, type: String,
             selector: String?, timeout: Int) async throws -> Data {

    let process = Process()
    process.executableURL = URL(fileURLWithPath: pythonPath)

    var args = [scriptPath, url, "--type", type, "--json"]
    if let sel = selector { args += ["--selector", sel] }
    args += ["--timeout", "\(timeout)"]
    process.arguments = args

    // Entorno explícito (no heredar el PATH restringido de launchd)
    let scriptDir = URL(fileURLWithPath: scriptPath).deletingLastPathComponent().path
    var env = ProcessInfo.processInfo.environment
    let venvBin = scriptDir + "/.venv/bin"
    env["VIRTUAL_ENV"] = scriptDir + "/.venv"
    env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
    process.environment = env
    process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError  = stderrPipe

    try process.run()

    // Leer ambas pipes en paralelo para evitar deadlock
    async let outData = Task.detached {
        stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    }.value
    async let errData = Task.detached {
        stderrPipe.fileHandleForReading.readDataToEndOfFile()
    }.value

    let (stdout, _) = try await (outData, errData)

    // waitUntilExit es seguro aquí: estamos en Task.detached, no en @MainActor
    process.waitUntilExit()

    guard process.terminationStatus == 0 || !stdout.isEmpty else {
        throw ExtractionError.processLaunchFailed(exitCode: process.terminationStatus)
    }
    return stdout
}
```

**Cancelación:** guardar referencia al `Process` en el ViewModel y llamar `process.terminate()` en `onDisappear` o al cancelar la `Task`.

## 4. Settings Scene + AppStorage

La `Settings {}` scene genera automáticamente el menú "ExtractorApp > Settings…" (⌘,):

```swift
@main
struct ExtractorApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
        Settings { SettingsView() }
    }
}
```

Validación reactiva con `@AppStorage`:

```swift
struct SettingsView: View {
    @AppStorage("pythonPath") var pythonPath: String = ""
    @AppStorage("scriptPath") var scriptPath: String = ""

    private var pythonValid: Bool {
        FileManager.default.isExecutableFile(atPath: pythonPath)
    }
    private var scriptValid: Bool {
        FileManager.default.fileExists(atPath: scriptPath)
    }

    var body: some View {
        Form {
            Section("Rutas") {
                HStack {
                    TextField("Intérprete Python", text: $pythonPath)
                    validationIcon(pythonValid)
                }
                HStack {
                    TextField("Script extractor_url.py", text: $scriptPath)
                    validationIcon(scriptValid)
                }
            }
            Text("El venv debe ser creado con el Python nativo (no Rosetta).")
                .font(.caption).foregroundColor(.secondary)
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .padding()
    }

    @ViewBuilder
    private func validationIcon(_ valid: Bool) -> some View {
        Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(valid ? .green : .red)
    }
}
```

`@AppStorage` persiste en `UserDefaults.standard`. Los valores son accesibles desde cualquier vista con la misma key.

## 5. Entitlements — Contenido Exacto

Fichero `ExtractorApp/ExtractorApp.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Sandbox OFF: permite Process() con rutas arbitrarias -->
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <!-- Descomenta si trafilatura usa JIT de regex y Python falla con SIGKILL: -->
    <!--
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    -->
</dict>
</plist>
```

En Xcode Build Settings:
- `CODE_SIGN_ENTITLEMENTS = ExtractorApp/ExtractorApp.entitlements`
- `ENABLE_HARDENED_RUNTIME = YES`
- `CODE_SIGN_INJECT_BASE_ENTITLEMENTS = NO` (evita entitlements de debug que entran en conflicto)

## 6. Xcode Project — Creación

**Enfoque recomendado: crear manualmente en Xcode GUI una única vez**, luego committear el `.xcodeproj` al repo. Las tareas del plan especifican los ajustes que el ejecutor debe configurar en Xcode.

**Alternativa automatizable: XcodeGen** (`brew install xcodegen` + `project.yml`). Permite reproducir el proyecto desde un YAML versionado. Más robusto para entornos CI.

**Estructura mínima del directorio:**
```
ExtractorApp/
├── ExtractorApp.xcodeproj/
│   └── project.pbxproj
├── ExtractorApp/
│   ├── ExtractorApp.swift          (@main, WindowGroup + Settings)
│   ├── ContentView.swift           (placeholder vacío para fase 3)
│   ├── Models/
│   │   ├── ExtractionResult.swift  (Codable)
│   │   └── ExtractionError.swift   (enum)
│   ├── Services/
│   │   └── PythonBridge.swift      (Process wrapper)
│   ├── Views/
│   │   └── SettingsView.swift
│   ├── Assets.xcassets/
│   └── ExtractorApp.entitlements
└── ExtractorApp.xcodeproj/
```

**Build settings clave:**
```
MACOSX_DEPLOYMENT_TARGET = 13.0
ARCHS = $(ARCHS_STANDARD)          // arm64 + x86_64 automático
SWIFT_VERSION = 5.9
PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.extractor-url
ENABLE_HARDENED_RUNTIME = YES
CODE_SIGN_ENTITLEMENTS = ExtractorApp/ExtractorApp.entitlements
```

## 7. Validación de Rutas — Patrón

```swift
enum PathValidation {
    case valid
    case notFound
    case notExecutable
    case empty
}

func validate(path: String) -> PathValidation {
    guard !path.isEmpty else { return .empty }
    guard FileManager.default.fileExists(atPath: path) else { return .notFound }
    guard FileManager.default.isExecutableFile(atPath: path) else { return .notExecutable }
    return .valid
}
```

Validación adicional al guardar preferencias (verifica que Python realmente funciona):
```swift
func quickValidatePython(at path: String) async -> Bool {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: path)
    p.arguments = ["--version"]
    p.standardOutput = Pipe()
    p.standardError = Pipe()
    return (try? await Task.detached { try p.run(); p.waitUntilExit(); return p.terminationStatus == 0 }.value) ?? false
}
```

## 8. ExtractionResult — Modelo Swift

```swift
struct ExtractionResult: Codable {
    let status: String          // "success" | "error"
    let url: String
    let selector: String?       // null en error
    let outputType: String?     // null en error (clave: "output_type")
    let charCount: Int?         // null en error (clave: "char_count")
    let content: String?        // null en error
    let errorMessage: String?   // null en success (clave: "error_message")

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }
}
```

## 9. Orden de Build Recomendado

1. **Crear proyecto Xcode** — estructura, build settings, entitlements (APP-05)
2. **ExtractionResult + ExtractionError** — modelos Codable sin dependencias
3. **PythonBridge** — wrapper Process() con el patrón async correcto
4. **SettingsView + AppStorage** — pantalla de preferencias con validación visual
5. **Verificación del bridge** — llamada de prueba desde ContentView o test manual

Dependencias: 1 → 2 → 3 → 4 (SettingsView depende de AppStorage keys que PythonBridge también lee)

## 10. Preguntas Abiertas (para verificar en ejecución)

| Pregunta | Cuándo verificar |
|----------|-----------------|
| ¿Necesita `allow-unsigned-executable-memory`? trafilatura usa regex JIT. | Al ejecutar el bridge por primera vez — observar si Python termina con SIGKILL |
| ¿`@StateObject` en ContentView causa re-init al navegar? | Al construir la ContentView en fase 4 |
| ¿El path `.venv/bin` relativo al script funciona desde el .app en Release? | En fase 7 (universal binary), no afecta desarrollo |

## RESEARCH COMPLETE

**Fichero:** `03-RESEARCH.md`

**Hallazgos clave:**
- `@Observable` no disponible en macOS 13 — usar `ObservableObject + @Published`
- Patrón correcto Process + Pipe: dos `Task.detached` leyendo en paralelo (no secuencial)
- Contrato JSON verificado directamente de `extractor_url.py`
- Entitlements: solo `app-sandbox = false`, `allow-unsigned-executable-memory` condicional
- Crear proyecto Xcode manualmente (GUI) una sola vez y commitearlo
