import XCTest
@testable import ExtractorApp

// MARK: - SettingsViewModelTests
//
// Valida la lógica de validación de rutas y persistencia de SettingsViewModel.
// NSOpenPanel no se puede testear en unit tests (requiere UI real) — se marca
// como "Manual Only" según la política del proyecto.
//
// Los tests de validación usan rutas del sistema conocidas (existentes y
// ejecutables en macOS) sin depender de recursos de red externos.

@MainActor
final class SettingsViewModelTests: XCTestCase {

    // MARK: - PathValidationState: pythonPath

    func testPythonPathEmpty_stateIsEmpty() {
        let vm = SettingsViewModel()
        vm.pythonPath = ""
        XCTAssertEqual(vm.pythonValidation, .empty)
    }

    func testPythonPathNotFound_stateIsNotFound() {
        let vm = SettingsViewModel()
        vm.pythonPath = "/ruta/que/no/existe/python"
        XCTAssertEqual(vm.pythonValidation, .notFound)
    }

    func testPythonPathExists_notExecutable_stateIsNotExecutable() throws {
        // Usamos un archivo conocido del sistema que NO es ejecutable
        // (p. ej. /etc/hosts — existe, pero no tiene bit de ejecución)
        let vm = SettingsViewModel()
        vm.pythonPath = "/etc/hosts"
        // /etc/hosts existe y no es ejecutable en macOS estándar
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: "/etc/hosts")
        let executable = fm.isExecutableFile(atPath: "/etc/hosts")
        guard exists && !executable else {
            throw XCTSkip("/etc/hosts no cumple precondición en este sistema")
        }
        XCTAssertEqual(vm.pythonValidation, .notExecutable)
    }

    func testPythonPathExecutable_stateIsValid() throws {
        // /bin/sh existe y es ejecutable en cualquier macOS
        let vm = SettingsViewModel()
        vm.pythonPath = "/bin/sh"
        let fm = FileManager.default
        guard fm.isExecutableFile(atPath: "/bin/sh") else {
            throw XCTSkip("/bin/sh no es ejecutable en este sistema")
        }
        XCTAssertEqual(vm.pythonValidation, .valid)
    }

    // MARK: - PathValidationState: scriptPath

    func testScriptPathEmpty_stateIsEmpty() {
        let vm = SettingsViewModel()
        vm.scriptPath = ""
        XCTAssertEqual(vm.scriptValidation, .empty)
    }

    func testScriptPathNotFound_stateIsNotFound() {
        let vm = SettingsViewModel()
        vm.scriptPath = "/ruta/que/no/existe/extractor_url.py"
        XCTAssertEqual(vm.scriptValidation, .notFound)
    }

    func testScriptPathExists_stateIsValid() throws {
        // Creamos un archivo temporal para simular un script .py existente
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_script_\(UUID().uuidString).py")
        try "# test".write(to: tmp, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let vm = SettingsViewModel()
        vm.scriptPath = tmp.path
        XCTAssertEqual(vm.scriptValidation, .valid,
            "Un archivo .py existente debe ser válido (no se exige bit de ejecución)")
    }

    // MARK: - Reactive validation (didSet)

    func testPythonPath_changesRevalidateAutomatically() {
        let vm = SettingsViewModel()

        vm.pythonPath = ""
        XCTAssertEqual(vm.pythonValidation, .empty, "vacío → .empty")

        vm.pythonPath = "/ruta/fantasma"
        XCTAssertEqual(vm.pythonValidation, .notFound, "ruta inexistente → .notFound")

        vm.pythonPath = "/bin/sh"
        XCTAssertEqual(vm.pythonValidation, .valid, "binario del sistema → .valid")
    }

    func testScriptPath_changesRevalidateAutomatically() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("reactivo_\(UUID().uuidString).py")
        try "# reactivo".write(to: tmp, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let vm = SettingsViewModel()

        vm.scriptPath = ""
        XCTAssertEqual(vm.scriptValidation, .empty)

        vm.scriptPath = "/no/existe"
        XCTAssertEqual(vm.scriptValidation, .notFound)

        vm.scriptPath = tmp.path
        XCTAssertEqual(vm.scriptValidation, .valid)
    }

    // MARK: - validatePythonPath / validateScriptPath (llamada explícita)

    func testExplicitValidationCallsProduceSameResult() {
        let vm = SettingsViewModel()
        vm.pythonPath = "/bin/ls"
        // didSet ya validó, pero una llamada explícita no debe cambiar el resultado
        let before = vm.pythonValidation
        vm.validatePythonPath()
        XCTAssertEqual(vm.pythonValidation, before)
    }

    // MARK: - PathValidationState helpers

    func testValidationStateSystemImageNames() {
        XCTAssertEqual(PathValidationState.empty.systemImageName, "minus.circle")
        XCTAssertEqual(PathValidationState.valid.systemImageName, "checkmark.circle.fill")
        XCTAssertEqual(PathValidationState.notFound.systemImageName, "xmark.circle.fill")
        XCTAssertEqual(PathValidationState.notExecutable.systemImageName,
                       "exclamationmark.triangle.fill")
    }

    func testValidationStateHelpText() {
        XCTAssertNil(PathValidationState.empty.helpText)
        XCTAssertNil(PathValidationState.valid.helpText)
        XCTAssertNotNil(PathValidationState.notFound.helpText)
        XCTAssertNotNil(PathValidationState.notExecutable.helpText)
    }

    // MARK: - @AppStorage persistence (UserDefaults round-trip)

    func testPythonPathPersistsInUserDefaults() {
        // UserDefaults es compartido entre el app y los tests (@testable import)
        let testPath = "/usr/bin/python3_test_\(UUID().uuidString)"
        UserDefaults.standard.set(testPath, forKey: "pythonPath")
        defer { UserDefaults.standard.removeObject(forKey: "pythonPath") }

        let vm = SettingsViewModel()
        // @AppStorage lee de UserDefaults en init — el valor debe coincidir
        XCTAssertEqual(vm.pythonPath, testPath)
    }

    func testScriptPathPersistsInUserDefaults() {
        let testPath = "/tmp/extractor_url_test_\(UUID().uuidString).py"
        UserDefaults.standard.set(testPath, forKey: "scriptPath")
        defer { UserDefaults.standard.removeObject(forKey: "scriptPath") }

        let vm = SettingsViewModel()
        XCTAssertEqual(vm.scriptPath, testPath)
    }
}
