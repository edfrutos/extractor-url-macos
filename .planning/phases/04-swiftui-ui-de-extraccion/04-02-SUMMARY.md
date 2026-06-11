---
phase: 04-swiftui-ui-de-extraccion
plan: 02
subsystem: ui
tags: [swiftui, macos, contentview, extractionviewmodel, stateobject]

requires:
  - phase: 04-swiftui-ui-de-extraccion
    plan: 01
    provides: ExtractionViewModel con contrato @Published completo

provides:
  - ContentView.swift reescrita con interfaz de extracción real
  - 5 estados de ventana implementados (inicial, URL-introducida, extrayendo, éxito, error)
  - BridgeTestViewModel eliminado del codebase

affects: [04-03, 04-04, fase-05-export]

tech-stack:
  added: []
  patterns:
    - "@StateObject para ViewModel en SwiftUI (no @Observable)"
    - "5 estados de ventana con Group { if/else if } anidado"
    - "DisclosureGroup para opciones avanzadas colapsadas por defecto"
    - "Error inline con .foregroundColor(.red) sin alert modal"

key-files:
  created: []
  modified:
    - ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift

key-decisions:
  - "Omitir .textContentType(.URL) — no disponible en macOS TextField, solo en SecureField"
  - "DisclosureGroup con isExpanded=false por defecto (D-13) — opciones avanzadas ocultas hasta que el usuario las necesite"
  - "Error inline en .red sin alert modal (D-08) — experiencia menos disruptiva para errores esperados como pythonNotFound"

patterns-established:
  - "Estados de ventana con Group + if/else if sobre propiedades @Published del ViewModel"
  - "isPythonPathError como flag semántico en ViewModel para diferenciar hints de UI sin duplicar lógica en la View"

requirements-completed: [APP-01, APP-02, APP-03, UI-01, UI-03]

duration: 8min
completed: 2026-06-11
---

# Phase 4 Plan 02: ContentView con ExtractionViewModel y 5 estados UI

**SwiftUI ContentView reescrita con 5 estados de ventana, DisclosureGroup de opciones avanzadas y error inline usando ExtractionViewModel de plan 04-01**

## Performance

- **Duration:** ~8 min
- **Started:** 2026-06-11T16:16:00Z
- **Completed:** 2026-06-11T16:24:00Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- ContentView.swift completamente reescrita: eliminado BridgeTestViewModel y todo el andamio de Fase 3
- Implementados los 5 estados de ventana: inicial (vacío), URL-introducida (botón activo), extrayendo (ProgressView), éxito (ScrollView monoespaciado), error (Text rojo + hint opcional)
- Compilación limpia verificada con xcodebuild BUILD SUCCEEDED

## Task Commits

1. **Task 1+2: Reescribir ContentView y verificar compilación** - `cd65ffe` (feat)

## Files Created/Modified

- `ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift` — Reescrita completamente con ExtractionViewModel, 5 estados, DisclosureGroup, Picker segmentado

## Criterios de aceptación verificados

| Criterio | Resultado |
|----------|-----------|
| `@StateObject private var vm = ExtractionViewModel` | 1 resultado |
| `minWidth: 500, minHeight: 450` | 1 resultado |
| `Extrayendo` con U+2026 | 1 resultado |
| `foregroundColor(.red)` | 1 resultado |
| `BridgeTestViewModel` en todos los .swift | 0 resultados |
| `xcodebuild BUILD SUCCEEDED` | PASSED |
| `@Observable` no presente | 0 resultados |

## Decisions Made

- **Omisión de `.textContentType(.URL)`:** Este modificador no está disponible en `TextField` de macOS (solo existe en `SecureField`). Se eliminó para evitar error de compilación. El valor semántico queda cubierto por `.onSubmit { vm.extract() }`.
- **`import Combine` eliminado:** La View no usa Combine directamente; el import sobrante del andamio anterior fue limpiado.

## Deviations from Plan

### Auto-fixed Issues

**1. [Regla 1 - Bug] Eliminado `.textContentType(.URL)` no disponible en macOS**
- **Found during:** Task 1 (escritura de ContentView.swift)
- **Issue:** El plan incluía `.textContentType(.URL)` en el TextField de URL. En macOS ese modificador solo está disponible en `SecureField`, no en `TextField` — habría causado error de compilación.
- **Fix:** Eliminado el modificador. El comportamiento semántico de "campo URL" se mantiene con `.onSubmit { vm.extract() }` y el placeholder "https://example.com".
- **Files modified:** ContentView.swift
- **Verification:** xcodebuild BUILD SUCCEEDED sin warnings relacionados
- **Committed in:** cd65ffe

---

**Total deviations:** 1 auto-fixed (Regla 1 — bug de incompatibilidad de API macOS)
**Impact on plan:** Fix necesario para compilación. Sin cambio de comportamiento visible para el usuario.

## Issues Encountered

Ninguno más allá de la desviación documentada.

## Known Stubs

Ninguno. La View consume datos reales de ExtractionViewModel; no hay valores hardcoded ni placeholders que fluyan a la UI.

## Threat Flags

Ninguno. No se han introducido nuevas superficies de red, rutas de auth, acceso a ficheros ni cambios de schema más allá de los documentados en el threat model del plan (T-04-04, T-04-05, T-04-06).

## Next Phase Readiness

- ContentView lista para producción, consume ExtractionViewModel end-to-end
- Plan 04-03 (SettingsView / Preferencias) puede implementarse sin bloqueo
- La ventana principal muestra campo URL, Picker segmentado, DisclosureGroup con opciones avanzadas y el área de resultado/error completa
- Pendiente: configurar ruta Python en SettingsView para que la extracción real funcione end-to-end

---
*Phase: 04-swiftui-ui-de-extraccion*
*Completed: 2026-06-11*
