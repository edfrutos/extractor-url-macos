import Foundation

enum ExtractionError: Error, LocalizedError {
    case pythonNotFound(path: String)
    case processLaunchFailed(underlying: Error)
    case extractionFailed(message: String)
    case jsonDecodeFailed(underlying: Error)
    case emptyOutput

    var errorDescription: String? {
        switch self {
        case .pythonNotFound(let path):
            return "Intérprete Python no encontrado o sin permisos de ejecución: \(path)"
        case .processLaunchFailed(let error):
            return "No se pudo lanzar el proceso: \(error.localizedDescription)"
        case .extractionFailed(let message):
            return "El extractor Python devolvió un error: \(message)"
        case .jsonDecodeFailed(let error):
            return "Respuesta JSON inválida del CLI: \(error.localizedDescription)"
        case .emptyOutput:
            return "El proceso terminó sin producir salida."
        }
    }
}
