---
gsd_state_version: 1.0
milestone: v2.0
milestone_name: SwiftUI Native App
status: milestone_complete
last_updated: 2026-06-13T11:08:04.722Z
last_activity: 2026-06-13
progress:
  total_phases: 5
  completed_phases: 5
  total_plans: 12
  completed_plans: 14
  percent: 100
stopped_at: Milestone complete (Phase 07 was final phase)
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-10)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone complete

## Current Position

Phase: 07
Plan: Not started
Status: Milestone complete
Last activity: 2026-06-13

```
v2.0 Progress: [#########-] 90% (Phase 7-02 completed)
```

## Performance Metrics

**Velocity (v2.0):**

- Total plans completed: 16 (07-01, 07-02)
- Average duration: 12 min

**By Phase (v2.0):**

| Phase | Plans | Total    | Avg/Plan |
|-------|-------|----------|----------|
| 01-06 | 12    | ~144 min | 12 min   |
| 07 | 2 | - | - |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [v2.0]: Puente Python → Swift vía `Process()` con `--json`; rutas configurables en preferencias.
- [v2.0]: Export HTML como único fichero autocontenido con CSS/JS inline.
- [v2.0]: Export PDF vía `WKWebView.pdf(configuration:)` (async, macOS 13+) — no PDFKit.
- [v2.0]: Universal binary (x86_64 + arm64), sin App Store ni notarización inicial obligatoria.
- [v2.0]: App Sandbox OFF, Hardened Runtime ON — patrón correcto para herramienta personal fuera del App Store.
- [v2.0]: `@Observable` macro (Swift 5.9+) como patrón de estado; fallback a `@StateObject + ObservableObject` si hay problemas en runtime macOS 13.
- [v2.0]: `readabilityHandler` asíncrono en paralelo para stdout y stderr — evita deadlock con buffers grandes de `trafilatura`.
- [v2.0]: BRIDGE-01 es la dependencia bloqueante — ninguna fase de UI ni export puede iniciarse antes de que el bridge funcione.
- [06-03]: webViewProvider como closure (() -> WKWebView?)? con [weak coordinator] — menor acoplamiento, sin ciclo de retención.
- [06-03]: Approach B (withCheckedThrowingContinuation + completionHandler) para createPDF — siempre seguro macOS 11+.
- [06-03]: WKPDFConfiguration() sin rect — WYSIWYG estricto (D-02) y página única continua (D-03).
- [06-03]: baseURL HTTPS en loadHTMLString — necesario para imágenes protocol-relative (Fix A post-verificación).
- [06-03]: Sondeo JS document.images[*].complete con timeout 5s en lugar de delay fijo 0.1s (Fix B post-verificación).

### Pending Todos

- Verificar si `@Observable` tiene comportamiento diferente en runtime macOS 13 vs 14 al inicio de Phase 4.
- Determinar si `allow-unsigned-executable-memory` es necesario con las dependencias Python concretas (Phase 7).

### Blockers/Concerns

- Ninguno para el inicio de Phase 3.

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Empaquetado | Bundling del intérprete Python dentro del `.app` | v3+ | v2.0 planning |
| Funcionalidad | Soporte páginas JavaScript (Playwright) | v3+ | v2.0 planning |
| Distribución | Estrategia de ruta del script para distribución a terceros | Decisión pendiente | v2.0 planning |

## Session Continuity

Last session: 2026-06-12T19:30:00Z
Stopped at: Phase 06 completa — Phase 07 es la siguiente
Resume file: None
