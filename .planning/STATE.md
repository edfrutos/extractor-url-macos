---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: planning
last_updated: "2026-08-20T00:00:00.000Z"
last_activity: 2026-08-20 -- Milestone v6.0 definido (5 fases: 14-18); pendiente research de la Fase 14
progress:
  total_phases: 5
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fase 14 — Historial y cola de extracciones. Definida a nivel de ROADMAP (goal/requirements/success criteria); falta research y plan.

## Current Position

Phase: 14 — Historial y cola de extracciones
Plan: ninguno todavía
Status: Planning — solo definido el goal/requirements/success criteria en ROADMAP.md
Last activity: 2026-08-20 — Milestone v6.0 iniciado: PROJECT.md, REQUIREMENTS.md, MILESTONES.md y ROADMAP.md actualizados con las 5 fases (14 Historial, 15 Flag manual JS, 16 Canales Sparkle, 17 Bundle Playwright, 18 Pulido técnico), orden fijado por el usuario. Directorios `.planning/phases/14-historial-cola/` a `.planning/phases/18-pulido-tecnico/` creados.

```
v6.0 Progress: [          ] 0% — en planificación
Phase 14: [          ] 0/? planes (research pendiente)
Phase 15: [          ] 0/? planes
Phase 16: [          ] 0/? planes
Phase 17: [          ] 0/? planes (fase grande — ver aviso de alcance en ROADMAP.md)
Phase 18: [          ] 0/? planes
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v6.0:

- [v6.0]: Alcance = todo el backlog diferido de v4.0/v5.0, en el orden que se presentó al usuario (historial → flags → canales → bundle JS → pulido) — decisión explícita del usuario ("en el orden establecido, TODO"), no priorizado por Claude.
- [v6.0]: La Fase 17 (Playwright/Chromium embebido) es señalada explícitamente como mucho más grande que el resto — comparable a toda la Fase 8 de v3.0. Tratarla como su propio sub-ciclo, no asumir que será rápida.
- [v6.0]: Fase 15 (flag manual) extiende v4.0 sin cambiar el comportamiento por defecto — sin pasar `--js`/`--no-js`, el comportamiento sigue siendo la heurística automática existente.
- [v6.0]: Fase 16 (canales beta) reutiliza el pipeline de la Fase 13 (`scripts/release-macos.sh`) — no un pipeline paralelo nuevo.
- [v6.0]: Fase 17 reutiliza el patrón de bundling de la Fase 8 y el patrón de firma/notarización de la Fase 13 — no reinventa ninguno de los dos desde cero.

### Pending Todos

- Iniciar research de la Fase 14 (historial y cola de extracciones): dónde persistir el historial (JSON local, SQLite, UserDefaults — a decidir en research), cómo expone la CLI la cola de URLs, qué vista nueva necesita la app SwiftUI.
- Tras completar cada fase, seguir el mismo patrón de cierre usado en v4.0/v5.0: SUMMARY.md, mover requirements a Validated, actualizar ROADMAP/STATE/PROJECT/REQUIREMENTS/MILESTONES.

### Blockers/Concerns

- Ninguno bloqueante — el milestone está en fase de definición, no de implementación. La Fase 17 merece una nota de atención por su tamaño (ver Decisions arriba), pero no bloquea empezar por la Fase 14.

## Deferred Items (desde v6.0)

| Category | Item | Status |
|----------|------|--------|
| Distribución | Notarización para distribución pública (App Store, web pública) | v7+ |
| Funcionalidad | Actualización automática del runtime Python bundleado | v7+ |
| Funcionalidad | Flags `--no-images`, `--no-links`, `--clipboard` | v7+ |
| Funcionalidad | Rollouts por fases de Sparkle (`sparkle:phasedRolloutInterval`) | v7+ si hay más usuarios |

## Session Continuity

Last session: 2026-08-20T00:00:00Z
Stopped at: Milestone v6.0 definido en los 4 ficheros de planning (5 fases). Falta research y plan de la Fase 14 antes de empezar a escribir código.
Resume file: .planning/ROADMAP.md (sección "v6.0 Historial y Distribución Completa")
