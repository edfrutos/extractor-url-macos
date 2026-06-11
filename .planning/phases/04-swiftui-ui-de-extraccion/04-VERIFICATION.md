---
phase: 04-swiftui-ui-de-extraccion
verified: 2026-06-11T18:23:00+02:00
status: human_needed
score: 4/4
re_verification: false
human_verification:
  - test: "Lanzar la app y extraer una URL real con Python configurado"
    expected: "ProgressView visible durante la extracción, ScrollView monoespaciado con contenido al terminar, botón re-habilitado"
    why_human: "El flujo end-to-end depende de PythonBridge y de que las rutas en Preferencias estén configuradas; no se puede comprobar sin ejecutar la app"
  - test: "Forzar pythonNotFound dejando pythonPath vacío y pulsar Extraer"
    expected: "Texto rojo 'Error: ...' inline + segunda línea 'Configura la ruta en Preferencias (⌘,)' en .secondary"
    why_human: "El hint de pythonPathError requiere ejecución real del camino de error del bridge"
  - test: "Pulsar Extraer con URL vacía (campo en blanco)"
    expected: "Botón deshabilitado — no es posible pulsarlo; la guard interna de extract() tampoco lo permite vía Return"
    why_human: "Comportamiento de disabled en SwiftUI macOS solo verificable visualmente en runtime"
---

# Phase 4 Verification — SwiftUI UI de Extracción

**Phase Goal:** El usuario puede introducir una URL, elegir tipo de salida y opciones avanzadas, lanzar la extracción y ver el resultado o el error directamente en la ventana principal.
**Verified:** 2026-06-11T18:23:00+02:00
**Status:** human_needed
**Re-verification:** No — verificación inicial

---

## Goal Achievement

El código entregado logra el objetivo de fase con evidencia directa en los archivos Swift.
`ContentView.swift` implementa los cinco estados de ventana (inicial, URL-introducida, extrayendo, éxito, error) mediante un `Group { if/else if }` que consume propiedades `@Published` de `ExtractionViewModel`.
`ExtractionViewModel` conecta la UI con `PythonBridge.run()` via `Task.detached`, aplica el guard D-07 contra llamadas en paralelo, limpia estado antes de extraer (D-09) y distingue el caso `pythonNotFound` para mostrar el hint de Preferencias.
El build compila limpio sin errores ni warnings relevantes.
Los tres checks que no pueden verificarse programáticamente son comportamientos de runtime que requieren confirmación humana.

---

## Success Criteria

| SC | Evidencia en código | Status |
|----|---------------------|--------|
| SC-1: URL + tipo + Extraer + ProgressView indeterminado | `TextField` con `.onSubmit { vm.extract() }`, `Picker` segmentado con tags "text"/"html"/"markdown", `Button { vm.extract() }`, `ProgressView("Extrayendo…")` visible cuando `vm.isExtracting == true` | PASS |
| SC-2: Controles habilitados solo tras completar extracción | Seis `.disabled(vm.isExtracting)` en TextField URL, Picker, Button, ambos TextField de DisclosureGroup y el DisclosureGroup completo. Botón además con `.disabled(vm.isExtracting || vm.urlString.isEmpty)` — cubre "antes deshabilitado, después habilitado" | PASS |
| SC-3: Error explícito inline sin relanzar | `else if let errorMsg = vm.errorMessage { Text("Error: \(errorMsg)").foregroundColor(.red) }` inline en el mismo Group. Sin `.alert` modal — error visible y persistente hasta nueva extracción | PASS |
| SC-4: Selector CSS y timeout configurables desde UI | `DisclosureGroup("Opciones avanzadas")` con `TextField($vm.selectorCSS)` y `TextField(value: $vm.timeout, formatter: NumberFormatter())`. Valores fluyen a `PythonBridge.run(selector:timeout:)` | PASS |

---

## Requirements

| Req | Evidencia | Status |
|-----|-----------|--------|
| APP-01: URL + lanzar extracción | `TextField` + `Button { vm.extract() }` + guard `urlString.isEmpty`. `vm.extract()` llama a `bridge.run(url: url, outputType: type, …)` | PASS |
| APP-02: Indicador de progreso indeterminado | `ProgressView("Extrayendo\u{2026}")` renderizado exclusivamente cuando `vm.isExtracting == true`. Sin valor de progreso — indeterminado | PASS |
| APP-03: Error explícito | `Text("Error: \(errorMsg)").foregroundColor(.red).font(.caption)` inline, más hint condicional `isPythonPathError`. Sin alert modal — experiencia no disruptiva conforme a D-08 | PASS |
| UI-01: Configurar tipo, selector CSS y timeout | Picker segmentado 3 opciones + `DisclosureGroup` con dos campos. Todos los valores se pasan al bridge | PASS |
| UI-03: Controles deshabilitados hasta completar | Ver SC-2. Seis puntos de `.disabled(vm.isExtracting)` cubren todos los controles interactivos. No existen controles de exportación en Phase 4 (son Phase 5) — la cobertura de UI-03 es parcial por diseño: los controles presentes en esta fase se deshabilitan correctamente; los de exportación se implementarán en Phase 5 | PASS (parcial por scope) |

Nota sobre UI-03: La definición en REQUIREMENTS.md menciona "controles de exportación" y `contentReady`. Ninguno de estos elementos pertenece a Phase 4 (asignados a Phase 5 en la tabla de fases del REQUIREMENTS.md). El comportamiento implementado — deshabilitar todos los controles activos durante la extracción — es la cobertura correcta para el scope de esta fase.

---

## Context Decisions

| Decision | Verificado | Status |
|----------|-----------|--------|
| D-01: VStack lineal con secciones de arriba a abajo | `VStack(spacing: 16)` con URL → Picker+Botón → DisclosureGroup → área resultado, separados por `Divider()` | PASS |
| D-02: ScrollView monoespaciado para resultado | `ScrollView { Text(content).font(.system(.caption, design: .monospaced)).padding() }` | PASS |
| D-03: minWidth 500, minHeight 450 | `.frame(minWidth: 500, minHeight: 450)` en línea 96 de ContentView | PASS |
| D-04: @StateObject + ObservableObject, no @Observable | `@StateObject private var vm = ExtractionViewModel()` en ContentView. `final class ExtractionViewModel: ObservableObject`. Sin `@Observable` en ningún archivo Swift | PASS |
| D-05: BridgeTestViewModel eliminado | `grep -r "BridgeTestViewModel" *.swift` → 0 resultados | PASS |
| D-06: 8 @Published (inputs + outputs) | `grep -c "@Published"` → 8: urlString, outputType, selectorCSS, timeout, isExtracting, resultContent, errorMessage, isPythonPathError | PASS |
| D-07: Botón disabled + guard en extract() | `.disabled(vm.isExtracting || vm.urlString.isEmpty)` en Button; `guard !isExtracting, !urlString.isEmpty` en extract() | PASS |
| D-08: Error inline en .red sin alert modal | `Text("Error: \(errorMsg)").foregroundColor(.red)` visible en ventana principal | PASS |
| D-09: Limpiar errorMessage y resultContent antes de extraer | `errorMessage = nil; resultContent = nil; isPythonPathError = false` antes del Task.detached | PASS |
| D-10: ScrollView muestra solo result.content sin metadatos | `Text(content)` directo — sin cabecera de url, charCount ni outputType | PASS |
| D-11: DisclosureGroup con dos campos avanzados | `DisclosureGroup("Opciones avanzadas", isExpanded: $isExpanded)` con TextField CSS + TextField timeout | PASS |
| D-12: Timeout con NumberFormatter, default 15 | `TextField("15", value: $vm.timeout, formatter: NumberFormatter())`. Default `var timeout: Int = 15` en ViewModel | PASS |
| D-13: DisclosureGroup colapsado por defecto | `@State private var isExpanded: Bool = false` | PASS |

---

## Build

```
xcodebuild -project ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj \
           -scheme ExtractorApp -destination 'platform=macOS' \
           -configuration Debug build
```

Resultado: **BUILD SUCCEEDED** — sin errores de compilación.

Desviaciones auto-corregidas por los ejecutores documentadas en SUMMARYs:
- Plan 04-01: `import Combine` añadido — requerido por SDK macOS 26.5 / Xcode 26.5 aunque el plan indicaba que no era necesario.
- Plan 04-02: `.textContentType(.URL)` eliminado — no disponible en `TextField` de macOS (solo en `SecureField`).

---

## Required Artifacts

| Artifact | Estado | Detalles |
|----------|--------|----------|
| `ExtractorApp/.../ViewModels/ExtractionViewModel.swift` | VERIFIED | 71 líneas, 8 @Published, Task.detached, handleError, wired a PythonBridge |
| `ExtractorApp/.../ContentView.swift` | VERIFIED | 103 líneas, @StateObject, 5 estados, DisclosureGroup, Picker segmentado, error inline |
| `ExtractorApp/.../Services/PythonBridge.swift` | VERIFIED (dependencia) | No modificado en Phase 4; firma `run(url:outputType:selector:timeout:)` compatible con llamadas del ViewModel |

---

## Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| ContentView | ExtractionViewModel | `@StateObject private var vm = ExtractionViewModel()` | WIRED |
| ContentView | vm.extract() | `Button { vm.extract() }` + `.onSubmit { vm.extract() }` | WIRED |
| ExtractionViewModel | PythonBridge.run() | `Task.detached { self?.bridge.run(url:outputType:selector:timeout:) }` | WIRED |
| PythonBridge.run() | resultContent | `self?.resultContent = result?.content` en MainActor.run | WIRED |
| resultContent | ScrollView Text | `else if let content = vm.resultContent { ScrollView { Text(content) } }` | WIRED |
| errorMessage | Text rojo | `else if let errorMsg = vm.errorMessage { Text("Error: \(errorMsg)").foregroundColor(.red) }` | WIRED |

---

## Data-Flow Trace (Level 4)

| Artifact | Variable | Fuente | Produce datos reales | Status |
|----------|----------|--------|----------------------|--------|
| ContentView | `vm.resultContent` | `PythonBridge.run()` → `result.content` → `self?.resultContent` | Si — subprocess Python real, no valor hardcoded | FLOWING |
| ContentView | `vm.errorMessage` | `error.localizedDescription` en handleError() | Si — propagado desde ExtractionError tipado | FLOWING |
| ExtractionViewModel | `resultContent` | `result?.content` (ExtractionResult.content: String?) | Si — decodificado de stdout JSON del proceso Python | FLOWING |

---

## Anti-Patterns Found

No se encontraron marcadores de deuda (TODO/FIXME/XXX/TBD) ni valores hardcoded en las rutas de renderizado. El comentario `// UI-SPEC placeholder` en línea 11 de ContentView es documentación inline, no un marcador de deuda.

---

## Deviations from Plan

| # | Desviación | Impacto | Auto-corregida |
|---|-----------|---------|----------------|
| 1 | `import Combine` añadido en ExtractionViewModel (plan decía que no era necesario) | Ninguno para el usuario — requerido por toolchain Xcode 26.5 | Si — commit 5d9a082 |
| 2 | `.textContentType(.URL)` eliminado de TextField URL (no disponible en macOS TextField) | Ninguno — comportamiento semántico cubierto por `.onSubmit` y placeholder | Si — commit cd65ffe |

---

## Human Verification Required

### 1. Flujo end-to-end con extracción real

**Test:** Configurar rutas en Preferencias (⌘,), introducir una URL válida (p.ej. `https://example.com`), seleccionar tipo "Markdown" y pulsar Extraer.
**Expected:** ProgressView visible durante la extracción; al terminar, ScrollView muestra el contenido en monoespaciado; el botón vuelve a estar habilitado.
**Why human:** Requiere subprocess Python real, rutas configuradas y conexión de red. No verificable con grep.

### 2. Manejo del error pythonNotFound con hint de Preferencias

**Test:** Dejar pythonPath vacío en Preferencias (o apuntar a una ruta inexistente), introducir una URL y pulsar Extraer.
**Expected:** Texto rojo "Error: Python no encontrado en …" + segunda línea en gris "Configura la ruta en Preferencias (⌘,)".
**Why human:** El hint condicional `isPythonPathError` solo se activa si ExtractionError.pythonNotFound se propaga correctamente end-to-end.

### 3. Comportamiento del botón Extraer con URL vacía

**Test:** Abrir la app sin introducir nada. Intentar pulsar Extraer.
**Expected:** Botón visualmente deshabilitado (gris), no responde al click ni al Return.
**Why human:** La propiedad `.disabled` en SwiftUI macOS solo es verificable visualmente en runtime.

---

## Gaps Summary

No hay gaps bloqueantes. Todos los must-haves están implementados y cableados con datos reales. Las tres verificaciones pendientes son de comportamiento runtime que requieren confirmación humana antes de marcar la fase como cerrada.

---

_Verified: 2026-06-11T18:23:00+02:00_
_Verifier: Claude (gsd-verifier)_
