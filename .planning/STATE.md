---
gsd_state_version: 1.0
milestone: v8.0
milestone_name: (nombre por definir)
status: complete
last_updated: "2026-08-27T00:00:00.000Z"
last_activity: 2026-08-27 -- v8.0 / Fase 23 CERRADA. SC1 (.app Release v2.1 = 882MB, en RELEASING.md 3.5), SC2 (release publico v2.1 notarizado+stapled, cero Mach-O sin hardened runtime), SC3 (--clipboard vs pbcopy real, aditivo con -o) y SC5 (setup-sparkle-local.sh ya trackeado) verificados. Pipeline endurecido (af48439) y tagging de release arreglado (cc1af03). Tag local v3.1 borrado; v2.1 se deja como esta. pytest 67/67, pylint 10.00/10, mypy limpio (sandbox). SC4/SC6 diferidos-condicionales a un release futuro. SUMMARY en .planning/phases/23-verificacion-release-real/23-01-SUMMARY.md. Commits af48439..cc1af03 en origin/main.
progress:
  total_phases: 1
  completed_phases: 1
  total_plans: 1
  completed_plans: 1
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-25)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** v6.0, v7.0 y **v8.0 completos y cerrados**. No hay milestone activo ni backlog de funcionalidad nueva. Un release `2.2` de pura validación se descartó explícitamente (2026-08-28) — no hay cambios de cara al usuario desde `v2.1`. El pipeline endurecido y SC4/SC6 se validarán en el próximo release que lleve una feature o fix real.

## Current Position

Phase: 23 — Verificación de release real y cierre de deuda técnica ✅ **Complete** (2026-08-27)
Plan: 23-01 informal (sin PLAN.md) — SUMMARY en `.planning/phases/23-verificacion-release-real/23-01-SUMMARY.md`
Status: **v8.0 cerrado.** SC1/SC2/SC3/SC5 verificados contra el release público `v2.1`; pipeline endurecido (`af48439`) y tagging de release arreglado (`cc1af03`). SC4/SC6 diferidos-condicionales a un release futuro (no bloquean el cierre). `pytest` 67/67 · `pylint` 10.00/10 · `mypy` limpio (sandbox).
Last activity: 2026-08-27 — Ejecución completa de la Fase 23 en conversación. Partiendo de 3 scripts modificados sin commitear que corregían rechazos reales de `notarytool` del release `v2.1`: se validaron (`bash -n` + `shellcheck`), se limpió el `Icon\r` + `.gitignore` y se commitearon (`af48439`). Verificado en el Mac real del usuario contra el `.app` publicado en `v2.1`: SC1 (882 MB), SC2 (`spctl`/`stapler`/`codesign` + barrido de hardened runtime, todo OK), SC3 (`--clipboard` vs `pbcopy` real, aditivo con `-o`). SC5 ya estaba resuelto (`setup-sparkle-local.sh` trackeado desde `5c3d663`). Tag local espurio `v3.1` borrado; sobre `v2.1` mal ubicado, el usuario decidió dejarlo y se arregló la causa raíz para v2.2+ (`cc1af03`: el guion de `release-macos.sh` ahora imprime `git tag -f` + `git push -f origin vX.Y`; `RELEASING.md` §2 actualizado). `pytest`/`pylint`/`mypy` corridos en un venv temporal del sandbox (código Python puro). SUMMARY escrito, ROADMAP/MILESTONES/STATE cerrados.

```
v8.0 Progress: [==========] 100% — Fase 23 completa. SC1/SC2/SC3/SC5 ✓; SC4/SC6 diferidos-condicionales.
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
- [v7.0]: Confirmado en checkpoint humano real — actualizar dependencias Python puras vía override de `PYTHONPATH` **no dispara ningún aviso de Gatekeeper**, ni siquiera tras un timeout de red real a mitad del proceso. Valida el hallazgo central de `21-RESEARCH.md` con un caso real, no solo búsqueda web.
- [v7.0]: Mensaje de error de `.failed(message:)` movido al texto de estado principal (antes solo en una etiqueta secundaria diminuta) — bug real de UI encontrado en el checkpoint humano cuando un timeout de red genuino pasó casi desapercibido.
- [v7.0]: Fase 22 no necesitó ningún cambio de pipeline — el `.app` ya se notariza+staplea y se publica en un repo GitHub público desde la Fase 13. La fase fue verificación (`spctl`) y corrección de documentación contradictoria, no implementación nueva.
- [v7.0]: Verificación de PUBLISH-02 con `spctl -a -vvv --type execute` contra un release YA publicado (no un build local) — `spctl` evalúa la firma/notarización del binario en sí, no el estado de confianza de la máquina, así que no hace falta un Mac limpio de verdad para simular lo que vería un descargador nuevo.
- [v7.0]: Bugs de layout de `ContentView.swift` (resultCard no llenaba la ventana, etiquetas solapadas con pickers) corregidos fuera de fase, a petición explícita del usuario tras probar la Fase 21 — no forman parte de ningún requirement de v7.0, pero se atendieron porque el usuario las reportó en el flujo natural de la conversación.
- [v8.0]: Fase 23 arrancada con un plan informal (`23-01`, sin `PLAN.md` formal) — los fixes salieron directamente de los rechazos reales de `notarytool` del release v2.1, no de un research/planning previo. Mismo criterio que la Fase 19 (fase pequeña, patrones ya establecidos, se documenta a posteriori).
- [v8.0]: Firma de ejecutables de Chromium **por descubrimiento** (`find -type f -perm -u+x`), no por nombre fijo — `notarytool` rechaza CUALQUIER ejecutable sin hardened runtime aunque no se use en un build headless. `chrome_crashpad_handler` a mano dejaba sin firmar `web_app_shortcut_copier`/`app_mode_loader` y cualquier otro que Chrome for Testing añada aguas arriba.
- [v8.0]: Firma de las instalaciones hermanas bajo `.local-browsers/` (`chromium_headless_shell-*`, `ffmpeg-*`) — árboles planos sin `.app` ni Framework; basta con firmar cada ejecutable suelto. El patrón `chromium-*` nunca las cazaba (`chromium_headless_shell` lleva guion bajo) y `ffmpeg-*` no se contemplaba.
- [v8.0]: `ditto` de empaquetado sin `--sequesterRsrc` — un `.app` moderno totalmente firmado no usa resource forks HFS+; con `--sequesterRsrc`, `ditto` crea un `__MACOSX/` dentro del zip que `notarytool` intenta notarizar y genera decenas de avisos de ruido. Mismo comando que la guía oficial de notarización de Apple.
- [v8.0]: Ante rechazo de notarización, `release-macos.sh` pide ahora `xcrun notarytool log <id>` explícitamente — el resumen de `submit --wait` solo trae `id`/`status`, no las razones del rechazo (el mensaje anterior decía "log completo arriba" y era falso).
- [v8.0]: `"${array[@]+"${array[@]}"}"` en vez de `"${array[@]}"` a secas en `release-macos.sh` — bajo `set -u`, bash 3.2 (el de macOS de serie) trata un array vacío como variable no definida y aborta con "unbound variable". Invisible en `bash -n`/linter estático; solo se manifiesta en ejecución con un array genuinamente vacío.
- [v8.0]: El recurso de icono de carpeta de macOS (`Icon\r`) se elimina y se añade `Icon?` al `.gitignore` — artefacto local sin valor en el repo.

### Pending Todos

Nada activo — v8.0 cerrado. Ítems que reaparecen cuando se lance el próximo release real:

- **SC4 (MAINT-04, condicional)**: si el release usa `ROLLOUT_INTERVAL_SECONDS`, confirmar `<sparkle:phasedRolloutInterval>` en el `appcast.xml` resultante.
- **SC6 (MAINT-06, condicional)**: durante el build, vigilar si reaparece el bug de `Info.plist` de Xcode 27 beta (`CFBundleIdentifier` con un log de Sparkle) — ver Blockers/Concerns.
- Ejercitar el **pipeline scriptado endurecido** (`af48439`) end-to-end — el `.app` público de `v2.1` se notarizó bien pero con un arreglo manual; falta comprobar que `release-macos.sh` lo hace solo.
- Al taggear el próximo release, seguir el guion impreso (incluye ya `git tag -f` + `git push -f origin vX.Y`) para que el tag caiga en el commit `chore(release)`.
- Subir `MARKETING_VERSION` de `2.1` a `2.2`+ (`release-macos.sh` lo hace).
- Recomendado no bloqueante: `pytest`/`pylint`/`mypy` en el `.venv` real del Mac — en el sandbox (Python 3.14 Linux, venv temporal) dieron 67/67 · 10.00/10 · limpio, pero el `.venv` del repo es de macOS.
- Recomendado no bloqueante: si se reabre POLISH-02 en el futuro, probar `defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 1` + reinicio de Xcode (ver `18-RESEARCH.md`).

### Blockers/Concerns

- Ninguno bloqueante. v6.0, v7.0 y v8.0 completos y cerrados. Sin milestone activo. SC4/SC6 de la Fase 23 quedaron como criterios condicionales a un release futuro (ver Pending Todos), no como bloqueos.
- **SC2 — notarización real con Chromium: VERIFICADA** (2026-08-27, contra el release público `v2.1`, no un build local). El `af48439` original nació de un rechazo de `notarytool` en un intento previo, pero el `.app` que de verdad se publicó pasó todas las comprobaciones en Mac real:
  - `spctl -a -vvv --type execute` → `accepted`, `source=Notarized Developer ID` (Eugenio de Frutos Sanchez, V29BTBRY6G).
  - `xcrun stapler validate` → ticket grapado OK.
  - `codesign --verify --deep --strict` → `valid on disk` + `satisfies its Designated Requirement`.
  - Barrido de Mach-O sin flag `runtime` en todo el bundle → **vacío** (Chromium `chrome-headless-shell`/`ffmpeg` y ejecutables sueltos de `Helpers/` incluidos).
  - Conclusión: el zip público de v2.1 está notarizado y bien firmado — **no hay que rehacer el binario**. `af48439` sigue siendo valioso: endurece el *pipeline* para que la próxima ejecución scriptada no dependa del arreglo manual que se hizo esta vez. Queda como residual "no bloqueante" probar ese pipeline scriptado end-to-end en el próximo release que toque por otro motivo.
- **Tags de git** (descubierto el 2026-08-27):
  - Tag local espurio `v3.1` → `af96740` (`Añade icono de app`, 12-jun): **borrado** (`git tag -d v3.1`; no estaba en `origin`, nada que propagar).
  - El tag `v2.1` (publicado en `origin`) apunta a `c662647` (`chore(runtime): 2026-08-24`), **6 commits por detrás** de `ec071d9` (`chore(release): v2.1`). **Decisión del usuario (2026-08-27): dejarlo como está** — el release y su asset son correctos, solo el commit señalado es "viejo"; no merece reescribir un tag publicado.
  - **Causa raíz**: `release-macos.sh` NO commitea — por diseño deja el `git add/commit/push` de `appcast.xml` + `project.pbxproj` como paso manual al final. Pero `_publish_release()` llama a `gh release create "v${VERSION}"` ANTES de que exista ese commit, así que `gh` crea el tag sobre el HEAD del `origin/main` de ese momento (el commit *anterior* al bump), no sobre el `chore(release): vX`.
  - **Arreglo aplicado y commiteado** (`cc1af03`, `scripts/release-macos.sh` + `RELEASING.md` §2): opción (c) — el eco final del script ahora imprime también `git tag -f "v${VERSION}"` + `git push -f origin "v${VERSION}"` tras el `git commit`/`git push` manual, para mover el tag recién creado al commit del release. Se respeta la regla "el script no commitea/pushea solo". `bash -n` + `shellcheck -S warning` OK. A partir de v2.2 el tag caerá bien si se sigue el guion impreso.
  - `pbxproj` sigue en `MARKETING_VERSION = 2.1` / `CURRENT_PROJECT_VERSION = 10` — el próximo release sube a `2.2`+ ; re-lanzar `release-macos.sh 2.1` fallaría en `gh release create "v2.1"` por el tag existente.
- **Bug nuevo sospechado de Xcode 27.0 beta GOLD** (encontrado tras el checkpoint de la Fase 21, el usuario había actualizado Xcode durante la sesión): `ExtractorApp/Info.plist` apareció con una clave `CFBundleIdentifier` corrupta — su valor no era un bundle identifier sino un mensaje de log interno de Sparkle (`/Users/runner/work/Sparkle/Sparkle/Sparkle/SPUStandardUserDriver.m:731 [Internal] Thread running at User-interactive quality-of-service class waiting on a lower QoS thread...`). No se identificó el mecanismo exacto (¿un build/index de Xcode 27 escribiendo salida de log en el sitio equivocado?). Revertido sin commitear (`git checkout -- Info.plist`) — no bloqueante porque no llegó a commitearse, pero **vigilar si reaparece** en futuros builds con Xcode 27 beta; si se repite, documentar como bug confirmado (mismo patrón que los bugs de Xcode 26.6 ya registrados en este proyecto) antes de considerar downgrade o workaround.
- **Bug real de Xcode 26.6 confirmado** (relacionado con `POLISH-02`): `GENERATE_INFOPLIST_FILE = YES` no sintetiza NINGUNA clave `INFOPLIST_KEY_*` personalizada en el `Info.plist` generado (`SUFeedURL`, `SUPublicEDKey`, `NSHumanReadableCopyright` — las 3 ausentes, confirmado con DerivedData borrado por completo, no era caché). Efecto observado: "Buscar actualizaciones…" fallaba con `You must specify the URL of the appcast as the SUFeedURL key...`. Corregido con un `Info.plist` físico parcial (`ExtractorApp/Info.plist`, solo esas 3 claves) + `INFOPLIST_FILE` en build settings, combinado con `GENERATE_INFOPLIST_FILE = YES` (mecanismo de merge documentado por Apple) — verificado en Mac real: las claves aparecen en el `.app` compilado y "Buscar actualizaciones…" funciona sin error.
- ~~Notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17) no se ha ejecutado todavía~~ → **RESUELTO 2026-08-27**: el release público v2.1 (con Chromium embebido) está notarizado y stapled, verificado en Mac real (`spctl`/`stapler`/`codesign` + barrido de hardened runtime). Ver el punto "SC2" arriba en esta sección.
- El bug de búsqueda de paquetes de Xcode 26.6 (POLISH-02) sigue sin resolverse — el paquete local de Sparkle es un workaround funcional pero no se actualizará solo a nuevas versiones; revisar si el repo se clona en otra máquina sin `.build-cache/Sparkle` presente (necesitará repetir `scripts/setup-sparkle-local.sh`).

## Deferred Items

| Category | Item | Status |
|----------|------|--------|
| Técnico | Migrar Sparkle a paquete remoto real (POLISH-02) si se resuelve el bug de Xcode 26.6 | v9+ si el usuario quiere reabrirlo — ver `18-RESEARCH.md` |
| Distribución | Mac App Store | Explícitamente fuera de alcance — sin fecha |

Los ítems de mantenimiento que estuvieron aquí (tamaño de build Release,
notarización real con Chromium, `--clipboard` real, `setup-sparkle-local.sh`)
fueron el alcance de v8.0 / Fase 23 y quedaron **cerrados el 2026-08-27**.
Solo SC4 (rollout en appcast) y SC6 (bug `Info.plist` Xcode 27) siguen
abiertos como criterios condicionales a un release futuro — ver Pending
Todos y Blockers/Concerns.

## Session Continuity

Last session: 2026-08-27T00:00:00Z
Stopped at: **v8.0 / Fase 23 CERRADA**. La sesión empezó con "revisa el estado del proyecto" y terminó ejecutando la Fase 23 entera. Secuencia: (1) se detectó que la definición de v8.0 ya estaba commiteada (`b6bc9f9`) y que había un release `v2.1` publicado (`ec071d9` + `appcast.xml`) con 3 scripts modificados sin commitear que corregían rechazos reales de `notarytool`; (2) validados (`bash -n` + `shellcheck`), limpiado `Icon\r` + `.gitignore`, commiteados como `af48439`; (3) el usuario verificó en su Mac contra el `.app` público de `v2.1`: SC1 (882 MB), SC2 (`spctl`/`stapler`/`codesign` + barrido hardened runtime OK), SC3 (`--clipboard` vs `pbcopy` real, aditivo); (4) SC5 ya resuelto (`5c3d663`); (5) tag `v3.1` espurio borrado, `v2.1` mal ubicado se deja por decisión del usuario, causa raíz arreglada para v2.2+ (`cc1af03`); (6) `pytest` 67/67 + `pylint` 10.00/10 + `mypy` limpio en venv temporal del sandbox; (7) SUMMARY escrito, ROADMAP/MILESTONES/STATE cerrados. Commits `af48439`, `e2962d6`, `3b2b3d8`, `d78784c`, `055e7bd`, `50383d4`, `cc1af03` + el de cierre, todos en `origin/main`.
Resume file: ninguno — **sin milestone activo**.

**Decisión 2026-08-28:** NO lanzar un release `2.2` de validación ahora. Desde `v2.1` (`ec071d9`) no hay ningún cambio de cara al usuario — `core.py`/`extractor_url.py`/`ExtractorApp/*.swift` intactos; solo `scripts/`, `.planning/` y docs. Un 2.2 empujaría vía Sparkle un auto-update sin cambios visibles a todos los usuarios. El usuario eligió **esperar a tener una feature o fix real que enviar**; el pipeline endurecido (`af48439`/`cc1af03`) y los criterios condicionales SC4/SC6 se validarán en ese próximo release. No re-proponer un release "a secas" como siguiente paso sin que haya algo que shippear.
