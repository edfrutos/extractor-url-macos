# Milestones

## v1.0 — Stabilization ✓ (2026-06-09)

**Goal:** Estabilizar el extractor y su CLI con tests deterministas y documentación fiable.

**Shipped:**
- Suite `pytest` con 14 tests y fixtures HTML locales
- Contratos CLI explícitos: `--gui` sin URL, exit codes de error, selector CSS inválido falla
- Pylint 10/10 en módulos de producción
- Documentación técnica alineada con la implementación real

**Phases:** 2 | **Requirements:** REQ-01 → REQ-06 (todos validados)

---

## v2.0 — SwiftUI Native App ✓ (2026-06-14)

**Goal:** Construir una app macOS nativa en SwiftUI que lanza el extractor Python vía subprocess y exporta el resultado a PDF, Markdown y HTML autocontenido.

**Shipped:**
- PythonBridge async con `readabilityHandler` paralelo (sin deadlock)
- SettingsView con validación reactiva de rutas y verificación de versión Python
- ContentView con UI premium, dark mode automático, LogoMark SVG
- Export MD + HTML autocontenido + PDF vectorial (`WKWebView.pdf`)
- Universal binary arm64+x86_64, deployment target macOS 13.0
- Hardened Runtime ON, App Sandbox OFF
- 21 tests unitarios (PythonBridge, SettingsViewModel, ExtractionViewModel)
- Assets de marca: logo SVG/PNG

**Phases:** 5 (03→07) | **Requirements:** BRIDGE-01→04, SETTINGS-01→03, APP-01→05, UI-01→03, EXPORT-01→04 (todos validados)

---

## v3.0 — Standalone App ✓ (2026-08-18)

**Goal:** La app funciona al abrir sin ninguna configuración — Python, dependencias y script van dentro del `.app` bundle.

**Shipped:**
- Runtime Python universal (arm64+x86_64, python-build-standalone) embebido en `Contents/Resources/python/`
- `extractor_url.py`, `core.py` y dependencias vendorizadas dentro del bundle, sin `pip install` del usuario
- `PythonBridge.resolvedPaths()`: auto-detección del bundle vía `Bundle.main.resourcePath`, con override `UserDefaults` opcional (compatibilidad v2.0)
- SettingsView: badge "Usando Python incluido (Python X.X.X)" + sección avanzada colapsable
- Checkpoint humano en Xcode: Build Succeeded, 49 tests (3 skipped esperados, 0 fallos), checklist visual completo

**Phases:** 3 (08→10) | **Requirements:** BUNDLE-01→03, BRIDGE-05→07, UX-01→03 (todos validados)

---

## v4.0 — Contenido Dinámico (JS) ✓ (2026-08-18)

**Goal:** El motor Python extrae contenido correctamente de páginas que dependen de JavaScript del lado del cliente (SPAs), cayendo a Playwright automáticamente solo cuando la extracción estática resulta insuficiente — sin tocar la app SwiftUI ni su bundle zero-config.

**Shipped:**
- `_looks_insufficient()`: heurística de texto visible (umbral 100 caracteres tras quitar `_NOISE_TAGS`) para detectar SPAs sin hidratar
- `_fetch_via_playwright()`: fallback a Chromium headless vía `playwright.sync_api`, con import perezoso y degradación en dos niveles (paquete ausente / browser ausente o timeout)
- Integración de 4 líneas en `_fetch_raw()` — sitios estáticos normales no pagan el coste de Playwright
- `tests/test_js_fallback.py`: 8 tests nuevos cubriendo las 4 ramas, sin depender de un browser real
- `requirements.txt` + `CLAUDE.md` documentan la nueva dependencia y su instalación en dos pasos

**Phases:** 1 (11) | **Requirements:** JS-01→04 (todos validados)
