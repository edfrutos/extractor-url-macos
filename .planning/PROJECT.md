# extractor-url

## What This Is

Utilidad local en Python para extraer contenido legible desde una URL y devolverlo como texto limpio, HTML o Markdown, con una app macOS nativa en SwiftUI que lanza el motor Python vía subprocess y exporta el resultado. Orientado a uso personal en macOS: fidelidad de extracción, flujo simple y evolución sin dependencias de servicios externos.

## Core Value

Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.

## Requirements

### Validated

- ✓ Extracción local de texto, HTML y Markdown desde URL con `requests`, `BeautifulSoup`, `trafilatura` y `markdownify`.
- ✓ REQ-01: El conversor Markdown tiene cobertura automatizada con fixtures HTML locales. — Validated in Phase 1
- ✓ REQ-02: La extracción maneja limpieza DOM, URLs relativas y selector CSS sin regresiones. — Validated in Phase 1
- ✓ REQ-03: La documentación técnica principal refleja el estado real del proyecto. — Validated in Phase 1
- ✓ REQ-04: La GUI funciona sin URL, tanto sin argumentos como con `--gui`. — Validated in Phase 2
- ✓ REQ-05: Los fallos de guardado y selector CSS son explícitos. — Validated in Phase 2
- ✓ REQ-06: La CLI pública y sus caminos de error principales tienen tests. — Validated in Phase 2
- ✓ BRIDGE-01: PythonBridge llama al CLI con `--json`, captura stdout/stderr async sin deadlock. — Validated in Phase 3
- ✓ BRIDGE-02: Si Python no está en la ruta configurada, el error tipado se propaga. — Validated in Phase 3
- ✓ SETTINGS-01: El usuario puede configurar rutas al intérprete y al script desde Preferencias. — Validated in Phase 3
- ✓ SETTINGS-02: La app avisa si alguna ruta no es ejecutable (validación reactiva). — Validated in Phase 3
- ✓ SETTINGS-03: El usuario puede verificar la versión Python desde Preferencias. — Validated in Phase 3
- ✓ APP-01: Campo URL + picker de tipo + botón Extraer con estado visual de progreso. — Validated in Phase 4
- ✓ APP-02: ProgressView visible durante extracción, ventana responde a eventos. — Validated in Phase 4
- ✓ APP-03: Error de extracción visible inline con mensaje descriptivo. — Validated in Phase 4
- ✓ UI-01: Selector CSS y timeout configurables antes de extraer. — Validated in Phase 4
- ✓ UI-02: Preview WKWebView del contenido extraído. — Validated in Phase 5
- ✓ EXPORT-01: Export a Markdown (.md) vía NSSavePanel. — Validated in Phase 5
- ✓ EXPORT-02: Export a HTML autocontenido (CSS/JS inline). — Validated in Phase 5
- ✓ EXPORT-04: Export a PDF vectorial (WKWebView.pdf, texto seleccionable). — Validated in Phase 6
- ✓ APP-04: Universal binary arm64+x86_64, deployment target macOS 13.0. — Validated in Phase 7
- ✓ APP-05: Hardened Runtime ON, App Sandbox OFF. — Validated in Phase 7
- ✓ BUNDLE-01: El .app incluye un intérprete Python universal (arm64+x86_64) en `Contents/Resources/`. — Validated in Phase 8
- ✓ BUNDLE-02: El .app incluye `extractor_url.py` y `core.py` en `Contents/Resources/scripts/`. — Validated in Phase 8
- ✓ BUNDLE-03: Las dependencias Python vendorizadas en el bundle. — Validated in Phase 8
- ✓ BRIDGE-05: PythonBridge detecta las rutas del bundle vía `Bundle.main.resourcePath` sin configuración del usuario. — Validated in Phase 9
- ✓ BRIDGE-06: PythonBridge usa rutas del bundle por defecto; acepta override de `UserDefaults` si existen y son válidas. — Validated in Phase 9
- ✓ BRIDGE-07: Override de `UserDefaults` inválido cae al bundle sin lanzar error al usuario. — Validated in Phase 9
- ✓ UX-01: La app extrae contenido en el primer lanzamiento sin que el usuario configure nada. — Validated in Phase 10
- ✓ UX-02: SettingsView muestra "Usando Python incluido (Python X.X.X)" cuando opera con el bundle. — Validated in Phase 10 (badge confirmado con "Python 3.13.14" real en checkpoint humano)
- ✓ UX-03: SettingsView mantiene override opcional de rutas para uso avanzado, colapsado por defecto. — Validated in Phase 10

- ✓ JS-01: `core.py` detecta heurísticamente cuando la extracción estática devuelve contenido insuficiente (`_looks_insufficient()`, umbral de 100 caracteres de texto visible). — Validated in Phase 11
- ✓ JS-02: Si se detecta contenido insuficiente, `core.py` reintenta automáticamente renderizando con Playwright (Chromium headless) vía `_fetch_via_playwright()`. — Validated in Phase 11
- ✓ JS-03: Si Playwright/Chromium no están instalados, la extracción degrada al resultado estático sin excepción no controlada — verificado real (sin mockear) en un entorno sin Playwright instalado. — Validated in Phase 11
- ✓ JS-04: 8 tests nuevos en `tests/test_js_fallback.py` cubren las 4 ramas con fixtures/mocks; `pytest tests/` (28 tests) pasa sin requerir un browser real. — Validated in Phase 11

- ✓ UPDATE-01: Sparkle 2.x integrado en `ExtractorApp.xcodeproj` (paquete local en `.build-cache/Sparkle`, ver desviación del plan en `12-01-SUMMARY.md` — el buscador remoto de Xcode 26.6 fallaba universalmente). — Validated in Phase 12
- ✓ UPDATE-02: `SPUStandardUpdaterController` inicializado en `ExtractorAppApp.swift`, comprobación automática en segundo plano + ítem de menú "Buscar actualizaciones…" confirmado visible en checkpoint humano. — Validated in Phase 12
- ✓ UPDATE-03: `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey` en Debug y Release del target ExtractorApp; clave pública con placeholder explícito hasta Fase 13. — Validated in Phase 12

- ✓ UPDATE-04: `scripts/release-macos.sh` automatiza build → firma Developer ID → notarización → generación de appcast → publicación en GitHub Releases — verificado con el release real v1.0. — Validated in Phase 13
- ✓ UPDATE-05: `appcast.xml` alojado en el repo, servido vía `raw.githubusercontent.com`, confirmado en vivo con `curl`; binario como asset de GitHub Release. — Validated in Phase 13
- ✓ UPDATE-06: `RELEASING.md` documenta el proceso completo; ninguna credencial expuesta en el repo en todo el checkpoint. — Validated in Phase 13

- ✓ HIST-01: `core.py` persiste un historial de extracciones (metadatos, no contenido) en `~/.cache/extractor-url/history.jsonl`. — Validated in Phase 14 (14-01)
- ✓ HIST-02: La app SwiftUI muestra el historial y permite reabrir una extracción previa sin repetirla (rellena campos + reextrae vía `ExtractionViewModel.extract()`). — Validated in Phase 14 (14-02), checkpoint humano en Xcode
- ✓ HIST-03: `extractor_url.py --batch <archivo> --json` procesa varias URLs secuencialmente, NDJSON, continúa tras un fallo individual. — Validated in Phase 14 (14-01)

- ✓ FLAG-01: `--js` fuerza el fallback Playwright sin depender de la heurística `_looks_insufficient()`. — Validated in Phase 15 (15-01), `js_mode="force"`
- ✓ FLAG-02: `--no-js` desactiva el fallback Playwright aunque la heurística lo activaría. — Validated in Phase 15 (15-01), `js_mode="off"`

- ✓ CHANNEL-01: `scripts/release-macos.sh` soporta publicar en un canal `beta` (`sparkle:channel`) sin afectar al canal por defecto. — Validated in Phase 16 (16-01)
- ✓ CHANNEL-02: La app puede optar (vía `SPUUpdaterDelegate.allowedChannels(for:)`) a recibir actualizaciones del canal beta. — Validated in Phase 16 (16-01), checkpoint humano en Xcode

- ✓ BUNDLEJS-01: El pipeline de bundling (Fase 8) vendoriza Playwright + Chromium dentro del `.app`, firmados con Developer ID/hardened runtime (Helpers Renderer/GPU con `allow-jit`). — Validated in Phase 17 (17-01), checkpoint humano en Xcode; notarización real con Chromium embebido deferida al próximo release real
- ✓ BUNDLEJS-02: El fallback JS del motor Python funciona en la app SwiftUI sin que el usuario instale Playwright por separado. — Validated in Phase 17 (17-01), extracción real de `quotes.toscrape.com/js/` desde la app

- ✓ POLISH-01: `_bump_version` en `scripts/release-macos.sh` acota el `sed`/`awk` a los bloques del target `ExtractorApp` únicamente (no toca `ExtractorAppTests`). — Validated in Phase 18 (18-01), verificado contra copia del `.pbxproj` real
- ✓ POLISH-02: Investigado el bug del buscador de paquetes de Xcode 26.6 — sin causa raíz confirmada, sigue documentado como no resuelto. Sparkle NO migrado a paquete remoto (decisión explícita del usuario de no invertir tiempo probándolo ahora). — Validated in Phase 18 (18-01), ver `18-RESEARCH.md`

- ✓ CONTENT-01: `--no-images` elimina imágenes del contenido extraído en todos los formatos soportados. — Validated in Phase 19 (19-01), `pytest`/`pylint`/`mypy` limpios en el sandbox
- ✓ CONTENT-02: `--no-links` elimina/aplana enlaces del contenido extraído (deja el texto, sin `href`). — Validated in Phase 19 (19-01)
- ✓ CLIP-01: `--clipboard` copia el resultado extraído al portapapeles del sistema. — Validated in Phase 19 (19-01), `pbcopy` verificado con `subprocess.run` mockeado (sin Mac real en el sandbox)

- ✓ ROLLOUT-01: `scripts/release-macos.sh` soporta un `sparkle:phasedRolloutInterval` opcional al publicar, sin afectar releases sin ese flag. — Validated in Phase 20 (20-01), verificado en el sandbox (shellcheck + prueba aislada de argumentos, sin pipeline real)
- ✓ ROLLOUT-02: El comportamiento y las implicaciones de un rollout por fases quedan documentados en `RELEASING.md`. — Validated in Phase 20 (20-01)

- ✓ PYRUNTIME-01: Mecanismo para actualizar las dependencias Python puras del runtime embebido sin re-publicar toda la app, sin romper la firma de código ni la notarización del `.app`. — Validated in Phase 21 (21-01), checkpoint humano en Mac real: actualización real publicada y aplicada sin ningún aviso de Gatekeeper
- ✓ PYRUNTIME-02: Si la actualización del runtime falla o queda corrupta, la app degrada de forma segura (rollback al runtime bundleado original). — Validated in Phase 21 (21-01), confirmado borrando el override a mano — la extracción siguió funcionando sin intervención del usuario

- ✓ PUBLISH-01: El `.app` notarizado se publica en una ubicación pública y descargable por cualquiera, sin requerir configuración especial del descargador. — Validated in Phase 22 (22-01), ya cumplido desde la Fase 13 (repo GitHub público)
- ✓ PUBLISH-02: Un usuario en un Mac limpio puede descargar y abrir el `.app` sin avisos de Gatekeeper. — Validated in Phase 22 (22-01), verificado con `spctl -a -vvv --type execute` contra el release real v1.0: `accepted`, `source=Notarized Developer ID`

### v8.0 — cerrado (2026-08-27)

- ✓ MAINT-01: `.app` Release/notarizado de `v2.1` = 882 MB (~387 MB zip). Documentado en `RELEASING.md` §3.5. — Validated in Phase 23 (23-01)
- ✓ MAINT-02: `v2.1` con Chromium embebido notarizado + stapled; `spctl` → `Notarized Developer ID`, `codesign --deep --strict` OK, cero Mach-O sin hardened runtime. Pipeline endurecido en `af48439`. — Validated in Phase 23 (23-01)
- ✓ MAINT-03: `--clipboard` vs `pbcopy` real en el Mac; aditivo con `-o`. — Validated in Phase 23 (23-01)
- ~ MAINT-04 (diferido-condicional): solo aplica si un release futuro usa `ROLLOUT_INTERVAL_SECONDS`. Mecanismo (Fase 20) intacto, sin verificar contra un appcast real.
- ✓ MAINT-05: `scripts/setup-sparkle-local.sh` ya trackeado desde `5c3d663` (Fase 16); decisión efectiva "sí". — Validated in Phase 23 (23-01)
- ~ MAINT-06 (diferido-condicional): el bug de `Info.plist` de Xcode 27 beta solo es observable durante un build nuevo; no hubo build en la Fase 23. Sigue como concern a vigilar.

### Out of Scope

- App Store o distribución comercial — no es el objetivo. La distribución pública de v7.0 es vía web (GitHub Releases o similar), no Mac App Store — decisión explícita del usuario al definir v7.0, mantiene esta línea sin cambios.

## Context

El proyecto tiene dos capas: el motor Python (`core.py` + `extractor_url.py`) y la app nativa SwiftUI (`ExtractorApp/`). La app lanza el motor vía `Foundation.Process()` con `--json`. v3.0 eliminó la dependencia del usuario de instalar Python y configurar rutas. v4.0 amplió el motor Python para extraer contenido de páginas que requieren JavaScript (SPAs). v5.0 añadió auto-actualización a la app SwiftUI (Sparkle). v6.0 cubrió el backlog diferido de v4.0/v5.0: historial y cola de extracciones, control manual del fallback JS, canales beta de Sparkle, Playwright embebido en el bundle, y pulido técnico menor. v7.0 cubre el backlog diferido restante de v6.0: flags de filtrado de contenido CLI, rollouts por fases de Sparkle, auto-actualización del runtime Python embebido, y notarización para distribución pública vía web (no App Store).

## Current Milestone: ninguno activo

v8.0 (Fase 23) **cerrado el 2026-08-27**. Sin backlog de funcionalidad
nueva ni milestone en curso. El siguiente hito natural, cuando el usuario
quiera, es un release real `2.2`+ que de paso ejercitaría el pipeline
scriptado endurecido en la Fase 23 y los criterios condicionales SC4/SC6.

### v8.0 — cerrado (resumen)

**Goal cumplido:** cerrar los ítems de mantenimiento/verificación
pendientes de v6.0/v7.0. Cerrado verificando el release público `v2.1` en
vez de lanzar uno nuevo:

- SC1 — `.app` Release/notarizado = 882 MB (~387 MB zip); el strip no
  adelgaza. En `RELEASING.md` §3.5.
- SC2 — `v2.1` con Chromium embebido notarizado + stapled, cero Mach-O
  sin hardened runtime (`spctl`/`stapler`/`codesign`).
- SC3 — `--clipboard` vs `pbcopy` real, aditivo con `-o`.
- SC5 — `setup-sparkle-local.sh` ya trackeado desde `5c3d663`.
- Pipeline endurecido (`af48439`): firma de Chromium por descubrimiento,
  `ditto` sin `--sequesterRsrc`, log de `notarytool`, guard bash 3.2.
- Tagging de release arreglado (`cc1af03`): el guion impreso mueve el tag
  al commit `chore(release)`. Aplica desde v2.2.
- SC4 (rollout en appcast) y SC6 (bug `Info.plist` Xcode 27) quedan
  **diferidos-condicionales** a un release futuro — no bloquean el cierre.

Ver `.planning/phases/23-verificacion-release-real/23-01-SUMMARY.md`.

## Current State

Milestone v1.0 (Stabilization) completado: suite `pytest` con 14 tests, pylint 10/10, contratos CLI explícitos.
Milestone v2.0 (SwiftUI Native App) completado: app macOS nativa, bridge Python async, export MD/HTML/PDF, universal binary, UI premium con dark mode automático.
Milestone v3.0 (Standalone App) completado y cerrado: Fases 8, 9 y 10 verificadas con `xcodebuild` real (Build Succeeded, 49 tests/3 skipped/0 fallos, checklist visual OK) — ver `.planning/phases/10-ux-zero-config/10-01-SUMMARY.md`.
Milestone v4.0 (Contenido Dinámico) completado y cerrado: Fase 11 implementa `_looks_insufficient()` + `_fetch_via_playwright()` en `core.py`, integrados en `_fetch_raw()`. Verificado con `pytest tests/` (28/28), `pylint` 10/10 y `mypy` limpio en un venv equivalente al del repo — ver `.planning/phases/11-playwright-fallback/11-01-SUMMARY.md`.
Milestone v5.0 (Auto-actualización) completado y cerrado: Fase 12 (Sparkle integrado en la app, paquete local por un bug de búsqueda de Xcode 26.6) y Fase 13 (`scripts/release-macos.sh` — build, firma Developer ID, notarización, appcast firmado con EdDSA, publicación en GitHub Releases) verificadas con un release real: `https://github.com/edfrutos/extractor-url-macos/releases/tag/v1.0`, `appcast.xml` publicado y confirmado en vivo — ver `.planning/phases/13-release-pipeline/13-01-SUMMARY.md` para los 4 bugs reales encontrados y corregidos durante el checkpoint (team ID en exportOptions.plist, hardened runtime del Python embebido, orden de bootstrap, firma EdDSA de generate_appcast).
Milestone v6.0 (Historial y Distribución Completa) completado y cerrado (2026-08-23): Fase 14 (historial y cola), Fase 15 (flag manual `--js`/`--no-js`), Fase 16 (canales beta de Sparkle), Fase 17 (Playwright/Chromium embebido, 886MB medidos, dos bugs reales de Playwright 1.62.0 encontrados y corregidos en el checkpoint) y Fase 18 (`_bump_version` acotado al target correcto, bug de Xcode 26.6 investigado sin causa raíz confirmada) — ver `.planning/phases/18-pulido-tecnico/18-01-SUMMARY.md` y `MILESTONES.md` para el detalle completo.
Milestone v7.0 (flags CLI, rollouts, auto-actualización runtime, distribución pública) completado y cerrado (2026-08-24): Fase 19 (flags de filtrado CLI, commit `8fbc9cc`) — `--no-images`/`--no-links`/`--clipboard`, 67/67 tests, pylint 10.00/10. Fase 20 (rollouts por fases de Sparkle, commit `42a3c32`) — `ROLLOUT_INTERVAL_SECONDS` → `--phased-rollout-interval`. Fase 21 (auto-actualización del runtime Python embebido, deps puras) — verificada en checkpoint humano: release real publicado y aplicado sin ningún aviso de Gatekeeper en ningún momento, confirmando el hallazgo central de la research (`.py` puros no pasan por Gatekeeper); degradación segura confirmada; un bug real de UI (mensaje de error poco visible) corregido en el mismo checkpoint. Fase 22 (notarización distribución pública) — el mecanismo técnico ya existía desde la Fase 13 (repo GitHub público, `.app` notarizado+stapleado); esta fase fue verificación (`spctl -a -vvv --type execute` contra el release real `v1.0`: `accepted`, `source=Notarized Developer ID`) y corrección de documentación contradictoria en `README.md`/`RELEASING.md`. De paso (fuera de fase, reportado por el usuario tras probar Fase 21), corregidos dos bugs reales de layout en `ContentView.swift`: el área de resultado no llenaba la ventana (quedaba dentro de un `ScrollView` que solo se dimensionaba a su contenido) y las etiquetas "Formato:"/"Exportar como" se solapaban con sus `Picker` segmentados. Ver `.planning/phases/22-notarizacion-distribucion-publica/22-01-SUMMARY.md` y `MILESTONES.md` para el detalle completo.
Milestone v8.0 completado y cerrado (2026-08-27): Fase 23 (verificación de release real y cierre de deuda técnica). Sin funcionalidad nueva — cerrado verificando el release público `v2.1` (SC1 `.app` = 882 MB, SC2 notarizado + hardened runtime OK, SC3 `--clipboard` real, SC5 `setup-sparkle-local.sh` ya trackeado) + endurecimiento del pipeline de firma/notarización (`af48439`) y fix del tagging de release (`cc1af03`). SC4 (rollout en appcast) y SC6 (bug `Info.plist` Xcode 27) diferidos-condicionales a un release futuro. `pytest` 67/67 · `pylint` 10.00/10 · `mypy` limpio. Ver `.planning/phases/23-verificacion-release-real/23-01-SUMMARY.md` y `MILESTONES.md`.

## Constraints

- **Tech stack**: Python 3 con `core.py` y `extractor_url.py`; SwiftUI + Foundation para la app.
- **Testing**: Sin dependencias de webs reales — usar fixtures HTML locales y mocks.
- **Platform**: macOS 13.0+ — universal binary arm64+x86_64.
- **Bundle size**: Python embebido añade ~30-60 MB al bundle — aceptable para uso personal.
- **[v4.0] Scope**: Playwright/Chromium (~300MB+) queda fuera del `.app` bundle — solo disponible vía `pip install` en el motor Python (CLI/venv), no en la app SwiftUI.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Separar motor e interfaces | Mantiene `core.py` reutilizable y desacoplado de CLI/GUI | ✓ Good |
| Priorizar tests antes que nuevas features | Evita regresiones sobre el pipeline Markdown | ✓ Good |
| Usar GSD mínimo para la fase 1 | Permite ejecutar workflows sin inventar planificación pesada | ✓ Good |
| `pytest tests/` desde raíz con `conftest.py` | Resuelve el gap sin instalar en modo editable | ✓ Good |
| Priorizar robustez CLI antes de empaquetado | Corrige primero contratos visibles al usuario | ✓ Good |
| Fallar ante selector CSS inválido | Evita ampliar silenciosamente el alcance de extracción | ✓ Good |
| Bridge vía `Foundation.Process()` con `--json` | Motor Python sin modificar; Swift gestiona UI y filesystem | ✓ Good |
| Export PDF vía `WKWebView.pdf(configuration:)` | Vectorial, texto seleccionable, sin PDFKit | ✓ Good |
| App Sandbox OFF, Hardened Runtime ON | Correcto para herramienta personal fuera del App Store | ✓ Good |
| Colores semánticos del sistema (no hex hardcodeado) | Dark mode automático sin lógica extra | ✓ Good |
| [v3.0] python-build-standalone como runtime embebido | Distribución portable sin dependencias del sistema, universal binary | ✓ Good (Phase 8) |
| [v3.0] `resolvedPaths()` UserDefaults-first / bundle-fallback en `PythonBridge` | Preserva overrides v2.0 sin romper el flujo zero-config nuevo | ✓ Good (Phase 9) |
| [v3.0] `PathSource` y `PythonOperatingMode` declarados `Equatable` explícitamente | Swift no sintetiza Equatable en enums sin declararlo, aunque no tengan valores asociados — necesario para que compilen los tests con `XCTAssertEqual` | ✓ Good (Phase 10, confirmado con build real) |
| [v3.0] `SettingsViewModel.operatingMode` reutiliza `PythonBridge.resolvedPaths()` en vez de reimplementar la lógica | Evita que el badge de Preferencias se desincronice del comportamiento real de `run()` | ✓ Good (Phase 10, confirmado con build real) |
| [v3.0] `IOCollector: @unchecked Sendable` (en vez de `nonisolated`) | El `nonisolated` no elimina los warnings de captura no-Sendable en closures `@Sendable` de `readabilityHandler`; el `NSLock` interno ya garantiza la seguridad real, así que `@unchecked Sendable` es el fix correcto — encontrado durante el checkpoint humano de Fase 10 | ✓ Good (Phase 10) |
| [v3.0] `refreshOperatingMode()` usa `Task.detached` (no `Task {}`) para `bundledPythonVersion()` | `SettingsViewModel` es `@MainActor`; un `Task {}` normal hereda ese aislamiento y el subprocess bloqueante `--version` se ejecutaría en el hilo principal pese al comentario original — bug real encontrado por el warning "No async operations occur within await expression" en el checkpoint | ✓ Good (Phase 10) |
| [v4.0] Fallback Playwright activado solo por heurística automática, sin flag manual | El usuario decidió que v4 prioriza "que simplemente funcione" sobre exponer un control explícito; un flag manual queda diferido a v5+ si hace falta | ✓ Good (Phase 11) |
| [v4.0] Playwright/Chromium no se embebe en el `.app` bundle SwiftUI | +300MB rompería la experiencia zero-config de v3.0 (bundle actual ~30-60MB); v4 es solo motor Python, la app queda fuera de este milestone | ✓ Good (Phase 11) |
| [v4.0] `_MIN_VISIBLE_TEXT_LENGTH = 100` (no 200 como proponía el research inicial) | La fixture de test "HTML rico" existente (`edefrutos_me.html`) mide solo 145 caracteres de texto visible — un umbral de 200 la marcaba como falso positivo. Encontrado al ejecutar los tests durante la implementación | ✓ Good (Phase 11) |
| [v4.0] `# type: ignore[import-not-found]` antes de `# pylint: disable=...` en la misma línea (no después) | mypy no reconoce la directiva `type: ignore` si aparece tras otro comentario en la misma línea física — encontrado al verificar `mypy core.py` | ✓ Good (Phase 11) |
| [v5.0] Sparkle 2 (no WinSparkle/NetSparkle/manual) para auto-update | Único framework de referencia para auto-update en macOS fuera del App Store; soporta App Sandbox OFF sin complejidad extra | ✓ Good (Phase 12/13, release real publicado) |
| [v5.0] Appcast alojado en GitHub Releases (`raw.githubusercontent.com` + assets de release) | El repo ya está en GitHub — sin infraestructura de hosting nueva, patrón usado en la práctica por otros proyectos macOS+Sparkle | ✓ Good (Phase 13, confirmado con curl en vivo) |
| [v5.0] Comprobación automática (24h, por defecto de Sparkle) + manual, sin toggle propio en Preferencias | Sparkle ya expone su propia UI nativa para que el usuario desactive el auto-check y persiste la preferencia — construir una UI propia sería duplicar trabajo | ✓ Good (Phase 12) |
| [v5.0] Claves `SUFeedURL`/`SUPublicEDKey` vía `INFOPLIST_KEY_*` en Build Settings, no un `Info.plist` físico | Este proyecto usa `GENERATE_INFOPLIST_FILE = YES` (Xcode 16+) — no existe un `.plist` editable a mano, hay que seguir el mecanismo real del proyecto | ✓ Good (Phase 12, confirmado leyendo `project.pbxproj`) |
| [v5.0] Paquete SPM Sparkle añadido manualmente en Xcode (no editando `project.pbxproj` a mano) | Las referencias `XCRemoteSwiftPackageReference`/`XCSwiftPackageProductDependency` requieren el resolver real de Xcode; editarlas a ciegas arriesga corromper el proyecto | ✓ Good (Phase 12) |
| [v5.0] `scripts/release-macos.sh` automatiza el pipeline de publicación (decisión explícita del usuario) | Evita repetir a mano build→firma→notarización→appcast→GitHub Release en cada versión, siguiendo el patrón ya establecido de `scripts/bundle-python.sh` | ✓ Good (Phase 13, release v1.0 publicado con el script) |
| [v5.0] `_resign_bundled_python()` re-firma el runtime Python embebido (Fase 8) con `--options runtime` tras exportar | `xcodebuild -exportArchive` no aplica hardened runtime a binarios sueltos copiados vía Build Phase, fuera del grafo de frameworks de Xcode — notarytool los rechaza sin ello. Encontrado en el checkpoint de Fase 13 | ✓ Good (Phase 13) |
| [v5.0] `sign_update` explícito como fallback si `generate_appcast` no firma el enclosure | `generate_appcast` no añadía `sparkle:edSignature` pese a que `sign_update` (mismos defaults de Keychain) sí firma en aislamiento — causa raíz no determinada, pero el fallback garantiza que el appcast siempre queda firmado | ✓ Good (Phase 13) |
| [v5.0] `exportOptions.plist` incluye `teamID` explícito (no solo `method`+`signingStyle`) | `xcodebuild -exportArchive` con firma Automatic sin team ID fijo falla con "No Team Found in Archive" al ejecutarse desde línea de comandos (no reproduce el comportamiento de la UI de Xcode) | ✓ Good (Phase 13) |
| [v6.0] Orden de fases 14→18 fijado por el usuario ("en el orden establecido, TODO") | El usuario pidió cubrir todo el backlog de v4.0/v5.0 en el orden en que se presentó (historial → flags → canales → bundle JS → pulido), no priorizado por Claude | ✓ Good (Phase 14 iniciada en ese orden) |
| [v6.0] Historial guarda solo metadatos, no el contenido extraído | Reabrir una entrada reextrae vía la caché HTTP ya existente (`_fetch_raw`) en vez de duplicar datos — mantiene `history.jsonl` pequeño y evita desincronización entre historial y caché | ✓ Good (Phase 14-01) |
| [v6.0] `--batch` exige `--json` explícitamente | Evita ampliar el comportamiento en silencio con un formato de texto plano ad-hoc para múltiples resultados — mismo principio que "selector CSS inválido falla explícito" ya establecido en v1.0 | ✓ Good (Phase 14-01) |
| [v6.0] `_lookup_title()` extraída como función compartida entre `main()` y `_run_batch()` | Eliminó duplicación real y bajó `pylint` de 9.95 a 10.00/10 (`too-many-statements` en `main()`) — refactor genuino, no solo un disable cosmético | ✓ Good (Phase 14-01) |
| [v6.0] `HistoryEntry.loadAll()` (Swift) reimplementa el parseo de `history.jsonl` en vez de invocar Python | La app solo lee el archivo del disco directamente — no hay razón para pagar el coste de un subprocess solo para listar el historial; mismo formato/orden y tolerancia a líneas corruptas que `load_history()` | ✓ Good (Phase 14-02) |
| [v6.0] "Reabrir" siempre reextrae vía `vm.extract()`, nunca un modo "mostrar sin reextraer" | Mantiene un único flujo de extracción en `ExtractionViewModel` — la caché HTTP de Python ya hace la reextracción rápida en el caso común, sin necesidad de un camino especial en `PythonBridge` | ✓ Good (Phase 14-02) |
| [v6.0] `js_mode != "auto"` salta la LECTURA de caché en `_fetch_raw()`, no la escritura | Sin esto, `--js`/`--no-js` no tendrían ningún efecto sobre una URL ya cacheada de una ejecución anterior — hallazgo del research (15-RESEARCH.md), no una decisión explícita del usuario, pero necesaria para que FLAG-01/02 cumplan lo que prometen | ✓ Good (Phase 15-01) |
| [v6.0] `--js`/`--no-js` vía `argparse.add_mutually_exclusive_group()`, sin validación manual | Falla nativo con `SystemExit(2)` si se pasan ambos — mismo principio de "fallar explícito" de v1.0, sin código propio que pueda tener bugs | ✓ Good (Phase 15-01) |
| [v6.0] `Info.plist` físico parcial (`ExtractorApp/Info.plist`) + `INFOPLIST_FILE`, combinado con `GENERATE_INFOPLIST_FILE = YES` | Bug confirmado de Xcode 26.6: no sintetiza ninguna clave `INFOPLIST_KEY_*` personalizada (`SUFeedURL`/`SUPublicEDKey`/`NSHumanReadableCopyright`) — verificado con DerivedData borrado por completo, no era caché. El merge `GENERATE_INFOPLIST_FILE` + `INFOPLIST_FILE` es el mecanismo oficial de Apple para este caso; evita esperar a que Apple arregle el bug | ✓ Good (encontrado fuera de fase, 2026-08-21) |
| [v6.0] `.app`/`.framework` de Chromium descubiertos por patrón (`find -name "*.app"`), no hardcodeados | Playwright 1.62.0 distribuye "Chrome for Testing" (`Google Chrome for Testing.app`), no el `Chromium.app` clásico asumido por el research/plan — encontrado como fallo real de build en el checkpoint humano de Fase 17. Descubrir por patrón evita que otro cambio de naming aguas arriba vuelva a romper el bundling | ✓ Good (Phase 17-01, checkpoint humano) |
| [v6.0] Una sola llamada `codesign` por Helper .app de Chromium (bundle completo, no ejecutable+bundle por separado) | Firmar el ejecutable interno con `--entitlements` y luego el `.app` contenedor por separado resella el ejecutable sin entitlements la segunda vez, borrando `allow-jit` — bug real detectado por `verify-bundle.sh` (BUNDLEJS-01) en el checkpoint de Fase 17, invisible en local porque un build ad-hoc sin hardened runtime no fuerza la restricción de JIT | ✓ Good (Phase 17-01, checkpoint humano) |
| [v6.0] `_bump_version` identifica bloques `XCBuildConfiguration` por `PRODUCT_BUNDLE_IDENTIFIER` exacto (no por posición/UUID) | Un `sed` global sobre todo el `.pbxproj` bumpeaba también `ExtractorAppTests`, que comparte los mismos valores de versión por coincidencia — el identificador de bundle es la única ancla estable e inequívoca entre ambos targets | ✓ Good (Phase 18-01, verificado contra copia del `.pbxproj` real) |
| [v6.0] POLISH-02 cerrado sin migrar Sparkle a paquete remoto | El bug de búsqueda de paquetes de Xcode 26.6 no tiene causa raíz confirmada tras investigación por búsqueda web; el usuario decidió explícitamente no invertir tiempo probando el fix candidato en su Mac real ahora — el paquete local ya es un mecanismo de producción funcional y verificado (Fases 12/16) | ✓ Good (Phase 18-01, decisión explícita del usuario) |
| [v7.0] Alcance = las 4 áreas restantes de `Deferred Items` de v6.0 (flags CLI, rollouts Sparkle, auto-actualización runtime, notarización distribución pública) | El usuario eligió explícitamente las 4 al preguntársele qué priorizar — no un subconjunto | Pending (definido, sin ejecutar) |
| [v7.0] Orden de fases: flags CLI → rollouts Sparkle → auto-actualización runtime → notarización distribución pública | Propuesto por Claude de menor a mayor complejidad/incertidumbre (ninguna fase depende de una posterior) y confirmado explícitamente por el usuario, igual que el patrón de v6.0 | Pending (definido, sin ejecutar) |
| [v7.0] "Notarización distribución pública" = web pública (GitHub Releases o similar), no Mac App Store | El App Store implica revisar App Sandbox (hoy OFF), Apple Review, metadatos en App Store Connect — mucho más grande y contradice el "Out of Scope: App Store" ya establecido del proyecto. El usuario confirmó explícitamente la opción web al preguntársele, manteniendo ese Out of Scope sin cambios | Pending (definido, sin ejecutar) |
| [v7.0] `_strip_images`/`_strip_links` mutan el `soup` in situ (`decompose`/`unwrap`) en vez de reconstruir el árbol | Reutiliza el mismo objeto `BeautifulSoup` ya construido en cada camino (texto/HTML/Markdown con y sin selector) sin duplicar lógica de parseo — un único punto de mutación cubre los tres return types | ✓ Good (Phase 19-01) |
| [v7.0] Camino trafilatura (Markdown sin selector) usa sus propios kwargs `include_images`/`include_links` en vez de mutar el soup | `trafilatura.extract()` opera sobre `html_text` crudo, no sobre el objeto `soup` de `core.py` — pasar sus flags nativos es más directo que reconstruir HTML desde un soup mutado solo para ese camino | ✓ Good (Phase 19-01) |
| [v7.0] `--clipboard` vía `subprocess.run(["pbcopy"], ...)`, no una dependencia pip nueva (`pyperclip` u otra) | El proyecto es macOS-only (Constraints), `pbcopy` ya está en cualquier Mac sin instalar nada — evita añadir una dependencia al runtime bundleado (Fase 8) solo para esto, consistente con el core value "sin depender de servicios externos" | ✓ Good (Phase 19-01) |
| [v7.0] `--clipboard` es aditivo (copia sin reemplazar la salida `--json`/`-o`/stdout existente) | Success Criterion 4 pedía los 3 flags "combinables... sin romper ningún contrato previo" — la interpretación más segura es que el comportamiento previo de cada modo de salida no cambia, y `--clipboard` solo añade una copia al portapapeles encima | ✓ Good (Phase 19-01) |
| [v7.0] `_build_parser()` extraída de `main()` | Añadir los 3 flags nuevos subió `main()` a 53 sentencias (límite pylint 50, `too-many-statements`) — extraer la construcción del parser (una operación pura, sin lógica de control) a su propia función bajó pylint a 10.00/10 sin cambiar comportamiento, mismo patrón que la extracción de `_lookup_title()` en la Fase 14-01 | ✓ Good (Phase 19-01) |
| [v7.0] `ROLLOUT_INTERVAL_SECONDS` vía variable de entorno, no un 3er argumento posicional | `<version> [canal]` ya estaba establecido desde la Fase 16 — añadir un 3er posicional obligaría a pasar el canal vacío (`""`) para usar solo rollout, mientras que una env var opcional se compone limpiamente con cualquier combinación sin tocar el uso existente | ✓ Good (Phase 20-01) |
| [v7.0] Flag `--phased-rollout-interval` confirmado inspeccionando el binario real de `generate_appcast` (extracción de strings ASCII con Python) en vez de asumirlo de memoria | El binario ya estaba descargado en `.build-cache/sparkle-tools/` (Fase 12) — verificar contra la fuente real evita implementar sobre un nombre de flag supuesto que podría no existir o estar mal escrito | ✓ Good (Phase 20-01) |
| [v7.0] Aborto de un rollout en marcha = editar `appcast.xml` a mano quitando `sparkle:phasedRolloutInterval`, no un flag/comando nuevo | Sparkle no documenta un mecanismo oficial de aborto; el proyecto ya trata `appcast.xml` como un archivo de repo revisado a mano antes de commitear (decisión de la Fase 13) — reutilizar ese flujo existente es más simple que construir tooling nuevo para un caso de uso raro | ✓ Good (Phase 20-01) |
| [v7.0] Fase 21 v1 acota el alcance a dependencias Python puras (requests/beautifulsoup4/markdownify/trafilatura) — nunca el intérprete, lxml ni Chromium | Actualizar binarios sueltos en tiempo de ejecución tiene incertidumbre real de Gatekeeper (no se pueden staplear, dependen de verificación online la primera vez); los `.py` puros nunca pasan por Gatekeeper al ser solo `import`eados como datos por el intérprete ya confiable del bundle. Decisión explícita del usuario tras la research (`21-RESEARCH.md`) — **confirmado en checkpoint humano**: ningún aviso de Gatekeeper en ningún momento al aplicar una actualización real | ✓ Good (Phase 21-01, checkpoint humano en Mac real) |
| [v7.0] Override del runtime = directorio antepuesto al PYTHONPATH del bundle, nunca reemplazo de archivos dentro del `.app` firmado | Evita por completo el riesgo de romper la firma de código del bundle; da degradación segura (PYRUNTIME-02) casi gratis — si el override no existe o falla, `PythonBridge` simplemente no lo antepone, sin lógica de rollback propia que pueda tener bugs | ✓ Good (Phase 21-01, confirmado en checkpoint borrando el override a mano) |
| [v7.0] `scripts/build_runtime_update.py` detecta y excluye paquetes con binarios compilados por inspección real (.so/.dylib/.pyd), no por lista fija de nombres | Más robusto ante cambios futuros en dependencias transitivas — verificado ejecutando el script de verdad en el sandbox Y en el Mac real (mismo resultado: excluye lxml/charset_normalizer/regex) | ✓ Good (Phase 21-01) |
| [v7.0] Verificación antes de activar un override = importación real contra el intérprete bundleado, no solo checksum SHA-256 | El checksum solo prueba que la descarga no se corrompió, no que los paquetes funcionan de verdad con esta versión concreta del intérprete — la importación real es la prueba que realmente importa | ✓ Good (Phase 21-01, checkpoint humano) |
| [v7.0] Mensaje de error de `.failed(message:)` movido al texto de estado principal (no una etiqueta secundaria diminuta) | Un timeout de red real durante el checkpoint humano (no relacionado con Gatekeeper) pasó casi desapercibido porque el mensaje solo aparecía en `caption2` bajo el botón — bug real de UI encontrado y corregido en el mismo checkpoint | ✓ Good (Phase 21-01, checkpoint humano) |
| [v7.0] `resultCard` sale del `ScrollView` general y usa `.frame(maxHeight: .infinity)` para ocupar el espacio vertical restante de la ventana | El `ScrollView` envolvía todo el layout (input/opciones/resultado/exportar); su `VStack` solo se dimensionaba al alto natural del contenido, dejando el preview HTML fijo en `minHeight:240` sin crecer nunca — bug real de layout reportado por el usuario tras el checkpoint de la Fase 21, sin relación con esa fase | ✓ Good (encontrado y corregido fuera de fase, 2026-08-24) |
| [v7.0] `.fixedSize()` en las etiquetas "Formato:"/"Exportar como" y sus `Picker` segmentados | El `Picker(.segmented)` no se comprimía limpiamente pese al `.frame(maxWidth:)` aplicado, solapando el texto de la etiqueta — `.fixedSize()` fuerza el tamaño natural en vez de dejar que el layout los comprima | ✓ Good (encontrado y corregido fuera de fase, 2026-08-24) |
| [v7.0] Fase 22 (PUBLISH-01/02) no necesitó ningún cambio de pipeline | El `.app` ya se notariza+staplea y se publica en un repo GitHub público desde la Fase 13 — el mecanismo técnico central ya existía; la fase fue verificación (`spctl -a -vvv --type execute` contra un release real: `accepted`, `source=Notarized Developer ID`) y corrección de documentación que decía lo contrario | ✓ Good (Phase 22-01) |
| [v8.0] Alcance = una única fase corta agrupando ítems de mantenimiento, no un milestone con backlog de funcionalidad | A diferencia de v6.0/v7.0, `Deferred Items` de `STATE.md` solo tenía ítems de verificación/mantenimiento (tamaño de build Release, notarización real con Chromium, `--clipboard` contra `pbcopy` real) que dependen todos de ejecutar un release real — no había funcionalidad nueva pendiente. El usuario confirmó explícitamente esta decisión al preguntársele | ✓ Good (v8.0 cerrado 2026-08-27) |
| [v8.0] Cerrar la Fase 23 verificando el release público `v2.1` en vez de lanzar uno nuevo | El `.app` de `v2.1` ya estaba publicado, notarizado y stapled (`spctl`/`stapler`/`codesign` OK, cero Mach-O sin hardened runtime) — SC1/SC2/SC3 se comprueban contra él sin gastar cuota de notarización ni arriesgar un release. `af48439`/`cc1af03` endurecen el pipeline para el próximo | ✓ Good |
| [v8.0] SC4 (rollout en appcast) y SC6 (bug `Info.plist` Xcode 27) se cierran como "diferidos-condicionales", no como bloqueos | Son criterios "si/cuando un release futuro haga X" — SC4 solo aplica si se usa `ROLLOUT_INTERVAL_SECONDS`, SC6 solo es observable durante un build nuevo. El usuario aprobó cerrar v8.0 así | ✓ Good |

## Evolution

Este documento evoluciona en transiciones de fase y límites de milestone.

**Después de cada fase:** mover requirements validados a Validated, añadir decisiones a Key Decisions.
**Después de cada milestone:** revisar Core Value, auditar Out of Scope, actualizar Context.

---
*Last updated: 2026-08-27 — v6.0, v7.0 y v8.0 completos y cerrados. Sin milestone activo. Siguiente hito natural: release real 2.2+.*
