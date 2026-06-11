import SwiftUI

struct SettingsView: View {
    @AppStorage("pythonPath") var pythonPath: String = ""
    @AppStorage("scriptPath") var scriptPath: String = ""

    private var pythonValid: Bool {
        !pythonPath.isEmpty && FileManager.default.isExecutableFile(atPath: pythonPath)
    }

    private var scriptValid: Bool {
        !scriptPath.isEmpty && FileManager.default.fileExists(atPath: scriptPath)
    }

    var body: some View {
        Form {
            Section("Rutas de ejecución") {
                HStack {
                    TextField("Intérprete Python (p. ej. /ruta/.venv/bin/python)", text: $pythonPath)
                    validationIcon(valid: pythonValid, path: pythonPath)
                }
                HStack {
                    TextField("Script extractor_url.py (ruta absoluta)", text: $scriptPath)
                    validationIcon(valid: scriptValid, path: scriptPath)
                }
            }

            Section("Información") {
                Text("El intérprete debe ser el Python nativo de la arquitectura del Mac (no Rosetta).\nEjemplo: /Users/usuario/proyectos/extractor-url/.venv/bin/python")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .padding()

        if !pythonValid && !pythonPath.isEmpty {
            Text("Ruta Python no encontrada o sin permisos de ejecución")
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
        }
        if !scriptValid && !scriptPath.isEmpty {
            Text("Script no encontrado en la ruta indicada")
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func validationIcon(valid: Bool, path: String) -> some View {
        if !path.isEmpty {
            Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(valid ? .green : .red)
        }
    }
}
