---
phase: 26-renderizado-js-wkwebview
type: checkpoint-humano
status: pending
created: "2026-10-21"
---

# Checkpoint humano — Fase 26 (tras 26-01 y 26-02)

## A. Developer ID sin cambios

1. Esquema **ExtractorApp**: ⌘B y ⌘U. **Esperado:** compila y los tests
   pasan, incluidos los nuevos.
2. ⌘R y extrae `https://quotes.toscrape.com/js/` como Markdown.
   **Esperado:** salen las citas, renderizadas con Chromium como hasta
   ahora.

## B. App Store: render con WKWebView (WKJS-02/03)

1. Esquema **ExtractorApp AppStore**: ⌘R. Ten a la vista la consola de
   Xcode: las líneas `[PythonBridge] Launching:` muestran cada llamada a
   Python (como en el log de la Fase 25).
2. Extrae `https://quotes.toscrape.com/js/` como Markdown. **Esperado:**
   - Salen las citas («The world as we have created it…»).
   - En la consola hay dos lanzamientos de Python: el segundo con `--file`
     y `--base-url`.
   - No aparece ningún aviso.
3. Extrae `https://example.com`. **Esperado:** un solo lanzamiento de
   Python, sin render (la heurística no lo pide).
4. Con la extracción de las citas hecha, exporta a Markdown. **Esperado:**
   el archivo tiene las citas, no la página vacía.
5. Historial: **una** entrada para `quotes.toscrape.com/js/` (no dos), con
   su título.

## C. Degradación (WKJS-04)

1. En Xcode, Product → Scheme → Edit Scheme… → Run → Arguments, añade en
   «Arguments Passed On Launch» `-webRendererForceFailure YES` (solo Debug)
   y ⌘R.
2. Extrae `https://quotes.toscrape.com/js/`. **Esperado:**
   - Resultado con el contenido estático (casi vacío).
   - Aviso «No se pudo ejecutar el JavaScript de la página…».
   - Sin error.
   - Una entrada en el historial.
3. Quita el argumento del esquema.

Si en B.2 las citas salen a medias o vacías, dímelo: es el riesgo del
`WKWebView` fuera de ventana (ver `26-RESEARCH.md`) y se corrige
metiéndolo en una ventana invisible.
