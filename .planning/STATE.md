---
gsd_state_version: 1.0
milestone: v4.0
milestone_name: Contenido Dinámico (JS)
status: complete
last_updated: "2026-08-18T00:00:00.000Z"
last_activity: 2026-08-18 -- Fase 11 implementada y verificada (pytest 28/28, pylint 10/10, mypy limpio) — milestone v4.0 cerrado
progress:
  total_phases: 1
  completed_phases: 1
  total_plans: 1
  completed_plans: 1
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-18)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone v4.0 completado y cerrado. Sin foco activo — pendiente que el usuario indique el siguiente milestone (v5+: historial de extracciones, flag manual --js/--no-js, notarización) o pida commit/push de lo hecho.

## Current Position

Phase: 11 — Playwright Fallback para Contenido Dinámico
Plan: 11-01 (Wave 1)
Status: Complete
Last activity: 2026-08-18 — Implementación completa: `_MIN_VISIBLE_TEXT_LENGTH`, `_looks_insufficient()`, `_fetch_via_playwright()` añadidos a `core.py`, integrados en `_fetch_raw()`. `tests/test_js_fallback.py` (8 tests) + `tests/fixtures/spa_vacia.html` nuevos. `requirements.txt` y `CLAUDE.md` documentan la dependencia `playwright`. Verificado en un venv Python 3.14 ad-hoc de este sandbox (el `.venv` del repo es macOS-específico, no ejecutable aquí): pytest 28/28, pylint 10/10, mypy limpio — incluyendo verificación real (sin mockear) de la degradación cuando Playwright no está instalado.

```
v4.0 Progress: [==========] 100% — verificado, milestone cerrado
Phase 11: [==========] 1/1 plan
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v4.0:

- [v4.0]: Fallback a Playwright activado solo por heurística automática de contenido insuficiente — sin flag manual `--js`/`--no-js` en este milestone (diferido a v5+ si hace falta).
- [v4.0]: Playwright/Chromium (~300MB+) no se embebe en el `.app` bundle SwiftUI — v4.0 es exclusivamente motor Python (CLI); la app queda fuera de este milestone.
- [v4.0]: Si Playwright no está instalado, la extracción degrada al resultado estático con aviso explícito, no con una excepción no controlada — confirmado con test real (sin mockear) contra un entorno sin el paquete instalado.
- [v4.0]: `_MIN_VISIBLE_TEXT_LENGTH = 100` (no 200) — ajustado durante la implementación porque la fixture de test "HTML rico" existente mide solo 145 caracteres de texto visible.
- [v4.0]: `# type: ignore[import-not-found]` debe ir ANTES de `# pylint: disable=...` en la misma línea — mypy no reconoce la directiva si aparece después de otro comentario.

### Pending Todos

- Ninguno pendiente de v4.0. Decidir siguiente milestone (v5+) o hacer commit/push de Fase 11 + docs (ver Blockers/Concerns).
- Recomendado no bloqueante: repetir `pytest tests/` en el `.venv` real del Mac (macOS, Python 3.12) antes de considerar esto verificado "en el entorno real del usuario" — la verificación de esta sesión se hizo en un venv Linux ad-hoc equivalente, no en el `.venv` del propio repo.

### Blockers/Concerns

- Nada bloqueante. Cambios de Fase 11 (core.py, requirements.txt, CLAUDE.md, tests/, docs de planning) siguen sin commitear en `git status` — preguntar al usuario antes de commitear/pushear, igual que en v3.0.

## Deferred Items (desde v4.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Historial y cola de extracciones | v5+ |
| Funcionalidad | Flag manual `--js`/`--no-js` | v5+ si la heurística automática resulta insuficiente en uso real |
| Distribución | Notarización para terceros | uso personal; revisar en v5+ |
| Distribución | Embeber Playwright/Chromium en el `.app` bundle | v5+ si hay demanda real, pese al coste de +300MB |

## Session Continuity

Last session: 2026-08-18T00:00:00Z
Stopped at: Milestone v4.0 cerrado (Fase 11 implementada y verificada). Pendiente: preguntar al usuario si quiere commitear/pushear, o definir v5.
Resume file: .planning/phases/11-playwright-fallback/11-01-SUMMARY.md
