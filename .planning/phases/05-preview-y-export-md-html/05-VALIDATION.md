---
phase: 5
slug: preview-y-export-md-html
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-11
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
> Plataforma: macOS SwiftUI nativo. WKWebView y NSSavePanel requieren UI real para tests E2E — la validación automática cubre la lógica del ViewModel; la interfaz se verifica manualmente.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (incluido en Xcode — sin instalación adicional) |
| **Config file** | Target "ExtractorAppTests" en Xcode — Wave 0 lo crea si no existe |
| **Quick run command** | `xcodebuild build -scheme ExtractorApp -destination 'platform=macOS'` |
| **Full suite command** | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' -only-testing:ExtractorAppTests/ViewModelTests` |
| **Estimated runtime** | ~15 segundos (build) / ~30 segundos (test suite) |

---

## Sampling Rate

- **After every task commit:** `xcodebuild build -scheme ExtractorApp` — confirma que no hay errores de compilación
- **After every plan wave:** `xcodebuild test -scheme ExtractorApp -only-testing:ExtractorAppTests/ViewModelTests`
- **Before `/gsd:verify-work`:** Suite completa + verificación manual del preview WKWebView con contenido real
- **Max feedback latency:** 30 segundos (build) · 60 segundos (test suite)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01 | ViewModel extensions | 1 | UI-02 | — | htmlForPreview nil cuando resultContent==nil | unit | `xcodebuild test … testHtmlForPreviewNilWhenNoContent` | ❌ Wave 0 | ⬜ pending |
| 05-02 | ViewModel extensions | 1 | UI-02 | — | htmlForPreview para markdown contiene marked.parse | unit | `xcodebuild test … testHtmlForPreviewMarkdownContainsMarked` | ❌ Wave 0 | ⬜ pending |
| 05-03 | ViewModel extensions | 1 | UI-02 | — | contentReady se resetea a false en extract() | unit | `xcodebuild test … testContentReadyResetOnExtract` | ❌ Wave 0 | ⬜ pending |
| 05-04 | generateHTML | 1 | EXPORT-03 | T-01 | template no contiene URLs externas | unit | `xcodebuild test … testGenerateHTMLNoExternalDeps` | ❌ Wave 0 | ⬜ pending |
| 05-05 | generateHTML | 1 | EXPORT-03 | — | dark mode CSS presente en template | unit | `xcodebuild test … testGenerateHTMLDarkMode` | ❌ Wave 0 | ⬜ pending |
| 05-06 | generateHTML | 1 | EXPORT-03 | — | markdown output contiene marked.parse script | unit | `xcodebuild test … testGenerateHTMLMarkdownContainsScript` | ❌ Wave 0 | ⬜ pending |
| 05-07 | export() dispatch | 1 | EXPORT-01 | — | export() despacha exportMarkdown cuando exportFormat=="markdown" | unit (mock) | `xcodebuild test … testExportDispatchMarkdown` | ❌ Wave 0 | ⬜ pending |
| 05-08 | WebPreviewView | 2 | UI-02 | — | WKWebView carga HTML y dispara didFinish | manual | Preview WKWebView en app real | — | ⬜ pending |
| 05-09 | NSSavePanel MD | 2 | EXPORT-02 | — | archivo .md guardado con contenido íntegro | manual | Exportar desde app real | — | ⬜ pending |
| 05-10 | NSSavePanel HTML | 2 | EXPORT-03 | T-01 | archivo .html autocontenido, dark mode en Safari | manual | Abrir .html en Safari | — | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift` — tests unitarios para `htmlForPreview`, `generateHTML`, `contentReady`, dispatch de `export()`
- [ ] Target "ExtractorAppTests" en Xcode — confirmar que existe o crear (Phase 3/4 pueden haberlo creado)
- [ ] Importar `@testable import ExtractorApp` en ViewModelTests

*Si el target ya existe del proyecto base: "Existing infrastructure covers all phase requirements" para Wave 0.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| WKWebView renderiza Markdown visualmente (no raw) | UI-02 | WKWebView no puede inicializarse headless | Extraer URL con tipo Markdown, verificar que el preview muestra HTML renderizado |
| NSSavePanel abre con nombre sugerido y extensión .md | EXPORT-02 | NSSavePanel requiere UI real | Pulsar Exportar con formato MD, verificar nombre sugerido y extensión en panel |
| Archivo .html se abre en Safari sin assets externos rotos | EXPORT-03 | Requiere browser real para verificar | Exportar HTML, abrir en Safari, activar dark mode del sistema |
| contentReady=false durante extracción nueva (botón Exportar deshabilitado) | UI-02 | Estado de UI — no testeable sin display | Pulsar Extraer, verificar que botón Exportar está gris durante extracción |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
