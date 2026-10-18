import SwiftUI

// MARK: - SettingsView

/// Ventana de Ajustes con pestañas en la barra (convención macOS):
/// General para el uso normal y Avanzado para el override manual de rutas.
struct SettingsView: View {

    private enum Tab: Hashable {
        case general
        case advanced
    }

    @StateObject private var vm = SettingsViewModel()

    // Fase 10/UX-03: si ya hay un override activo (o el bundle no está
    // disponible), abrir directamente en Avanzado para que el usuario vea
    // de inmediato lo que está pasando. Solo la primera vez.
    @State private var selectedTab: Tab = .general
    @State private var didSetInitialTab: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsTab(vm: vm)
                .tabItem { Label("General", systemImage: "gearshape") }
                .tag(Tab.general)

            AdvancedSettingsTab(vm: vm)
                .tabItem { Label("Avanzado", systemImage: "wrench.and.screwdriver") }
                .tag(Tab.advanced)
        }
        .frame(width: 520, height: 440)
        .onAppear {
            guard !didSetInitialTab else { return }
            didSetInitialTab = true
            if !vm.isBundleMode {
                selectedTab = .advanced
            }
        }
    }
}

// MARK: - GeneralSettingsTab

private struct GeneralSettingsTab: View {

    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        Form {
            // MARK: Modo de operación
            Section {
                OperatingModeRow(mode: vm.operatingMode)
            } header: {
                Text("Modo de operación")
            }

            // MARK: Actualizaciones (Fase 16: opt-in a canal beta)
            Section {
                Toggle(isOn: $vm.betaChannelOptIn) {
                    Text("Recibir actualizaciones beta")
                    Text("Las versiones beta pueden ser menos estables. Puedes desactivar esto en cualquier momento.")
                }
            } header: {
                Text("Actualizaciones")
            }

            // MARK: Runtime Python (Fase 21: dependencias puras vendorizadas)
            if vm.isBundleMode {
                Section {
                    RuntimeUpdateRow(
                        activeVersion: vm.activeRuntimeVersion,
                        state: vm.runtimeUpdateState,
                        onCheck: { vm.checkForRuntimeUpdate() }
                    )
                } header: {
                    Text("Dependencias del motor")
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - AdvancedSettingsTab

private struct AdvancedSettingsTab: View {

    @ObservedObject var vm: SettingsViewModel

    @State private var verificationResult: String? = nil
    @State private var isVerifying: Bool = false
    @State private var showPathsHelp: Bool = false

    var body: some View {
        Form {
            // MARK: Rutas de ejecución
            Section {
                PathInputRow(
                    label: "Intérprete Python",
                    helpText: "Intérprete Python nativo del Mac (no Rosetta). Selecciona el ejecutable del entorno virtual.",
                    placeholder: "/ruta/al/.venv/bin/python",
                    path: $vm.pythonPath,
                    validation: vm.pythonValidation,
                    onPick: { vm.pickPythonPath() }
                )

                PathInputRow(
                    label: "Script extractor_url.py",
                    helpText: "Ruta absoluta al fichero extractor_url.py",
                    placeholder: "/ruta/al/extractor_url.py",
                    path: $vm.scriptPath,
                    validation: vm.scriptValidation,
                    onPick: { vm.pickScriptPath() }
                )
            } header: {
                // La ayuda vive en un popover (botón "?"), no en el propio
                // formulario: los ajustes de macOS se mantienen escuetos.
                HStack {
                    Text("Rutas de ejecución")
                    Spacer()
                    Button {
                        showPathsHelp.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(.borderless)
                    .help("Cómo localizar el intérprete y el script")
                    .popover(isPresented: $showPathsHelp, arrowEdge: .bottom) {
                        PathsHelpView()
                    }
                }
            } footer: {
                Text("Override manual de rutas para desarrollo o instalaciones no estándar. No es necesario para el uso normal — la app funciona con el Python incluido.")
            }

            // MARK: Verificación
            Section {
                HStack(spacing: 8) {
                    Button("Verificar configuración") {
                        Task { await verifyConfiguration() }
                    }
                    .disabled(isVerifying || vm.pythonPath.isEmpty)

                    if isVerifying {
                        ProgressView()
                            .controlSize(.small)
                        Text("Comprobando intérprete…")
                            .foregroundStyle(.secondary)
                    }
                }

                if let result = verificationResult {
                    Text(result)
                        .font(.callout)
                        .monospaced()
                        .textSelection(.enabled)
                        .foregroundStyle(
                            result.lowercased().contains("error")
                                ? Color.red
                                : Color.secondary
                        )
                }
            } header: {
                Text("Verificación")
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Verify Configuration

    /// Ejecuta `pythonPath --version` via Process y almacena el resultado en verificationResult.
    /// Amenaza T-03-04-01: solo se pasa `--version` — sin args controlados por el usuario.
    private func verifyConfiguration() async {
        guard !vm.pythonPath.isEmpty else { return }

        isVerifying = true
        verificationResult = nil

        // Captura el valor en el hilo principal antes de entrar en el closure Sendable
        let pythonPathCopy = vm.pythonPath

        let result = await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: pythonPathCopy)
                process.arguments = ["--version"]

                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe

                do {
                    try process.run()

                    // Un binario que cuelga bloquearía `waitUntilExit()`
                    // indefinidamente y con él el spinner "Comprobando
                    // intérprete…", sin forma de cancelar. Watchdog: a los
                    // 10 s se envía SIGTERM y `waitUntilExit()` retorna;
                    // eso deja `terminationReason == .uncaughtSignal`.
                    let watchdog = DispatchWorkItem { process.terminate() }
                    DispatchQueue.global().asyncAfter(deadline: .now() + 10, execute: watchdog)

                    process.waitUntilExit()
                    watchdog.cancel()

                    if process.terminationReason == .uncaughtSignal {
                        cont.resume(returning: "Error: la verificación superó el tiempo límite (10 s) o el proceso terminó de forma anómala.")
                        return
                    }

                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        ?? "Sin respuesta"
                    cont.resume(returning: output.isEmpty ? "Sin respuesta" : output)
                } catch {
                    cont.resume(returning: "Error: \(error.localizedDescription)")
                }
            }
        }

        await MainActor.run {
            verificationResult = result
            isVerifying = false
        }
    }
}

// MARK: - PathsHelpView

/// Ayuda del override manual, mostrada en un popover desde la pestaña Avanzado.
private struct PathsHelpView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Usa el Python nativo de la arquitectura del Mac (no Rosetta).")
                .font(.callout)

            helpRow(
                icon: "1.circle.fill",
                title: "Activar el entorno virtual",
                body: "Abre Terminal y ejecuta: source /ruta/proyecto/.venv/bin/activate"
            )
            helpRow(
                icon: "2.circle.fill",
                title: "Localizar el intérprete",
                body: "Ejecuta 'which python' en Terminal con el venv activo para obtener la ruta exacta."
            )
            helpRow(
                icon: "3.circle.fill",
                title: "Localizar el script",
                body: "Selecciona el archivo extractor_url.py dentro de la carpeta del proyecto."
            )
        }
        .padding(16)
        .frame(width: 340)
    }

    @ViewBuilder
    private func helpRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .imageScale(.medium)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                    .font(.callout)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - PathInputRow

private struct PathInputRow: View {

    let label: String
    let helpText: String
    let placeholder: String
    @Binding var path: String
    let validation: PathValidationState
    let onPick: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                Text(helpText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                // labelsHidden + prompt: dentro de un Form agrupado, el título
                // de un TextField se pinta como etiqueta a la izquierda (el
                // placeholder acababa ahí, partido en dos líneas).
                TextField(label, text: $path, prompt: Text(placeholder))
                    .labelsHidden()
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)

                // "Elegir…" con puntos suspensivos: abre un panel (convención macOS)
                Button("Elegir…") {
                    onPick()
                }
                .help("Seleccionar archivo con el panel de Finder")
            }

            validationStatus
        }
        .padding(.vertical, 4)
    }

    // Estado bajo el campo con un SF Symbol coloreado (convención macOS),
    // en vez de una cápsula de color junto al título.
    @ViewBuilder
    private var validationStatus: some View {
        if validation != .empty {
            Label {
                Text(validation.helpText ?? "Ruta válida")
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: validation.systemImageName)
                    .foregroundStyle(validation.color)
            }
            .font(.caption)
        }
    }
}

// MARK: - OperatingModeRow (Fase 10: UX Zero-Config)

private struct OperatingModeRow: View {

    let mode: PythonOperatingMode

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var title: String {
        switch mode {
        case .bundle(let version):
            guard let version else { return "Usando Python incluido" }
            return "Usando Python incluido (Python \(version))"
        case .override:
            return "Usando configuración manual"
        case .unavailable:
            return "Python no disponible"
        }
    }

    private var subtitle: String {
        switch mode {
        case .bundle:
            return "No necesitas configurar nada — la extracción funciona de serie."
        case .override:
            return "Sobrescribiendo el Python incluido con la ruta manual de la pestaña Avanzado."
        case .unavailable:
            return "Configura una ruta manual en la pestaña Avanzado para poder extraer contenido."
        }
    }

    private var iconName: String {
        switch mode {
        case .bundle:      return "checkmark.seal.fill"
        case .override:    return "slider.horizontal.3"
        case .unavailable: return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch mode {
        case .bundle:      return .green
        case .override:    return .blue
        case .unavailable: return .orange
        }
    }
}

// MARK: - RuntimeUpdateRow (Fase 21: dependencias puras vendorizadas)

private struct RuntimeUpdateRow: View {

    let activeVersion: String?
    let state: RuntimeUpdateState
    let onCheck: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(statusColor)
            Text("requests, beautifulsoup4, markdownify y trafilatura — el intérprete Python y Chromium solo se actualizan con un release completo de la app.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Button("Buscar actualización") {
                    onCheck()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(state == .checking)

                if state == .checking {
                    ProgressView()
                        .scaleEffect(0.6)
                        .controlSize(.mini)
                }
            }

        }
        .padding(.vertical, 4)
    }

    // Error visible directamente en el texto de estado principal (no solo
    // en una segunda línea pequeña) — un timeout de red real durante el
    // checkpoint humano de la Fase 21 pasó casi desapercibido cuando el
    // fallo solo aparecía en una etiqueta secundaria diminuta.
    private var statusText: String {
        switch state {
        case .updated(let version):
            return "Dependencias actualizadas a \(version)."
        case .upToDate:
            if let activeVersion {
                return "Ya al día (versión \(activeVersion))."
            }
            return "Ya al día (usando las dependencias incluidas en el bundle)."
        case .checking:
            return "Comprobando…"
        case .failed(let message):
            return "Error: \(message)"
        case .idle:
            if let activeVersion {
                return "Dependencias actualizadas a \(activeVersion)."
            }
            return "Usando las dependencias incluidas en el bundle."
        }
    }

    private var statusColor: Color {
        if case .failed = state { return .red }
        return .primary
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .frame(width: 520)
}
