import Foundation
import WebKit

/// Renderiza una página con JavaScript en un `WKWebView` fuera de pantalla
/// y devuelve el HTML resultante (Fase 26).
///
/// La variante App Store no puede llevar Chromium/Playwright (sandbox y
/// tamaño): cuando la CLI responde `js_render_needed`, la app renderiza aquí
/// y vuelve a pasar el HTML a Python con `--file` y `--base-url`. Quién
/// decide si hace falta renderizar sigue siendo solo la heurística de
/// `core.py`.
///
/// WebKit no expone un equivalente a `networkidle` de Playwright: tras
/// `didFinish` se sondea el texto visible hasta que hay contenido y deja de
/// crecer, o hasta agotar el plazo.
@MainActor
final class WebRenderer: NSObject, WKNavigationDelegate {

    struct Page {
        let html: String
        let finalURL: URL
    }

    enum RenderError: LocalizedError {
        case httpStatus(Int)
        case navigation(Error)
        case timeout
        case emptyDocument
        #if DEBUG
        /// `-webRendererForceFailure YES` en los argumentos del esquema
        /// (checkpoint de la Fase 26: probar la degradación).
        case forcedForTesting
        #endif

        var errorDescription: String? {
            switch self {
            case .httpStatus(let code):
                return "El servidor respondió con HTTP \(code)."
            case .navigation(let error):
                return "La página no se pudo cargar: \(error.localizedDescription)"
            case .timeout:
                return "La página no terminó de cargar en el tiempo límite."
            case .emptyDocument:
                return "La página renderizada está vacía."
            #if DEBUG
            case .forcedForTesting:
                return "Fallo forzado para pruebas (webRendererForceFailure)."
            #endif
            }
        }
    }

    /// Texto visible mínimo para dar la página por hidratada; el mismo umbral
    /// que `_MIN_VISIBLE_TEXT_LENGTH` en `core.py`.
    private static let minVisibleTextLength = 100
    private static let pollIntervalNanoseconds: UInt64 = 500_000_000

    private var webView: WKWebView?
    private var statusCode: Int?
    private var loadContinuation: CheckedContinuation<Void, Error>?

    /// Carga `url`, espera a que el JavaScript pinte el contenido y devuelve
    /// `document.documentElement.outerHTML`. `timeout` es el plazo total.
    func render(url: URL, timeout: TimeInterval) async throws -> Page {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "webRendererForceFailure") {
            throw RenderError.forcedForTesting
        }
        #endif

        // Sin cookies ni caché compartidas con el resto de la app.
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: 1280, height: 800),
            configuration: configuration
        )
        webView.navigationDelegate = self
        self.webView = webView
        defer {
            webView.stopLoading()
            webView.navigationDelegate = nil
            self.webView = nil
        }

        let deadline = Date().addingTimeInterval(timeout)
        try await load(URLRequest(url: url, timeoutInterval: timeout), until: deadline)
        // Igual que _render_page() con Playwright: una página de error no es
        // el contenido de la web.
        if let statusCode, statusCode >= 400 {
            throw RenderError.httpStatus(statusCode)
        }
        await waitForContent(in: webView, until: deadline)

        let outerHTML = try await webView.evaluateJavaScript(
            "document.documentElement.outerHTML"
        ) as? String
        guard let html = outerHTML, !html.isEmpty else { throw RenderError.emptyDocument }
        return Page(html: html, finalURL: webView.url ?? url)
    }

    // MARK: - Carga

    private func load(_ request: URLRequest, until deadline: Date) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            loadContinuation = continuation
            webView?.load(request)
            let delay = max(0, deadline.timeIntervalSinceNow)
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                self?.finishLoad(.failure(RenderError.timeout))
            }
        }
    }

    /// Reanuda la espera de la carga una sola vez (lo que llegue antes:
    /// `didFinish`, un fallo o el plazo).
    private func finishLoad(_ result: Result<Void, Error>) {
        guard let continuation = loadContinuation else { return }
        loadContinuation = nil
        continuation.resume(with: result)
    }

    /// Sondea el texto visible hasta que hay contenido y deja de crecer. Al
    /// agotar el plazo vuelve igualmente: lo que haya pintado ya suele ser
    /// mejor que el HTML estático.
    private func waitForContent(in webView: WKWebView, until deadline: Date) async {
        var previousLength = -1
        while Date() < deadline {
            let value = try? await webView.evaluateJavaScript(
                "document.body ? document.body.innerText.length : 0"
            )
            let length = (value as? Int) ?? 0
            if length >= Self.minVisibleTextLength && length == previousLength {
                return
            }
            previousLength = length
            try? await Task.sleep(nanoseconds: Self.pollIntervalNanoseconds)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse
    ) async -> WKNavigationResponsePolicy {
        if navigationResponse.isForMainFrame,
           let response = navigationResponse.response as? HTTPURLResponse {
            statusCode = response.statusCode
        }
        return .allow
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishLoad(.success(()))
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        finishLoad(.failure(RenderError.navigation(error)))
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        finishLoad(.failure(RenderError.navigation(error)))
    }
}
