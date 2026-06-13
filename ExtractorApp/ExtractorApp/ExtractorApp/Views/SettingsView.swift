import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Form {
                // MARK: Rutas de ejecución
                Section {
                    PathInputRow(
                        label: "Intérprete Python",
                        placeholder: "/ruta/al/.venv/bin/python",
                        path: $vm.pythonPath,
                        validation: vm.pythonValidation,
                        onPick: { vm.pickPythonPath() }
                    )

                    PathInputRow(
                        label: "Script extractor_url.py",
                        placeholder: "/ruta/al/extractor_url.py",
                        path: $vm.scriptPath,
                        validation: vm.scriptValidation,
                        onPick: { vm.pickScriptPath() }
                    )
                } header: {
                    Label("Rutas de ejecución", systemImage: "terminal")
                        .font(.headline)
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("El intérprete debe ser el Python nativo de la arquitectura del Mac (no Rosetta).")
                        Text("Ejemplo: /Users/usuario/proyectos/extractor-url/.venv/bin/python")
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // MARK: Estado de validación
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
                    HelpTextView()
                } header: {
                    Label("Información", systemImage: "info.circle")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 520, alignment: .top)
        .padding(.vertical, 8)
    }
}

// MARK: - PathInputRow

private struct PathInputRow: View {

    let label: String
    let placeholder: String
    @Binding var path: String
    let validation: PathValidationState
    let onPick: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                TextField(placeholder, text: $path)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)

                // Indicador de validación
                ValidationIcon(state: validation)

                // Botón "Examinar"
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
}

// MARK: - ValidationIcon

private struct ValidationIcon: View {

    let state: PathValidationState

    var body: some View {
        Image(systemName: state.systemImageName)
            .foregroundStyle(state.color)
            .imageScale(.large)
            .help(validationHelp)
            .animation(.easeInOut(duration: 0.2), value: state)
    }

    private var validationHelp: String {
        switch state {
        case .empty:         return "Sin ruta configurada"
        case .valid:         return "Ruta válida"
        case .notFound:      return "Archivo no encontrado"
        case .notExecutable: return "Sin permisos de ejecución"
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

// MARK: - HelpTextView

private struct HelpTextView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            helpRow(
                icon: "1.circle.fill",
                title: "Activar el entorno virtual",
                body: "Abre Terminal y ejecuta: source /ruta/proyecto/.venv/bin/activate"
            )
            helpRow(
                icon: "2.circle.fill",
                title: "Localizar el intérprete",
                body: "Ejecuta «which python» en Terminal con el venv activo para obtener la ruta exacta."
            )
            helpRow(
                icon: "3.circle.fill",
                title: "Localizar el script",
                body: "Selecciona el archivo extractor_url.py dentro de la carpeta del proyecto."
            )
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func helpRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.accentColor)
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

// MARK: - Preview

#Preview {
    SettingsView()
        .frame(width: 520)
}
