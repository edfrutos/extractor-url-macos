import Foundation

struct ExtractionResult: Codable {
    let status: String
    let url: String
    let selector: String?
    let outputType: String?
    let charCount: Int?
    let content: String?
    let errorMessage: String?
    let title: String?          // Phase 6 — null en JSON → nil en Swift
    /// Fase 26: solo con `--js-external`; ausente en el resto de llamadas.
    let jsRenderNeeded: Bool?

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content, title
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
        case jsRenderNeeded = "js_render_needed"
    }

    var isSuccess: Bool { status == "success" }
    /// La CLI pide renderizar la página con JavaScript (`WebRenderer`).
    var needsJSRender: Bool { jsRenderNeeded == true }
}
