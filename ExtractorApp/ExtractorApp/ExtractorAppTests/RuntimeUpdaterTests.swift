import XCTest
@testable import ExtractorApp

// MARK: - RuntimeUpdaterTests (Fase 21)
//
// Cubre lo verificable sin red ni un Mac real: decodificación del
// manifiesto JSON y los mensajes de error. La descarga/verificación/
// extracción reales (RuntimeUpdater.checkAndApplyUpdate()) requieren red
// y el intérprete bundleado — quedan para el checkpoint humano (ver
// CHECKPOINT-HUMANO.md).

final class RuntimeUpdaterTests: XCTestCase {

    // MARK: - ManifestInfo decoding

    func testManifestInfo_decodesFromRealShape() throws {
        let json = """
        {
          "version": "2026-08-23",
          "download_url": "https://github.com/edfrutos/extractor-url-macos/releases/download/runtime-2026-08-23/python-packages-2026-08-23.zip",
          "sha256": "5607f5ce1959e6565bda6551010549579e86c1d4494ba6388c290db1dc154a13"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))

        let manifest = try JSONDecoder().decode(RuntimeUpdater.ManifestInfo.self, from: data)

        XCTAssertEqual(manifest.version, "2026-08-23")
        XCTAssertEqual(
            manifest.downloadUrl,
            "https://github.com/edfrutos/extractor-url-macos/releases/download/runtime-2026-08-23/python-packages-2026-08-23.zip"
        )
        XCTAssertEqual(manifest.sha256, "5607f5ce1959e6565bda6551010549579e86c1d4494ba6388c290db1dc154a13")
    }

    func testManifestInfo_missingField_failsToDecode() {
        let json = """
        { "version": "2026-08-23", "sha256": "abc" }
        """
        let data = json.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeUpdater.ManifestInfo.self, from: data))
    }

    // MARK: - UpdateError messages

    func testUpdateError_allCasesHaveNonEmptyDescription() {
        let cases: [RuntimeUpdater.UpdateError] = [
            .manifestUnavailable, .checksumMismatch, .extractionFailed, .verificationImportFailed,
        ]
        for error in cases {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - No override activo por defecto

    func testActiveVersion_nilByDefault_whenNoOverridePresent() {
        // Sin haber aplicado nunca una actualización en este proceso de
        // test, no debe haber una versión activa — RuntimeUpdater no debe
        // inventar un override que no existe en disco.
        UserDefaults.standard.removeObject(forKey: "runtimeOverrideActiveVersion")
        XCTAssertNil(RuntimeUpdater.activeVersion())
        XCTAssertNil(RuntimeUpdater.activeOverridePath())
    }
}
