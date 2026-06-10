# Phase 3: Python Bridge y Preferencias — Context

**Gathered:** 2026-06-10
**Status:** Ready for planning
**Source:** Conversation context + milestone research synthesis

<domain>
## Phase Boundary

Esta fase establece el núcleo técnico sobre el que se construyen todas las fases posteriores: el bridge subprocess entre Swift y el CLI Python existente, y la pantalla de Preferencias que lo configura.

**Entrega concreta:**
- `PythonBridge.swift` — clase que lanza `extractor_url.py` vía `Foundation.Process()`, captura stdout/stderr con `readabilityHandler` asíncrono y decodifica el JSON de respuesta a `ExtractionResult`
- `ExtractionResult.swift` — modelo `Codable` que mapea la respuesta JSON del CLI
- `ExtractionError.swift` — enum tipado con los casos de error del bridge
- `SettingsView.swift` — pantalla de Preferencias con dos campos AppStorage: ruta al intérprete Python y ruta al script
- Configuración del proyecto Xcode: App Sandbox OFF, Hardened Runtime ON, deployment target macOS 13.0

**No pertenece a esta fase:** ninguna vista de extracción principal, ningún preview de contenido, ninguna exportación.

</domain>

<decisions>
## Implementation Decisions

### Xcode Project Setup
- El proyecto Xcode se crea en `ExtractorApp/` en la raíz del repo (sibling a `core.py` y `extractor_url.py`)
- Deployment target: **macOS 13.0**
- `ARCHS_STANDARD` cubre x86_64 + arm64 automáticamente con target macOS 13.0
- **App Sandbox: OFF** — `com.apple.security.app-sandbox = false` en el entitlement desde el principio. Sin esto, `Foundation.Process()` con rutas configurables por el usuario no puede ejecutarse.
- **Hardened Runtime: ON** — `com.apple.security.cs-hardened-runtime = true`. Necesario para distribución fuera del App Store sin notarización problemática.
- `allow-unsigned-executable-memory` se determina empíricamente al ejecutar el bridge por primera vez (trafilatura puede necesitarlo)

### Foundation.Process Bridge
- API: `Foundation.Process()` con `executableURL`, `arguments`, `Pipe` para stdout y stderr
- **readabilityHandler asíncrono en paralelo para stdout Y stderr** — nunca leer secuencialmente (deadlock cuando stderr llena buffer de 64 KB mientras stdout no ha terminado)
- Llamada al CLI: `python extractor_url.py {url} --type {type} --json [--selector {sel}] [--timeout {n}]`
- El proceso se lanza con `Task.detached(priority: .userInitiated)` — nunca `waitUntilExit()` desde `@MainActor`
- El entorno del proceso se construye explícitamente: `ProcessInfo.processInfo.environment` como base, luego se inyecta `VIRTUAL_ENV`, `PYTHONPATH` y el directorio `bin/` del venv en `PATH`. **No heredar el PATH de launchd** (no tiene `/opt/homebrew/bin` ni el venv)
- `process.currentDirectoryURL` se fija al directorio del script para que imports relativos funcionen

### ExtractionResult (Codable)
- Modelo Swift que mapea el JSON de `extractor_url.py --json`:
  ```
  status: "success" | "error"
  url: String
  selector: String? (opcional)
  output_type: String
  char_count: Int
  content: String (presente en success)
  error_message: String (presente en error)
  ```
- Se decodifica con `JSONDecoder()` sobre los datos de stdout
- El Python CLI no se modifica — el contrato JSON ya existe y es correcto

### Error Handling
- `ExtractionError` enum con casos:
  - `pythonNotFound(path: String)` — el ejecutable configurado no existe o no tiene permisos
  - `processLaunchFailed(underlying: Error)` — `process.run()` lanzó excepción
  - `extractionFailed(message: String)` — CLI devolvió `status: "error"`
  - `jsonDecodeFailed(underlying: Error)` — stdout no es JSON válido
  - `emptyOutput` — stdout vacío tras terminación normal
- Los errores se propagan al caller del bridge como `throws` — no se silencian

### SwiftUI Architecture
- Patrón: **`@Observable` macro** (Swift 5.9+, macOS 14+ en runtime). Para macOS 13 se usa `@StateObject + ObservableObject` como fallback si hay incompatibilidades en runtime.
- `ExtractorViewModel` (o `ExtractionViewModel`) es la clase `@Observable` que centraliza el estado: `isExtracting`, `result: ExtractionResult?`, `error: ExtractionError?`
- Las actualizaciones de estado al `ViewModel` siempre se hacen en `@MainActor` (`await MainActor.run { ... }`)

### Preferences / Settings
- **Settings scene** de SwiftUI (`Settings { SettingsView() }`) — no ventana separada
- Dos campos `@AppStorage`:
  - `pythonPath`: String — ruta al intérprete Python (ej. `/ruta/al/.venv/bin/python`)
  - `scriptPath`: String — ruta absoluta a `extractor_url.py`
- Valor por defecto sugerido: `.venv/bin/python` y `extractor_url.py` relativos al bundle (para desarrollo). El usuario los ajusta para producción.
- **Validación al guardar y al arrancar**: comprobar que la ruta existe (`FileManager.default.fileExists`) y que es ejecutable (`FileManager.default.isExecutable`). Si no, mostrar aviso en Preferencias (no alert bloqueante).
- Validación adicional: ejecutar `python --version` con el intérprete configurado y verificar salida — detecta arch mismatch (arm64/x86_64) y venv roto.

### Claude's Discretion
- Nombre exacto de las clases y structs Swift (PythonBridge vs ExtractorBridge, etc.)
- Si usar `actor` para el bridge o solo `Task.detached`
- Estructura exacta del Xcode project (grupos, targets)
- Tamaño del buffer acumulador para stdout (el agente elige según experiencia)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone Research
- `.planning/research/SUMMARY.md` — Síntesis completa: stack, features, arquitectura, pitfalls
- `.planning/research/ARCHITECTURE.md` — Estructura de proyecto, data flow, error states, fase build order
- `.planning/research/PITFALLS.md` — 16 pitfalls con código de prevención (críticos para esta fase: PATH env, Pipe deadlock, waitUntilExit en @MainActor, arch mismatch)
- `.planning/research/STACK.md` — APIs Apple verificadas, configuración Xcode, entitlements

### Project Context
- `.planning/REQUIREMENTS.md` — Requisitos BRIDGE-01–04, SETTINGS-01–03, APP-05
- `.planning/ROADMAP.md` — Fase 3 goal y success criteria
- `extractor_url.py` — Punto de entrada del CLI Python (ver argumentos y JSON output)
- `CLAUDE.md` — Guía de estilo del proyecto

### JSON Contract
El CLI Python con `--json` produce:
```json
{
  "status": "success",
  "url": "https://...",
  "selector": null,
  "output_type": "markdown",
  "char_count": 1234,
  "content": "# Título\n..."
}
```
En error: `{"status": "error", "error_message": "..."}` con exit code 1.

</canonical_refs>

<specifics>
## Specific Ideas

- El bridge debe tener un método de test que llame al CLI con una URL hardcoded y devuelva el resultado — permite verificar el bridge de forma aislada sin UI
- La validación de ruta en Preferencias debe mostrar un semáforo visual (✓ verde / ✗ rojo) en tiempo real según el usuario escribe
- Documentar en Preferencias que el venv debe ser creado con el Python nativo de la arquitectura del Mac (no Rosetta) para evitar arch mismatch en extensiones C

</specifics>

<deferred>
## Deferred Ideas

- Auto-detección de la ruta Python (pyenv, homebrew, system Python) — complejidad innecesaria para v2.0, mejor que el usuario configure manualmente
- XCTest para el bridge — diferido a milestone posterior (Future Requirements en REQUIREMENTS.md)
- `allow-unsigned-executable-memory` entitlement — se determina empíricamente en esta fase pero solo se añade si es necesario

</deferred>

---

*Phase: 03-python-bridge-y-preferencias*
*Context gathered: 2026-06-10 via conversation context synthesis*
