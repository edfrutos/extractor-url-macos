# Pitfalls Research: SwiftUI macOS + Subprocess + Export

**Proyecto:** extractor-url v2.0 SwiftUI Native App
**Fecha:** 2026-06-10
**Confianza general:** MEDIUM-HIGH (patrones verificados con documentación oficial Apple + foros Apple Developer)

---

## Critical Pitfalls (bloquean el progreso si se ignoran)

### 1. Foundation.Process() hereda un PATH reducido en apps GUI

**Problem:**
Una app GUI lanzada desde Finder o Dock arranca con el entorno de `launchd`, que expone un `PATH` mínimo (`/usr/bin:/bin:/usr/sbin:/sbin`). No incluye `/usr/local/bin`, `/opt/homebrew/bin`, ni la ruta al `.venv`. El usuario guarda en UserDefaults la ruta `/usr/local/bin/python3` o `~/.venv/bin/python3`; al ejecutar `Process()`, el ejecutable existe, pero los módulos del venv fallan con `ModuleNotFoundError` porque `PYTHONPATH` y `VIRTUAL_ENV` no están en el entorno del proceso hijo.

**Prevention:**
```swift
// NUNCA usar process.environment = nil en una app GUI
// SIEMPRE construir el entorno explícitamente:
var env = ProcessInfo.processInfo.environment
let pythonPath = UserDefaults.standard.string(forKey: "pythonExecutablePath") 
                 ?? "/usr/bin/python3"
let venvDir = URL(fileURLWithPath: pythonPath)
              .deletingLastPathComponent()  // .../bin/
              .deletingLastPathComponent()  // venv root
let sitePackages = venvDir.appendingPathComponent("lib/python3.x/site-packages")

env["VIRTUAL_ENV"] = venvDir.path
env["PYTHONPATH"] = sitePackages.path
// Añadir el bin del venv al PATH
if let existingPath = env["PATH"] {
    env["PATH"] = venvDir.appendingPathComponent("bin").path + ":" + existingPath
}
process.environment = env
```
Alternativamente: usar el propio ejecutable del venv como `executableURL` y pasar `extractor_url.py` como primer argumento — el intérprete del venv ya conoce sus `site-packages`.

**Address in:** Phase 1 (Python Bridge — primer sprint de integración)

---

### 2. Deadlock en Pipe cuando stdout y stderr se leen de forma síncrona secuencial

**Problem:**
El patrón más común en tutoriales es:
```swift
let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
```
Si el proceso escribe suficiente en `stderr` para llenar el buffer del kernel (normalmente 64 KB) mientras `stdout` todavía no ha terminado, el proceso hijo se bloquea esperando que alguien drene `stderr`. La app Swift está bloqueada en `readDataToEndOfFile()` sobre `stdout`. Deadlock silencioso: la app congela sin timeout, sin error visible. El extractor Python usa `trafilatura` y puede emitir warnings/logs por stderr.

**Prevention:**
Usar `readabilityHandler` asíncrono para ambas pipes en paralelo:
```swift
let stdoutPipe = Pipe()
let stderrPipe = Pipe()
process.standardOutput = stdoutPipe
process.standardError  = stderrPipe
process.standardInput  = FileHandle.nullDevice  // evita hang si Python lee stdin

var stdoutData = Data()
var stderrData = Data()

stdoutPipe.fileHandleForReading.readabilityHandler = { fh in
    let chunk = fh.availableData
    if chunk.isEmpty { fh.readabilityHandler = nil }  // EOF
    else { stdoutData.append(chunk) }
}
stderrPipe.fileHandleForReading.readabilityHandler = { fh in
    let chunk = fh.availableData
    if chunk.isEmpty { fh.readabilityHandler = nil }
    else { stderrData.append(chunk) }
}

process.terminationHandler = { p in
    // Limpiar handlers antes de procesar resultados
    stdoutPipe.fileHandleForReading.readabilityHandler = nil
    stderrPipe.fileHandleForReading.readabilityHandler = nil
    DispatchQueue.main.async {
        // actualizar UI con stdoutData / stderrData
    }
}
```
Referencia oficial: Apple Developer Forums thread 690310 — el equipo de Apple recomienda `DispatchIO` sobre `FileHandle` para pipes en producción.

**Address in:** Phase 1 (Python Bridge)

---

### 3. Llamar a `process.waitUntilExit()` desde `@MainActor` congela la UI

**Problem:**
`waitUntilExit()` es bloqueante. Si se llama desde un `Task {}` que hereda el actor de la vista (`@MainActor`), bloquea el hilo principal. La ventana deja de responder. En SwiftUI el problema es especialmente silencioso: no hay crash, solo UI frozen. El botón de "Extraer" parece activo pero la app no responde.

**Prevention:**
```swift
// Vista SwiftUI — @MainActor implícito
Button("Extraer") {
    Task {
        await viewModel.extract(url: urlString)
    }
}

// ViewModel
@MainActor
class ExtractorViewModel: ObservableObject {
    @Published var result: String = ""
    @Published var isLoading = false

    func extract(url: String) async {
        isLoading = true
        // Task.detached garantiza ejecución fuera del MainActor
        let output = await Task.detached(priority: .userInitiated) {
            return try? PythonBridge.run(url: url)
        }.value
        result = output ?? ""
        isLoading = false
    }
}
```
La regla: todo lo que involucre `Process().run()` + lectura de pipes va en `Task.detached` o `DispatchQueue.global`. Solo la actualización del `@Published` vuelve al MainActor.

**Address in:** Phase 1 (Python Bridge) + Phase 2 (SwiftUI Views)

---

### 4. PDF en blanco con `WKWebView.createPDF()` por llamada prematura

**Problem:**
`webView(_:didFinish:)` se dispara cuando el navegador ha parseado el DOM, pero el renderizado puede no estar completo: imágenes, fonts y layout asíncrono todavía se están calculando. Llamar a `createPDF()` en ese instante produce un PDF en blanco o con contenido parcial. Este es el pitfall más frecuente en reportes de Stack Overflow y Apple Developer Forums para WKWebView PDF export.

El problema se agrava cuando el contenido HTML del extractor incluye estilos CSS inline extensos o tablas complejas — el layout puede tardar varios frames adicionales.

**Prevention:**
Patrón recomendado: esperar un tick del run loop tras `didFinish`, o usar evaluación JavaScript para confirmar `document.readyState`:
```swift
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // Opción A: delay mínimo de 1 frame (suficiente para contenido estático)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.exportPDF(from: webView)
    }
}

// Opción B: más robusta para contenido dinámico
func waitForRenderComplete(_ webView: WKWebView) async {
    await withCheckedContinuation { cont in
        webView.evaluateJavaScript("document.readyState") { result, _ in
            // "complete" significa que todos los recursos se han cargado
            cont.resume()
        }
    }
    // Un tick adicional para el layout post-recursos
    await Task.yield()
}
```
Para este proyecto el HTML generado por el extractor es estático (sin JS externo), por lo que `asyncAfter(deadline: .now() + 0.1)` es suficiente. Documentar este número mágico con un comentario.

**Address in:** Phase 3 (PDF Export)

---

### 5. Arquitectura del venv no coincide con el binario Universal

**Problem:**
Si el desarrollador creó el `.venv` en un Mac con Apple Silicon ejecutando Rosetta, o lo creó con el Python del sistema x86_64 en un M1, el venv es `x86_64`. Cuando la app SwiftUI se construye como Universal (arm64+x86_64) y se ejecuta en arm64 nativo, el intérprete Python del venv también es x86_64. Python arrancará bajo Rosetta, pero las extensiones C compiladas para el venv (como `lxml`, `requests` con extensiones, o `trafilatura`) pueden fallar con `mach-o file is not for this architecture` si alguna dependencia tiene binarios solo arm64 incompatibles, o bien puede haber una mezcla de archivos de la misma librería con arquitecturas distintas en el mismo venv.

El síntoma más frecuente: `import lxml` falla en arm64 nativo con un `.venv` creado bajo Rosetta.

**Prevention:**
1. Verificar la arquitectura del Python del venv antes de usar:
```swift
// En PythonBridge, antes de ejecutar el extractor:
func verifyPythonArch(at pythonPath: String) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: pythonPath)
    process.arguments = ["-c", "import platform; print(platform.machine())"]
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    process.waitUntilExit()
    let arch = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
               .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return !arch.isEmpty  // "arm64" o "x86_64"
}
```
2. Documentar en la pantalla de preferencias que el venv debe crearse con el Python nativo del Mac donde se ejecutará la app.
3. Para builds de CI: crear el venv con `python3 -m venv` usando el Python de Homebrew arm64 (`/opt/homebrew/bin/python3`).
4. `lipo -archs /path/to/binary` para verificar arquitectura del Python ejecutable.

**Address in:** Phase 1 (Python Bridge) — documentar en README + validación en la pantalla de preferencias

---

## Important Pitfalls (provocan problemas de calidad si se ignoran)

### 6. App Sandbox NO está activo por defecto, pero Hardened Runtime SÍ

**Problem:**
App Sandbox es opcional si no se distribuye por App Store. Sin embargo, Hardened Runtime se activa automáticamente al firmar con un Developer ID certificate (necesario incluso para distribución directa). Hardened Runtime bloquea:
- `DYLD_INSERT_LIBRARIES` y otras variables `DYLD_*` del entorno del proceso hijo
- Carga de librerías sin firma (relevante si las extensiones C del venv no están firmadas)

Para este proyecto (herramienta personal, sin notarización inicial) se puede desactivar Hardened Runtime en Xcode: `Signing & Capabilities → Hardened Runtime → desmarcar`. Pero si en algún momento se activa Hardened Runtime (requerido para notarización), añadir el entitlement:
```xml
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```
`com.apple.security.app-sandbox` debe estar a `false` explícitamente en el `.entitlements` del target.

**Prevention:**
Verificar en Xcode → target → Build Settings → `CODE_SIGN_ENTITLEMENTS`. Asegurarse de que el archivo `.entitlements` NO contiene `com.apple.security.app-sandbox = true` a menos que sea intencional. Añadir un test de smoke en la CI que verifique que `Process()` puede ejecutar Python.

**Address in:** Phase 1 (setup del proyecto Xcode)

---

### 7. `terminationHandler` se llama en un hilo arbitrario, no en el MainActor

**Problem:**
El closure de `process.terminationHandler` se ejecuta en un hilo interno de `Process`, no en el main thread. Actualizar propiedades `@Published` o vistas SwiftUI directamente desde ese closure provoca warnings de concurrencia en Swift 6 y crashes en versiones anteriores.

```swift
// ❌ Incorrecto
process.terminationHandler = { p in
    self.result = String(data: stdoutData, encoding: .utf8) ?? ""  // ← crash potencial
}

// ✅ Correcto
process.terminationHandler = { [weak self] p in
    DispatchQueue.main.async {
        self?.result = String(data: stdoutData, encoding: .utf8) ?? ""
    }
}
```

**Prevention:**
Usar siempre `DispatchQueue.main.async` dentro de `terminationHandler`, o estructurar el bridge con `withCheckedContinuation` que resuelve en un contexto async que luego se consume desde el MainActor.

**Address in:** Phase 1 (Python Bridge)

---

### 8. `currentDirectoryURL` de Process() apunta al bundle, no al directorio del script

**Problem:**
Si el extractor Python hace `open("output.txt", "w")` o referencias relativas a archivos, el working directory del proceso hijo es por defecto el directorio del bundle de la app (`.app/Contents/MacOS/`), no el directorio donde vive `extractor_url.py`. Esto puede romper imports relativos o escritura de archivos temporales.

**Prevention:**
```swift
let scriptURL = URL(fileURLWithPath: scriptPath)
process.currentDirectoryURL = scriptURL.deletingLastPathComponent()
```
El extractor actual no hace escrituras relativas (usa `--output` explícito o stdout), pero documentarlo como regla para el bridge.

**Address in:** Phase 1 (Python Bridge)

---

### 9. NSSavePanel + exportación asíncrona: el panel puede cerrarse antes de que termine la escritura

**Problem:**
`NSSavePanel.beginSheetModal` es asíncrono. Si el usuario confirma el panel y la app inmediatamente lanza la generación del PDF (que también es asíncrona), puede darse una condición de carrera donde el panel ya está cerrado pero el archivo todavía no se ha escrito. Además, si se reutiliza la URL del panel después de que el panel se haya destruido, la URL puede invalidarse en ciertos contextos de sandbox (aunque este proyecto no use sandbox).

**Prevention:**
Capturar la URL del panel en el closure de respuesta y no almacenarla en propiedades de instancia que puedan ser sobrescritas:
```swift
savePanel.beginSheetModal(for: window) { [weak self] response in
    guard response == .OK, let url = savePanel.url else { return }
    // url capturada en el closure — segura hasta que el closure termine
    Task {
        await self?.writePDF(to: url)
    }
}
```

**Address in:** Phase 3 (Export)

---

### 10. `WKWebView.createPDF()` vs `printOperation(with:)` — diferencias reales

**Problem:**
`createPDF()` (disponible desde macOS 11.0) produce un PDF vectorial con el contenido del WebView tal como está renderizado — sin diálogo de impresión, controlado programáticamente. Es la opción correcta para exportación silenciosa.

`printOperation(with: NSPrintInfo)` muestra el panel de impresión del sistema (o puede suprimirse con `showsPrintPanel = false`), y permite guardar a PDF usando `NSPrintInfo.outputType = .pdf`. Esta ruta tiene más opciones de paginación pero es más compleja de controlar.

Para este proyecto: usar `createPDF()` para exportación directa a archivo. Usar `printOperation` solo si se necesita un diálogo de impresión explícito. No mezclar ambas rutas en el mismo flujo.

`createPDF` está disponible en macOS 11.0+. El target es macOS 13+, así que no hay problema de disponibilidad.

**Prevention:**
Decidir una sola ruta en Phase 3 y documentarla. No implementar ambas.

**Address in:** Phase 3 (PDF Export) — decisión de arquitectura temprana

---

### 11. Task cancellation no detiene el Process() en curso

**Problem:**
Si el usuario cancela la extracción (botón "Cancelar" en la UI), hacer `task.cancel()` en Swift cancela el Task pero NO mata el proceso Python subyacente. El proceso continúa ejecutándose en background, consumiendo recursos, y si termina después de la cancelación puede intentar escribir en propiedades del ViewModel ya liberadas.

**Prevention:**
```swift
class PythonBridge {
    private var currentProcess: Process?

    func cancel() {
        currentProcess?.terminate()
        currentProcess = nil
    }

    func run(url: String) async throws -> String {
        let process = Process()
        currentProcess = process
        defer { currentProcess = nil }
        // ... configurar y lanzar ...
        // En el terminationHandler comprobar si fue cancelado:
        guard process.terminationReason == .exit else { throw BridgeError.cancelled }
    }
}
```
Añadir botón "Cancelar" en la UI que llame a `bridge.cancel()` y actualice el estado de la vista.

**Address in:** Phase 2 (SwiftUI Views + estado de carga)

---

## Minor Pitfalls (bueno saberlo)

### 12. `UserDefaults` para rutas de Python — validar al arranque

Si la ruta guardada en `UserDefaults` ya no existe (el usuario borró el venv, actualizó Python), la app intentará lanzar un ejecutable inexistente y `Process.run()` lanzará una excepción. Validar la ruta al arrancar la app y mostrar la pantalla de preferencias si no es válida. Usar `FileManager.default.fileExists(atPath:)` antes de cada extracción.

**Address in:** Phase 1 (preferencias)

---

### 13. `ONLY_ACTIVE_ARCH` en Debug impide verificar Universal

Xcode tiene `ONLY_ACTIVE_ARCH = YES` en Debug por defecto — compila solo para la arquitectura activa (arm64 en M1/M2). El fat binary solo se produce en Release. No asumir que el binario de desarrollo es Universal; verificar con `lipo -archs` solo sobre builds de Release o Archive.

**Address in:** Phase 4 (Universal Binary build)

---

### 14. Versiones mínimas de API para PDF export

`WKWebView.createPDF(configuration:completionHandler:)` — disponible desde macOS 11.0 (Big Sur). El target del proyecto es macOS 13+, por lo que no se necesitan guards de disponibilidad. Sin embargo, si en el futuro se baja el target a macOS 12 o inferior, el método requiere `@available(macOS 11.0, *)`.

`NSPrintOperation` con `WKWebView.printOperation(with:)` — disponible desde macOS 10.12.

**Address in:** Phase 3 (no acción requerida con target macOS 13+, solo documentar)

---

### 15. HTML autocontenido — rutas relativas rotas en WKWebView

Al exportar HTML autocontenido, si el cuerpo HTML generado por el extractor Python incluye URLs relativas (`src="images/foo.png"`), `WKWebView.loadHTMLString(_:baseURL:)` necesita un `baseURL` válido para resolverlas. Sin `baseURL`, imágenes y recursos relativos no cargarán en el preview. Para HTML autocontenido esto no es problema (todo inline), pero si el flujo usa `loadHTMLString` para el preview previo a PDF, pasar `baseURL: URL(string: "about:blank")` o la URL original del artículo.

**Address in:** Phase 2 (Preview) + Phase 3 (HTML export)

---

### 16. Firma ad-hoc vs Developer ID — impacto en `Process()`

Una app firmada ad-hoc (`codesign -s -`) puede lanzar subprocesos sin restricciones. Una app firmada con Developer ID activa Hardened Runtime por defecto. Si el proyecto empieza sin firma (desarrollo local) y después se firma para distribución, revisar que el entitlement `com.apple.security.app-sandbox` NO se añade automáticamente — Xcode a veces lo sugiere al añadir una firma.

**Address in:** Phase 4 (distribución / packaging)

---

## Resumen por fase

| Fase | Pitfalls críticos a resolver antes de continuar |
|------|------------------------------------------------|
| Phase 1: Python Bridge | #1 PATH/PYTHONPATH, #2 Pipe deadlock, #3 MainActor blocking, #5 arch venv, #6 Sandbox/Entitlements, #7 terminationHandler thread, #8 currentDirectoryURL |
| Phase 2: SwiftUI Views | #3 (UI freeze), #11 Task cancellation + Process.terminate(), #15 WKWebView baseURL |
| Phase 3: Export PDF/HTML/MD | #4 Blank PDF timing, #9 NSSavePanel race, #10 createPDF vs printOperation |
| Phase 4: Universal Binary | #5 (validación final), #13 ONLY_ACTIVE_ARCH, #16 firma y entitlements |

---

## Fuentes

- Apple Developer Forums thread 690310 — Process/NSTask pipe handling with DispatchIO (MEDIUM confidence — contenido verificado)
- Apple Developer Documentation: Foundation.Process, Pipe, WKWebView (MEDIUM confidence — acceso parcial a contenido)
- Apple Developer Documentation: WKNavigationDelegate.didFinish (MEDIUM confidence)
- Apple Developer Documentation: App Sandbox, Hardened Runtime (MEDIUM confidence — acceso parcial)
- Swift Concurrency documentation — MainActor, Task, withCheckedContinuation (HIGH confidence)
- Patrones de `readabilityHandler` / `terminationHandler` — múltiples fuentes Apple y Swift Forums (MEDIUM confidence)
