---
phase: 04-swiftui-ui-de-extraccion
plan: "01"
subsystem: swiftui-viewmodel
tags: [swiftui, viewmodel, observableobject, async, concurrency]
dependency_graph:
  requires: []
  provides: [ExtractionViewModel]
  affects: [ContentView, ExtractorAppApp]
tech_stack:
  added: []
  patterns: [ObservableObject, Task.detached, MainActor.run, weak-self]
key_files:
  created:
    - ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift
  modified: []
decisions:
  - "import Combine añadido explícitamente: SDK macOS 26.5 / Xcode 26.5 requiere el import para @Published aunque SwiftUI lo reexporta en versiones anteriores"
  - "PBXFileSystemSynchronizedRootGroup: el pbxproj no necesita modificación manual; Xcode recoge ViewModels/ automáticamente al existir en disco"
metrics:
  duration: "8 minutos"
  completed: "2026-06-11"
  tasks_completed: 2
  files_created: 1
  files_modified: 0
---

# Phase 04 Plan 01: ExtractionViewModel Summary

**One-liner:** ObservableObject con 8 propiedades @Published y extract() async via Task.detached + MainActor.run para separar lógica de negocio de la View.

## Qué se creó

`ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift`

Clase `@MainActor final class ExtractionViewModel: ObservableObject` que:

- Expone 8 propiedades `@Published` (inputs: `urlString`, `outputType`, `selectorCSS`, `timeout`; outputs: `isExtracting`, `resultContent`, `errorMessage`, `isPythonPathError`)
- Implementa `extract()` con los contratos D-06, D-07, D-09, D-12
- Delega la llamada de red a `PythonBridge.run(url:outputType:selector:timeout:)` mediante `Task.detached(priority: .userInitiated)`
- Convierte el caso `ExtractionError.pythonNotFound` en `isPythonPathError = true` para que la View muestre el hint de Preferencias

## Criterios de aceptación verificados

| # | Criterio | Resultado |
|---|----------|-----------|
| 1 | Archivo existe en `ViewModels/ExtractionViewModel.swift` | PASS |
| 2 | `grep -c "@Published"` devuelve 8 | PASS (8) |
| 3 | `grep "@Observable"` devuelve 0 | PASS (0) |
| 4 | `grep "Task.detached"` devuelve ≥1 | PASS (1) |
| 5 | `xcodebuild ... build` → BUILD SUCCEEDED | PASS |

## Desviaciones del plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] import Combine requerido por toolchain**

- **Encontrado durante:** Task 2 — primera compilación
- **Error:** `static subscript 'subscript(_enclosingInstance:wrapped:storage:)' is not available due to missing import of defining module 'Combine'`
- **Contexto:** El plan indica explícitamente "No importar Combine — @Published no lo requiere en SwiftUI desde Swift 5.7+". Sin embargo, el proyecto compila con SDK macOS 26.5 / Xcode 26.5 (objectVersion = 77, MACOSX_DEPLOYMENT_TARGET = 26.5 en build settings del proyecto) donde el compilador exige el import explícito.
- **Fix:** Se añadió `import Combine` como primer import del archivo.
- **Archivos modificados:** `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift`
- **Commit:** 5d9a082

**2. [Informativo] pbxproj no modificado**

- El plan contemplaba modificar `project.pbxproj` con xcodeproj gem. El proyecto usa `PBXFileSystemSynchronizedRootGroup` (Xcode 16+ folder sync), por lo que Xcode detecta automáticamente cualquier archivo Swift añadido al directorio `ExtractorApp/`. No fue necesario modificar el pbxproj.
- xcodeproj gem (1.27.0) estaba disponible pero resultó innecesario.

## Commit

`5d9a082` — `feat(04-01): crea ExtractionViewModel con ObservableObject y extract()`

## Self-Check: PASSED

- `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/ExtractionViewModel.swift` — FOUND
- Commit `5d9a082` — FOUND en git log
- BUILD SUCCEEDED — verificado
