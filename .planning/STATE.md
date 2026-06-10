---
gsd_state_version: 1.0
milestone: v2.0
milestone_name: SwiftUI Native App
status: executing
last_updated: "2026-06-10T16:46:56.435Z"
last_activity: 2026-06-10 -- Phase 3 planning complete
progress:
  total_phases: 5
  completed_phases: 0
  total_plans: 3
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-10)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone v2.0 — SwiftUI Native App — Phase 3: Python Bridge y Preferencias

## Current Position

Phase: 03 — Python Bridge y Preferencias
Plan: Not started
Status: Ready to execute
Last activity: 2026-06-10 -- Phase 3 planning complete

```
v2.0 Progress: [----------] 0% (0/5 phases)
```

## Performance Metrics

**Velocity (v1.0):**

- Total plans completed: 3
- Average duration: 2 min

**By Phase (v1.0):**

| Phase | Plans | Total  | Avg/Plan |
|-------|-------|--------|----------|
| 1     | 2     | 3 min  | 1.5 min  |
| 2     | 1     | 1 min  | 1 min    |

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

### Pending Todos

- Verificar empíricamente `UTType(filenameExtension: "md")` en macOS 13 antes de implementar export MD (Phase 5).
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

Last session: 2026-06-10T13:33:00.000Z
Stopped at: Roadmap v2.0 created — next step: `/gsd:plan-phase 3`
Resume file: None
