# PLAN.md — extractor-url

Plan de desarrollo parametrado y alineado con el estado real del repositorio.

## 1. Estado actual

### Qué existe ya

- Herramienta Python en un solo archivo: `extractor_url.py`.
- Interfaces disponibles:
  - CLI con `argparse`
  - GUI con `tkinter`
- Tipos de salida disponibles:
  - texto limpio
  - HTML completo
  - Markdown
- Pipeline Markdown ya implementado:
  - `_fetch_raw()` para descarga base
  - `_clean_soup()` para limpieza DOM y resolución de URLs relativas
  - `trafilatura` como primera opción sin selector
  - `markdownify` como fallback o conversión directa con selector
  - `_post_process_markdown()` para limpieza final
- Selector CSS opcional ya disponible en CLI y API.
- La GUI ya usa `threading`, así que la descarga no bloquea el hilo principal.

### Qué no existe todavía

- Directorio `tests/` con fixtures locales.
- Reintentos HTTP y timeout configurable por usuario.
- Opciones CLI para `--clipboard`, `--no-links`, `--no-images` o caché local.
- Empaquetado `.app` para macOS.
- Documentación completamente alineada con la implementación actual.

## 2. Objetivo del plan

Evolucionar `extractor-url` desde una utilidad funcional de extracción web a una herramienta estable y mantenible, priorizando primero la calidad del Markdown, la fiabilidad del flujo CLI/GUI y la claridad documental, antes de abordar empaquetado o una UI macOS más ambiciosa.

## 3. Parámetros de ejecución

Estos parámetros permiten adaptar el plan sin reescribirlo.

| Parámetro | Valores sugeridos | Valor recomendado ahora | Efecto |
|---|---|---|---|
| `objetivo_producto` | `cli_robusta`, `app_macos_mvp`, `app_macos_nativa` | `cli_robusta` | Cambia el alcance del roadmap |
| `horizonte` | `corrección`, `mvp`, `v1` | `mvp` | Ajusta profundidad y entregables |
| `soporte_js` | `no`, `opcional`, `si` | `opcional` | Introduce o aplaza `playwright` |
| `prioridad_fidelidad_md` | `alta`, `media` | `alta` | Prioriza tests y calidad de conversión |
| `ui_objetivo` | `ninguna`, `tkinter`, `pywebview`, `swiftui` | `tkinter` | Define cuánto invertir en interfaz |
| `distribucion` | `uso_personal`, `distribucion_firmada` | `uso_personal` | Afecta empaquetado y firma |
| `tolerancia_refactor` | `minima`, `media`, `alta` | `minima` | Marca si se mantiene archivo único |
| `nivel_testing` | `smoke`, `unitario`, `unitario_fixtures` | `unitario_fixtures` | Define el esfuerzo de validación |

## 4. Principios de implementación

- Mantener cambios pequeños y verificables.
- No refactorizar a paquete todavía salvo necesidad clara.
- No depender de webs reales para pruebas automatizadas.
- Usar fixtures HTML locales como fuente determinista.
- Mantener el archivo único mientras el coste de modularización supere el beneficio.
- Tratar la documentación como parte del entregable, no como tarea posterior.

## 5. Fases recomendadas

### Fase 1 — Validación automática del conversor

Objetivo:
Crear una base de tests que congele el comportamiento bueno actual y detecte regresiones en Markdown.

Tareas:
- Crear `tests/`.
- Crear `tests/fixtures/` con HTML locales basados en los ejemplos ya guardados.
- Añadir tests para:
  - `_clean_soup()`
  - `_main_content()`
  - `_post_process_markdown()`
  - `extract_html_structure_to_markdown()` usando mocks o HTML controlado
- Verificar URLs relativas resueltas y eliminación de ruido DOM.
- Añadir al menos un caso de selector CSS explícito.

Criterios de cierre:
- Existe una suite ejecutable con `pytest tests/`.
- No hay llamadas a webs reales en pruebas.
- Hay cobertura sobre los casos problemáticos detectados en `NOTEBOOK.md`.

### Fase 2 — Robustez de red y experiencia operativa

Objetivo:
Reducir fallos evitables en descarga y mejorar el comportamiento ante errores reales.

Tareas:
- Añadir reintentos HTTP con backoff.
- Hacer configurable el timeout desde CLI.
- Exponer ese timeout también en GUI si aporta valor.
- Añadir mensajes de error más específicos cuando falle selector, red o parseo.
- Evaluar caché local simple en `/tmp` para repeticiones rápidas.

Criterios de cierre:
- La descarga reintenta fallos transitorios de forma controlada.
- El usuario puede ajustar timeout sin tocar código.
- El comportamiento ante error queda documentado.

### Fase 3 — CLI más útil para uso diario

Objetivo:
Convertir la CLI en una herramienta más flexible sin aumentar mucho la complejidad interna.

Tareas:
- Añadir `--clipboard` para copiar salida al portapapeles en macOS.
- Añadir `--no-links` para convertir enlaces a texto plano.
- Añadir `--no-images` para omitir imágenes en Markdown.
- Evaluar alias `--main-only` si simplifica casos comunes frente a `--selector`.
- Asegurar que `stdout` queda limpio cuando se usa en pipes.

Criterios de cierre:
- Las nuevas flags tienen comportamiento claro y probado.
- La CLI sigue siendo simple y coherente con el diseño actual.

### Fase 4 — Alineación documental

Objetivo:
Convertir la documentación existente en documentación fiable.

Tareas:
- Actualizar `CLAUDE.md` para reflejar:
  - `_fetch_raw()`
  - pipeline Markdown real
  - `selector`
  - uso de `threading` en GUI
- Revisar `NOTEBOOK.md` para separar:
  - completado
  - pendiente
  - visión futura
- Marcar `extractor contenido url.md` como referencia histórica o retirarlo del flujo principal.
- Usar `DESIGN.md` si se necesita una versión breve y vigente de la arquitectura.

Criterios de cierre:
- La documentación principal no contradice al código.
- Un colaborador nuevo puede entender el estado real del proyecto leyendo 2 documentos.

### Fase 5 — Empaquetado macOS

Objetivo:
Distribuir la herramienta sin depender de ejecución manual por terminal.

Tareas si `ui_objetivo=tkinter`:
- Preparar empaquetado simple como `.app`.
- Verificar arranque, icono y escritura de archivos.

Tareas si `ui_objetivo=pywebview`:
- Diseñar una UI más moderna manteniendo backend Python.
- Definir puente Python ↔ UI.

Tareas si `ui_objetivo=swiftui`:
- Tratarlo como una línea de producto nueva o fase mayor.
- Extraer una interfaz clara para invocar el backend Python.

Criterios de cierre:
- Existe una aplicación ejecutable en macOS ajustada al objetivo elegido.

## 6. Priorización recomendada

| Prioridad | Línea de trabajo | Motivo |
|---|---|---|
| P0 | Tests con fixtures locales | Falta principal para estabilizar el proyecto |
| P0 | Alinear documentación | Evita planificar sobre información obsoleta |
| P1 | Reintentos y timeout configurable | Mejora fiabilidad real de uso |
| P1 | Flags CLI de uso diario | Aumenta utilidad sin gran refactor |
| P2 | Caché local y mejoras de UX | Aporta comodidad, no bloquea |
| P2 | Empaquetado macOS | Relevante, pero no antes de estabilizar |
| P3 | Soporte JS con `playwright` | Útil, pero añade complejidad y peso |
| P3 | UI nativa SwiftUI | Objetivo mayor, no inmediato |

## 7. Riesgos y decisiones abiertas

- Si el objetivo final es una app macOS nativa, conviene limitar inversión en `tkinter` a mejoras tácticas.
- `playwright` añade cobertura funcional, pero complica instalación, tests y distribución.
- Mantener archivo único simplifica el repo hoy, pero puede tensarse al crecer opciones CLI y GUI.
- La calidad del Markdown depende del tipo de web objetivo:
  - artículos y blogs favorecen `trafilatura`
  - páginas genéricas favorecen `markdownify` con selector

## 8. Plan mínimo recomendado para ejecutar ya

1. Crear `tests/` con fixtures HTML locales.
2. Cubrir con pruebas el pipeline Markdown actual.
3. Actualizar `CLAUDE.md` y limpiar la jerarquía documental.
4. Añadir reintentos HTTP y timeout configurable.
5. Añadir `--clipboard`, `--no-links` y `--no-images`.
6. Reevaluar después si compensa empaquetar o rediseñar la UI.

## 9. Fuente de verdad del proyecto

- Estado técnico actual: `extractor_url.py`
- Visión y evolución: `NOTEBOOK.md`
- Convenciones operativas del repositorio: `AGENTS.md` y `CLAUDE.md`
- Referencia histórica: `extractor contenido url.md`
