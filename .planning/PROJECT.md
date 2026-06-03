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

### Active

- [ ] REQ-04: Permitir `--gui` sin URL posicional y validar la URL solo cuando haga falta en modo CLI.
- [ ] REQ-05: Hacer explícitos los errores de guardado y de selector CSS inválido, sin fallbacks silenciosos.
- [ ] REQ-06: Cubrir con tests la interfaz pública CLI y sus caminos de error principales.

### Out of Scope

- App Store o distribución comercial — no es el objetivo actual.
- Reescritura completa a SwiftUI ahora — se pospone hasta estabilizar extractor y tests.

## Context

El proyecto vive hoy en un único archivo `extractor_url.py` con CLI y GUI `tkinter`. La documentación relevante del repo indica que la prioridad actual es consolidar el pipeline Markdown y construir una base fiable de tests antes de abordar empaquetado o cambios grandes de arquitectura.

## Current State

Phase 1 complete: el proyecto dispone de una suite `pytest` local con fixtures HTML deterministas, el comando `pytest tests/ -q` funciona desde la raíz y la documentación principal quedó alineada con la implementación real.

La siguiente fase prioriza robustez de la CLI pública: corregir `--gui`, endurecer los códigos de salida en error y evitar ampliaciones silenciosas cuando falla un selector CSS explícito.

## Constraints

- **Tech stack**: Python 3 y archivo único — minimizar refactor estructural por ahora.
- **Testing**: Sin dependencias de webs reales — usar fixtures HTML locales y mocks.
- **Platform**: macOS — algunas mejoras futuras pueden apoyarse en utilidades nativas como `pbcopy`.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Mantener archivo único en esta fase | El coste de modularizar ahora no compensa frente a estabilizar el comportamiento | ✓ Good |
| Priorizar tests antes que nuevas features | Evita regresiones sobre el pipeline Markdown ya mejorado | ✓ Good |
| Usar GSD mínimo para la fase 1 | Permite ejecutar workflows sin inventar una planificación pesada | ✓ Good |
| Hacer que `pytest tests/` funcione desde la raíz con `tests/conftest.py` | Resuelve el gap sin tocar la lógica funcional ni exigir instalación editable | ✓ Good |
| Priorizar robustez de CLI antes de empaquetado macOS | Corrige primero contratos visibles para usuario y automatización | ✓ Good |

---
*Last updated: 2026-06-03 after Phase 1 completion*
