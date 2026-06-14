---
gsd_state_version: 1.0
milestone: v2.0
milestone_name: SwiftUI Native App
status: complete
last_updated: "2026-06-14T11:22:00.000Z"
last_activity: 2026-06-14 -- Phase 03 completada (Python Bridge + Premium UI + Logo)
progress:
  total_phases: 7
  completed_phases: 7
  total_plans: 15
  completed_plans: 15
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-10)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone v2.0 COMPLETO

## Current Position

Phase: — (todas completadas)
Status: **MILESTONE v2.0 COMPLETO**
Last activity: 2026-06-14 -- Phase 03 completada (Python Bridge + Premium UI + Logo)

```
v2.0 Progress: [##########] 100% — COMPLETO
```

## Phase Summary

| Phase | Nombre | Planes | Estado |
|-------|--------|--------|--------|
| 01 | validacion-automatica-del-conversor | 2/2 | ✅ Completa |
| 02 | robustez-cli-y-manejo-errores | 0/0 | ⏭ Omitida (placeholder) |
| 03 | python-bridge-y-preferencias | 4/4 | ✅ Completa |
| 04 | swiftui-ui-de-extraccion | 2/2 | ✅ Completa |
| 05 | preview-y-export-md-html | 2/2 | ✅ Completa |
| 06 | export-pdf | 3/3 | ✅ Completa |
| 07 | universal-binary-y-configuracion-de-build | 2/2 | ✅ Completa |

## Performance Metrics

**Velocity (v2.0):**

- Total planes completados: 15
- Duración media por plan: ~12 min

**By Phase (v2.0):**

| Phase | Plans | Avg/Plan |
|-------|-------|----------|
| 01 | 2 | ~12 min |
| 03 | 4 | ~10 min |
| 04 | 2 | ~12 min |
| 05 | 2 | ~12 min |
| 06 | 3 | ~15 min |
| 07 | 2 | ~12 min |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.

- [v2.0]: Puente Python → Swift vía `Process()` con `--json`; rutas configurables en preferencias.
- [v2.0]: Export HTML como único fichero autocontenido con CSS/JS inline.
- [v2.0]: Export PDF vía `WKWebView.pdf(configuration:)` (async, macOS 13+) — no PDFKit.
- [v2.0]: Universal binary (x86_64 + arm64), sin App Store ni notarización inicial obligatoria.
- [v2.0]: App Sandbox OFF, Hardened Runtime ON — patrón correcto para herramienta personal fuera del App Store.
- [v2.0]: `@StateObject + ObservableObject` como patrón de estado (macOS 13 compatible).
- [v2.0]: `readabilityHandler` asíncrono en paralelo para stdout y stderr — evita deadlock con buffers grandes de `trafilatura`.
- [03-04]: Colores semánticos del sistema (`Color(.windowBackgroundColor)` etc.) — dark mode automático, sin hex hardcodeado.
- [03-04]: Patrón `fill + overlay stroke` en RoundedRectangle — compatible macOS 13.5 (vs `.fill().stroke()` que es macOS 14+).
- [06-03]: webViewProvider como closure `(() -> WKWebView?)?` con `[weak coordinator]` — menor acoplamiento, sin ciclo de retención.
- [06-03]: baseURL HTTPS en `loadHTMLString` — necesario para imágenes protocol-relative.
- [06-03]: Sondeo JS `document.images[*].complete` con timeout 5s en lugar de delay fijo.

### Pending Todos

Ninguno para v2.0. Los ítems siguientes son candidatos para v3+:

- Verificar comportamiento de `@Observable` en runtime macOS 13 vs 14 (si se migra a la macro).
- Determinar si `allow-unsigned-executable-memory` es necesario con las dependencias Python concretas.

### Blockers/Concerns

Ninguno.

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Empaquetado | Bundling del intérprete Python dentro del `.app` | v3+ | v2.0 planning |
| Funcionalidad | Soporte páginas JavaScript (Playwright) | v3+ | v2.0 planning |
| Distribución | Estrategia de ruta del script para distribución a terceros | Decisión pendiente | v2.0 planning |

## Session Continuity

Last session: 2026-06-14T11:22:00Z
Stopped at: Milestone v2.0 completo — todos los commits mergeados
Resume file: None
