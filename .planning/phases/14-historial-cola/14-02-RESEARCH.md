---
phase: 14-historial-cola
plan: 02-research
type: research
status: complete
created: "2026-08-20"
---

# Phase 14-02: Vista de historial en la app SwiftUI — Research

## User Constraints

### Locked Decisions (desde 14-01)

- `history.jsonl` en `~/.cache/extractor-url/history.jsonl`, JSON Lines, solo metadatos (sin `content`) — la app lee ese archivo directamente del disco, sin pasar por `PythonBridge`.
- El campo `output_type` de cada entrada ya usa los mismos valores que `ExtractionViewModel.outputType` ("text"/"html"/"markdown") — `main()` graba `args.type` (el choice crudo de la CLI), no el `content_type` interno mapeado ("html_string" etc.) — sin necesidad de remapeo en Swift.

### Claude's Discretion

- Dónde vive el punto de entrada a la vista de historial (botón en el hero, menú, etc.).
- Si "reabrir" reextrae de verdad (vía el bridge, aprovechando la caché HTTP de Python) o simplemente rellena los campos sin ejecutar — se decide reextraer, ver Summary.

### Deferred Ideas (OUT OF SCOPE — 14-02)

- Búsqueda/filtrado del historial — v7+ si hace falta (ver `14-RESEARCH.md`, Deferred Ideas ya documentadas).
- Refresco en vivo del historial mientras la vista está abierta (FSEvents/watcher) — recargar en cada apertura de la vista es suficiente para v6.0.
- Borrar entradas individuales del historial desde la UI — v7+ si se pide.

## Summary

"Reabrir" una entrada de historial = rellenar `ExtractionViewModel.urlString`/`outputType`/`selectorCSS` con los datos de la entrada y llamar a `vm.extract()` de nuevo. **No se reimplementa el flujo de extracción** — se reutiliza el que ya existe. Como `_fetch_raw()` (Python) cachea por URL, la reextracción es rápida (hit de caché) en la mayoría de los casos, cumpliendo la intención de "sin repetirla" sin necesidad de guardar el contenido completo en el historial (decisión ya tomada en 14-01). "Reexportar" se resuelve transitivamente: tras reabrir, `contentReady` vuelve a `true` y los botones de exportación ya existentes (`exportCard`) funcionan sin cambios.

3 archivos nuevos, ningún archivo existente reescrito — solo `ContentView.swift` recibe una adición pequeña (botón + `.sheet`):

- `Models/HistoryEntry.swift` — `Codable` + loader que lee `history.jsonl` (implementación Swift independiente de `core.load_history()`, mismo formato, mismo orden más-reciente-primero — la app no invoca Python para esto).
- `ViewModels/HistoryViewModel.swift` — `@MainActor ObservableObject`, `@Published var entries`, `reload()`.
- `Views/HistoryView.swift` — `List` con las entradas, acción "Reabrir" por fila.

## Análisis del Estado Actual del Código

### `ContentView.swift` — puntos de integración

`heroSection` (líneas 42-82) ya tiene un `HStack` con `Spacer()` antes del
indicador de `isExtracting` — sitio natural para un botón de historial
(icono `clock.arrow.circlepath`, junto al spinner). `ContentView` usa
`@StateObject private var vm = ExtractionViewModel()` (línea 6) — el
nuevo botón necesita `@State private var showingHistory = false` y un
`.sheet(isPresented: $showingHistory) { HistoryView(...) }` adjuntado al
`ZStack` raíz (mismo patrón que cualquier sheet estándar de SwiftUI, sin
precedente previo en este archivo pero sin complejidad añadida).

### `ExtractionViewModel` — superficie ya suficiente para "reabrir"

`urlString`, `outputType`, `selectorCSS` son `@Published var` de solo
escritura directa (líneas 12-14) — la vista de historial puede asignarlos
sin necesidad de un método nuevo en el ViewModel, y llamar a
`vm.extract()` (ya público, guard interno `!isExtracting` ya evita doble
disparo — mismo patrón que el botón "Extraer" existente).

### Esquema JSON ya fijado por `core.py` (14-01)

```json
{"timestamp": "...", "url": "...", "output_type": "markdown", "selector": null, "status": "success", "char_count": 4231, "title": "...", "error_message": null}
```

Mapeo directo a un `Codable` Swift con `CodingKeys` (mismo patrón que
`Models/ExtractionResult.swift`): `output_type → outputType`,
`char_count → charCount`, `error_message → errorMessage` — resto de
campos con el mismo nombre.

## Standard Stack

- `FileManager.default.homeDirectoryForCurrentUser` + `.appendingPathComponent(".cache/extractor-url/history.jsonl")` — ruta equivalente a `Path.home() / ".cache" / "extractor-url" / "history.jsonl"` de Python, sin nueva dependencia.
- `JSONDecoder` línea a línea (`String(contentsOf:).split(separator: "\n")` + `try? decoder.decode(...)` por línea, ignorando fallos) — mismo enfoque tolerante a líneas corruptas que `core.load_history()`, sin librería nueva.

## Architecture Patterns

### `Models/HistoryEntry.swift`

```swift
import Foundation

struct HistoryEntry: Codable, Identifiable {
    let timestamp: String
    let url: String
    let outputType: String?
    let selector: String?
    let status: String
    let charCount: Int?
    let title: String?
    let errorMessage: String?

    var id: String { timestamp + url }   // única por (timestamp, url) — sin uuid persistido en el JSON

    enum CodingKeys: String, CodingKey {
        case timestamp, url, selector, status, title
        case outputType   = "output_type"
        case charCount    = "char_count"
        case errorMessage = "error_message"
    }

    var isSuccess: Bool { status == "success" }

    static func loadAll(limit: Int? = nil) -> [HistoryEntry] {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".cache/extractor-url/history.jsonl")
        guard let text = try? String(contentsOf: path, encoding: .utf8) else { return [] }

        let decoder = JSONDecoder()
        var entries: [HistoryEntry] = []
        for line in text.split(separator: "\n") {
            guard let data = line.data(using: .utf8),
                  let entry = try? decoder.decode(HistoryEntry.self, from: data)
            else { continue }
            entries.append(entry)
        }
        entries.reverse()
        if let limit { return Array(entries.prefix(limit)) }
        return entries
    }
}
```

### `ViewModels/HistoryViewModel.swift`

```swift
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var entries: [HistoryEntry] = []

    func reload() {
        entries = HistoryEntry.loadAll()
    }
}
```

### `Views/HistoryView.swift` — patrón de fila + acción de reabrir

```swift
import SwiftUI

struct HistoryView: View {
    @StateObject private var historyVM = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    let onReopen: (HistoryEntry) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Historial").font(.headline)
                Spacer()
                Button("Cerrar") { dismiss() }
            }
            .padding()

            if historyVM.entries.isEmpty {
                emptyState
            } else {
                List(historyVM.entries) { entry in
                    HistoryRow(entry: entry) {
                        onReopen(entry)
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 360)
        .onAppear { historyVM.reload() }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath").font(.largeTitle).foregroundStyle(.secondary)
            Text("Sin extracciones todavía").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: entry.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(entry.isSuccess ? .green : .orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title ?? entry.url)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    Text(entry.url)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                if let outputType = entry.outputType {
                    Text(outputType.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
```

### Integración en `ContentView.swift`

```swift
@State private var showingHistory = false

// dentro de heroSection, antes del Spacer/isExtracting existente:
Button {
    showingHistory = true
} label: {
    Image(systemName: "clock.arrow.circlepath")
}
.buttonStyle(.plain)
.help("Historial de extracciones")

// adjuntado al ZStack raíz de body, tras el .onAppear existente:
.sheet(isPresented: $showingHistory) {
    HistoryView { entry in
        vm.urlString = entry.url
        vm.outputType = entry.outputType ?? "text"
        vm.selectorCSS = entry.selector ?? ""
        vm.extract()
    }
}
```

## Don't Hand-Roll

- **No reimplementar `record_history_entry`/`load_history` en Swift para escribir** — la app solo LEE `history.jsonl`; quien escribe siempre es el motor Python (vía CLI, incluida la propia app cuando llama a `PythonBridge.run()` → `extractor_url.py --json`). No hace falta que Swift escriba entradas por sí mismo.
- **No añadir un nuevo modo al bridge para "reabrir sin reextraer"** — reabrir SIEMPRE reextrae vía `vm.extract()` normal; la caché HTTP de Python ya hace que sea rápido en el caso común, sin necesidad de un camino especial en `PythonBridge`.

## Common Pitfalls

### Pitfall 1: Ruta del historial distinta entre Python y Swift

Si la ruta construida en Swift no coincide exactamente con
`Path.home() / ".cache" / "extractor-url" / "history.jsonl"` de Python
(p.ej. usar `NSHomeDirectory()` con un layout distinto, o un separador
distinto), la vista de historial estará siempre vacía sin error visible.
Verificar en el checkpoint humano abriendo el archivo real con `cat` y
comparando con lo que la app muestra.

### Pitfall 2: `outputType` nil rompe el Picker al reabrir

Si una entrada antigua no tuviera `output_type` (no debería pasar con el
código de 14-01, pero por robustez), asignar `vm.outputType = entry.outputType ?? "text"` evita dejar el picker en un estado inconsistente.

## Estrategia de Verificación

Igual que la Fase 12 — Swift no se puede compilar en este sandbox. Se
escribe el código completo aquí y se verifica en un checkpoint humano en
Xcode: compila, la vista de historial muestra entradas reales generadas
por extracciones previas de la app, y "reabrir" repuebla los campos y
reextrae correctamente.

## Sources

### Primary (HIGH confidence)

- Lectura directa de este repo: `ContentView.swift` completo, `ExtractionViewModel.swift` (líneas 1-88), `Models/ExtractionResult.swift`, `.planning/phases/14-historial-cola/14-RESEARCH.md` (esquema JSON ya fijado en 14-01).

## Metadata

- Requirements cubiertos: HIST-02
- Depends on: Phase 14-01 (esquema de `history.jsonl` ya fijado y verificado)
- Bloquea: 14-02-PLAN.md (implementación) + checkpoint humano en Xcode
