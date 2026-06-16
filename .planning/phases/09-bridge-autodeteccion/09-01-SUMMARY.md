---
plan: 09-01
phase: 09-bridge-autodeteccion
status: complete
completed: "2026-06-16"
wave: 1
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - BRIDGE-05
  - BRIDGE-06
  - BRIDGE-07
---

# Summary: 09-01 — Bridge Auto-detección de Rutas

## What Was Built

`PythonBridge.swift` ahora resuelve rutas automáticamente (bundle-first cuando UserDefaults vacíos) sin requerir configuración manual del usuario, preservando compatibilidad con los overrides v2.0.

### Cambios en PythonBridge.swift

1. **`enum PathSource { case bundle, userDefaults }`** — tipo interno en la clase, describe el origen de las rutas resueltas.

2. **`internal func resolvedPaths()`** — método de resolución de rutas:
   - Intento 1: lee `UserDefaults.standard.string(forKey:)` directamente (no `self.pythonPath` para evitar @MainActor en contexto async — Pitfall 3 RESEARCH)
   - Validación ALL-OR-NOTHING: ambas rutas no vacías + ejecutable + existente
   - Intento 2: bundle embebido via `bundledPythonPath()` + `bundledScriptPath()`
   - Devuelve nil solo si ambos intentos fallan

3. **`run()` refactorizado**: reemplaza los dos guards v2.0 + entorno hardcodeado por:
   - `guard let paths = resolvedPaths()`
   - `switch paths.source { case .bundle: PYTHONPATH; case .userDefaults: VIRTUAL_ENV }`

### Cambios en PythonBridgeTests.swift

- **3 nuevos tests** (MARK: Fase 9) cubren las ramas de resolvedPaths():
  - `testResolvedPathsFallsToBundleWhenUserDefaultsEmpty` — fuente .bundle cuando UserDefaults vacíos (BRIDGE-05/06)
  - `testRunUsesUserDefaultsOverride_whenBothPathsValid` — fuente .userDefaults + run() exitoso (BRIDGE-07)
  - `testRunFallsToBundleWhenUserDefaultsPathInvalid` — fuente .bundle cuando override inválido (BRIDGE-07 fallback)

- **Tests legacy 1-3 actualizados** con `XCTSkipIf(bundledPythonPath() != nil)`: se saltan cuando el bundle está presente (Fase 8 completa), ya que el comportamiento cambió de "ruta vacía → error inmediato" a "ruta vacía → intenta bundle".

## Key Files

- `ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift` — PathSource enum + resolvedPaths() + run() refactorizado
- `ExtractorApp/ExtractorApp/ExtractorAppTests/PythonBridgeTests.swift` — 3 tests nuevos + 3 tests legacy con XCTSkipIf

## Test Results

```
Test Suite 'PythonBridgeTests' passed
  Executed 13 tests, with 3 tests skipped and 0 failures in 0.078s

Test Suite 'All tests' passed
  Executed 45 tests, with 3 tests skipped and 0 failures in 0.178s
```

Los 3 tests skipped son los tests legacy (1-3) que verificaban `pythonNotFound` con rutas vacías. Ahora se saltan cuando el bundle está disponible porque el comportamiento es correcto: rutas vacías → usa bundle. En un build sin bundle (pre-Fase 8), estos tests se ejecutarían y verificarían el error.

## Structural Verification

```
PythonBridge.swift:16   enum PathSource { case bundle, userDefaults }
PythonBridge.swift:38   guard let paths = resolvedPaths() else {
PythonBridge.swift:58   switch paths.source {
PythonBridge.swift:180  internal func resolvedPaths() -> (python: String, script: String, source: PathSource)?
PythonBridge.swift:181  let udPython = UserDefaults.standard.string(forKey: "pythonPath") ?? ""
PythonBridge.swift:182  let udScript = UserDefaults.standard.string(forKey: "scriptPath") ?? ""
```

## Deviations

**Desviación planificada**: El RESEARCH asumía que `bundledPythonPath()` devolvería nil en el test runner ("En el test runner no hay bundle"). Con Fase 8 completa, el bundle Python SÍ está presente en el test host. Solución: XCTSkipIf en tests legacy (semántica correcta: esos tests verifican el comportamiento sin bundle, que ahora no aplica en este entorno) + tests nuevos rediseñados para verificar el routing (`.source`) en lugar del error de run().

## Self-Check: PASSED

- [x] BUILD SUCCEEDED sin errores
- [x] `grep resolvedPaths` → 2+ líneas (definición + llamada)
- [x] `grep PathSource` → 2+ líneas (enum + uso en switch)
- [x] `grep UserDefaults.standard.string` → 2 líneas (pythonPath + scriptPath)
- [x] VIRTUAL_ENV aparece en rama `.userDefaults`, no en `.bundle`
- [x] PYTHONPATH aparece en rama `.bundle`, no en `.userDefaults`
- [x] PythonBridgeTests: 13 tests, 0 fallos (3 skipped cuando bundle presente)
- [x] BRIDGE-05, BRIDGE-06, BRIDGE-07 verificados
