---
phase: 05-preview-y-export-md-html
plan: "01"
subsystem: swiftui-viewmodel-export
tags: [swiftui, viewmodel, export, nssavepanel, marked-js, xctest]
dependency_graph:
  requires: [ExtractionViewModel, PythonBridge]
  provides: [contentReady, exportFormat, htmlForPreview, generateHTML, export, exportMarkdown, exportHTML, ExtractorAppTests]
  affects: [ContentView, WebPreviewView]
tech_stack:
  added: [marked.js 18.0.5 (bundled inline, sin dependencia de runtime)]
  patterns: [withCheckedContinuation, NSSavePanel async, raw string literal, computed-property-preview]
key_files:
  created: []
  modified:
    - ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift
    - ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift
decisions:
  - "marked.umd.js v18.0.5 (42,9 KB) embebido como raw string #\"\"\"...\"\"\"# — compila sin problemas, no fue necesario el fallback de recurso de bundle"
  - "generateHTML envuelve también outputType==\"html\" en el template con dark mode (sin escapar el contenido): el plan decía 'tal cual' pero los must-haves y testGenerateHTMLDarkMode exigen dark mode en los 3 tipos"
  - "UTType(filenameExtension: \"md\") verificado empíricamente: resuelve a net.daringfireball.markdown y conforma a public.text; se mantiene el fallback ?? .plainText"
metrics:
  duration: "12 minutos"
  completed: "2026-06-12"
  tasks_completed: 3
  files_created: 0
  files_modified: 2
---

# Phase 05 Plan 01: Lógica de preview y export del ViewModel — Summary

**One-liner:** ExtractionViewModel extendido con contentReady/exportFormat, htmlForPreview, generateHTML autocontenido (marked.js inline + dark mode) y export async vía NSSavePanel, con 7 tests unitarios en verde.

## Qué se hizo

### Task 0 (Wave 0) — ya completada en sesión anterior (commit `ebdfd8a`)

Target XCTest `ExtractorAppTests` + scheme compartido + scaffold de `ViewModelTests.swift`.

### Task 1 — ExtractionViewModel extendido (commit `dd22f7f`)

- `@Published var contentReady = false` y `@Published var exportFormat = "markdown"` (D-10, D-14).
- `var htmlForPreview: String?` computada (D-05) que delega en `generateHTML`.
- `contentReady = false` insertado en el bloque de limpieza D-09 de `extract()`.
- `generateHTML(content:outputType:)`: HTML5 autocontenido con CSS inline del UI-SPEC, `@media (prefers-color-scheme: dark)` y `@media print` en los 3 tipos. Markdown: escape `\` → `` ` `` → `$` EN ESE ORDEN (PITFALL 3) + `marked.parse()` con marked.js inline. Text: escape `&`/`<` + `<pre>`. HTML: contenido sin escapar dentro del template.
- `export()` con `switch exportFormat` (pdf = no-op hasta Phase 6); `exportMarkdown()`/`exportHTML()` con `NSSavePanel` + `withCheckedContinuation` (D-11, D-12), `UTType(filenameExtension: "md") ?? .plainText` (PITFALL 2), errores por `print` a consola.
- `suggestedFilename(from:extension:)`: 50 chars saneados por regex, fallback "export".
- `marked.umd.js` v18.0.5 (42 921 bytes, de npm) como `private static let markedJS` en raw string.

### Task 2 — 7 tests unitarios implementados (commit `dd22f7f`)

`xcodebuild test -only-testing:ExtractorAppTests/ViewModelTests` → **TEST SUCCEEDED, 7/7 passed**.

## Criterios de aceptación verificados

| # | Criterio | Resultado |
|---|----------|-----------|
| 1 | contentReady, exportFormat, htmlForPreview, generateHTML, switch exportFormat, withCheckedContinuation presentes (grep) | PASS |
| 2 | `UTType(filenameExtension: "md") ?? .plainText` sin force-unwrap | PASS |
| 3 | Dark mode + escape de backticks antes de marked.parse | PASS (testGenerateHTMLDarkMode + orden de escapes) |
| 4 | BUILD SUCCEEDED | PASS |
| 5 | TEST SUCCEEDED 7/7, sin XCTFail residual | PASS |

## Desviaciones del plan

**1. [Contradicción resuelta] outputType "html" envuelto en template**

El plan (Task 1 action) indicaba devolver `content` tal cual para `"html"`, pero los must-haves y `testGenerateHTMLDarkMode` exigen `@media (prefers-color-scheme: dark)` en los 3 outputType. Se resolvió a favor de los criterios verificables: el contenido HTML se inserta sin escapar dentro del mismo template autocontenido.

**2. [Informativo] Raw string en vez de string multilínea normal**

El plan sugería `"""..."""`; se usó `#"""..."""#` porque marked.umd.js contiene backslashes y backticks que romperían un literal normal. Verificado: el JS no contiene `"""` ni `\#`, por lo que el raw string es seguro. El delimitador de cierre va en columna 0 (requisito de indentación de Swift).

**3. [Pendiente resuelto] UTType verificado empíricamente**

`UTType(filenameExtension: "md")` → `net.daringfireball.markdown`, conforma a `public.text` (verificado con snippet Swift en esta máquina). El todo de STATE.md queda cerrado.

## Verificación E2E manual pendiente

`exportMarkdown`/`exportHTML` abren `NSSavePanel` real (no mockeable sin refactor) — verificación manual según VALIDATION.md al cerrar la fase.

## Commits

- `ebdfd8a` — `feat(05-01): añade target XCTest ExtractorAppTests + scheme compartido` (Task 0, sesión anterior)
- `dd22f7f` — `feat(05-01): añade lógica de preview y export al ExtractionViewModel` (Tasks 1-2)

## Self-Check: PASSED

- `ExtractionViewModel.swift` contiene los 8 símbolos requeridos — FOUND
- Commit `dd22f7f` — FOUND en git log
- BUILD SUCCEEDED y TEST SUCCEEDED (7/7) — verificados
