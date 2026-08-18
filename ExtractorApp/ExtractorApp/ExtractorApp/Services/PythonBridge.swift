import Foundation
import SwiftUI

/// Puente Foundation.Process() que ejecuta el CLI Python de forma asíncrona.
///
/// - Captura stdout/stderr con readabilityHandler en background DispatchQueue
///   para evitar deadlock con buffers grandes (trafilatura produce mucho texto).
/// - Timeout Swift real: si el proceso no termina en `timeout + 5` segundos,
///   se mata y se lanza ExtractionError.timeout.
/// - Task.detached en el call-site (ExtractionViewModel) garantiza que
///   el MainActor no se bloquea en ningún momento.
final class PythonBridge {
    @AppStorage("pythonPath") var pythonPath: String = ""
    @AppStorage("scriptPath") var scriptPath: String = ""

    enum PathSource: Equatable { case bundle, userDefaults }

    // MARK: - Run

    /// Lanza el CLI Python con --json y devuelve el resultado decodificado.
    ///
    /// - Parameters:
    ///   - url:       URL a extraer.
    ///   - outputType: "text" | "html" | "markdown".
    ///   - selector:  Selector CSS opcional.
    ///   - timeout:   Segundos máximos de espera para el script Python (por defecto 15).
    ///               Swift añade 5 s de margen antes de forzar terminación.
    /// - Throws: `ExtractionError` tipado.
    /// - Returns: `ExtractionResult` con los datos extraídos.
    func run(
        url: String,
        outputType: String,
        selector: String? = nil,
        timeout: Int = 15
    ) async throws -> ExtractionResult {

        // -- Resolución de rutas (UserDefaults-first / bundle fallback) ----
        guard let paths = resolvedPaths() else {
            throw ExtractionError.pythonNotFound(path: "(bundle no compilado)")
        }
        let pythonExec = paths.python
        let scriptFile = paths.script

        // -- Configurar proceso -------------------------------------------
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonExec)

        var arguments = [scriptFile, url, "--type", outputType, "--json"]
        if let sel = selector {
            arguments += ["--selector", sel]
        }
        // Timeout interno del script; Swift añade margen de 5 s adicionales.
        arguments += ["--timeout", "\(timeout)"]
        process.arguments = arguments

        // Entorno según origen de rutas
        var env = ProcessInfo.processInfo.environment
        switch paths.source {
        case .bundle:
            if let libPath = Self.bundledVendoredLibPath() {
                let existing = env["PYTHONPATH"] ?? ""
                env["PYTHONPATH"] = existing.isEmpty ? libPath : libPath + ":" + existing
            }
            process.currentDirectoryURL = URL(fileURLWithPath: scriptFile)
                .deletingLastPathComponent()
        case .userDefaults:
            let scriptDir = URL(fileURLWithPath: scriptFile)
                .deletingLastPathComponent().path
            let venvBin = scriptDir + "/.venv/bin"
            env["VIRTUAL_ENV"] = scriptDir + "/.venv"
            env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
            process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)
        }
        process.environment = env

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // -- Lanzar proceso -----------------------------------------------
        do {
            try process.run()
        } catch {
            throw ExtractionError.processLaunchFailed(underlying: error)
        }

        // -- Captura async con readabilityHandler -------------------------
        // readabilityHandler en background DispatchQueue evita el deadlock
        // que ocurre cuando stdout y stderr se llenan simultáneamente
        // (buffers grandes de trafilatura). readDataToEndOfFile() bloquea
        // el hilo; readabilityHandler acumula datos sin bloquear.
        //
        // Se usa una clase auxiliar (IOCollector) para mutar estado desde
        // múltiples closures sin warnings de captura de var concurrente.
        let collector = IOCollector()

        let (stdout, _) = try await withCheckedThrowingContinuation {
            (cont: CheckedContinuation<(Data, Data), Error>) in

            let queue = DispatchQueue(
                label: "com.extractor.pythonbridge.io",
                qos: .userInitiated
            )

            // Timeout de seguridad Swift: termina el proceso si excede límite.
            queue.asyncAfter(deadline: .now() + .seconds(timeout + 5)) {
                guard process.isRunning else { return }
                process.terminate()
                if collector.tryFinish() {
                    stdoutPipe.fileHandleForReading.readabilityHandler = nil
                    stderrPipe.fileHandleForReading.readabilityHandler = nil
                    cont.resume(throwing: ExtractionError.timeout)
                }
            }

            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                let chunk = handle.availableData
                if chunk.isEmpty {
                    // EOF — proceso cerró stdout; señal de finalización normal.
                    if collector.tryFinish() {
                        stdoutPipe.fileHandleForReading.readabilityHandler = nil
                        stderrPipe.fileHandleForReading.readabilityHandler = nil
                        cont.resume(returning: collector.result())
                    }
                } else {
                    collector.appendOut(chunk)
                }
            }

            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                let chunk = handle.availableData
                guard !chunk.isEmpty else { return }
                collector.appendErr(chunk)
            }
        }

        process.waitUntilExit()

        // -- Decodificación JSON ------------------------------------------
        if stdout.isEmpty {
            throw ExtractionError.emptyOutput
        }

        let result: ExtractionResult
        do {
            result = try JSONDecoder().decode(ExtractionResult.self, from: stdout)
        } catch {
            throw ExtractionError.jsonDecodeFailed(underlying: error)
        }

        guard result.isSuccess else {
            throw ExtractionError.extractionFailed(
                message: result.errorMessage ?? "Error desconocido"
            )
        }

        return result
    }

    // MARK: - Convenience

    /// Extracción de prueba rápida contra example.com (útil en SettingsView).
    func testRun() async throws -> ExtractionResult {
        try await run(
            url: "https://example.com",
            outputType: "text",
            selector: nil,
            timeout: 10
        )
    }
}

// MARK: - Path Resolution (Fase 9: UserDefaults-first / bundle fallback)

extension PythonBridge {

    // Lee UserDefaults directamente (no self.pythonPath) para evitar dependencia
    // de @MainActor en el contexto async de run() (Pitfall 3 RESEARCH fase 9).
    internal func resolvedPaths() -> (python: String, script: String, source: PathSource)? {
        let udPython = UserDefaults.standard.string(forKey: "pythonPath") ?? ""
        let udScript = UserDefaults.standard.string(forKey: "scriptPath") ?? ""
        if !udPython.isEmpty,
           !udScript.isEmpty,
           FileManager.default.isExecutableFile(atPath: udPython),
           FileManager.default.fileExists(atPath: udScript) {
            return (python: udPython, script: udScript, source: .userDefaults)
        }
        guard let bundlePython = Self.bundledPythonPath(),
              let bundleScript = Self.bundledScriptPath() else { return nil }
        return (python: bundlePython, script: bundleScript, source: .bundle)
    }
}

// MARK: - Bundle Paths (Fase 8: rutas del intérprete embebido)

extension PythonBridge {

    /// Ruta al intérprete Python universal embebido en el bundle.
    /// Devuelve nil si el binario no existe o no es ejecutable
    /// (p.ej. en un build de desarrollo antes de ejecutar bundle-python.sh).
    static func bundledPythonPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let path = resourcePath + "/python/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: path) else { return nil }
        return path
    }

    /// Ruta al script principal extractor_url.py en el bundle.
    /// Devuelve nil si el archivo no existe.
    static func bundledScriptPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let path = resourcePath + "/scripts/extractor_url.py"
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }

    /// Ruta a las deps Python vendorizadas (python-packages/).
    /// Siempre devuelve la ruta construida; no valida existencia
    /// porque el directorio se crea en build time.
    static func bundledVendoredLibPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        return resourcePath + "/python/lib/python-packages"
    }

    /// Ejecuta `--version` contra el intérprete bundleado y devuelve el número
    /// de versión (p.ej. "3.13.14"). Bloqueante — llamar desde un contexto
    /// en background (ver SettingsViewModel.refreshOperatingMode()).
    /// Devuelve nil si el bundle no está disponible o el proceso falla.
    static func bundledPythonVersion() -> String? {
        guard let path = bundledPythonPath() else { return nil }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = ["--version"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            return nil
        }
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !output.isEmpty
        else { return nil }

        guard output.hasPrefix("Python ") else { return output }
        return String(output.dropFirst("Python ".count))
    }
}

// MARK: - IOCollector

/// Acumula stdout/stderr desde readabilityHandlers concurrentes.
/// Usa NSLock para seguridad de hilos real; `@unchecked Sendable` porque el
/// compilador no puede verificar esa seguridad a través del NSLock, pero
/// las cuatro mutaciones de estado están protegidas por él.
private final class IOCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var outData = Data()
    private var errData = Data()
    private var done = false

    func appendOut(_ chunk: Data) {
        lock.lock()
        outData.append(chunk)
        lock.unlock()
    }

    func appendErr(_ chunk: Data) {
        lock.lock()
        errData.append(chunk)
        lock.unlock()
    }

    /// Intenta marcar como finalizado. Devuelve true solo la primera vez.
    func tryFinish() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !done else { return false }
        done = true
        return true
    }

    /// Devuelve el par (stdout, stderr) acumulado.
    func result() -> (Data, Data) {
        lock.lock()
        defer { lock.unlock() }
        return (outData, errData)
    }
}

