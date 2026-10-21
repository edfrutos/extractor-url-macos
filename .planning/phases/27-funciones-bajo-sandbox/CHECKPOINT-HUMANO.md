---
phase: 27-funciones-bajo-sandbox
type: checkpoint-humano
status: pending
created: "2026-10-21"
---

# Checkpoint humano — Fase 27 (tras 27-01)

Haz cada prueba con el esquema **ExtractorApp AppStore**. Las de errores
(E), también con **ExtractorApp** para compararlas.

## A. Compila y los tests pasan

Esquema **ExtractorApp**: ⌘B y ⌘U.

## B. Exportar (SBXFEAT-01)

Extrae `https://quotes.toscrape.com/js/` como Markdown y exporta a:

1. **Markdown:** archivo con las citas.
2. **HTML:** se abre en Safari con las citas.
3. **PDF:** se abre en Vista Previa con las citas.

Guarda los tres en una carpeta cualquiera, por ejemplo el Escritorio.

## C. Copiar (SBXFEAT-04)

1. Pulsa «Copiar» y pega en TextEdit. **Esperado:** el Markdown completo.
2. Repite con ⌘⇧C, extrayendo como HTML.

## D. Historial y archivos locales (SBXFEAT-02/03)

1. «Abrir HTML…» con una página guardada. **Esperado:** se extrae.
2. Sal de la app (⌘Q) y vuelve a lanzarla (⌘R). **Esperado:** el historial
   conserva las extracciones de antes.
3. Desde el historial, reabre la página guardada. **Esperado:** se abre un
   panel en su carpeta pidiendo volver a elegirla. Al aceptar, se extrae.
4. Desde el historial, reabre `quotes.toscrape.com/js/`. **Esperado:** se
   extrae sin panel.

## E. Errores (SBXFEAT-05), en las dos variantes

| Prueba | Cómo |
|---|---|
| Red | `https://url-que-no-existe-9999.xyz` |
| 403 | `https://httpbin.org/status/403` |
| Selector | `https://example.com` con selector `#no-existe` |
| Timeout | `https://httpbin.org/delay/10` con timeout 3 |

**Esperado:**

- El mismo mensaje principal en las dos variantes.
- En el 403, el «Detalle» puede cambiar: Developer ID reintenta antes con
  Chromium.

Pégame las cuatro parejas de mensajes si alguna no coincide.
