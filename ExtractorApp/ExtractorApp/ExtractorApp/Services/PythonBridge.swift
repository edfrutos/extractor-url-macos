import Foundation
import SwiftUI

final class PythonBridge {
    @AppStorage("pythonPath") var pythonPath: String = ""
    @AppStorage("scriptPath") var scriptPath: String = ""

    func run(
        url: String,
        outputType: String,
        selector: String? = nil,
        timeout: Int = 15
    ) async throws -> ExtractionResult {
        guard !pythonPath.isEmpty, FileManager.default.isExecutableFile(atPath: pythonPath) else {
            throw ExtractionError.pythonNotFound(path: pythonPath)
        }
        guard !scriptPath.isEmpty, FileManager.default.fileExists(atPath: scriptPath) else {
            throw ExtractionError.pythonNotFound(path: scriptPath)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)

        var arguments = [scriptPath, url, "--type", outputType, "--json"]
        if let sel = selector {
            arguments += ["--selector", sel]
        }
        arguments += ["--timeout", "\(timeout)"]
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let scriptDir = URL(fileURLWithPath: scriptPath).deletingLastPathComponent().path
        let venvBin = scriptDir + "/.venv/bin"
        var env = ProcessInfo.processInfo.environment
        env["VIRTUAL_ENV"] = scriptDir + "/.venv"
        env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
        process.environment = env
        process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)

        do {
            try process.run()
        } catch {
            throw ExtractionError.processLaunchFailed(underlying: error)
        }

        async let outData: Data = Task.detached { stdoutPipe.fileHandleForReading.readDataToEndOfFile() }.value
        async let errData: Data = Task.detached { stderrPipe.fileHandleForReading.readDataToEndOfFile() }.value
        let (stdout, _) = try await (outData, errData)
        process.waitUntilExit()

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
            throw ExtractionError.extractionFailed(message: result.errorMessage ?? "Error desconocido")
        }
        return result
    }

    func testRun() async throws -> ExtractionResult {
        try await run(url: "https://example.com", outputType: "text", selector: nil, timeout: 10)
    }
}
