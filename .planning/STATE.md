---
gsd_state_version: 1.0
milestone: v7.0
milestone_name: (nombre por definir)
status: complete
last_updated: "2026-08-24T06:00:00.000Z"
last_activity: 2026-08-24 -- v7.0 completo (Fases 19-22). Fase 22 (notarizacion distribucion publica) verificada con spctl contra el release real v1.0: accepted, source=Notarized Developer ID -- el mecanismo ya existia desde la Fase 13, solo hacia falta verificarlo y corregir documentacion contradictoria. De paso, corregidos dos bugs reales de layout en ContentView.swift reportados por el usuario.
progress:
  total_phases: 4
  completed_phases: 4
  total_plans: 4
  completed_plans: 4
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-24)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** v6.0 y v7.0 completos y cerrados. Sin milestone v8.0 definido todavía — pendiente de decisión del usuario sobre qué priorizar a continuación (ver Deferred Items).

## Current Position

Phase: 22 — Notarización para distribución pública (Complete) — última fase de v7.0
Plan: 22-01 completo (sin research/plan formales por separado — verificación + documentación hechas directamente en conversación, ver `22-01-SUMMARY.md`)
Status: Complete — PUBLISH-01/PUBLISH-02 validados con `spctl` contra un release real
Last activity: 2026-08-24 — Antes de escribir nada, se revisó qué ya existía: el `.app` ya se notariza+staplea (Fase 13) y se publica en GitHub Releases de un repo ya público — el mecanismo técnico central de PUBLISH-01/02 ya estaba cubierto. Verificado con `spctl -a -vvv --type execute` contra el release real `v1.0` (descargado de verdad con `gh release download`, no un build local): `ExtractorApp.app: accepted`, `source=Notarized Developer ID` — el veredicto exacto que vería cualquiera abriendo la app por primera vez, sin depender del estado de confianza de la máquina (no hizo falta un Mac limpio de verdad). `RELEASING.md` nueva sección 3.8 (distribución pública, diferenciada del flujo de Sparkle). `README.md` corregido — ya no dice "no implica distribución pública a terceros"; tabla de milestones actualizada (estaba parada en v5.0) y nueva línea "Descarga" apuntando a Releases. `22-01-SUMMARY.md` escrito. **Con esto, v7.0 queda completo** (Fases 19-22, todos los requirements validados). De paso, fuera de fase (reportado por el usuario tras probar la Fase 21): dos bugs reales de layout en `ContentView.swift` corregidos — (1) `resultCard` vivía dentro de un `ScrollView` que envolvía todo el layout, cuyo `VStack` solo se dimensionaba al alto natural del contenido, dejando el preview HTML fijo en `minHeight:240` sin crecer nunca; movido fuera con `.frame(maxHeight: .infinity)` para ocupar el espacio restante de la ventana; (2) las etiquetas "Formato:"/"Exportar como" se solapaban con sus `Picker` segmentados (no se comprimían limpiamente pese al `.frame(maxWidth:)`) — corregido con `.fixedSize()` en ambos. Ambos confirmados visualmente por el usuario con capturas de pantalla reales tras recompilar. También se encontró (y revirtió sin commitear) un posible bug nuevo de Xcode 27.0 beta GOLD que corrompía `Info.plist` con una clave `CFBundleIdentifier` con contenido de log interno de Sparkle — ver Blockers/Concerns.
ROADMAP.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md/STATE.md actualizados marcando v7.0 completo. Fase 21 y el fix de `ContentView.swift` (layout) ya están commiteados por el usuario desde su terminal (hash exacto no capturado en esta sesión — la terminal del sandbox estuvo caída, el commit se hizo directamente en el Mac del usuario). Pendiente: commitear la Fase 22 (docs de `RELEASING.md`/`README.md`/`.planning`).

```
v7.0 Progress: [==========] 100% — Fases 19-22 completas. MILESTONE COMPLETO.
Phase 19: [==========] Complete (19-01, commit 8fbc9cc)
Phase 20: [==========] Complete (20-01, commit 42a3c32)
Phase 21: [==========] Complete (21-01, verificado en checkpoint humano — sin avisos de Gatekeeper)
Phase 22: [==========] Complete (22-01, verificado con spctl contra release real v1.0)
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

### Pending Todos

- Commitear los cambios de la Fase 22 (`RELEASING.md`/`README.md`/`.planning/`) — nada de esto está commiteado todavía.
- Sin milestone v8.0 definido — cuando el usuario quiera, revisar `Deferred Items` como punto de partida (migrar Sparkle a paquete remoto si se resuelve el bug de Xcode, o cualquier backlog nuevo).
- Recomendado no bloqueante: probar `python extractor_url.py <url> --clipboard` en un Mac real (sandbox Linux no tiene `pbcopy`, solo verificado con mocks) — Fase 19.
- Recomendado no bloqueante: en el próximo release real con `ROLLOUT_INTERVAL_SECONDS` puesto, confirmar en el `appcast.xml` resultante que `<sparkle:phasedRolloutInterval>` aparece con el valor esperado — Fase 20.
- Decidir si commitear `scripts/setup-sparkle-local.sh` (añadido durante el checkpoint de la Fase 16, no estaba en el plan original) — sigue pendiente, no bloqueante.
- Medir el tamaño real de un build Release/archivado (con strip) en el próximo release real — la cifra de 886MB (Fase 17) es de un build Debug local, probablemente algo menor en Release.
- Ejecutar notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17, deferido) en el próximo release real — verificar tiempos y que `_resign_bundled_chromium()` funciona end-to-end con Developer ID real.
- Recomendado no bloqueante: repetir `pytest tests/`/`pylint`/`mypy` de 14-01/15-01 en el `.venv` real del Mac.
- Recomendado no bloqueante: si el usuario quiere reabrir POLISH-02 en el futuro, probar `defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 1` + reinicio de Xcode en su Mac real (ver `18-RESEARCH.md`).

### Blockers/Concerns

- Ninguno bloqueante. v7.0 completo.
- **Bug nuevo sospechado de Xcode 27.0 beta GOLD** (encontrado tras el checkpoint de la Fase 21, el usuario había actualizado Xcode durante la sesión): `ExtractorApp/Info.plist` apareció con una clave `CFBundleIdentifier` corrupta — su valor no era un bundle identifier sino un mensaje de log interno de Sparkle (`/Users/runner/work/Sparkle/Sparkle/Sparkle/SPUStandardUserDriver.m:731 [Internal] Thread running at User-interactive quality-of-service class waiting on a lower QoS thread...`). No se identificó el mecanismo exacto (¿un build/index de Xcode 27 escribiendo salida de log en el sitio equivocado?). Revertido sin commitear (`git checkout -- Info.plist`) — no bloqueante porque no llegó a commitearse, pero **vigilar si reaparece** en futuros builds con Xcode 27 beta; si se repite, documentar como bug confirmado (mismo patrón que los bugs de Xcode 26.6 ya registrados en este proyecto) antes de considerar downgrade o workaround.
- **Bug real de Xcode 26.6 confirmado** (relacionado con `POLISH-02`): `GENERATE_INFOPLIST_FILE = YES` no sintetiza NINGUNA clave `INFOPLIST_KEY_*` personalizada en el `Info.plist` generado (`SUFeedURL`, `SUPublicEDKey`, `NSHumanReadableCopyright` — las 3 ausentes, confirmado con DerivedData borrado por completo, no era caché). Efecto observado: "Buscar actualizaciones…" fallaba con `You must specify the URL of the appcast as the SUFeedURL key...`. Corregido con un `Info.plist` físico parcial (`ExtractorApp/Info.plist`, solo esas 3 claves) + `INFOPLIST_FILE` en build settings, combinado con `GENERATE_INFOPLIST_FILE = YES` (mecanismo de merge documentado por Apple) — verificado en Mac real: las claves aparecen en el `.app` compilado y "Buscar actualizaciones…" funciona sin error.
- Notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17) no se ha ejecutado todavía — deferida al próximo release real para no gastar cuota. El codesigning en sí ya está verificado (`codesign --verify --deep --strict` + `allow-jit` correctos), así que el riesgo residual es bajo, pero la notarización real (`notarytool submit --wait`) con un bundle de ~900MB no se ha probado y podría tardar sensiblemente más de lo habitual (ya documentado en `RELEASING.md` 3.5).
- El bug de búsqueda de paquetes de Xcode 26.6 (POLISH-02) sigue sin resolverse — el paquete local de Sparkle es un workaround funcional pero no se actualizará solo a nuevas versiones; revisar si el repo se clona en otra máquina sin `.build-cache/Sparkle` presente (necesitará repetir `scripts/setup-sparkle-local.sh`).

## Deferred Items

| Category | Item | Status |
|----------|------|--------|
| Técnico | Migrar Sparkle a paquete remoto real (POLISH-02) si se resuelve el bug de Xcode 26.6 | v8+ si el usuario quiere reabrirlo — ver `18-RESEARCH.md` |
| Distribución | Mac App Store | Explícitamente fuera de alcance de v7.0 (ver Decisions) — sin fecha |
| Infraestructura | Medir tamaño de un build Release/archivado (886MB de la Fase 17 es de un build Debug) | Próximo release real |
| Infraestructura | Ejecutar notarización real con Chromium embebido (Paso 6 del checkpoint de la Fase 17) | Próximo release real |
| Investigación | Vigilar si reaparece el bug sospechado de Xcode 27.0 beta GOLD (corrupción de `Info.plist`) | Solo si se repite — ver Blockers/Concerns |

v7.0 completo — ningún ítem de v7.0 queda diferido. Sin milestone v8.0
definido todavía.

## Session Continuity

Last session: 2026-08-24T06:00:00Z
Stopped at: **v7.0 completo** (Fases 19-22) — pero la Fase 22 (docs) **todavía sin commitear**. Secuencia de esta sesión (continuación de una sesión previa que ya había completado Fases 19-20): (1) Fase 21 (auto-actualización runtime) investigada, implementada y verificada en checkpoint humano real — release real publicado y aplicado sin ningún aviso de Gatekeeper, confirmado explícitamente por el usuario; un bug real de UI (mensaje de error poco visible) encontrado y corregido; (2) durante el checkpoint, la terminal de este sandbox estuvo fallando de forma intermitente ("Unable to read current working directory" / "Shell cwd was reset... (deleted)") — probablemente el volumen externo `/Volumes/ESSAGER` se desconectó/reconectó (hubo un salto de fecha de 2026-08-23 a 2026-08-24 entre mensajes, sugiriendo que el Mac durmió); las herramientas de archivo (Read/Edit/Write) siguieron funcionando con normalidad, solo Bash se vio afectado, y de forma intermitente — si vuelve a pasar en la próxima sesión, reintentar tras una pausa suele bastar, o pedir al usuario que ejecute los comandos directamente en su terminal (mismo filesystem, funciona igual); (3) usuario reportó `Info.plist` corrupto con una clave `CFBundleIdentifier` conteniendo un log interno de Sparkle — causa sospechada: acababa de actualizar a Xcode 27.0 beta GOLD; revertido sin commitear, documentado como bug a vigilar; (4) usuario commiteó la Fase 21 + el fix de `Info.plist` revertido desde su propia terminal; (5) usuario reportó un problema de layout (área de resultado HTML muy estrecha) — diagnosticado y corregido en `ContentView.swift` (dos bugs reales: `resultCard` atrapado en un `ScrollView` que no lo dejaba crecer, y etiquetas solapadas con sus pickers segmentados), confirmado visualmente con capturas reales, commiteado por el usuario; (6) Fase 22 (notarización distribución pública): revisado que el mecanismo ya existía desde la Fase 13, verificado con `spctl -a -vvv --type execute` contra el release real `v1.0` (`accepted`, `source=Notarized Developer ID`), documentación corregida en `RELEASING.md`/`README.md`. `22-01-SUMMARY.md` escrito. ROADMAP.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md/STATE.md actualizados marcando v7.0 completo. **Los cambios de la Fase 22 (RELEASING.md, README.md, .planning/) no están commiteados todavía** — próximo paso natural: dar al usuario el comando de commit final, y preguntarle qué quiere priorizar para un futuro v8.0 (o si lo dejamos aquí).
Resume file: ninguno — v7.0 cerrado, pendiente el commit final de la Fase 22 y definir v8.0 si el usuario quiere seguir
