---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: executing
last_updated: "2026-08-21T00:00:00.000Z"
last_activity: 2026-08-21 -- Fase 15 (flag manual --js/--no-js) completa: js_mode en core.py, flags mutuamente excluyentes en extractor_url.py, 51/51 tests, pylint 10/10, mypy limpio
progress:
  total_phases: 5
  completed_phases: 2
  total_plans: 3
  completed_plans: 3
  percent: 40
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-21)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fases 14 y 15 completas. Siguiente: Fase 16 (canales beta de Sparkle).

## Current Position

Phase: 15 — Flag manual `--js`/`--no-js` (Complete)
Plan: 15-01 completo
Status: Complete — FLAG-01/FLAG-02 validados
Last activity: 2026-08-21 — `core.py`: `_fetch_raw()`/`_fetch_soup()`/`extract_formatted_content()`/`extract_html_structure_to_markdown()` ganan `js_mode: str = "auto"` ("auto"/"force"/"off"); `js_mode != "auto"` salta la lectura de caché (no la escritura) para que los flags tengan efecto real sobre una URL ya cacheada. `extractor_url.py`: `--js`/`--no-js` como grupo mutuamente excluyente de `argparse`, `_resolve_js_mode()`, propagado a `main()`/`_run_batch()`/`_lookup_title()`. 11 tests nuevos (6 `test_flag_js.py` + 5 en `test_cli.py`). Verificado: pytest 51/51, pylint 10.00/10, mypy limpio, smoke test manual de la CLI real.

```
v6.0 Progress: [====      ] 40% — Fases 14-15 completas, resto sin empezar
Phase 14: [==========] Complete (14-01 Python + 14-02 Swift)
Phase 15: [==========] Complete (15-01)
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
- [v6.0]: `js_mode` ("auto"/"force"/"off") sustituye la línea única `if _looks_insufficient(...)` por una decisión de 3 vías en `_fetch_raw()` — sin tocar la heurística en sí, que sigue siendo el comportamiento exacto de v4.0 cuando `js_mode="auto"`.
- [v6.0]: `js_mode != "auto"` salta solo la LECTURA de caché en `_fetch_raw()`, no la escritura — sin esto, `--js`/`--no-js` no tendrían efecto sobre una URL ya cacheada de una ejecución anterior (hallazgo del research, no una decisión explícita del usuario).
- [v6.0]: `--js`/`--no-js` como `argparse.add_mutually_exclusive_group()` en vez de validación manual — falla nativo con `SystemExit(2)` si se pasan ambos, mismo principio de "fallar explícito" ya establecido en v1.0.

### Pending Todos

- Avanzar a la Fase 16 (canales beta de Sparkle) — necesitará research corta + plan.
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01/15-01 en el `.venv` real del Mac.

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
Stopped at: Fases 14 y 15 completas. Fase 15 (`--js`/`--no-js`) implementada, verificada (pytest 51/51, pylint 10/10, mypy limpio) y lista para commitear. Pendiente: iniciar Fase 16 (canales beta de Sparkle).
Resume file: .planning/phases/15-flag-manual-js/15-01-SUMMARY.md
