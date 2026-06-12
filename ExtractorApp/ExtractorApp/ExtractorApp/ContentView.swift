import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ExtractionViewModel()  // D-04, D-05
    @State private var isExpanded: Bool = false          // D-13: colapsado por defecto

    var body: some View {
        VStack(spacing: 16) {  // D-01: VStack lineal

            // ── Campo URL ──────────────────────────────────────────────
            TextField("https://example.com", text: $vm.urlString)  // UI-SPEC placeholder
                .onSubmit { vm.extract() }
                .disabled(vm.isExtracting)

            Divider()  // entre URL y fila Picker+Botón

            // ── Fila Picker de tipo + Botón Extraer ────────────────────
            HStack(spacing: 8) {
                Picker("Tipo", selection: $vm.outputType) {
                    Text("Texto").tag("text")         // UI-SPEC: "Texto"
                    Text("HTML").tag("html")          // UI-SPEC: "HTML"
                    Text("Markdown").tag("markdown")  // UI-SPEC: "Markdown"
                }
                .pickerStyle(.segmented)              // Claude's Discretion: segmented
                .disabled(vm.isExtracting)

                Button {
                    vm.extract()
                } label: {
                    Label("Extraer", systemImage: "arrow.down.circle")  // UI-SPEC exacto
                }
                .buttonStyle(.borderedProminent)                          // UI-SPEC: acento exclusivo
                .accessibilityLabel("Extraer contenido de la URL")       // UI-SPEC exacto
                .disabled(vm.isExtracting || vm.urlString.isEmpty)       // D-07
            }

            Divider()  // entre fila Picker+Botón y DisclosureGroup

            // ── Opciones avanzadas ─────────────────────────────────────
            DisclosureGroup("Opciones avanzadas", isExpanded: $isExpanded) {  // D-11
                VStack(spacing: 8) {
                    HStack {
                        Text("Selector CSS")          // UI-SPEC label exacto
                            .frame(width: 160, alignment: .leading)
                        TextField("article, .content\u{2026}", text: $vm.selectorCSS)  // U+2026
                            .disabled(vm.isExtracting)
                    }
                    HStack {
                        Text("Tiempo límite (segundos)")  // UI-SPEC label exacto
                            .frame(width: 160, alignment: .leading)
                        TextField("15", value: $vm.timeout, formatter: NumberFormatter())  // D-12
                            .disabled(vm.isExtracting)
                    }
                }
                .padding(.top, 4)
            }
            .disabled(vm.isExtracting)

            Divider()  // entre DisclosureGroup y área resultado

            // ── Área resultado / progreso / error ──────────────────────
            // D-01: area final del VStack
            Group {
                if vm.isExtracting {
                    // Estado 3: extrayendo — APP-02
                    ProgressView("Extrayendo\u{2026}")  // U+2026, UI-SPEC exacto
                } else if vm.resultContent != nil {
                    // Estado 4: éxito — D-06: WKWebView para los 3 tipos
                    WebPreviewView(
                        htmlContent: vm.htmlForPreview,
                        contentReady: $vm.contentReady,
                        viewModel: vm
                    )
                } else if let errorMsg = vm.errorMessage {
                    // Estado 5: error — D-08, APP-03
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Error: \(errorMsg)")
                            .foregroundColor(.red)
                            .font(.caption)
                        if vm.isPythonPathError {
                            // UI-SPEC: hint en .secondary, visualmente diferenciado
                            Text("Configura la ruta en Preferencias (⌘,)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Estado 1/2: vacío — sin contenido visible
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()  // NUEVO Phase 5: entre preview y fila export

            // ── Fila de exportación (Phase 5) ──────────────────────────
            HStack(spacing: 8) {
                Picker("", selection: $vm.exportFormat) {
                    Text("Markdown").tag("markdown")     // UI-SPEC exacto
                    Text("HTML").tag("html")             // UI-SPEC exacto
                    Text("PDF").tag("pdf").disabled(true)  // D-09: Phase 6
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .disabled(!vm.contentReady)  // D-07, D-08

                Button {
                    Task { await vm.export() }
                } label: {
                    Label("Exportar", systemImage: "square.and.arrow.up")  // UI-SPEC
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Exportar contenido")  // UI-SPEC exacto
                .disabled(!vm.contentReady)  // D-08
            }

        }
        .padding()
        .frame(minWidth: 500, minHeight: 450)  // D-03
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
