# Features Research: SwiftUI macOS Extraction + Export App

**Domain:** Native macOS utility app — subprocess bridge + export tool
**Researched:** 2026-06-10
**Confidence:** HIGH (core APIs verified via Context7 / Apple official docs)

---

## Feature Categories

---

### URL Input & Extraction

**Table stakes:**

- User can type or paste a URL into a text field (SwiftUI `TextField`)
- User can select output type via a `Picker` (Text / HTML / Markdown)
- User can trigger extraction with a button; button is disabled while extraction is running
- A `ProgressView()` (indeterminate spinner) is visible during the 5–30 second extraction window — without it the app appears frozen
- Extraction runs off the main thread; UI remains responsive throughout
- Error messages are shown inline (not modal dialogs) when the CLI returns non-zero exit or malformed JSON
- User can cancel an in-progress extraction

**Differentiators:**

- Advanced options panel (collapsible): CSS selector, `--timeout`, `--no-cache`
- URL history / recent URLs via `UserDefaults` or `AppStorage`
- Drag-and-drop URL onto the window
- Keyboard shortcut to trigger extraction (Cmd+Return)

**Notes (complexity and async):**

The subprocess bridge is the architectural keystone. `Foundation.Process` is the correct API — not `NSTask` (deprecated alias). The non-blocking pattern is:

```swift
// Run on a background actor or Task, never on MainActor
Task {
    let result = try await runPythonCLI(url: inputURL, type: selectedType)
    await MainActor.run { self.extractedContent = result }
}
```

Inside `runPythonCLI`:

```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: pythonPath)
process.arguments = [scriptPath, url, "--type", type, "--json"]

let stdoutPipe = Pipe()
let stderrPipe = Pipe()
process.standardOutput = stdoutPipe
process.standardError  = stderrPipe

try process.run()
process.waitUntilExit()  // safe because we're already off MainActor

let data   = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
let stderr = stderrPipe.fileHandleForReading.readDataToEndOfFile()

guard process.terminationStatus == 0 else {
    throw ExtractionError.nonZeroExit(String(data: stderr, encoding: .utf8) ?? "")
}

return try JSONDecoder().decode(ExtractionResult.self, from: data)
```

`process.waitUntilExit()` blocks the calling thread — therefore it MUST run inside a `Task` (or `DispatchQueue.global()`) and never on `@MainActor`. The `terminationHandler` callback alternative works but complicates structured concurrency; `Task + waitUntilExit` is simpler and idiomatic for Swift 5.5+.

The JSON contract expected from the CLI (`--json` flag): `{ "title": String, "url": String, "content": String }`. This is already planned in the CLI layer.

**Cancellation:** Wrap the task in a stored `Task<_, _>` and call `.cancel()`. The process itself must also be killed: `process.terminate()` before `process.waitUntilExit()` in a cancelled path.

---

### Content Preview

**Table stakes:**

- User sees the extracted content immediately after extraction completes
- Markdown content is rendered visually (not as raw Markdown text)
- HTML content is rendered in a browser-like view
- The preview scrolls for long content
- The preview area shows "No content yet" when empty

**Differentiators:**

- Syntax highlighting for code blocks in Markdown
- Toggle between rendered and raw source view
- Dark mode adaptation for previewed content

**Notes:**

WKWebView is the correct choice for all preview types — it handles Markdown (via a lightweight JS renderer like marked.js bundled in the app) and HTML natively. It is wrapped via `NSViewRepresentable`:

```swift
struct WebPreview: NSViewRepresentable {
    var html: String

    func makeNSView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.navigationDelegate = context.coordinator
        return wv
    }

    func updateNSView(_ wv: WKWebView, context: Context) {
        wv.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject, WKNavigationDelegate { }
}
```

`loadHTMLString(_:baseURL:)` — confirmed API, returns `WKNavigation?`. For Markdown preview, convert the Markdown string to HTML server-side (in Swift using a lightweight library such as `swift-markdown` or `Ink`) before passing to WKWebView, or inline a JS renderer. Inlining marked.js (~50 KB minified) as a bundle resource is simpler than adding a Swift dependency.

`WKNavigationDelegate.webView(_:didFinish:)` is the canonical hook to know when content is ready — this is critical before triggering PDF export (see PDF section).

---

### Markdown Export

**Table stakes:**

- User can save the raw extracted Markdown string to a `.md` file
- NSSavePanel is shown with a default filename derived from the page title (sanitised)
- Default directory is `~/Desktop` or last-used directory
- On success, a brief confirmation ("Saved to ~/Desktop/page-title.md") is shown
- No transformation of content — what the CLI returns is written verbatim

**Differentiators:**

- "Open in Finder" action after save
- Copy to clipboard as an alternative to file save

**Notes:**

Use SwiftUI `.fileExporter` modifier (confirmed API, macOS 12+ recommended) or `NSSavePanel` directly for finer control:

```swift
// SwiftUI fileExporter approach — simpler, idiomatic
.fileExporter(
    isPresented: $showMarkdownExporter,
    document: MarkdownDocument(content: extractedContent),
    contentType: .plainText,
    defaultFilename: sanitizedTitle + ".md"
) { result in
    handleExportResult(result)
} onCancellation: {
    // no-op
}
```

`MarkdownDocument` must conform to `FileDocument`. For direct `NSSavePanel` control (e.g. setting `.md` extension explicitly):

```swift
let panel = NSSavePanel()
panel.allowedContentTypes = [UTType(filenameExtension: "md")!]
panel.nameFieldStringValue = sanitizedTitle + ".md"
panel.beginSheetModal(for: window) { response in
    if response == .OK, let url = panel.url {
        try? content.write(to: url, atomically: true, encoding: .utf8)
    }
}
```

Complexity: **Low**. This is the simplest export path — no rendering required.

---

### Self-contained HTML Export

**Table stakes:**

- User can save a single `.html` file that opens correctly in Safari/Chrome without any external assets
- CSS is inlined in a `<style>` block (no external stylesheets)
- Page is readable: comfortable line width (max ~720px), legible font size (16px base), adequate margins
- Dark-mode-aware via `@media (prefers-color-scheme: dark)`
- Code blocks are styled (monospace font, subtle background)
- Original page title appears in `<title>` and an `<h1>`
- Source URL is shown as a small footer link

**Differentiators:**

- Print-optimised `@media print` section within the same file
- Timestamp of extraction in the footer

**Notes (CSS baseline to inline):**

No external framework dependency. A minimal bespoke CSS reset is the correct choice — no Tailwind or Bootstrap in a self-contained single file. The following baseline covers all table-stakes readability requirements:

```css
/* Inline in <style> — approximately 60 lines */
*, *::before, *::after { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-size: 1rem;
  line-height: 1.7;
  color: #1a1a1a;
  background: #fff;
  max-width: 720px;
  margin: 2rem auto;
  padding: 0 1.25rem;
}
@media (prefers-color-scheme: dark) {
  body { color: #e8e8e8; background: #1c1c1e; }
  code, pre { background: #2c2c2e; }
  a { color: #58a6ff; }
}
h1,h2,h3,h4 { line-height: 1.3; margin-top: 1.8em; }
p { margin: 0.9em 0; }
a { color: #0066cc; }
code { font-family: "SF Mono", Menlo, monospace; font-size: 0.875em;
       background: #f4f4f5; padding: 0.15em 0.35em; border-radius: 4px; }
pre { background: #f4f4f5; padding: 1em; border-radius: 6px; overflow-x: auto; }
pre code { background: none; padding: 0; }
blockquote { border-left: 3px solid #ccc; margin: 0; padding-left: 1em; color: #555; }
img { max-width: 100%; height: auto; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 0.5em 0.75em; }
@media print { body { max-width: none; margin: 1cm; } }
```

**Format spec for the generated file:**

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <style>/* baseline CSS above */</style>
</head>
<body>
  <h1>{title}</h1>
  <p class="meta">Extraído de <a href="{url}">{url}</a> · {date}</p>
  <hr>
  {html_content}
  <footer><small>Generado con extractor-url · {date}</small></footer>
</body>
</html>
```

The `{html_content}` is the HTML output from the CLI (`--type html`). Images with relative `src` attributes will be broken — this is acceptable for v2.0; the feature scope is "readable text content", not full page cloning.

Complexity: **Medium**. The Swift side assembles a string from a template; the hard part is having a good template. No additional library needed.

---

### PDF Export

**Table stakes:**

- User can save the rendered content as a paginated PDF file
- NSSavePanel is shown with a `.pdf` default filename
- PDF is letter or A4 size, readable (not a screenshot — real PDF text)
- Export only available after content has been extracted and previewed

**Notes (WKWebView async PDF, NSPrintOperation details):**

Two verified APIs exist. Prefer `createPDF` / `pdf(configuration:)` over `NSPrintOperation` for this use case — it produces a clean PDF without the macOS print dialog.

**Option A — `createPDF(configuration:completionHandler:)` (macOS 11.0+):**

```swift
// Confirmed signature from Apple docs:
// @MainActor func createPDF(
//     configuration: WKPDFConfiguration = .init(),
//     completionHandler: @escaping @MainActor @Sendable (Result<Data, any Error>) -> Void
// )

webView.createPDF { result in   // called on MainActor
    switch result {
    case .success(let data):
        savePDFData(data)
    case .failure(let error):
        showError(error)
    }
}
```

**Option B — `pdf(configuration:)` async/await (macOS 12.0+):**

```swift
// Confirmed signature: async func pdf(configuration: WKPDFConfiguration = .init()) throws -> Data

Task {
    do {
        let data = try await webView.pdf()
        savePDFData(data)
    } catch {
        showError(error)
    }
}
```

Option B is cleaner with Swift concurrency. macOS 12 minimum is reasonable for a new app in 2026.

**Critical sequencing — the async trap:**

PDF must not be triggered until the WKWebView has finished rendering the HTML. The failure mode is a blank or partial PDF. Correct pattern:

```swift
// In the NSViewRepresentable Coordinator (WKNavigationDelegate):
func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // Signal SwiftUI that content is ready
    parent.onContentLoaded()
}
```

In SwiftUI state: `@State private var contentReady = false`. PDF export button is `.disabled(!contentReady)`. On `loadHTMLString`, reset `contentReady = false`; set it back to `true` only in `didFinish`.

**WKPDFConfiguration:**

`WKPDFConfiguration` has a single meaningful property in current docs: `rect` (a `CGRect` specifying the portion of the web view to capture). Default (nil rect) captures the full rendered content. No direct page-size or margin API — layout is controlled by the HTML/CSS `@media print` rules.

**NSPrintOperation alternative (macOS 11.0+):**

```swift
// Confirmed: func printOperation(with: NSPrintInfo) -> NSPrintOperation
let info = NSPrintInfo.shared.copy() as! NSPrintInfo
info.horizontalPagination = .fit
info.isHorizontallyCentered = true
info.jobDisposition = NSPrintInfo.JobDisposition.save
info.dictionary().setObject(saveURL, forKey: NSPrintInfo.AttributeKey.jobSavingURL as NSString)
let op = webView.printOperation(with: info)
op.run()  // shows print panel unless showsPrintPanel = false
```

`NSPrintOperation` is more complex and shows macOS print UI. Use `createPDF` instead — simpler, no UI, returns `Data` directly.

Complexity: **Medium-High** due to the sequencing requirement (must wait for `didFinish`).

---

### Preferences / Configuration

**Table stakes:**

- User can set the path to the Python interpreter (default: auto-detect from `PATH` or common locations such as `/usr/local/bin/python3`, `~/.venv/bin/python`)
- User can set the path to `extractor_url.py` (default: bundle-relative or adjacent to app)
- Settings persist across launches via `@AppStorage` / `UserDefaults`
- A "Test connection" button verifies that `python --version` and `extractor_url.py --help` return successfully

**Differentiators:**

- Default export directory setting
- Default output type (Text / HTML / Markdown)

**Notes:**

Use `@AppStorage` wrappers — confirmed SwiftUI API backed by `UserDefaults`. Settings panel via SwiftUI `Settings` scene (macOS 13+) or a sheet. Auto-detection of Python path on first launch should probe: `which python3`, `/usr/local/bin/python3`, `~/.pyenv/shims/python3`. Store the resolved path.

---

## Anti-features (defer or skip for v2.0)

| Anti-Feature | Why Avoid | What to Do Instead |
|---|---|---|
| Batch URL extraction | Multiplies complexity of async state; no user demand established | Single URL per session; iterate in v3 |
| Built-in Markdown editor | Out of scope; the app is an extractor, not an editor | Export to .md, let user edit externally |
| Safari extension / browser integration | Separate entitlement, separate review, separate codebase | Bookmarklet or Share Extension in v3 |
| Image download and embedding in self-contained HTML | Major complexity; requires fetching each asset, encoding to base64 | Acceptable gap for v2.0; note broken images in footer |
| App Store distribution | Notarisation + sandbox constraints conflict with subprocess and arbitrary file paths | Direct distribution via GitHub Releases |
| Sync / iCloud export | No clear benefit for local CLI tool | Local-only is fine for v2.0 |
| Multiple windows / tabs | Adds state management complexity | Single window; toolbar-based navigation |
| Login/authentication for paywalled content | Security and legal scope creep | Out of scope permanently |
| Undo/redo for text edits in preview | Preview is read-only in v2.0 | No edits, export only |
| Custom themes for HTML export | Nice, but adds surface area | Single good default template is enough |

---

## Feature Dependencies (build order)

```
Preferences (Python path) → Subprocess Bridge → Content Preview → All Exports

Subprocess Bridge (JSON output)
  └── Content Preview (WKWebView loadHTMLString)
        ├── PDF Export (must wait for didFinish)
        └── HTML Export (assembled from CLI output)

Markdown Export (no dependency on WKWebView — pure string write)
```

**Minimum viable path:**
1. Preferences (Python path config)
2. URL input form + subprocess bridge + JSON parsing
3. Markdown export (simplest, validates bridge works end-to-end)
4. Content preview (WKWebView)
5. HTML self-contained export
6. PDF export (depends on preview being ready)

---

## Confidence Assessment

| Area | Confidence | Source |
|---|---|---|
| Process/subprocess API | HIGH | Foundation docs via Context7 |
| WKWebView createPDF | HIGH | WebKit docs via Context7, confirmed signatures |
| WKNavigationDelegate didFinish | HIGH | WebKit docs via Context7 |
| NSViewRepresentable lifecycle | HIGH | SwiftUI docs via Context7 |
| fileExporter modifier | HIGH | SwiftUI docs via Context7 |
| NSPrintOperation + WKWebView | HIGH | WebKit docs via Context7 |
| Self-contained HTML CSS baseline | MEDIUM | General web standards, no Apple-specific verification needed |
| Swift concurrency Task + waitUntilExit pattern | HIGH | Swift concurrency model + Foundation docs |
| Python path auto-detection | MEDIUM | macOS convention; test on actual machines with pyenv/brew |

---

## Sources

- `createPDF(configuration:completionHandler:)` — https://developer.apple.com/documentation/webkit/wkwebview/createpdf
- `pdf(configuration:)` async — https://developer.apple.com/documentation/webkit/wkwebview/pdf
- `printOperation(with:)` — https://developer.apple.com/documentation/webkit/wkwebview/printoperation
- `WKNavigationDelegate.webView(_:didFinish:)` — https://developer.apple.com/documentation/webkit/wknavigationdelegate/webview(_:didfinish:)
- `loadHTMLString(_:baseURL:)` — https://developer.apple.com/documentation/webkit/wkwebview/load
- `NSViewRepresentable` — https://developer.apple.com/documentation/swiftui/nsviewrepresentable
- `fileExporter` modifier — https://developer.apple.com/documentation/swiftui/view/fileexporter
- `Task.detached` for background work — https://developer.apple.com/documentation/swiftui/scene/onchange
- `ProgressView` — https://developer.apple.com/documentation/SwiftUI/ProgressView
