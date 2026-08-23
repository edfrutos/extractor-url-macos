---
gsd_state_version: 1.0
milestone: v7.0
milestone_name: (nombre por definir)
status: executing
last_updated: "2026-08-23T03:00:00.000Z"
last_activity: 2026-08-23 -- Fase 20 (rollouts por fases de Sparkle) completa: ROLLOUT_INTERVAL_SECONDS (env var) -> --phased-rollout-interval en generate_appcast, mismo patrón que --channel de la Fase 16. Flag confirmado inspeccionando el binario real. Mecánica documentada en RELEASING.md 3.6.
progress:
  total_phases: 4
  completed_phases: 2
  total_plans: 2
  completed_plans: 2
  percent: 50
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-23)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** v6.0 completo y cerrado (Fases 14-18). v7.0 en marcha: Fases 19-20 completas. Siguiente: Fase 21 (auto-actualización del runtime Python embebido) — necesita research previa, sin plan todavía.

## Current Position

Phase: 20 — Rollouts por fases de Sparkle (Complete)
Plan: 20-01 completo
Status: Complete — ROLLOUT-01/ROLLOUT-02 validados en el sandbox (script bash, sin checkpoint humano necesario)
Last activity: 2026-08-23 — Implementado `ROLLOUT_INTERVAL_SECONDS` directamente en conversación (sin research doc separado — se verificó el flag real de `generate_appcast` inspeccionando el binario Mach-O ya presente en `.build-cache/sparkle-tools/bin/generate_appcast`, extrayendo sus strings ASCII con Python ya que `strings` no está instalado en este sandbox, en vez de asumir el nombre del flag de memoria). Confirmado: `--phased-rollout-interval <segundos>` es el flag real; Sparkle hardcodea 7 grupos, duración total = intervalo × 7, no aplica a comprobación manual de actualizaciones ni a updates críticos (confirmado también contra la documentación oficial de Sparkle vía WebFetch). `scripts/release-macos.sh`: `ROLLOUT_INTERVAL_SECONDS="${ROLLOUT_INTERVAL_SECONDS:-}"` (variable de entorno, no 3er posicional, para no reordenar `<version> [canal]`), validación de entero positivo en `_preflight_checks()`, `rollout_args=()` en `_archive_and_generate_appcast()` mismo patrón que `channel_args`. `RELEASING.md` nueva sección 3.6 documentando la mecánica, la limitación de comprobación manual, y la forma práctica de abortar un rollout (editar `appcast.xml` a mano, ya es un archivo revisado manualmente desde la Fase 13). `bash -n`/`shellcheck` limpios; lógica de construcción de argumentos probada aislada (4 combinaciones canal/rollout) y validación de entero probada con casos límite. No se pudo probar contra un `generate_appcast` real en ejecución (necesita Xcode/notarización). `20-01-SUMMARY.md` escrito. ROADMAP.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md actualizados. Nada de esto está commiteado todavía (la Fase 19 sí — commit `8fbc9cc`).

```
v7.0 Progress: [=====     ] 50% — Fases 19-20 completas, resto sin empezar.
Phase 19: [==========] Complete (19-01, verificado en sandbox sin Mac)
Phase 20: [==========] Complete (20-01, verificado en sandbox sin Mac/Xcode)
Phase 21: [          ] 0/? planes (auto-actualización runtime Python -- necesita research previa)
Phase 22: [          ] 0/? planes (notarización distribución pública vía web, no App Store)
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
- [v6.0]: `_bump_version` identifica bloques `XCBuildConfiguration` por `PRODUCT_BUNDLE_IDENTIFIER` exacto (no por posición/UUID) — un `sed` global sobre todo el `.pbxproj` bumpeaba también `ExtractorAppTests`, que comparte los mismos valores de versión por coincidencia.
- [v6.0]: POLISH-02 cerrado sin migrar Sparkle a paquete remoto — el bug de búsqueda de Xcode 26.6 no tiene causa raíz confirmada y el usuario decidió explícitamente no invertir tiempo probando el fix candidato ahora. El paquete local sigue siendo el mecanismo de producción, ya verificado (Fases 12/16).
- [v7.0]: Alcance = las 4 áreas restantes de `Deferred Items` de v6.0 — flags CLI, rollouts Sparkle, auto-actualización runtime, notarización distribución pública. El usuario eligió explícitamente las 4 al preguntársele qué priorizar (no un subconjunto).
- [v7.0]: Orden de fases 19→22 propuesto por Claude de menor a mayor complejidad/incertidumbre (ninguna fase depende de una posterior) y confirmado explícitamente por el usuario, mismo patrón que v6.0.
- [v7.0]: "Notarización distribución pública" = web pública (GitHub Releases o similar), explícitamente NO Mac App Store — el App Store implicaría revisar App Sandbox (hoy OFF), Apple Review, App Store Connect; mucho más grande y contradice el Out of Scope ya establecido. Confirmado con una pregunta directa al usuario.
- [v7.0]: Fase 19 ejecutada directamente en conversación, sin research/plan formales previos — fase pequeña, sin dependencias nuevas, patrones ya establecidos (mismo estilo que `--js`/`--no-js` de la Fase 15). Decisión implícita al no bloquear en pedir research cuando el usuario dijo "Fase 19" — documentado igualmente con `19-01-SUMMARY.md` tras la implementación.
- [v7.0]: `--clipboard` vía `subprocess.run(["pbcopy"], ...)`, no una dependencia pip nueva — el proyecto es macOS-only, `pbcopy` ya está en cualquier Mac, evita tocar el runtime bundleado (Fase 8) solo para esto.
- [v7.0]: `--clipboard` es aditivo (copia sin reemplazar `--json`/`-o`/stdout) — interpretación más segura de "combinable sin romper contratos previos" del Success Criterion 4.
- [v7.0]: `ROLLOUT_INTERVAL_SECONDS` vía variable de entorno, no un 3er argumento posicional en `release-macos.sh` — evita reordenar `<version> [canal]` ya establecido en la Fase 16; se compone limpiamente con cualquier combinación.
- [v7.0]: Flag `--phased-rollout-interval` de `generate_appcast` confirmado inspeccionando el binario real (extracción de strings con Python) en vez de asumirlo — el binario ya estaba en `.build-cache/sparkle-tools/` desde la Fase 12.
- [v7.0]: Aborto de un rollout en marcha = editar `appcast.xml` a mano (quitar `sparkle:phasedRolloutInterval`), no un comando nuevo — reutiliza el flujo de revisión manual del appcast ya establecido en la Fase 13, Sparkle no documenta un mecanismo oficial de aborto.

### Pending Todos

- Commitear los cambios de la Fase 20 (ROADMAP.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md/STATE.md + `scripts/release-macos.sh`/`RELEASING.md`) — nada está commiteado todavía.
- Iniciar research/plan de la Fase 21 (auto-actualización del runtime Python embebido) — marcada explícitamente como necesitando research previa (mecanismo de actualización sin romper la firma del `.app`).
- Recomendado no bloqueante: probar `python extractor_url.py <url> --clipboard` en un Mac real (sandbox Linux no tiene `pbcopy`, solo verificado con mocks) — Fase 19.
- Recomendado no bloqueante: en el próximo release real con `ROLLOUT_INTERVAL_SECONDS` puesto, confirmar en el `appcast.xml` resultante que `<sparkle:phasedRolloutInterval>` aparece con el valor esperado — Fase 20.
- Decidir si commitear `scripts/setup-sparkle-local.sh` (añadido durante el checkpoint de la Fase 16, no estaba en el plan original) — sigue pendiente, no bloqueante.
- Medir el tamaño real de un build Release/archivado (con strip) en el próximo release real — la cifra de 886MB (Fase 17) es de un build Debug local, probablemente algo menor en Release.
- Ejecutar notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17, deferido) en el próximo release real — verificar tiempos y que `_resign_bundled_chromium()` funciona end-to-end con Developer ID real.
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01/15-01 en el `.venv` real del Mac.
- Recomendado no bloqueante: si el usuario quiere reabrir POLISH-02 en el futuro, probar `defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 1` + reinicio de Xcode en su Mac real (ver `18-RESEARCH.md`).

### Blockers/Concerns

- Ninguno bloqueante. v6.0 está completo, v7.0 recién definido sin trabajo de código empezado.
- **Bug real de Xcode 26.6 confirmado** (relacionado con `POLISH-02`): `GENERATE_INFOPLIST_FILE = YES` no sintetiza NINGUNA clave `INFOPLIST_KEY_*` personalizada en el `Info.plist` generado (`SUFeedURL`, `SUPublicEDKey`, `NSHumanReadableCopyright` — las 3 ausentes, confirmado con DerivedData borrado por completo, no era caché). Efecto observado: "Buscar actualizaciones…" fallaba con `You must specify the URL of the appcast as the SUFeedURL key...`. Corregido con un `Info.plist` físico parcial (`ExtractorApp/Info.plist`, solo esas 3 claves) + `INFOPLIST_FILE` en build settings, combinado con `GENERATE_INFOPLIST_FILE = YES` (mecanismo de merge documentado por Apple) — verificado en Mac real: las claves aparecen en el `.app` compilado y "Buscar actualizaciones…" funciona sin error.
- Notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17) no se ha ejecutado todavía — deferida al próximo release real para no gastar cuota. El codesigning en sí ya está verificado (`codesign --verify --deep --strict` + `allow-jit` correctos), así que el riesgo residual es bajo, pero la notarización real (`notarytool submit --wait`) con un bundle de ~900MB no se ha probado y podría tardar sensiblemente más de lo habitual (ya documentado en `RELEASING.md` 3.5).
- El bug de búsqueda de paquetes de Xcode 26.6 (POLISH-02) sigue sin resolverse — el paquete local de Sparkle es un workaround funcional pero no se actualizará solo a nuevas versiones; revisar si el repo se clona en otra máquina sin `.build-cache/Sparkle` presente (necesitará repetir `scripts/setup-sparkle-local.sh`).

## Deferred Items

| Category | Item | Status |
|----------|------|--------|
| Técnico | Migrar Sparkle a paquete remoto real (POLISH-02) si se resuelve el bug de Xcode 26.6 | v8+ si el usuario quiere reabrirlo — ver `18-RESEARCH.md` |
| Distribución | Mac App Store | Explícitamente fuera de alcance de v7.0 (ver Decisions) — sin fecha |

Los 4 ítems que antes estaban aquí como "v7+" (notarización distribución pública, auto-actualización runtime, flags CLI, rollouts Sparkle) pasaron a ser el alcance activo de v7.0 — ver Current Position y ROADMAP.md `## v7.0`.

## Session Continuity

Last session: 2026-08-23T03:00:00Z
Stopped at: **Fase 20 completa** (código + docs), nada commiteado todavía. Secuencia de esta sesión: (1) commit de la Fase 18/cierre de v6.0 (`f74f6dd`); (2) definición de v7.0 (alcance, orden, aclaración App Store vs. web), commit `d26f264`; (3) Fase 19 (flags de filtrado CLI) implementada y verificada, commit `8fbc9cc`; (4) usuario dijo "seguimos" — Fase 20 (rollouts por fases de Sparkle) implementada directamente: confirmado el flag real de `generate_appcast` inspeccionando el binario ya presente en el repo (`.build-cache/sparkle-tools/`) antes de codificar, `ROLLOUT_INTERVAL_SECONDS` añadido a `release-macos.sh`, mecánica documentada en `RELEASING.md` 3.6. `bash -n`/`shellcheck` limpios, lógica de argumentos probada aislada. `20-01-SUMMARY.md` escrito. ROADMAP.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md actualizados marcando Fase 20 completa. Nada de esto está commiteado todavía. Próximo paso natural: preguntar al usuario si quiere commitear, y si quiere iniciar la Fase 21 (necesita research previa).
Resume file: ninguno — Fase 20 completa, pendiente commit y decidir si se sigue con la Fase 21 (research)
