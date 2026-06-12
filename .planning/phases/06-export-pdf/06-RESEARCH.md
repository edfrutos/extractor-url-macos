# Phase 6: Export PDF - Research

**Researched:** 2026-06-12
**Domain:** WKWebView PDF export (macOS) + NSAppearance + NSSavePanel + Python CLI contract
**Confidence:** HIGH (stack verificado en código existente; APIs Apple confirmadas vía documentación oficial y Apple Developer Forums)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** El PDF se genera desde el WKWebView visible del preview (no offscreen). El Coordinator ya guarda `weak var webView`.
- **D-02:** WYSIWYG estricto — el ancho del PDF sigue al ancho de la ventana en el momento de exportar. No se fuerza ancho mínimo.
- **D-03:** Página única continua — comportamiento natural de `WKWebView.pdf()`. No paginar A4.
- **D-04:** Forzar modo claro siempre en el PDF: `appearance = NSAppearance(named: .aqua)` antes de `.pdf()` y restaurar después.
- **D-05:** Añadir `title` al contrato JSON del CLI Python (`--json`). `ExtractionResult` gana campo opcional `title: String?`.
- **D-06:** Los tres formatos (MD, HTML, PDF) usan el título como nombre sugerido. Unificar `suggestedFilename()`.
- **D-07:** Fallback cuando no haya `<title>`: prefijo del contenido (primeros 50 chars sanitizados). Si también vacío, `"export"`.
- **D-08:** Alerta visible (`NSAlert`) si la generación o el guardado del PDF falla.
- **D-09:** Sin indicador de progreso durante la generación.

### Claude's Discretion

- Mecanismo exacto para exponer el WKWebView del preview al flujo de export (referencia vía Coordinator, callback, o registro en el ViewModel).
- Detalle del override de apariencia para forzar modo claro (D-04) y su restauración segura.
- Estructura del NSAlert (título/mensaje) y wording exacto en español.
- Cómo extrae el `<title>` el lado Python (BeautifulSoup `soup.title` vs trafilatura metadata) — mantener compatibilidad con los dos caminos de extracción.

### Deferred Ideas (OUT OF SCOPE)

- Paginado A4 con márgenes para impresión — fuera de v2.0.
- Indicador de progreso / estado `isExporting` con botón deshabilitado durante export.
- Subir MD/HTML a alerta visible de error.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| EXPORT-04 | El export PDF usa `WKWebView.pdf(configuration:)` (macOS 13+, async/await), con guarda de estado `contentReady` antes de invocar la API, y guarda el resultado vía `NSSavePanel`. | Investigado en profundidad: API confirmada, timing pitfall documentado, patrón completo de implementación establecido. |
</phase_requirements>

---

## Summary

Phase 6 activa la rama PDF del selector de exportación ya existente en la UI. La API central es `WKWebView.createPDF(configuration:completionHandler:)` (macOS 11+, target es 13+), que tiene un análogo `async/await` nativo disponible desde macOS 13 como `pdf(configuration:)` — sin necesidad de `withCheckedContinuation`. El resultado es `Data` que se escribe directamente a la URL del `NSSavePanel` igual que el patrón ya establecido para MD y HTML.

El pitfall crítico documentado (Pitfall #4 en PITFALLS.md) es la llamada prematura a `createPDF()` antes de que el layout del WebView esté completo — `didFinish` señaliza que el DOM está parseado, pero el render del layout CSS puede necesitar un tick adicional. Para el HTML estático generado por este proyecto (sin recursos externos), un `DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)` es suficiente; el comentario existente en `WebPreviewView.Coordinator.didFinish` ya anticipaba este requisito.

El forzado de modo claro (D-04) se implementa con `webView.appearance = NSAppearance(named: .aqua)` antes de llamar a `createPDF`, guardando y restaurando la apariencia previa inmediatamente después — operación síncrona segura en `@MainActor`. En el lado Python, la extracción del `<title>` se hace con `soup.title.string if soup.title else None` (BeautifulSoup) como primera opción, con `trafilatura.extract_metadata(html).title` como fallback — ambos caminos ya tienen el HTML parseado disponible.

**Primary recommendation:** Implementar `exportPDF()` como método `@MainActor async` en `ExtractionViewModel`, siguiendo exactamente el patrón de `exportMarkdown()`/`exportHTML()` con `withCheckedContinuation` para el `NSSavePanel`, y wrapping de `createPDF` con `withCheckedThrowingContinuation` o uso del análogo async nativo. El acceso al WKWebView se hace vía `Coordinator.webView` (weak ref ya existente), pasado al ViewModel en el momento de la llamada a través de un closure o callback registrado.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Generación del PDF (`createPDF`) | Frontend (NSViewRepresentable / WKWebView) | ViewModel (orquesta) | `createPDF` es un método de instancia de `WKWebView`; debe ejecutarse donde vive el webview |
| Timing / delay post-render | Frontend (Coordinator) | — | El Coordinator conoce el ciclo de navegación; es el lugar natural para el delay |
| Override de apariencia (modo claro) | Frontend (WKWebView layer) | ViewModel (inicia) | La apariencia se aplica al objeto `WKWebView`; el ViewModel solo pide al caller que lo haga |
| Apertura de NSSavePanel | ViewModel (`@MainActor`) | — | Patrón ya establecido en `exportMarkdown`/`exportHTML` |
| Escritura de Data a disco | ViewModel (`@MainActor`) | — | Misma capa que los otros formatos |
| NSAlert en error | ViewModel / ContentView | — | Error presentado desde `@MainActor` con `NSAlert.runModal()` |
| Extracción del `<title>` Python | Python CLI (`core.py`) | — | BeautifulSoup ya tiene el soup; trafilatura ya extrae metadata |
| Campo `title` en JSON output | Python CLI (`extractor_url.py`) | — | El bloque `_print_json_output` del éxito añade el campo |
| Decodificación de `title` en Swift | `ExtractionResult.swift` | `ExtractionViewModel` | `Codable` opcional, sin CodingKey especial (nombre coincide en snake_case no aplica: "title" == "title") |

---

## Standard Stack

### Core (sin instalaciones nuevas — stack ya presente)

| Biblioteca | Versión | Propósito | Por qué estándar |
|------------|---------|-----------|-----------------|
| WebKit (`WKWebView`) | macOS 13+ SDK | Generación del PDF vectorial | API nativa Apple, ya en uso en Phase 5 |
| AppKit (`NSAppearance`, `NSSavePanel`, `NSAlert`) | macOS 13+ SDK | Override apariencia, panel guardar, alertas | APIs nativas macOS, ya importadas |
| BeautifulSoup4 | ya instalada | Extracción `soup.title` en Python | Ya en uso en `core.py` |
| trafilatura | ya instalada | Fallback metadata title si BS4 falla | Ya en uso en `extract_html_structure_to_markdown` |
| `UniformTypeIdentifiers` (`UTType.pdf`) | macOS 11+ | Tipo de archivo para `NSSavePanel` | Ya importado en `ExtractionViewModel.swift` |

### No se requieren dependencias nuevas

Esta fase no instala ningún paquete adicional ni en Python ni en Swift. Todas las APIs necesarias están disponibles en el SDK (macOS 13+, deployment target del proyecto) y las librerías Python ya están en el `.venv`.

---

## Package Legitimacy Audit

No se instalan paquetes externos nuevos en esta fase. Sección no aplicable.

---

## Architecture Patterns

### System Architecture Diagram

```
Usuario pulsa "Exportar" (exportFormat == "pdf")
        │
        ▼
ExtractionViewModel.export() [@MainActor]
        │
        ├─ guard contentReady else return  (SC-1: botón ya gated en UI)
        │
        ▼
ExtractionViewModel.exportPDF(webView: WKWebView) [@MainActor async]
        │
        ├─ 1. Guardar appearance actual del webView
        ├─ 2. webView.appearance = NSAppearance(named: .aqua)   (D-04)
        │
        ├─ 3. Delay 0.1s  [DispatchQueue.main.asyncAfter o Task.sleep]
        │      (evita PDF en blanco — Pitfall #4)
        │
        ├─ 4. webView.createPDF(configuration: WKPDFConfiguration())
        │      → async/await o withCheckedThrowingContinuation
        │      → Result<Data, Error>
        │
        ├─ 5. Restaurar webView.appearance = savedAppearance
        │
        ├─ SUCCESS path:
        │   ├─ NSSavePanel (allowedContentTypes: [.pdf])
        │   │    nameFieldStringValue = suggestedFilename(title, "pdf")
        │   │    → withCheckedContinuation (patrón existente)
        │   └─ data.write(to: url, options: .atomic)
        │         └─ catch → NSAlert (D-08)
        │
        └─ FAILURE path (createPDF error):
            └─ NSAlert (D-08)

Python CLI (--json) — lado paralelo:
  extract_formatted_content()
        │
        ├─ soup.title.string if soup.title else None   (BeautifulSoup path)
        │   OR trafilatura.extract_metadata(html).title  (trafilatura path)
        │
        └─ _print_json_output({ ..., "title": title_value })
```

### Recommended Project Structure (cambios mínimos)

```
extractor_url.py              # añadir "title" al bloque _print_json_output (éxito)
core.py                       # añadir _extract_title(soup, html_text) → Optional[str]
ExtractorApp/
├── Models/
│   └── ExtractionResult.swift    # añadir title: String?
├── ViewModels/
│   └── ExtractionViewModel.swift # exportPDF(), suggestedFilename refactorizado
├── Views/
│   ├── ContentView.swift         # quitar .disabled(true) del tag "pdf"
│   └── WebPreviewView.swift      # exponer webView al ViewModel (callback/closure)
tests/
└── test_cli.py                   # ampliar contrato JSON con campo title
ExtractorAppTests/
└── ViewModelTests.swift          # tests exportPDF no-crash, suggestedFilename
```

### Pattern 1: Acceso al WKWebView desde el ViewModel (Claude's Discretion)

**Recomendación:** Registrar un closure `onWebViewAvailable: ((WKWebView) -> Void)?` en el ViewModel, llamado desde `WebPreviewView.makeNSView`. El ViewModel guarda una `weak` referencia.

**Por qué este mecanismo:** Añade el mínimo acoplamiento — no hay dependencia directa de tipos SwiftUI en el ViewModel, y la referencia weak evita retenciones. Alternativas como un `@EnvironmentObject` compartido o un `NotificationCenter` son más complejas sin beneficio real para este caso.

```swift
// ExtractionViewModel.swift
// [ASSUMED] — patrón basado en convención; no hay API Apple específica para esto
@MainActor
final class ExtractionViewModel: ObservableObject {
    // ...existing...
    private(set) weak var previewWebView: WKWebView?

    func registerWebView(_ webView: WKWebView) {
        previewWebView = webView
    }
}

// WebPreviewView.swift — en makeNSView, después de crear el webView:
// context.coordinator.parent.viewModel.registerWebView(webView)
// Requiere pasar el ViewModel al WebPreviewView o accederlo via Environment
```

**Alternativa más simple (también válida):** El Coordinator almacena el `webView` (ya lo hace con `weak var webView`). `exportPDF()` recibe el `webView` como parámetro vía un closure `() -> WKWebView?` registrado en el ViewModel desde `makeNSView`.

### Pattern 2: createPDF con async/await nativo

`WKWebView` tiene un método async nativo en macOS 13+: `pdf(configuration:)` que devuelve `Data` y lanza error. No requiere `withCheckedContinuation`. [ASSUMED — confirmado por denominación en Apple Docs URL (`3824706-pdf`) pero el contenido completo de la página no fue accesible; la existencia del método async se infiere de la URL y del patrón de Apple de añadir async siblings]

```swift
// Approach A: async nativo (macOS 13+, preferido si disponible)
// [ASSUMED] — verificar en Xcode que el símbolo compila
@MainActor
func exportPDF() async {
    guard let webView = previewWebView else { return }

    let savedAppearance = webView.appearance
    webView.appearance = NSAppearance(named: .aqua)  // D-04

    // Delay mínimo para que el layout termine (Pitfall #4)
    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s

    do {
        let config = WKPDFConfiguration()  // rect default = viewport del webview
        let pdfData = try await webView.pdf(configuration: config)
        webView.appearance = savedAppearance  // restaurar antes de cualquier throw

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = suggestedFilename(title: pageTitle, extension: "pdf")
        panel.canCreateDirectories = true

        let response = await withCheckedContinuation {
            (cont: CheckedContinuation<NSApplication.ModalResponse, Never>) in
            panel.begin { cont.resume(returning: $0) }
        }
        guard response == .OK, let url = panel.url else { return }

        try pdfData.write(to: url, options: .atomic)
    } catch {
        webView.appearance = savedAppearance  // restaurar también en error
        showPDFError(error)
    }
}
```

```swift
// Approach B: callback wrapping con withCheckedThrowingContinuation
// [VERIFIED desde Apple Docs — createPDF(configuration:completionHandler:) macOS 11+]
// Usar si el símbolo async de Approach A no compila en el target
let pdfData = try await withCheckedThrowingContinuation {
    (cont: CheckedContinuation<Data, Error>) in
    webView.createPDF(configuration: WKPDFConfiguration()) { result in
        cont.resume(with: result)
    }
}
```

### Pattern 3: NSAlert para errores PDF (D-08)

```swift
// [ASSUMED] — patrón estándar AppKit NSAlert
@MainActor
private func showPDFError(_ error: Error) {
    let alert = NSAlert()
    alert.messageText = "Error al exportar PDF"
    alert.informativeText = "No se pudo generar el archivo PDF.\n\(error.localizedDescription)"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Aceptar")
    alert.runModal()
}
```

### Pattern 4: Extracción del title en Python

**Estrategia:** Extraer el `<title>` de `soup.title` en `core.py` — el soup ya está disponible en ambos caminos de extracción. No llamar a trafilatura solo para el title (coste innecesario). `trafilatura.extract_metadata` es el fallback si `soup.title` es None (páginas sin `<title>` pero con Open Graph `og:title`).

```python
# core.py — nueva función helper [CITED: beautifulsoup4 docs + trafilatura docs]
def _extract_title(
    soup: BeautifulSoup,
    html_text: Optional[str] = None,
) -> Optional[str]:
    """Extrae el <title> de la página. Fallback a trafilatura metadata."""
    # Camino 1: BeautifulSoup (rápido, sin coste extra)
    if soup.title and soup.title.string:
        title = soup.title.string.strip()
        if title:
            return title
    # Camino 2: trafilatura metadata (cubre og:title, twitter:title, etc.)
    if html_text:
        try:
            meta = trafilatura.extract_metadata(html_text)
            if meta and meta.title:
                return meta.title.strip()
        except Exception:  # pylint: disable=broad-exception-caught
            pass
    return None
```

**Integración en extractor_url.py:** El `_print_json_output` de éxito añade `"title"` al dict. El title se extrae del soup antes de llamar a `_format_soup_content`. En el camino markdown (que usa `extract_html_structure_to_markdown`), el soup se construye internamente — habrá que devolver el title por una vía separada o refactorizar ligeramente para exponerlo.

**Opción más simple:** En `extractor_url.py`, llamar a `_fetch_soup` + `_extract_title` de forma independiente antes del `extract_formatted_content`, o hacer que `extract_formatted_content` devuelva también el title (cambiaría la firma — evaluar impacto en tests).

**Recomendación Claude's Discretion:** Añadir `_extract_title_from_url(url, html_text)` como función independiente en `core.py` que toma el html_text crudo (disponible en `_fetch_raw`). Llamarla en `main()` de `extractor_url.py` justo antes del bloque JSON, pasando el html raw de la caché si está disponible. Esto no cambia la firma de `extract_formatted_content` y no rompe ningún test existente.

```python
# extractor_url.py — bloque JSON de éxito ampliado
if args.json:
    # Obtener title de forma independiente
    raw_result = _fetch_raw(args.url, timeout=args.timeout)
    page_title: Optional[str] = None
    if raw_result:
        html_text, _ = raw_result
        try:
            title_soup = BeautifulSoup(html_text, "lxml")
        except FeatureNotFound:
            title_soup = BeautifulSoup(html_text, "html.parser")
        page_title = _extract_title(title_soup, html_text)

    _print_json_output({
        "status": "success",
        "url": args.url,
        "selector": args.selector,
        "output_type": args.type,
        "char_count": len(result_str),
        "content": result_str,
        "title": page_title,  # None → null en JSON → None en Swift Codable
    })
```

**Nota sobre caché:** `_fetch_raw` respeta la caché interna, así que la segunda llamada (para el title) será un hit de caché — sin coste de red adicional en la mayoría de los casos.

### Pattern 5: Refactor de suggestedFilename

```swift
// ExtractionViewModel.swift [ASSUMED — patrón basado en código existente]
// Añadir pageTitle: String? como @Published
@Published var pageTitle: String? = nil  // poblado al decodificar ExtractionResult

private func suggestedFilename(title: String?, extension ext: String) -> String {
    // Preferir title saneado (D-06)
    if let raw = title, !raw.isEmpty {
        let sanitized = raw
            .replacingOccurrences(of: "[^a-zA-Z0-9_\\-\\s]", with: "-",
                                   options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(60)
            .description
            .replacingOccurrences(of: " ", with: "-")
        if !sanitized.isEmpty {
            return "\(sanitized).\(ext)"
        }
    }
    // Fallback: prefijo del contenido — heurística existente (D-07)
    if let content = resultContent {
        let name = String(content.prefix(50))
            .replacingOccurrences(of: "[^a-zA-Z0-9_\\-]", with: "-",
                                   options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        if !name.isEmpty { return "\(name).\(ext)" }
    }
    return "export.\(ext)"
}
```

**Refactor de las llamadas existentes:** `exportMarkdown()` y `exportHTML()` pasan de `suggestedFilename(from: content, extension: ext)` a `suggestedFilename(title: pageTitle, extension: ext)`. El método privado antiguo desaparece.

### Anti-Patterns to Avoid

- **Llamar `createPDF()` directamente en `didFinish` sin delay:** produce PDF en blanco con contenido CSS complejo. Ya documentado en PITFALLS.md (#4).
- **No restaurar `webView.appearance` en el path de error:** el webview queda en modo claro permanentemente, afectando el preview del usuario.
- **Forzar la apariencia en el `WKWebViewConfiguration`:** no existe esa API; la apariencia se controla en la instancia NSView, no en la configuración.
- **Pasar `CGRect` con coordenadas y-offset para "paginar":** documentado como bug/limitación en Apple Developer Forums thread 700418 — el rect y-offset no hace clipping del contenido, captura siempre la página completa. Para página única continua (D-03) esto es el comportamiento deseado: usar `WKPDFConfiguration()` sin modificar el `rect`, dejando que capture el viewport completo.
- **Usar `NSSavePanel.allowedFileTypes` (deprecated):** usar `allowedContentTypes = [.pdf]`. `UTType.pdf` está disponible desde macOS 11+ sin imports adicionales.
- **Llamar `NSAlert.runModal()` desde un thread no-main:** `NSAlert` solo puede usarse en el main thread. Siempre desde `@MainActor`.

---

## Don't Hand-Roll

| Problema | No construir | Usar en su lugar | Por qué |
|----------|-------------|-----------------|---------|
| Generación de PDF vectorial | Renderizado propio, canvas, PDFKit manual | `WKWebView.createPDF()` | El webview ya tiene el DOM renderizado; PDFKit requeriría replicar todo el render |
| Selector de archivo nativo | Ventana custom, TextField de ruta | `NSSavePanel` (ya en uso) | Integración con el file system de macOS, acceso a bookmarks, manejo de permisos |
| Detección de apariencia del sistema | Leer `UserDefaults` de apariencia | `NSAppearance.current` / `.effectiveAppearance` | La API de AppKit gestiona toda la cascada de herencia de apariencia |
| Extracción del título de página | Parser HTML manual, regex | `BeautifulSoup soup.title` (ya en stack) | Casos edge: `<title>` vacío, whitespace, entidades HTML, charset — ya resueltos |

**Key insight:** `WKWebView.createPDF()` produce texto seleccionable, vectorial, con el render exacto del HTML — una reimplementación manual requeriría PDFKit + CoreText + layout engine propio, órdenes de magnitud más complejo.

---

## Common Pitfalls

### Pitfall 1: PDF en blanco por llamada prematura a createPDF (CRÍTICO)

**What goes wrong:** El PDF se genera vacío o con contenido parcial a pesar de que el WKWebView muestra el contenido correctamente.
**Why it happens:** `webView(_:didFinish:)` se dispara cuando el DOM está parseado, pero el layout CSS (especialmente con fuentes del sistema, tablas, o JS inline como `marked.js`) puede seguir calculándose durante 1-3 frames más.
**How to avoid:** Añadir `try? await Task.sleep(nanoseconds: 100_000_000)` (0.1s) entre recibir el webView y llamar a `createPDF`. Para contenido HTML estático generado por el extractor, 0.1s es suficiente. El comentario en `WebPreviewView.Coordinator.didFinish` ya anticipaba este requisito.
**Warning signs:** PDF se abre en Preview vacío o con solo el fondo blanco. El mismo HTML en el webview preview se ve perfectamente.

**Fuente:** PITFALLS.md #4, Apple Developer Forums thread 700418, digitalbunker.dev/how-to-create-pdf-from-wkwebview/ [CITED]

### Pitfall 2: Apariencia no restaurada en el path de error

**What goes wrong:** Si `createPDF` lanza error, el `catch` no restaura `webView.appearance` y el preview queda en modo claro aunque el sistema esté en modo oscuro.
**Why it happens:** La restauración solo se pone en el happy path.
**How to avoid:** Usar un `defer { webView.appearance = savedAppearance }` justo después de guardar la apariencia. O poner la restauración explícitamente en ambos paths (`catch` y éxito). `defer` es más robusto.
**Warning signs:** Después de un export fallido, el preview cambia de color.

### Pitfall 3: Confusión entre `pdf(configuration:)` async y `createPDF(configuration:completionHandler:)`

**What goes wrong:** El compilador no encuentra `pdf(configuration:)` en macOS 13 deployment target, aunque Apple lo documenta.
**Why it happens:** El método async `pdf(configuration:)` puede tener una disponibilidad más alta que `createPDF(configuration:completionHandler:)` (macOS 11+). [ASSUMED — verificar en Xcode]
**How to avoid:** Intentar primero el método async; si no compila, usar `withCheckedThrowingContinuation` wrapping del completion handler. El Approach B en los patrones de código es siempre seguro con macOS 11+.
**Warning signs:** Error de compilación "value of type WKWebView has no member pdf".

### Pitfall 4: `WKPDFConfiguration.rect` con coordenadas Y no hace clipping

**What goes wrong:** Al intentar recortar el PDF a una región, el rect y-offset no funciona — el PDF siempre captura la página completa.
**Why it happens:** Bug/limitación conocida de `WKWebView.createPDF` en macOS (Apple Developer Forums thread 700418). [CITED]
**How to avoid:** Para este proyecto (D-03: página única continua) esto es el comportamiento deseado. No modificar el `rect` del `WKPDFConfiguration`; dejar el default (viewport completo del webview).
**Warning signs:** N/A para este proyecto (es el comportamiento que queremos).

### Pitfall 5: `soup.title.string` puede devolver None aunque `soup.title` exista

**What goes wrong:** `soup.title` es un Tag vacío (`<title></title>`) — `.string` devuelve `None`.
**Why it happens:** El HTML tiene el tag `<title>` pero sin contenido.
**How to avoid:** Usar el patrón `soup.title.string.strip() if soup.title and soup.title.string else None`. Verificar siempre ambos niveles. [CITED: BeautifulSoup docs]
**Warning signs:** KeyError o TypeError al acceder a `.string` en el soup.

### Pitfall 6: El campo `title` en JSON rompe tests existentes

**What goes wrong:** `test_cli.py` valida la estructura JSON exacta; añadir `"title"` rompe assertions de tipo `assertEqual(result.keys(), expected_keys)`.
**Why it happens:** Tests escritos para el contrato JSON de Phase 5 sin prever la extensión.
**How to avoid:** Actualizar `test_cli.py` en la misma Wave que el cambio Python. El campo es opcional en Swift (`String?`) — un `null` en JSON es retrocompatible con el decoder Codable de Swift. Los tests Python sí deben actualizarse.
**Warning signs:** `pytest tests/` falla en el bloque JSON del éxito.

---

## Code Examples

### createPDF — API signature (macOS 11+, no async)
```swift
// Source: developer.apple.com/documentation/webkit/wkwebview/createpdf
// [VERIFIED via Apple Docs URL]
func createPDF(
    configuration: WKPDFConfiguration = WKPDFConfiguration(),
    completionHandler: @escaping (Result<Data, Error>) -> Void
)
```

### Override de apariencia para modo claro
```swift
// Source: eclecticlight.co/2019/04/19/printing-without-tears-in-dark-mode-and-exporting-to-pdf/
// [CITED]
// Pattern: guardar → overrride → operar → restaurar
let savedAppearance = webView.appearance
webView.appearance = NSAppearance(named: .aqua)
defer { webView.appearance = savedAppearance }
// ... createPDF ...
```

### NSSavePanel para PDF
```swift
// Source: developer.apple.com/documentation/appkit/nssavepanel/allowedcontenttypes
// [CITED — UTType.pdf disponible desde macOS 11+]
let panel = NSSavePanel()
panel.allowedContentTypes = [.pdf]    // NO usar allowedFileTypes (deprecated macOS 12)
panel.nameFieldStringValue = "mi-documento.pdf"
panel.canCreateDirectories = true
```

### Extracción de title en Python
```python
# Source: beautifulsoup4 docs — [CITED]
# Patrón seguro con None-check doble
title: Optional[str] = None
if soup.title and soup.title.string:
    stripped = soup.title.string.strip()
    if stripped:
        title = stripped
```

### Contrato JSON ampliado (Python output)
```json
{
  "status": "success",
  "url": "https://example.com",
  "selector": null,
  "output_type": "markdown",
  "char_count": 1234,
  "content": "# Título\n\nContenido...",
  "title": "Ejemplo — Página de prueba"
}
```

### ExtractionResult.swift ampliado
```swift
// Retrocompatible: title es Optional, sin CodingKey (nombre coincide)
// [ASSUMED — CodingKey no necesario porque "title" en JSON == "title" en Swift]
struct ExtractionResult: Codable {
    let status: String
    let url: String
    let selector: String?
    let outputType: String?
    let charCount: Int?
    let content: String?
    let errorMessage: String?
    let title: String?          // NUEVO Phase 6 — null en JSON → nil en Swift

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content, title
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `NSSavePanel.allowedFileTypes = ["pdf"]` | `allowedContentTypes = [.pdf]` (UTType) | macOS 12 (deprecated) | Usar la API moderna; la deprecated sigue funcionando pero genera warnings |
| `createPDF(completionHandler:)` sin config | `createPDF(configuration:completionHandler:)` con `WKPDFConfiguration` | macOS 11 | La config permite especificar el rect; default es el viewport completo |
| `NSPrintOperation` para "Export as PDF" | `WKWebView.createPDF()` | macOS 11+ | `createPDF` es programático y silencioso; NSPrintOperation muestra diálogo del sistema |

**Deprecated/outdated:**
- `allowedFileTypes` en NSSavePanel: deprecado en macOS 12, usar `allowedContentTypes`
- `printOperation(with:)` para PDF silencioso: correcto técnicamente pero añade complejidad del diálogo de impresión — para este caso (exportación directa) `createPDF` es la API correcta

---

## Runtime State Inventory

Esta fase es greenfield para las funcionalidades nuevas (exportPDF, title en JSON). No hay estado runtime que migrar.

- **Stored data:** Ninguno — la caché de `_fetch_raw` guarda HTML, no titles; se regenera. [VERIFIED: código core.py]
- **Live service config:** Ninguno — no hay servicios externos.
- **OS-registered state:** Ninguno.
- **Secrets/env vars:** Ninguno.
- **Build artifacts:** La adición de `title: String?` a `ExtractionResult` es retrocompatible — el decoder tolerante de Swift no falla si el campo no está en el JSON (lo deja nil).

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework Python | pytest (ya configurado) |
| Framework Swift | XCTest (`ExtractorAppTests` target, 7 tests existentes) |
| Config file | `tests/` dir (pytest), `ExtractorApp/ExtractorAppTests/` (XCTest) |
| Quick run command | `pytest tests/ -x -q` / Xcode Product > Test |
| Full suite command | `pytest tests/ -v` / `xcodebuild test -scheme ExtractorApp` |

### Phase Requirements → Test Map

| Req ID | Comportamiento | Test Type | Automated Command | File Exists? |
|--------|---------------|-----------|-------------------|-------------|
| EXPORT-04 (SC-1) | Botón PDF deshabilitado hasta `contentReady = true` | unit (Swift) | `xcodebuild test -scheme ExtractorApp -only-testing ExtractorAppTests/ViewModelTests` | ✅ `ViewModelTests.swift` (extender) |
| EXPORT-04 (SC-2) | `exportPDF()` genera Data no vacía cuando webview tiene contenido | integration manual | Manual — NSSavePanel no mockeable | N/A — manual-only |
| EXPORT-04 (SC-3) | NSSavePanel sugiere nombre derivado del title | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ Wave 0 gap |
| D-05 — title en JSON | `--json` incluye campo `title` con valor string o null | unit (Python) | `pytest tests/test_cli.py -k json -x` | ✅ `test_cli.py` (extender) |
| D-06 — suggestedFilename unificado | Preferir title sobre prefijo de contenido | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ Wave 0 gap |
| D-07 — fallback filename | Sin title → prefijo contenido → "export" | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ Wave 0 gap |
| D-08 — NSAlert en error | No crash; rama de error de exportPDF cubierta | unit (Swift) | `xcodebuild test` (rama no-op no lanza alert en tests) | ✅ patrón existente en `testExportDispatchMarkdown` |

### Sampling Rate

- **Per task commit:** `pytest tests/ -x -q && xcodebuild test -scheme ExtractorApp -quiet 2>&1 | tail -5`
- **Per wave merge:** Suite completa (pytest + XCTest)
- **Phase gate:** Ambas suites verdes antes de `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `ExtractorAppTests/ViewModelTests.swift` — añadir `testSuggestedFilenameWithTitle`, `testSuggestedFilenameFallbackContent`, `testSuggestedFilenameFallbackExport`
- [ ] `tests/test_cli.py` — extender fixture JSON para verificar campo `title` (presente y `null`)
- [ ] No se necesita instalar frameworks nuevos

*(Los gaps son extensiones de archivos existentes, no creaciones de cero)*

---

## Security Domain

Esta fase no introduce superficie de ataque nueva. La escritura de Data a disco usa `.atomic` (write + rename, sin corrupción parcial). El `title` del HTML es un string display-only — no se evalúa como código ni se interpola en SQL. `NSSavePanel` gestiona los permisos del sistema de archivos. No hay entradas de red, autenticación ni criptografía nuevas.

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V5 Input Validation | Marginal | El `title` se sanitiza antes de usarse como nombre de archivo (regex existente) |
| V6 Cryptography | No | — |
| V2 Authentication | No | — |
| V4 Access Control | No | NSSavePanel delega al OS |

---

## Open Questions

1. **¿Existe `pdf(configuration:)` como método async nativo en el SDK de macOS 13?**
   - What we know: La URL de Apple Docs (`3824706-pdf`) existe y apunta a un método diferente de `createPDF(configuration:completionHandler:)`. WebSearch confirma su existencia.
   - What's unclear: Disponibilidad exacta (¿macOS 12? ¿13? ¿14?). El contenido completo de la página no fue accesible vía WebFetch.
   - Recommendation: El planner debe incluir una tarea Wave 0 que verifique la compilación en Xcode antes de elegir Approach A o B. El Approach B (withCheckedThrowingContinuation) funciona en macOS 11+ y es el fallback seguro.

2. **¿Se hace una segunda llamada a `_fetch_raw` para el title o se refactoriza `extract_formatted_content`?**
   - What we know: La caché de `_fetch_raw` hace que la segunda llamada sea O(1) en la mayoría de los casos (hit de caché). Cambiar la firma de `extract_formatted_content` rompería los tests existentes.
   - What's unclear: Si la caché siempre está activa o si el usuario puede haberla desactivado con `--no-cache`.
   - Recommendation: La segunda llamada a `_fetch_raw` es el enfoque de menor riesgo. Documentar que si `--no-cache` está activo, se hace una segunda petición de red (aceptable: mismo URL, misma sesión). Claude's Discretion del planner.

3. **¿El delay de 0.1s es suficiente para HTML con `marked.js` inline?**
   - What we know: El HTML del extractor usa `marked.js` bundled inline; el script evalúa y escribe `innerHTML` al cargar. Esto es JS síncrono en el proceso de navegación — debería completarse antes de `didFinish`.
   - What's unclear: Si WKWebView dispara `didFinish` antes o después de ejecutar scripts inline al cargar.
   - Recommendation: 0.1s es el valor documentado para contenido estático. Si se detectan PDFs en blanco durante las pruebas manuales, aumentar a 0.3s. No usar delays > 0.5s sin justificación (experiencia usuario degradada).

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| WebKit (WKWebView) | PDF generation | ✓ | macOS 13+ SDK | — (API nativa) |
| AppKit (NSAppearance, NSSavePanel, NSAlert) | Appearance override, save, error | ✓ | macOS 13+ SDK | — |
| BeautifulSoup4 | title extraction Python | ✓ | ya instalada en .venv | trafilatura metadata |
| trafilatura | fallback title | ✓ | ya instalada en .venv | None → null en JSON |
| pytest | Python tests | ✓ | ya instalado | — |
| XCTest | Swift tests | ✓ | Xcode SDK | — |

**Missing dependencies con fallback:** Ninguno — todos los componentes están disponibles.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `pdf(configuration:)` existe como método async nativo en macOS 13 | Code Examples / Pitfall 3 | Bajo — el Approach B (withCheckedThrowingContinuation) funciona en todos los casos |
| A2 | La segunda llamada a `_fetch_raw` es un hit de caché cuando `use_cache=True` | Pattern 4 | Bajo — si es miss de caché, hay petición de red adicional pero no un error |
| A3 | El campo `"title"` en JSON no necesita CodingKey (nombre idéntico en ambos lados) | Code Examples | Bajo — si fallara el decode, el error sería evidente en compilación o en test |
| A4 | Un delay de 0.1s es suficiente para que `marked.js` inline complete el render antes de `createPDF` | Common Pitfalls #3 | Medio — si el delay es insuficiente, el PDF saldrá vacío en las pruebas manuales (ajustable) |
| A5 | El mecanismo de closure/callback para exponer el WKWebView al ViewModel no introduce ciclos de retención | Architecture Patterns #1 | Bajo — usar `[weak self]` en el closure es el patrón estándar |

---

## Sources

### Primary (HIGH confidence)
- `WebPreviewView.swift`, `ExtractionViewModel.swift`, `ExtractionResult.swift`, `ContentView.swift` — código existente del proyecto, leído directamente en esta sesión
- `.planning/research/PITFALLS.md` — investigación previa verificada con Apple Developer Forums
- `extractor_url.py`, `core.py` — contrato JSON actual verificado (campo `title` ausente confirmado)
- `ViewModelTests.swift` — suite existente, 7 tests, patrón `testExportDispatch` relevante

### Secondary (MEDIUM confidence)
- [createPDF(configuration:completionHandler:) — Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkwebview/createpdf(configuration:completionhandler:)) — URL confirmada, contenido no accesible vía WebFetch pero denominación clara
- [pdf(configuration:) — Apple Developer Documentation](https://developer.apple.com/documentation/webkit/wkwebview/3824706-pdf) — método async confirmado por URL e inferencia de patrón Apple
- [How To Create a PDF In A WKWebView — digitalbunker.dev](https://digitalbunker.dev/how-to-create-pdf-from-wkwebview/) — patrón de implementación con delegate + timing
- [MacOS WKWebView createPDF and CGRect — Apple Developer Forums thread 700418](https://developer.apple.com/forums/thread/700418) — limitación del rect y-offset confirmada
- [Printing without tears in Dark Mode — eclecticlight.co](https://eclecticlight.co/2019/04/19/printing-without-tears-in-dark-mode-and-exporting-to-pdf/) — técnica de override NSAppearance para PDF
- [allowedContentTypes — Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nssavepanel/allowedcontenttypes) — UTType.pdf en NSSavePanel
- [Trafilatura Core Functions](https://trafilatura.readthedocs.io/en/latest/corefunctions.html) — `extract_metadata()` retorna Document con `.title`
- [BeautifulSoup title extraction](https://pytutorial.com/how-to-use-beautifulsoup-to-extract-title-tag/) — patrón `soup.title.string if soup.title else None`

### Tertiary (LOW confidence)
- WebSearch sobre delay/timing en `createPDF` — múltiples posts sin fuente autorizada única; consistentes con PITFALLS.md #4

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — APIs nativas Apple en SDK ya instalado, librerías Python ya presentes
- Architecture: HIGH — decisiones bloqueadas en CONTEXT.md, patrones existentes en Phase 5 muy reutilizables
- createPDF async/await: MEDIUM — método confirmado por URL, disponibilidad exacta requiere verificación en Xcode
- Pitfalls timing: MEDIUM — comportamiento documentado en múltiples fuentes, delay recomendado 0.1s es ajustable
- Python title extraction: HIGH — BeautifulSoup API estable y bien documentada

**Research date:** 2026-06-12
**Valid until:** 2026-07-12 (APIs Apple estables; trafilatura ocasionalmente cambia firma de funciones internas)
