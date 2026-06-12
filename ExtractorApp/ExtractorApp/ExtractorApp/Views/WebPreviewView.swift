import SwiftUI
import WebKit

/// Preview del contenido extraído renderizado en un WKWebView (D-01).
/// JS habilitado por defecto — no se necesita WKWebViewConfiguration.
struct WebPreviewView: NSViewRepresentable {
    var htmlContent: String?
    @Binding var contentReady: Bool
    var viewModel: ExtractionViewModel  // Phase 6 (D-01): para registrar webViewProvider

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        // Phase 6 (D-01): registrar el proveedor en el ViewModel con capture weak del coordinator
        // para evitar ciclo de retención (A5 de RESEARCH.md)
        viewModel.webViewProvider = { [weak coordinator = context.coordinator] in
            coordinator?.webView
        }
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // PITFALL 1: updateNSView se invoca en cada re-render de SwiftUI
        // (incl. hovers); sin este guard el WebView recargaría en bucle.
        guard htmlContent != context.coordinator.lastLoadedHTML else { return }
        context.coordinator.lastLoadedHTML = htmlContent

        if let html = htmlContent {
            webView.loadHTMLString(html, baseURL: nil)  // origen about:blank
        } else {
            // D-04: nueva extracción → limpiar y resetear contentReady
            webView.loadHTMLString("", baseURL: nil)
            let coordinator = context.coordinator
            DispatchQueue.main.async { [weak coordinator] in
                coordinator?.parent.contentReady = false
            }
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebPreviewView
        weak var webView: WKWebView?
        var lastLoadedHTML: String?

        init(_ parent: WebPreviewView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // D-02/D-03: señaliza DOM renderizado. Para preview no hace
            // falta delay; Phase 6 (PDF) sí lo necesitará.
            DispatchQueue.main.async { [weak self] in
                self?.parent.contentReady = true
            }
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            print("[WebPreviewView] didFail: \(error.localizedDescription)")
        }
    }
}
