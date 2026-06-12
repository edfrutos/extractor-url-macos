import XCTest
@testable import ExtractorApp

@MainActor
final class ViewModelTests: XCTestCase {

    func testHtmlForPreviewNilWhenNoContent() async throws {
        let vm = ExtractionViewModel()
        vm.resultContent = nil
        XCTAssertNil(vm.htmlForPreview)
    }

    func testHtmlForPreviewMarkdownContainsMarked() async throws {
        let vm = ExtractionViewModel()
        vm.resultContent = "# Hola"
        vm.outputType = "markdown"
        let html = try XCTUnwrap(vm.htmlForPreview)
        XCTAssertTrue(html.contains("marked.parse"))
    }

    func testContentReadyResetOnExtract() async throws {
        let vm = ExtractionViewModel()
        vm.contentReady = true
        vm.urlString = "https://example.com"
        vm.extract()
        XCTAssertFalse(vm.contentReady)
    }

    func testGenerateHTMLNoExternalDeps() async throws {
        let vm = ExtractionViewModel()
        // No se chequea ausencia genérica de "http": la constante markedJS
        // puede contener URLs en comentarios. Solo referencias a recursos.
        for type in ["text", "html", "markdown"] {
            let html = vm.generateHTML(content: "# Hola", outputType: type)
            XCTAssertFalse(html.contains("src=\"http"), "src externo en \(type)")
            XCTAssertFalse(html.contains("<link rel"), "<link rel en \(type)")
            XCTAssertFalse(html.contains("@import url(http"), "@import en \(type)")
        }
    }

    func testGenerateHTMLDarkMode() async throws {
        let vm = ExtractionViewModel()
        for type in ["text", "html", "markdown"] {
            let html = vm.generateHTML(content: "x", outputType: type)
            XCTAssertTrue(
                html.contains("@media (prefers-color-scheme: dark)"),
                "falta dark mode en \(type)"
            )
        }
    }

    func testGenerateHTMLMarkdownContainsScript() async throws {
        let vm = ExtractionViewModel()
        let html = vm.generateHTML(content: "x", outputType: "markdown")
        XCTAssertTrue(html.contains("marked.parse"))
        XCTAssertTrue(html.contains("<script>"))
    }

    func testExportDispatchMarkdown() async throws {
        // NSSavePanel abre UI real y no es mockeable sin refactor: la
        // verificación E2E de exportMarkdown/exportHTML es manual
        // (VALIDATION.md Manual-Only). Aquí se cubre la rama no-op y el
        // valor por defecto del formato.
        let vm = ExtractionViewModel()
        XCTAssertEqual(vm.exportFormat, "markdown")

        vm.exportFormat = "pdf"
        vm.resultContent = "contenido"
        await vm.export()  // rama "pdf" es no-op: no crashea ni cambia estado
        XCTAssertEqual(vm.resultContent, "contenido")
        XCTAssertEqual(vm.exportFormat, "pdf")
    }
}
