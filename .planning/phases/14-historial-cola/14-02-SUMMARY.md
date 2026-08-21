---
plan: 14-02
phase: 14-historial-cola
status: complete
completed: "2026-08-21"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - HIST-02
---

# Summary: 14-02 — Vista de historial en la app (SwiftUI)

## What Was Built

### Models/HistoryEntry.swift

- `HistoryEntry: Codable, Identifiable` — mapea el esquema JSON ya fijado
  por `core.py` en 14-01 (`output_type`, `char_count`, `error_message` vía
  `CodingKeys`, mismo patrón que `Models/ExtractionResult.swift`).
- `HistoryEntry.loadAll(limit:)` — lee
  `~/.cache/extractor-url/history.jsonl` con
  `FileManager.default.homeDirectoryForCurrentUser`, decodifica línea a
  línea con `try?` (una línea corrupta se ignora sin romper las demás,
  misma tolerancia que `load_history()` en Python), devuelve más reciente
  primero.

### ViewModels/HistoryViewModel.swift

- `@MainActor final class HistoryViewModel: ObservableObject` —
  `@Published private(set) var entries`, `reload()` delega en
  `HistoryEntry.loadAll()`.

### Views/HistoryView.swift

- `HistoryView` — `List` de entradas con estado vacío ("Sin extracciones
  todavía") y botón "Cerrar".
- `HistoryRow` — icono de éxito/error (check verde / triángulo naranja),
  título o URL, badge de formato; toda la fila es el botón de "reabrir".

### ContentView.swift

- `@State private var showingHistory` + botón `clock.arrow.circlepath`
  en `heroSection`, antes del indicador de `isExtracting`.
- `.sheet(isPresented: $showingHistory) { HistoryView { entry in ... } }`
  adjuntado al `ZStack` raíz. El closure de `onReopen` asigna
  `vm.urlString`/`vm.outputType` (fallback `"text"`)/`vm.selectorCSS` y
  llama a `vm.extract()` — sin lógica de extracción duplicada, reutiliza
  el flujo ya existente de `ExtractionViewModel`.

**La app solo LEE `history.jsonl`** — quien escribe siempre es el motor
Python (14-01), incluso cuando la propia app llama a `PythonBridge.run()`.

## Bug de calidad encontrado y corregido durante el checkpoint

Durante la revisión del diff pendiente se detectó una condición de carrera
real en `Services/PythonBridge.swift`, no relacionada con esta fase:
`IOCollector.result()` había perdido el `lock.lock()`/`defer { lock.unlock() }`
que protege la lectura de `outData`/`errData`, mientras
`appendOut`/`appendErr` seguían escribiendo con el lock desde los
`readabilityHandler` concurrentes de stdout/stderr. Corregido restaurando
el lock en `result()` — commit `7fa4095`.

## Verification Status — ✅ VERIFICADO (checkpoint humano)

Verificado en Xcode real por el usuario, con extracciones reales hechas
desde la propia app:

- `Build Succeeded` tras Clean Build Folder + Build.
- El botón de historial abre el sheet con las entradas correctas (título/URL,
  badge de formato, más reciente primero).
- "Reabrir" una entrada cierra el sheet, repuebla `urlString`/`outputType`/
  `selectorCSS` con los valores correctos, y reextrae automáticamente
  (spinner "Extrayendo...") vía el flujo existente.

## Self-Check

- [x] `HistoryEntry.loadAll()` lee la misma ruta exacta que escribe `core.py`
- [x] Una línea corrupta no rompe la carga de las demás entradas
- [x] "Reabrir" no reimplementa lógica de extracción — solo asigna campos y llama a `vm.extract()`
- [x] Ninguna entrada de historial se escribe desde Swift
- [x] Build Succeeded en Xcode
- [x] Historial visible con entradas reales de la app
- [x] Reabrir funciona de principio a fin, campos correctos
- [x] Bug de carrera en `PythonBridge.IOCollector.result()` corregido y commiteado
