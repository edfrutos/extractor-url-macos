import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var vm = BridgeTestViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Python Bridge — Verificación")
                .font(.title2)

            Text("Configura las rutas en Preferencias (⌘,) antes de probar.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button("Test Bridge (example.com)") {
                vm.testBridge()
            }
            .disabled(vm.isRunning)

            if vm.isRunning {
                ProgressView("Extrayendo…")
            }

            if !vm.resultText.isEmpty {
                ScrollView {
                    Text(vm.resultText)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                }
                .frame(maxHeight: 300)
            }

            if !vm.errorText.isEmpty {
                Text("Error: \(vm.errorText)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 350)
    }
}

final class BridgeTestViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var resultText: String = ""
    @Published var errorText: String = ""

    private let bridge = PythonBridge()

    func testBridge() {
        isRunning = true
        resultText = ""
        errorText = ""

        Task.detached(priority: .userInitiated) { [weak self] in
            do {
                let result = try await self?.bridge.testRun()
                await MainActor.run {
                    self?.resultText = result?.content?.prefix(500).description ?? "Sin contenido"
                    self?.isRunning = false
                }
            } catch {
                await MainActor.run {
                    self?.errorText = error.localizedDescription
                    self?.isRunning = false
                }
            }
        }
    }
}
