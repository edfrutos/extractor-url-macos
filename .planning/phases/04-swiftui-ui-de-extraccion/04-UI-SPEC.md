---
phase: 4
slug: swiftui-ui-de-extraccion
status: draft
shadcn_initialized: false
preset: macOS HIG
created: 2026-06-11
platform: macOS SwiftUI
---

# Phase 4 — UI Design Contract: SwiftUI UI de Extracción

> Contrato visual e interactivo para la fase de extracción SwiftUI nativa.
> Generado por gsd-ui-researcher. Verificado por gsd-ui-checker.
> NOTA: Este spec adapta la plantilla estándar a SwiftUI/macOS. No aplican
> shadcn, radix, tokens hex ni px. Todas las unidades son pt (puntos SwiftUI).

---

## Design System

| Propiedad          | Valor                                           |
|--------------------|-------------------------------------------------|
| Tool               | none — SwiftUI nativo                           |
| Preset             | macOS Human Interface Guidelines (HIG)          |
| Component library  | SwiftUI built-in (no third-party)               |
| Icon library       | SF Symbols 4 (sistema, sin dependencias extra)  |
| Font               | SF Pro — system font vía `.font(.body)` etc.    |
| Deployment target  | macOS 13.0+                                     |

Fuente: CONTEXT.md decisions + arquitectura declarada en STATE.md y RESEARCH.md.

---

## Spacing Scale

Escala base 4pt (macOS HIG 4pt grid). Equivalencias SwiftUI `spacing:` / `.padding()`.

| Token | Valor (pt) | SwiftUI equivalente            | Uso                                     |
|-------|------------|--------------------------------|-----------------------------------------|
| xs    | 4pt        | `.padding(4)` / `spacing: 4`  | Separación ícono-etiqueta, gaps inline  |
| sm    | 8pt        | `.padding(8)` / `spacing: 8`  | Padding interno de campos TextField     |
| md    | 16pt       | `.padding()` / `spacing: 16`  | Espaciado estándar entre elementos VStack |
| lg    | 24pt       | `.padding(24)` / `spacing: 24`| Padding exterior de la ventana          |
| xl    | 32pt       | `.padding(32)` / `spacing: 32`| No usado en Phase 4                     |

VStack principal: `spacing: 16` (md) — extraído del scaffold `ContentView.swift` línea 7.
Padding exterior de la ventana: `.padding()` equivalente a 16pt por defecto SwiftUI.
DisclosureGroup interno: `spacing: 8` (sm) entre los dos campos avanzados.

Excepciones:
- Touch targets de botón: SwiftUI aplica padding automático en `Button` estilo `.bordered` / `.borderedProminent` — no necesita override manual.
- `minWidth: 500, minHeight: 450` — constraint de ventana, no spacing (D-03).

---

## Typography

Tamaños semánticos macOS via modificadores SwiftUI `.font(...)`. No se declaran
tamaños px/pt absolutos salvo excepciones de monoespaciado.

| Rol          | Tamaño semántico | Peso         | SwiftUI modifier                              | Uso en Phase 4                              |
|--------------|------------------|--------------|-----------------------------------------------|---------------------------------------------|
| Title        | ~20pt (title2)   | Semibold 600 | `.font(.title2)`                              | NO usado en Phase 4 — andamio eliminado     |
| Headline     | ~13pt (headline) | Semibold 600 | `.font(.headline)`                            | NO usado en Phase 4                         |
| Body         | ~13pt (body)     | Regular 400  | `.font(.body)`                                | Texto del campo URL, etiquetas de controles |
| Label/Caption| ~11pt (caption)  | Regular 400  | `.font(.caption)` / `.font(.caption2)`        | Mensajes de error inline, hint de preferencias |
| Monospaced   | ~11pt (caption)  | Regular 400  | `.font(.system(.caption, design: .monospaced))`| ScrollView de resultado extraído (D-02)     |

Pesos declarados: exactamente 2 — Regular (400) para cuerpo/etiquetas y Semibold (600) para ningún elemento en Phase 4 (no hay headings propios — la ventana usa chrome nativo).

Line heights: gestionadas por SF Pro automáticamente. No se declaran ratios manuales en SwiftUI nativo.

Nota: El modificador `.font(.system(.caption, design: .monospaced))` viene del scaffold
`ContentView.swift` línea 31 — patrón establecido en el proyecto, se mantiene.

---

## Color

Solo colores semánticos del sistema. Sin hex hardcodeados salvo `.red` para errores
(convención establecida en el proyecto — `SettingsView.swift` línea 39 y CONTEXT.md D-08).

| Rol              | Color semántico SwiftUI                         | Uso                                                    |
|------------------|-------------------------------------------------|--------------------------------------------------------|
| Dominant (60%)   | `.background` / `Color(NSColor.windowBackgroundColor)` | Fondo de ventana — gestionado por macOS |
| Secondary (30%)  | `Color(NSColor.controlBackgroundColor)`         | ScrollView resultado, DisclosureGroup interior          |
| Accent (10%)     | `.accentColor` (azul del sistema por defecto)   | SOLO el botón primario "Extraer" (`.borderedProminent`) |
| Error/Destructive| `.red`                                          | SOLO `Text` de error inline bajo área de resultado (D-08) |
| Text primary     | `.primary`                                      | Contenido del ScrollView, etiquetas                    |
| Text secondary   | `.secondary`                                    | Placeholder, captions de ayuda                         |
| Validation OK    | `.green`                                        | Ícono validación (patrón SettingsView — coherencia)     |

Accent reservado exclusivamente para: botón "Extraer" con estilo `.borderedProminent`.
Ningún otro elemento usa accentColor. Los campos, Picker y DisclosureGroup usan estilos
sin tinte de acento.

---

## Copywriting Contract

Texto exacto para cada elemento de la UI. El ejecutor NO debe parafrasear ni inventar
variaciones — usar literalmente los strings que siguen.

| Elemento                          | Texto exacto                                                                              |
|-----------------------------------|-------------------------------------------------------------------------------------------|
| Placeholder campo URL             | `"https://example.com"`                                                                   |
| Label campo URL                   | Sin label visible — el placeholder lo describe. Usar `.textContentType(.URL)`             |
| Botón Extraer                     | `"Extraer"` con ícono SF Symbol `arrow.down.circle` a la izquierda del label             |
| Label ProgressView durante extracción | `"Extrayendo…"` (con puntos suspensivos tipográficos U+2026, no tres puntos ASCII) |
| Estado vacío inicial (sin contenido, sin error) | Sin texto visible — área de resultado vacía (no mostrar placeholder de resultado) |
| Picker — opción texto             | `"Texto"`                                                                                 |
| Picker — opción HTML              | `"HTML"`                                                                                  |
| Picker — opción Markdown          | `"Markdown"`                                                                              |
| DisclosureGroup título            | `"Opciones avanzadas"`                                                                    |
| Label campo CSS selector          | `"Selector CSS"` (como label del TextField, no como placeholder)                         |
| Placeholder campo CSS selector    | `"article, .content…"` — indica que es opcional mediante puntos suspensivos              |
| Label campo timeout               | `"Tiempo límite (segundos)"`                                                              |
| Placeholder campo timeout         | `"15"` — valor por defecto numérico                                                      |
| Error genérico inline             | `"Error: \(vm.errorMessage!)"` en `.foregroundColor(.red)` (D-08)                       |
| Error caso pythonNotFound (hint)  | Añadir línea adicional: `"Configura la ruta en Preferencias (⌘,)"` en `.font(.caption).foregroundColor(.secondary)` |
| Accessibility label botón Extraer | `"Extraer contenido de la URL"` (para VoiceOver)                                        |

Nota sobre el hint de `pythonNotFound`: se detecta con `if vm.errorMessage?.contains("Python no encontrado") == true` o con un `Bool` adicional `vm.isPythonPathError` en el ViewModel — el ejecutor elige la estrategia más limpia.

---

## SwiftUI Component Contract

No aplica registro de terceros. Lista de componentes SwiftUI nativos autorizados para
esta fase y sus modificadores prescritos.

| Componente SwiftUI       | Modificadores prescritos                                                                 | Notas                                         |
|--------------------------|------------------------------------------------------------------------------------------|-----------------------------------------------|
| `VStack`                 | `spacing: 16`                                                                            | Contenedor principal de ContentView           |
| `TextField` (URL)        | `.textContentType(.URL)`, `.onSubmit { vm.extract() }`, `.disabled(vm.isExtracting)`   | Return key dispara extracción                 |
| `Picker`                 | `.pickerStyle(.segmented)`, `.disabled(vm.isExtracting)`                                | 3 opciones en 500pt — segmented es adecuado   |
| `Button` (Extraer)       | `.buttonStyle(.borderedProminent)`, `.disabled(vm.isExtracting \|\| vm.urlString.isEmpty)`, `.accessibilityLabel(...)` | D-07 |
| `ProgressView`           | `ProgressView("Extrayendo…")` — indeterminado, sin valor                               | Visible solo cuando `vm.isExtracting == true` |
| `ScrollView`             | `ScrollView { Text(...).font(.system(.caption, design: .monospaced)).padding() }.frame(maxHeight: .infinity)` | D-02 — área de resultado |
| `Text` (error)           | `.foregroundColor(.red)`, `.font(.caption)`                                             | D-08 — inline, no alert modal                 |
| `DisclosureGroup`        | `isExpanded: $isExpanded` con `@State private var isExpanded = false`                   | D-11, D-13 — colapsado por defecto            |
| `TextField` (CSS)        | `.textContentType(.none)`, sin keyboard type especial                                   | Campo opcional dentro de DisclosureGroup      |
| `TextField` (timeout)    | `value: $vm.timeout, formatter: NumberFormatter()`                                      | D-12 — sin Stepper                            |
| `Divider`                | Sin modificadores                                                                        | Separador visual entre secciones del VStack   |
| `HStack`                 | `spacing: 8`                                                                            | Fila [Picker + Botón Extraer]                 |

---

## SwiftUI Interaction Contract

### Estados de la ventana

| Estado                              | Comportamiento de UI                                                                                     |
|-------------------------------------|----------------------------------------------------------------------------------------------------------|
| Inicial (URL vacía)                 | Botón deshabilitado. Área de resultado vacía. Sin error visible. DisclosureGroup colapsado.              |
| URL introducida, sin extraer        | Botón habilitado. Picker activo. DisclosureGroup expandible. Sin indicador de progreso.                  |
| Extrayendo (`isExtracting = true`)  | `ProgressView("Extrayendo…")` visible. Botón deshabilitado. Picker deshabilitado. TextField URL deshabilitado. `resultContent` y `errorMessage` = nil (D-09). |
| Extracción exitosa                  | ProgressView oculto. ScrollView muestra `result.content` en monoespaciado. Sin texto de error. Botón re-habilitado. |
| Error de extracción                 | ProgressView oculto. ScrollView vacío (o con contenido previo limpiado). `Text("Error: ...")` en rojo visible bajo el área de resultado. Botón re-habilitado. |

### Constraints de ventana

```swift
.frame(minWidth: 500, minHeight: 450)
```

Fuente: D-03.

### Picker style — justificación

`.pickerStyle(.segmented)` con 3 opciones ("Texto", "HTML", "Markdown") en ancho mínimo
500pt es viable: cada opción ocupa ~80pt, total ~240pt, dejando espacio para el botón
Extraer en la misma HStack. Si el botón ocupa ~90pt, la HStack total suma ~330pt, dentro
del mínimo de 500pt con padding.

### TextField return key

```swift
TextField("https://example.com", text: $vm.urlString)
    .onSubmit { vm.extract() }
```

`.onSubmit` se dispara con Return/Enter en macOS. Equivalente funcional al botón Extraer.
La misma guard de `vm.urlString.isEmpty` debe aplicarse dentro de `vm.extract()`.

### DisclosureGroup estado inicial

```swift
@State private var isExpanded = false
DisclosureGroup("Opciones avanzadas", isExpanded: $isExpanded) { ... }
```

Estado de expansión NO persistido (`@AppStorage` no usado aquí) — D-13.

### Nombre del ViewModel

`ExtractionViewModel` — coherente con `ExtractionResult` y `ExtractionError` ya en el
proyecto. Evita `Extractor` (ambiguo con el módulo Python) y `BridgeTest` (andamio
eliminado). Fuente: Claude's Discretion en CONTEXT.md.

### Ícono del botón Extraer

SF Symbol: `arrow.down.circle` — semántica "descargar/obtener contenido". Preferido sobre
`arrow.clockwise` (que sugiere "reintentar/refrescar"). Fuente: CONTEXT.md `<specifics>`.

```swift
Label("Extraer", systemImage: "arrow.down.circle")
```

### Separadores Divider

Se añade `Divider()` entre:
1. Campo URL y fila [Picker + Botón]
2. Fila [Picker + Botón] y DisclosureGroup
3. DisclosureGroup y área de resultado/error

Fuente: Claude's Discretion en CONTEXT.md.

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: N/A — SwiftUI nativo, sin registros de terceros

**Approval:** pending

---

## Pre-population Sources

| Fuente             | Decisiones incorporadas                                                                 |
|--------------------|-----------------------------------------------------------------------------------------|
| CONTEXT.md D-01→D-13 | Layout VStack, ScrollView monoespaciado, minWidth/minHeight, @StateObject, reescritura ContentView, campos ViewModel, guard botón, error inline rojo, limpieza en extract(), contenido sin metadatos, DisclosureGroup, TextField timeout sin Stepper, estado colapsado |
| CONTEXT.md `<specifics>` | .textContentType(.URL), .onSubmit, hint pythonNotFound, ícono arrow.down.circle |
| ContentView.swift  | spacing:16, .monospaced caption, ProgressView("Extrayendo…"), .disabled(vm.isRunning), patrón Task.detached + MainActor |
| SettingsView.swift | Patrón Form+Section, .foregroundColor(.red) para errores, .foregroundColor(.secondary) para captions |
| ExtractionError.swift | Strings exactos de errorDescription para copywriting de errores                   |
| ExtractionResult.swift | Campos disponibles: content, isSuccess, errorMessage — confirmado qué exponer en UI |
| REQUIREMENTS.md    | APP-01 (URL+extracción), APP-02 (ProgressView), APP-03 (error explícito), UI-01 (tipo+selector+timeout), UI-03 (controles deshabilitados hasta completar) |
| Claude's Discretion | ExtractionViewModel como nombre, .segmented picker, Divider entre secciones         |
