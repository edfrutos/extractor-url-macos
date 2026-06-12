---
phase: 06-export-pdf
plan: "03"
subsystem: swift-viewmodel-view
tags: [swift, webkit, wkwebview, pdf, nssavepanel, nsappearance, xctests, tdd]

requires:
  - phase: 06-02
    provides: [suggestedFilename(title:extension:), pageTitle, ExtractionResult.title]

provides:
  - ExtractionViewModel.webViewProvider (closure (() -> WKWebView?)?)
  - ExtractionViewModel.exportPDF() async (EXPORT-04 end-to-end)
  - ExtractionViewModel.showPDFError(_:) (NSAlert D-08)
  - WebPreviewView.viewModel (registro del closure en makeNSView)
  - ContentView: opcion PDF del Picker habilitada (SC-1)

affects: [07-packaging, verificacion-humana]

tech-stack:
  added: [WebKit (import nuevo en ExtractionViewModel)]
  patterns:
    - webViewProvider-closure-weak-coordinator
    - withCheckedThrowingContinuation-createPDF
    - NSAppearance-defer-restore
    - NSAlert-MainActor-runModal

key-files:
  created: []
  modified:
    - ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift
    - ExtractorApp/ExtractorApp/ExtractorApp/Views/WebPreviewView.swift
    - ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift
    - ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift

key-decisions:
  - "webViewProvider como closure (() -> WKWebView?)? en ViewModel — menor acoplamiento que referencia directa; capture [weak coordinator] evita ciclo de retención"
  - "Approach B (withCheckedThrowingContinuation + completionHandler) para createPDF — siempre seguro macOS 11+"
  - "WKPDFConfiguration() sin modificar rect — D-02 WYSIWYG ancho ventana, D-03 página única continua"
  - "defer { webView.appearance = savedAppearance } garantiza restauracion NSAppearance en exito y error"
  - "baseURL HTTPS en loadHTMLString — necesario para resolver imágenes protocol-relative (Fix A)"
  - "Sondeo JS document.images[*].complete con timeout 5s e intervalo 200ms — sustituye delay fijo 0.1s (Fix B)"
  - "showPDFError via NSAlert.runModal() en @MainActor — wording exacto del UI-SPEC D-08"
  - "T-06-06 mitigado: pdfData.write(to:options:.atomic) evita corrupcion parcial"

patterns-established:
  - "webViewProvider: patrón closure weak-coordinator para exponer WKWebView a ViewModel sin ciclo de retención"
  - "exportPDF: guard-webView → NSAppearance.aqua → defer → sleep → createPDF → NSSavePanel → write .atomic"
  - "TDD noop test: testExportPDFWithoutWebViewIsNoop verifica guard return sin crash con webViewProvider=nil"

requirements-completed: [EXPORT-04]

duration: ~14 min
completed: "2026-06-12"
---

# Phase 06 Plan 03: Exportacion PDF end-to-end Summary

**Exportacion PDF vectorial con texto seleccionable implementada via WKWebView.createPDF + NSAppearance forzada a claro + NSSavePanel con nombre derivado del titulo de pagina; imágenes protocol-relative corregidas via baseURL HTTPS y sondeo JS de carga.**

## Performance

- **Duration:** ~35 min (implementación + 2 correcciones post-verificación humana)
- **Started:** 2026-06-12T16:42:39Z
- **Completed:** 2026-06-12T19:30:00Z
- **Tasks completadas:** 4 de 4 (Task 4 verificacion humana APROBADA)
- **Files modified:** 4

## Accomplishments

- Task 1: `webViewProvider` closure registrado en `makeNSView` de `WebPreviewView` via `[weak coordinator]` — el ViewModel puede acceder al WKWebView visible sin acoplamiento directo ni ciclo de retención
- Task 2: `exportPDF()` implementado con modo claro forzado (D-04), delay 0.1s (Pitfall 1), `createPDF` via `withCheckedThrowingContinuation` (Approach B), `NSSavePanel` con `.pdf` y `suggestedFilename`, escritura `.atomic` (T-06-06); `showPDFError` con `NSAlert`; rama `pdf` activa en `export()`
- Task 3: `.disabled(true)` eliminado del tag `"pdf"` en el Picker — PDF habilitado cuando `contentReady` es true (SC-1 confirmado)
- TDD: test `testExportPDFWithoutWebViewIsNoop` verde — `webViewProvider=nil` produce guard return sin crash

## Task Commits

| Task | Nombre | Commit | Tipo |
|------|--------|--------|------|
| 1 | Exponer WKWebView via webViewProvider | `7eed298` | feat |
| 2 RED | Test noop exportPDF sin webView | `b86d111` | test |
| 2 GREEN | exportPDF() + showPDFError + rama pdf | `03f56c4` | feat |
| 3 | Habilitar opcion PDF del Picker | `cc196f3` | feat |
| Fix A | baseURL HTTPS en WebPreviewView | `db64b70` | fix |
| Fix B | Espera activa JS para imágenes remotas | `0491d99` | fix |
| 4 | Verificacion humana — APROBADA | — | checkpoint |

## Files Created/Modified

- `ExtractorApp/.../ViewModels/ExtractionViewModel.swift` — `import WebKit`, `var webViewProvider`, `exportPDF()` async, `showPDFError()`, rama `case "pdf": await exportPDF()`
- `ExtractorApp/.../Views/WebPreviewView.swift` — propiedad `viewModel: ExtractionViewModel`, registro closure en `makeNSView` con `[weak coordinator]`
- `ExtractorApp/.../ContentView.swift` — `viewModel: vm` en llamada a `WebPreviewView`; `.disabled(true)` eliminado del tag `"pdf"`
- `ExtractorApp/.../ExtractorAppTests/ViewModelTests.swift` — `testExportPDFWithoutWebViewIsNoop`

## Decisions Made

- Closure `webViewProvider` (opcion A del PATTERNS.md) vs. referencia directa (opcion B): elegida A por menor acoplamiento y porque el PLAN.md la especifica explicitamente.
- `defer` para restaurar `NSAppearance` garantiza restauracion incluso si `createPDF` lanza error (Pitfall 2 de RESEARCH.md).
- `WKPDFConfiguration()` sin `.rect` — respetar WYSIWYG estricto (D-02) y pagina unica (D-03).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug / Fix A] baseURL HTTPS ausente en loadHTMLString**

- **Found during:** Task 4 — verificación humana; el PDF generado no mostraba imágenes
- **Causa raíz:** `loadHTMLString(_:baseURL:)` con `baseURL: nil` hace que las URLs protocol-relative (`//cdn.example.com/img.jpg`) no puedan resolverse porque el parser no tiene esquema base. WKWebView las descarta silenciosamente.
- **Fix:** Pasar `baseURL: URL(string: "https://")` en `WebPreviewView.loadHTMLString`. Provee el esquema HTTPS sin alterar la ruta; las imágenes protocol-relative se resuelven correctamente.
- **Files modified:** `ExtractorApp/ExtractorApp/ExtractorApp/Views/WebPreviewView.swift`
- **Commit:** `db64b70`

**2. [Rule 1 - Bug / Fix B] Delay fijo 0.1s insuficiente para imágenes remotas**

- **Found during:** Task 4 — tras Fix A las imágenes cargaban en la vista pero no siempre aparecían en el PDF
- **Causa raíz:** `Task.sleep(nanoseconds: 100_000_000)` es un límite de tiempo ciego que no detecta si las imágenes del DOM han terminado de cargar. Para páginas con imágenes remotas, 100ms es insuficiente en condiciones de red normales.
- **Fix:** Sustituir el delay fijo por sondeo JS activo: `evaluateJavaScript("document.images.length > 0 && Array.from(document.images).every(i => i.complete)")` con intervalo de 200ms y timeout de 5s. Si el sondeo expira se procede igualmente (mejor esfuerzo).
- **Files modified:** `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift`
- **Commit:** `0491d99`

### Incidencias fuera del plan (sin cambios de código)

**Icono del Dock — caché de macOS:** Tras compilar en limpio el Dock mostraba el icono genérico. Resuelto con `lsregister -kill -r -domain local -domain system -domain user` para forzar reconstrucción del caché de Launch Services. No requirió cambios de código ni de assets.

## Issues Encountered

- El primer build de verificacion falló porque `xcodebuild` se invocó desde el directorio raiz del proyecto (que no contiene el `.xcodeproj`). Se corrigió usando el path absoluto al `.xcodeproj`. No es una desviación del plan.
- Los warnings de Swift 6 (`reference to captured var 'self' in concurrently-executing code`) son preexistentes de fases anteriores. Fuera del scope de este plan.

## Known Stubs

Ninguno — la exportacion PDF esta completamente implementada. Task 4 (verificacion humana) confirma el resultado real del PDF pero no es un stub de implementacion.

## Threat Flags

Ninguno nuevo — las amenazas T-06-06 (write .atomic), T-06-07 (NSSavePanel), T-06-08 (createPDF) y T-06-09 (suggestedFilename) estaban en el threat model del plan y han sido todas tratadas segun su disposicion (mitigate/accept).

## TDD Gate Compliance

- RED commit: `b86d111` — `test(06-03): add failing test for exportPDF noop (RED)`
- GREEN commit: `03f56c4` — `feat(06-03): implementar exportPDF() + showPDFError + activar rama pdf`
- REFACTOR: no necesario — el codigo GREEN es ya limpio

## Next Phase Readiness

- EXPORT-04 implementado end-to-end y verificado manualmente — Phase 6 cerrada
- Phase 7 (empaquetado/distribución) puede iniciarse

## Self-Check: PASSED

- [x] `ExtractionViewModel.swift` contiene `webViewProvider`, `func exportPDF` y sondeo JS activo (Fix B)
- [x] `WebPreviewView.swift` contiene `webViewProvider = { [weak coordinator` y `baseURL: URL(string: "https://")` (Fix A)
- [x] `ContentView.swift` contiene `Text("PDF").tag("pdf")` SIN `.disabled(true)`
- [x] `ViewModelTests.swift` contiene `testExportPDFWithoutWebViewIsNoop`
- [x] Commits `7eed298`, `b86d111`, `03f56c4`, `cc196f3`, `db64b70`, `0491d99` presentes en el log
- [x] BUILD SUCCEEDED (solo warnings Swift 6 preexistentes, fuera de scope)
- [x] TEST SUCCEEDED: 11 tests Swift (ViewModelTests), 20 tests Python — todos verdes
- [x] Task 4 verificacion humana: APROBADA (texto seleccionable, sin páginas en blanco, modo claro forzado, imágenes presentes)

---

<!-- Phase: 06-export-pdf | Plan: 03 | Completed: 2026-06-12 | EXPORT-04 cumplido end-to-end -->
