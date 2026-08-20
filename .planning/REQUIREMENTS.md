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

## Validated (v3.0 — Standalone App)

### BUNDLE — Runtime embebido

- [x] **BUNDLE-01**: El usuario puede abrir el `.app` en cualquier Mac (arm64 o x86_64, macOS 13+) y la app arranca sin instalar Python previamente. — Phase 08
- [x] **BUNDLE-02**: El `.app` incluye `extractor_url.py` y `core.py` en `Contents/Resources/scripts/` accesibles vía `Bundle.main.resourcePath`. — Phase 08
- [x] **BUNDLE-03**: Las dependencias Python (`requests`, `beautifulsoup4`, `lxml`, `markdownify`, `trafilatura`) están vendorizadas en el bundle e importables sin `pip install` del usuario. — Phase 08

### BRIDGE — Auto-detección de rutas

- [x] **BRIDGE-05**: PythonBridge detecta la ruta del intérprete bundleado vía `Bundle.main.resourcePath` y la usa por defecto sin leer `UserDefaults`. — Phase 09
- [x] **BRIDGE-06**: PythonBridge detecta la ruta del script bundleado vía `Bundle.main.resourcePath` y la usa por defecto. — Phase 09
- [x] **BRIDGE-07**: Si `UserDefaults` contiene rutas válidas (override manual), PythonBridge las prefiere sobre las del bundle — compatibilidad con configuración preexistente de v2.0. — Phase 09

### UX — Zero-config experience

- [x] **UX-01**: El usuario introduce una URL y pulsa Extraer en el primer lanzamiento — la extracción funciona sin haber abierto Preferencias. — Phase 10
- [x] **UX-02**: SettingsView muestra una fila informativa "Usando Python incluido (Python X.X.X)" cuando opera con el runtime del bundle. — Phase 10
- [x] **UX-03**: SettingsView mantiene los campos de override de rutas como sección opcional para uso avanzado. — Phase 10

---

## Validated (v4.0 — Contenido Dinámico)

### JS — Fallback Playwright para SPAs

- [x] **JS-01**: `core.py` detecta heurísticamente cuando la extracción estática (`requests` + `BeautifulSoup`) devuelve contenido vacío o insuficiente. — Phase 11 (`_looks_insufficient()`, umbral 100 caracteres)
- [x] **JS-02**: Si se detecta contenido insuficiente, se reintenta automáticamente renderizando la página con Playwright (Chromium headless) antes de fallar. — Phase 11 (`_fetch_via_playwright()` + integración en `_fetch_raw()`)
- [x] **JS-03**: Si Playwright/Chromium no están instalados en el entorno activo (p.ej. el runtime embebido de la app v3.0, que no lo incluye), la extracción degrada al resultado estático con un aviso explícito — sin excepción no controlada. — Phase 11, verificado real (sin mockear) en un entorno sin Playwright instalado
- [x] **JS-04**: Tests cubren la heurística de detección y el camino de fallback con fixtures/mocks, sin exigir un navegador real para pasar en un entorno CI estándar. — Phase 11 (`tests/test_js_fallback.py`, 8 tests, suite completa 28/28)

---

## Future Requirements

- Notarización y distribución a terceros (App Store, web pública) — v7+
- Actualización automática del runtime Python bundleado — v7+
- Flags `--no-images`, `--no-links`, `--clipboard` — v7+
- Rollouts por fases de Sparkle (`sparkle:phasedRolloutInterval`) — v7+ si hay más usuarios

## Out of Scope (v4.0)

- **App Store / notarización**: uso personal, sin distribución pública.
- **App SwiftUI**: v4.0 es exclusivamente motor Python (CLI); la app no cambia ni bundlea Playwright.
- **Control manual del fallback**: sin flag `--js`/`--no-js` en v4 — solo detección automática.
- **Múltiples motores de rendering**: solo Playwright/Chromium, sin Selenium ni WKWebView headless.

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
| BUNDLE-01…03 | v3.0 | ✅ Complete | Phase 08 |
| BRIDGE-05…07 | v3.0 | ✅ Complete | Phase 09 |
| UX-01…03 | v3.0 | ✅ Complete | Phase 10 |
| JS-01…04 | v4.0 | ✅ Complete | Phase 11 |
| UPDATE-01…03 | v5.0 | ✅ Complete | Phase 12 |
| UPDATE-04…06 | v5.0 | ✅ Complete | Phase 13 |
| HIST-01…03 | v6.0 | ⬜ Pending | Phase 14 |
| FLAG-01…02 | v6.0 | ⬜ Pending | Phase 15 |
| CHANNEL-01…02 | v6.0 | ⬜ Pending | Phase 16 |
| BUNDLEJS-01…02 | v6.0 | ⬜ Pending | Phase 17 |
| POLISH-01…02 | v6.0 | ⬜ Pending | Phase 18 |

## Validated (v5.0 — Sparkle en la app)

### UPDATE — Integración Sparkle

- [x] **UPDATE-01**: Sparkle 2.x integrado en `ExtractorApp.xcodeproj` (paquete local, no remoto — ver desviación en `12-01-SUMMARY.md`). — Phase 12
- [x] **UPDATE-02**: `SPUStandardUpdaterController` inicializado, comprobación automática (24h) + ítem de menú manual "Buscar actualizaciones…" confirmado en checkpoint humano. — Phase 12
- [x] **UPDATE-03**: `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey` en Debug y Release — clave real desde Fase 13 (`pdjSqDBJV9/d5LtjgvRvAQ+FzR4V7K/Q2qCaF2Zjrlk=`). — Phase 12/13

### UPDATE — Pipeline de release

- [x] **UPDATE-04**: `scripts/release-macos.sh` automatiza build → firma Developer ID → notarización → generación de appcast → publicación en GitHub Releases. — Phase 13, release real v1.0 publicado
- [x] **UPDATE-05**: `appcast.xml` alojado en el propio repo (`raw.githubusercontent.com`); binarios como assets de GitHub Release. — Phase 13, verificado con curl en vivo
- [x] **UPDATE-06**: Documentación del proceso de release (`RELEASING.md`), incluida la gestión segura de la clave privada EdDSA y las credenciales de notarización. — Phase 13

---

## Active (v6.0 — Historial y Distribución Completa)

Orden fijado por el usuario: historial → flags → canales → bundle JS → pulido.

### HIST — Historial y cola de extracciones (Phase 14)

- [ ] **HIST-01**: `core.py`/`extractor_url.py` persiste un historial de extracciones (URL, fecha, formato, resultado/error) en almacenamiento local.
- [ ] **HIST-02**: La app SwiftUI muestra el historial y permite reabrir/reexportar una extracción previa sin repetirla.
- [ ] **HIST-03**: El usuario puede encolar varias URLs (CLI y/o app) y procesarlas secuencialmente sin intervención por cada una.

### FLAG — Control manual del fallback JS (Phase 15)

- [ ] **FLAG-01**: `--js` fuerza el fallback Playwright sin depender de `_looks_insufficient()`.
- [ ] **FLAG-02**: `--no-js` desactiva el fallback Playwright aunque la heurística lo activaría.

### CHANNEL — Canales beta de Sparkle (Phase 16)

- [ ] **CHANNEL-01**: `scripts/release-macos.sh` soporta publicar en el canal `beta` (`sparkle:channel`) sin afectar al canal por defecto.
- [ ] **CHANNEL-02**: La app puede optar al canal beta vía `SPUUpdaterDelegate.allowedChannelsForUpdater`.

### BUNDLEJS — Playwright embebido en el bundle (Phase 17)

- [ ] **BUNDLEJS-01**: El pipeline de bundling (Fase 8) vendoriza Playwright + Chromium dentro del `.app`, firmados y notarizables (Developer ID + hardened runtime en todos los binarios internos de Chromium).
- [ ] **BUNDLEJS-02**: El fallback JS del motor Python funciona en la app SwiftUI sin que el usuario instale Playwright por separado.

### POLISH — Pulido técnico (Phase 18)

- [ ] **POLISH-01**: `_bump_version` en `scripts/release-macos.sh` acota el `sed` a los bloques del target `ExtractorApp` únicamente.
- [ ] **POLISH-02**: Investigado y documentado el bug del buscador de paquetes de Xcode 26.6; Sparkle migrado a paquete remoto si se confirma resuelto.

## Out of Scope (v6.0)

- **App Store / notarización pública**: uso personal, sin distribución a terceros.
- **Rollouts por fases de Sparkle**: v6.0 cubre canales beta, no `phasedRolloutInterval` — v7+ si hay más usuarios.

## Notes

- App Sandbox OFF se mantiene — sin cambios de entitlements en v4 (la app SwiftUI no se toca).
- Playwright requiere `pip install playwright` + `playwright install chromium` — documentado en `CLAUDE.md` (sección Entorno).
- Umbral final de heurística: `_MIN_VISIBLE_TEXT_LENGTH = 100` (ajustado desde 200 durante la implementación por un falso positivo contra la fixture de test existente — ver `11-01-SUMMARY.md`).
- `UPDATE-01` es la dependencia bloqueante de v5.0: sin el paquete Sparkle añadido (paso humano en Xcode), ni `UPDATE-02` ni `UPDATE-03` pueden compilar, y `UPDATE-04..06` (Fase 13) no tienen nada real que firmar/publicar.
- La clave privada EdDSA de Sparkle NUNCA se commitea — vive en el Keychain del Mac que ejecuta `generate_keys`. Solo la clave pública (`SUPublicEDKey`) va en el repo.
