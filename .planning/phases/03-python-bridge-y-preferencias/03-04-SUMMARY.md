---
phase: "03"
plan: "04"
subsystem: "SwiftUI UI Layer"
tags: [swiftui, macos, ui, semantic-colors, settings, accessibility]
dependency_graph:
  requires: ["03-03"]
  provides: ["ContentView-semantic-colors", "SettingsView-capsule-badges", "verifyConfiguration"]
  affects: ["ContentView.swift", "Views/SettingsView.swift"]
tech_stack:
  added: []
  patterns:
    - "Color(.windowBackgroundColor) / Color(.textBackgroundColor) / Color(.controlBackgroundColor) para dark mode automatico"
    - "RoundedRectangle fill + overlay stroke (patron macOS 13 compatible en lugar de fill().stroke() macOS 14+)"
    - "Capsule badges con fill color.opacity(0.15) para validacion visual"
    - "Process() + DispatchQueue.global para verificacion Python sin bloquear MainActor"
    - "Captura de @AppStorage fuera de closure Sendable para evitar warning de actor isolation"
key_files:
  created: []
  modified:
    - "ExtractorApp/ExtractorApp/ExtractorApp/ContentView.swift"
    - "ExtractorApp/ExtractorApp/ExtractorApp/Views/SettingsView.swift"
decisions:
  - "Usar Color.accentColor en LogoMark en lugar de gradiente hex hardcodeado — adapta al accent color del sistema"
  - "Patron fill+overlay en lugar de fill().stroke() — compatibilidad macOS 13.5 (deployment target)"
  - "verifyConfiguration() captura pythonPath antes del closure Sendable — elimina warning actor isolation"
  - "SettingsView mantiene @StateObject SettingsViewModel en lugar de @AppStorage directo — architecture de plan 03-02 preservada"
metrics:
  duration: "~10 minutos"
  completed: "2026-06-13"
  tasks_completed: 2
  tasks_total: 2
  files_modified: 2
---

# Phase 03 Plan 04: Rediseno visual premium de ContentView y SettingsView Summary

ContentView y SettingsView rediseñados con colores semanticos del sistema Apple y Capsule badges de validacion; BUILD SUCCEEDED sin errores, sin colores hex hardcodeados en ninguno de los dos ficheros.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | ContentView rediseno visual premium | f7c706f | ContentView.swift |
| 2 | SettingsView rediseno visual premium | 2f8b759 | Views/SettingsView.swift |

## What Was Built

### Task 1 — ContentView.swift

- **Fondo:** `Color(.windowBackgroundColor)` sustituye la logica `colorScheme == .dark ? surfaceDark : LinearGradient(hex...)` — invierte automaticamente en dark mode.
- **Zona URL:** HStack con icono "link" + TextField encapsulados en RoundedRectangle(cornerRadius: 10) con fill `Color(.textBackgroundColor)` y overlay stroke `secondary.opacity(0.3)` — compatible macOS 13.5.
- **Hero section:** fondo `Color(.controlBackgroundColor).opacity(0.6)` en lugar de `cardDark.opacity(0.6) / white.opacity(0.85)`.
- **Cards:** `Color(.controlBackgroundColor)` sustituye `cardBackground` (que era dark/light con hex).
- **Zona resultado:** RoundedRectangle con fill `Color(.controlBackgroundColor)` + `accessibilityElement(children: .contain)`.
- **Estado extrayendo (APP-02):** `VStack { ProgressView().scaleEffect(1.2); Text(...).font(.subheadline).foregroundStyle(.secondary) }`.
- **Estado error (APP-03):** `HStack(alignment: .top) { Image("exclamationmark.triangle.fill").font(.title3); VStack { Text("Error de extraccion").bold(); Text(errorMsg).caption } }` + `Button("Abrir Preferencias").buttonStyle(.link)`.
- **Boton Extraer:** `.buttonStyle(.borderedProminent)` — ya no hardcodea background color.
- **LogoMark:** usa `Color.accentColor` en lugar del gradiente `Color(red: 0.310...)`.
- **minHeight 480** (vs 500 anterior), padding horizontal 24 pt.

### Task 2 — SettingsView.swift

- **Titulo:** `Text("Preferencias").font(.title2).bold()` sobre el Form.
- **PathInputRow:** icono `chevron.right.2` + texto de ayuda `.caption2.tertiary` bajo el label.
- **validationBadge():** sustituye `ValidationIcon`. Para `.valid`: `Capsule().fill(green.opacity(0.15))` + `Label("OK", systemImage: "checkmark").caption2.green`. Para `.notFound`: `Capsule().fill(red.opacity(0.15))` + `Label("No encontrado", systemImage: "xmark").caption2.red`. `.empty` devuelve `EmptyView()`.
- **Seccion Verificacion:** `Button("Verificar configuracion")` + resultado monospaced; `ProgressView` durante verificacion.
- **verifyConfiguration():** `Process()` con `executableURL = pythonPath`, `arguments = ["--version"]`, en `DispatchQueue.global`. Captura `pythonPathCopy` antes del closure para evitar warning actor isolation (T-03-04-01: solo `--version`, sin args del usuario).
- **Seccion Ayuda:** texto + ejemplo monospaced + banner naranja condicional si rutas invalidas + helpRows.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Compatibilidad macOS 13.5 en RoundedRectangle**
- **Found during:** Task 1, primer build
- **Issue:** `.fill(_:style:).stroke(_:lineWidth:antialiased:)` encadenados en Shape son API macOS 14+; el deployment target es 13.5.
- **Fix:** Patron `background(Color).clipShape(shape).overlay(shape.stroke(...))` — compatible desde macOS 12.
- **Files modified:** ContentView.swift
- **Commit:** f7c706f (incluido en el mismo commit de tarea)

**2. [Rule 1 - Bug] `.accentColor` como ShapeStyle en foregroundStyle**
- **Found during:** Task 1, primer build
- **Issue:** `.foregroundStyle(.accentColor)` falla — `.accentColor` no conforma directamente a ShapeStyle en este contexto.
- **Fix:** `Color.accentColor` explicitamente tipado.
- **Files modified:** ContentView.swift
- **Commit:** f7c706f

**3. [Rule 1 - Bug] Actor isolation warning en verifyConfiguration()**
- **Found during:** Task 2, segundo build
- **Issue:** Acceso a `vm.pythonPath` (main actor-isolated) desde closure `Sendable` en `DispatchQueue.global`.
- **Fix:** `let pythonPathCopy = vm.pythonPath` capturado en el hilo principal antes de entrar en el closure.
- **Files modified:** Views/SettingsView.swift
- **Commit:** 2f8b759

### Architectural Notes

- `SettingsView` mantiene `@StateObject private var vm = SettingsViewModel()` (arquitectura establecida en plan 03-02) en lugar de `@AppStorage` directo. El plan 03-04 especificaba `@AppStorage` en la descripcion de contexto pero el artifact real ya usaba ViewModel; se preserva para no romper los tests de `SettingsViewModelTests.swift`.
- `LogoMark` se conserva en ContentView.swift (introducido en 03-03) con los hex dentro del Canvas reemplazados por `Color.accentColor`, cumpliendo el requisito de no hex hardcodeados.

## Threat Surface Scan

Ninguna superficie nueva no contemplada en el threat model. `verifyConfiguration()` ejecuta exclusivamente `--version` (T-03-04-01 mitigado). La salida de `python --version` se muestra en UI sin datos sensibles (T-03-04-02 aceptado).

## Known Stubs

Ninguno. Ambas vistas conectan directamente a ViewModels reales (`ExtractionViewModel`, `SettingsViewModel`).

## Self-Check: PASSED

- ContentView.swift: FOUND
- SettingsView.swift: FOUND
- 03-04-SUMMARY.md: FOUND
- Commit f7c706f (ContentView): FOUND
- Commit 2f8b759 (SettingsView): FOUND
