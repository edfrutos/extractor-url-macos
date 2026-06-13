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

        // -- Validación de rutas ------------------------------------------
        guard !pythonPath.isEmpty,
              FileManager.default.isExecutableFile(atPath: pythonPath) else {
            throw ExtractionError.pythonNotFound(path: pythonPath)
        }
        guard !scriptPath.isEmpty,
              FileManager.default.fileExists(atPath: scriptPath) else {
            throw ExtractionError.pythonNotFound(path: scriptPath)
        }

        // -- Configurar proceso -------------------------------------------
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)

        var arguments = [scriptPath, url, "--type", outputType, "--json"]
        if let sel = selector {
            arguments += ["--selector", sel]
        }
        // Timeout interno del script; Swift añade margen de 5 s adicionales.
        arguments += ["--timeout", "\(timeout)"]
        process.arguments = arguments

        // Entorno con venv activado (necesario para trafilatura, markdownify, etc.)
        let scriptDir = URL(fileURLWithPath: scriptPath)
            .deletingLastPathComponent().path
        let venvBin = scriptDir + "/.venv/bin"
        var env = ProcessInfo.processInfo.environment
        env["VIRTUAL_ENV"] = scriptDir + "/.venv"
        env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
        process.environment = env
        process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)

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

        let (stdout, _stderr) = try await withCheckedThrowingContinuation {
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

// MARK: - IOCollector

/// Acumula stdout/stderr desde readabilityHandlers concurrentes.
/// Usa NSLock para seguridad de hilos sin warnings de captura de var.
private final class IOCollector {
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
