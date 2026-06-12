---
phase: 6
slug: export-pdf
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-12
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | pytest (Python) + XCTest (Swift, target `ExtractorAppTests`) |
| **Config file** | `tests/` (pytest) · `ExtractorApp/ExtractorAppTests/` (XCTest) |
| **Quick run command** | `pytest tests/ -x -q` |
| **Full suite command** | `pytest tests/ -v` · `xcodebuild test -scheme ExtractorApp` |
| **Estimated runtime** | ~60 seconds (ambas suites) |

---

## Sampling Rate

- **After every task commit:** Run `pytest tests/ -x -q && xcodebuild test -scheme ExtractorApp -quiet 2>&1 | tail -5`
- **After every plan wave:** Run `pytest tests/ -v` + `xcodebuild test -scheme ExtractorApp`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| TBD | TBD | TBD | EXPORT-04 (SC-1) — botón PDF deshabilitado hasta `contentReady = true` | — | N/A | unit (Swift) | `xcodebuild test -scheme ExtractorApp -only-testing ExtractorAppTests/ViewModelTests` | ✅ `ViewModelTests.swift` (extender) | ⬜ pending |
| TBD | TBD | TBD | EXPORT-04 (SC-2) — `exportPDF()` genera Data no vacía | — | escritura `.atomic` a disco | integration manual | Manual — NSSavePanel no mockeable | N/A — manual-only | ⬜ pending |
| TBD | TBD | TBD | EXPORT-04 (SC-3) — NSSavePanel sugiere nombre derivado del title | — | title sanitizado antes de usarse como filename | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | D-05 — `--json` incluye campo `title` (string o null) | — | N/A | unit (Python) | `pytest tests/test_cli.py -k json -x` | ✅ `test_cli.py` (extender) | ⬜ pending |
| TBD | TBD | TBD | D-06 — suggestedFilename prefiere title sobre prefijo de contenido | — | N/A | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | D-07 — fallback filename: title → prefijo contenido → "export" | — | N/A | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | D-08 — NSAlert en error de exportPDF, sin crash | — | N/A | unit (Swift) | `xcodebuild test -scheme ExtractorApp` | ✅ patrón en `testExportDispatchMarkdown` | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

*Los Task IDs se completan cuando el planner emita los PLAN.md.*

---

## Wave 0 Requirements

- [ ] `ExtractorAppTests/ViewModelTests.swift` — añadir `testSuggestedFilenameWithTitle`, `testSuggestedFilenameFallbackContent`, `testSuggestedFilenameFallbackExport`
- [ ] `tests/test_cli.py` — extender fixture JSON para verificar campo `title` (presente y `null`)
- [ ] Verificar compilación de `pdf(configuration:)` async en Xcode (Approach A) antes de elegir frente a `createPDF` + continuation (Approach B)

*Los gaps son extensiones de archivos existentes — no se instalan frameworks nuevos.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| PDF resultante con contenido íntegro, texto seleccionable, sin páginas en blanco | EXPORT-04 (SC-2) | NSSavePanel y render real de WKWebView no son mockeables en XCTest | Extraer una URL en la app, esperar `contentReady`, exportar PDF, abrir en Vista Previa: comprobar texto seleccionable y ausencia de páginas en blanco |
| PDF renderiza en modo claro con tema oscuro del sistema activo | D-04 | Apariencia del sistema no controlable desde tests | Activar dark mode en macOS, exportar PDF, comprobar fondo claro |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
