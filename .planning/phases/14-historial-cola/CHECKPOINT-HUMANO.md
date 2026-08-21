---
phase: 14-historial-cola
type: checkpoint-humano
status: pending
created: "2026-08-20"
---

# Checkpoint Humano — Fase 14-02 (Vista de historial en la app)

## Objetivo

Compilar y verificar la vista de historial: botón nuevo en la cabecera de
la app, sheet con la lista de extracciones previas, y "reabrir" una
entrada rellenando los campos y reextrayendo.

## Estado de partida

- 3 archivos Swift nuevos: `Models/HistoryEntry.swift`,
  `ViewModels/HistoryViewModel.swift`, `Views/HistoryView.swift`.
- `ContentView.swift` modificado: botón de historial en `heroSection` +
  `.sheet` en el `body`.
- Nada de esto está commiteado todavía.
- Requiere que ya hayas hecho al menos una extracción con la app (Fase
  14-01, motor Python) para que `history.jsonl` tenga contenido real que
  mostrar — si el archivo está vacío, verás el estado vacío ("Sin
  extracciones todavía"), no un error.

## Paso 1 — Build

1. Abre `ExtractorApp.xcodeproj` en Xcode (o vuelve a la ventana ya
   abierta de la Fase 12/13).
2. `Product → Clean Build Folder` (⇧⌘K), luego `Product → Build` (⌘B).

**Resultado esperado:** `Build Succeeded`.

**Si falla:** copia el error exacto (archivo, línea, mensaje) y
pégamelo.

## Paso 2 — Generar algo de historial real (si no lo tienes ya)

Con la app corriendo (⌘R), extrae un par de URLs distintas (con formatos
distintos si quieres, texto/HTML/Markdown) para tener varias entradas.

## Paso 3 — Verificar la vista de historial

1. Pulsa el icono de reloj (🕐, `clock.arrow.circlepath`) en la cabecera
   de la app, junto al título.
2. Debería abrirse una ventana/sheet con la lista de extracciones que
   acabas de hacer, la más reciente arriba.

**Repórtame:**
- ¿Aparece la lista con las entradas correctas (título o URL, badge de
  formato)?
- ¿Las entradas de éxito muestran un check verde y las de error (si
  provocaste alguna) un triángulo naranja?

## Paso 4 — Verificar "Reabrir"

1. Pulsa sobre una entrada del historial.
2. Debería cerrarse el sheet y la app debería reextraer automáticamente
   esa misma URL con el mismo formato/selector — verás el spinner de
   "Extrayendo..." brevemente y luego el resultado.

**Repórtame:** ¿Reabrir funciona? ¿El campo URL y el picker de formato
quedan rellenos con los valores correctos de la entrada que pulsaste?

## Paso 5 — Cierre (lo hago yo, no tú)

Cuando confirmes Build Succeeded + historial visible + reabrir
funcionando, yo:

1. Escribo `14-02-SUMMARY.md` con los resultados reales.
2. Marco la Fase 14 completa (HIST-01, HIST-02, HIST-03 validados) en
   ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md.
3. Te pregunto si quieres commitear/pushear, y si seguimos con la Fase
   15 (flag manual `--js`/`--no-js`).

## Plan de contingencia

- **El historial aparece vacío pese a haber extraído URLs** → probable
  desajuste de ruta (Pitfall 1 del research, `14-02-RESEARCH.md`) —
  ejecuta `cat ~/.cache/extractor-url/history.jsonl` en Terminal para
  confirmar que el archivo existe y tiene contenido; si existe pero la
  app no lo ve, dímelo con la salida de ese `cat`.
- **Reabrir no reextrae / no pasa nada al pulsar una fila** → revisa que
  el closure `onReopen` se esté ejecutando (podría ser un problema de
  `dismiss()` o de binding) — dime exactamente qué observas.
- **El botón de historial no aparece en la cabecera** → posible problema
  de layout en `heroSection` — pégame una captura si es más fácil que
  describirlo.
