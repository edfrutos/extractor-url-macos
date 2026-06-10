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

## v2.0 — SwiftUI Native App 🔄 (en curso)

**Goal:** Construir una app macOS nativa en SwiftUI que lanza el extractor Python vía subprocess y exporta el resultado a PDF, Markdown y HTML autocontenido.
