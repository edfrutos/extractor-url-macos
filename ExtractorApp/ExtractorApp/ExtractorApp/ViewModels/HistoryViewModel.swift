import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var entries: [HistoryEntry] = []

    func reload() {
        entries = HistoryEntry.loadAll()
    }
}
