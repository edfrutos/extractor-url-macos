---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: executing
last_updated: "2026-08-20T00:00:00.000Z"
last_activity: 2026-08-20 -- Fase 14-01 (historial y cola, lado Python) completa y verificada: pytest 40/40, pylint 10/10, mypy limpio
progress:
  total_phases: 5
  completed_phases: 0
  total_plans: 1
  completed_plans: 1
  percent: 10
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fase 14 — lado Python (historial + `--batch`) completo y verificado. Falta 14-02 (vista de historial en la app SwiftUI, HIST-02) antes de dar la Fase 14 por cerrada; luego Fases 15-18 sin empezar.

## Current Position

Phase: 14 — Historial y cola de extracciones
Plan: 14-01 (Python) completo; 14-02 (Swift) por definir
Status: In progress — HIST-01/HIST-03 validados, HIST-02 pendiente
Last activity: 2026-08-20 — `core.py`: `_HISTORY_FILE`, `record_history_entry()` (best-effort, solo metadatos, nunca contenido), `load_history()` (ignora líneas corruptas). `extractor_url.py`: `_history_entry()`, `_lookup_title()` (extraída para eliminar duplicación entre `main()` y `_run_batch()`), historial alimentado desde los 3 caminos (éxito/error/GUI), flag `--batch` (exige `--json`, NDJSON, continúa tras fallo individual). 12 tests nuevos (7 `test_history.py` + 5 `test_cli.py`). Verificado: pytest 40/40, pylint 10.00/10 (tras refactor de `_lookup_title`, subió de 9.95), mypy limpio.

```
v6.0 Progress: [=         ] 10% — Fase 14 lado Python completo, resto sin empezar
Phase 14: [=====     ] 14-01 (Python) completo / 14-02 (Swift) pendiente
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
- [v6.0]: Historial en JSON Lines (`~/.cache/extractor-url/history.jsonl`), reutilizando `_CACHE_DIR` ya existente — sin SQLite ni ubicación nueva. Solo metadatos, nunca el contenido extraído.
- [v6.0]: `--batch` exige `--json` explícitamente — falla con `sys.exit(2)` si no, mismo principio que "selector CSS inválido falla explícito" de v1.0.
- [v6.0]: La cola de la app SwiftUI (14-02) reutilizará `PythonBridge.run()` en bucle — no se cambia el contrato JSON de una extracción individual.

### Pending Todos

- Definir y ejecutar la Fase 14-02: vista de historial en la app SwiftUI (HIST-02) — lee `history.jsonl` directamente del disco, sin pasar por el bridge. Necesitará research corta + plan + checkpoint humano en Xcode (como Fase 12).
- Tras cerrar 14-02, dar la Fase 14 completa por cerrada y avanzar a la Fase 15 (flag manual `--js`/`--no-js`).
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01 en el `.venv` real del Mac.

### Blockers/Concerns

- Ninguno bloqueante. La Fase 17 merece una nota de atención por su tamaño (ver Decisions arriba), pero no bloquea el resto de fases.

## Deferred Items (desde v6.0)

| Category | Item | Status |
|----------|------|--------|
| Distribución | Notarización para distribución pública (App Store, web pública) | v7+ |
| Funcionalidad | Actualización automática del runtime Python bundleado | v7+ |
| Funcionalidad | Flags `--no-images`, `--no-links`, `--clipboard` | v7+ |
| Funcionalidad | Rollouts por fases de Sparkle (`sparkle:phasedRolloutInterval`) | v7+ si hay más usuarios |

## Session Continuity

Last session: 2026-08-20T00:00:00Z
Stopped at: Fase 14-01 (historial y cola, lado Python) completa y verificada. Pendiente: definir 14-02 (vista SwiftUI) o preguntar al usuario si quiere commitear/pushear primero.
Resume file: .planning/phases/14-historial-cola/14-01-SUMMARY.md
