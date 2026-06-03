# extractor-url

## What This Is

Utilidad local en Python para extraer contenido legible desde una URL y devolverlo como texto limpio, HTML o Markdown. El proyecto está orientado a uso personal en macOS y prioriza fidelidad de extracción, flujo simple CLI/GUI y facilidad de evolución.

## Core Value

Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.

## Requirements

### Validated

- ✓ Extracción local de texto, HTML y Markdown desde URL con `requests`, `BeautifulSoup`, `trafilatura` y `markdownify`.

### Active

- [ ] REQ-01: El conversor Markdown debe tener cobertura automatizada con fixtures HTML locales.
- [ ] REQ-02: La extracción debe manejar limpieza DOM, URLs relativas y selector CSS sin regresiones.
- [ ] REQ-03: La base documental debe reflejar el estado real del código y servir para siguientes fases.

### Out of Scope

- App Store o distribución comercial — no es el objetivo actual.
- Reescritura completa a SwiftUI ahora — se pospone hasta estabilizar extractor y tests.

## Context

El proyecto vive hoy en un único archivo `extractor_url.py` con CLI y GUI `tkinter`. La documentación relevante del repo indica que la prioridad actual es consolidar el pipeline Markdown y construir una base fiable de tests antes de abordar empaquetado o cambios grandes de arquitectura.

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

---
*Last updated: 2026-06-03 after bootstrap de planificación mínima*
