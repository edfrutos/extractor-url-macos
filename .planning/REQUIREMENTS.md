# Requirements

## Validated (v1.0 — Stabilization)

- [x] REQ-01 — Añadir tests automatizados con fixtures HTML locales para el conversor.
- [x] REQ-02 — Verificar limpieza DOM, URLs relativas y selector CSS.
- [x] REQ-03 — Alinear la documentación técnica principal con la implementación real.
- [x] REQ-04 — Permitir `--gui` sin URL posicional y validar la URL solo en modo CLI.
- [x] REQ-05 — Propagar con exit code de error los fallos de guardado y los selectores CSS inválidos.
- [x] REQ-06 — Añadir pruebas sobre la interfaz pública CLI y sus caminos de error principales.

## Active (v2.0 — SwiftUI Native App)

### APP — Shell de la aplicación

- [x] **APP-01**: El usuario puede introducir una URL y lanzar la extracción desde la app SwiftUI.
- [x] **APP-02**: La app muestra un indicador de progreso indeterminado durante la extracción.
- [x] **APP-03**: La app muestra errores de extracción de forma explícita (alert o mensaje inline).
- [x] **APP-04**: La app compila como universal binary x86_64 + arm64, deployment target macOS 13.0.
- [x] **APP-05**: App Sandbox desactivado (herramienta personal, distribución fuera del App Store).

### BRIDGE — Puente Python subprocess

- [ ] **BRIDGE-01**: La app lanza el CLI Python vía `Foundation.Process()` con `--json` y captura stdout y stderr con `readabilityHandler` asíncrono.
- [ ] **BRIDGE-02**: La app decodifica el JSON de respuesta al modelo Swift `ExtractionResult` (`Codable`).
- [ ] **BRIDGE-03**: La extracción se ejecuta en `Task.detached` para no bloquear la UI.
- [ ] **BRIDGE-04**: Los errores del proceso (Python no encontrado, fallo de extracción, JSON inválido) se propagan y se muestran en la UI.

### SETTINGS — Preferencias

- [ ] **SETTINGS-01**: El usuario puede configurar la ruta al intérprete Python desde la pantalla de Preferencias (`Settings` scene).
- [ ] **SETTINGS-02**: El usuario puede configurar la ruta al script `extractor_url.py` desde Preferencias.
- [ ] **SETTINGS-03**: La app valida que las rutas configuradas son ejecutables y avisa si no lo son.

### UI — Interfaz de extracción

- [x] **UI-01**: El usuario puede configurar tipo de salida (text/html/markdown), selector CSS y timeout desde la UI.
- [x] **UI-02**: El usuario puede previsualizar el contenido extraído en un `WKWebView` (`NSViewRepresentable`).
- [x] **UI-03**: Los controles de exportación están deshabilitados hasta que la extracción completa y el DOM esté listo (`contentReady`).

### EXPORT — Exportación

- [x] **EXPORT-01**: El usuario selecciona el formato de salida (MD / HTML / PDF) con un selector antes de exportar.
- [x] **EXPORT-02**: El export `.md` guarda el contenido íntegro extraído sin transformaciones vía `NSSavePanel`.
- [x] **EXPORT-03**: El export `.html` genera un único archivo autocontenido con CSS inline (max-width, apple-system font, `@media (prefers-color-scheme: dark)`, `@media print`), legible en navegador sin dependencias externas.
- [x] **EXPORT-04**: El export PDF usa `WKWebView.pdf(configuration:)` (macOS 13+, async/await), con guarda de estado `contentReady` antes de invocar la API, y guarda el resultado vía `NSSavePanel`.

## Future Requirements

- Bundling del intérprete Python dentro del `.app` para distribución sin dependencias externas.
- Soporte para páginas JavaScript (Playwright).
- Flags `--no-images`, `--no-links`, `--clipboard`.
- Empaquetado `.app`, firma y notarización para distribución amplia.
- Tests automatizados de la app SwiftUI (XCTest / XCUITest).

## Out of Scope (v2.0)

- Mac App Store / notarización estricta — distribución personal, sin sandbox.
- Reimplementación del extractor en Swift — se reutiliza el CLI Python existente.
- Drag-and-drop de URLs — complejidad innecesaria para v2.0.
- Descarga de imágenes referenciadas — las URLs relativas de imágenes no se resuelven.
- Interfaz multiventana o soporte de pestañas — ventana única para v2.0.

## Traceability

| Requirement | Status | Implemented by |
|-------------|--------|----------------|
| REQ-01 | Complete | Phase 01 / Plan 01 |
| REQ-02 | Complete | Phase 01 / Plan 01 |
| REQ-03 | Complete | Phase 01 / Plan 01 |
| REQ-04 | Complete | Phase 02 |
| REQ-05 | Complete | Phase 02 |
| REQ-06 | Complete | Phase 02 |
| APP-01 | Active | Phase 04 |
| APP-02 | Active | Phase 04 |
| APP-03 | Active | Phase 04 |
| APP-04 | Complete | Phase 07 |
| APP-05 | Complete | Phase 07 |
| BRIDGE-01 | Active | Phase 03 |
| BRIDGE-02 | Active | Phase 03 |
| BRIDGE-03 | Active | Phase 03 |
| BRIDGE-04 | Active | Phase 03 |
| SETTINGS-01 | Active | Phase 03 |
| SETTINGS-02 | Active | Phase 03 |
| SETTINGS-03 | Active | Phase 03 |
| UI-01 | Active | Phase 04 |
| UI-02 | Complete | Phase 05 |
| UI-03 | Active | Phase 04 |
| EXPORT-01 | Complete | Phase 05 |
| EXPORT-02 | Complete | Phase 05 |
| EXPORT-03 | Complete | Phase 05 |
| EXPORT-04 | Complete | Phase 06 |

## Notes

- El contrato JSON del CLI Python (`--json`) ya está implementado — no se modifica Python para v2.0.
- App Sandbox desactivado intencionalmente: `Foundation.Process()` con rutas configurables requiere acceso irrestricto al sistema de archivos.
- `BRIDGE-01` es la dependencia bloqueante: todas las fases de UI y export dependen de que el bridge funcione correctamente.
