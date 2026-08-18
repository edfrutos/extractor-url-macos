# Phase 9: Bridge Auto-detección de Rutas — Research

**Researched:** 2026-06-16
**Domain:** Swift / Foundation — PythonBridge path resolution, UserDefaults override, XCTest mocking
**Confidence:** HIGH

---

## User Constraints (from CONTEXT.md)

No existe CONTEXT.md para esta fase. Las decisiones relevantes proceden de PROJECT.md y STATE.md:

### Locked Decisions (desde v3.0 planning)
- Python bundled en `Contents/Resources/python/bin/python3.13` (universal binary arm64+x86_64).
- Scripts en `Contents/Resources/scripts/extractor_url.py` y `core.py`.
- `PYTHONPATH` env var apunta a `Contents/Resources/python/lib/python-packages/` (no .pth file).
- App Sandbox OFF — no hay entitlements adicionales que afecten a subprocess.
- SettingsView mantiene override de rutas para uso avanzado — no se elimina (se hace opcional en Fase 10).

### Claude's Discretion
- Estructura interna del método `resolvedPaths()` en PythonBridge.
- Estrategia de testeo de las tres ramas (bundle / override válido / override inválido).
- Orden de preferencia en la lógica de resolución (UserDefaults-first cuando override válido).

### Deferred Ideas (OUT OF SCOPE — Fase 10)
- Badge "Usando Python incluido (Python X.X.X)" en SettingsView.
- Colapsar la sección de override como sección avanzada en SettingsView.
- Comportamiento UX del primer lanzamiento (UX-01).

---

## Summary

PythonBridge.swift actualmente lee las rutas al intérprete y al script vía `@AppStorage("pythonPath")` y `@AppStorage("scriptPath")`, lo que exige configuración manual por parte del usuario (comportamiento v2.0). La Fase 8 ya añadió la extensión `bundledPythonPath()` / `bundledScriptPath()` / `bundledVendoredLibPath()` como métodos estáticos que resuelven las rutas desde `Bundle.main.resourcePath`, pero `run()` todavía no los usa.

Esta fase conecta esa infraestructura: modifica `run()` para que resuelva las rutas dinámicamente con la lógica de prioridad correcta (UserDefaults-first cuando el override es válido y ejecutable, bundle como fallback), y añade los tests XCTest que cubren las tres ramas exigidas por los criterios de éxito de BRIDGE-07.

El cambio es quirúrgico: un método privado `resolvedPaths()` que encapsula la lógica de selección de rutas, sin tocar el resto del pipeline de subprocess (IOCollector, readabilityHandler, timeout). SettingsView y SettingsViewModel no necesitan modificación en esta fase.

**Primary recommendation:** Introducir `resolvedPaths() -> (python: String, script: String)?` como método de instancia en PythonBridge que implementa la prioridad UserDefaults-first / bundle-fallback, y reemplazar los dos guards de validación al inicio de `run()` por una llamada a ese método.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Resolución de rutas al intérprete | PythonBridge (Services) | — | Es responsabilidad del bridge, no de la UI ni del ViewModel |
| Lectura de UserDefaults (override) | PythonBridge (Services) | SettingsViewModel (ya lo hace para UI) | El bridge necesita leer directamente para no depender del ViewModel |
| Validación de ejecutabilidad de ruta | PythonBridge (Services) | — | Ya lo hace en `run()` — se refactoriza a `resolvedPaths()` |
| Configuración de PYTHONPATH en env | PythonBridge.run() | — | Debe variar según si se usa bundle o override (ver sección Pitfall 3) |
| Tests de las 3 ramas | PythonBridgeTests (XCTest) | — | Tests de unidad sin dependencia del bundle real |

---

## Análisis del Estado Actual del Código

### PythonBridge.swift — situación exacta

**Instancia en ExtractionViewModel (línea 36):**
```swift
private let bridge = PythonBridge()
```
PythonBridge es una clase `final` (no un actor), instanciada una sola vez. `run()` es `async throws`.

**Propiedades en la clase (líneas 13-14):**
```swift
@AppStorage("pythonPath") var pythonPath: String = ""
@AppStorage("scriptPath") var scriptPath: String = ""
```
Estas propiedades se pueden leer desde cualquier hilo (UserDefaults es thread-safe). La validación actual en `run()` (líneas 36-43) hace dos guards sobre ellas.

**Métodos bundled ya disponibles (extensión, líneas 167-195):**
- `static func bundledPythonPath() -> String?` — devuelve nil si no ejecutable
- `static func bundledScriptPath() -> String?` — devuelve nil si no existe
- `static func bundledVendoredLibPath() -> String?` — siempre devuelve ruta construida

**Configuración de entorno en `run()` (líneas 58-65) — PROBLEMA PENDIENTE:**
```swift
let scriptDir = URL(fileURLWithPath: scriptPath)
    .deletingLastPathComponent().path
let venvBin = scriptDir + "/.venv/bin"
var env = ProcessInfo.processInfo.environment
env["VIRTUAL_ENV"] = scriptDir + "/.venv"
env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
```
Este bloque asume que el script vive junto a un `.venv/`. Con el bundle, el entorno debe ser diferente: `PYTHONPATH` apunta a `python-packages/`, sin `.venv`. Ver Pitfall 3.

### SettingsViewModel — sin modificación necesaria

SettingsViewModel usa `@AppStorage("pythonPath")` y `@AppStorage("scriptPath")` solo para la UI de Preferencias. PythonBridge puede leer las mismas claves de UserDefaults directamente (ambos comparten el mismo UserDefaults.standard). No hay acoplamiento que romper.

### PythonBridgeTests — patrón de test existente

Los tests actuales (PythonBridgeTests.swift) instancian `PythonBridge()` y sobrescriben `bridge.pythonPath` y `bridge.scriptPath` directamente. Este patrón funciona porque las propiedades `@AppStorage` son `var` accesibles públicamente — se pueden inyectar desde los tests sin mock del UserDefaults.

Los nuevos tests para la Fase 9 pueden seguir el mismo patrón:
- Rama bundle: `bridge.pythonPath = ""` + `bridge.scriptPath = ""` (simula instalación limpia)
- Rama override válido: `bridge.pythonPath = "/bin/sh"` + `bridge.scriptPath = <tmp_file>` (ejecutable real + script existente)
- Rama override inválido: `bridge.pythonPath = "/ruta/inexistente"` + `bridge.scriptPath = ""` (fallback al bundle)

---

## Standard Stack

No se instalan dependencias externas. Esta fase modifica únicamente código Swift existente.

| Componente | Versión | Propósito | Estado |
|------------|---------|-----------|--------|
| Foundation.UserDefaults | macOS 13+ | Leer override de rutas | Ya en uso |
| Foundation.FileManager | macOS 13+ | Validar ejecutabilidad | Ya en uso |
| Foundation.Bundle | macOS 13+ | Resolver resourcePath | Ya en uso (extensión Fase 8) |
| XCTest | Xcode 15+ | Tests de las 3 ramas | Ya en uso |

## Package Legitimacy Audit

No aplica — esta fase no instala paquetes externos.

---

## Architecture Patterns

### Diagrama de flujo — resolución de rutas en run()

```
run() llamado
     │
     ▼
resolvedPaths()
     │
     ├─► ¿pythonPath (UserDefaults) no vacío
     │   Y FileManager.isExecutable?
     │         │
     │         ├─ SÍ ─► ¿scriptPath (UserDefaults) existe?
     │         │               │
     │         │               ├─ SÍ ─► usar (pythonPath, scriptPath) — override v2.0
     │         │               │
     │         │               └─ NO ─► caer a bundle (override de python sin script)
     │         │
     │         └─ NO ─► caer a bundle
     │
     ├─► bundledPythonPath() != nil
     │   Y bundledScriptPath() != nil?
     │         │
     │         ├─ SÍ ─► usar rutas bundle
     │         │
     │         └─ NO ─► return nil → throw ExtractionError.pythonNotFound
     │
     ▼
run() configura entorno según origen de rutas:
  • bundle  → PYTHONPATH = bundledVendoredLibPath(), sin VIRTUAL_ENV
  • override → VIRTUAL_ENV + PATH (comportamiento v2.0 actual)
```

### Patrón recomendado — resolvedPaths()

```swift
// MARK: - Path Resolution (Fase 9)

/// Resuelve las rutas al intérprete Python y al script con prioridad:
/// 1. UserDefaults (override manual del usuario) si ambas rutas son válidas.
/// 2. Bundle bundled como fallback.
///
/// - Returns: Tupla (python, script) o nil si ninguna fuente tiene rutas válidas.
private func resolvedPaths() -> (python: String, script: String, source: PathSource)? {
    // -- Intento 1: override de UserDefaults --
    let ud = UserDefaults.standard
    let udPython = ud.string(forKey: "pythonPath") ?? ""
    let udScript  = ud.string(forKey: "scriptPath") ?? ""

    if !udPython.isEmpty,
       FileManager.default.isExecutableFile(atPath: udPython),
       !udScript.isEmpty,
       FileManager.default.fileExists(atPath: udScript) {
        return (udPython, udScript, .userDefaults)
    }

    // -- Intento 2: bundle --
    if let bPython = Self.bundledPythonPath(),
       let bScript = Self.bundledScriptPath() {
        return (bPython, bScript, .bundle)
    }

    return nil
}

enum PathSource { case userDefaults, bundle }
```

**Nota de diseño:** Usar `UserDefaults.standard.string(forKey:)` en lugar de `self.pythonPath` (propiedad `@AppStorage`) evita la dependencia de `@MainActor` que impondría `@AppStorage` en un contexto async. `@AppStorage` en una clase que no es un actor es accesible desde cualquier hilo pero puede generar warnings en futuros compiladores. La lectura directa de `UserDefaults.standard` es explícita y thread-safe. [ASSUMED — basado en comportamiento documentado de UserDefaults; @AppStorage wrapping es un detalle de implementación de SwiftUI]

### Modificación de run() — bloque de configuración de entorno

Reemplazar los dos guards actuales + el bloque de entorno (líneas 36-65) por:

```swift
// -- Resolución de rutas ------------------------------------------
guard let paths = resolvedPaths() else {
    throw ExtractionError.pythonNotFound(path: "")
}
let pythonExec = paths.python
let scriptFile = paths.script

// -- Configurar proceso -------------------------------------------
let process = Process()
process.executableURL = URL(fileURLWithPath: pythonExec)

var arguments = [scriptFile, url, "--type", outputType, "--json"]
// ... (resto igual)

// -- Entorno según origen de rutas --------------------------------
var env = ProcessInfo.processInfo.environment
switch paths.source {
case .bundle:
    // Bundle: PYTHONPATH apunta a deps vendorizadas; sin .venv
    if let libPath = Self.bundledVendoredLibPath() {
        let existing = env["PYTHONPATH"] ?? ""
        env["PYTHONPATH"] = existing.isEmpty ? libPath : "\(libPath):\(existing)"
    }
    // Directorio de trabajo: carpeta del script bundled
    let scriptDir = URL(fileURLWithPath: scriptFile).deletingLastPathComponent().path
    process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)

case .userDefaults:
    // Override v2.0: comportamiento original con .venv
    let scriptDir = URL(fileURLWithPath: scriptFile).deletingLastPathComponent().path
    let venvBin = scriptDir + "/.venv/bin"
    env["VIRTUAL_ENV"] = scriptDir + "/.venv"
    env["PATH"] = venvBin + ":" + (env["PATH"] ?? "/usr/bin:/bin:/usr/local/bin")
    process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)
}
process.environment = env
```

### Estructura de archivos afectados

```
ExtractorApp/ExtractorApp/
├── ExtractorApp/Services/
│   └── PythonBridge.swift          ← MODIFICAR (añadir resolvedPaths() + PathSource + adaptar run())
└── ExtractorAppTests/
    └── PythonBridgeTests.swift     ← AMPLIAR (añadir 3 tests de ramas)
```

**Ningún otro archivo Swift requiere modificación en esta fase.**

---

## Don't Hand-Roll

| Problema | No construir | Usar en cambio | Por qué |
|----------|-------------|----------------|---------|
| Inyección de dependencias para tests | Mock complejo de UserDefaults / Bundle | Sobrescribir propiedades `@AppStorage` directamente en tests (patrón ya usado) | Los tests de Fase 3 ya validan que este patrón funciona — PythonBridgeTests.swift líneas 23-37 |
| Lógica de detección de arquitectura del binario | `lipo` en tiempo de ejecución | Confiar en que el bundle-python.sh ya produjo el universal binary | Responsabilidad de Fase 8; verificado en verify-bundle.sh |
| Thread-safety de UserDefaults | Locks propios | `UserDefaults.standard` (thread-safe por diseño de Foundation) | Documentado en Apple Developer Documentation |

---

## Common Pitfalls

### Pitfall 1: Condición de override parcial (python válido, script inválido)
**What goes wrong:** El usuario de v2.0 tiene `pythonPath` configurado pero `scriptPath` vacío o apuntando a una ruta que ya no existe. Si se usa el python del override con el script del bundle (mix), la ruta del script puede no ser importable correctamente.
**Why it happens:** La lógica de override se aplica por pares, no individualmente.
**How to avoid:** `resolvedPaths()` solo acepta el override si AMBAS rutas son válidas. Si falla una, caer al bundle completo. Nunca mezclar python de UserDefaults con script del bundle ni viceversa.
**Warning signs:** Tests de rama "override parcial" deben verificar que el resultado es bundle, no híbrido.

### Pitfall 2: PYTHONPATH incorrecto para el bundle
**What goes wrong:** Si `run()` aplica el bloque de entorno `.venv` cuando se usa el bundle, Python del bundle no encontrará las deps vendorizadas y fallará con `ModuleNotFoundError`.
**Why it happens:** El bloque de entorno actual (v2.0) asume siempre `.venv`. El bundle no tiene `.venv`.
**How to avoid:** El switch `paths.source` en el bloque de entorno es obligatorio — no compartir el mismo bloque de configuración de entorno para ambos casos.
**Warning signs:** `ExtractionError.extractionFailed` con mensaje que contiene "ModuleNotFoundError" o "No module named 'requests'".

### Pitfall 3: @AppStorage y acceso desde contexto async
**What goes wrong:** `@AppStorage` en una clase no-actor puede emitir warnings de concurrencia en Swift 6 si se accede desde un contexto `async` sin `@MainActor`.
**Why it happens:** `@AppStorage` es un property wrapper de SwiftUI que internamente usa `UserDefaults`, pero su wrapper añade observación de cambios que puede requerir `@MainActor`.
**How to avoid:** En `resolvedPaths()` leer `UserDefaults.standard.string(forKey:)` directamente en lugar de `self.pythonPath`. Esto es explícitamente thread-safe y evita el wrapper de SwiftUI.
**Warning signs:** Warnings del compilador "property wrapper 'AppStorage' cannot be used in a non-isolated context" al compilar con Swift 6 strict concurrency.

### Pitfall 4: Tests que dependen del bundle real
**What goes wrong:** `PythonBridge.bundledPythonPath()` devuelve nil en el test runner (Bundle.main.resourcePath apunta a los recursos del host de tests, no al .app de producción). Un test que espere `.bundle` y ejecute `run()` real fallará siempre en CI.
**Why it happens:** El bundle de producción solo existe en un build de Release/Debug del .app, no en el host de XCTest.
**How to avoid:** Los tests de las 3 ramas deben verificar la LÓGICA de selección de rutas, no ejecutar Python real. Para la rama bundle en tests: usar un script shell temporal como python falso (mismo patrón que testRunDecodesValidJSON) y simular bundled paths vía subclass o verificar solo el path selection sin llamar a run().
**Warning signs:** Tests que llaman a `bridge.run()` en la rama bundle sin un script temporal falso cuelgan o fallan con `pythonNotFound`.

### Pitfall 5: ExtractionError.pythonNotFound con path vacío
**What goes wrong:** Si `resolvedPaths()` devuelve nil porque ni UserDefaults ni bundle tienen rutas válidas, se lanza `ExtractionError.pythonNotFound(path: "")`. El mensaje de error en la UI queda vacío.
**Why it happens:** El caso "instalación limpia sin bundle compilado" produce path vacío.
**How to avoid:** Incluir un mensaje descriptivo: `throw ExtractionError.pythonNotFound(path: "bundle no disponible — recompila la app")`. O añadir un caso nuevo al enum si el planner lo considera apropiado.

---

## Estrategia de Tests para las 3 Ramas (BRIDGE-07)

Los tres criterios de éxito de Fase 9 mapean directamente a tres ramas de test:

### Rama 1 — Bundle por defecto (instalación limpia)
**Precondición:** `bridge.pythonPath = ""` y `bridge.scriptPath = ""`
**Qué verificar:** `resolvedPaths()` intenta primero UserDefaults (vacíos → skip) y luego bundle. En el entorno de test, `bundledPythonPath()` devuelve nil (no hay bundle compilado), por lo que `resolvedPaths()` devuelve nil y `run()` lanza `pythonNotFound`.
**Test:** Verificar que con ambas rutas vacías se lanza `pythonNotFound` (comportamiento ya cubierto por `testRunThrowsPythonNotFound_whenPythonPathIsEmpty`). Añadir test específico que verifica el mensaje de error contiene contexto de bundle.

**Alternativa para probar el path bundle real:** Usar un test que verifique directamente `resolvedPaths()` — para ello, hacer `resolvedPaths()` `internal` en lugar de `private` en el contexto de `@testable import`. [ASSUMED — decisión de visibilidad a confirmar con el planner]

### Rama 2 — Override válido (UserDefaults con rutas ejecutables)
**Precondición:** `bridge.pythonPath = "/bin/sh"` (ejecutable real) + `bridge.scriptPath = <tmp_script_que_imprime_JSON>`
**Qué verificar:** `resolvedPaths()` encuentra UserDefaults válidos y los usa; `run()` ejecuta el script tmp y devuelve `ExtractionResult`. Reutilizar el patrón de `testRunDecodesValidJSON_whenScriptOutputsSuccessJSON`.
**Test:** Nuevo test `testRunUsesUserDefaultsOverride_whenBothPathsValid`.

### Rama 3 — Override inválido con fallback al bundle
**Precondición:** `bridge.pythonPath = "/ruta/inexistente"` + `bridge.scriptPath = ""`
**Qué verificar:** `resolvedPaths()` rechaza el override (python no ejecutable) y cae al bundle. En el entorno de test, el bundle no está disponible, así que el resultado final es `pythonNotFound`.
**Test:** Nuevo test `testRunFallsToBundleWhenUserDefaultsPathInvalid` — verificar que se lanza `pythonNotFound` (el bundle no existe en el test runner) y NO `extractionFailed` ni otro error.

**Nota importante:** La lógica "fallback al bundle cuando el override es inválido" es verificable sin el bundle real porque el resultado observable es idéntico al de "instalación limpia" — se lanza `pythonNotFound`. Lo que confirma el test es que el override inválido NO bloquea ni lanza un error diferente.

---

## Impacto en SettingsView / SettingsViewModel

**SettingsView:** Sin cambios en esta fase. Los campos de override (`pythonPath`, `scriptPath`) siguen funcionando para la validación visual de la UI (PathValidationState). La Fase 10 añadirá el badge informativo.

**SettingsViewModel:** Sin cambios. Sigue usando `@AppStorage("pythonPath")` y `@AppStorage("scriptPath")` para binding bidireccional con la UI. PythonBridge lee las mismas claves de `UserDefaults.standard` de forma independiente.

**ExtractionViewModel:** Sin cambios. `private let bridge = PythonBridge()` sigue siendo la única instanciación. El nuevo comportamiento es transparente para el ViewModel.

**SettingsViewModelTests:** Sin cambios necesarios. Los tests existentes no testean PythonBridge directamente.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest (integrado en Xcode) |
| Config file | `ExtractorApp.xcodeproj` — target `ExtractorAppTests` |
| Quick run command | `Cmd+U` en Xcode o `xcodebuild test -scheme ExtractorApp` |
| Full suite command | `xcodebuild test -scheme ExtractorApp -destination 'platform=macOS'` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | Archivo Existe? |
|--------|----------|-----------|-------------------|-----------------|
| BRIDGE-05 | Bundle python detectado sin UserDefaults | unit | `xcodebuild test -only-testing:ExtractorAppTests/PythonBridgeTests/testRunFallsToBundleWhenUserDefaultsPathInvalid` | Parcialmente (nuevo test) |
| BRIDGE-06 | Bundle script detectado sin UserDefaults | unit | Mismo test que BRIDGE-05 (cubre ambos) | Parcialmente (nuevo test) |
| BRIDGE-07 | Override UserDefaults preferido si válido | unit | `xcodebuild test -only-testing:ExtractorAppTests/PythonBridgeTests/testRunUsesUserDefaultsOverride_whenBothPathsValid` | No — Wave 0 gap |

### Wave 0 Gaps
- [ ] `testRunUsesUserDefaultsOverride_whenBothPathsValid` — cubre BRIDGE-07 rama override válido
- [ ] `testRunFallsToBundleWhenUserDefaultsPathInvalid` — cubre BRIDGE-05/06 + BRIDGE-07 fallback

---

## Security Domain

Esta fase no introduce superficies de ataque nuevas. El subprocess ya existía; solo cambia el origen de las rutas.

| ASVS Category | Applies | Control |
|---------------|---------|---------|
| V5 Input Validation | Sí — las rutas resueltas se pasan a `Process.executableURL` | `FileManager.isExecutableFile` valida antes de usar |
| V4 Access Control | No — no hay cambio en permisos ni sandbox | App Sandbox OFF ya establecido |

**Riesgo específico:** Path traversal en rutas de UserDefaults. Mitigación existente: `FileManager.isExecutableFile(atPath:)` valida existencia y permisos antes de usar la ruta. No se interpola en strings de shell — se pasa como argumento tipado a `Process`.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Leer `UserDefaults.standard.string(forKey:)` directamente en lugar de `self.pythonPath` (@AppStorage) es equivalente y thread-safe en el contexto async de run() | Pitfall 3, resolvedPaths() pattern | Bajo — ambos acceden al mismo UserDefaults.standard; el wrapper @AppStorage añade observación de cambios pero no altera el valor almacenado |
| A2 | Hacer `resolvedPaths()` `internal` (en lugar de `private`) para que los tests puedan acceder directamente al resultado de selección de rutas | Estrategia de Tests Rama 1 | Bajo — decisión de visibilidad reversible; alternativa: probar via run() con scripts temporales |
| A3 | El entorno de test (XCTest host) tiene `Bundle.main.resourcePath` apuntando a los recursos del test runner, no al .app de producción, por lo que `bundledPythonPath()` devuelve nil en tests | Pitfall 4, Estrategia de Tests | Alto si incorrecto — los tests de rama bundle dependen de este supuesto para ser válidos. Verificado en BundlePathTests.swift comentario línea 8-9: "En el test runner, Bundle.main.resourcePath apunta a los recursos del host de tests, no al bundle de producción" [CITED: BundlePathTests.swift comentario del proyecto] |

---

## Open Questions (RESOLVED)

1. **Visibilidad de `resolvedPaths()`**
   - Lo que sabemos: el método necesita ser testeable; actualmente los tests de Fase 3 acceden a propiedades `@AppStorage` directamente.
   - Lo que era ambiguo: si `resolvedPaths()` debe ser `private` o `internal`.
   - **RESOLVED: `internal`** — ver 09-01-PLAN.md Task 1 action párrafo final. Los tests de las 3 ramas lo llaman directamente sin subclassing.

2. **Enum `PathSource` — alcance**
   - Lo que sabemos: `run()` necesita saber si usar `.venv` o `PYTHONPATH` para configurar el entorno.
   - Lo que era ambiguo: si `PathSource` debe ser `private` o `internal`.
   - **RESOLVED: `private` dentro de la clase** — ver 09-01-PLAN.md Task 1 action párrafo final. Los tests no inspeccionan `PathSource` directamente; verifican el comportamiento observable.

3. **Manejo de `ExtractionError.pythonNotFound(path:)` con path vacío**
   - Lo que sabemos: cuando ni UserDefaults ni bundle tienen rutas válidas, el `path:` asociado queda vacío.
   - Lo que era ambiguo: si enriquecer el mensaje o añadir caso nuevo al enum.
   - **RESOLVED: mantener enum existente, pasar `"(bundle no compilado)"` como path** — ver 09-01-PLAN.md Task 1 action, `guard let paths`. No se añaden casos nuevos al enum (responsabilidad de Fase 10).

---

## Sources

### Primary (HIGH confidence)
- `ExtractorApp/Services/PythonBridge.swift` — código real inspeccionado; estado actual de `run()`, `@AppStorage`, extensión bundle paths
- `ExtractorAppTests/BundlePathTests.swift` — confirma que `Bundle.main.resourcePath` en tests apunta al host de tests, no al bundle de producción (comentario explícito línea 8-9)
- `ExtractorAppTests/PythonBridgeTests.swift` — patrón de test con inyección de rutas via propiedad directa
- `.planning/phases/08-bundle-python-runtime/08-02-PLAN.md` — documentación de la estructura de directorios del bundle y decisión de separar Fase 8 (añadir métodos) de Fase 9 (conectar lógica)

### Secondary (MEDIUM confidence)
- `REQUIREMENTS.md` — BRIDGE-05, BRIDGE-06, BRIDGE-07 con criterios de éxito verbatim
- `ROADMAP.md` — dependencias de fase y success criteria

### Tertiary
- Comportamiento de `UserDefaults` thread-safety: [ASSUMED] basado en conocimiento de Foundation — Apple documenta thread-safety de UserDefaults.standard para operaciones de lectura/escritura.

---

## Metadata

**Confidence breakdown:**
- Análisis del código actual: HIGH — código inspeccionado directamente
- Patrón de resolución de rutas: HIGH — lógica deducida del código existente y los criterios de éxito
- Estrategia de tests: HIGH — patrón existente en PythonBridgeTests.swift es aplicable directamente
- Entorno Swift/UserDefaults thread-safety: MEDIUM-HIGH — comportamiento estable de Foundation

**Research date:** 2026-06-16
**Valid until:** 2026-07-16 (código Swift estable; sin dependencias externas)
