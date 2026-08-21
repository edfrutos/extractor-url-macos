---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: executing
last_updated: "2026-08-21T00:00:00.000Z"
last_activity: 2026-08-21 -- Fase 14 (historial y cola) completa: 14-02 (vista SwiftUI) verificada en checkpoint humano real (Build Succeeded, historial visible, reabrir funciona)
progress:
  total_phases: 5
  completed_phases: 1
  total_plans: 2
  completed_plans: 2
  percent: 20
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-21)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fase 14 completa (Python + SwiftUI, HIST-01/02/03 validados). Siguiente: Fase 15 (flag manual `--js`/`--no-js`).

## Current Position

Phase: 14 — Historial y cola de extracciones (Complete)
Plan: 14-01 (Python) + 14-02 (Swift) completos
Status: Complete — HIST-01/HIST-02/HIST-03 validados
Last activity: 2026-08-21 — 14-02: `Models/HistoryEntry.swift` (Codable + `loadAll()`, lee `~/.cache/extractor-url/history.jsonl`), `ViewModels/HistoryViewModel.swift`, `Views/HistoryView.swift` (lista + reabrir), `ContentView.swift` (botón historial + `.sheet`). De paso, corregida una condición de carrera real en `PythonBridge.IOCollector.result()` (leía `outData`/`errData` sin el `NSLock` que las protege). Checkpoint humano en Xcode verificado: Build Succeeded, historial visible con entradas reales, reabrir repuebla campos y reextrae. Commit `7fa4095` pusheado a `origin/main`.

```
v6.0 Progress: [==        ] 20% — Fase 14 completa, resto sin empezar
Phase 14: [==========] Complete (14-01 Python + 14-02 Swift)
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
- [v6.0]: `HistoryEntry.loadAll()` (Swift) es una implementación independiente de `load_history()` (Python), mismo formato/orden — la app SwiftUI solo LEE `history.jsonl` del disco, nunca escribe ni invoca Python para el historial.
- [v6.0]: "Reabrir" una entrada de historial reutiliza `ExtractionViewModel.extract()` tal cual (asigna `urlString`/`outputType`/`selectorCSS` y llama) — no reimplementa el flujo de extracción ni añade un modo especial al bridge.

### Pending Todos

- Fase 15 (flag manual `--js`/`--no-js`): research completa (`15-RESEARCH.md`), falta el plan de implementación (`15-01-PLAN.md`).
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01 en el `.venv` real del Mac.

### Blockers/Concerns

- Ninguno bloqueante. La Fase 17 merece una nota de atención por su tamaño (ver Decisions arriba), pero no bloquea el resto de fases.
- **Bug real de Xcode 26.6 confirmado** (relacionado con `POLISH-02`): `GENERATE_INFOPLIST_FILE = YES` no sintetiza NINGUNA clave `INFOPLIST_KEY_*` personalizada en el `Info.plist` generado (`SUFeedURL`, `SUPublicEDKey`, `NSHumanReadableCopyright` — las 3 ausentes, confirmado con DerivedData borrado por completo, no era caché). Efecto observado: "Buscar actualizaciones…" fallaba con `You must specify the URL of the appcast as the SUFeedURL key...`. Corregido con un `Info.plist` físico parcial (`ExtractorApp/Info.plist`, solo esas 3 claves) + `INFOPLIST_FILE` en build settings, combinado con `GENERATE_INFOPLIST_FILE = YES` (mecanismo de merge documentado por Apple) — verificado en Mac real: las claves aparecen en el `.app` compilado y "Buscar actualizaciones…" funciona sin error.

## Deferred Items (desde v6.0)

| Category | Item | Status |
|----------|------|--------|
| Distribución | Notarización para distribución pública (App Store, web pública) | v7+ |
| Funcionalidad | Actualización automática del runtime Python bundleado | v7+ |
| Funcionalidad | Flags `--no-images`, `--no-links`, `--clipboard` | v7+ |
| Funcionalidad | Rollouts por fases de Sparkle (`sparkle:phasedRolloutInterval`) | v7+ si hay más usuarios |

## Session Continuity

Last session: 2026-08-21T00:00:00Z
Stopped at: Fase 14 completa (14-01 Python + 14-02 Swift), checkpoint humano verificado, commit `7fa4095` pusheado a `origin/main`. Pendiente: iniciar Fase 15 (flag manual `--js`/`--no-js`).
Resume file: .planning/phases/14-historial-cola/14-02-SUMMARY.md
