---
phase: 09-bridge-autodeteccion
plan: 01
type: validation
---

# Validation Map — Phase 9: Bridge Auto-detección de Rutas

## Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest (integrado en Xcode) |
| Config file | `ExtractorApp.xcodeproj` — target `ExtractorAppTests` |
| Quick run | `Cmd+U` en Xcode |
| Full suite | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS'` |
| Only Phase 9 | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' -only-testing:ExtractorAppTests/PythonBridgeTests` |

## Phase Requirements → Test Map

| Req ID | Behavior esperado | Tipo | Test name | Archivo |
|--------|-------------------|------|-----------|---------|
| BRIDGE-05 | Bundle python detectado sin UserDefaults | unit | `testResolvedPathsFallsToBundleWhenUserDefaultsEmpty` | PythonBridgeTests.swift |
| BRIDGE-06 | Bundle script detectado sin UserDefaults | unit | `testResolvedPathsFallsToBundleWhenUserDefaultsEmpty` (cubre ambos) | PythonBridgeTests.swift |
| BRIDGE-07 | Override UserDefaults preferido si ambas rutas válidas | unit | `testRunUsesUserDefaultsOverride_whenBothPathsValid` | PythonBridgeTests.swift |
| BRIDGE-07 (fallback) | Override inválido → cae al bundle sin crashear | unit | `testRunFallsToBundleWhenUserDefaultsPathInvalid` | PythonBridgeTests.swift |

## Wave 0 Gaps (tests a crear en Task 2)

- [ ] `testResolvedPathsFallsToBundleWhenUserDefaultsEmpty` — BRIDGE-05, BRIDGE-06: verifica que con UserDefaults vacíos, `resolvedPaths()` devuelve nil y `run()` lanza `.pythonNotFound`
- [ ] `testRunUsesUserDefaultsOverride_whenBothPathsValid` — BRIDGE-07: verifica que con `/bin/sh` + script tmp válido, `run()` ejecuta el script y devuelve `ExtractionResult` con `status == "success"`
- [ ] `testRunFallsToBundleWhenUserDefaultsPathInvalid` — BRIDGE-07 fallback: verifica que con ruta inexistente en UserDefaults, `resolvedPaths()` devuelve nil y `run()` lanza `.pythonNotFound` (no `.extractionFailed`)

## Test Execution Order

```
Task 1 → xcodebuild build (smoke: compila sin errores)
Task 2 → xcodebuild test -only-testing:ExtractorAppTests/PythonBridgeTests (suite completa: 13/13)
```

## Pass Criteria

| Check | Comando | Resultado esperado |
|-------|---------|-------------------|
| Compila sin errores | `xcodebuild build -scheme ExtractorApp -destination 'platform=macOS' -quiet 2>&1 \| grep -E 'error:\|BUILD'` | `BUILD SUCCEEDED` |
| Suite completa verde | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' -only-testing:ExtractorAppTests/PythonBridgeTests -quiet 2>&1 \| grep -E 'passed\|failed'` | `13 tests passed, 0 failed` |
| resolvedPaths presente | `grep -c "resolvedPaths" ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift` | `>= 2` |
| PathSource presente | `grep -c "PathSource" ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift` | `>= 2` |
| 3 tests nuevos presentes | `grep -c "testResolvedPathsFallsToBundleWhenUserDefaultsEmpty\|testRunUsesUserDefaultsOverride_whenBothPathsValid\|testRunFallsToBundleWhenUserDefaultsPathInvalid" ExtractorApp/ExtractorApp/ExtractorAppTests/PythonBridgeTests.swift` | `3` |

## Regression Guard

Los 10 tests previos de `PythonBridgeTests.swift` deben seguir pasando sin modificaciones. La suite BundlePathTests (7 tests) no se toca.

Total esperado tras Phase 9: **20 tests** (13 PythonBridgeTests + 7 BundlePathTests).
