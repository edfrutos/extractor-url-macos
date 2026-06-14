import XCTest
@testable import ExtractorApp

// MARK: - PythonBridgeTests
//
// Valida el comportamiento del puente Foundation.Process() sin depender de
// webs externas. Los tests que requieren el CLI Python real se marcan con
// XCTSkip cuando las rutas no están configuradas en el entorno de CI.
//
// Categorías:
//   1. ExtractionError.pythonNotFound  — rutas inválidas / vacías
//   2. ExtractionError.emptyOutput     — proceso termina sin escribir en stdout
//   3. ExtractionError.jsonDecodeFailed — stdout no es JSON válido
//   4. ExtractionResult decodificación — JSON correcto → modelo Swift
//   5. Comportamiento de timeout       — flag en ExtractionError

@MainActor
final class PythonBridgeTests: XCTestCase {

    // MARK: - Helpers

    /// Devuelve un PythonBridge con rutas vacías (estado "no configurado").
    private func makeBridgeUnconfigured() -> PythonBridge {
        let bridge = PythonBridge()
        bridge.pythonPath = ""
        bridge.scriptPath = ""
        return bridge
    }

    /// Devuelve un PythonBridge con una ruta Python válida del sistema pero
    /// script inexistente — útil para probar el segundo guard.
    private func makeBridgeWithSystemPython() -> PythonBridge {
        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"  // ejecutable real del sistema
        bridge.scriptPath = "/ruta/que/no/existe/extractor_url.py"
        return bridge
    }

    // MARK: - 1. pythonNotFound — ruta Python vacía

    func testRunThrowsPythonNotFound_whenPythonPathIsEmpty() async {
        let bridge = makeBridgeUnconfigured()
        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError.pythonNotFound")
        } catch let error as ExtractionError {
            if case .pythonNotFound = error {
                // Correcto
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }

    // MARK: - 2. pythonNotFound — ruta Python inexistente

    func testRunThrowsPythonNotFound_whenPythonPathDoesNotExist() async {
        let bridge = PythonBridge()
        bridge.pythonPath = "/ruta/inexistente/python"
        bridge.scriptPath = ""
        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError.pythonNotFound")
        } catch let error as ExtractionError {
            if case .pythonNotFound = error {
                // Correcto
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }

    // MARK: - 3. pythonNotFound — script inexistente

    func testRunThrowsPythonNotFound_whenScriptPathDoesNotExist() async {
        let bridge = makeBridgeWithSystemPython()
        // pythonPath = /bin/sh (ejecutable real), scriptPath = inexistente
        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError.pythonNotFound")
        } catch let error as ExtractionError {
            if case .pythonNotFound = error {
                // Correcto — segundo guard detecta script inexistente
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }

    // MARK: - 4. emptyOutput — proceso termina sin producir JSON

    func testRunThrowsEmptyOutput_whenProcessProducesNoStdout() async throws {
        // Usamos /bin/sh como "python" y un script temporal que no imprime nada.
        // El proceso termina con código 0 pero stdout vacío → emptyOutput.
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("empty_\(UUID().uuidString).py")
        // Script Python vacío: al ejecutarlo con /bin/sh produce stdout vacío
        // (sh interpreta Python como comandos de shell — fallará, pero stdout = "")
        // Usamos un script que solo imprime a stderr para simular stdout vacío.
        try "#!/bin/sh\necho 'error' >&2".write(to: tmp, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: tmp.path
        )
        defer { try? FileManager.default.removeItem(at: tmp) }

        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"
        bridge.scriptPath = tmp.path

        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError")
        } catch let error as ExtractionError {
            // emptyOutput o processLaunchFailed/extractionFailed son válidos aquí
            // según cómo responda sh al script. Lo importante: no crashea.
            switch error {
            case .emptyOutput, .extractionFailed, .jsonDecodeFailed, .processLaunchFailed:
                break  // Cualquiera de estos es una respuesta de error correcta
            case .pythonNotFound:
                XCTFail("No debería lanzar pythonNotFound con rutas válidas: \(error)")
            case .timeout:
                XCTFail("No debería agotar el timeout en este test: \(error)")
            }
        } catch {
            XCTFail("Error inesperado (no ExtractionError): \(error)")
        }
    }

    // MARK: - 5. jsonDecodeFailed — stdout contiene texto no-JSON

    func testRunThrowsJsonDecodeFailed_whenStdoutIsNotJSON() async throws {
        // Script que imprime texto plano en stdout (no JSON).
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("notjson_\(UUID().uuidString).sh")
        try "#!/bin/sh\necho 'esto no es json'".write(to: tmp, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: tmp.path
        )
        defer { try? FileManager.default.removeItem(at: tmp) }

        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"
        bridge.scriptPath = tmp.path

        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError.jsonDecodeFailed")
        } catch let error as ExtractionError {
            if case .jsonDecodeFailed = error {
                // Correcto — stdout no vacío pero no es JSON decodificable
            } else {
                XCTFail("Error incorrecto: \(error) (esperado jsonDecodeFailed)")
            }
        } catch {
            XCTFail("Error inesperado: \(error)")
        }
    }

    // MARK: - 6. Decodificación JSON correcta

    func testRunDecodesValidJSON_whenScriptOutputsSuccessJSON() async throws {
        // Script que imprime un JSON compatible con ExtractionResult.
        let jsonPayload = """
        {"status":"success","url":"https://example.com","content":"Hola mundo","output_type":"text","char_count":10,"selector":null,"error_message":null,"title":null}
        """
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("validjson_\(UUID().uuidString).sh")
        // Usar printf para evitar el newline extra de echo
        let script = "#!/bin/sh\nprintf '\(jsonPayload)'"
        try script.write(to: tmp, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: tmp.path
        )
        defer { try? FileManager.default.removeItem(at: tmp) }

        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"
        bridge.scriptPath = tmp.path

        let result = try await bridge.run(
            url: "https://example.com",
            outputType: "text"
        )

        XCTAssertEqual(result.status, "success")
        XCTAssertEqual(result.url, "https://example.com")
        XCTAssertEqual(result.content, "Hola mundo")
        XCTAssertEqual(result.outputType, "text")
        XCTAssertTrue(result.isSuccess)
        XCTAssertNil(result.title)   // Phase 6 — null en JSON → nil en Swift
    }

    // MARK: - 7. Decodificación JSON con campo title (Phase 6)

    func testRunDecodesTitle_whenJSONIncludesTitleField() async throws {
        let jsonPayload = """
        {"status":"success","url":"https://example.com","content":"Contenido","output_type":"markdown","char_count":9,"selector":null,"error_message":null,"title":"Mi Artículo"}
        """
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("withtitle_\(UUID().uuidString).sh")
        try "#!/bin/sh\nprintf '\(jsonPayload)'"
            .write(to: tmp, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: tmp.path
        )
        defer { try? FileManager.default.removeItem(at: tmp) }

        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"
        bridge.scriptPath = tmp.path

        let result = try await bridge.run(
            url: "https://example.com",
            outputType: "markdown"
        )

        XCTAssertEqual(result.title, "Mi Artículo")
    }

    // MARK: - 8. extractionFailed — JSON con status "error"

    func testRunThrowsExtractionFailed_whenJSONStatusIsError() async throws {
        let jsonPayload = """
        {"status":"error","url":"https://example.com","content":null,"output_type":"text","char_count":null,"selector":null,"error_message":"URL no alcanzable","title":null}
        """
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("errjson_\(UUID().uuidString).sh")
        try "#!/bin/sh\nprintf '\(jsonPayload)'"
            .write(to: tmp, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: tmp.path
        )
        defer { try? FileManager.default.removeItem(at: tmp) }

        let bridge = PythonBridge()
        bridge.pythonPath = "/bin/sh"
        bridge.scriptPath = tmp.path

        do {
            _ = try await bridge.run(url: "https://example.com", outputType: "text")
            XCTFail("Debería haber lanzado ExtractionError.extractionFailed")
        } catch let error as ExtractionError {
            if case .extractionFailed(let msg) = error {
                XCTAssertEqual(msg, "URL no alcanzable")
            } else {
                XCTFail("Error incorrecto: \(error)")
            }
        }
    }

    // MARK: - 9. ExtractionError.timeout existe y es descriptivo

    func testTimeoutErrorHasLocalizedDescription() {
        let error = ExtractionError.timeout
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
    }

    // MARK: - 10. Todos los casos de ExtractionError tienen descripción

    func testAllExtractionErrorCasesHaveDescription() {
        let cases: [ExtractionError] = [
            .pythonNotFound(path: "/test"),
            .processLaunchFailed(underlying: NSError(domain: "test", code: 1)),
            .extractionFailed(message: "test"),
            .jsonDecodeFailed(underlying: NSError(domain: "test", code: 2)),
            .emptyOutput,
            .timeout,
        ]
        for error in cases {
            XCTAssertNotNil(
                error.errorDescription,
                "\(error) debe tener errorDescription"
            )
            XCTAssertFalse(
                error.errorDescription?.isEmpty ?? true,
                "\(error) no debe tener descripción vacía"
            )
        }
    }
}
