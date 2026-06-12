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

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content, title
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }
}
