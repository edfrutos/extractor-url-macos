# Phase 4: SwiftUI UI de Extracción — Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-11
**Phase:** 04-swiftui-ui-de-extraccion
**Areas discussed:** Layout de ventana, Estado reactivo, Presentación de errores, Opciones avanzadas

---

## Layout de ventana

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| VStack lineal | URL arriba, controles en medio, resultado abajo. Sigue patrón existente en ContentView. | ✓ |
| Split horizontal (controles \| resultado) | HSplitView con panel de controles y panel de resultado. Más espacio para el resultado, más complejo. | |
| Form-style con secciones | Mismo estético que SettingsView. Demasiado formal para una ventana de extracción activa. | |

**User's choice:** VStack lineal
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| ScrollView de texto | TextEditor o Text en ScrollView. Simple, sin dependencias. Se reemplaza por WKWebView en Fase 5. | ✓ |
| Placeholder con mensaje hasta extraer | Texto gris de estado vacío hasta que haya contenido. | |
| Sin área de resultado en Fase 4 | Solo ProgressView y mensaje breve; el preview completo llega en Fase 5. | |

**User's choice:** ScrollView de texto
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| 500×450 | Coherente con minWidth: 500 ya en ContentView. | ✓ |
| 600×500 | Más generoso, útil con Disclosure Group visible. | |
| Tú decides | Claude elige tamaño. | |

**User's choice:** 500×450
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Picker segmentado | .pickerStyle(.segmented) — los 3 tipos visibles de un vistazo. | |
| Picker desplegable (menu) | .pickerStyle(.menu) — menos espacio horizontal, clic extra. | |
| Tú decides | Claude elige según espacio disponible en el layout. | ✓ |

**User's choice:** Tú decides (Claude's discretion)
**Notes:** —

---

## Estado reactivo

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| @StateObject + ObservableObject | Compatible macOS 13.0 garantizado. Patrón ya en uso. | ✓ |
| @Observable macro (macOS 14+ runtime) | Más limpio y moderno. Riesgo en runtime macOS 13 según STATE.md. | |

**User's choice:** @StateObject + ObservableObject
**Notes:** STATE.md marca como pendiente verificar comportamiento de @Observable en macOS 13. Diferido.

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Reemplaza completamente | ContentView.swift se reescribe con ViewModel limpio. BridgeTestViewModel eliminado. | ✓ |
| Extiende BridgeTestViewModel | Añadir propiedades al ViewModel existente. Acumula deuda. | |

**User's choice:** Reemplaza completamente
**Notes:** BridgeTestViewModel era andamio de prueba de Fase 3, no base para la UI real.

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| ExtractionViewModel | Coherente con ExtractionResult, ExtractionError. | |
| ExtractorViewModel | Nombrado por la herramienta/app. | |
| Tú decides | Claude elige el nombre más coherente. | ✓ |

**User's choice:** Tú decides (Claude's discretion)
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Sí, disabled mientras isExtracting | Evita llamadas en paralelo. Patrón ya en BridgeTestViewModel. | ✓ |
| No, el usuario puede cancelar relanzando | No hay cancel() en PythonBridge. Complica estado. | |

**User's choice:** Sí, disabled mientras isExtracting
**Notes:** —

---

## Presentación de errores

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Mensaje inline en rojo | Text en .foregroundColor(.red), no bloquea UI, permite reintentar. | ✓ |
| Alert modal (.alert) | Bloquea hasta dismiss. Adecuado para errores fatales. | |
| Ambos: inline + alert según tipo | Inline para errores de contenido, alert para errores de configuración. | |

**User's choice:** Mensaje inline en rojo
**Notes:** Patrón ya en ContentView de Fase 3 (errorText en Text rojo).

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Sí, se limpia al pulsar Extraer | ViewModel limpia error = nil cuando isExtracting = true. | ✓ |
| No, persiste hasta nuevo resultado | Error visible mientras el usuario edita la URL. | |

**User's choice:** Sí, se limpia al pulsar Extraer
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Solo el contenido extraído en ScrollView | result.content directamente. La URL y tipo ya son visibles en los controles. | ✓ |
| Cabecera con metadatos + contenido | URL, tipo y char_count encima del contenido. | |
| Tú decides | Claude elige qué metadatos del ExtractionResult son útiles mostrar. | |

**User's choice:** Solo el contenido extraído
**Notes:** —

---

## Opciones avanzadas

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| DisclosureGroup colapsable | 'Opciones avanzadas ▾' que expande CSS selector y timeout. Oculto por defecto. | ✓ |
| Siempre visibles bajo los controles | Dos TextField siempre presentes. Más simple pero más espacio vertical. | |
| Solo en Preferencias | Timeout y selector en SettingsView. Menos flexible por sesión. | |

**User's choice:** DisclosureGroup colapsable
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| TextField libre con valor por defecto 15 | Sin Stepper. Default 15s, el usuario sobreescribe. | ✓ |
| Stepper 5–60 s | Evita valores inválidos pero menos flexible. | |
| Tú decides | Claude elige el control más apropiado. | |

**User's choice:** TextField libre con valor por defecto 15
**Notes:** —

| Opción | Descripción | Seleccionada |
|--------|-------------|--------------|
| Colapsado por defecto | El flujo habitual es solo URL + tipo. Opciones avanzadas son el caso excepcional. | ✓ |
| Expandido por defecto | Útil si el usuario usa selector CSS frecuentemente. | |

**User's choice:** Colapsado por defecto
**Notes:** —

---

## Claude's Discretion

- **Nombre del ViewModel** — Claude elige entre ExtractionViewModel / ExtractorViewModel u otro, manteniendo coherencia con `ExtractionResult` y `ExtractionError`.
- **Estilo del selector de tipo** — Claude elige `.pickerStyle(.segmented)` o `.pickerStyle(.menu)` según espacio disponible en el VStack.

## Deferred Ideas

- Preview WKWebView del contenido renderizado — Fase 5 (UI-02).
- Botón de cancelación de extracción en curso — requiere `process.terminate()` en PythonBridge, diferido a post-v2.0.
- Historial de URLs extraídas — nueva funcionalidad, fuera del scope v2.0.
- `@Observable` macro — diferido hasta verificar comportamiento en runtime macOS 13.
