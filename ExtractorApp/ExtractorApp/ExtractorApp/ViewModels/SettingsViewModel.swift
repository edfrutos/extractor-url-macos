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

// MARK: - Python Operating Mode (Fase 10: UX Zero-Config)

/// Modo de resolución de rutas activo, reflejando `PythonBridge.resolvedPaths()`.
enum PythonOperatingMode: Equatable {
    /// Usando el intérprete embebido en el bundle. `version` llega async
    /// (requiere lanzar `--version` en background) y es nil hasta resolverse.
    case bundle(version: String?)
    /// Usando el override manual configurado en Preferencias (compatibilidad v2.0).
    case override
    /// Ni el override de UserDefaults ni el bundle tienen rutas válidas.
    case unavailable
}

// MARK: - Runtime Update State (Fase 21)

/// Estado de la comprobación/aplicación de una actualización de runtime
/// (dependencias Python puras — ver `RuntimeUpdater`/`21-RESEARCH.md`).
enum RuntimeUpdateState: Equatable {
    case idle
    case checking
    case upToDate
    case updated(version: String)
    case failed(message: String)
}

// MARK: - SettingsViewModel

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: @AppStorage — persiste automáticamente en UserDefaults

    @AppStorage("pythonPath") var pythonPath: String = "" {
        didSet {
            validatePythonPath()
            refreshOperatingMode()
        }
    }

    @AppStorage("scriptPath") var scriptPath: String = "" {
        didSet {
            validateScriptPath()
            refreshOperatingMode()
        }
    }

    /// Opt-in a actualizaciones del canal beta de Sparkle (Fase 16).
    /// Leído directamente por `ExtractorUpdaterDelegate.allowedChannels(for:)`
    /// — no necesita refrescar nada al cambiar, Sparkle lo consulta en la
    /// siguiente comprobación (automática o manual).
    @AppStorage("betaChannelOptIn") var betaChannelOptIn: Bool = false

    // MARK: Validation state (@Published para reactividad en View)

    @Published private(set) var pythonValidation: PathValidationState = .empty
    @Published private(set) var scriptValidation: PathValidationState = .empty

    // MARK: Operating mode (@Published — badge en SettingsView)

    @Published private(set) var operatingMode: PythonOperatingMode = .unavailable

    // MARK: Runtime update (Fase 21 — @Published para reactividad en View)

    @Published private(set) var runtimeUpdateState: RuntimeUpdateState = .idle

    /// Versión de override activa, o nil si se usa el runtime bundleado.
    var activeRuntimeVersion: String? { RuntimeUpdater.activeVersion() }

    /// `true` cuando la app opera con el Python embebido (flujo zero-config por defecto).
    var isBundleMode: Bool {
        if case .bundle = operatingMode { return true }
        return false
    }

    private let bridge = PythonBridge()

    // MARK: Init

    init() {
        // Validar estado inicial (puede haber rutas ya guardadas)
        validatePythonPath()
        validateScriptPath()
        refreshOperatingMode()
    }

    // MARK: - Operating Mode

    /// Recalcula `operatingMode` reutilizando la misma lógica de resolución
    /// de rutas que usa `PythonBridge.run()`, para que el badge de Preferencias
    /// refleje siempre el modo realmente activo (BRIDGE-05/06/07, UX-02, UX-03).
    private func refreshOperatingMode() {
        guard let paths = bridge.resolvedPaths() else {
            operatingMode = .unavailable
            return
        }

        switch paths.source {
        case .userDefaults:
            operatingMode = .override

        case .bundle:
            operatingMode = .bundle(version: nil)
            // --version es un subprocess bloqueante — Task.detached lo saca
            // del MainActor (refreshOperatingMode ya corre en él); solo se
            // aplica el resultado si seguimos en modo bundle.
            Task.detached { [weak self] in
                let version = PythonBridge.bundledPythonVersion()
                await MainActor.run {
                    guard let self, case .bundle = self.operatingMode else { return }
                    self.operatingMode = .bundle(version: version)
                }
            }
        }
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

    // MARK: - Runtime Update (Fase 21)

    /// Comprueba el manifiesto remoto y aplica una actualización de
    /// dependencias puras si hay una disponible. Solo tiene efecto real
    /// en modo bundle (ver `RuntimeUpdater` — el override se antepone al
    /// PYTHONPATH del bundle, no aplica en modo override manual).
    func checkForRuntimeUpdate() {
        runtimeUpdateState = .checking
        // Task.detached (no Task {}) — mismo motivo que refreshOperatingMode():
        // RuntimeUpdater.checkAndApplyUpdate() incluye trabajo síncrono
        // bloqueante (Process().run()/waitUntilExit() en extract()/
        // verifyImportable()) que no debe ejecutarse en el MainActor pese
        // a que la función es async (bug real encontrado en el checkpoint
        // humano de la Fase 10 con un patrón equivalente).
        Task.detached { [weak self] in
            do {
                let applied = try await RuntimeUpdater.checkAndApplyUpdate()
                await MainActor.run {
                    guard let self else { return }
                    if let applied {
                        self.runtimeUpdateState = .updated(version: applied)
                    } else {
                        self.runtimeUpdateState = .upToDate
                    }
                }
            } catch {
                await MainActor.run {
                    guard let self else { return }
                    self.runtimeUpdateState = .failed(message: error.localizedDescription)
                }
            }
        }
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
