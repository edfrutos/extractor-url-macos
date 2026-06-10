# extractor-url

## What This Is

Utilidad local en Python para extraer contenido legible desde una URL y devolverlo como texto limpio, HTML o Markdown. El proyecto está orientado a uso personal en macOS y prioriza fidelidad de extracción, flujo simple CLI/GUI y facilidad de evolución.

## Core Value

Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.

## Requirements

### Validated

- ✓ Extracción local de texto, HTML y Markdown desde URL con `requests`, `BeautifulSoup`, `trafilatura` y `markdownify`.
- ✓ REQ-01: El conversor Markdown tiene cobertura automatizada con fixtures HTML locales. — Validated in Phase 1
- ✓ REQ-02: La extracción maneja limpieza DOM, URLs relativas y selector CSS sin regresiones en la base actual. — Validated in Phase 1
- ✓ REQ-03: La documentación técnica principal refleja el estado real actual del proyecto. — Validated in Phase 1
- ✓ REQ-04: La GUI funciona sin URL, tanto sin argumentos como con `--gui`. — Validated in Phase 2
- ✓ REQ-05: Los fallos de guardado y selector CSS son explícitos. — Validated in Phase 2
- ✓ REQ-06: La CLI pública y sus caminos de error principales tienen tests. — Validated in Phase 2

### Active

- Ninguno para el milestone de estabilización actual.

### Out of Scope

- App Store o distribución comercial — no es el objetivo actual.
- Reescritura completa a SwiftUI ahora — se pospone hasta estabilizar extractor y tests.

## Context

El proyecto separa el motor en `core.py` y las interfaces CLI/GUI en
`extractor_url.py`. La estabilización actual prioriza contratos explícitos,
tests deterministas y documentación fiable.

## Current Milestone: v2.0 SwiftUI Native App

**Goal:** Construir una app macOS nativa en SwiftUI que lanza el extractor Python existente vía subprocess y exporta el resultado íntegro a PDF, Markdown y HTML autocontenido.

**Target features:**

- UI SwiftUI: campo URL, selector de tipo, opciones avanzadas (selector CSS, timeout)
- Bridge Python: `Process()` llama al CLI con `--json`, rutas configurables en preferencias
- Preview del resultado extraído (título, URL, cuerpo)
- Export a Markdown (.md) — NSSavePanel
- Export a HTML autocontenido (único .html con CSS y JS inline)
- Export a PDF — WKWebView → NSPrintOperation → archivo PDF
- Universal binary — fat binary x86_64 + arm64

## Current State

Milestone v1.0 (Stabilization) completado: suite `pytest` con 14 tests, pylint 10/10, contratos CLI explícitos. Milestone v2.0 en definición: app nativa SwiftUI para macOS.

## Constraints

- **Tech stack**: Python 3 con `core.py` y `extractor_url.py`.
- **Testing**: Sin dependencias de webs reales — usar fixtures HTML locales y mocks.
- **Platform**: macOS — algunas mejoras futuras pueden apoyarse en utilidades nativas como `pbcopy`.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Separar motor e interfaces | Mantiene `core.py` reutilizable y desacoplado de CLI/GUI | ✓ Good |
| Priorizar tests antes que nuevas features | Evita regresiones sobre el pipeline Markdown ya mejorado | ✓ Good |
| Usar GSD mínimo para la fase 1 | Permite ejecutar workflows sin inventar una planificación pesada | ✓ Good |
| Hacer que `pytest tests/` funcione desde la raíz con `tests/conftest.py` | Resuelve el gap sin tocar la lógica funcional ni exigir instalación editable | ✓ Good |
| Priorizar robustez de CLI antes de empaquetado macOS | Corrige primero contratos visibles para usuario y automatización | ✓ Good |
| Fallar ante selector explícito inválido | Evita ampliar silenciosamente el alcance de extracción | ✓ Good |

---
*Last updated: 2026-06-09 after Phase 2 completion*
