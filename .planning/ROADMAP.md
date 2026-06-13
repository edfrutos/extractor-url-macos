# Roadmap: extractor-url

## v2.0 SwiftUI Native App

## Overview

Construir una app macOS nativa en SwiftUI que lanza el extractor Python existente vía subprocess y exporta el resultado íntegro a Markdown, HTML autocontenido y PDF. El motor Python no se modifica: Swift gestiona toda la UI y el sistema de archivos; Python sigue siendo el motor de extracción sin cambios.

El bridge subprocess es la dependencia bloqueante de todo el milestone. Las fases siguen un orden estricto en cadena.

## Phases

- [ ] **Phase 3: Python Bridge y Preferencias** - Cimentar el bridge subprocess async y las preferencias de ruta antes de tocar UI.
- [x] **Phase 4: SwiftUI UI de Extracción** - Primera interfaz funcional end-to-end: campo URL, controles, progreso y errores. (completed 2026-06-11)
- [x] **Phase 5: Preview y Export MD/HTML** - Preview WKWebView del contenido extraído y exportación a Markdown y HTML autocontenido. (completed 2026-06-12)
- [x] **Phase 6: Export PDF** - Exportación PDF vectorial vía WKWebView con control de timing de renderizado. (completed 2026-06-12)
- [ ] **Phase 7: Universal Binary y Configuración de Build** - Verificación fat binary, firma, notarización y empaquetado .dmg.

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

**Plans**: 3 planes

Plans:

- [ ] 03-01-PLAN.md — Proyecto Xcode + entitlements + modelos ExtractionResult y ExtractionError
- [ ] 03-02-PLAN.md — PythonBridge (subprocess async paralelo) + ExtractorApp entry point
- [ ] 03-03-PLAN.md — SettingsView con validación reactiva + verificación end-to-end del bridge

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

**Plans**: 2 planes

Plans:

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

**Plans**: 2 planes
Plans:
**Wave 1**

- [x] 05-01-PLAN.md — ExtractionViewModel: contentReady/exportFormat, htmlForPreview, generateHTML autocontenido + target XCTest y tests unitarios

**Wave 2** *(blocked on Wave 1 completion)*

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

**Plans**: 3 planes

Plans:

**Wave 1**

- [x] 06-01-PLAN.md — Contrato JSON Python: campo `title` (`_extract_title` + bloque JSON + tests)
- [x] 06-02-PLAN.md — Contrato Swift: `ExtractionResult.title`, `pageTitle`, `suggestedFilename(title:)` unificado + tests

**Wave 2** *(blocked on Wave 1: depende de 06-02)*

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

**Plans**: 2 planes

Plans:

**Wave 1**

- [x] 07-01-PLAN.md — Build settings: MACOSX_DEPLOYMENT_TARGET = 13.0, ARCHS = arm64 x86_64 + entitlements hardened-runtime

**Wave 2** *(blocked on Wave 1: depende de compilación exitosa)*

- [x] 07-02-PLAN.md — Validación binaria: lipo -archs, codesign verification, ejecución y checkpoint humano (completed 2026-06-13)

**UI hint**: no

## Progress

**Execution Order:**
Phases execute in numeric order: 3 → 4 → 5 → 6 → 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 3. Python Bridge y Preferencias | 0/3 | In progress | - |
| 4. SwiftUI UI de Extracción | 2/2 | Complete   | 2026-06-11 |
| 5. Preview y Export MD/HTML | 2/2 | Complete   | 2026-06-12 |
| 6. Export PDF | 3/3 | Complete    | 2026-06-13 |
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
**Plans**:

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
**Plans**:

- [x] Corregir contratos de error y añadir cobertura CLI
