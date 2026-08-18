---
plan: 10-01
phase: 10-ux-zero-config
status: complete
completed: "2026-08-18"
tasks_completed: 5
tasks_total: 5
requirements_covered:
  - UX-01
  - UX-02
  - UX-03
---

# Summary: 10-01 — UX Zero-Config

## What Was Built

`SettingsView` ahora comunica el modo de operación real de `PythonBridge` en
vez de presentar un formulario de rutas vacío como si fuera obligatorio.

### PythonBridge.swift

- `enum PathSource` → `enum PathSource: Equatable` (ver "Bug encontrado en
  Fase 9" abajo).
- `static func bundledPythonVersion() -> String?` — ejecuta
  `--version` contra el intérprete bundleado y devuelve `"3.13.14"` (sin el
  prefijo `"Python "`). `nil` si no hay bundle o el proceso falla.
- `IOCollector` pasa de `nonisolated final class` con métodos `nonisolated`
  a `final class IOCollector: @unchecked Sendable` (ver "Bugs encontrados
  en el checkpoint" abajo).

### SettingsViewModel.swift

- `enum PythonOperatingMode: Equatable { case bundle(version: String?), override, unavailable }`
- `@Published private(set) var operatingMode` + `var isBundleMode: Bool`.
- `refreshOperatingMode()`: delega en `PythonBridge.resolvedPaths()` (la
  misma instancia/lógica que usa `run()`) para que el badge nunca se
  desincronice del comportamiento real de extracción. Se llama desde
  `init()` y desde los `didSet` de `pythonPath`/`scriptPath`.
- La resolución de versión (`bundledPythonVersion()`) es bloqueante, así que
  se ejecuta en `Task.detached` (no `Task {}` — ver "Bugs encontrados en el
  checkpoint" abajo).

### SettingsView.swift

- Nueva sección "Modo de operación" con `OperatingModeRow`: icono +
  título + subtítulo, coloreado por modo (verde `.bundle`, azul `.override`,
  naranja `.unavailable`).
- Las secciones de rutas/verificación/advertencias/ayuda pasan a vivir bajo
  `if advancedExpanded { ... }`, con una cabecera-botón "Configuración
  avanzada" que las expande/colapsa.
- `advancedExpanded` empieza en `false`; se fuerza a `true` una única vez en
  `.onAppear` si el modo inicial no es bundle (usuarios con override v2.0 ya
  configurado siguen viendo sus rutas sin un clic extra).

### SettingsViewModelTests.swift

4 tests nuevos bajo `MARK: - Fase 10: PythonOperatingMode`, todos
condicionados a `PythonBridge.bundledPythonPath()` igual que los tests de
Fase 9 (el bundle no existe en el host de XCTest salvo que Fase 8 ya se haya
ejecutado sobre ese checkout):

- `testOperatingMode_isOverride_whenUserDefaultsPathsAreValid`
- `testOperatingMode_isBundleOrUnavailable_whenUserDefaultsEmpty`
- `testOperatingMode_returnsToBundleOrUnavailable_whenOverrideCleared`
- `testOperatingMode_isOverride_notBundle_whenPartialOverrideCompletedAfterwards`

## Bug encontrado en Fase 9 (no introducido por esta fase)

`PythonBridgeTests.swift` (commit `b78632a`, Fase 9) llama
`XCTAssertEqual(paths.source, .bundle)` contra `enum PathSource { case bundle, userDefaults }`
declarado **sin** `: Equatable`. Se corrigió en Fase 10 (`enum PathSource: Equatable`)
porque Fase 10 también lo necesita para `PythonOperatingMode`. Confirmado con
el build real de este checkpoint: con `Equatable` declarado compila sin error.

## Bugs encontrados durante el checkpoint humano (2026-08-18)

El build inicial (código escrito sin Xcode disponible) tenía errores/avisos
reales, corregidos en esta sesión tras cada intento de build/test en Xcode:

1. **10 warnings de concurrencia** — "Capture of 'collector' with
   non-Sendable type 'IOCollector' in a '@Sendable' closure". El intento
   original de silenciarlos marcando la clase y sus métodos `nonisolated`
   no resolvía el problema (`nonisolated` no implica `Sendable`). Fix:
   `final class IOCollector: @unchecked Sendable` — el `NSLock` interno ya
   garantiza la seguridad de hilos real; `@unchecked` es correcto porque el
   compilador no puede verificar esa garantía a través del lock.
2. **`Cannot find 'nilCall' in scope`** — typo en
   `stderrPipe.fileHandleForReading.readabilityHandler = nilCall` (debía ser
   `nil`). Corregido.
3. **`No 'async' operations occur within 'await' expression`** — bug real,
   no solo cosmético: `refreshOperatingMode()` corre en `@MainActor`
   (`SettingsViewModel` está anotado `@MainActor`), y un `Task { }` normal
   *hereda* ese aislamiento. La llamada `await PythonBridge.bundledPythonVersion()`
   (función síncrona, no `async`) se estaba ejecutando en el hilo principal
   pese a que el comentario decía "se ejecuta fuera del hilo principal" —
   el subprocess bloqueante (`--version`) podía congelar la UI brevemente.
   Fix: `Task.detached { }` + eliminar el `await` inútil sobre la función
   síncrona.

Tras estos tres fixes, `Product → Build` (⌘B) da `Build Succeeded` sin
warnings de concurrencia.

## Verification Status — ✅ VERIFICADO (checkpoint humano 2026-08-18)

```
xcodebuild build          → Build Succeeded (0 warnings de Sendable/concurrencia tras fixes)
xcodebuild test (⌘U)      → Executed 49 tests, with 3 tests skipped and 0 failures
```

Desglose por suite:

| Suite | Resultado |
|-------|-----------|
| BundlePathTests | 7/7 passed |
| PythonBridgeTests | 13 ejecutados, 3 skipped (esperado — bundle presente, comportamiento correcto de fallback), 0 fallos |
| SettingsViewModelTests | 18/18 passed (incluye los 4 tests nuevos de Fase 10) |
| ViewModelTests | 11/11 passed |

Checklist visual (`TESTING-HUMANO.md` secciones 2-0 a 2D) — todo OK:

1. **2-0** — Instalación sin overrides: badge verde "Usando Python incluido
   (Python 3.13.14)" (versión real confirmada), sección avanzada colapsada.
2. **2B** — Ruta Python inválida en override: badge rojo "No encontrado" en
   el campo, badge de "Modo de operación" se mantiene en verde bundle.
3. **2C** — Override válido (venv + `extractor_url.py` reales del repo):
   badge cambia a azul "Usando configuración manual".
4. **2D** — Borrar el override: badge vuelve a verde "Usando Python incluido"
   sin reiniciar la app — criterio de éxito #4 de la Fase 10 confirmado.

## Self-Check

- [x] `PathSource: Equatable` — necesario para tests de Fase 9 y Fase 10
- [x] `PythonOperatingMode` cubre las 3 ramas de `resolvedPaths()`
- [x] `SettingsView` ya no presenta las rutas de override como flujo principal
- [x] 4 tests nuevos añadidos con el mismo patrón de branching que Fase 9
- [x] `xcodebuild build` — Build Succeeded (checkpoint humano 2026-08-18)
- [x] `xcodebuild test` — 49 tests, 3 skipped, 0 fallos
- [x] Checkpoint humano visual (TESTING-HUMANO.md) — completo, badge y transiciones OK
