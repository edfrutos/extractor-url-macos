---
phase: 6
slug: export-pdf
status: draft
shadcn_initialized: false
preset: macOS HIG
created: 2026-06-12
platform: macOS SwiftUI
---

# Phase 6 — UI Design Contract: Export PDF

> Contrato visual e interactivo para la fase de exportación PDF vía WKWebView.
> Generado por gsd-ui-researcher. Verificado por gsd-ui-checker.
> NOTA: Este spec adapta la plantilla estándar a SwiftUI/macOS. No aplican
> shadcn, radix, tokens hex ni px. Todas las unidades son pt (puntos SwiftUI).
> Este spec EXTIENDE Phase 5 — hereda todos los valores sin excepción y documenta
> exclusivamente los elementos nuevos o modificados introducidos por la opción PDF.

---

## Design System

| Propiedad          | Valor                                                                |
|--------------------|----------------------------------------------------------------------|
| Tool               | none — SwiftUI nativo                                                |
| Preset             | macOS Human Interface Guidelines (HIG)                               |
| Component library  | SwiftUI built-in + WebKit.WKWebView (NSViewRepresentable)            |
| Icon library       | SF Symbols 4 (sistema, sin dependencias extra)                       |
| Font (SwiftUI)     | SF Pro — system font vía `.font(.body)` etc.                         |
| Font (WKWebView)   | `-apple-system, BlinkMacSystemFont, sans-serif` (CSS inline)         |
| Deployment target  | macOS 13.0+                                                          |

HEREDADO de 05-UI-SPEC.md sin cambios. Sin frameworks de terceros adicionales.
No se instalan dependencias nuevas en Python ni en Swift.

Fuente: RESEARCH.md § Standard Stack

---

## Spacing Scale

Escala base 4pt — IDÉNTICA a Phase 4 y Phase 5. Sin excepciones nuevas en Phase 6.

| Token | Valor (pt) | SwiftUI equivalente              | Uso Phase 4+5+6                                      |
|-------|------------|----------------------------------|------------------------------------------------------|
| xs    | 4pt        | `.padding(4)` / `spacing: 4`    | Separación ícono-etiqueta, gaps inline               |
| sm    | 8pt        | `.padding(8)` / `spacing: 8`    | HStack fila export (entre Picker y botón)            |
| md    | 16pt       | `.padding()` / `spacing: 16`    | Espaciado estándar entre elementos VStack            |
| lg    | 24pt       | `.padding(24)` / `spacing: 24`  | Padding exterior de la ventana                       |
| xl    | 32pt       | `.padding(32)` / `spacing: 32`  | No usado en ninguna fase hasta Phase 6               |

Phase 6 no introduce ningún nuevo token de espaciado.

Fuente: 05-UI-SPEC.md § Spacing Scale (heredado íntegramente)

---

## Typography

HEREDADA íntegramente de Phase 5. Sin roles tipográficos nuevos en la capa SwiftUI.

| Rol           | Tamaño semántico | Peso        | SwiftUI modifier                                 | Uso en Phase 6                              |
|---------------|------------------|-------------|--------------------------------------------------|---------------------------------------------|
| Body          | ~13pt (body)     | Regular 400 | `.font(.body)`                                   | Label NSAlert ("Error al exportar PDF")     |
| Label/Caption | ~11pt (caption)  | Regular 400 | `.font(.caption)`                                | Sin uso nuevo en Phase 6                    |

### Tipografía dentro del WKWebView (CSS — sin cambios)

El HTML template de `generateHTML(content:outputType:)` permanece inalterado.
Phase 6 fuerza modo claro (fondo blanco, texto negro) durante la captura PDF,
pero el CSS del template no se modifica.

| Elemento HTML | Valor CSS                                                              |
|---------------|------------------------------------------------------------------------|
| body          | `font-family: -apple-system, BlinkMacSystemFont, sans-serif`           |
| body          | `font-size: 16px; line-height: 1.6`                                    |
| pre / code    | `font-family: ui-monospace, monospace; font-size: 14px`                |
| max-width     | `max-width: 800px; margin: 0 auto; padding: 1em`                       |

El PDF resultante heredará estos valores CSS. El override de apariencia (modo claro)
es temporal y solo afecta al proceso de captura, no al template CSS.

Fuente: 05-UI-SPEC.md § Typography + CONTEXT.md D-04

---

## Color

HEREDADO de Phase 5. Phase 6 no añade colores semánticos nuevos.

| Rol              | Color semántico SwiftUI                            | Uso en Phase 6                                                |
|------------------|----------------------------------------------------|---------------------------------------------------------------|
| Dominant (60%)   | `.background` / `Color(NSColor.windowBackgroundColor)` | Sin cambio — fondo de ventana gestionado por macOS       |
| Secondary (30%)  | `Color(NSColor.controlBackgroundColor)`            | Sin cambio                                                    |
| Accent (10%)     | `.accentColor` (azul del sistema)                  | SOLO botón "Exportar" (`.borderedProminent`) — sin cambio     |
| Error/Destructive| `.red`                                             | Sin cambio respecto a Phase 5                                 |
| Text primary     | `.primary`                                         | Label del Picker de formato export — sin cambio               |
| Text secondary   | `.secondary`                                       | Sin uso nuevo en Phase 6 (PDF ya no está deshabilitado)       |

### Override de apariencia para captura PDF (no es un cambio de color del UI)

Durante la generación del PDF se aplica `webView.appearance = NSAppearance(named: .aqua)`
(modo claro forzado). Este override es **temporal y no visible para el usuario** —
el WKWebView vuelve a su apariencia previa inmediatamente después de `createPDF`.
Se implementa con `defer { webView.appearance = savedAppearance }` para garantizar
la restauración incluso si `createPDF` lanza error.

El PDF resultante tendrá siempre: fondo blanco, texto negro, independientemente del
tema del sistema en el momento de exportar.

Fuente: CONTEXT.md D-04 + RESEARCH.md § Pitfall 2

### Ventana principal durante la captura

El usuario verá el WKWebView brevemente cambiar a modo claro (0.1s de delay + tiempo
de `createPDF`). Este comportamiento es aceptable — no se añade overlay ni indicador
de progreso (CONTEXT.md D-09).

---

## Copywriting Contract

Strings exactos para todos los elementos nuevos de Phase 6.
Los strings de Phase 5 no se modifican (heredados íntegramente).

### Modificaciones al Picker de formato

| Elemento                                    | Texto exacto Phase 5           | Texto exacto Phase 6                                                |
|---------------------------------------------|--------------------------------|---------------------------------------------------------------------|
| Picker formato — opción PDF                 | `"PDF"` — `.disabled(true)`    | `"PDF"` — **sin `.disabled(true)`** — quitar la restricción        |

El string "PDF" no cambia. Solo se elimina el `.disabled(true)` del tag.

### NSSavePanel para PDF

| Elemento                              | Texto exacto                                                                                           |
|---------------------------------------|--------------------------------------------------------------------------------------------------------|
| NSSavePanel — nombre sugerido         | Título de la página saneado + `".pdf"` — preferir `result.title` sobre prefijo de contenido (D-06)    |
| NSSavePanel — extensión permitida     | `allowedContentTypes: [.pdf]` — `UTType.pdf` disponible desde macOS 11+, sin import adicional          |
| NSSavePanel — opción crear directorio | `canCreateDirectories = true`                                                                          |

### Algoritmo de nombre sugerido (D-06, D-07) — unificado para los 3 formatos

El método `suggestedFilename(title:extension:)` reemplaza la heurística anterior de
Phase 5 (prefijo de contenido como primera opción) para todos los formatos:

1. Si `result.title` no es nil y no está vacío tras sanear: usar título saneado + extensión
2. Si no: primeros 50 chars de `resultContent` sanitizados + extensión (heurística Phase 5)
3. Si también vacío: `"export"` + extensión

Sanitización del título: `[^a-zA-Z0-9_\-\s]` → `"-"`, espacios → `"-"`, prefix(60), trim `"-"`.

Este refactor afecta a `exportMarkdown()` y `exportHTML()` (que pasan a usar el mismo
método), así como al nuevo `exportPDF()`.

Fuente: CONTEXT.md D-06, D-07 + RESEARCH.md § Pattern 5

### NSAlert de error PDF (D-08)

Mostrar `NSAlert` cuando `createPDF` lanza error O cuando `data.write(to:)` falla.
MD y HTML mantienen el patrón `print()` silencioso — no se modifican.

| Campo NSAlert        | Texto exacto                                                                          |
|----------------------|---------------------------------------------------------------------------------------|
| `messageText`        | `"Error al exportar PDF"`                                                             |
| `informativeText`    | `"No se pudo generar el archivo PDF.\n\(error.localizedDescription)"`                 |
| `alertStyle`         | `.warning`                                                                            |
| Botón único          | `"Aceptar"`                                                                           |

`NSAlert.runModal()` se llama exclusivamente desde `@MainActor`.

Fuente: CONTEXT.md D-08 + RESEARCH.md § Pattern 3

### Accesibilidad

| Elemento                      | Accessibility label                    | Nota                                                    |
|-------------------------------|----------------------------------------|---------------------------------------------------------|
| Botón Exportar (PDF activo)   | `"Exportar contenido"` (sin cambio)    | Heredado de Phase 5 — el label es genérico y correcto   |
| Opción PDF del Picker         | Sin cambio — VoiceOver lee `"PDF"`     | Ya no tiene estado deshabilitado                        |

---

## SwiftUI Component Contract

Componentes modificados en Phase 6 respecto a Phase 5.
Los componentes no listados aquí se mantienen sin cambio — ver 05-UI-SPEC.md.

### Cambio en el Picker de formato export

```swift
// Phase 5 (ANTES):
Text("PDF").tag("pdf").disabled(true)

// Phase 6 (DESPUÉS):
Text("PDF").tag("pdf")
// Sin .disabled(true) — la opción PDF queda habilitada junto a MD y HTML
```

El Picker completo mantiene `.disabled(!vm.contentReady)` en el nivel del
componente Picker, que ya cubre el estado "sin contenido". No hay cambio en
la lógica de habilitación del Picker.

### ExtractionViewModel — propiedades nuevas

```swift
// Añadir a ExtractionViewModel.swift
@Published var pageTitle: String? = nil   // poblado al decodificar ExtractionResult

// Reemplazar suggestedFilename(from:extension:) con:
private func suggestedFilename(title: String?, extension ext: String) -> String
```

### ExtractionResult — campo nuevo

```swift
// Models/ExtractionResult.swift — añadir campo opcional (retrocompatible)
let title: String?   // nil si el JSON no incluye el campo o vale null

// CodingKeys actualizado:
enum CodingKeys: String, CodingKey {
    case status, url, selector, content, title
    case outputType   = "output_type"
    case charCount    = "char_count"
    case errorMessage = "error_message"
}
```

No rompe el decoder existente: `String?` con valor ausente → `nil`.

### WebPreviewView — mecanismo de exposición del WKWebView (D-01)

El `Coordinator` ya guarda `weak var webView: WKWebView?`. Phase 6 registra un
closure en el ViewModel para que `exportPDF()` pueda acceder al webView:

```swift
// ExtractionViewModel.swift
var webViewProvider: (() -> WKWebView?)? = nil   // registrado desde makeNSView

// WebPreviewView.makeNSView — tras crear el webView:
context.coordinator.webView = webView
viewModel.webViewProvider = { [weak coordinator] in coordinator?.webView }
```

El ViewModel llama `webViewProvider?()` en `exportPDF()` para obtener la referencia.
Si devuelve `nil` (webView no disponible), `exportPDF()` retorna sin acción.

Fuente: CONTEXT.md D-01 + RESEARCH.md § Pattern 1

### Estructura VStack en ContentView — modificación Phase 6

Solo cambia la línea del tag "pdf" en el Picker de la fila export:

```swift
// ANTES (Phase 5):
Picker("", selection: $vm.exportFormat) {
    Text("Markdown").tag("markdown")
    Text("HTML").tag("html")
    Text("PDF").tag("pdf").disabled(true)   // ← quitar .disabled(true)
}

// DESPUÉS (Phase 6):
Picker("", selection: $vm.exportFormat) {
    Text("Markdown").tag("markdown")
    Text("HTML").tag("html")
    Text("PDF").tag("pdf")                  // ← habilitado
}
```

El resto de la estructura VStack de ContentView permanece idéntico a Phase 5.

---

## SwiftUI Interaction Contract

### Estados de la ventana — Phase 6 (sin cambios de estado)

Phase 6 no añade ni elimina estados. La tabla de 6 estados de Phase 5 se mantiene
íntegramente. El cambio es que en Estado 5 ("Contenido listo"), la opción PDF del
Picker ya no está deshabilitada individualmente.

| Estado | Condición | Picker formato export (cambio Phase 6)   | Botón Exportar |
|--------|-----------|-------------------------------------------|----------------|
| 1-4, 6 | Sin `contentReady` | Picker deshabilitado en bloque (`.disabled(!vm.contentReady)`) — PDF inaccesible igual que MD y HTML | Deshabilitado |
| 5. Contenido listo | `vm.contentReady == true` | **PDF habilitado** junto a MD y HTML — las 3 opciones son seleccionables | Habilitado |

### Flujo de exportación PDF — Estados internos (sin indicador visual)

No se añade estado visual de "exportando PDF" (D-09). El flujo desde el punto de
vista del usuario:

1. Usuario selecciona "PDF" en el Picker (Estado 5)
2. Usuario pulsa "Exportar" → `Task { await vm.export() }`
3. El WKWebView cambia brevemente a modo claro (~0.1s + tiempo createPDF)
4. Se abre NSSavePanel con nombre sugerido y extensión `.pdf`
5a. Usuario confirma ubicación → el PDF se guarda → NSSavePanel cierra
5b. Usuario cancela → NSSavePanel cierra sin cambio de estado
6. En caso de error: NSAlert modal con mensaje y botón "Aceptar"

No hay cambio en `vm.contentReady` en ningún caso. El usuario puede exportar
múltiples veces sin re-extraer.

### Flujo `exportPDF()` — contrato de implementación

```
exportPDF() [@MainActor async]
  │
  ├─ guard webViewProvider?() != nil else return (silencioso — no debería ocurrir)
  │
  ├─ 1. savedAppearance = webView.appearance
  ├─ 2. webView.appearance = NSAppearance(named: .aqua)   [D-04]
  ├─ 3. defer { webView.appearance = savedAppearance }     [restaurar siempre]
  │
  ├─ 4. try? await Task.sleep(nanoseconds: 100_000_000)   [0.1s — Pitfall #4]
  │
  ├─ 5. pdfData = try await webView.createPDF(...)
  │      Si falla → NSAlert("Error al exportar PDF") + return
  │
  ├─ 6. NSSavePanel(allowedContentTypes: [.pdf])
  │      nameFieldStringValue = suggestedFilename(title: pageTitle, extension: "pdf")
  │      canCreateDirectories = true
  │      → withCheckedContinuation (patrón de Phase 5)
  │      Si usuario cancela → return
  │
  └─ 7. pdfData.write(to: url, options: .atomic)
         Si falla → NSAlert("Error al exportar PDF")
```

### Constraints de ventana

Sin cambios respecto a Phase 5:

```swift
.frame(minWidth: 500, minHeight: 450)
```

---

## Cambios en el contrato JSON Python ↔ Swift

Phase 6 extiende el contrato JSON del CLI Python con el campo `title`.
Este cambio es transversal (afecta a Python y Swift) y es parte del contrato UI
porque determina el nombre de archivo sugerido en el NSSavePanel.

### Contrato JSON ampliado

```json
{
  "status": "success",
  "url": "https://example.com",
  "selector": null,
  "output_type": "markdown",
  "char_count": 1234,
  "content": "# Título\n\nContenido...",
  "title": "Ejemplo — Página de prueba"
}
```

El campo `"title"` es `String | null`. Nunca omitido — siempre presente con valor
string o `null`. Retrocompatible con el decoder Swift (`String?` acepta `null` → `nil`).

### Extracción del título en Python (core.py)

```python
# Patrón seguro (BeautifulSoup primero, trafilatura como fallback)
def _extract_title(soup, html_text=None):
    if soup.title and soup.title.string:
        stripped = soup.title.string.strip()
        if stripped:
            return stripped
    if html_text:
        try:
            meta = trafilatura.extract_metadata(html_text)
            if meta and meta.title:
                return meta.title.strip()
        except Exception:
            pass
    return None
```

Fuente: CONTEXT.md D-05 + RESEARCH.md § Pattern 4

---

## Registry Safety

No aplica. Sin cambios respecto a Phase 5.

| Registry         | Blocks Used | Safety Gate                         |
|------------------|-------------|-------------------------------------|
| SwiftUI built-in | N/A         | not required — framework de sistema  |
| WebKit           | WKWebView   | not required — framework de sistema  |
| AppKit           | NSAlert, NSSavePanel, NSAppearance | not required — framework de sistema |
| marked.js 14.x   | inline      | no registry — bundled como String literal en Swift |

Fuente: RESEARCH.md § Package Legitimacy Audit

---

## Pre-population Sources

| Fuente                        | Decisiones incorporadas                                                                                                                          |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| CONTEXT.md D-01               | PDF desde WKWebView visible del preview (no offscreen) — Coordinator ya tiene `weak var webView`                                                  |
| CONTEXT.md D-02               | WYSIWYG estricto — ancho PDF sigue al ancho de ventana, sin forzar ancho mínimo                                                                   |
| CONTEXT.md D-03               | Página única continua — `WKPDFConfiguration()` sin modificar `rect`                                                                              |
| CONTEXT.md D-04               | Forzar modo claro en PDF: `NSAppearance(named: .aqua)` + `defer` para restaurar                                                                   |
| CONTEXT.md D-05               | Campo `title: String?` en JSON y en `ExtractionResult.swift`                                                                                     |
| CONTEXT.md D-06               | Los 3 formatos usan título como nombre sugerido — refactor de `suggestedFilename()`                                                               |
| CONTEXT.md D-07               | Fallback: prefijo de contenido (50 chars) → `"export"` si vacío                                                                                  |
| CONTEXT.md D-08               | NSAlert visible en error de generación o guardado PDF; MD/HTML mantienen `print()` silencioso                                                     |
| CONTEXT.md D-09               | Sin indicador de progreso durante la generación PDF — sub-segundo para contenido ya renderizado                                                   |
| RESEARCH.md Pattern 1         | Closure `webViewProvider` en ViewModel para acceder al WKWebView sin acoplamiento directo                                                         |
| RESEARCH.md Pattern 2         | `createPDF(configuration:completionHandler:)` con `withCheckedThrowingContinuation` como fallback seguro; verificar async nativo en Wave 0        |
| RESEARCH.md Pattern 3         | Wording exacto del NSAlert: "Error al exportar PDF" / "No se pudo generar el archivo PDF.\n..."                                                  |
| RESEARCH.md Pattern 4         | `_extract_title(soup, html_text)` en `core.py`; segunda llamada a `_fetch_raw` es hit de caché                                                   |
| RESEARCH.md Pattern 5         | `suggestedFilename(title:extension:)` con sanitización regex, prefix(60), fallback                                                               |
| RESEARCH.md Pitfall 1         | Delay 0.1s (`Task.sleep(nanoseconds: 100_000_000)`) entre `didFinish` y `createPDF`                                                              |
| RESEARCH.md Pitfall 2         | `defer { webView.appearance = savedAppearance }` para restaurar en ambos paths                                                                   |
| RESEARCH.md Anti-patterns     | `allowedContentTypes: [.pdf]` (no `allowedFileTypes`); `NSAlert.runModal()` solo desde `@MainActor`                                               |
| 05-UI-SPEC.md completo        | Design system, spacing scale, tipografía, colores semánticos, estructura VStack, estados de ventana, patrón NSSavePanel+withCheckedContinuation    |
| REQUIREMENTS.md EXPORT-04     | Único requisito de la fase: `WKWebView.pdf()` async, `contentReady` como guarda, `NSSavePanel`                                                   |
| ROADMAP.md Phase 6            | 3 success criteria: botón PDF gated hasta `contentReady`, PDF vectorial con texto seleccionable, NSSavePanel con nombre sugerido de título        |

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: N/A — SwiftUI nativo + WebKit + AppKit sistema, sin registros de terceros

**Approval:** pending
