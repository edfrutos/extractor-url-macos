import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Validation State

enum PathValidationState: Equatable {
    case empty
    case valid
    case notFound
    case notExecutable  // solo aplicable al intérprete Python

    var systemImageName: String {
        switch self {
        case .empty:        return "minus.circle"
        case .valid:        return "checkmark.circle.fill"
        case .notFound:     return "xmark.circle.fill"
        case .notExecutable: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .empty:         return .secondary
        case .valid:         return .green
        case .notFound:      return .red
        case .notExecutable: return .orange
        }
    }

    var helpText: String? {
        switch self {
        case .empty:         return nil
        case .valid:         return nil
        case .notFound:      return "Archivo no encontrado en la ruta indicada."
        case .notExecutable: return "El archivo existe pero no tiene permisos de ejecución."
        }
    }
}

// MARK: - SettingsViewModel

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: @AppStorage — persiste automáticamente en UserDefaults

    @AppStorage("pythonPath") var pythonPath: String = "" {
        didSet { validatePythonPath() }
    }

    @AppStorage("scriptPath") var scriptPath: String = "" {
        didSet { validateScriptPath() }
    }

    // MARK: Validation state (@Published para reactividad en View)

    @Published private(set) var pythonValidation: PathValidationState = .empty
    @Published private(set) var scriptValidation: PathValidationState = .empty

    // MARK: Init

    init() {
        // Validar estado inicial (puede haber rutas ya guardadas)
        validatePythonPath()
        validateScriptPath()
    }

    // MARK: - Validation Logic

    /// Valida el intérprete Python: debe existir Y ser ejecutable.
    func validatePythonPath() {
        pythonValidation = validate(path: pythonPath, requireExecutable: true)
    }

    /// Valida el script: debe existir (no se requiere bit de ejecución en .py).
    func validateScriptPath() {
        scriptValidation = validate(path: scriptPath, requireExecutable: false)
    }

    private func validate(path: String, requireExecutable: Bool) -> PathValidationState {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        let fm = FileManager.default
        guard fm.fileExists(atPath: trimmed) else { return .notFound }

        if requireExecutable {
            guard fm.isExecutableFile(atPath: trimmed) else { return .notExecutable }
        }

        return .valid
    }

    // MARK: - NSOpenPanel File Picker

    /// Abre NSOpenPanel para elegir el intérprete Python.
    /// Permite cualquier archivo ejecutable (sin filtro de extensión).
    func pickPythonPath() {
        let panel = makeOpenPanel(
            title: "Seleccionar intérprete Python",
            prompt: "Seleccionar",
            message: "Elige el ejecutable Python del entorno virtual (p. ej. .venv/bin/python)."
        )
        panel.allowedContentTypes = []  // sin restricción de tipo — permite binarios sin extensión
        panel.allowsOtherFileTypes = true

        if panel.runModal() == .OK, let url = panel.url {
            pythonPath = url.path
        }
    }

    /// Abre NSOpenPanel para elegir el script extractor_url.py.
    func pickScriptPath() {
        let panel = makeOpenPanel(
            title: "Seleccionar script extractor_url.py",
            prompt: "Seleccionar",
            message: "Elige el archivo extractor_url.py del proyecto."
        )
        // Filtrar por extensión .py
        if let pyType = UTType(filenameExtension: "py") {
            panel.allowedContentTypes = [pyType]
        }
        panel.allowsOtherFileTypes = true

        if panel.runModal() == .OK, let url = panel.url {
            scriptPath = url.path
        }
    }

    // MARK: - Helpers

    private func makeOpenPanel(title: String, prompt: String, message: String) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.title = title
        panel.prompt = prompt
        panel.message = message
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.showsHiddenFiles = true   // necesario para ver .venv/bin/python
        return panel
    }
}
