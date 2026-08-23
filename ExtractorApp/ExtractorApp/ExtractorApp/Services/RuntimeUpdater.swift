import CryptoKit
import Foundation

/// Actualiza las dependencias Python puras vendorizadas (Fase 21) sin
/// tocar el `.app` firmado — descarga a
/// `~/Library/Application Support/ExtractorApp/python-packages-override/<version>/`
/// y `PythonBridge` lo antepone al `PYTHONPATH` del bundle si existe y
/// pasó la verificación. Nunca modifica nada dentro de `Contents/Resources/`
/// (no rompe la firma de código del bundle) — ver `21-RESEARCH.md` para el
/// porqué del alcance (solo deps puras, nunca el intérprete/lxml/Chromium).
enum RuntimeUpdater {

    struct ManifestInfo: Decodable, Equatable {
        let version: String
        let downloadUrl: String
        let sha256: String

        enum CodingKeys: String, CodingKey {
            case version
            case downloadUrl = "download_url"
            case sha256
        }
    }

    enum UpdateError: LocalizedError {
        case manifestUnavailable
        case checksumMismatch
        case extractionFailed
        case verificationImportFailed

        var errorDescription: String? {
            switch self {
            case .manifestUnavailable:
                return "No se pudo comprobar si hay una actualización disponible."
            case .checksumMismatch:
                return "La descarga no coincide con el checksum esperado — descartada por seguridad."
            case .extractionFailed:
                return "No se pudo extraer el paquete de actualización."
            case .verificationImportFailed:
                return "La actualización se descargó pero no pasó la verificación — descartada, sigue activo el runtime anterior."
            }
        }
    }

    private static let manifestURL = URL(
        string: "https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/runtime-manifest.json"
    )!

    private static let activeVersionKey = "runtimeOverrideActiveVersion"

    /// Directorio raíz de todas las versiones de override descargadas.
    private static var overrideRootURL: URL {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ExtractorApp", isDirectory: true)
            .appendingPathComponent("python-packages-override", isDirectory: true)
    }

    /// Ruta activa (si hay una versión aplicada y su directorio sigue
    /// existiendo) — es lo que `PythonBridge` antepone al `PYTHONPATH`.
    /// Si el directorio desapareció (borrado a mano, disco externo, etc.)
    /// devuelve nil y `PythonBridge` cae automáticamente al bundle — sin
    /// necesitar lógica de rollback explícita (PYRUNTIME-02).
    static func activeOverridePath() -> String? {
        guard let version = UserDefaults.standard.string(forKey: activeVersionKey),
              !version.isEmpty else { return nil }
        let path = overrideRootURL.appendingPathComponent(version, isDirectory: true).path
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }

    /// Versión activa actualmente, o nil si se usa el runtime bundleado.
    static func activeVersion() -> String? {
        guard activeOverridePath() != nil else { return nil }
        return UserDefaults.standard.string(forKey: activeVersionKey)
    }

    /// Comprueba el manifiesto remoto y, si hay una versión más nueva que
    /// la activa, la descarga, verifica (checksum + import real contra el
    /// intérprete bundleado) y la aplica. Devuelve la versión aplicada, o
    /// nil si ya estaba al día. Si cualquier paso falla, la versión activa
    /// NO cambia — nunca deja el override a medias (PYRUNTIME-02).
    static func checkAndApplyUpdate() async throws -> String? {
        let manifest = try await fetchManifest()
        if manifest.version == activeVersion() {
            return nil
        }

        let zipURL = try await download(manifest: manifest)
        defer { try? FileManager.default.removeItem(at: zipURL) }
        try verifyChecksum(fileURL: zipURL, expected: manifest.sha256)

        let destination = overrideRootURL.appendingPathComponent(manifest.version, isDirectory: true)
        try extract(zipURL: zipURL, to: destination)

        guard verifyImportable(overridePath: destination.path) else {
            try? FileManager.default.removeItem(at: destination)
            throw UpdateError.verificationImportFailed
        }

        UserDefaults.standard.set(manifest.version, forKey: activeVersionKey)
        pruneOldVersions(keeping: manifest.version)
        return manifest.version
    }

    // MARK: - Steps

    private static func fetchManifest() async throws -> ManifestInfo {
        do {
            let (data, _) = try await URLSession.shared.data(from: manifestURL)
            return try JSONDecoder().decode(ManifestInfo.self, from: data)
        } catch {
            throw UpdateError.manifestUnavailable
        }
    }

    private static func download(manifest: ManifestInfo) async throws -> URL {
        guard let url = URL(string: manifest.downloadUrl) else {
            throw UpdateError.manifestUnavailable
        }
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        // download(from:) deja el archivo en una ubicación temporal que el
        // sistema puede purgar en cualquier momento — se mueve a un nombre
        // estable propio antes de que termine este método.
        let stableURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".zip")
        try FileManager.default.moveItem(at: tempURL, to: stableURL)
        return stableURL
    }

    private static func verifyChecksum(fileURL: URL, expected: String) throws {
        let data = try Data(contentsOf: fileURL)
        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        guard hex == expected.lowercased() else {
            throw UpdateError.checksumMismatch
        }
    }

    /// Extrae vía `/usr/bin/unzip` invocado directamente (no Archive
    /// Utility/Finder) a un directorio temporal, y solo lo mueve al
    /// destino final si `unzip` termina con éxito — nunca deja un
    /// override a medio extraer que `PythonBridge` pudiera recoger.
    private static func extract(zipURL: URL, to destination: URL) throws {
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let tempDest = destination.appendingPathExtension("tmp-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDest, withIntermediateDirectories: true)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-q", zipURL.path, "-d", tempDest.path]
        do {
            try process.run()
        } catch {
            try? FileManager.default.removeItem(at: tempDest)
            throw UpdateError.extractionFailed
        }
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            try? FileManager.default.removeItem(at: tempDest)
            throw UpdateError.extractionFailed
        }

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.moveItem(at: tempDest, to: destination)
    }

    /// Verificación funcional real (no solo checksum): lanza el intérprete
    /// YA bundleado, firmado y notarizado (nunca uno nuevo) con el
    /// override antepuesto al PYTHONPATH, e intenta importar los 4
    /// paquetes actualizados. Si falla, la actualización se descarta antes
    /// de tocar la versión activa.
    private static func verifyImportable(overridePath: String) -> Bool {
        guard let python = PythonBridge.bundledPythonPath(),
              let bundledLib = PythonBridge.bundledVendoredLibPath() else { return false }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: python)
        process.arguments = ["-c", "import requests, bs4, markdownify, trafilatura"]
        var env = ProcessInfo.processInfo.environment
        env["PYTHONPATH"] = overridePath + ":" + bundledLib
        process.environment = env
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return false
        }
        process.waitUntilExit()
        return process.terminationStatus == 0
    }

    /// Borra versiones de override antiguas tras aplicar una nueva —
    /// evita acumular descargas indefinidamente en Application Support.
    private static func pruneOldVersions(keeping activeVersion: String) {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: overrideRootURL.path) else { return }
        for entry in entries where entry != activeVersion {
            try? fm.removeItem(atPath: overrideRootURL.appendingPathComponent(entry).path)
        }
    }
}
