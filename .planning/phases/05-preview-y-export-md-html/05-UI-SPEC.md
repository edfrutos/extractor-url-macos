---
phase: 5
slug: preview-y-export-md-html
status: approved
shadcn_initialized: false
preset: macOS HIG
created: 2026-06-11
platform: macOS SwiftUI
---

# Phase 5 — UI Design Contract: Preview y Export MD/HTML

> Contrato visual e interactivo para la fase de preview WKWebView y exportación MD/HTML.
> Generado por gsd-ui-researcher. Verificado por gsd-ui-checker.
> NOTA: Este spec adapta la plantilla estándar a SwiftUI/macOS. No aplican
> shadcn, radix, tokens hex ni px. Todas las unidades son pt (puntos SwiftUI).
> Este spec EXTIENDE Phase 4 — hereda todos los valores sin excepción y documenta
> exclusivamente los elementos nuevos o modificados.

---

## Design System

| Propiedad          | Valor                                                        |
|--------------------|--------------------------------------------------------------|
| Tool               | none — SwiftUI nativo                                        |
| Preset             | macOS Human Interface Guidelines (HIG)                       |
| Component library  | SwiftUI built-in + WebKit.WKWebView (NSViewRepresentable)    |
| Icon library       | SF Symbols 4 (sistema, sin dependencias extra)               |
| Font (SwiftUI)     | SF Pro — system font vía `.font(.body)` etc.                 |
| Font (WKWebView)   | `-apple-system, BlinkMacSystemFont, sans-serif` (CSS inline) |
| Deployment target  | macOS 13.0+                                                  |

HEREDADO de 04-UI-SPEC.md sin cambios. Adición Phase 5: WebKit como único framework
externo autorizado. Sin componentes de terceros.

---

## Spacing Scale

Escala base 4pt — IDÉNTICA a Phase 4. Sin excepciones nuevas.

| Token | Valor (pt) | SwiftUI equivalente             | Uso Phase 4+5                                       |
|-------|------------|---------------------------------|-----------------------------------------------------|
| xs    | 4pt        | `.padding(4)` / `spacing: 4`   | Separación ícono-etiqueta, gaps inline              |
| sm    | 8pt        | `.padding(8)` / `spacing: 8`   | HStack fila export (entre Picker y botón), DisclosureGroup interno |
| md    | 16pt       | `.padding()` / `spacing: 16`   | Espaciado estándar entre elementos VStack           |
| lg    | 24pt       | `.padding(24)` / `spacing: 24` | Padding exterior de la ventana                      |
| xl    | 32pt       | `.padding(32)` / `spacing: 32` | No usado en Phase 4 ni Phase 5                      |

### Notas específicas Phase 5

- **WebPreviewView padding:** El WKWebView ocupa todo el espacio disponible con
  `.frame(maxWidth: .infinity, maxHeight: .infinity)`. El padding visual del contenido
  lo gestiona el CSS inline del template HTML (`padding: 1em`), no modificadores SwiftUI.
- **Altura mínima del área preview:** No se declara `minHeight` fijo en SwiftUI.
  El VStack con `Spacer()` o `.frame(maxHeight: .infinity)` en `WebPreviewView` garantiza
  que ocupe todo el espacio entre la fila de extracción y la fila de exportación.
  La ventana ya tiene `minHeight: 450` (D-03 de Phase 4); con los controles superiores
  (~120pt) y la fila export (~36pt), el WebView dispone de al menos ~294pt de altura útil.
- **HStack fila export:** `spacing: 8` (sm) — igual que la fila de extracción (Picker+Botón).

---

## Typography

HEREDADA íntegramente de Phase 4. Sin roles nuevos en la capa SwiftUI.

| Rol          | Tamaño semántico  | Peso         | SwiftUI modifier                               | Uso                                           |
|--------------|-------------------|--------------|------------------------------------------------|-----------------------------------------------|
| Body         | ~13pt (body)      | Regular 400  | `.font(.body)`                                 | Etiquetas de controles, label del Picker export |
| Label/Caption| ~11pt (caption)   | Regular 400  | `.font(.caption)`                              | Mensajes de estado, hint accesibilidad        |
| Monospaced   | ~11pt (caption)   | Regular 400  | `.font(.system(.caption, design: .monospaced))`| NO usado en Phase 5 — reemplazado por WKWebView |

### Tipografía dentro del WKWebView (CSS — no SwiftUI)

El HTML template de `generateHTML(content:outputType:)` controla la tipografía del
contenido renderizado. SwiftUI NO aplica modificadores `.font()` al interior del WebView.

| Elemento HTML | Valor CSS                                         |
|---------------|---------------------------------------------------|
| body          | `font-family: -apple-system, BlinkMacSystemFont, sans-serif` |
| body          | `font-size: 16px; line-height: 1.6`               |
| pre / code    | `font-family: ui-monospace, monospace; font-size: 14px` |
| max-width     | `max-width: 800px; margin: 0 auto; padding: 1em`  |

Estos valores son contratos del template HTML, no del design system SwiftUI.
El ejecutor los implementa en `generateHTML()` en el ViewModel.

---

## Color

HEREDADO de Phase 4. Los nuevos elementos de Phase 5 usan los mismos colores semánticos.

| Rol              | Color semántico SwiftUI                          | Uso en Phase 5                                          |
|------------------|--------------------------------------------------|---------------------------------------------------------|
| Dominant (60%)   | `.background` / `Color(NSColor.windowBackgroundColor)` | Fondo de ventana — gestionado por macOS          |
| Secondary (30%)  | `Color(NSColor.controlBackgroundColor)`          | NO aplicado directamente al WKWebView — el WebView usa su propio fondo CSS |
| Accent (10%)     | `.accentColor` (azul del sistema)                | SOLO botón "Exportar" (`.borderedProminent`) — idéntico al botón "Extraer" |
| Error/Destructive| `.red`                                           | Sin cambios respecto a Phase 4 — errores inline          |
| Text primary     | `.primary`                                       | Label del Picker de formato export                      |
| Text secondary   | `.secondary`                                     | Estado PDF deshabilitado — color gris automático del sistema |

### Dark mode en WKWebView

El template CSS incluye:

```css
@media (prefers-color-scheme: dark) {
  body { background: #1e1e1e; color: #d4d4d4; }
  a { color: #6ab0f5; }
}
```

El WKWebView respeta automáticamente el esquema de color del sistema. SwiftUI no
necesita ningún modificador adicional para esto.

### PDF deshabilitado — color

La opción "PDF" en el Picker usa `.disabled(true)`. SwiftUI aplica automáticamente
`.secondary` / gris del sistema al elemento deshabilitado. No se necesita color
ni modificador explícito.

---

## Copywriting Contract

Strings exactos para todos los elementos de Phase 5. El ejecutor NO debe parafrasear.

| Elemento                                       | Texto exacto                                                                               |
|------------------------------------------------|--------------------------------------------------------------------------------------------|
| Picker formato — opción Markdown               | `"Markdown"`                                                                               |
| Picker formato — opción HTML                   | `"HTML"`                                                                                   |
| Picker formato — opción PDF (deshabilitada)    | `"PDF"` — sin sufijo ni tooltip; el estado deshabilitado lo comunica visualmente           |
| Label del Picker de formato                    | Sin label visible — el Picker segmented se describe por sus opciones. Usar `.labelsHidden()` |
| Botón Exportar — label                         | `"Exportar"` con ícono SF Symbol `square.and.arrow.up` a la izquierda del label           |
| Accessibility label botón Exportar             | `"Exportar contenido"` (para VoiceOver)                                                    |
| Estado WKWebView cargando (contentReady=false) | Sin texto visible — área de preview vacía o mostrando fondo en blanco/gris del sistema. No mostrar ProgressView adicional para la carga del WebView. |
| Confirmación export exitoso                    | Sin alerta ni banner — el NSSavePanel cierra indicando éxito implícitamente. No añadir Toast ni Sheet de confirmación en Phase 5. |
| NSSavePanel — nombre sugerido (MD)             | Primeros 50 caracteres de `vm.resultContent` sanitizados (eliminar `[^a-zA-Z0-9_-]`, trim) + `".md"` |
| NSSavePanel — nombre sugerido (HTML)           | Misma heurística que MD + `".html"`                                                        |
| NSSavePanel — extensión permitida (MD)         | `allowedContentTypes: [UTType(filenameExtension: "md") ?? .plainText]`                    |
| NSSavePanel — extensión permitida (HTML)       | `allowedContentTypes: [.html]`                                                             |
| ProgressView (durante extracción) — label      | `"Extrayendo…"` (U+2026 — heredado de Phase 4, sin cambio)                                |

### Nota sobre UTType para Markdown

`UTType(filenameExtension: "md")` puede devolver `nil` en macOS 13 (pendiente verificación
empírica — STATE.md Pending Todos). El fallback a `.plainText` es el comportamiento seguro.
El ejecutor debe verificar esto antes de implementar.

---

## SwiftUI Component Contract

Componentes nuevos o modificados en Phase 5. Los componentes de Phase 4 no se repiten
aquí — ver 04-UI-SPEC.md sección "SwiftUI Component Contract".

| Componente SwiftUI               | Modificadores prescritos                                                                                          | Notas                                                       |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| `WebPreviewView` (NSViewRepresentable) | `.frame(maxWidth: .infinity, maxHeight: .infinity)` en el punto de uso en ContentView            | Ocupa todo el espacio disponible entre controles superiores y fila export |
| `Picker` (formato export)        | `.pickerStyle(.segmented)`, `.labelsHidden()`, `.disabled(!vm.contentReady)`                                      | D-07, D-08 — fila inferior, separada del Picker de tipo     |
| `Button` (Exportar)              | `.buttonStyle(.borderedProminent)`, `.disabled(!vm.contentReady)`, `.accessibilityLabel("Exportar contenido")`   | D-08 — misma condición que controles de Phase 4 post-extracción |
| `HStack` (fila export)           | `spacing: 8`                                                                                                      | D-07 — debajo del WKWebView, al final del VStack principal  |
| `Divider`                        | Sin modificadores                                                                                                  | Añadir `Divider()` entre el WKWebView y la HStack de export |

### Estructura VStack modificada en ContentView (Phase 5)

```
VStack(spacing: 16) {
    // [HEREDADO Phase 4]
    TextField(...)                    // Campo URL
    Divider()
    HStack(spacing: 8) {             // Fila extracción
        Picker(tipo) [.segmented]
        Button("Extraer") [.borderedProminent]
    }
    Divider()
    DisclosureGroup("Opciones avanzadas") { ... }
    Divider()

    // [NUEVO Phase 5 — reemplaza ScrollView]
    WebPreviewView(
        htmlContent: vm.htmlForPreview,
        contentReady: $vm.contentReady
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)

    Divider()                         // [NUEVO Phase 5]

    HStack(spacing: 8) {             // [NUEVO Phase 5 — fila export]
        Picker("", selection: $vm.exportFormat) {
            Text("Markdown").tag("markdown")
            Text("HTML").tag("html")
            Text("PDF").tag("pdf").disabled(true)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .disabled(!vm.contentReady)

        Button {
            Task { await vm.export() }
        } label: {
            Label("Exportar", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
        .disabled(!vm.contentReady)
        .accessibilityLabel("Exportar contenido")
    }
}
.padding()
.frame(minWidth: 500, minHeight: 450)
```

### WebPreviewView — firma de inicializador

```swift
// Views/WebPreviewView.swift
struct WebPreviewView: NSViewRepresentable {
    var htmlContent: String?
    @Binding var contentReady: Bool
    // ...
}
```

Llamado desde ContentView con:
```swift
WebPreviewView(htmlContent: vm.htmlForPreview, contentReady: $vm.contentReady)
```

### ExtractionViewModel — propiedades nuevas

```swift
@Published var contentReady: Bool = false
@Published var exportFormat: String = "markdown"
var htmlForPreview: String? { /* propiedad computada — D-05 */ }
```

---

## SwiftUI Interaction Contract

### Estados de la ventana — Phase 5 (6 estados)

Extiende los 5 estados de Phase 4 con el estado intermedio del WKWebView.

| Estado | Condición | Botón Extraer | Picker tipo | Picker formato export | Botón Exportar | Área preview |
|--------|-----------|---------------|-------------|----------------------|----------------|--------------|
| 1. Inicial (URL vacía) | `vm.urlString.isEmpty` | Deshabilitado | Activo | Deshabilitado | Deshabilitado | WKWebView vacío (fondo sistema) |
| 2. URL introducida | `!vm.urlString.isEmpty && !vm.isExtracting && !vm.contentReady` | Habilitado | Activo | Deshabilitado | Deshabilitado | WKWebView vacío |
| 3. Extrayendo | `vm.isExtracting == true` | Deshabilitado | Deshabilitado | Deshabilitado | Deshabilitado | `ProgressView("Extrayendo…")` reemplaza el WKWebView |
| 4. WKWebView cargando | `vm.isExtracting == false && vm.htmlForPreview != nil && vm.contentReady == false` | Habilitado | Activo | Deshabilitado | Deshabilitado | WKWebView cargando (fondo blanco/gris, sin indicador adicional) |
| 5. Contenido listo | `vm.contentReady == true` | Habilitado | Activo | Activo | Habilitado | WKWebView muestra contenido renderizado |
| 6. Error de extracción | `vm.errorMessage != nil` | Habilitado | Activo | Deshabilitado | Deshabilitado | `Text("Error: ...")` en rojo **reemplaza** el WKWebView (mismo bloque `if/else` que Estado 3) — no es un overlay |

### Transiciones de estado críticas

**Extracción nueva iniciada (reset):**
- `vm.resultContent = nil`
- `vm.contentReady = false`
- `vm.htmlForPreview` → `nil` (propiedad computada, automático)
- `updateNSView` detecta `htmlContent == nil` → `webView.loadHTMLString("", baseURL: nil)`
- Estado → 3 (Extrayendo)

**Extracción completada con éxito:**
- `vm.resultContent` recibe el contenido
- `vm.htmlForPreview` → string no-nil
- `updateNSView` detecta nuevo `htmlContent` → `webView.loadHTMLString(htmlContent, baseURL: nil)`
- Estado → 4 (WKWebView cargando)
- `Coordinator.webView(_:didFinish:)` → `parent.contentReady = true`
- Estado → 5 (Contenido listo)

**Export iniciado:**
- `Task { await vm.export() }` — no bloquea UI
- NSSavePanel se abre modalmente
- Si el usuario confirma: guarda archivo, NSSavePanel cierra
- Si el usuario cancela: no hay cambio de estado
- En ningún caso cambia `vm.contentReady` — el usuario puede exportar múltiples veces

### Estado 3 — ProgressView durante extracción

En Phase 5, el `ProgressView("Extrayendo…")` puede colocarse en el mismo espacio
que el WKWebView, condicionado por `vm.isExtracting`:

```swift
if vm.isExtracting {
    ProgressView("Extrayendo…")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
} else {
    WebPreviewView(htmlContent: vm.htmlForPreview, contentReady: $vm.contentReady)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

Alternativa válida: mantener `WebPreviewView` siempre presente y superponer
`ProgressView` con `.overlay`. El ejecutor elige la estrategia más limpia.

### Constraints de ventana

Sin cambios respecto a Phase 4:

```swift
.frame(minWidth: 500, minHeight: 450)
```

Con los nuevos elementos (HStack export ~36pt + Divider ~1pt), la altura útil del
WKWebView se reduce ligeramente. El `minHeight: 450` sigue siendo adecuado.

### Picker formato export — justificación de estilo `.segmented`

3 opciones ("Markdown", "HTML", "PDF") en ancho disponible tras el botón Exportar
(~90pt). El Picker ocupa el espacio restante de la HStack. Con `minWidth: 500`:
espacio disponible ≈ 500 - 2×16pt padding - 8pt spacing - 90pt botón ≈ 370pt.
Tres opciones segmented caben sin truncación.

---

## Registry Safety

No aplica. SwiftUI nativo + WebKit (sistema). Sin registros de terceros.
`marked.js` se incluye como constante Swift hardcodeada en el ViewModel, no
como dependencia de paquete.

| Registry         | Blocks Used | Safety Gate                        |
|------------------|-------------|------------------------------------|
| SwiftUI built-in | N/A         | not required — framework de sistema |
| WebKit           | WKWebView   | not required — framework de sistema |
| marked.js 14.x   | inline      | no registry — bundled como String literal en Swift |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: N/A — SwiftUI nativo + WebKit sistema, sin registros de terceros

**Approval:** APPROVED — 2026-06-11

---

## Pre-population Sources

| Fuente                  | Decisiones incorporadas                                                                                           |
|-------------------------|-------------------------------------------------------------------------------------------------------------------|
| 05-CONTEXT.md D-01→D-14 | WebPreviewView NSViewRepresentable, contentReady Binding, updateNSView con htmlContent, marked.js bundled, WKWebView para 3 tipos, HStack export, .disabled(!vm.contentReady), Picker MD/HTML/PDF, NSSavePanel, CSS inline template, exportFormat @Published |
| 05-CONTEXT.md `<deferred>` | PDF deshabilitado en Phase 5 — opción visible pero `.disabled(true)` |
| 05-CONTEXT.md `<specifics>` | marked.js 14.x, NSSavePanel allowedContentTypes, WKWebViewConfiguration por defecto |
| 04-UI-SPEC.md completo  | Spacing scale, tipografía, colores semánticos, .borderedProminent para botón primario, spacing:8 en HStack, minWidth/minHeight, patrón ProgressView |
| REQUIREMENTS.md         | UI-02 (WKWebView NSViewRepresentable), EXPORT-01 (selector formato), EXPORT-02 (export MD con NSSavePanel), EXPORT-03 (HTML autocontenido sin assets externos) |
| ROADMAP.md Phase 5      | Success criteria: Markdown renderizado visualmente, NSSavePanel, HTML sin assets rotos, dark mode, selector visible antes de exportar |
| STATE.md Pending Todos  | Verificación empírica UTType(filenameExtension: "md") en macOS 13 antes de implementar export MD |
