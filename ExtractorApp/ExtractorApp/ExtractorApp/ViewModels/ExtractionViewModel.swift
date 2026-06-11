import Combine
import Foundation
import SwiftUI

@MainActor
final class ExtractionViewModel: ObservableObject {

    // MARK: - Inputs (D-06)
    @Published var urlString: String = ""
    @Published var outputType: String = "text"   // "text" | "html" | "markdown"
    @Published var selectorCSS: String = ""
    @Published var timeout: Int = 15             // D-12: valor por defecto 15

    // MARK: - Outputs (D-06)
    @Published var isExtracting: Bool = false
    @Published var resultContent: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isPythonPathError: Bool = false  // hint "Preferencias" en la View

    // MARK: - Private
    private let bridge = PythonBridge()

    // MARK: - Actions

    /// Lanza la extracción. No relanza si ya hay una en curso (D-07).
    func extract() {
        guard !isExtracting, !urlString.isEmpty else { return }

        // D-09: limpiar estado anterior antes de lanzar
        errorMessage = nil
        resultContent = nil
        isPythonPathError = false
        isExtracting = true

        let url = urlString
        let type = outputType
        let selector: String? = selectorCSS.trimmingCharacters(in: .whitespaces).isEmpty
            ? nil
            : selectorCSS.trimmingCharacters(in: .whitespaces)
        let timeoutValue = timeout > 0 ? timeout : 15  // D-12: fallback a 15

        Task.detached(priority: .userInitiated) { [weak self] in
            do {
                let result = try await self?.bridge.run(
                    url: url,
                    outputType: type,
                    selector: selector,
                    timeout: timeoutValue
                )
                await MainActor.run {
                    self?.resultContent = result?.content
                    self?.isExtracting = false
                }
            } catch {
                await MainActor.run {
                    self?.handleError(error)
                    self?.isExtracting = false
                }
            }
        }
    }

    // MARK: - Error formatting

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        if let e = error as? ExtractionError, case .pythonNotFound = e {
            isPythonPathError = true
        }
    }
}
