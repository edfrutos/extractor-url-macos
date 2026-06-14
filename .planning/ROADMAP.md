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

- [ ] **Phase 8: Bundle Python Runtime** - Empaquetar el runtime Python universal y las dependencias vendorizadas dentro del .app.
- [ ] **Phase 9: Bridge Auto-detección de Rutas** - PythonBridge localiza el runtime y el script del bundle vía `Bundle.main.resourcePath` sin configuración del usuario.
- [ ] **Phase 10: UX Zero-Config** - SettingsView refleja el modo bundled e informa al usuario; primera apertura extrae sin configuración previa.

### Phase 8: Bundle Python Runtime

**Goal**: El `.app` bundle contiene un intérprete Python universal (arm64+x86_64), los scripts del motor de extracción y todas las dependencias Python vendorizadas, de forma que la app puede ejecutar extracciones en cualquier Mac sin que el usuario instale nada.
**Depends on**: Phase 7
**Requirements**: BUNDLE-01, BUNDLE-02, BUNDLE-03
**Success Criteria** (what must be TRUE):

  1. El directorio `Contents/Resources/python/bin/python3` existe en el bundle, es ejecutable y `lipo -archs` devuelve `x86_64 arm64`.
  2. Los archivos `extractor_url.py` y `core.py` están presentes en `Contents/Resources/scripts/` y son legibles vía `Bundle.main.resourcePath`.
  3. Las dependencias `requests`, `beautifulsoup4`, `lxml`, `markdownify` y `trafilatura` están instaladas en `Contents/Resources/python/lib/` (vendorizadas con `pip install --target`) y son importables desde el intérprete bundleado sin acceso a red ni a `pip` del sistema.
  4. Un script de shell de validación ejecutado sobre el `.app` de Release invoca `Contents/Resources/python/bin/python3 Contents/Resources/scripts/extractor_url.py --json https://example.com` y devuelve JSON válido.

**Plans**: TBD
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

**Plans**: TBD
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

**Plans**: TBD
**UI hint**: yes

### Estado v3.0

**Execution Order:** Phases execute in numeric order: 8 → 9 → 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. Bundle Python Runtime | 0/TBD | Not started | - |
| 9. Bridge Auto-detección de Rutas | 0/TBD | Not started | - |
| 10. UX Zero-Config | 0/TBD | Not started | - |
