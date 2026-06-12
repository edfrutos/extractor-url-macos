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

    // MARK: - Phase 6 Plan 03: exportPDF sin webView (no-op)

    func testExportPDFWithoutWebViewIsNoop() async throws {
        // webViewProvider es nil (no hay WebPreviewView activo en tests)
        // → export("pdf") debe terminar sin crash y conservar resultContent
        let vm = ExtractionViewModel()
        vm.resultContent = "contenido"
        vm.exportFormat = "pdf"
        await vm.export()
        XCTAssertEqual(vm.resultContent, "contenido")
    }

    // MARK: - Phase 6: Tests de suggestedFilename (D-06/D-07)

    func testSuggestedFilenameWithTitle() async throws {
        let vm = ExtractionViewModel()
        vm.pageTitle = "Mi Artículo de Prueba"
        let result = vm.suggestedFilename(title: vm.pageTitle, extension: "pdf")
        // El título saneado debe aparecer en el nombre (no "export")
        XCTAssertTrue(result.hasSuffix(".pdf"), "debe terminar en .pdf")
        XCTAssertNotEqual(result, "export.pdf", "no debe usar el fallback 'export'")
        XCTAssertFalse(result.contains(" "), "el nombre no debe contener espacios")
    }

    func testSuggestedFilenameFallbackToContent() async throws {
        let vm = ExtractionViewModel()
        vm.pageTitle = nil
        vm.resultContent = "Contenido sin titulo"
        let result = vm.suggestedFilename(title: nil, extension: "md")
        // Sin title → usa prefijo del contenido, no "export"
        XCTAssertTrue(result.hasSuffix(".md"), "debe terminar en .md")
        XCTAssertNotEqual(result, "export.md", "no debe usar el fallback 'export' si hay contenido")
    }

    func testSuggestedFilenameFallbackToExport() async throws {
        let vm = ExtractionViewModel()
        vm.pageTitle = nil
        vm.resultContent = nil
        let result = vm.suggestedFilename(title: nil, extension: "txt")
        // Sin title ni contenido → "export.<ext>"
        XCTAssertEqual(result, "export.txt")
    }
}
