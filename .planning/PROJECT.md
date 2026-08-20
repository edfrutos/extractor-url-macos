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

### Out of Scope

- App Store o distribución comercial — no es el objetivo.
- Embeber Playwright/Chromium en el `.app` bundle de la app SwiftUI — v4 es solo motor Python (CLI); +300MB de peso no es aceptable para el bundle zero-config de v3. Revisar en v6+ si hay demanda real.
- Flag manual `--js`/`--no-js` para forzar u omitir el fallback — v4 usa solo detección automática; un control manual explícito queda diferido.
- Historial de extracciones y cola — v6+.
- Canales beta/nightly, rollouts por fases — Sparkle los soporta pero v5.0 no los necesita (pocos usuarios).
- Notarización para **distribución pública a terceros** (App Store, web pública) sigue fuera de alcance — la notarización de v5.0 es solo para que las actualizaciones vía Sparkle no muestren avisos de Gatekeeper en las propias instalaciones del autor, no para publicar la app a desconocidos.

## Context

El proyecto tiene dos capas: el motor Python (`core.py` + `extractor_url.py`) y la app nativa SwiftUI (`ExtractorApp/`). La app lanza el motor vía `Foundation.Process()` con `--json`. v3.0 eliminó la dependencia del usuario de instalar Python y configurar rutas. v4.0 amplió el motor Python para extraer contenido de páginas que requieren JavaScript (SPAs). v5.0 añade auto-actualización a la app SwiftUI (Sparkle) para eliminar la distribución 100% manual del `.app`.

## Current Milestone: v5.0 Auto-actualización (Sparkle) — COMPLETADO 2026-08-20

**Goal:** La app comprueba e instala nuevas versiones de sí misma automáticamente (Sparkle 2), sin que el usuario tenga que descargar y reemplazar el `.app` a mano — con un pipeline de release reproducible (build → firma Developer ID → notarización → appcast → GitHub Releases).

**Target features:**

- Sparkle 2 integrado en `ExtractorApp.xcodeproj` vía SPM, con comprobación automática (24h) + ítem de menú manual
- `appcast.xml` alojado en GitHub Releases del propio repo, sin infraestructura nueva
- `scripts/release-macos.sh` automatiza el pipeline completo de publicación
- Actualizaciones firmadas con EdDSA (Sparkle) + Developer ID notarizado (Gatekeeper) — doble verificación

## Current State

Milestone v1.0 (Stabilization) completado: suite `pytest` con 14 tests, pylint 10/10, contratos CLI explícitos.
Milestone v2.0 (SwiftUI Native App) completado: app macOS nativa, bridge Python async, export MD/HTML/PDF, universal binary, UI premium con dark mode automático.
Milestone v3.0 (Standalone App) completado y cerrado: Fases 8, 9 y 10 verificadas con `xcodebuild` real (Build Succeeded, 49 tests/3 skipped/0 fallos, checklist visual OK) — ver `.planning/phases/10-ux-zero-config/10-01-SUMMARY.md`.
Milestone v4.0 (Contenido Dinámico) completado y cerrado: Fase 11 implementa `_looks_insufficient()` + `_fetch_via_playwright()` en `core.py`, integrados en `_fetch_raw()`. Verificado con `pytest tests/` (28/28), `pylint` 10/10 y `mypy` limpio en un venv equivalente al del repo — ver `.planning/phases/11-playwright-fallback/11-01-SUMMARY.md`.
Milestone v5.0 (Auto-actualización) completado y cerrado: Fase 12 (Sparkle integrado en la app, paquete local por un bug de búsqueda de Xcode 26.6) y Fase 13 (`scripts/release-macos.sh` — build, firma Developer ID, notarización, appcast firmado con EdDSA, publicación en GitHub Releases) verificadas con un release real: `https://github.com/edfrutos/extractor-url-macos/releases/tag/v1.0`, `appcast.xml` publicado y confirmado en vivo — ver `.planning/phases/13-release-pipeline/13-01-SUMMARY.md` para los 4 bugs reales encontrados y corregidos durante el checkpoint (team ID en exportOptions.plist, hardened runtime del Python embebido, orden de bootstrap, firma EdDSA de generate_appcast).

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

## Evolution

Este documento evoluciona en transiciones de fase y límites de milestone.

**Después de cada fase:** mover requirements validados a Validated, añadir decisiones a Key Decisions.
**Después de cada milestone:** revisar Core Value, auditar Out of Scope, actualizar Context.

---
*Last updated: 2026-08-20 — Milestone v5.0 Auto-actualización (Sparkle) cerrado: primer release real v1.0 publicado y verificado en vivo (appcast.xml firmado, GitHub Release)*
