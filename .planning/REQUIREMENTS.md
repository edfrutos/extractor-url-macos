# Requirements

## Validated (v1.0 — Stabilization)

- [x] REQ-01 — Añadir tests automatizados con fixtures HTML locales para el conversor.
- [x] REQ-02 — Verificar limpieza DOM, URLs relativas y selector CSS.
- [x] REQ-03 — Alinear la documentación técnica principal con la implementación real.
- [x] REQ-04 — Permitir `--gui` sin URL posicional y validar la URL solo en modo CLI.
- [x] REQ-05 — Propagar con exit code de error los fallos de guardado y los selectores CSS inválidos.
- [x] REQ-06 — Añadir pruebas sobre la interfaz pública CLI y sus caminos de error principales.

## Validated (v2.0 — SwiftUI Native App)

### APP — Shell de la aplicación

- [x] **APP-01**: El usuario puede introducir una URL y lanzar la extracción desde la app SwiftUI. — Phase 04
- [x] **APP-02**: La app muestra un indicador de progreso indeterminado durante la extracción. — Phase 04
- [x] **APP-03**: La app muestra errores de extracción de forma explícita (mensaje inline). — Phase 04
- [x] **APP-04**: La app compila como universal binary x86_64 + arm64, deployment target macOS 13.0. — Phase 07
- [x] **APP-05**: App Sandbox desactivado (herramienta personal, distribución fuera del App Store). — Phase 07

### BRIDGE — Puente Python subprocess

- [x] **BRIDGE-01**: La app lanza el CLI Python vía `Foundation.Process()` con `--json` y captura stdout/stderr con `readabilityHandler` asíncrono. — Phase 03
- [x] **BRIDGE-02**: La app decodifica el JSON de respuesta al modelo Swift `ExtractionResult` (`Codable`). — Phase 03
- [x] **BRIDGE-03**: La extracción se ejecuta en `Task.detached` para no bloquear la UI. — Phase 03
- [x] **BRIDGE-04**: Los errores (Python no encontrado, fallo, JSON inválido) se propagan y muestran en la UI. — Phase 03

### SETTINGS — Preferencias

- [x] **SETTINGS-01**: El usuario puede configurar la ruta al intérprete Python desde Preferencias. — Phase 03
- [x] **SETTINGS-02**: El usuario puede configurar la ruta al script `extractor_url.py` desde Preferencias. — Phase 03
- [x] **SETTINGS-03**: La app valida que las rutas configuradas son ejecutables y avisa si no lo son. — Phase 03

### UI — Interfaz de extracción

- [x] **UI-01**: El usuario puede configurar tipo de salida (text/html/markdown), selector CSS y timeout. — Phase 04
- [x] **UI-02**: El usuario puede previsualizar el contenido extraído en un `WKWebView`. — Phase 05
- [x] **UI-03**: Los controles de exportación están deshabilitados hasta que `contentReady = true`. — Phase 04

### EXPORT — Exportación

- [x] **EXPORT-01**: El usuario selecciona el formato de salida (MD / HTML / PDF) antes de exportar. — Phase 05
- [x] **EXPORT-02**: El export `.md` guarda el contenido íntegro vía `NSSavePanel`. — Phase 05
- [x] **EXPORT-03**: El export `.html` genera un único archivo autocontenido con CSS inline. — Phase 05
- [x] **EXPORT-04**: El export PDF usa `WKWebView.pdf(configuration:)` (async, macOS 13+). — Phase 06

---

## Active (v3.0 — Standalone App)

### BUNDLE — Runtime embebido

- [ ] **BUNDLE-01**: El usuario puede abrir el `.app` en cualquier Mac (arm64 o x86_64, macOS 13+) y la app arranca sin instalar Python previamente.
- [ ] **BUNDLE-02**: El `.app` incluye `extractor_url.py` y `core.py` en `Contents/Resources/scripts/` accesibles vía `Bundle.main.resourcePath`.
- [ ] **BUNDLE-03**: Las dependencias Python (`requests`, `beautifulsoup4`, `lxml`, `markdownify`, `trafilatura`) están vendorizadas en el bundle e importables sin `pip install` del usuario.

### BRIDGE — Auto-detección de rutas

- [ ] **BRIDGE-05**: PythonBridge detecta la ruta del intérprete bundleado vía `Bundle.main.resourcePath` y la usa por defecto sin leer `UserDefaults`.
- [ ] **BRIDGE-06**: PythonBridge detecta la ruta del script bundleado vía `Bundle.main.resourcePath` y la usa por defecto.
- [ ] **BRIDGE-07**: Si `UserDefaults` contiene rutas válidas (override manual), PythonBridge las prefiere sobre las del bundle — compatibilidad con configuración preexistente de v2.0.

### UX — Zero-config experience

- [ ] **UX-01**: El usuario introduce una URL y pulsa Extraer en el primer lanzamiento — la extracción funciona sin haber abierto Preferencias.
- [ ] **UX-02**: SettingsView muestra una fila informativa "Usando Python incluido (Python X.X.X)" cuando opera con el runtime del bundle.
- [ ] **UX-03**: SettingsView mantiene los campos de override de rutas como sección opcional para uso avanzado.

---

## Future Requirements

- Soporte páginas JavaScript / SPAs (Playwright o WKWebView headless) — v4+
- Historial y cola de extracciones — v4+
- Notarización y distribución a terceros — v4+
- Actualización automática del runtime Python bundleado — v4+
- Flags `--no-images`, `--no-links`, `--clipboard` — v4+

## Out of Scope (v3.0)

- **App Store / notarización**: sin sandbox; uso personal sin distribución pública en v3.
- **Múltiples versiones Python**: un único runtime bundleado, sin gestor de versiones.
- **Actualización automática**: el bundle se regenera con cada build de Xcode.
- **Reimplementación del extractor en Swift**: se reutiliza el CLI Python existente.

---

## Traceability

| Requirement | Milestone | Status | Phase / Plan |
|-------------|-----------|--------|--------------|
| REQ-01…06 | v1.0 | ✅ Complete | Phases 01-02 |
| APP-01…05 | v2.0 | ✅ Complete | Phases 03-07 |
| BRIDGE-01…04 | v2.0 | ✅ Complete | Phase 03 |
| SETTINGS-01…03 | v2.0 | ✅ Complete | Phase 03 |
| UI-01…03 | v2.0 | ✅ Complete | Phases 04-05 |
| EXPORT-01…04 | v2.0 | ✅ Complete | Phases 05-06 |
| BUNDLE-01…03 | v3.0 | ⬜ Pending | Phase 08 |
| BRIDGE-05…07 | v3.0 | ⬜ Pending | Phase 09 |
| UX-01…03 | v3.0 | ⬜ Pending | Phase 10 |

## Notes

- `BUNDLE-01` es la dependencia bloqueante de v3.0: sin el runtime embebido, BRIDGE-05/06 y UX-01 no pueden implementarse.
- App Sandbox OFF se mantiene — simplifica el bundling (sin entitlements adicionales para subprocess con binario embebido).
- La distribución `python-build-standalone` (Gregory Szorc) es el candidato preferido: portable, sin deps del sistema, universal binary disponible.
