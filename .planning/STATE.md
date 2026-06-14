---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Standalone App
status: planning
last_updated: "2026-06-14T19:42:00.000Z"
last_activity: 2026-06-14 -- Milestone v3.0 iniciado
progress:
  total_phases: 0
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-14)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Phase 8 — bundling Python runtime dentro del .app

## Current Position

Phase: Not started (definiendo requirements)
Plan: —
Status: Defining requirements
Last activity: 2026-06-14 — Milestone v3.0 started

```
v3.0 Progress: [----------] 0%
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v3.0:

- [v3.0]: python-build-standalone como distribución Python embebida — portable, sin deps del sistema, universal arm64+x86_64.
- [v3.0]: App Sandbox OFF simplifica el bundling — sin entitlements adicionales para subprocess con binario embebido.
- [v3.0]: Bundle size ~30-60 MB añadido es aceptable para uso personal.
- [v3.0]: SettingsView mantiene override de rutas para uso avanzado — no se elimina, se hace opcional.

### Pending Todos

- Decidir estructura exacta del bundle: `Contents/Resources/python/` vs `Contents/Frameworks/`.
- Verificar compatibilidad python-build-standalone con macOS 13.0 (deployment target).
- Determinar si las dependencias se vendorizan con `pip install --target` o con el venv completo.

### Blockers/Concerns

- Ninguno en planificación.

## Deferred Items (desde v2.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Soporte páginas JavaScript (Playwright) | v4+ |
| Funcionalidad | Historial y cola de extracciones | v4+ |
| Distribución | Notarización para terceros | v3 es personal; revisar en v4 |

## Session Continuity

Last session: 2026-06-14T19:42:00Z
Stopped at: Definiendo requirements para v3.0
Resume file: None
