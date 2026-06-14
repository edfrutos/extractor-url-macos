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

## v3.0 — Standalone App 🔄 (en curso)

**Goal:** La app funciona al abrir sin ninguna configuración — Python, dependencias y script van dentro del `.app` bundle.
