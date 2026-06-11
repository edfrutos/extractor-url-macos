import Foundation

struct ExtractionResult: Codable {
    let status: String
    let url: String
    let selector: String?
    let outputType: String?
    let charCount: Int?
    let content: String?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }
}
