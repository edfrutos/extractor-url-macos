import Foundation

enum ExtractionError: Error, LocalizedError {
    case pythonNotFound(path: String)
    case processLaunchFailed(underlying: Error)
    case extractionFailed(message: String)
    case jsonDecodeFailed(underlying: Error)
    /// Sin salida en stdout; `detail` resume stderr si trae algo.
    case emptyOutput(detail: String?)
    /// El proceso no completó dentro del tiempo límite y fue terminado.
    case timeout

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
        case .emptyOutput(let detail):
            guard let detail else { return "El proceso terminó sin producir salida." }
            return "El proceso terminó sin producir salida.\nDetalle: \(detail)"
        case .timeout:
            return "La extracción superó el tiempo límite y fue cancelada."
        }
    }
}
