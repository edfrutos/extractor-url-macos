# PLAN.md — extractor-url

Plan de desarrollo parametrado y alineado con el estado real del repositorio.

## 1. Estado actual

### Qué existe ya

- **Herramienta Python modular**: `core.py` (lógica de extracción) y `extractor_url.py` (interfaces CLI/GUI).
- **Puente de comunicación JSON**: La CLI soporta `--json` para la comunicación con aplicaciones externas.
- **Interfaces disponibles**: CLI con `argparse` y GUI con `tkinter`.
- **Tipos de salida disponibles**: texto limpio, HTML completo, Markdown.
- **Pipeline Markdown implementado**: `trafilatura` como primera opción, `markdownify` como fallback.
- La GUI ya usa `threading` para no bloquear el hilo principal.

### Qué no existe todavía

- Cobertura de tests completa.
- Reintentos HTTP y timeout configurable por el usuario.
- Renderizado de JavaScript.
- Empaquetado `.app` para macOS.

## 2. Objetivo del plan

**Evolucionar `extractor-url` a una aplicación nativa de macOS (SwiftUI) de alto rendimiento.** La aplicación utilizará el motor de extracción de Python (`core.py`) como backend, comunicándose a través de una interfaz CLI basada en JSON. La fiabilidad y la calidad de la conversión a Markdown son las prioridades principales.

## 3. Parámetros de ejecución

Estos parámetros reflejan la decisión de priorizar una aplicación nativa.

| Parámetro | Valores sugeridos | Valor **actual** | Efecto |
|---|---|---|---|
| `objetivo_producto` | `cli_robusta`, `app_macos_mvp`, `app_macos_nativa` | **`app_macos_nativa`** | Cambia el alcance del roadmap |
| `horizonte` | `corrección`, `mvp`, `v1` | `v1` | Apunta a una versión completa |
| `soporte_js` | `no`, `opcional`, `si` | `opcional` | Se evaluará en fases posteriores |
| `prioridad_fidelidad_md` | `alta`, `media` | `alta` | Prioriza tests y calidad de conversión |
| `ui_objetivo` | `ninguna`, `tkinter`, `pywebview`, `swiftui` | **`swiftui`** | Define el objetivo final de la interfaz |
| `distribucion` | `uso_personal`, `distribucion_firmada` | `distribucion_firmada` | Implica firma de código y notarización |
| `tolerancia_refactor` | `minima`, `media`, `alta` | **`alta`** | Necesaria para la modularización |
| `nivel_testing` | `smoke`, `unitario`, `unitario_fixtures` | `unitario_fixtures` | Define el esfuerzo de validación |

## 4. Principios de implementación

- **Separación de Lógica y Presentación**: El motor de Python (`core.py`) debe permanecer agnóstico a la interfaz.
- **Comunicación Estructurada**: La comunicación entre el frontend (Swift) y el backend (Python) se realizará a través de la CLI con salida JSON.
- **Tests como Red de Seguridad**: Usar fixtures locales y `pytest` para validar el `core.py` antes de cualquier cambio.

## 5. Fases recomendadas

**Nota importante**: El objetivo del proyecto ha sido re-priorizado hacia una aplicación nativa de macOS. **El estado detallado, la justificación de las decisiones y el progreso de las fases se documentan en `NOTEBOOK.md`**.

Las fases a continuación se mantienen como una referencia general del trabajo pendiente.

### Fase 0.5 — Refactorización para UI Nativa (✅ COMPLETADA)

- **Descripción**: Se ha refactorizado el script monolítico en `core.py` (lógica) y `extractor_url.py` (interfaces). Se ha implementado la salida `--json` en la CLI.
- **Estado**: ✅ **COMPLETADA**. Ver `NOTEBOOK.md` para detalles.

### Fase 1 — Validación automática del conversor (⏳ PENDIENTE)

- **Objetivo**: Ampliar la base de tests para congelar el comportamiento actual y detectar regresiones.

### Fase 2 — Robustez de red y experiencia operativa (⏳ PENDIENTE)

- **Objetivo**: Reducir fallos evitables en la descarga y mejorar el manejo de errores.
- **Tareas**: Añadir reintentos HTTP, timeout configurable.

### Fase 3 — CLI más útil para uso diario (⏳ PENDIENTE)

- **Objetivo**: Mejorar la CLI para hacerla más flexible.
- **Tareas**: `--clipboard`, `--no-links`, `--no-images`.

### Fase 4 — UI nativa SwiftUI (v1.0) (⏳ PENDIENTE - SIGUIENTE)

- **Objetivo**: Construir la interfaz nativa en Xcode/SwiftUI.
- **Tareas**: Llamar al backend de Python, construir la vista, integrar con servicios de macOS.

## 6. Fuente de verdad del proyecto

- **Visión, evolución y estado detallado**: `NOTEBOOK.md`
- **Plan estratégico de alto nivel**: `PLAN.md` (este documento)
- **Estado técnico actual**: `core.py` y `extractor_url.py`