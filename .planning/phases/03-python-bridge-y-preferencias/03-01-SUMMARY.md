---
phase: "03"
plan: "01"
status: complete
completed: "2026-06-11"
---

# Summary: Plan 03-01 — Proyecto Xcode y modelos Swift

## Completado

- Proyecto Xcode creado en ExtractorApp/ExtractorApp/ con deployment target macOS 13.0, Hardened Runtime ON, App Sandbox OFF
- ExtractionResult.swift: struct Codable con CodingKeys que mapean output_type, char_count, error_message
- ExtractionError.swift: enum con 5 casos tipados (pythonNotFound, processLaunchFailed, extractionFailed, jsonDecodeFailed, emptyOutput)
- ContentView.swift: placeholder creado
- ExtractorApp.entitlements: com.apple.security.app-sandbox = false
- BUILD SUCCEEDED

## Incidencias

- Xcode no permite fusionar en carpetas existentes — se requirió mover la carpeta interior a _saved/, crear el proyecto limpio y restaurar los ficheros
- CODE_SIGN_ENTITLEMENTS tenía un \n literal al final — corregido directamente en project.pbxproj
- Xcode 16 usa PBXFileSystemSynchronizedRootGroup: los ficheros nuevos en disco se añaden automáticamente al proyecto sin pasos manuales
