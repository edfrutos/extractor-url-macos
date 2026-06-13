import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var vm = ExtractionViewModel()
    @State private var isExpanded: Bool = false
    @State private var extractButtonScale: CGFloat = 1.0
    @State private var heroAppear: Bool = false

    var body: some View {
        ZStack {
            Color(.windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        inputCard
                        optionsCard
                        resultCard
                        exportCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(minWidth: 560, minHeight: 480)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                heroAppear = true
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        HStack(spacing: 12) {
            LogoMark(size: 36)
                .opacity(heroAppear ? 1 : 0)
                .offset(x: heroAppear ? 0 : -12)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: heroAppear)

            VStack(alignment: .leading, spacing: 2) {
                Text("Extractor URL")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Extrae contenido web en texto, HTML o Markdown")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .opacity(heroAppear ? 1 : 0)
            .offset(y: heroAppear ? 0 : 4)
            .animation(.easeOut(duration: 0.45).delay(0.1), value: heroAppear)

            Spacer()

            if vm.isExtracting {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                        .controlSize(.mini)
                    Text("Extrayendo...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.isExtracting)
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(spacing: 0) {
            // Campo URL con estilo capsula
            HStack(spacing: 8) {
                Image(systemName: "link")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)

                TextField("https://example.com", text: $vm.urlString)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .onSubmit { vm.extract() }
                    .disabled(vm.isExtracting)
                    .accessibilityLabel("URL a extraer")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )

            Spacer().frame(height: 10)

            // Fila Picker + Boton Extraer
            HStack(spacing: 10) {
                Text("Formato:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Tipo", selection: $vm.outputType) {
                    Text("Texto").tag("text")
                    Text("HTML").tag("html")
                    Text("Markdown").tag("markdown")
                }
                .pickerStyle(.segmented)
                .disabled(vm.isExtracting)
                .frame(maxWidth: 220)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        extractButtonScale = 0.94
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            extractButtonScale = 1.0
                        }
                        vm.extract()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(
                            systemName: vm.isExtracting
                                ? "stop.circle"
                                : "arrow.down.circle.fill"
                        )
                        .font(.system(size: 14, weight: .semibold))
                        Text("Extraer")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .buttonStyle(.borderedProminent)
                .scaleEffect(extractButtonScale)
                .accessibilityLabel("Extraer contenido de la URL")
                .disabled(vm.isExtracting || vm.urlString.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: vm.urlString.isEmpty)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Options Card

    private var optionsCard: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 10) {
                Divider()
                    .padding(.horizontal, -14)

                optionRow(icon: "number", label: "Selector CSS") {
                    TextField("article, .content\u{2026}", text: $vm.selectorCSS)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .disabled(vm.isExtracting)
                }

                Divider()
                    .padding(.horizontal, -14)

                optionRow(icon: "clock", label: "Tiempo limite (s)") {
                    TextField("15", value: $vm.timeout, formatter: NumberFormatter())
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .disabled(vm.isExtracting)
                        .frame(maxWidth: 80)
                }
            }
            .padding(.top, 6)
            .disabled(vm.isExtracting)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("Opciones avanzadas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private func optionRow<Content: View>(
        icon: String,
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 140, alignment: .leading)
            content()
            Spacer()
        }
        .padding(.horizontal, 2)
    }

    // MARK: - Result Card

    @ViewBuilder
    private var resultCard: some View {
        VStack(spacing: 0) {
            // Header del resultado
            HStack {
                Image(systemName: resultHeaderIcon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(resultHeaderColor)
                Text(resultHeaderLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()

                if vm.resultContent != nil && !vm.isExtracting {
                    Text(vm.outputType.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()
                .padding(.horizontal, -24)

            // Contenido resultado con fondo diferenciado
            resultContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityElement(children: .contain)
        }
        .frame(minHeight: 240)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.controlBackgroundColor))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .animation(.easeInOut(duration: 0.3), value: vm.isExtracting)
        .animation(.easeInOut(duration: 0.3), value: vm.resultContent != nil)
    }

    private var resultHeaderIcon: String {
        if vm.isExtracting { return "arrow.down.circle" }
        if vm.resultContent != nil { return "checkmark.circle.fill" }
        if vm.errorMessage != nil { return "exclamationmark.triangle.fill" }
        return "doc.text"
    }

    private var resultHeaderColor: Color {
        if vm.isExtracting { return .accentColor }
        if vm.resultContent != nil { return .green }
        if vm.errorMessage != nil { return .orange }
        return .secondary
    }

    private var resultHeaderLabel: String {
        if vm.isExtracting { return "Extrayendo..." }
        if vm.resultContent != nil {
            let chars = vm.resultContent?.count ?? 0
            return "Resultado — \(chars.formatted()) caracteres"
        }
        if vm.errorMessage != nil { return "Error" }
        return "Vista previa"
    }

    @ViewBuilder
    private var resultContent: some View {
        if vm.isExtracting {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Extrayendo contenido\u{2026}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 40)

        } else if vm.resultContent != nil {
            WebPreviewView(
                htmlContent: vm.htmlForPreview,
                contentReady: $vm.contentReady,
                viewModel: vm
            )
            .frame(minHeight: 200)

        } else if let errorMsg = vm.errorMessage {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Error de extraccion")
                            .font(.subheadline)
                            .bold()
                        Text(errorMsg)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                if vm.isPythonPathError {
                    Button("Abrir Preferencias") {
                        NSApp.sendAction(
                            Selector(("showPreferencesWindow:")),
                            to: nil,
                            from: nil
                        )
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 56, height: 56)
                LogoMark(size: 28)
                    .opacity(0.6)
            }
            Text("Introduce una URL y pulsa Extraer")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Text("El resultado aparecera aqui")
                .font(.caption)
                .foregroundStyle(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Export Card

    private var exportCard: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(vm.contentReady ? Color.accentColor : Color.secondary)

                Text("Exportar como")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Picker("", selection: $vm.exportFormat) {
                    Text("Markdown").tag("markdown")
                    Text("HTML").tag("html")
                    Text("PDF").tag("pdf")
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .disabled(!vm.contentReady)
                .frame(maxWidth: 200)

                Spacer()

                Button {
                    Task { await vm.export() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Exportar")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Exportar contenido")
                .disabled(!vm.contentReady)
                .animation(.easeInOut(duration: 0.2), value: vm.contentReady)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .padding(.top, 8)
        }
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - LogoMark

/// Icono vectorial de la marca: nodo central con 3 ramas de extraccion.
/// Pure SwiftUI Canvas — sin dependencia de assets externos.
struct LogoMark: View {
    let size: CGFloat

    var body: some View {
        Canvas { ctx, bounds in
            let cx = bounds.width / 2
            let cy = bounds.height / 2
            let r  = min(cx, cy)

            // Fondo circular con tono de acento del sistema
            let bgPath = Path(ellipseIn: CGRect(
                x: cx - r, y: cy - r, width: r * 2, height: r * 2
            ))
            ctx.fill(bgPath, with: .color(Color.accentColor))

            let s         = r * 0.36
            let lineWidth = max(1.5, r * 0.09)
            let style     = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            let nodeR     = s * 0.28

            // Nodo central (circulo blanco relleno)
            let nodePath = Path(ellipseIn: CGRect(
                x: cx - nodeR, y: cy - nodeR,
                width: nodeR * 2, height: nodeR * 2
            ))
            ctx.fill(nodePath, with: .color(.white))

            // 3 ramas salientes a 0 deg, 120 deg, 240 deg
            let angles: [Double] = [0, 120, 240].map { $0 * .pi / 180 }
            for angle in angles {
                let endX = cx + cos(angle) * s
                let endY = cy + sin(angle) * s

                var linePath = Path()
                linePath.move(to: CGPoint(
                    x: cx + cos(angle) * nodeR,
                    y: cy + sin(angle) * nodeR
                ))
                linePath.addLine(to: CGPoint(x: endX, y: endY))
                ctx.stroke(linePath, with: .color(.white.opacity(0.92)), style: style)

                let dotR = nodeR * 0.7
                let dotPath = Path(ellipseIn: CGRect(
                    x: endX - dotR, y: endY - dotR,
                    width: dotR * 2, height: dotR * 2
                ))
                ctx.fill(dotPath, with: .color(.white.opacity(0.85)))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
