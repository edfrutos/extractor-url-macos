# Phase 4: SwiftUI UI de Extracción — Context

**Gathered:** 2026-06-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase reemplaza el andamio de prueba de Fase 3 (`ContentView.swift` con `BridgeTestViewModel`) por la interfaz de extracción real y funcional.

**Entrega concreta:**
- `ContentView.swift` reescrito — campo URL, selector de tipo, DisclosureGroup con opciones avanzadas (CSS selector, timeout), botón Extraer, ProgressView durante extracción, ScrollView con contenido extraído y mensaje de error inline
- `ExtractionViewModel` (nombre a decisión de Claude) — `@StateObject + ObservableObject`, reemplaza `BridgeTestViewModel` por completo
- Integración end-to-end con `PythonBridge.run()` ya existente

**No pertenece a esta fase:** preview WKWebView del contenido (Fase 5), exportación MD/HTML/PDF (Fase 5–6), universal binary (Fase 7).

</domain>

<decisions>
## Implementation Decisions

### Layout de ventana
- **D-01:** VStack lineal — de arriba a abajo: campo URL, fila [selector de tipo + botón Extraer], DisclosureGroup opciones avanzadas, área de resultado/error (ScrollView o ProgressView).
- **D-02:** Área de resultado implementada como `ScrollView { Text(...) }` con fuente monoespaciada. En Fase 5 este área se reemplaza por `WKWebView` (NSViewRepresentable).
- **D-03:** Ventana mínima `minWidth: 500, minHeight: 450`.

### Estado reactivo
- **D-04:** Patrón `@StateObject + ObservableObject` — macOS 13.0 compatible, patrón ya establecido en el proyecto. No usar `@Observable` macro hasta verificar comportamiento en runtime macOS 13 (pendiente STATE.md).
- **D-05:** `ContentView.swift` se reescribe completamente. `BridgeTestViewModel` se elimina — era andamio de Fase 3, no reutilizar.
- **D-06:** El ViewModel expone al menos: `urlString: String`, `outputType: String`, `selectorCSS: String`, `timeout: Int`, `isExtracting: Bool`, `resultContent: String?`, `errorMessage: String?`.
- **D-07:** Botón Extraer con `.disabled(vm.isExtracting || vm.urlString.isEmpty)` — sin llamadas en paralelo.

### Presentación de errores
- **D-08:** Errores con `Text("Error: \(vm.errorMessage!)")` en `.foregroundColor(.red)` inline bajo el área de resultado. Sin `.alert` modal — el usuario puede corregir y reintentar sin dismiss.
- **D-09:** Al pulsar Extraer, el ViewModel limpia `errorMessage = nil` y `resultContent = nil` antes de lanzar la extracción.
- **D-10:** El ScrollView de resultado muestra exclusivamente `result.content` — sin cabecera de metadatos (url, charCount, outputType). Los controles ya muestran la URL y el tipo activo.

### Opciones avanzadas
- **D-11:** `DisclosureGroup("Opciones avanzadas") { ... }` colapsado por defecto. Contiene dos campos: TextField para CSS selector (opcional, vacío = sin selector) y TextField para timeout en segundos.
- **D-12:** Timeout: `TextField("15", value: $vm.timeout, formatter: NumberFormatter())`. Valor por defecto 15. Sin Stepper — más flexible.
- **D-13:** DisclosureGroup arranca `isExpanded = false`. El estado de expansión no se persiste.

### Claude's Discretion
- Nombre exacto del ViewModel (`ExtractionViewModel` vs `ExtractorViewModel` vs otro — mantener coherencia con `ExtractionResult`, `ExtractionError`).
- Estilo del selector de tipo (`.pickerStyle(.segmented)` recomendado por legibilidad, pero Claude elige según el espacio disponible en el layout).
- Separadores visuales (Divider) entre secciones del VStack.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Fase 3 — Bridge y preferencias (dependencia directa)
- `.planning/phases/03-python-bridge-y-preferencias/03-CONTEXT.md` — Decisiones de arquitectura del bridge: Task.detached, MainActor, env PATH, error types
- `ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift` — API a llamar: `run(url:outputType:selector:timeout:)` async throws → ExtractionResult
- `ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift` — Andamio a reemplazar (ver patrón @StateObject + Task.detached ya en uso)
- `ExtractorApp/ExtractorApp/ExtractorApp/Views/SettingsView.swift` — Referencia de estilo de formularios SwiftUI en el proyecto

### Modelos Swift
- `ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionResult.swift` — Modelo Codable decodificado del bridge
- `ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionError.swift` — Enum de errores tipados del bridge

### Requisitos y roadmap
- `.planning/REQUIREMENTS.md` — Requisitos APP-01, APP-02, APP-03, UI-01, UI-03
- `.planning/ROADMAP.md` — Phase 4 goal y success criteria

### Investigación previa (pitfalls)
- `.planning/research/PITFALLS.md` — 16 pitfalls con código de prevención (deadlock pipes, waitUntilExit en @MainActor, PATH env)
- `.planning/research/SUMMARY.md` — Síntesis de stack y arquitectura

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `PythonBridge.run(url:outputType:selector:timeout:)` — listo, no modificar. Acepta exactamente los parámetros que expone la UI (outputType: "text"/"html"/"markdown", selector: String?, timeout: Int).
- `ExtractionResult.content` — String? con el contenido a mostrar. `ExtractionResult.isSuccess` — Bool para distinguir éxito de error.
- `ExtractionError` — 5 casos tipados; usar `error.localizedDescription` o un `switch` para mensajes específicos al usuario.
- `SettingsView.swift` — patrón `@AppStorage` + `Form { Section { ... } }` como referencia de estilo.

### Established Patterns
- `@StateObject private var vm = ViewModel()` + `@Published` — patrón en `ContentView.swift` (BridgeTestViewModel).
- `Task.detached(priority: .userInitiated) { ... }` + `await MainActor.run { ... }` — patrón del bridge para llamadas async sin bloquear UI.
- `.disabled(condition)` en Button — patrón ya en `ContentView.swift`.
- `ProgressView("Extrayendo…")` — componente ya en ContentView, reutilizar.

### Integration Points
- El nuevo ViewModel llama a `PythonBridge().run(...)` en un `Task.detached`. Las rutas Python/script se leen desde `@AppStorage` dentro de `PythonBridge` — el ViewModel no necesita acceder a ellas directamente.
- `ExtractorAppApp.swift` ya tiene la `Settings { SettingsView() }` scene — sin cambios en este archivo.

</code_context>

<specifics>
## Specific Ideas

- El botón Extraer puede llevar un ícono SF Symbols (`arrow.down.circle` o `arrow.clockwise`) para reforzar la acción visualmente.
- El campo URL debería tener `.textContentType(.URL)` y quizás `.onSubmit { vm.extract() }` para permitir extraer pulsando Return.
- El mensaje de error puede incluir un breve hint cuando es `pythonNotFound` — ej. "Configura la ruta en Preferencias (⌘,)".

</specifics>

<deferred>
## Deferred Ideas

- Preview WKWebView del contenido renderizado — Fase 5 (UI-02, EXPORT-01).
- Botón de cancelación de extracción en curso — requiere `process.terminate()` en PythonBridge, diferido a mejoras post-v2.0.
- Historial de URLs extraídas — nueva funcionalidad, fuera del scope v2.0.
- `@Observable` macro — diferido hasta verificar comportamiento en runtime macOS 13 (ver STATE.md).

</deferred>

---

*Phase: 04-swiftui-ui-de-extraccion*
*Context gathered: 2026-06-11*
