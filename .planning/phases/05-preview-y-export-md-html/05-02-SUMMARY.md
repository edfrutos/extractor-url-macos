---
phase: 05-preview-y-export-md-html
plan: "02"
subsystem: swiftui-ui-preview-export
tags: [swiftui, wkwebview, nsviewrepresentable, coordinator, export-ui]
dependency_graph:
  requires: [ExtractionViewModel (05-01), htmlForPreview, contentReady, exportFormat, export()]
  provides: [WebPreviewView, ContentView export row]
  affects: [Phase 6 (PDF export reutilizará WebPreviewView/contentReady)]
tech_stack:
  added: []
  patterns: [NSViewRepresentable, Coordinator WKNavigationDelegate, guard-anti-recarga, segmented-picker-export]
key_files:
  created:
    - ExtractorApp/ExtractorApp/ExtractorApp/Views/WebPreviewView.swift
  modified:
    - ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift
decisions:
  - "El reset de contentReady con htmlContent nil captura el Coordinator con [weak coordinator]: el plan indicaba [weak context] pero Context es struct y 'weak' solo aplica a clases"
metrics:
  duration: "10 minutos + verificación humana"
  completed: "2026-06-12"
  tasks_completed: 3
  files_created: 1
  files_modified: 1
---

# Phase 05 Plan 02: WebPreviewView + fila de exportación — Summary

**One-liner:** Preview WKWebView renderizado (NSViewRepresentable + Coordinator con guard anti-recarga) y fila de exportación MD/HTML/PDF en ContentView, verificados visualmente por el usuario.

## Qué se hizo

### Task 1 — WebPreviewView.swift (commit `741f25c`)

- `struct WebPreviewView: NSViewRepresentable` con la firma exacta del UI-SPEC (`htmlContent: String?`, `@Binding var contentReady: Bool`).
- `makeNSView` crea el `WKWebView` una vez (configuración por defecto, JS habilitado) y asigna el Coordinator como `navigationDelegate`.
- `updateNSView` con guard PITFALL 1 (`htmlContent != lastLoadedHTML`) antes de cualquier `loadHTMLString(_:baseURL: nil)`; con `htmlContent == nil` limpia el WebView y resetea `contentReady = false` (D-04).
- `Coordinator: NSObject, WKNavigationDelegate`: `didFinish` → `contentReady = true` vía `DispatchQueue.main.async` (D-02/D-03); `didFail` → log a consola.

### Task 2 — ContentView.swift (commit `741f25c`)

- La rama de éxito reemplaza `ScrollView { Text }` por `WebPreviewView(htmlContent: vm.htmlForPreview, contentReady: $vm.contentReady)` (D-06 — WKWebView para los 3 tipos).
- Nueva fila de exportación tras Divider: Picker segmented `Markdown`/`HTML`/`PDF` (PDF `.disabled(true)`, D-09) + botón `Exportar` (`square.and.arrow.up`, `.borderedProminent`, `.accessibilityLabel("Exportar contenido")`), ambos `.disabled(!vm.contentReady)` (D-07/D-08).
- Estados 3 (ProgressView) y 6 (error + hint Preferencias) sin cambios.

### Task 3 — Verificación humana: APPROVED (2026-06-12)

El usuario verificó los 8 puntos: preview renderizado (no raw), controles condicionados a `contentReady`, sin parpadeo en hover (PITFALL 1), PDF deshabilitado, export `.md` íntegro, export `.html` autocontenido con dark mode en Safari.

## Criterios de aceptación verificados

| # | Criterio | Resultado |
|---|----------|-----------|
| 1 | WebPreviewView: NSViewRepresentable, @Binding contentReady, guard anti-recarga, didFinish, baseURL: nil (grep) | PASS |
| 2 | ContentView: WebPreviewView(...), Picker exportFormat, PDF disabled, Label Exportar, Task await export, accessibilityLabel (grep) | PASS |
| 3 | ScrollView{Text} de la rama de éxito eliminado (0 ocurrencias) | PASS |
| 4 | BUILD SUCCEEDED + ViewModelTests 7/7 siguen verdes | PASS |
| 5 | Checkpoint human-verify: 8/8 puntos | APPROVED |

## Desviaciones del plan

**1. [Rule 1 - Bug] `[weak context]` no compila**

- **Encontrado durante:** Task 1 — primera compilación.
- **Error:** `'weak' may only be applied to class and class-bound protocol types, not 'WebPreviewView.Context'`.
- **Fix:** se captura `context.coordinator` (clase) en una constante local y se usa `[weak coordinator]` en el closure.
- **Commit:** `741f25c`.

## Commits

- `741f25c` — `feat(05-02): añade WebPreviewView WKWebView y fila de exportación`

## Self-Check: PASSED

- `Views/WebPreviewView.swift` — FOUND (≥30 líneas, struct NSViewRepresentable)
- `ContentView.swift` contiene `WebPreviewView(` y `await vm.export()` — FOUND
- Commit `741f25c` — FOUND en git log
- BUILD SUCCEEDED, TEST SUCCEEDED 7/7, verificación humana aprobada
