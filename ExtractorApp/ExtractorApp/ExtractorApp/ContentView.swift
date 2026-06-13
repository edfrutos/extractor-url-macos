import SwiftUI

// MARK: - Brand Design System

/// Paleta de colores centralizada — coherente con logo y app icon.
extension Color {
    static let brandPrimary   = Color(red: 0.310, green: 0.431, blue: 0.969) // #4F6EF7
    static let brandSecondary = Color(red: 0.227, green: 0.337, blue: 0.831) // #3A56D4
    static let brandAccent    = Color(red: 0.388, green: 0.761, blue: 0.663) // #63C2A9 mint
    static let surfaceLight   = Color(red: 0.969, green: 0.973, blue: 0.988)
    static let surfaceDark    = Color(red: 0.110, green: 0.118, blue: 0.157)
    static let cardLight      = Color.white
    static let cardDark       = Color(red: 0.145, green: 0.157, blue: 0.208)
}

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var vm = ExtractionViewModel()
    @State private var isExpanded: Bool = false
    @State private var extractButtonScale: CGFloat = 1.0
    @State private var heroAppear: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Fondo adaptativo
            adaptiveBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Hero ──────────────────────────────────────────────────
                heroSection

                // ── Contenido principal (scroll para ventanas pequeñas) ──
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        inputCard
                        optionsCard
                        resultCard
                        exportCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(minWidth: 560, minHeight: 500)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                heroAppear = true
            }
        }
    }

    // MARK: - Background

    private var adaptiveBackground: some View {
        Group {
            if colorScheme == .dark {
                Color.surfaceDark
            } else {
                LinearGradient(
                    colors: [
                        Color.surfaceLight,
                        Color(red: 0.945, green: 0.953, blue: 0.996)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
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
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Extrae contenido web en texto, HTML o Markdown")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .opacity(heroAppear ? 1 : 0)
            .offset(y: heroAppear ? 0 : 4)
            .animation(.easeOut(duration: 0.45).delay(0.1), value: heroAppear)

            Spacer()

            // Indicador de estado activo
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
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            colorScheme == .dark
                ? Color.cardDark.opacity(0.6)
                : Color.white.opacity(0.85)
        )
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.isExtracting)
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(spacing: 0) {
            // Label
            HStack {
                Image(systemName: "link")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.brandPrimary)
                Text("URL")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 6)

            Divider().padding(.horizontal, 14)

            // Campo URL
            TextField("https://example.com", text: $vm.urlString)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .onSubmit { vm.extract() }
                .disabled(vm.isExtracting)
                .accessibilityLabel("URL a extraer")

            Divider().padding(.horizontal, 14)

            // Fila Picker + Botón Extraer
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text("Formato")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Picker("Tipo", selection: $vm.outputType) {
                    Text("Texto").tag("text")
                    Text("HTML").tag("html")
                    Text("Markdown").tag("markdown")
                }
                .pickerStyle(.segmented)
                .disabled(vm.isExtracting)
                .frame(maxWidth: 220)

                Spacer()

                // Botón Extraer con animación de tap
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        vm.urlString.isEmpty || vm.isExtracting
                            ? Color.brandPrimary.opacity(0.35)
                            : Color.brandPrimary
                    )
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .scaleEffect(extractButtonScale)
                .accessibilityLabel("Extraer contenido de la URL")
                .disabled(vm.isExtracting || vm.urlString.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: vm.urlString.isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: cardShadow, radius: 4, x: 0, y: 2)
    }

    // MARK: - Options Card

    private var optionsCard: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 10) {
                Divider().padding(.horizontal, -14)

                optionRow(icon: "number", label: "Selector CSS") {
                    TextField("article, .content\u{2026}", text: $vm.selectorCSS)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .disabled(vm.isExtracting)
                }

                Divider().padding(.horizontal, -14)

                optionRow(icon: "clock", label: "Tiempo límite (s)") {
                    TextField("15", value: $vm.timeout, formatter: NumberFormatter())
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, design: .monospaced))
                        .disabled(vm.isExtracting)
                        .frame(maxWidth: 60)
                }
            }
            .padding(.top, 6)
            .disabled(vm.isExtracting)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.brandPrimary)
                Text("Opciones avanzadas")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: cardShadow, radius: 4, x: 0, y: 2)
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
                .frame(width: 150, alignment: .leading)
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
                        .foregroundStyle(Color.brandPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.brandPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            // Contenido resultado
            resultContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 240)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: cardShadow, radius: 4, x: 0, y: 2)
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
        if vm.isExtracting { return Color.brandPrimary }
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
                ZStack {
                    Circle()
                        .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 4)
                        .frame(width: 48, height: 48)
                    ProgressView()
                        .scaleEffect(1.4)
                        .tint(Color.brandPrimary)
                }
                Text("Extrayendo\u{2026}")
                    .font(.system(size: 14, weight: .medium))
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
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.orange)
                    Text(errorMsg)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if vm.isPythonPathError {
                    HStack(spacing: 6) {
                        Image(systemName: "gear")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Text("Configura la ruta Python en Preferencias (⌘,)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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
                    .fill(Color.brandPrimary.opacity(0.08))
                    .frame(width: 56, height: 56)
                LogoMark(size: 28)
                    .opacity(0.6)
            }
            Text("Introduce una URL y pulsa Extraer")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            Text("El resultado aparecerá aquí")
                .font(.caption)
                .foregroundStyle(Color.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Export Card

    private var exportCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(vm.contentReady ? Color.brandPrimary : Color.secondary)

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
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    vm.contentReady
                        ? Color.brandAccent
                        : Color.secondary.opacity(0.2)
                )
                .foregroundStyle(vm.contentReady ? Color.white : Color.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Exportar contenido")
            .disabled(!vm.contentReady)
            .animation(.easeInOut(duration: 0.2), value: vm.contentReady)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: cardShadow, radius: 4, x: 0, y: 2)
    }

    // MARK: - Helpers

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                Color.cardDark
            } else {
                Color.cardLight
            }
        }
    }

    private var cardShadow: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.25)
            : Color.black.opacity(0.06)
    }
}

// MARK: - LogoMark

/// Icono vectorial de la marca: nodo central con 3 ramas de extracción.
/// Pure SwiftUI Canvas — sin dependencia de assets externos.
struct LogoMark: View {
    let size: CGFloat

    var body: some View {
        Canvas { ctx, bounds in
            let cx = bounds.width / 2
            let cy = bounds.height / 2
            let r  = min(cx, cy)

            // Fondo circular con gradiente azul índigo
            let bgPath = Path(ellipseIn: CGRect(
                x: cx - r, y: cy - r, width: r * 2, height: r * 2
            ))
            ctx.fill(
                bgPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.310, green: 0.431, blue: 0.969),
                        Color(red: 0.227, green: 0.337, blue: 0.831)
                    ]),
                    startPoint: CGPoint(x: cx - r, y: cy - r),
                    endPoint: CGPoint(x: cx + r, y: cy + r)
                )
            )

            let s         = r * 0.36
            let lineWidth = max(1.5, r * 0.09)
            let style     = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            let nodeR     = s * 0.28

            // Nodo central (círculo blanco relleno)
            let nodePath = Path(ellipseIn: CGRect(
                x: cx - nodeR, y: cy - nodeR,
                width: nodeR * 2, height: nodeR * 2
            ))
            ctx.fill(nodePath, with: .color(.white))

            // 3 ramas salientes a 0°, 120°, 240°
            let angles: [Double] = [0, 120, 240].map { $0 * .pi / 180 }
            for angle in angles {
                let endX = cx + cos(angle) * s
                let endY = cy + sin(angle) * s

                // Línea nodo → extremo
                var linePath = Path()
                linePath.move(to: CGPoint(
                    x: cx + cos(angle) * nodeR,
                    y: cy + sin(angle) * nodeR
                ))
                linePath.addLine(to: CGPoint(x: endX, y: endY))
                ctx.stroke(linePath, with: .color(.white.opacity(0.92)), style: style)

                // Punto terminal (círculo mint accent)
                let dotR = nodeR * 0.7
                let dotPath = Path(ellipseIn: CGRect(
                    x: endX - dotR, y: endY - dotR,
                    width: dotR * 2, height: dotR * 2
                ))
                ctx.fill(dotPath, with: .color(Color(red: 0.388, green: 0.761, blue: 0.663)))
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
