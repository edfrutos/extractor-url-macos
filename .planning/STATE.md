---
gsd_state_version: 1.0
milestone: v2.0
milestone_name: SwiftUI Native App
status: executing
last_updated: "2026-06-12T08:16:00.000Z"
last_activity: 2026-06-12 -- Plan 05-01 complete (ViewModel export logic, 7/7 tests)
progress:
  total_phases: 5
  completed_phases: 2
  total_plans: 7
  completed_plans: 6
  percent: 40
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-10)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Phase 05 — preview-y-export-md-html

## Current Position

Phase: 05 (preview-y-export-md-html) — EXECUTING
Plan: 2 of 2 (05-01 complete — dd22f7f)
Status: Executing Phase 05
Last activity: 2026-06-12 -- Plan 05-01 complete (ViewModel export logic, 7/7 tests)

```
v2.0 Progress: [##--------] 20% (1/5 phases)
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

Last session: 2026-06-11T16:19:39.968Z
Stopped at: Phase 4 context gathered
Resume file: None
