# Phase 6: Export PDF - Pattern Map

**Mapped:** 2026-06-12
**Files analyzed:** 7 ficheros nuevos o modificados
**Analogs found:** 7 / 7

---

## File Classification

| Fichero nuevo/modificado | Role | Data Flow | Closest Analog | Match Quality |
|--------------------------|------|-----------|----------------|---------------|
| `core.py` (modificar) | utility | transform | `core.py` — `_apply_selector()` + `_fetch_raw()` | exact — mismo fichero, mismo patrón helper privado |
| `extractor_url.py` (modificar) | utility / CLI | request-response | `extractor_url.py` — bloque `_print_json_output` lines 290-297 | exact — mismo fichero, mismo bloque JSON a extender |
| `ExtractorApp/.../Models/ExtractionResult.swift` (modificar) | model | CRUD | `ExtractionResult.swift` lines 1-20 (actual completo) | exact — mismo fichero, misma struct Codable |
| `ExtractorApp/.../ViewModels/ExtractionViewModel.swift` (modificar) | service / ViewModel | request-response | `ExtractionViewModel.swift` — `exportMarkdown()` / `exportHTML()` lines 154-207 | exact — mismo fichero, patrón NSSavePanel + withCheckedContinuation a replicar |
| `ExtractorApp/.../Views/WebPreviewView.swift` (modificar) | view / NSViewRepresentable | event-driven | `WebPreviewView.swift` lines 1-66 (completo) | exact — mismo fichero, Coordinator con `weak var webView` a exponer |
| `ExtractorApp/.../Views/ContentView.swift` (modificar) | view | request-response | `ContentView.swift` lines 96-113 — fila export Picker | exact — mismo fichero, una línea a eliminar |
| `ExtractorAppTests/ViewModelTests.swift` (modificar) | test | — | `ViewModelTests.swift` lines 59-72 — `testExportDispatchMarkdown` | exact — mismo fichero, patrón `@MainActor` test a extender |
| `tests/test_cli.py` (modificar) | test | — | `tests/test_cli.py` lines 34-57 — `test_main_json_devuelve_salida_estructurada` | exact — mismo fichero, fixture JSON a ampliar |

---

## Pattern Assignments

### `core.py` — nueva función `_extract_title()` (utility, transform)

**Analog:** `core.py` — funciones helper privadas existentes (`_apply_selector`, `_fetch_raw`, `_post_process_markdown`)

**Imports pattern** (lines 8-25 — sin cambio, ya están todos los imports necesarios):
```python
from __future__ import annotations

import sys
from typing import Optional

import trafilatura
from bs4 import BeautifulSoup, FeatureNotFound
```

**Core pattern — helper privado** (copiar estructura de `_apply_selector`, lines 171-184):
```python
def _apply_selector(
    soup: BeautifulSoup, selector: str
) -> Optional[Tag]:
    """Aplica un selector CSS para acotar el contenido extraído."""
    try:
        found = soup.select_one(selector)
    except SelectorSyntaxError as error:
        print(f"Selector CSS inválido '{selector}': {error}", file=sys.stderr)
        return None

    if found and isinstance(found, Tag):
        return found
    print(f"Selector '{selector}' no encontró ningún elemento.", file=sys.stderr)
    return None
```

**Nueva función a crear — mismo patrón de guard doble y except broad en frontera:**
```python
def _extract_title(
    soup: BeautifulSoup,
    html_text: Optional[str] = None,
) -> Optional[str]:
    """Extrae el <title> de la página. Fallback a trafilatura metadata."""
    # Camino 1: BeautifulSoup (guard doble — Pitfall #5 de RESEARCH.md)
    if soup.title and soup.title.string:
        title = soup.title.string.strip()
        if title:
            return title
    # Camino 2: trafilatura metadata (og:title, twitter:title, etc.)
    if html_text:
        try:
            meta = trafilatura.extract_metadata(html_text)
            if meta and meta.title:
                return meta.title.strip()
        except Exception:  # pylint: disable=broad-exception-caught
            pass
    return None
```

**Error handling pattern** (copiar de `_fetch_raw` lines 119-124 — stderr + return None):
```python
    except requests.exceptions.RequestException as e:
        print(f"Error al acceder a la URL '{url}': {e}", file=sys.stderr)
        return None
    except Exception as e:  # pylint: disable=broad-exception-caught
        print(f"Error inesperado: {e}", file=sys.stderr)
        return None
```

**Ubicación en el fichero:** Insertar entre `_post_process_markdown` (line 187) y `_format_soup_content` (line 197), dentro del bloque `# Limpieza y utilidades`.

---

### `extractor_url.py` — ampliar bloque JSON de éxito (utility/CLI, request-response)

**Analog:** `extractor_url.py` — bloque `_print_json_output` de éxito, lines 290-297

**Bloque actual a modificar** (lines 290-297):
```python
    if args.json:
        _print_json_output({
            "status": "success",
            "url": args.url,
            "selector": args.selector,
            "output_type": args.type,
            "char_count": len(result_str),
            "content": result_str,
        })
```

**Imports nuevos necesarios** (añadir a bloque de imports locales, line 20, junto al import existente de `core`):
```python
from core import extract_formatted_content, _fetch_raw, _extract_title
```

**Patrón de extracción de title antes del bloque JSON** (copiar lógica de `_fetch_soup` lines 127-136 para el parser con fallback):
```python
from bs4 import FeatureNotFound
# ...
    if args.json:
        # Extraer title de forma independiente (segunda llamada = hit de caché)
        page_title: Optional[str] = None
        raw_result = _fetch_raw(args.url, timeout=args.timeout, use_cache=args.use_cache)
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
            "title": page_title,   # None → null en JSON → nil en Swift Codable
        })
```

**Error handling:** El bloque de error JSON (lines 280-285) no se toca — `title` solo aparece en el path de éxito.

---

### `Models/ExtractionResult.swift` — añadir campo `title` (model, CRUD)

**Analog:** `ExtractionResult.swift` completo (lines 1-20) — la struct actual es el patrón a extender

**Struct actual completa** (lines 1-20):
```swift
import Foundation

struct ExtractionResult: Codable {
    let status: String
    let url: String
    let selector: String?
    let outputType: String?
    let charCount: Int?
    let content: String?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }
}
```

**Cambio mínimo a aplicar:** Añadir `title: String?` en los campos Y en el `CodingKeys` (sin alias — "title" == "title"):
```swift
    let errorMessage: String?
    let title: String?          // NUEVO Phase 6 — null en JSON → nil en Swift

    enum CodingKeys: String, CodingKey {
        case status, url, selector, content, title   // añadir title aquí
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }
```

**Retrocompatibilidad:** Campo optional — el decoder Swift tolera ausencia del campo (nil). No rompe JSON sin `title`.

---

### `ViewModels/ExtractionViewModel.swift` — `exportPDF()` + refactor `suggestedFilename` (service/ViewModel, request-response)

**Analog primario:** `exportMarkdown()` lines 154-175 y `exportHTML()` lines 177-198 — patrón NSSavePanel + withCheckedContinuation + do/catch

**Analog secundario:** `suggestedFilename(from:extension:)` lines 200-207 — heurística de fallback a unificar

**Imports pattern** (lines 1-5 — sin cambio, `UniformTypeIdentifiers` ya importado):
```swift
import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers
```

**Estado nuevo a añadir** (junto a los `@Published` existentes, tras line 22):
```swift
@Published var exportFormat: String = "markdown"   // ya existe
// NUEVO Phase 6:
private(set) weak var previewWebView: WKWebView?
@Published var pageTitle: String? = nil            // poblado al decodificar ExtractionResult
```

**Registro del webView** (método nuevo, mismo patrón de weak ref del Coordinator):
```swift
func registerWebView(_ webView: WKWebView) {
    previewWebView = webView
}
```

**Core pattern — exportPDF()** (copiar estructura de `exportMarkdown` lines 154-175, reemplazando String por Data):
```swift
// Patrón base a copiar: exportMarkdown() lines 154-175
@MainActor
func exportMarkdown() async {
    guard let content = resultContent else { return }

    let panel = NSSavePanel()
    panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
    panel.nameFieldStringValue = suggestedFilename(from: content, extension: "md")
    panel.canCreateDirectories = true

    let response = await withCheckedContinuation {
        (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
        panel.begin { continuation.resume(returning: $0) }
    }
    guard response == .OK, let url = panel.url else { return }

    do {
        try content.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        print("[ExportMarkdown] Error al guardar: \(error.localizedDescription)")
    }
}
```

**exportPDF() a crear — mismo esqueleto, con variaciones para WebKit + NSAlert:**
```swift
@MainActor
func exportPDF() async {
    guard let webView = previewWebView else { return }

    // D-04: forzar modo claro; defer garantiza restauración en error y éxito
    let savedAppearance = webView.appearance
    webView.appearance = NSAppearance(named: .aqua)
    defer { webView.appearance = savedAppearance }

    // Pitfall #1: delay para que layout CSS termine tras didFinish
    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s

    // Approach B (siempre seguro, macOS 11+):
    do {
        let pdfData = try await withCheckedThrowingContinuation {
            (cont: CheckedContinuation<Data, Error>) in
            webView.createPDF(configuration: WKPDFConfiguration()) { result in
                cont.resume(with: result)
            }
        }

        // NSSavePanel — mismo patrón que exportMarkdown/exportHTML
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = suggestedFilename(title: pageTitle, extension: "pdf")
        panel.canCreateDirectories = true

        let response = await withCheckedContinuation {
            (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
            panel.begin { continuation.resume(returning: $0) }
        }
        guard response == .OK, let url = panel.url else { return }

        try pdfData.write(to: url, options: .atomic)

    } catch {
        showPDFError(error)   // D-08: NSAlert visible
    }
}
```

**refactor suggestedFilename** (reemplaza `suggestedFilename(from:extension:)` lines 200-207):
```swift
// ANTES (Phase 5):
private func suggestedFilename(from content: String, extension ext: String) -> String {
    let name = String(content.prefix(50))
        .replacingOccurrences(of: "[^a-zA-Z0-9_\\-]", with: "-", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    return "\(name.isEmpty ? "export" : name).\(ext)"
}

// DESPUÉS (Phase 6) — nueva firma, misma heurística de fallback:
private func suggestedFilename(title: String?, extension ext: String) -> String {
    // D-06: preferir title saneado
    if let raw = title, !raw.isEmpty {
        let sanitized = raw
            .replacingOccurrences(of: "[^a-zA-Z0-9_\\-\\s]", with: "-",
                                   options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let truncated = String(sanitized.prefix(60))
            .replacingOccurrences(of: " ", with: "-")
        if !truncated.isEmpty { return "\(truncated).\(ext)" }
    }
    // D-07: fallback — prefijo del contenido (heurística original)
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

**Actualizar llamadas existentes** en `exportMarkdown` (line 161) y `exportHTML` (line 184):
```swift
// ANTES:
panel.nameFieldStringValue = suggestedFilename(from: content, extension: "md")
// DESPUÉS:
panel.nameFieldStringValue = suggestedFilename(title: pageTitle, extension: "md")
```

**Error handling — NSAlert** (D-08, patrón AppKit estándar, `@MainActor` garantizado):
```swift
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

**Activar rama pdf en `export()`** (line 147 — reemplazar `break`):
```swift
// ANTES (line 147):
case "pdf":
    break
// DESPUÉS:
case "pdf":
    await exportPDF()
```

**Import adicional necesario** (añadir a línea 1 del fichero):
```swift
import WebKit   // WKWebView, WKPDFConfiguration, createPDF
```

---

### `Views/WebPreviewView.swift` — exponer WKWebView al ViewModel (view/NSViewRepresentable, event-driven)

**Analog:** `WebPreviewView.swift` completo (lines 1-66) — especialmente `makeNSView` (lines 14-18) y Coordinator (lines 40-65)

**Mecanismo actual — Coordinator ya guarda la ref** (lines 14-18 + 43):
```swift
func makeNSView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    context.coordinator.webView = webView   // ref existente en Coordinator
    return webView
}
// ...
class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebPreviewView
    weak var webView: WKWebView?            // ya existe — candidata para D-01
```

**Cambio a aplicar — registrar en ViewModel vía closure o binding:**

Opción A (closure en ViewModel — menor acoplamiento, recomendada por RESEARCH.md Pattern 1):
```swift
// WebPreviewView añade una propiedad:
var onWebViewReady: ((WKWebView) -> Void)?

// En makeNSView, tras crear el webView:
func makeNSView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    context.coordinator.webView = webView
    onWebViewReady?(webView)          // NUEVO: notificar al ViewModel
    return webView
}
```

Opción B (pasar ViewModel como propiedad de WebPreviewView):
```swift
// WebPreviewView recibe el ViewModel:
var viewModel: ExtractionViewModel

// En makeNSView:
viewModel.registerWebView(webView)
```

**Patrón didFinish existente** (lines 50-55 — base para el comentario sobre delay PDF):
```swift
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // D-02/D-03: señaliza DOM renderizado. Para preview no hace
    // falta delay; Phase 6 (PDF) sí lo necesitará.
    DispatchQueue.main.async { [weak self] in
        self?.parent.contentReady = true
    }
}
```

**No se modifica `didFinish`** — el delay de 0.1s se aplica en `exportPDF()` en el ViewModel, no aquí.

---

### `Views/ContentView.swift` — habilitar opción PDF del Picker (view, request-response)

**Analog:** `ContentView.swift` line 99 — la línea exacta a modificar

**Línea actual** (line 99):
```swift
Text("PDF").tag("pdf").disabled(true)  // D-09: Phase 6
```

**Cambio a aplicar** (eliminar `.disabled(true)` y el comentario de placeholder):
```swift
Text("PDF").tag("pdf")
```

**Contexto completo del Picker de exportación** (lines 96-103 — sin más cambios):
```swift
Picker("", selection: $vm.exportFormat) {
    Text("Markdown").tag("markdown")
    Text("HTML").tag("html")
    Text("PDF").tag("pdf")             // MODIFICADO: eliminar .disabled(true)
}
.pickerStyle(.segmented)
.labelsHidden()
.disabled(!vm.contentReady)           // D-07/D-08: ya gateado por contentReady
```

---

### `ExtractorAppTests/ViewModelTests.swift` — ampliar suite (test)

**Analog:** `ViewModelTests.swift` lines 59-72 — `testExportDispatchMarkdown`, el test de rama no-op que PDF debe extender/complementar

**Patrón de test existente** (lines 59-72):
```swift
func testExportDispatchMarkdown() async throws {
    // NSSavePanel no es mockeable sin refactor: E2E manual.
    // Se cubre la rama no-op y el valor por defecto del formato.
    let vm = ExtractionViewModel()
    XCTAssertEqual(vm.exportFormat, "markdown")

    vm.exportFormat = "pdf"
    vm.resultContent = "contenido"
    await vm.export()    // rama "pdf" era no-op; Phase 6: activa → no debe crashear sin webView
    XCTAssertEqual(vm.resultContent, "contenido")
    XCTAssertEqual(vm.exportFormat, "pdf")
}
```

**Tests nuevos a añadir** (misma clase `@MainActor final class ViewModelTests`):

Test 1 — exportPDF sin webView registrado no crashea:
```swift
func testExportPDFWithoutWebViewIsNoop() async throws {
    let vm = ExtractionViewModel()
    vm.resultContent = "contenido de prueba"
    vm.exportFormat = "pdf"
    // previewWebView es nil — debe salir en guard sin crash
    await vm.export()
    XCTAssertEqual(vm.resultContent, "contenido de prueba")
}
```

Test 2 — suggestedFilename con title (D-06):
```swift
func testSuggestedFilenameWithTitle() async throws {
    let vm = ExtractionViewModel()
    vm.pageTitle = "Mi Artículo de Prueba"
    // Verificar que el title saneado aparece en el nombre sugerido
    // (acceso a método privado requiere @testable; usar resultado de exportMarkdown
    //  o exponer la función como internal para tests)
    // Alternativa: verificar vía integración que exportMarkdown propone nombre correcto
}
```

Test 3 — suggestedFilename fallback a contenido (D-07):
```swift
func testSuggestedFilenameFallbackToContent() async throws {
    let vm = ExtractionViewModel()
    vm.pageTitle = nil
    vm.resultContent = "Contenido de prueba sin título"
    // Sin title → debe usar prefijo del contenido, no "export"
    // Implementar cuando suggestedFilename sea internal en vez de private
}
```

Test 4 — suggestedFilename fallback a "export" (D-07):
```swift
func testSuggestedFilenameFallbackToExport() async throws {
    let vm = ExtractionViewModel()
    vm.pageTitle = nil
    vm.resultContent = nil
    // Sin title ni contenido → debe devolver "export.<ext>"
}
```

**Nota:** Los tests 2-4 requieren que `suggestedFilename` sea `internal` en vez de `private` para ser accesible con `@testable import`. El planner debe incluir esa decisión.

---

### `tests/test_cli.py` — ampliar contrato JSON (test)

**Analog:** `test_cli.py` lines 34-57 — `test_main_json_devuelve_salida_estructurada`

**Test existente a extender** (lines 34-57):
```python
def test_main_json_devuelve_salida_estructurada(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba el contrato JSON de una extracción correcta."""
    monkeypatch.setattr(sys, "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"])
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["status"] == "success"
    assert output["url"] == "https://example.com"
    assert output["content"] == "contenido"
    # NUEVO Phase 6: añadir assertions:
    assert "title" in output              # campo presente (puede ser null)
```

**Test nuevo — campo title con valor string:**
```python
def test_main_json_incluye_title_cuando_hay_titulo(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba que --json incluye el campo title cuando la página tiene <title>."""
    import core   # importar para monkeypatch de _fetch_raw y _extract_title
    monkeypatch.setattr(sys, "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"])
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )
    monkeypatch.setattr(core, "_fetch_raw",
        lambda *_a, **_kw: ("<html><title>Mi Título</title></html>", "https://example.com"))
    monkeypatch.setattr(core, "_extract_title",
        lambda *_a, **_kw: "Mi Título")

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["title"] == "Mi Título"
```

**Test nuevo — campo title null cuando no hay `<title>`:**
```python
def test_main_json_title_null_sin_titulo(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba que title es null en JSON cuando la página no tiene <title>."""
    import core
    monkeypatch.setattr(sys, "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"])
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )
    monkeypatch.setattr(core, "_fetch_raw",
        lambda *_a, **_kw: ("<html><body>sin título</body></html>", "https://example.com"))
    monkeypatch.setattr(core, "_extract_title",
        lambda *_a, **_kw: None)

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["title"] is None
```

**Patrón de imports** (lines 1-12 — sin cambio, añadir `import core` dentro de los tests que lo necesiten):
```python
from __future__ import annotations

import builtins
import json
import sys
from typing import NoReturn

import pytest

import extractor_url
```

---

## Shared Patterns

### NSSavePanel async (withCheckedContinuation)
**Fuente:** `ExtractionViewModel.swift` lines 164-168 — `exportMarkdown()`
**Aplicar a:** `exportPDF()` — mismo esqueleto para el panel
```swift
let response = await withCheckedContinuation {
    (continuation: CheckedContinuation<NSApplication.ModalResponse, Never>) in
    panel.begin { continuation.resume(returning: $0) }
}
guard response == .OK, let url = panel.url else { return }
```

### weak var para WKWebView
**Fuente:** `WebPreviewView.swift` line 43 — `weak var webView: WKWebView?`
**Aplicar a:** `ExtractionViewModel.previewWebView` — misma declaración `private(set) weak var`
```swift
weak var webView: WKWebView?    // Coordinator (existente)
// → replicar en ViewModel:
private(set) weak var previewWebView: WKWebView?
```

### @MainActor + guard nil early return
**Fuente:** `ExtractionViewModel.swift` lines 154-156 — `exportMarkdown()`
**Aplicar a:** `exportPDF()` — guard del webView antes de cualquier operación
```swift
@MainActor
func exportMarkdown() async {
    guard let content = resultContent else { return }
// → en exportPDF:
    guard let webView = previewWebView else { return }
```

### except broad en frontera Python
**Fuente:** `core.py` lines 122-124 — `_fetch_raw()` y `_apply_selector()`
**Aplicar a:** `_extract_title()` — bloque try de trafilatura
```python
    except Exception:  # pylint: disable=broad-exception-caught
        pass
```

### Errores Python a stderr, retornar None
**Fuente:** `core.py` lines 119-121 — `_fetch_raw()`
**Aplicar a:** `_extract_title()` — si se añade logging de errores
```python
    print(f"Error inesperado: {e}", file=sys.stderr)
    return None
```

### Bloque JSON de éxito con _print_json_output
**Fuente:** `extractor_url.py` lines 290-297
**Aplicar a:** Bloque JSON ampliado con campo `title`
```python
_print_json_output({
    "status": "success",
    "url": args.url,
    "selector": args.selector,
    "output_type": args.type,
    "char_count": len(result_str),
    "content": result_str,
    # NUEVO:
    "title": page_title,
})
```

### Monkeypatch para tests CLI Python
**Fuente:** `test_cli.py` lines 39-47 — patrón `monkeypatch.setattr` + `pytest.raises(SystemExit)`
**Aplicar a:** Tests nuevos de campo `title` — mismo esqueleto de fixture
```python
monkeypatch.setattr(extractor_url, "extract_formatted_content",
    lambda *_args, **_kwargs: "contenido")
with pytest.raises(SystemExit, match="0"):
    extractor_url.main()
output = json.loads(capsys.readouterr().out)
```

---

## No Analog Found

No hay ficheros sin análogo en esta fase. Todos los cambios son extensiones directas de código existente.

---

## Metadata

**Analog search scope:** Todo el proyecto — `ExtractorApp/`, `tests/`, raíz Python
**Files scanned:** 8 ficheros leídos directamente (core.py, extractor_url.py, ExtractionViewModel.swift, WebPreviewView.swift, ContentView.swift, ExtractionResult.swift, ViewModelTests.swift, test_cli.py)
**Pattern extraction date:** 2026-06-12

**Decisiones de acoplamiento relevantes para el planner:**
- `suggestedFilename` debe cambiar de `private` a `internal` para que los tests de XCTest puedan acceder con `@testable import`.
- El import de `WebKit` en `ExtractionViewModel.swift` es el único import nuevo Swift — el resto son APIs ya presentes.
- En Python, `_extract_title` y `_fetch_raw` deben ser importadas explícitamente en `extractor_url.py` (actualmente solo se importa `extract_formatted_content`).
- La opción B para exponer el webView (pasar ViewModel directamente a WebPreviewView) es más simple si `ContentView` ya instancia el `ExtractionViewModel` como `@StateObject` — el planner elige.
