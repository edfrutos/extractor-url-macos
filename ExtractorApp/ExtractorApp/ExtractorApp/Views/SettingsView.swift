import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()

    @State private var verificationResult: String? = nil
    @State private var isVerifying: Bool = false

    // MARK: Sección avanzada (Fase 10: colapsada por defecto en modo bundle)
    @State private var advancedExpanded: Bool = false
    @State private var didSetInitialAdvancedState: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera con titulo
            Text("Preferencias")
                .font(.title2)
                .bold()
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Form {
                // MARK: Modo de operación
                Section {
                    OperatingModeRow(mode: vm.operatingMode)
                } header: {
                    Label("Modo de operación", systemImage: "gearshape.2")
                        .font(.headline)
                }

                // MARK: Actualizaciones (Fase 16: opt-in a canal beta)
                Section {
                    Toggle("Recibir actualizaciones beta", isOn: $vm.betaChannelOptIn)
                    Text("Las versiones beta pueden ser menos estables. Puedes desactivar esto en cualquier momento.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                } header: {
                    Label("Actualizaciones", systemImage: "arrow.down.circle")
                        .font(.headline)
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
                        Label("Dependencias del motor", systemImage: "shippingbox")
                            .font(.headline)
                    }
                }

                // MARK: Configuración avanzada (colapsable, opcional)
                // DisclosureGroup nativo — mismo componente que optionsCard en
                // ContentView, en vez de un Button+chevron a mano: mantiene la
                // app coherente y expone a VoiceOver el trait de
                // expandido/colapsado que un Button normal no comunica.
                Section {
                    DisclosureGroup(isExpanded: $advancedExpanded) {
                        VStack(alignment: .leading, spacing: 16) {
                            // MARK: Rutas de ejecución
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Rutas de ejecución", systemImage: "terminal")
                                    .font(.headline)

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
                            }

                            Divider()

                            // MARK: Verificación
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Verificación", systemImage: "checkmark.seal")
                                    .font(.headline)

                                Button("Verificar configuración") {
                                    Task { await verifyConfiguration() }
                                }
                                .buttonStyle(.bordered)
                                .disabled(isVerifying || vm.pythonPath.isEmpty)

                                if isVerifying {
                                    HStack(spacing: 6) {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                            .controlSize(.mini)
                                        Text("Comprobando intérprete…")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                if let result = verificationResult {
                                    Text(result)
                                        .font(.caption)
                                        .monospaced()
                                        .foregroundStyle(
                                            result.lowercased().contains("error")
                                                ? Color.red
                                                : Color.secondary
                                        )
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.textBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                            }

                            // MARK: Advertencias (condicional)
                            if vm.pythonValidation.helpText != nil || vm.scriptValidation.helpText != nil {
                                Divider()
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Advertencias", systemImage: "exclamationmark.triangle")
                                        .font(.headline)
                                    ValidationSummaryView(
                                        pythonValidation: vm.pythonValidation,
                                        scriptValidation: vm.scriptValidation
                                    )
                                }
                            }

                            Divider()

                            // MARK: Ayuda
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Ayuda", systemImage: "info.circle")
                                    .font(.headline)

                                Text("Usar el Python nativo de la arquitectura del Mac (no Rosetta).")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)

                                Text("/Users/usuario/proyectos/extractor-url/.venv/bin/python")
                                    .font(.caption)
                                    .monospaced()
                                    .foregroundStyle(.secondary)

                                if vm.pythonValidation != .valid || vm.scriptValidation != .valid {
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.orange)
                                            .font(.caption)
                                        Text("Configura ambas rutas correctamente para poder extraer contenido.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }

                                Divider()

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
                        }
                        .padding(.top, 8)
                    } label: {
                        Label("Configuración avanzada", systemImage: "wrench.and.screwdriver")
                            .font(.headline)
                    }

                    Text("Override manual de rutas para desarrollo o instalaciones no estándar. No es necesario para el uso normal — la app funciona con el Python incluido.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 520, alignment: .top)
        .onAppear {
            // Solo la primera vez: si ya hay un override activo (o el bundle
            // no está disponible), abrir la sección avanzada de entrada para
            // que el usuario vea de inmediato lo que está pasando (UX-03).
            guard !didSetInitialAdvancedState else { return }
            didSetInitialAdvancedState = true
            advancedExpanded = !vm.isBundleMode
        }
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

    // MARK: - Help Row

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
            HStack(spacing: 8) {
                Image(systemName: "chevron.right.2")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text(helpText)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                validationBadge(validation: validation, path: path)
            }

            HStack(spacing: 8) {
                TextField(placeholder, text: $path)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)

                // Boton Examinar
                Button {
                    onPick()
                } label: {
                    Label("Examinar", systemImage: "folder")
                        .labelStyle(.iconOnly)
                }
                .help("Seleccionar archivo con el panel de Finder")
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: Validation Badge (Capsule)

    @ViewBuilder
    private func validationBadge(validation: PathValidationState, path: String) -> some View {
        switch validation {
        case .valid:
            Capsule()
                .fill(Color.green.opacity(0.15))
                .frame(height: 22)
                .overlay(
                    Label("OK", systemImage: "checkmark")
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                )
                .fixedSize()

        case .notFound:
            Capsule()
                .fill(Color.red.opacity(0.15))
                .frame(height: 22)
                .overlay(
                    Label("No encontrado", systemImage: "xmark")
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                )
                .fixedSize()

        case .notExecutable:
            Capsule()
                .fill(Color.orange.opacity(0.15))
                .frame(height: 22)
                .overlay(
                    Label("Sin permisos", systemImage: "lock")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                )
                .fixedSize()

        case .empty:
            EmptyView()
        }
    }
}

// MARK: - ValidationSummaryView

private struct ValidationSummaryView: View {

    let pythonValidation: PathValidationState
    let scriptValidation: PathValidationState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let msg = pythonValidation.helpText {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: pythonValidation.systemImageName)
                        .foregroundStyle(pythonValidation.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Intérprete Python")
                            .fontWeight(.medium)
                        Text(msg)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.callout)
            }

            if let msg = scriptValidation.helpText {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: scriptValidation.systemImageName)
                        .foregroundStyle(scriptValidation.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Script extractor_url.py")
                            .fontWeight(.medium)
                        Text(msg)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.callout)
            }
        }
        .padding(.vertical, 4)
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
            return "Sobrescribiendo el Python incluido con la ruta manual de Configuración avanzada."
        case .unavailable:
            return "Configura una ruta manual en Configuración avanzada para poder extraer contenido."
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
                .font(.caption2)
                .foregroundStyle(.tertiary)

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
