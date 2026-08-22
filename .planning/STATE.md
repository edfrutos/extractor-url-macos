---
gsd_state_version: 1.0
milestone: v6.0
milestone_name: Historial y Distribución Completa
status: executing
last_updated: "2026-08-22T00:00:00.000Z"
last_activity: 2026-08-22 -- Fase 17 (Playwright/Chromium embebido) completa: checkpoint humano en Mac real verificado (Build Succeeded, verify-bundle.sh 19 OK/0 FAIL, extracción real de SPA sin Playwright de sistema); dos bugs reales encontrados y corregidos durante el checkpoint (nombre de bundle Chromium cambiado, doble-firmado que borraba allow-jit)
progress:
  total_phases: 5
  completed_phases: 4
  total_plans: 5
  completed_plans: 5
  percent: 80
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-22)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fases 14, 15, 16 y 17 completas. Siguiente: Fase 18 (pulido técnico — última de v6.0).

## Current Position

Phase: 17 — Playwright/Chromium embebido en el bundle (Complete)
Plan: 17-01 completo
Status: Complete — BUNDLEJS-01/BUNDLEJS-02 validados (checkpoint humano en Mac real)
Last activity: 2026-08-22 — Checkpoint humano ejecutado en Mac real siguiendo `CHECKPOINT-HUMANO.md`: `Build Succeeded` (tras dos correcciones encontradas en el propio checkpoint), `verify-bundle.sh` → 19 OK/0 FAIL (BUNDLEJS-01/02 en verde), extracción real de `https://quotes.toscrape.com/js/` desde la app SwiftUI (⌘R) devolvió las citas correctamente sin Playwright instalado a nivel de sistema. Tamaño real medido: 886MB (`.app` Debug local, arm64 nativo) — documentado en `RELEASING.md` 3.5 junto con la estimación inicial (~250-350MB de incremento), más baja que la realidad. Dos bugs reales encontrados y corregidos en vivo (no visibles desde el sandbox de planificación): (1) Playwright 1.62.0 distribuye "Chrome for Testing" (`Google Chrome for Testing.app`), no `Chromium.app` clásico — corregido descubriendo `.app`/`.framework` por patrón en `bundle-playwright.sh`/`verify-bundle.sh`/`release-macos.sh` en vez de hardcodear el nombre, confirmado descargando el zip real de `cdn.playwright.dev` e inspeccionando su estructura sin necesidad de macOS; (2) doble-firmado (ejecutable interno + `.app` del Helper por separado) borraba `allow-jit` de los Helpers Renderer/GPU, detectado por `verify-bundle.sh` (BUNDLEJS-01 en FAIL pese a que BUNDLEJS-02 funcional pasaba igual, por no forzarse hardened runtime en local) — corregido consolidando en una sola llamada `codesign` por Helper. Paso 6 del checkpoint (release real con notarización) omitido deliberadamente para no gastar cuota — deferido al próximo release real. `17-01-SUMMARY.md` escrito con el detalle completo. ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md actualizados. Nada de esto está commiteado todavía.

```
v6.0 Progress: [========  ] 80% — Fases 14-17 completas, resto sin empezar
Phase 14: [==========] Complete (14-01 Python + 14-02 Swift)
Phase 15: [==========] Complete (15-01)
Phase 16: [==========] Complete (16-01)
Phase 17: [==========] Complete (17-01, checkpoint humano verificado en Mac real)
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
- [v6.0]: Fase 17 vendoriza Chromium (vía Playwright) para UNA sola arquitectura — la nativa del Mac de build (normalmente arm64) — no arm64+x64. Decisión explícita del usuario tras la research (17-RESEARCH.md), que había encontrado que dos árboles sin fusionar rondan 500-700MB (vs. ~300MB de referencia del ROADMAP) y requieren Rosetta 2 en el Mac de build. Trade-off aceptado: en la arquitectura no nativa, el fallback JS embebido no está disponible — degrada a HTML estático vía el mismo manejo de excepciones que `_fetch_via_playwright()` ya tiene desde la Fase 11 (no es una regresión de robustez).
- [v6.0]: El tamaño real medido del `.app` con Chromium embebido es 886MB (Debug local, arm64 nativo), sensiblemente por encima de la estimación de ~250-350MB de incremento del research — Playwright 1.62.0 distribuye "Chrome for Testing" (build más pesado, con locales de decenas de idiomas), no el snapshot de Chromium más ligero que asumía la estimación inicial. Documentado como cifra real en `RELEASING.md` en vez de forzar que coincida con la estimación.
- [v6.0]: `.app`/`.framework` de Chromium descubiertos por patrón (`find -name "*.app"` / `"*.framework"`) en vez de hardcodear "Chromium.app"/"Chromium Framework.framework" — el nombre real es "Google Chrome for Testing.app" en Playwright 1.62.0, y descubrir por patrón evita que otro cambio de naming aguas arriba vuelva a romper el bundling.
- [v6.0]: Codesigning de cada Helper de Chromium en una sola llamada `codesign` sobre el `.app` (no ejecutable + `.app` por separado) — firmar el ejecutable interno con entitlements y luego resellar el `.app` contenedor sin entitlements borra el `allow-jit` recién aplicado. Bug real detectado por `verify-bundle.sh` en el checkpoint de la Fase 17.

### Pending Todos

- Avanzar a la Fase 18 (pulido técnico — última fase de v6.0): `POLISH-01`/`POLISH-02`, research/planning aún por definir.
- Decidir si commitear `scripts/setup-sparkle-local.sh` (añadido durante el checkpoint de la Fase 16, no estaba en el plan original) — sigue pendiente, no bloqueante.
- Commitear todos los cambios de la Fase 17 (nada está commiteado todavía).
- Medir el tamaño real de un build Release/archivado (con strip) en el próximo release real — la cifra de 886MB es de un build Debug local, probablemente algo menor en Release.
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01/15-01 en el `.venv` real del Mac.

### Blockers/Concerns

- Ninguno bloqueante.
- **Bug real de Xcode 26.6 confirmado** (relacionado con `POLISH-02`): `GENERATE_INFOPLIST_FILE = YES` no sintetiza NINGUNA clave `INFOPLIST_KEY_*` personalizada en el `Info.plist` generado (`SUFeedURL`, `SUPublicEDKey`, `NSHumanReadableCopyright` — las 3 ausentes, confirmado con DerivedData borrado por completo, no era caché). Efecto observado: "Buscar actualizaciones…" fallaba con `You must specify the URL of the appcast as the SUFeedURL key...`. Corregido con un `Info.plist` físico parcial (`ExtractorApp/Info.plist`, solo esas 3 claves) + `INFOPLIST_FILE` en build settings, combinado con `GENERATE_INFOPLIST_FILE = YES` (mecanismo de merge documentado por Apple) — verificado en Mac real: las claves aparecen en el `.app` compilado y "Buscar actualizaciones…" funciona sin error.
- Notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17) no se ha ejecutado todavía — deferida al próximo release real para no gastar cuota. El codesigning en sí ya está verificado (`codesign --verify --deep --strict` + `allow-jit` correctos), así que el riesgo residual es bajo, pero la notarización real (`notarytool submit --wait`) con un bundle de ~900MB no se ha probado y podría tardar sensiblemente más de lo habitual (ya documentado en `RELEASING.md` 3.5).

## Deferred Items (desde v6.0)

| Category | Item | Status |
|----------|------|--------|
| Distribución | Notarización para distribución pública (App Store, web pública) | v7+ |
| Funcionalidad | Actualización automática del runtime Python bundleado | v7+ |
| Funcionalidad | Flags `--no-images`, `--no-links`, `--clipboard` | v7+ |
| Funcionalidad | Rollouts por fases de Sparkle (`sparkle:phasedRolloutInterval`) | v7+ si hay más usuarios |

## Session Continuity

Last session: 2026-08-22T00:00:00Z
Stopped at: Fase 17 (Playwright/Chromium embebido) completa y verificada en Mac real. Checkpoint humano ejecutado paso a paso: build inicial falló (nombre de bundle Chromium cambiado, corregido descubriendo `.app`/`.framework` por patrón), segundo build compiló pero `verify-bundle.sh` detectó `allow-jit` ausente en el Helper Renderer (bug de doble-firmado, corregido consolidando en una sola llamada `codesign` por Helper), tercer build → `verify-bundle.sh` 19 OK/0 FAIL, extracción real de `quotes.toscrape.com/js/` desde la app confirmó el fallback JS funcionando end-to-end. Tamaño real medido: 886MB. `17-01-SUMMARY.md` escrito; ROADMAP.md/PROJECT.md/REQUIREMENTS.md/RELEASING.md actualizados con BUNDLEJS-01/02 validados y los hallazgos reales. Paso 6 (release real con notarización) omitido deliberadamente. Nada de esto está commiteado todavía — pendiente preguntar al usuario si quiere commitear/pushear y si sigue con la Fase 18.
Resume file: ninguno — Fase 17 cerrada, siguiente paso es decidir commit y avanzar a Fase 18 (research/planning pendiente de iniciar)
