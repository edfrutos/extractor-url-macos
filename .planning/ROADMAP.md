# Roadmap: extractor-url

## v2.0 SwiftUI Native App

## Overview

Construir una app macOS nativa en SwiftUI que lanza el extractor Python existente vía subprocess y exporta el resultado íntegro a Markdown, HTML autocontenido y PDF. El motor Python no se modifica: Swift gestiona toda la UI y el sistema de archivos; Python sigue siendo el motor de extracción sin cambios.

El bridge subprocess es la dependencia bloqueante de todo el milestone. Las fases siguen un orden estricto en cadena.

## Phases

- [x] **Phase 3: Python Bridge y Preferencias** - Cimentar el bridge subprocess async y las preferencias de ruta antes de tocar UI. (completed 2026-06-14)
- [x] **Phase 4: SwiftUI UI de Extracción** - Primera interfaz funcional end-to-end: campo URL, controles, progreso y errores. (completed 2026-06-11)
- [x] **Phase 5: Preview y Export MD/HTML** - Preview WKWebView del contenido extraído y exportación a Markdown y HTML autocontenido. (completed 2026-06-12)
- [x] **Phase 6: Export PDF** - Exportación PDF vectorial vía WKWebView con control de timing de renderizado. (completed 2026-06-12)
- [x] **Phase 7: Universal Binary y Configuración de Build** - Verificación fat binary, firma, notarización y empaquetado .dmg. (completed 2026-06-13)

## Phase Details

### Phase 3: Python Bridge y Preferencias

**Goal**: El bridge `Foundation.Process()` llama al CLI Python con `--json`, captura stdout/stderr de forma asíncrona sin deadlock, y las rutas al intérprete y al script son configurables y validadas en la pantalla de Preferencias.
**Depends on**: Nothing (first phase of v2.0)
**Requirements**: BRIDGE-01, BRIDGE-02, BRIDGE-03, BRIDGE-04, SETTINGS-01, SETTINGS-02, SETTINGS-03, APP-05
**Success Criteria** (what must be TRUE):

  1. Desde Preferencias el usuario puede configurar la ruta al intérprete Python y al script, y la app avisa si alguna ruta no es ejecutable.
  2. Llamar a `PythonBridge.run(url:type:)` con una URL válida devuelve un `ExtractionResult` con contenido, sin congelar la UI.
  3. Si Python no está en la ruta configurada o el CLI falla, el error tipado se propaga y es inspeccionable (no se silencia).
  4. La extracción corre en `Task.detached` — la ventana responde a eventos durante los 5-30 segundos que dura el proceso.

**Plans**: 4 planes — 03-01-PLAN.md · 03-02-PLAN.md · 03-03-PLAN.md · 03-04-PLAN.md

- [x] 03-01-PLAN.md — Proyecto Xcode + entitlements + modelos ExtractionResult y ExtractionError
- [x] 03-02-PLAN.md — PythonBridge (subprocess async paralelo) + SettingsView con validación reactiva
- [x] 03-03-PLAN.md — ContentView rediseño premium con LogoMark + assets de marca
- [x] 03-04-PLAN.md — ContentView y SettingsView colores semánticos del sistema (macOS 13 compatible)

**UI hint**: yes

### Phase 4: SwiftUI UI de Extracción

**Goal**: El usuario puede introducir una URL, elegir tipo de salida y opciones avanzadas, lanzar la extracción y ver el resultado o el error directamente en la ventana principal.
**Depends on**: Phase 3
**Requirements**: APP-01, APP-02, APP-03, UI-01, UI-03
**Success Criteria** (what must be TRUE):

  1. El usuario introduce una URL, selecciona tipo (text/html/markdown) y pulsa Extraer — la app muestra un `ProgressView` indeterminado mientras trabaja.
  2. Una vez completada la extracción, los controles de exportación se habilitan; antes de completarla permanecen deshabilitados.
  3. Si la extracción falla, la ventana muestra el mensaje de error de forma explícita (alert o inline) sin necesidad de relanzar la app.
  4. El usuario puede configurar selector CSS y timeout desde la UI antes de extraer.

**Plans**: 2 planes — 04-01-PLAN.md · 04-02-PLAN.md

- [x] 04-01-PLAN.md — ExtractionViewModel: ObservableObject con @Published + extract() wiring PythonBridge
- [x] 04-02-PLAN.md — ContentView reescritura completa + verificación build end-to-end

**UI hint**: yes

### Phase 5: Preview y Export MD/HTML

**Goal**: El usuario puede previsualizar el contenido extraído renderizado en un WKWebView y guardarlo como archivo `.md` o `.html` autocontenido desde un panel de guardado nativo.
**Depends on**: Phase 4
**Requirements**: UI-02, EXPORT-01, EXPORT-02, EXPORT-03
**Success Criteria** (what must be TRUE):

  1. El contenido Markdown extraído se muestra renderizado visualmente (no como texto raw) en el área de preview.
  2. El usuario selecciona formato MD y pulsa Exportar — se abre `NSSavePanel`/`fileExporter` y el archivo guardado se abre correctamente en cualquier editor de texto.
  3. El usuario selecciona formato HTML y pulsa Exportar — el archivo `.html` resultante se abre en Safari/Chrome sin assets externos rotos y aplica dark mode según las preferencias del sistema.
  4. El selector de formato (MD / HTML / PDF) está visible antes de exportar y refleja el formato activo.

**Plans**: 2 planes — Wave 1: 05-01-PLAN.md · Wave 2: 05-02-PLAN.md (blocked on Wave 1)

- [x] 05-01-PLAN.md — ExtractionViewModel: contentReady/exportFormat, htmlForPreview, generateHTML autocontenido + target XCTest y tests unitarios
- [x] 05-02-PLAN.md — WebPreviewView (NSViewRepresentable WKWebView) + ContentView con fila de exportación + verificación visual

**UI hint**: yes

### Phase 6: Export PDF

**Goal**: El usuario puede exportar el contenido previamente renderizado en WKWebView como PDF vectorial con texto seleccionable, sin páginas en blanco, vía `WKWebView.pdf(configuration:)`.
**Depends on**: Phase 5
**Requirements**: EXPORT-04
**Success Criteria** (what must be TRUE):

  1. El botón de exportación PDF está deshabilitado hasta que el DOM del WKWebView ha completado el renderizado (`contentReady = true`).
  2. El archivo PDF resultante contiene el contenido íntegro, el texto es seleccionable y no hay páginas en blanco.
  3. Se abre `NSSavePanel` con extensión `.pdf` y nombre sugerido derivado del título de la página antes de guardar.

**Plans**: 3 planes — Wave 1: 06-01-PLAN.md · 06-02-PLAN.md · Wave 2: 06-03-PLAN.md (blocked on 06-02)

- [x] 06-01-PLAN.md — Contrato JSON Python: campo `title` (`_extract_title` + bloque JSON + tests)
- [x] 06-02-PLAN.md — Contrato Swift: `ExtractionResult.title`, `pageTitle`, `suggestedFilename(title:)` unificado + tests
- [x] 06-03-PLAN.md — `exportPDF()` (createPDF + modo claro + NSSavePanel + NSAlert), habilitar Picker PDF + verificación humana

**UI hint**: yes

### Phase 7: Universal Binary y Configuración de Build

**Goal**: La app compila como fat binary arm64+x86_64 con deployment target macOS 13.0, App Sandbox desactivado, Hardened Runtime activo, y puede distribuirse directamente vía .dmg con firma Developer ID.
**Depends on**: Phase 6
**Requirements**: APP-04, APP-05
**Success Criteria** (what must be TRUE):

  1. `lipo -archs ExtractorApp` devuelve `x86_64 arm64` en el binario de Release.
  2. La app arranca y extrae contenido correctamente en un Mac Apple Silicon y en un Mac Intel (o Rosetta) con macOS 13.0.
  3. El archivo `.entitlements` tiene `app-sandbox = false` y `hardened-runtime = true`; la app pasa la notarización con `stapler`.

**Plans**: 2 planes — Wave 1: 07-01-PLAN.md · Wave 2: 07-02-PLAN.md (blocked on Wave 1)

- [x] 07-01-PLAN.md — Build settings: MACOSX_DEPLOYMENT_TARGET = 13.0, ARCHS = arm64 x86_64 + entitlements hardened-runtime
- [x] 07-02-PLAN.md — Validación binaria: lipo -archs, codesign verification, ejecución y checkpoint humano (completed 2026-06-13)

**UI hint**: no

## Progress

**Execution Order:** Phases execute in numeric order: 3 → 4 → 5 → 6 → 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 3. Python Bridge y Preferencias | 4/4 | Complete | 2026-06-14 |
| 4. SwiftUI UI de Extracción | 2/2 | Complete | 2026-06-11 |
| 5. Preview y Export MD/HTML | 2/2 | Complete | 2026-06-12 |
| 6. Export PDF | 3/3 | Complete | 2026-06-13 |
| 7. Universal Binary y Configuración de Build | 2/2 | Complete | 2026-06-13 |

---

## Completed: v1.0 Stabilization

### Phase 1: Validacion automatica del conversor

**Goal**: Crear una base de tests locales que congele el comportamiento correcto del conversor Markdown y permita evolucionar el proyecto sin regresiones.
**Depends on**: Nothing (first phase)
**Requirements**: REQ-01, REQ-02, REQ-03
**Success Criteria** (what must be TRUE):

  1. Existe un directorio `tests/` con fixtures HTML locales y pruebas ejecutables.
  2. El flujo Markdown actual queda cubierto en los casos de limpieza DOM, selector CSS y URLs relativas.
  3. La documentación principal deja claro qué está implementado y qué queda pendiente.

**Status**: Complete — 2026-06-03

- [x] 01-01: Crear base de tests y alinear documentación de la fase
- [x] 01-02: Cerrar gaps de `pytest tests/` y desajuste documental en `NOTEBOOK.md`

### Phase 2: Robustez CLI y manejo explícito de errores

**Goal**: Corregir las regresiones y silencios peligrosos de la CLI pública para que la herramienta falle de forma explícita, soporte `--gui` como está documentado y quede cubierta por pruebas sobre sus caminos de error principales.
**Depends on**: Phase 1
**Requirements**: REQ-04, REQ-05, REQ-06
**Success Criteria** (what must be TRUE):

  1. `python extractor_url.py --gui` abre la interfaz sin exigir URL posicional.
  2. Un fallo al guardar con `-o/--output` devuelve exit code distinto de cero.
  3. Un selector CSS inválido no amplía silenciosamente el alcance de extracción.
  4. Existen pruebas automatizadas sobre la CLI pública y sus caminos de error principales.

**Status**: Complete — 2026-06-09

- [x] Corregir contratos de error y añadir cobertura CLI

---

## v3.0 Standalone App

Eliminar la dependencia del usuario de instalar Python y configurar rutas manualmente. El runtime Python universal, los scripts del motor de extracción y todas las dependencias Python van embebidos dentro del `.app bundle`. PythonBridge detecta las rutas del bundle automáticamente; SettingsView informa del modo de operación y mantiene override opcional para uso avanzado.

BUNDLE-01 es la dependencia bloqueante: sin el runtime embebido, las fases 9 y 10 no pueden completarse.

### Checklist v3.0

- [x] **Phase 8: Bundle Python Runtime** - Empaquetar el runtime Python universal y las dependencias vendorizadas dentro del .app. (completed 2026-06-15)
- [x] **Phase 9: Bridge Auto-detección de Rutas** - PythonBridge localiza el runtime y el script del bundle vía `Bundle.main.resourcePath` sin configuración del usuario. (completed 2026-06-16)
- [x] **Phase 10: UX Zero-Config** - SettingsView refleja el modo bundled e informa al usuario; primera apertura extrae sin configuración previa. (completed 2026-08-18, verificado con xcodebuild real)

### Phase 8: Bundle Python Runtime

**Goal**: El `.app` bundle contiene un intérprete Python universal (arm64+x86_64), los scripts del motor de extracción y todas las dependencias Python vendorizadas, de forma que la app puede ejecutar extracciones en cualquier Mac sin que el usuario instale nada.
**Depends on**: Phase 7
**Requirements**: BUNDLE-01, BUNDLE-02, BUNDLE-03
**Success Criteria** (what must be TRUE):

  1. El directorio `Contents/Resources/python/bin/python3` existe en el bundle, es ejecutable y `lipo -archs` devuelve `x86_64 arm64`.
  2. Los archivos `extractor_url.py` y `core.py` están presentes en `Contents/Resources/scripts/` y son legibles vía `Bundle.main.resourcePath`.
  3. Las dependencias `requests`, `beautifulsoup4`, `lxml`, `markdownify` y `trafilatura` están instaladas en `Contents/Resources/python/lib/` (vendorizadas con `pip install --target`) y son importables desde el intérprete bundleado sin acceso a red ni a `pip` del sistema.
  4. Un script de shell de validación ejecutado sobre el `.app` de Release invoca `Contents/Resources/python/bin/python3 Contents/Resources/scripts/extractor_url.py --json https://example.com` y devuelve JSON válido.

**Plans**: 3 planes — Wave 1: 08-01-PLAN.md · 08-02-PLAN.md · Wave 2: 08-03-PLAN.md
- [x] 08-01-PLAN.md — scripts/bundle-python.sh: descarga, lipo merge, pip vendorize, codesign
- [x] 08-02-PLAN.md — Xcode: Copy Python Scripts phase + Run Script "Bundle Python Runtime"
- [x] 08-03-PLAN.md — scripts/verify-bundle.sh (14 OK) + BundlePathTests.swift (7/7) + validación end-to-end

**UI hint**: no

### Phase 9: Bridge Auto-detección de Rutas

**Goal**: `PythonBridge.swift` resuelve automáticamente las rutas al intérprete y al script desde `Bundle.main.resourcePath`, sin leer `UserDefaults`, y acepta un override de `UserDefaults` cuando el usuario ha configurado rutas válidas explícitamente (compatibilidad v2.0).
**Depends on**: Phase 8
**Requirements**: BRIDGE-05, BRIDGE-06, BRIDGE-07
**Success Criteria** (what must be TRUE):

  1. En una instalación limpia (sin `UserDefaults` previos), `PythonBridge` llama al intérprete bundleado y al script bundleado — ninguna ruta del sistema operativo del usuario es necesaria.
  2. Si `UserDefaults` contiene rutas válidas y ejecutables (override v2.0), `PythonBridge` las usa en lugar de las del bundle — el comportamiento anterior se preserva sin migración.
  3. Si las rutas de `UserDefaults` existen pero no son ejecutables o no existen en disco, `PythonBridge` cae al bundle sin lanzar error al usuario.
  4. `PythonBridgeTests` cubre las tres ramas: bundle por defecto, override válido y override inválido con fallback al bundle.

**Plans**: 1 plan — Wave 1: 09-01-PLAN.md

Plans:
- [x] 09-01-PLAN.md — resolvedPaths() + PathSource + run() bifurcado + 3 tests de ramas (completed 2026-06-16)

**UI hint**: no

### Phase 10: UX Zero-Config

**Goal**: El usuario abre la app por primera vez y puede extraer contenido inmediatamente sin abrir Preferencias ni configurar ninguna ruta; SettingsView muestra el modo de operación activo y mantiene la sección de override como opción avanzada colapsada.
**Depends on**: Phase 9
**Requirements**: UX-01, UX-02, UX-03
**Success Criteria** (what must be TRUE):

  1. El usuario instala el `.app`, lo abre y pulsa Extraer con una URL — la extracción completa sin haber abierto Preferencias ni configurado nada.
  2. SettingsView muestra una fila o badge "Usando Python incluido (Python X.X.X)" con la versión real del intérprete bundleado cuando opera en modo bundle.
  3. Los campos de override de rutas están presentes en SettingsView pero visualmente diferenciados como sección avanzada opcional — no interfieren con el flujo por defecto.
  4. Si el usuario borra los overrides de `UserDefaults`, la app vuelve al modo bundle y el badge informativo aparece de nuevo en SettingsView.

**Plans**: 1 plan — Wave 1: 10-01-PLAN.md

Plans:
- [x] 10-01-PLAN.md — PythonOperatingMode + bundledPythonVersion() + badge SettingsView + sección avanzada colapsable + 4 tests de modo (completed 2026-08-17)

**UI hint**: yes

### Estado v3.0

**Execution Order:** Phases execute in numeric order: 8 → 9 → 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. Bundle Python Runtime | 3/3 | Complete | 2026-06-15 |
| 9. Bridge Auto-detección de Rutas | 1/1 | Complete | 2026-06-16 |
| 10. UX Zero-Config | 1/1 | Complete | 2026-08-18 |

---

## v4.0 Contenido Dinámico (JS)

## Overview

Extender el motor Python (`core.py`) para extraer contenido de páginas que dependen de JavaScript del lado del cliente (SPAs), que hoy devuelven HTML vacío o mínimo vía `requests` + `BeautifulSoup`. El fallback a Playwright (Chromium headless) es automático por heurística — sin flag manual, sin cambios en la app SwiftUI, sin tocar el bundle zero-config de v3.0.

JS-01 (heurística de detección) es la dependencia bloqueante: sin ella, JS-02 no tiene forma de decidir cuándo activarse y JS-04 no tiene nada que testear.

### Checklist v4.0

- [x] **Phase 11: Playwright Fallback para Contenido Dinámico** - `core.py` detecta contenido estático insuficiente y reintenta automáticamente con Playwright antes de fallar. (completed 2026-08-18)

### Phase 11: Playwright Fallback para Contenido Dinámico

**Goal**: `core.py` detecta cuando la extracción estática (`requests` + `BeautifulSoup`) devuelve contenido vacío o insuficiente, y reintenta automáticamente renderizando la página con Playwright (Chromium headless) antes de fallar — sin cambiar el comportamiento ni el rendimiento en sitios estáticos normales, y sin romper el entorno bundleado de la app (que no incluye Playwright).
**Depends on**: Nothing nuevo — extiende `core.py` de v1.0; independiente de la app SwiftUI (v2.0/v3.0).
**Requirements**: JS-01, JS-02, JS-03, JS-04
**Success Criteria** (what must be TRUE):

  1. Una URL que devuelve HTML mínimo/vacío por la vía estática (ej. SPA renderizada 100% en cliente) se extrae con contenido real al activarse el fallback Playwright.
  2. Un sitio estático normal (blog, artículo) no activa Playwright — mismo tiempo de respuesta y comportamiento que en v1-v3.
  3. Si Playwright/Chromium no están instalados en el entorno (ej. runtime embebido de la app v3.0, que no lo incluye por decisión de scope), la extracción degrada al resultado estático con un aviso explícito, sin excepción no controlada.
  4. Tests cubren la heurística de detección de contenido insuficiente y el camino de fallback con fixtures/mocks, sin exigir un navegador real para pasar en un entorno CI estándar.

**Plans**: 1 plan — Wave 1: 11-01-PLAN.md

Plans:
- [x] 11-01-PLAN.md — `_looks_insufficient()` + `_fetch_via_playwright()` + integración en `_fetch_raw()` + 8 tests (completed 2026-08-18)

**UI hint**: no — fuera de scope de la app SwiftUI en v4.0

### Estado v4.0

**Execution Order:** Phases execute in numeric order: 11

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 11. Playwright Fallback para Contenido Dinámico | 1/1 | Complete | 2026-08-18 |

---

## v5.0 Auto-actualización (Sparkle)

## Overview

Eliminar la distribución 100% manual del `.app`: la app comprueba e instala
sus propias actualizaciones vía Sparkle 2, con un pipeline de release
reproducible (`scripts/release-macos.sh`) que construye, firma con
Developer ID, notariza, genera el appcast firmado con EdDSA, y publica en
GitHub Releases del propio repo — sin infraestructura de hosting nueva.

UPDATE-01 (paquete SPM añadido en Xcode) es la dependencia bloqueante de
toda la Fase 12; UPDATE-04..06 (Fase 13) dependen de que UPDATE-03 exista
en `Info.plist` antes de tener sentido generar claves/appcast reales.

### Checklist v5.0

- [x] **Phase 12: Integración Sparkle en la app** - Sparkle 2 vía SPM (local, ver desviación en 12-01-SUMMARY.md), `SPUStandardUpdaterController`, ítem de menú "Buscar actualizaciones…". (completed 2026-08-20)
- [x] **Phase 13: Pipeline de release y publicación** - `scripts/release-macos.sh` automatiza build→firma→notarización→appcast→GitHub Releases. (completed 2026-08-20 — primer release real v1.0 publicado)

### Phase 12: Integración Sparkle en la app

**Goal**: La app inicializa Sparkle 2 (`SPUStandardUpdaterController`) en su entry point SwiftUI, comprueba actualizaciones automáticamente en segundo plano (comportamiento por defecto de Sparkle, 24h) y expone un ítem de menú manual "Buscar actualizaciones…" — sin tocar `ContentView`, `SettingsView`, `PythonBridge` ni el motor Python.
**Depends on**: Nothing nuevo — extiende la app SwiftUI existente (v2.0/v3.0); ortogonal al motor Python (v1.0/v4.0).
**Requirements**: UPDATE-01, UPDATE-02, UPDATE-03
**Success Criteria** (what must be TRUE):

  1. El paquete SPM `sparkle-project/Sparkle` está añadido al target `ExtractorApp` y el proyecto compila (`Build Succeeded`) en Xcode.
  2. `ExtractorAppApp.swift` inicializa `SPUStandardUpdaterController` una sola vez y expone `CheckForUpdatesView` vía `CommandGroup(after: .appInfo)`.
  3. El ítem de menú "Buscar actualizaciones…" aparece en el menú de la app junto a "Acerca de ExtractorApp" al ejecutar la app en Xcode.
  4. `Info.plist` (vía `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey`) apunta al appcast real de GitHub Releases, con la clave pública como placeholder explícito hasta la Fase 13.

**Plans**: 1 plan — Wave 1: 12-01-PLAN.md

Plans:
- [x] 12-01-PLAN.md — ExtractorAppApp.swift + CheckForUpdatesView.swift + INFOPLIST_KEY_SU* + paquete Sparkle local en .build-cache/ (completed 2026-08-20)

**UI hint**: yes

### Phase 13: Pipeline de release y publicación

**Goal**: Existe un proceso reproducible (`scripts/release-macos.sh`) para publicar una nueva versión de la app: genera/reutiliza las claves EdDSA, construye y firma con Developer ID, notariza, genera el appcast firmado, y publica el binario + appcast en GitHub Releases del repo — de forma que una actualización instalada vía Sparkle no muestre avisos de Gatekeeper.
**Depends on**: Phase 12 (UPDATE-03 debe existir en `Info.plist` antes de que generar un appcast real tenga sentido).
**Requirements**: UPDATE-04, UPDATE-05, UPDATE-06
**Success Criteria** (what must be TRUE):

  1. `scripts/release-macos.sh` construye, firma (Developer ID), notariza (`notarytool submit --wait` + `stapler staple`), genera el appcast (`generate_appcast`) y publica en GitHub Releases (`gh release create`/`upload`) sin pasos manuales adicionales más allá de proporcionar credenciales vía variables de entorno.
  2. El `appcast.xml` resultante, servido vía `raw.githubusercontent.com`, es válido y su `<enclosure>` incluye la firma EdDSA correcta.
  3. Una instalación previa de la app (build Developer ID notarizado, versión anterior) detecta la nueva versión vía Sparkle, la descarga, instala y relanza sin avisos de Gatekeeper.
  4. La clave privada EdDSA y las credenciales de notarización nunca aparecen en el repo — documentado explícitamente en `RELEASING.md` o equivalente.

**Plans**: 1 plan — Wave 1: 13-01-PLAN.md

Plans:
- [x] 13-01-PLAN.md — scripts/release-macos.sh + RELEASING.md + primer release real v1.0 (completed 2026-08-20)

**UI hint**: no

### Estado v5.0

**Execution Order:** Phases execute in numeric order: 12 → 13

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 12. Integración Sparkle en la app | 1/1 | Complete | 2026-08-20 |
| 13. Pipeline de release y publicación | 1/1 | Complete | 2026-08-20 |

---

## v6.0 Historial y Distribución Completa

## Overview

Cierra el backlog explícito diferido en v4.0/v5.0. Cinco temas sin relación
técnica directa entre sí — historial/cola de extracciones (motor Python +
app), control manual del fallback JS (motor Python), canales beta de
Sparkle (pipeline de release + app), Playwright embebido en el bundle
(empaquetado, retoma la Fase 8), y pulido técnico menor. Orden fijado
explícitamente por el usuario: 14 → 15 → 16 → 17 → 18, sin depender unas de
otras salvo donde se indica.

**Aviso de alcance**: la Fase 17 (Playwright/Chromium embebido) es
sustancialmente más grande que el resto — descargar y vendorizar Chromium
(varios binarios internos: helpers de proceso, GPU, renderer, crashpad
handler, etc.), cada uno firmado con Developer ID + hardened runtime para
ser notarizable, es un proyecto comparable en alcance a toda la Fase 8 de
v3.0 (que solo tuvo que resolver esto para un único intérprete Python).
Tratarla como su propio sub-ciclo de research/plan/checkpoint cuando le
toque el turno, no asumir que será tan rápida como las fases 14-16.

### Checklist v6.0

- [x] **Phase 14: Historial y cola de extracciones** - Persistencia de extracciones previas + procesamiento de varias URLs en cola. (completed 2026-08-21)
- [x] **Phase 15: Flag manual `--js`/`--no-js`** - Control explícito del fallback Playwright junto a la heurística automática de v4.0. (completed 2026-08-21)
- [x] **Phase 16: Canales beta de Sparkle** - Publicar y recibir actualizaciones en un canal `beta` opcional. (completed 2026-08-21)
- [x] **Phase 17: Playwright/Chromium embebido en el bundle** - El fallback JS funciona en la app SwiftUI sin depender de una instalación externa de Playwright. (completed 2026-08-22)
- [x] **Phase 18: Pulido técnico** - Acotar `_bump_version`, investigar el bug del buscador de paquetes de Xcode 26.6. (completed 2026-08-23)

### Phase 14: Historial y cola de extracciones

**Goal**: El usuario puede consultar extracciones anteriores sin repetirlas, y puede encolar varias URLs para procesarlas secuencialmente sin intervención manual por cada una.
**Depends on**: Nothing nuevo — extiende motor Python (`core.py`/`extractor_url.py`) y app SwiftUI (`ContentView`/nueva vista de historial), sin tocar Sparkle ni el bundling.
**Requirements**: HIST-01, HIST-02, HIST-03
**Success Criteria** (what must be TRUE):

  1. Cada extracción completada (éxito o error) queda registrada localmente con URL, fecha, formato y resultado/mensaje de error.
  2. El usuario puede ver el historial desde la app y reabrir/reexportar una extracción previa sin volver a descargar la URL.
  3. El usuario puede encolar varias URLs (desde la app y/o la CLI) y el sistema las procesa una a una sin que el usuario tenga que relanzar el comando/pulsar Extraer por cada una.
  4. El historial no depende de servicios externos — almacenamiento local, consistente con el core value del proyecto.

**Plans**: 2 planes — Wave 1: 14-01-PLAN.md (Python) · 14-02-PLAN.md (Swift)

Plans:
- [x] 14-01-PLAN.md — `record_history_entry()`/`load_history()` en core.py, `--batch` NDJSON en extractor_url.py (completed 2026-08-20, pytest 40/40, pylint 10/10, mypy limpio)
- [x] 14-02-PLAN.md — vista de historial en la app SwiftUI (HIST-02): HistoryEntry/HistoryViewModel/HistoryView + integración ContentView, checkpoint humano en Xcode verificado (completed 2026-08-21)

**UI hint**: yes

### Phase 15: Flag manual `--js`/`--no-js`

**Goal**: El usuario puede forzar u omitir explícitamente el fallback Playwright desde la CLI, sin depender únicamente de la heurística automática de `_looks_insufficient()` (v4.0).
**Depends on**: Phase 11 (v4.0) — extiende `core.py`/`extractor_url.py`, no la sustituye.
**Requirements**: FLAG-01, FLAG-02
**Success Criteria** (what must be TRUE):

  1. `--js` fuerza el render con Playwright aunque la heurística automática no lo hubiera activado.
  2. `--no-js` desactiva el fallback Playwright aunque la heurística automática sí lo activaría.
  3. Sin pasar ninguno de los dos flags, el comportamiento es exactamente el de v4.0 (heurística automática, sin cambios).
  4. Tests cubren los 2 flags sin depender de un browser real, siguiendo el mismo patrón de mocking que `tests/test_js_fallback.py`.

**Plans**: 1 plan — Wave 1: 15-01-PLAN.md

Plans:
- [x] 15-01-PLAN.md — js_mode ("auto"/"force"/"off") en core.py + --js/--no-js en extractor_url.py, 51/51 tests, pylint 10/10, mypy limpio (completed 2026-08-21)

**UI hint**: no

### Phase 16: Canales beta de Sparkle

**Goal**: Es posible publicar una versión en un canal `beta` separado del canal por defecto, y la app puede optar (opt-in) a recibirlas, sin afectar a los usuarios en el canal estable.
**Depends on**: Phase 13 (`scripts/release-macos.sh` y el pipeline de publicación ya existentes).
**Requirements**: CHANNEL-01, CHANNEL-02
**Success Criteria** (what must be TRUE):

  1. `scripts/release-macos.sh` acepta un flag/variable para publicar en el canal `beta` (`sparkle:channel`) sin tocar las entradas del canal por defecto en el mismo `appcast.xml`.
  2. La app, si el usuario opta al canal beta, ve y puede instalar versiones marcadas como `beta` vía `SPUUpdaterDelegate.allowedChannelsForUpdater`.
  3. Un usuario que NO ha optado al canal beta nunca ve ni recibe una versión beta — el canal por defecto sigue funcionando exactamente igual que en v5.0.

**Plans**: 1 plan — Wave 1: 16-01-PLAN.md

Plans:
- [x] 16-01-PLAN.md — canal opcional en scripts/release-macos.sh + ExtractorUpdaterDelegate/toggle en la app, checkpoint humano en Xcode verificado (completed 2026-08-21)

**UI hint**: yes

### Phase 17: Playwright/Chromium embebido en el bundle

**Goal**: El `.app` bundle incluye Playwright + Chromium vendorizados, firmados con Developer ID y con hardened runtime en todos los binarios internos, de forma que el fallback JS del motor Python funciona en la app SwiftUI sin que el usuario instale nada por separado — y el bundle sigue siendo notarizable.
**Depends on**: Phase 8 (v3.0, patrón de bundling del runtime Python) y Phase 13 (v5.0, pipeline de firma/notarización) — reutiliza y extiende ambos.
**Requirements**: BUNDLEJS-01, BUNDLEJS-02
**Success Criteria** (what must be TRUE):

  1. El pipeline de bundling descarga y vendoriza Chromium (vía Playwright) dentro de `Contents/Resources/`, universal o con la estrategia de arquitectura que corresponda según lo que ofrezca Playwright.
  2. Todos los binarios internos de Chromium relevantes (helpers de proceso, GPU, renderer, `crashpad_handler`, etc.) quedan firmados con Developer ID + hardened runtime — el `.app` pasa notarización sin errores de "hardened runtime no habilitado" (mismo tipo de problema ya resuelto para el Python embebido en la Fase 13, pero multiplicado a muchos más binarios).
  3. Una extracción de una SPA real desde la app SwiftUI (sin Playwright instalado en el sistema del usuario) activa el fallback JS embebido y devuelve contenido correcto.
  4. El incremento de tamaño del bundle (~300MB+) queda documentado y aceptado explícitamente — no es un límite duro del proyecto pero sí una decisión consciente a registrar.

**Decisión de alcance (post-research, 17-RESEARCH.md)**: se vendoriza Chromium
para una sola arquitectura — la nativa del Mac de build (normalmente arm64),
no arm64+x64. Reduce el tamaño real a ~250-350MB (cerca de la cifra de
referencia) y elimina la dependencia de Rosetta 2 en el Mac de build.
Trade-off aceptado: en la arquitectura no nativa, el fallback JS embebido no
está disponible — degrada a HTML estático (mismo comportamiento que
Playwright no instalado, ya cubierto por `_fetch_via_playwright()` desde la
Fase 11).

**Plans**: 1 plan — Wave 1: 17-01-PLAN.md (research completa en `.planning/phases/17-playwright-chromium-embebido/17-RESEARCH.md`)

**Estado**: Completa — verificado en checkpoint humano (Mac real): `verify-bundle.sh` 19 OK/0 FAIL (BUNDLEJS-01/02), extracción real de una SPA (`quotes.toscrape.com/js/`) desde la app sin Playwright de sistema. Tamaño real medido: 886MB (`.app` Debug local, arm64 nativo) — más alto que la estimación inicial de ~250-350MB, documentado en `RELEASING.md` 3.5. Dos bugs reales encontrados y corregidos durante el checkpoint (no visibles desde el sandbox de planificación): nombre del bundle de Chromium cambiado (Playwright 1.62.0 distribuye "Chrome for Testing", no "Chromium.app" clásico) y un doble-firmado que borraba `allow-jit` de los Helpers Renderer/GPU — ver `17-01-SUMMARY.md`. Notarización real con Chromium embebido (Paso 6 del checkpoint) queda deferida al próximo release real, no ejecutada aquí para no gastar cuota.

**UI hint**: no

### Phase 18: Pulido técnico

**Goal**: Limpiar dos deudas técnicas menores identificadas durante el checkpoint de la Fase 13, sin afectar funcionalidad.
**Depends on**: Phase 13.
**Requirements**: POLISH-01, POLISH-02
**Success Criteria** (what must be TRUE):

  1. `_bump_version` en `scripts/release-macos.sh` solo modifica `CURRENT_PROJECT_VERSION`/`MARKETING_VERSION` de los bloques del target `ExtractorApp` — `ExtractorAppTests` queda intacto.
  2. Investigado el bug de búsqueda de paquetes de Xcode 26.6 (raíz del workaround de paquete local de la Fase 12) — documentado si se identifica la causa, o confirmado que sigue sin resolverse.
  3. Si el bug de Xcode se confirma resuelto (nueva versión de Xcode, fix identificado), Sparkle se migra de paquete local a referencia remota real con versión pinneada.

**Plans**: 1 plan — Wave 1: 18-01 (research + fix, ver `18-RESEARCH.md`/`18-01-SUMMARY.md`)

**Estado**: Completa. POLISH-01 corregido y verificado en el sandbox (transformación de texto pura, `_bump_version` acotada al target `ExtractorApp` vía `awk`, `ExtractorAppTests` intacto). POLISH-02 investigado por búsqueda web sin causa raíz confirmada — documentado como "investigado, sigue sin resolverse"; el usuario decidió explícitamente no invertir tiempo en probarlo en su Mac real ahora, así que el Success Criterion 3 (migrar a paquete remoto) queda sin cumplir por decisión explícita, no por fallo técnico — el paquete local sigue siendo el mecanismo de producción, ya verificado.

**UI hint**: no

### Estado v6.0

**Execution Order:** Phases execute in the order fixed by the user: 14 → 15 → 16 → 17 → 18

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 14. Historial y cola de extracciones | 2/2 | Complete | 2026-08-21 |
| 15. Flag manual `--js`/`--no-js` | 1/1 | Complete | 2026-08-21 |
| 16. Canales beta de Sparkle | 1/1 | Complete | 2026-08-21 |
| 17. Playwright/Chromium embebido en el bundle | 1/1 | Complete | 2026-08-22 |
| 18. Pulido técnico | 1/1 | Complete | 2026-08-23 |

## v7.0 (nombre por definir)

## Overview

Cierra el backlog diferido restante de v6.0. Cuatro temas sin relación
técnica directa entre sí — flags de filtrado CLI (motor Python, patrón
idéntico a la Fase 15), rollouts por fases de Sparkle (pipeline de
release, retoma la Fase 13/16), auto-actualización del runtime Python
embebido (empaquetado + Sparkle, necesita research previa), y
notarización para distribución pública vía web (firma/notarización,
retoma la Fase 13, explícitamente NO Mac App Store). Orden fijado
explícitamente por el usuario: 19 → 20 → 21 → 22, propuesto por Claude de
menor a mayor complejidad/incertidumbre — ninguna fase depende de una
posterior.

**Aviso de alcance**: la Fase 21 (auto-actualización del runtime Python)
necesita research antes de planificar — el runtime vive dentro del `.app`
bundle firmado (Fase 8/13), así que cualquier mecanismo de actualización
tiene que evitar romper la firma de código/notarización del bundle
principal (candidato a investigar: un runtime actualizado fuera del
bundle, en `~/Library/Application Support/`, con `PythonBridge` prefiriéndolo
sobre el bundleado si existe — mismo patrón que ya usa
`resolvedPaths()` para overrides de `UserDefaults` desde v3.0, pero sin
confirmar todavía). La Fase 22 (notarización pública) es explícitamente
**web pública, no Mac App Store** — decisión explícita del usuario, ver
`PROJECT.md` Key Decisions.

### Checklist v7.0

- [x] **Phase 19: Flags de filtrado CLI** - `--no-images`/`--no-links`/`--clipboard` en el motor Python. (completed 2026-08-23)
- [x] **Phase 20: Rollouts por fases de Sparkle** - Publicar actualizaciones progresivamente en vez de a todos los usuarios a la vez. (completed 2026-08-23)
- [x] **Phase 21: Auto-actualización del runtime Python embebido** - Actualizar el runtime sin re-publicar toda la app. (completed 2026-08-24)
- [x] **Phase 22: Notarización para distribución pública** - El `.app` notarizado se puede descargar y ejecutar sin avisos de Gatekeeper, vía web (no App Store). (completed 2026-08-24)

### Phase 19: Flags de filtrado CLI

**Goal**: El usuario puede excluir imágenes/enlaces del contenido extraído y copiar el resultado directamente al portapapeles, sin redirigir manualmente la salida.
**Depends on**: Nothing nuevo — extiende el motor Python (`core.py`/`extractor_url.py`), mismo patrón que la Fase 15 (flags mutuamente compatibles, sin cambiar el comportamiento por defecto).
**Requirements**: CONTENT-01, CONTENT-02, CLIP-01
**Success Criteria** (what must be TRUE):

  1. `--no-images` elimina las imágenes del contenido extraído en todos los formatos soportados (texto/HTML/Markdown, donde aplique).
  2. `--no-links` elimina o aplana los enlaces del contenido extraído (deja el texto visible, sin `href`).
  3. `--clipboard` copia el resultado extraído al portapapeles del sistema — comportamiento CLI-only, sin acoplarse a la GUI SwiftUI.
  4. Los tres flags son independientes y combinables entre sí y con `--js`/`--no-js`/`--batch` existentes, sin romper ningún contrato previo.

**Plans**: 1 plan — Wave 1: 19-01 (ejecutada directamente en conversación, ver `19-01-SUMMARY.md`)

**Estado**: Completa. Verificado en el sandbox (lógica Python pura, sin necesitar Mac): `pytest tests/` 67/67, `pylint` 10.00/10, `mypy` limpio. `--clipboard` verificado con `subprocess.run` mockeado (sin `pbcopy` real disponible en este sandbox Linux) — recomendado no bloqueante: confirmar en un Mac real.

**UI hint**: no

### Phase 20: Rollouts por fases de Sparkle

**Goal**: Las actualizaciones se pueden publicar con un rollout progresivo (no a todos los usuarios a la vez), reutilizando el pipeline de release existente.
**Depends on**: Phase 13 (pipeline de release) y Phase 16 (canales beta) — extiende ambos, no un pipeline paralelo nuevo.
**Requirements**: ROLLOUT-01, ROLLOUT-02
**Success Criteria** (what must be TRUE):

  1. `scripts/release-macos.sh` soporta especificar un `sparkle:phasedRolloutInterval` opcional al publicar un release, sin afectar releases que no lo especifiquen.
  2. El comportamiento y las implicaciones de un rollout por fases (cómo reparte Sparkle el despliegue, cómo monitorizarlo o abortarlo) quedan documentados en `RELEASING.md`.

**Plans**: 1 plan — Wave 1: 20-01 (ejecutada directamente en conversación, ver `20-01-SUMMARY.md`)

**Estado**: Completa. `ROLLOUT_INTERVAL_SECONDS` (variable de entorno, no posicional — no reordena `<version> [canal]`) → `--phased-rollout-interval` en `generate_appcast`, mismo patrón que `--channel` de la Fase 16. Flag confirmado inspeccionando directamente el binario real de `generate_appcast` ya presente en `.build-cache/sparkle-tools/` (sin adivinar). Mecánica de Sparkle documentada en `RELEASING.md` 3.6: 7 grupos hardcodeados, duración total = intervalo × 7, no aplica a comprobación manual ni updates críticos, sin mecanismo oficial de aborto — se documenta la alternativa práctica (editar `appcast.xml` a mano). Verificado en el sandbox: `bash -n`/`shellcheck` limpios, lógica de construcción de argumentos probada de forma aislada (4 combinaciones). No se pudo probar contra un `generate_appcast` real en ejecución (necesita Xcode/notarización, fuera de este sandbox) — recomendado confirmar en el próximo release real con la variable puesta.

**UI hint**: no

### Phase 21: Auto-actualización del runtime Python embebido

**Goal**: El runtime Python embebido (intérprete + dependencias vendorizadas) se puede actualizar sin que el usuario tenga que descargar/reinstalar toda la app de nuevo.
**Depends on**: Phase 8 (bundling original del runtime) y Phase 12/13 (Sparkle/pipeline) — probablemente reutiliza patrones de ambos, pero necesita research previa sobre cómo actualizar binarios sin romper la firma del `.app`.
**Requirements**: PYRUNTIME-01, PYRUNTIME-02
**Success Criteria** (what must be TRUE):

  1. Existe un mecanismo para actualizar el runtime Python (intérprete y/o dependencias) de forma independiente a un release completo de la app, sin romper la firma de código ni la notarización del `.app` bundle.
  2. Si la actualización del runtime falla o queda corrupta, la app degrada de forma segura — rollback al runtime bundleado original, sin dejar la app inutilizable.
  3. El usuario no necesita intervención manual para que la actualización se aplique, o si la requiere, es un único paso claro y documentado.

**Decisión de alcance (post-research, `21-RESEARCH.md`, confirmada por el
usuario)**: v1 actualiza SOLO las dependencias Python puras (`requests`,
`beautifulsoup4`, `markdownify`, `trafilatura`) vía un directorio
antepuesto al `PYTHONPATH` del bundle — nunca el intérprete, `lxml`
(extensión compilada) ni Chromium. Esto evita por completo la
incertidumbre real de Gatekeeper para binarios sueltos descargados en
tiempo de ejecución (los `.py` puros, a diferencia de ejecutables, no
disparan ninguna evaluación de Gatekeeper al ser solo `import`eados por
el intérprete ya confiable y notarizado del bundle).

**Plans**: 1 plan — Wave 1: 21-01 (implementación directa tras la
research, ver `21-RESEARCH.md`)

**Estado**: Completa — verificada en checkpoint humano (Mac real,
2026-08-24). `RuntimeUpdater.swift` descarga/verifica SHA-256/extrae a
Application Support y verifica que el intérprete bundleado puede
importar los 4 paquetes antes de activar el override; `PythonBridge.swift`
lo antepone al `PYTHONPATH` sin tocar el `.app` firmado; nueva sección
"Dependencias del motor" en Preferencias. `scripts/build_runtime_update.py`
ejecutado de verdad tanto en el sandbox como en el Mac real (mismo
resultado: excluye `lxml`/`charset_normalizer`/`regex`). Publicado un
release real (`runtime-2026-08-24`) y aplicado desde la app: **"Dependencias
actualizadas a 2026-08-24" sin ningún aviso de Gatekeeper en ningún
momento** (confirmado explícitamente por el usuario) — confirma el
hallazgo central de la research. Degradación segura (PYRUNTIME-02)
confirmada al borrar el override a mano. Un timeout de red real (no
relacionado con Gatekeeper) reveló un bug de visibilidad del mensaje de
error en la UI, corregido en el mismo checkpoint. Ver
`.planning/phases/21-auto-actualizacion-runtime/21-01-SUMMARY.md`.

**UI hint**: sí — nueva sección en Preferencias ("Dependencias del motor")

### Phase 22: Notarización para distribución pública

**Goal**: Cualquier usuario (no solo el autor) puede descargar el `.app` notarizado desde una ubicación pública y ejecutarlo sin avisos de Gatekeeper — vía web, sin pasar por el Mac App Store.
**Depends on**: Phase 13 (firma/notarización ya establecida) — extiende el pipeline existente a un canal de distribución público, además del canal de auto-actualización entre instalaciones del autor que ya existe.
**Requirements**: PUBLISH-01, PUBLISH-02
**Success Criteria** (what must be TRUE):

  1. El `.app` notarizado se publica en una ubicación pública y descargable (p.ej. GitHub Releases público) sin requerir configuración especial por parte de quien lo descarga.
  2. Un usuario en un Mac limpio (sin la cuenta de desarrollador del autor, sin haber compilado nunca el proyecto) puede descargar y abrir el `.app` sin avisos de Gatekeeper de "developer cannot be verified" ni pasos manuales en Preferencias de Seguridad.
  3. El proceso de publicación pública queda documentado en `RELEASING.md`, diferenciado del proceso de release/appcast existente para las auto-actualizaciones vía Sparkle.

**Decisión de alcance**: distribución vía web pública (GitHub Releases o
similar), explícitamente NO Mac App Store — el App Store implicaría
revisar App Sandbox (hoy OFF), Apple Review y metadatos en App Store
Connect, contradiciendo el "Out of Scope: App Store" ya establecido del
proyecto. Decisión explícita del usuario al definir v7.0.

**Plans**: 1 plan — Wave 1: 22-01 (ejecutada directamente en conversación, ver `22-01-SUMMARY.md`)

**Estado**: Completa. Hallazgo previo: el mecanismo técnico central ya
existía desde la Fase 13 (`.app` notarizado+stapleado, publicado en un
repo GitHub ya público) — esta fase fue sobre todo verificación y
documentación, sin cambios de pipeline. Verificado con `spctl -a -vvv
--type execute` contra el release real `v1.0` (descargado de verdad, no
un build local): `accepted`, `source=Notarized Developer ID` — el
veredicto exacto que vería cualquiera abriendo el `.app` por primera
vez, sin depender del estado de confianza de la máquina. `RELEASING.md`
nueva sección 3.8 (distribución pública, diferenciada del flujo de
Sparkle); `README.md` corregido (ya no dice "no implica distribución
pública a terceros") y actualizado con la tabla de milestones v6.0/v7.0
que estaba parada en v5.0.

**UI hint**: no

### Estado v7.0

**Execution Order:** Phases execute in the order fixed by the user: 19 → 20 → 21 → 22

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 19. Flags de filtrado CLI | 1/1 | Complete | 2026-08-23 |
| 20. Rollouts por fases de Sparkle | 1/1 | Complete | 2026-08-23 |
| 21. Auto-actualización del runtime Python embebido | 1/1 | Complete | 2026-08-24 |
| 22. Notarización para distribución pública | 1/1 | Complete | 2026-08-24 |

## v8.0 (nombre por definir)

## Overview

A diferencia de v6.0/v7.0, esta vez no queda un backlog claro de
funcionalidades — solo un puñado de ítems de mantenimiento/verificación
que quedaron pendientes de v6.0/v7.0 porque requieren un **release real
completo** para comprobarse (medir un build Release de verdad, ejecutar
la notarización real con Chromium embebido, probar `--clipboard` contra
un `pbcopy` real). El usuario decidió explícitamente agruparlos en una
única fase corta en vez de definir un milestone con más alcance.

### Checklist v8.0

- [ ] **Phase 23: Verificación de release real y cierre de deuda técnica** - Ejecutar un release real completo y confirmar los cabos sueltos de v6.0/v7.0 que solo se pueden verificar así.

### Phase 23: Verificación de release real y cierre de deuda técnica

**Goal**: Ejecutar un release real completo de la app y usarlo para cerrar todos los ítems de mantenimiento/verificación pendientes que dependían de eso — sin introducir funcionalidad nueva.
**Depends on**: Phase 13 (pipeline de release), Phase 17 (Chromium embebido), Phase 19 (`--clipboard`), Phase 20 (rollouts), Phase 16 (paquete local de Sparkle) — no extiende ninguno, solo los ejercita de verdad.
**Requirements**: MAINT-01, MAINT-02, MAINT-03, MAINT-04, MAINT-05, MAINT-06
**Success Criteria** (what must be TRUE):

  1. Un release real completo (`scripts/release-macos.sh <version>`) se ejecuta de principio a fin; el tamaño del `.app` Release/archivado (con strip) queda medido y documentado en `RELEASING.md` junto a la cifra de 886MB (Debug) ya existente.
  2. La notarización real con Chromium embebido se confirma exitosa (`notarytool submit --wait` completa sin errores) y `_resign_bundled_chromium()` funciona end-to-end con Developer ID real — tiempo real medido y documentado (Paso 6 diferido del checkpoint de la Fase 17).
  3. `--clipboard` se prueba contra un `pbcopy` real en el Mac (Fase 19 solo lo verificó con `subprocess.run` mockeado, sin `pbcopy` disponible en el sandbox).
  4. Si se usa `ROLLOUT_INTERVAL_SECONDS` en este release, se confirma que `<sparkle:phasedRolloutInterval>` aparece en el `appcast.xml` resultante con el valor esperado (Fase 20) — opcional, solo si el usuario decide probar un rollout real en este release.
  5. Decisión tomada (commitear o no) sobre `scripts/setup-sparkle-local.sh`, pendiente desde el checkpoint de la Fase 16. — **Resuelto**: ya está trackeado desde `5c3d663` (cierre de la Fase 16); la decisión efectiva fue "sí".
  6. Si el bug sospechado de Xcode 27.0 beta GOLD (corrupción de `Info.plist` con una clave `CFBundleIdentifier` conteniendo un log interno de Sparkle) reaparece durante este build, se documenta como confirmado; si no reaparece, se anota que no se repitió.

**Plans**:

- [~] 23-01 (informal, sin PLAN.md) — commit `af48439` (`fix(23-01)`): corrige los rechazos reales de `notarytool` del release v2.1 (ejecutables de Chromium sin hardened runtime — sueltos en `Helpers/` y hermanos `chromium_headless_shell-*`/`ffmpeg-*`), quita `--sequesterRsrc` del `ditto`, pide el log detallado de `notarytool` al rechazar, guard `"${array[@]+...}"` para bash 3.2. Falta re-lanzar el release para verificar SC1–SC6.

**UI hint**: no

### Estado v8.0

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 23. Verificación de release real y cierre de deuda técnica | 0/? (23-01 informal en curso) | In progress | — |
