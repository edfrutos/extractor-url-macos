---
phase: 06-export-pdf
plan: 02
subsystem: swift-model-viewmodel
tags: [swift, codable, viewmodel, filename, xctests, security]
dependency_graph:
  requires: [06-01]
  provides: [ExtractionResult.title, ExtractionViewModel.pageTitle, suggestedFilename(title:extension:)]
  affects: [06-03-PLAN.md]
tech_stack:
  added: []
  patterns: [Codable-optional-field, internal-method-testable, D-06-D-07-filename-fallback]
key_files:
  created: []
  modified:
    - ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionResult.swift
    - ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift
    - ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift
decisions:
  - "suggestedFilename cambia de private a internal para acceso con @testable import en XCTest"
  - "Regex [^a-zA-Z0-9_\\-\\s] elimina path traversal (T-06-04) antes de usar el title como nombre de archivo"
  - "Cadena D-06→D-07: title saneado → prefijo de contenido → export.<ext>"
metrics:
  duration: "~8 min"
  completed: "2026-06-12"
  tasks_completed: 3
  files_modified: 3
requirements: [EXPORT-04]
---

# Phase 06 Plan 02: Contrato de nombre de archivo y campo title (Swift) Summary

Campo `title` opcional en `ExtractionResult`, `pageTitle` publicado en ViewModel, `suggestedFilename(title:extension:)` unificado con cadena D-06→D-07, y tres tests XCTest verdes.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Campo title en ExtractionResult | e62f7d4 | ExtractionResult.swift |
| 2 | pageTitle + suggestedFilename unificado | b4e1c87 | ExtractionViewModel.swift |
| 3 | Tests de suggestedFilename | dae0a4c | ViewModelTests.swift |

## What Was Built

### Task 1: ExtractionResult.title

Se añadió `let title: String?` a la struct `ExtractionResult: Codable` y se incluyó `title` en el `CodingKeys` sin alias (el nombre JSON coincide con el nombre Swift). El campo opcional garantiza retrocompatibilidad: JSON sin `title` decodifica a `nil` sin lanzar error.

### Task 2: pageTitle + suggestedFilename unificado

Tres cambios atómicos en `ExtractionViewModel.swift`:

1. `@Published var pageTitle: String? = nil` — nuevo @Published junto a los existentes
2. En `extract()`, bloque `MainActor.run` de éxito: `self?.pageTitle = result?.title`
3. Reemplaza `private suggestedFilename(from:extension:)` (lines 200-207) por `func suggestedFilename(title:extension:)` con visibilidad `internal` (necesaria para @testable import)

Algoritmo D-06/D-07:
- Si `title` no es nil ni vacío: sanear con `[^a-zA-Z0-9_\-\s]` → "-", trim, prefix(60), espacios → "-"
- Fallback: prefijo de 50 chars de `resultContent` saneado con `[^a-zA-Z0-9_\-]` → "-"
- Fallback final: `"export.<ext>"`

`exportMarkdown` y `exportHTML` actualizados a `suggestedFilename(title: pageTitle, extension:)`. `case "pdf": break` sin cambios (lo activa Plan 03).

### Task 3: Tests XCTest

Tres tests `@MainActor` añadidos a `ViewModelTests`:

- `testSuggestedFilenameWithTitle`: pageTitle="Mi Artículo de Prueba" → termina en ".pdf", no contiene espacios, no es "export.pdf"
- `testSuggestedFilenameFallbackToContent`: pageTitle=nil, resultContent="Contenido sin titulo" → no es "export.md"
- `testSuggestedFilenameFallbackToExport`: pageTitle=nil, resultContent=nil → "export.txt"

Resultado: **10 tests ejecutados, 0 fallos — TEST SUCCEEDED**

## Deviations from Plan

None — el plan se ejecutó exactamente como estaba escrito.

## Security Notes

**T-06-04 mitigado:** La regex `[^a-zA-Z0-9_\-\s]` en `suggestedFilename(title:extension:)` elimina caracteres de path traversal (`/`, `..`, `.`) antes de usar el title como nombre de archivo en NSSavePanel. Los tests verifican que el output no contiene espacios y tiene la extensión correcta.

## Self-Check: PASSED

- [x] `ExtractorApp/ExtractorApp/ExtractorApp/Models/ExtractionResult.swift` contiene `let title: String?`
- [x] `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift` contiene `pageTitle`, `suggestedFilename(title:`, no contiene `suggestedFilename(from:`
- [x] `ExtractorApp/ExtractorApp/ExtractorAppTests/ViewModelTests.swift` contiene los 3 tests nuevos
- [x] Commits e62f7d4, b4e1c87, dae0a4c existen en el log
- [x] TEST SUCCEEDED (10 tests, 0 fallos)
