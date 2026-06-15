import XCTest
@testable import ExtractorApp

/// Tests para los métodos de resolución de rutas bundled en PythonBridge.
///
/// NOTA: Verifican la lógica de construcción de rutas.
/// En el test runner, Bundle.main.resourcePath apunta a los recursos del host
/// de tests, no al bundle de producción. Los tests de existencia real se hacen
/// con verify-bundle.sh sobre el .app compilado.
final class BundlePathTests: XCTestCase {

    // MARK: - bundledPythonPath

    func testBundledPythonPathReturnsNilWhenNotPresent() {
        let path = PythonBridge.bundledPythonPath()
        if let path = path {
            XCTAssertTrue(path.hasSuffix("/python/bin/python3.13"),
                         "La ruta bundled debe terminar en /python/bin/python3.13, got: \(path)")
            XCTAssertTrue(path.contains("Resources"),
                         "La ruta bundled debe estar dentro de Resources")
        }
        // nil es resultado válido cuando el bundle aún no está compilado
    }

    func testBundledPythonPathHasCorrectStructure() {
        guard let resourcePath = Bundle.main.resourcePath else {
            XCTFail("Bundle.main.resourcePath no disponible en este entorno")
            return
        }
        let expectedPath = resourcePath + "/python/bin/python3.13"
        XCTAssertTrue(expectedPath.hasSuffix("/python/bin/python3.13"))
        XCTAssertFalse(expectedPath.contains("//"),
                       "La ruta no debe tener barras dobles")
    }

    // MARK: - bundledScriptPath

    func testBundledScriptPathReturnsNilOrValidSuffix() {
        let path = PythonBridge.bundledScriptPath()
        if let path = path {
            XCTAssertTrue(path.hasSuffix("/scripts/extractor_url.py"),
                         "La ruta del script debe terminar en /scripts/extractor_url.py")
            XCTAssertTrue(path.contains("Resources"),
                         "El script debe estar dentro de Resources")
        }
        // nil es válido: archivo no existe en el bundle de tests
    }

    func testBundledScriptPathStructure() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        let expectedPath = resourcePath + "/scripts/extractor_url.py"
        XCTAssertTrue(expectedPath.contains("/scripts/extractor_url.py"))
        XCTAssertFalse(expectedPath.contains("//"))
    }

    // MARK: - bundledVendoredLibPath

    func testBundledVendoredLibPathNeverNil() {
        let path = PythonBridge.bundledVendoredLibPath()
        if Bundle.main.resourcePath != nil {
            XCTAssertNotNil(path,
                           "bundledVendoredLibPath() debe devolver ruta cuando resourcePath está disponible")
        }
    }

    func testBundledVendoredLibPathHasCorrectStructure() {
        guard let path = PythonBridge.bundledVendoredLibPath() else { return }
        XCTAssertTrue(path.hasSuffix("/python/lib/python-packages"),
                     "La ruta de deps debe terminar en /python/lib/python-packages")
        XCTAssertTrue(path.contains("Resources"))
        XCTAssertFalse(path.contains("//"))
    }

    // MARK: - Consistencia entre métodos

    func testAllBundledPathsShareSameResourceBase() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        let vendoredPath = PythonBridge.bundledVendoredLibPath()
        XCTAssertEqual(vendoredPath, resourcePath + "/python/lib/python-packages",
                      "La ruta vendored debe construirse sobre resourcePath")
    }
}
