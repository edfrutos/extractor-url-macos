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
                // MARK: Modo de operacion
                Section {
                    OperatingModeRow(mode: vm.operatingMode)
                } header: {
                    Label("Modo de operacion", systemImage: "gearshape.2")
                        .font(.headline)
                }

                // MARK: Configuracion avanzada (colapsable, opcional)
                Section {
                    Button {
                        withAnimation { advancedExpanded.toggle() }
                    } label: {
                        HStack {
                            Label("Configuracion avanzada", systemImage: "wrench.and.screwdriver")
                                .font(.headline)
                            Spacer()
                            Text(advancedExpanded ? "Ocultar" : "Mostrar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: advancedExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Text("Override manual de rutas para desarrollo o instalaciones no estandar. No es necesario para el uso normal — la app funciona con el Python incluido.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if advancedExpanded {
                    // MARK: Rutas de ejecucion
                    Section {
                        PathInputRow(
                            label: "Interprete Python",
                            helpText: "Interprete Python nativo del Mac (no Rosetta). Selecciona el ejecutable del entorno virtual.",
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
                        Label("Rutas de ejecucion", systemImage: "terminal")
                            .font(.headline)
                    }

                    // MARK: Verificacion
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Button("Verificar configuracion") {
                                Task { await verifyConfiguration() }
                            }
                            .buttonStyle(.bordered)
                            .disabled(isVerifying || vm.pythonPath.isEmpty)

                            if isVerifying {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .controlSize(.mini)
                                    Text("Comprobando interprete...")
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
                                            ? AnyShapeStyle(Color.red)
                                            : AnyShapeStyle(Color.secondary)
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.textBackgroundColor))
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Label("Verificacion", systemImage: "checkmark.seal")
                            .font(.headline)
                    }

                    // MARK: Advertencias (condicional)
                    if vm.pythonValidation.helpText != nil || vm.scriptValidation.helpText != nil {
                        Section {
                            ValidationSummaryView(
                                pythonValidation: vm.pythonValidation,
                                scriptValidation: vm.scriptValidation
                            )
                        } header: {
                            Label("Advertencias", systemImage: "exclamationmark.triangle")
                                .font(.headline)
                        }
                    }

                    // MARK: Ayuda
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
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
                                title: "Localizar el interprete",
                                body: "Ejecuta 'which python' en Terminal con el venv activo para obtener la ruta exacta."
                            )
                            helpRow(
                                icon: "3.circle.fill",
                                title: "Localizar el script",
                                body: "Selecciona el archivo extractor_url.py dentro de la carpeta del proyecto."
                            )
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Label("Ayuda", systemImage: "info.circle")
                            .font(.headline)
                    }
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
                    process.waitUntilExit()
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
                        Text("Interprete Python")
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
            return "Usando configuracion manual"
        case .unavailable:
            return "Python no disponible"
        }
    }

    private var subtitle: String {
        switch mode {
        case .bundle:
            return "No necesitas configurar nada — la extraccion funciona de serie."
        case .override:
            return "Sobrescribiendo el Python incluido con la ruta manual de Configuracion avanzada."
        case .unavailable:
            return "Configura una ruta manual en Configuracion avanzada para poder extraer contenido."
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

// MARK: - Preview

#Preview {
    SettingsView()
        .frame(width: 520)
}
