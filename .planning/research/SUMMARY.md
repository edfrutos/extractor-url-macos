# Research Summary: extractor-url v2.0 SwiftUI Native App

**Synthesized:** 2026-06-10
**Confidence overall:** HIGH (todas las APIs verificadas contra documentación oficial Apple via Context7; contrato JSON verificado directamente de fuente Python)

---

## Executive Summary

extractor-url v2.0 añade una capa nativa SwiftUI sobre un CLI Python ya funcional. El patrón arquitectónico es una separación limpia: Swift gestiona toda la UI y el diálogo con el sistema de archivos; Python sigue siendo el motor de extracción sin modificaciones. El bridge es unidireccional (`Foundation.Process` → Python → JSON) y el contrato JSON ya está implementado en `extractor_url.py` (líneas 280-297), lo que elimina el riesgo de integración más frecuente en proyectos de este tipo.

La decisión de distribución (fuera del Mac App Store, sin sandbox) es correcta y no es una limitación: permite llamar a cualquier intérprete Python del sistema sin restricciones, encaja con el perfil de herramienta personal, y permite distribución directa via .dmg o GitHub Releases con notarización estándar. El stack es 100% Apple frameworks sin dependencias de terceros en Swift, lo que reduce la superficie de mantenimiento a cero en el lado nativo.

El riesgo técnico más alto no está en la implementación SwiftUI sino en la integración subprocess: el entorno PATH reducido de las apps GUI, el deadlock potencial en pipes, y el bloqueo del MainActor con `waitUntilExit()` son los tres fallos que más frecuentemente bloquean proyectos de este tipo. Los tres tienen prevención documentada y deben resolverse en la primera fase antes de tocar UI.

---

## Stack Additions

Frameworks Apple requeridos (sin paquetes de terceros):

| Framework / API | Rol | macOS mínimo |
|----------------|-----|--------------|
| `Foundation.Process` + `Pipe` | Subprocess bridge hacia Python CLI | 10.13 |
| `WebKit.WKWebView` via `NSViewRepresentable` | Preview HTML + base para PDF | 10.15 |
| `WKWebView.pdf(configuration:)` | PDF export async/await | **12.0** (driver del deployment target) |
| `AppKit.NSSavePanel` | Diálogos de guardado para PDF (raw Data) | 10.0 |
| `SwiftUI.fileExporter` | Diálogos de guardado para MD y HTML (FileDocument) | 12.0 |
| `SwiftUI.AppStorage` / `UserDefaults` | Persistencia de preferencias | 11.0 |
| `SwiftUI.Settings` scene | Ventana de preferencias (Cmd+,) | 11.0 |
| `Swift Concurrency` (`Task.detached`, `async/await`) | Subprocess fuera del MainActor | 12.0 completo |
| `Foundation.JSONDecoder` | Parseo del contrato JSON del CLI | 10.10 |

**Deployment target recomendado: macOS 13.0 (Ventura)**
Justificacion: `WKWebView.pdf(configuration:)` fuerza macOS 12+ como minimo absoluto; macOS 13 asegura Swift Concurrency sin limitaciones de backport y es el minimo razonable en 2026 para equipos de 2-3 anos.

**Universal Binary:** `ARCHS = $(ARCHS_STANDARD)` con `MACOSX_DEPLOYMENT_TARGET = 13.0` genera fat binary arm64+x86_64 automaticamente. Con deployment target macOS 13 no es necesario forzar `ARCHS` explicitamente (solo cambia a partir de macOS 27 deployment target segun Xcode 27 release notes).

**Entitlements:**
- `com.apple.security.app-sandbox` ausente o `false` -- requerido para `Process()` con rutas arbitrarias
- `com.apple.security.hardened-runtime` `true` -- requerido para notarizacion con Developer ID
- `com.apple.security.cs.allow-unsigned-executable-memory` `true` -- anadir si Python/trafilatura falla con SIGKILL bajo Hardened Runtime

**Descartado:** Swift Foundation Subprocess proposal (0007/0037) -- propuesta de evolucion, no API estable. Usar `Foundation.Process` clasico.

---

## Feature Table Stakes

### URL Input y Subprocess Bridge

**Table stakes (debe funcionar en v2.0):**
- Campo URL + Picker de tipo (Text/HTML/Markdown) + boton Extraer deshabilitado durante extraccion
- `ProgressView()` indeterminado visible durante los 5-30 segundos de extraccion -- sin el la app parece congelada
- Extraccion en background (`Task.detached`); UI completamente responsiva durante el proceso
- Errores inline (no modal) con texto de stderr formateado cuando el CLI retorna exit code != 0
- Cancelacion de extraccion en curso (`process.terminate()` + limpieza de estado)

**Differentiators (v2.0 si hay tiempo; v3 si no):**
- Panel de opciones avanzadas colapsable: selector CSS, timeout, no-cache
- Historial de URLs recientes via `UserDefaults`
- Drag-and-drop de URL sobre la ventana
- Atajo de teclado Cmd+Return para disparar extraccion

### Content Preview

**Table stakes:**
- Markdown renderizado visualmente (no texto raw) via `WKWebView` + marked.js inline (~50 KB)
- HTML renderizado en vista tipo navegador via `WKWebView`
- Scroll para contenido largo; placeholder "Sin contenido" cuando vacio

**Differentiators:** Toggle rendered/raw; syntax highlighting en bloques de codigo

### Markdown Export

**Table stakes:**
- Guardar string Markdown verbatim (sin transformacion) a archivo `.md`
- NSSavePanel / `.fileExporter` con nombre derivado del titulo de la pagina (sanitizado)
- Confirmacion breve tras guardado exitoso

**Differentiators:** "Abrir en Finder" post-guardado; copia al portapapeles

### Self-contained HTML Export

**Table stakes:**
- Archivo `.html` unico que abre correctamente en Safari/Chrome sin assets externos
- CSS inline (~60 lineas) con tipografia legible (max-width 720px, 16px base, line-height 1.7)
- Dark mode via `@media (prefers-color-scheme: dark)`
- Titulo original en `<title>` + `<h1>`; URL fuente en footer
- Codigo con monospace + fondo sutil; tablas con bordes

**Differentiators:** Seccion `@media print`; timestamp de extraccion en footer

**Nota:** Imagenes con rutas relativas quedaran rotas -- aceptable en v2.0 (scope: texto, no clonacion completa de pagina).

### PDF Export

**Table stakes:**
- PDF paginado guardado via `WKWebView.pdf(configuration:)` -- vectorial, texto seleccionable
- `NSSavePanel` con extension `.pdf` y nombre por defecto
- Boton de exportacion deshabilitado hasta que el contenido haya terminado de renderizarse en WKWebView (`didFinish` + tick adicional)

**Differentiators:** ninguno para v2.0

### Preferences

**Table stakes:**
- Ruta al interprete Python (auto-deteccion en primer arranque; fallback a 6 ubicaciones conocidas)
- Ruta a `extractor_url.py` (default: relativa al bundle dentro del repo)
- Boton "Probar conexion" que verifica `python --version` y `--help`
- Persistencia via `@AppStorage`; ventana via `Settings {}` scene (Cmd+,)

**Differentiators:** Directorio de exportacion por defecto; tipo de salida por defecto

### Anti-features (diferir o descartar)

| Anti-feature | Decision |
|---|---|
| Extraccion por lotes | v3+ -- multiplica complejidad de estado async |
| Editor Markdown integrado | Fuera de scope -- exportar y editar externamente |
| Safari Extension / Share Extension | v3+ -- entitlement y codebase separados |
| Imagenes incrustadas en HTML (base64) | Fuera de scope v2.0 -- anotar como gap en footer |
| Mac App Store | No -- incompatible con sandbox + subprocess |
| Sync / iCloud | v3+ -- no aporta valor en herramienta local |
| Historial persistente (Core Data) | v3+ -- UserDefaults suficiente para volumen personal |

---

## Architecture Decisions

### Estructura de repo

`ExtractorApp/` como sibling directo de `core.py` en la raiz del monorepo. El proyecto Xcode vive en `ExtractorApp/ExtractorApp.xcodeproj/`. Esta ubicacion mantiene el repo cohesionado, permite rutas relativas entre Xcode y los scripts Python, y no contamina los namespaces Python con assets Swift.

```
extractor-url/
+-- core.py                      (sin cambios)
+-- extractor_url.py             (sin cambios -- contrato JSON ya existe)
+-- tests/                       (sin cambios)
+-- .venv/
+-- ExtractorApp/                (nuevo -- Xcode project root)
|   +-- ExtractorApp.xcodeproj/
|   +-- ExtractorApp/
|       +-- ExtractorApp.swift   (@main)
|       +-- ContentView.swift
|       +-- ExtractionViewModel.swift  (@Observable)
|       +-- PythonBridge.swift   (Process() async wrapper)
|       +-- Models/ExtractionResult.swift  (Codable)
|       +-- Views/               (InputView, PreviewView, ExportView)
|       +-- Settings/SettingsView.swift
|       +-- Resources/ExtractorApp.entitlements
+-- .planning/
```

### Patron de estado: @Observable (no ObservableObject)

`@Observable` macro (Swift 5.9+) es la direccion oficial de Apple. Elimina `@Published` por propiedad; SwiftUI solo re-renderiza vistas que leen propiedades que realmente cambian. Un `ExtractionViewModel` por escena es suficiente -- sin coordinadores ni routers para una app de ventana unica.

Flujo: `@Observable ExtractionViewModel` -> `ExtractionResult?` -> `PreviewView` + `ExportView`

**Nota de compatibilidad:** Si hay problemas en runtime macOS 13, fallback a `@StateObject + ObservableObject`.

### App Sandbox: desactivado intencionalmente

`Process()` necesita llamar a interpretes Python en rutas arbitrarias del usuario. El sandbox lo impide. La app es para distribucion personal (no App Store). Decision: sandbox OFF, Hardened Runtime ON. Este es el patron correcto documentado por Apple para herramientas de desarrollador fuera del App Store.

### Contrato JSON: ya completo, no requiere cambios Python

El CLI Python ya implementa `--json` con el schema siguiente (verificado de fuente, lineas 280-297):

```
SUCCESS: { "status": "success", "url", "selector", "output_type", "char_count", "content" }
ERROR:   { "status": "error", "url", "error_message" }
```

El tipo Swift `ExtractionResult: Codable` mapea directamente este schema con `CodingKeys` para snake_case -> camelCase. No se toca Python en ninguna fase Swift.

### Estrategia de ruta Python (auto-deteccion)

Orden de resolucion en primer arranque:
1. `UserDefaults["pythonPath"]` si existe y es ejecutable
2. `<bundle>/../../../.venv/bin/python` (relativo al repo)
3. `~/.pyenv/shims/python`
4. `/opt/homebrew/bin/python3`
5. `/usr/local/bin/python3`
6. `/usr/bin/python3`

Si ninguno es valido: forzar apertura de `SettingsView` con alerta explicativa.

---

## Watch Out For

Pitfalls en orden de prioridad (criticos primero):

### 1. PATH reducido en apps GUI -- modules no encontrados (CRITICO, Fase 2.1)

Una app lanzada desde Finder/Dock hereda el PATH minimo de `launchd` (`/usr/bin:/bin:/usr/sbin:/sbin`). El interprete Python del venv existe, pero sus `site-packages` no estan en `PYTHONPATH` -> `ModuleNotFoundError` en tiempo de ejecucion.

**Prevencion:** Construir el entorno del proceso explicitamente -- nunca `process.environment = nil`. Anadir `VIRTUAL_ENV`, `PYTHONPATH` y el `bin/` del venv al `PATH` antes de llamar a `process.run()`. Alternativa mas simple: usar el ejecutable del venv directamente como `executableURL`.

### 2. Deadlock en Pipe cuando stdout y stderr se leen en secuencia (CRITICO, Fase 2.1)

El patron `readDataToEndOfFile()` secuencial provoca deadlock silencioso si stderr supera el buffer del kernel (~64 KB). `trafilatura` puede emitir warnings extensos.

**Prevencion:** Usar `readabilityHandler` asincrono para ambas pipes en paralelo. No usar `readDataToEndOfFile()` en secuencia sobre dos pipes al mismo tiempo.

### 3. `waitUntilExit()` en el MainActor congela la UI (CRITICO, Fase 2.1)

`Task {}` en SwiftUI hereda el `@MainActor` por defecto. `waitUntilExit()` dentro de ese Task bloquea el hilo principal -- ventana frozen, sin crash, dificil de diagnosticar.

**Prevencion:** Toda la logica de `Process().run()` + lectura de pipes va dentro de `Task.detached(priority: .userInitiated)`. Solo la actualizacion del ViewModel vuelve al MainActor.

### 4. PDF en blanco por llamada prematura a `createPDF()` (ALTO, Fase 2.4)

`webView(_:didFinish:)` se dispara cuando el DOM esta parseado, no cuando el layout esta completo. Llamar a `createPDF()` en ese instante produce PDF en blanco o parcial.

**Prevencion:** Delay minimo de 100ms tras `didFinish` antes de llamar a `createPDF()` (suficiente para HTML estatico sin JS externo). Deshabilitar el boton PDF hasta que `contentReady = true`.

### 5. Arquitectura venv != arquitectura del binario Universal (ALTO, Fase 2.1 + validacion 2.5)

Un venv creado bajo Rosetta (x86_64) puede fallar con `mach-o file is not for this architecture` al ejecutarse en arm64 nativo, especialmente para `lxml` y extensiones C.

**Prevencion:** Documentar en Preferencias que el venv debe crearse con Python nativo del Mac. Anadir verificacion de arquitectura en `PythonBridge` antes de la primera extraccion. Para CI: usar `/opt/homebrew/bin/python3` (Homebrew arm64).

---

## Phase Build Order

Las fases son dependientes en cadena estricta. No hay paralelismo util entre ellas.

```
Fase 2.1 JSON Bridge --> Fase 2.2 UI + Preview --> Fase 2.3 Export MD/HTML --> Fase 2.4 Export PDF --> Fase 2.5 Universal Binary
(fundacion)            (funcionalidad completa)   (valor anadido)              (complemento)           (distribucion)
```

### Fase 2.1 -- JSON Bridge + Path Resolution

**Deliverable:** `PythonBridge.swift`, `ExtractionResult.swift`, `ExtractionViewModel.swift` (logica de extraccion y errores), `SettingsView.swift` basico, tests de bridge con Process mock.
**Rationale:** Fundacion bloqueante. El contrato JSON ya existe en Python; puede comenzar inmediatamente.
**Pitfalls a resolver:** PATH/PYTHONPATH, Pipe deadlock, MainActor blocking, arch venv, entitlements sin sandbox, `terminationHandler` en hilo arbitrario, `currentDirectoryURL`.
**Criterio de exito:** `PythonBridge.run(url:type:)` devuelve `ExtractionResult` valido o lanza `ExtractionError` tipado en todos los escenarios. Verificado con tests sin red real.
**Necesita investigacion adicional:** No.

### Fase 2.2 -- UI de Extraccion + Preview

**Deliverable:** `ContentView.swift`, `InputView.swift`, `PreviewView.swift` (WKWebView), integracion `@Observable` completa, `ProgressView`, gestion de errores inline, boton Cancelar.
**Rationale:** Primera funcionalidad end-to-end visible. El preview WKWebView es prerequisito para PDF export.
**Pitfalls a resolver:** UI freeze (confirmacion), Task cancellation + `process.terminate()`, `WKWebView baseURL`.
**Necesita investigacion adicional:** No.

### Fase 2.3 -- Export Markdown y HTML

**Deliverable:** `ExportView.swift` con `.fileExporter` para `.md` y template HTML autocontenido con CSS inline.
**Rationale:** Dos exports de bajo riesgo que validan el pipeline completo sin complejidad de WKWebView.
**Pitfalls a resolver:** NSSavePanel race condition, UTType para `.md` en macOS 13.
**Necesita investigacion adicional:** Verificar empiricamente `UTType(filenameExtension: "md")` en macOS 13.

### Fase 2.4 -- Export PDF

**Deliverable:** Export PDF via `WKWebView.pdf(configuration:)` (async, macOS 12+), con control de timing post-`didFinish`.
**Rationale:** Ruta mas compleja; no desbloquea ninguna otra funcionalidad. Diferirla al final es seguro.
**Pitfalls a resolver:** Blank PDF timing (delay 100ms+), decision unica `createPDF` vs `printOperation`.
**Necesita investigacion adicional:** Si -- el delay de 100ms puede necesitar ajuste segun complejidad del HTML real. Probar con paginas largas antes de publicar.

### Fase 2.5 -- Universal Binary + Distribucion

**Deliverable:** Verificacion fat binary, firma con Developer ID, notarizacion, empaquetado .dmg.
**Pitfalls a resolver:** `ONLY_ACTIVE_ARCH = YES` en Debug (verificar con Release build + `lipo -archs`), `com.apple.security.cs.disable-library-validation` si extensiones C del venv no estan firmadas.
**Necesita investigacion adicional:** No -- proceso bien documentado.

---

## Open Questions

1. **`@Observable` en runtime macOS 13:** La macro `@Observable` se introdujo con Swift 5.9 / Xcode 15. El deployment target macOS 13 deberia soportarla, pero el comportamiento en runtime macOS 13 (vs macOS 14) necesita verificacion empirica. Si hay problemas: fallback a `@StateObject + ObservableObject`.

2. **Delay PDF en HTML del extractor:** El valor de 100ms para el delay post-`didFinish` es suficiente para HTML estatico simple. El HTML que genera `trafilatura`/`markdownify` puede incluir tablas complejas. Validar con paginas de produccion reales; puede necesitar 200-300ms.

3. **`allow-unsigned-executable-memory` realmente necesario:** Con Hardened Runtime activo, `trafilatura` y sus dependencias (regex con JIT) pueden requerir este entitlement. Verificar empiricamente: si Python muere con SIGKILL, anadirlo.

4. **Ruta del script en builds de distribucion:** En desarrollo, `extractor_url.py` esta relativo al repo. En una app distribuida a otro usuario, el script no estara en la ruta esperada. Decision pendiente: bundlear el script dentro del `.app` o requerir configuracion manual. Para uso personal (repo local) la ruta relativa al bundle funciona.

5. **`UTType` para Markdown en macOS 13:** `UTType(filenameExtension: "md")` puede devolver `nil` en macOS 13. Alternativa: `UTType.plainText` con extension forzada a `.md` via `nameFieldStringValue`. Verificar antes de la Fase 2.3.

---

## Confidence Assessment

| Area | Confianza | Notas |
|------|-----------|-------|
| Stack (frameworks, APIs, versiones) | HIGH | Todas las APIs verificadas via Context7 + Apple official docs. Firmas de metodos confirmadas. |
| Features (table stakes, diferenciadores) | HIGH | Basado en APIs verificadas. CSS baseline es estandar web sin dependencia Apple. |
| Architecture (@Observable, estructura repo, data flow) | HIGH | Contrato JSON verificado directamente de fuente Python (lineas 280-297). Patrones SwiftUI de docs oficiales. |
| Pitfalls (PATH, Pipe, MainActor, PDF timing, venv arch) | MEDIUM-HIGH | Patrones verificados con docs Apple + foros Apple Developer. MEDIUM en algunos porque el contenido completo de paginas Apple no siempre estuvo disponible, pero los patrones son consistentes y bien conocidos. |
| Distribucion / notarizacion | MEDIUM | Proceso conocido pero no verificado paso a paso en esta investigacion. Sin bloqueo para las fases de desarrollo. |

**Gaps:**
- Comportamiento exacto de `@Observable` en runtime macOS 13 -- requiere prueba empirica
- Necesidad real de `allow-unsigned-executable-memory` con las dependencias Python concretas -- requiere prueba
- Estrategia de empaquetado del script Python para distribucion a terceros -- decision de producto pendiente

---

## Sources Aggregated

- Foundation.Process: https://developer.apple.com/documentation/foundation/process (Context7, HIGH)
- Apple Developer Forums thread 690310 -- Process/NSTask pipe handling (MEDIUM)
- WKWebView.pdf: https://developer.apple.com/documentation/webkit/wkwebview/pdf%28configuration%3A%29 (Context7, HIGH)
- WKWebView.createPDF: https://developer.apple.com/documentation/webkit/wkwebview/createpdf (Context7, HIGH)
- WKNavigationDelegate.didFinish: https://developer.apple.com/documentation/webkit/wknavigationdelegate/webview(_:didfinish:) (Context7, HIGH)
- NSViewRepresentable: https://developer.apple.com/documentation/swiftui/nsviewrepresentable (Context7, HIGH)
- NSSavePanel: https://developer.apple.com/documentation/appkit/nssavepanel (Context7, HIGH)
- AppStorage: https://developer.apple.com/documentation/swiftui/appstorage (Context7, HIGH)
- Settings scene: https://developer.apple.com/documentation/swiftui/settings (Context7, HIGH)
- fileExporter: https://developer.apple.com/documentation/swiftui/view/fileexporter (Context7, HIGH)
- ImageRenderer: https://developer.apple.com/documentation/swiftui/imagerenderer (Context7, HIGH)
- @Observable: https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app (Context7, HIGH)
- Xcode 27 release notes ARCHS_STANDARD: https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes (Context7, HIGH)
- Notarizacion: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution (MEDIUM)
- Python contract: extractor_url.py lineas 280-297 -- verificado directamente (HIGH)
