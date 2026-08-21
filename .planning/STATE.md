---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: executing
last_updated: "2026-08-21T00:00:00.000Z"
last_activity: 2026-08-21 -- Fase 16 (canales beta de Sparkle) completa: canal opcional en scripts/release-macos.sh + ExtractorUpdaterDelegate/toggle de opt-in en la app, checkpoint humano en Xcode verificado (Build Succeeded, toggle persistente)
progress:
  total_phases: 5
  completed_phases: 3
  total_plans: 4
  completed_plans: 4
  percent: 60
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-21)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fases 14, 15 y 16 completas. Siguiente: Fase 17 (Playwright/Chromium embebido — fase grande).

## Current Position

Phase: 16 — Canales beta de Sparkle (Complete)
Plan: 16-01 completo
Status: Complete — CHANNEL-01/CHANNEL-02 validados (checkpoint humano en Xcode)
Last activity: 2026-08-21 — `scripts/release-macos.sh`: `CHANNEL="${2:-}"` como 2º argumento opcional, `channel_args=(--channel "${CHANNEL}")` solo si no vacío en `_archive_and_generate_appcast()`, `--prerelease` + sufijo de título/notas en `_publish_release()`; sin canal, comportamiento idéntico al de antes de la fase. `RELEASING.md` documenta el uso y el pitfall de `MARKETING_VERSION` distinto para beta. `ExtractorAppApp.swift`: `ExtractorUpdaterDelegate: NSObject, SPUUpdaterDelegate` con `allowedChannels(for:)` leyendo `betaChannelOptIn` de `UserDefaults`. `SettingsViewModel`/`SettingsView`: toggle "Recibir actualizaciones beta" vía `@AppStorage`. Añadido de paso `scripts/setup-sparkle-local.sh` (utilidad para preparar Sparkle como paquete SPM local, mitigando el bug de red del buscador de paquetes de Xcode 26.6). Checkpoint humano en Xcode verificado: Build Succeeded sin necesitar Fix-it de nombre (`allowedChannels(for:)` aceptado tal cual), toggle persistente tras reabrir Preferencias.

```
v6.0 Progress: [======    ] 60% — Fases 14-16 completas, resto sin empezar
Phase 14: [==========] Complete (14-01 Python + 14-02 Swift)
Phase 15: [==========] Complete (15-01)
Phase 16: [==========] Complete (16-01)
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
- [v6.0]: `scripts/setup-sparkle-local.sh` añadido fuera del plan original de la Fase 16, como utilidad para mitigar el bug de red del buscador de paquetes SPM de Xcode 26.6 (ya documentado en 12-01-SUMMARY.md) — descarga y verifica por checksum el `.xcframework` de Sparkle y parchea `Package.swift` para referenciarlo por path local.
- [v6.0]: `allowedChannels(for:)` (no `allowedChannelsForUpdater`) fue el nombre correcto de la API de `SPUUpdaterDelegate` — confirmado en Xcode real (Build Succeeded sin Fix-it), cierra la nota de confianza media del research de la Fase 16.

### Pending Todos

- Avanzar a la Fase 17 (Playwright/Chromium embebido en el bundle) — fase grande, necesitará research corta + plan; comparable en alcance a la Fase 8 de v3.0.
- Decidir si commitear `scripts/setup-sparkle-local.sh` (añadido durante el checkpoint de la Fase 16, no estaba en el plan original).
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
Stopped at: Fases 14, 15 y 16 completas. Fase 16 (canales beta de Sparkle) verificada con checkpoint humano real en Xcode (Build Succeeded, toggle persistente). Pendiente: decidir sobre `scripts/setup-sparkle-local.sh` (commitear o no) y arrancar Fase 17 (Playwright/Chromium embebido — fase grande).
Resume file: .planning/phases/16-canales-sparkle/16-01-SUMMARY.md
