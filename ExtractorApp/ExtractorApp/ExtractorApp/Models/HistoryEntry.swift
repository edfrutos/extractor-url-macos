import Foundation

struct HistoryEntry: Codable, Identifiable {
    let timestamp: String
    let url: String
    let outputType: String?
    let selector: String?
    let status: String
    let charCount: Int?
    let title: String?
    let errorMessage: String?

    var id: String { timestamp + url }

    enum CodingKeys: String, CodingKey {
        case timestamp, url, selector, status, title
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }

    /// Lee ~/.cache/extractor-url/history.jsonl (escrito por core.py) y
    /// devuelve las entradas más recientes primero. Líneas JSON corruptas
    /// se ignoran sin romper la carga de las demás — misma tolerancia que
    /// core.load_history() en Python.
    static func loadAll(limit: Int? = nil) -> [HistoryEntry] {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".cache/extractor-url/history.jsonl")
        guard let text = try? String(contentsOf: path, encoding: .utf8) else { return [] }

        let decoder = JSONDecoder()
        var entries: [HistoryEntry] = []
        for line in text.split(separator: "\n") {
            guard let data = line.data(using: .utf8),
                  let entry = try? decoder.decode(HistoryEntry.self, from: data)
            else { continue }
            entries.append(entry)
        }
        entries.reverse()
        if let limit { return Array(entries.prefix(limit)) }
        return entries
    }
}
