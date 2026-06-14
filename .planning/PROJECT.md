# extractor-url

## What This Is

Utilidad local en Python para extraer contenido legible desde una URL y devolverlo como texto limpio, HTML o Markdown, con una app macOS nativa en SwiftUI que lanza el motor Python vía subprocess y exporta el resultado. Orientado a uso personal en macOS: fidelidad de extracción, flujo simple y evolución sin dependencias de servicios externos.

## Core Value

Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.

## Requirements

### Validated

- ✓ Extracción local de texto, HTML y Markdown desde URL con `requests`, `BeautifulSoup`, `trafilatura` y `markdownify`.
- ✓ REQ-01: El conversor Markdown tiene cobertura automatizada con fixtures HTML locales. — Validated in Phase 1
- ✓ REQ-02: La extracción maneja limpieza DOM, URLs relativas y selector CSS sin regresiones. — Validated in Phase 1
- ✓ REQ-03: La documentación técnica principal refleja el estado real del proyecto. — Validated in Phase 1
- ✓ REQ-04: La GUI funciona sin URL, tanto sin argumentos como con `--gui`. — Validated in Phase 2
- ✓ REQ-05: Los fallos de guardado y selector CSS son explícitos. — Validated in Phase 2
- ✓ REQ-06: La CLI pública y sus caminos de error principales tienen tests. — Validated in Phase 2
- ✓ BRIDGE-01: PythonBridge llama al CLI con `--json`, captura stdout/stderr async sin deadlock. — Validated in Phase 3
- ✓ BRIDGE-02: Si Python no está en la ruta configurada, el error tipado se propaga. — Validated in Phase 3
- ✓ SETTINGS-01: El usuario puede configurar rutas al intérprete y al script desde Preferencias. — Validated in Phase 3
- ✓ SETTINGS-02: La app avisa si alguna ruta no es ejecutable (validación reactiva). — Validated in Phase 3
- ✓ SETTINGS-03: El usuario puede verificar la versión Python desde Preferencias. — Validated in Phase 3
- ✓ APP-01: Campo URL + picker de tipo + botón Extraer con estado visual de progreso. — Validated in Phase 4
- ✓ APP-02: ProgressView visible durante extracción, ventana responde a eventos. — Validated in Phase 4
- ✓ APP-03: Error de extracción visible inline con mensaje descriptivo. — Validated in Phase 4
- ✓ UI-01: Selector CSS y timeout configurables antes de extraer. — Validated in Phase 4
- ✓ UI-02: Preview WKWebView del contenido extraído. — Validated in Phase 5
- ✓ EXPORT-01: Export a Markdown (.md) vía NSSavePanel. — Validated in Phase 5
- ✓ EXPORT-02: Export a HTML autocontenido (CSS/JS inline). — Validated in Phase 5
- ✓ EXPORT-04: Export a PDF vectorial (WKWebView.pdf, texto seleccionable). — Validated in Phase 6
- ✓ APP-04: Universal binary arm64+x86_64, deployment target macOS 13.0. — Validated in Phase 7
- ✓ APP-05: Hardened Runtime ON, App Sandbox OFF. — Validated in Phase 7

### Active (v3.0)

- [ ] BUNDLE-01: El .app incluye un intérprete Python universal (arm64+x86_64) en `Contents/Resources/`.
- [ ] BUNDLE-02: El .app incluye `extractor_url.py` y `core.py` en `Contents/Resources/scripts/`.
- [ ] BUNDLE-03: Las dependencias Python (`requests`, `beautifulsoup4`, `lxml`, `markdownify`, `trafilatura`) van vendorizadas en el bundle.
- [ ] BRIDGE-05: PythonBridge detecta las rutas del bundle vía `Bundle.main.resourcePath` sin configuración del usuario.
- [ ] BRIDGE-06: PythonBridge usa rutas del bundle por defecto; acepta override de `UserDefaults` si existen y son válidas.
- [ ] UX-01: La app extrae contenido en el primer lanzamiento sin que el usuario configure nada.
- [ ] UX-02: SettingsView muestra "Usando Python incluido (vX.X)" cuando opera con el bundle.
- [ ] UX-03: SettingsView mantiene override opcional de rutas para uso avanzado.

### Out of Scope

- App Store o distribución comercial — no es el objetivo.
- Soporte páginas JavaScript (Playwright / WKWebView headless) — v4+.
- Historial de extracciones y cola — v4+.
- Notarización para distribución a terceros — v3 es uso personal.

## Context

El proyecto tiene dos capas: el motor Python (`core.py` + `extractor_url.py`) y la app nativa SwiftUI (`ExtractorApp/`). La app lanza el motor vía `Foundation.Process()` con `--json`. v3.0 elimina la dependencia del usuario de instalar Python y configurar rutas: el runtime y las dependencias van dentro del `.app bundle`.

## Current Milestone: v3.0 Standalone App

**Goal:** La app funciona al abrir sin ninguna configuración — Python, dependencias y script van dentro del `.app` bundle.

**Target features:**

- Python runtime universal (arm64+x86_64) embebido en `Contents/Resources/`
- `extractor_url.py`, `core.py` y dependencias vendorizadas dentro del bundle
- PythonBridge detecta rutas del bundle automáticamente vía `Bundle.main.resourcePath`
- SettingsView: "Usando Python incluido (vX.X)" — sin configuración obligatoria de rutas
- Primera apertura funciona de inmediato — zero-config experience

## Current State

Milestone v1.0 (Stabilization) completado: suite `pytest` con 14 tests, pylint 10/10, contratos CLI explícitos.
Milestone v2.0 (SwiftUI Native App) completado: app macOS nativa, bridge Python async, export MD/HTML/PDF, universal binary, UI premium con dark mode automático.
Milestone v3.0 en planificación: bundling del runtime Python para eliminar la configuración de rutas.

## Constraints

- **Tech stack**: Python 3 con `core.py` y `extractor_url.py`; SwiftUI + Foundation para la app.
- **Testing**: Sin dependencias de webs reales — usar fixtures HTML locales y mocks.
- **Platform**: macOS 13.0+ — universal binary arm64+x86_64.
- **Bundle size**: Python embebido añade ~30-60 MB al bundle — aceptable para uso personal.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Separar motor e interfaces | Mantiene `core.py` reutilizable y desacoplado de CLI/GUI | ✓ Good |
| Priorizar tests antes que nuevas features | Evita regresiones sobre el pipeline Markdown | ✓ Good |
| Usar GSD mínimo para la fase 1 | Permite ejecutar workflows sin inventar planificación pesada | ✓ Good |
| `pytest tests/` desde raíz con `conftest.py` | Resuelve el gap sin instalar en modo editable | ✓ Good |
| Priorizar robustez CLI antes de empaquetado | Corrige primero contratos visibles al usuario | ✓ Good |
| Fallar ante selector CSS inválido | Evita ampliar silenciosamente el alcance de extracción | ✓ Good |
| Bridge vía `Foundation.Process()` con `--json` | Motor Python sin modificar; Swift gestiona UI y filesystem | ✓ Good |
| Export PDF vía `WKWebView.pdf(configuration:)` | Vectorial, texto seleccionable, sin PDFKit | ✓ Good |
| App Sandbox OFF, Hardened Runtime ON | Correcto para herramienta personal fuera del App Store | ✓ Good |
| Colores semánticos del sistema (no hex hardcodeado) | Dark mode automático sin lógica extra | ✓ Good |
| [v3.0] python-build-standalone como runtime embebido | Distribución portable sin dependencias del sistema, universal binary | Pending |

## Evolution

Este documento evoluciona en transiciones de fase y límites de milestone.

**Después de cada fase:** mover requirements validados a Validated, añadir decisiones a Key Decisions.
**Después de cada milestone:** revisar Core Value, auditar Out of Scope, actualizar Context.

---
*Last updated: 2026-06-14 — Milestone v3.0 started*
