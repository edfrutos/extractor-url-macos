---
gsd_state_version: 1.0
milestone: v7.0
milestone_name: (nombre por definir)
status: executing
last_updated: "2026-08-23T04:00:00.000Z"
last_activity: 2026-08-23 -- Fase 21 (auto-actualizacion runtime) implementada tras research: RuntimeUpdater.swift (nuevo) + PythonBridge.swift + SettingsView/ViewModel + scripts/build_runtime_update.py. Alcance acotado a dependencias Python puras (confirmado con el usuario) para evitar la incertidumbre de Gatekeeper con binarios sueltos. Checkpoint humano pendiente (necesita Xcode real).
progress:
  total_phases: 4
  completed_phases: 2
  total_plans: 3
  completed_plans: 2
  percent: 50
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-23)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** v6.0 completo y cerrado (Fases 14-18). v7.0 en marcha: Fases 19-20 completas y commiteadas. Fase 21 implementada, checkpoint humano pendiente (necesita Xcode real). Siguiente tras el checkpoint: Fase 22 (notarización distribución pública).

## Current Position

Phase: 21 — Auto-actualización del runtime Python embebido (Implementada, checkpoint humano pendiente)
Plan: 21-01 implementado (sin research/plan formales por separado — research se hizo inline, ver `21-RESEARCH.md`)
Status: Código escrito y verificado donde el sandbox lo permite (script Python + lógica pura) — falta el checkpoint humano en Xcode (compilación Swift, red real, y sobre todo confirmar que no aparece ningún aviso de Gatekeeper)
Last activity: 2026-08-23 — Investigación previa a fondo (sin poder probar en Mac real): binarios sueltos no se pueden staplear, un intérprete descargado y ejecutado probablemente dispara Gatekeeper, pero los archivos `.py` puros que el intérprete YA bundleado/notarizado simplemente `import`ea como datos NO pasan por Gatekeeper en absoluto. Presentado al usuario, quien confirmó explícitamente acotar el alcance de v1 a las dependencias Python puras (`requests`/`beautifulsoup4`/`markdownify`/`trafilatura`), dejando intérprete/`lxml`/Chromium fuera (siguen actualizándose solo con un release completo). Implementado: `scripts/build_runtime_update.py` (nuevo) — pip install limpio + detección automática de paquetes con binarios compilados (`.so`/`.dylib`/`.pyd`, hoy `lxml`/`charset_normalizer`/`regex`) para excluirlos del zip + manifiesto JSON con sha256 — **ejecutado de verdad en el sandbox**, confirmado: zip sin binarios compilados, checksum correcto, manifiesto válido, `pylint`/`mypy` 10/10 limpios. `RuntimeUpdater.swift` (nuevo, Swift): descarga manifiesto+zip, verifica SHA-256, extrae vía `/usr/bin/unzip` directo (no Archive Utility/Finder) a Application Support, y verifica con una importación real contra el intérprete bundleado antes de activar el override — si cualquier paso falla, la versión activa no cambia (PYRUNTIME-02 sin lógica de rollback explícita, gratis por diseño). `PythonBridge.swift`: antepone el override al PYTHONPATH del bundle sin tocar el `.app` firmado. `SettingsViewModel.swift`/`SettingsView.swift`: nueva sección "Dependencias del motor" en Preferencias con botón manual "Buscar actualización" (`Task.detached` con `[weak self]`, mismo patrón que `refreshOperatingMode()` de la Fase 10, para no bloquear MainActor con el `Process()` síncrono). `RuntimeUpdaterTests.swift` (nuevo, 4 tests — decodificación de manifiesto, mensajes de error, sin override por defecto). Confirmado que el proyecto usa `PBXFileSystemSynchronizedRootGroup` (Xcode 16+) — los archivos nuevos no necesitan edición de `project.pbxproj`, a diferencia de la Fase 17. `RELEASING.md` nueva sección 3.7. `21-RESEARCH.md`/`CHECKPOINT-HUMANO.md` escritos. Nada de esto está commiteado todavía.

```
v7.0 Progress: [=====     ] 50% — Fases 19-20 completas y commiteadas, Fase 21 implementada (checkpoint pendiente).
Phase 19: [==========] Complete (19-01, commit 8fbc9cc)
Phase 20: [==========] Complete (20-01, commit 42a3c32)
Phase 21: [========  ] Implementada, checkpoint humano pendiente (21-01, sin commitear)
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
- [v7.0]: Fase 21 v1 acota el alcance a dependencias Python puras (`requests`/`beautifulsoup4`/`markdownify`/`trafilatura`) — nunca el intérprete, `lxml` ni Chromium. Decisión explícita del usuario tras la research (`21-RESEARCH.md`), que encontró que actualizar binarios sueltos en tiempo de ejecución tiene incertidumbre real de Gatekeeper (no se pueden staplear, dependen de verificación online), mientras que archivos `.py` puros nunca pasan por Gatekeeper al ser solo `import`eados como datos.
- [v7.0]: Mecanismo de override = directorio antepuesto al `PYTHONPATH` del bundle (`~/Library/Application Support/ExtractorApp/python-packages-override/<version>/`), nunca reemplazo de archivos dentro del `.app` firmado — evita romper la firma de código por completo, y da degradación segura (PYRUNTIME-02) casi gratis: si el override no existe o falla la verificación, `PythonBridge` simplemente no lo antepone.
- [v7.0]: `scripts/build_runtime_update.py` detecta y excluye automáticamente cualquier paquete con binarios compilados (`.so`/`.dylib`/`.pyd`) en vez de mantener una lista fija de nombres a mano — más robusto ante cambios futuros en las dependencias transitivas (hoy excluye `lxml`/`charset_normalizer`/`regex`, verificado ejecutando el script de verdad en el sandbox).
- [v7.0]: Verificación antes de activar un override = importación real contra el intérprete bundleado (`python -c "import requests, bs4, markdownify, trafilatura"`), no solo el checksum SHA-256 — el checksum solo prueba que la descarga no se corrompió, no que los paquetes funcionan con esta versión concreta del intérprete.
- [v7.0]: Publicación del paquete de runtime como GitHub Release **separado** del release de la app (`runtime-<version>`, no el mismo tag) — evita mezclar los ciclos de vida de ambos mecanismos de actualización.

### Pending Todos

- Completar el checkpoint humano de la Fase 21 en Xcode real (ver `CHECKPOINT-HUMANO.md`) — build, tests, y sobre todo confirmar que aplicar una actualización de runtime no dispara ningún aviso de Gatekeeper.
- Commitear los cambios de la Fase 21 una vez completado el checkpoint (o antes, si el usuario prefiere commitear el código ya escrito primero).
- Recomendado no bloqueante: probar `python extractor_url.py <url> --clipboard` en un Mac real (sandbox Linux no tiene `pbcopy`, solo verificado con mocks) — Fase 19.
- Recomendado no bloqueante: en el próximo release real con `ROLLOUT_INTERVAL_SECONDS` puesto, confirmar en el `appcast.xml` resultante que `<sparkle:phasedRolloutInterval>` aparece con el valor esperado — Fase 20.
- Decidir si commitear `scripts/setup-sparkle-local.sh` (añadido durante el checkpoint de la Fase 16, no estaba en el plan original) — sigue pendiente, no bloqueante.
- Medir el tamaño real de un build Release/archivado (con strip) en el próximo release real — la cifra de 886MB (Fase 17) es de un build Debug local, probablemente algo menor en Release.
- Ejecutar notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17, deferido) en el próximo release real — verificar tiempos y que `_resign_bundled_chromium()` funciona end-to-end con Developer ID real.
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01/15-01 en el `.venv` real del Mac.
- Recomendado no bloqueante: si el usuario quiere reabrir POLISH-02 en el futuro, probar `defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 1` + reinicio de Xcode en su Mac real (ver `18-RESEARCH.md`).

### Blockers/Concerns

- Ninguno bloqueante para continuar, pero la Fase 21 no se puede cerrar sin el checkpoint humano — la pregunta central (¿dispara Gatekeeper algún aviso al aplicar una actualización de runtime?) solo se puede confirmar en un Mac real, no en este sandbox.
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

Last session: 2026-08-23T04:00:00Z
Stopped at: **Fase 21 implementada, checkpoint humano pendiente**. Secuencia de esta sesión: (1) commit de la Fase 18/cierre de v6.0 (`f74f6dd`); (2) definición de v7.0, commit `d26f264`; (3) Fase 19 implementada y commiteada (`8fbc9cc`); (4) Fase 20 implementada y commiteada (`42a3c32`); (5) usuario dijo "adelante" — Fase 21: research a fondo sobre Gatekeeper/notarización de binarios sueltos (sin poder probar en Mac real, por búsqueda web), presentada al usuario con una pregunta de alcance explícita — confirmó acotar v1 a dependencias Python puras. Implementado `scripts/build_runtime_update.py` (ejecutado y verificado de verdad en el sandbox), `RuntimeUpdater.swift`/`PythonBridge.swift`/`SettingsViewModel.swift`/`SettingsView.swift`/`RuntimeUpdaterTests.swift` (Swift, sin poder compilar en este sandbox Linux — revisado a mano: llaves balanceadas, patrones de concurrencia consistentes con los ya establecidos en `refreshOperatingMode()`). Confirmado que el proyecto usa grupos sincronizados de Xcode 16, así que los archivos Swift nuevos no necesitan tocar `project.pbxproj`. `21-RESEARCH.md`/`CHECKPOINT-HUMANO.md` escritos. ROADMAP.md/STATE.md actualizados (PROJECT.md/REQUIREMENTS.md/MILESTONES.md pendientes de esta misma pasada). Nada de esto está commiteado todavía. Próximo paso natural: preguntar al usuario si quiere commitear ahora (código sin verificar en Xcode) o esperar al checkpoint humano primero.
Resume file: .planning/phases/21-auto-actualizacion-runtime/CHECKPOINT-HUMANO.md
