---
phase: 26-renderizado-js-wkwebview
plan: 02
status: complete
completed: "2026-10-21"
requirements: [WKJS-02, WKJS-03, WKJS-04]
---

# 26-02 — Resumen

Sin compilar: el sandbox de Linux no tiene Swift. Se compila y prueba en el
Mac (`CHECKPOINT-HUMANO.md`).

## Hecho

- **`Models/Services/WebRenderer.swift`** (nuevo): `@MainActor`.
  - `WKWebView` fuera de pantalla, de 1280×800, con
    `websiteDataStore = .nonPersistent()`.
  - `render(url:timeout:)`:
    - Carga y espera `didFinish`, un fallo o el plazo.
    - Si el marco principal responde HTTP ≥ 400 → error.
    - Sondea `document.body.innerText.length` cada 0,5 s hasta ≥ 100 y
      estable, o hasta el plazo.
    - Devuelve `outerHTML` y la URL final.
  - En `DEBUG`, `-webRendererForceFailure YES` fuerza el fallo.
- **`ExtractionResult`**: `jsRenderNeeded` (`js_render_needed`) y
  `needsJSRender`.
- **`PythonBridge`**
  - `Source` (`.url` / `.renderedHTML(file:baseURL:)`) y
    `run(source:…, externalJS:, jsOff:)`. `run(url:…)` sigue existiendo como
    atajo.
  - Los argumentos salen de `arguments(...)`, una función estática pura
    probada en tests.
  - Un resultado de error con `js_render_needed` se devuelve en vez de
    lanzarse.
- **`ExtractionViewModel`**
  - `extract()` usa `runExtraction`. En App Store (`#if APPSTORE`), primera
    pasada con `--js-external` y, si se pide, `WebRenderer` + `runRendered`:
    temporal en `temporaryDirectory` con BOM UTF-8, `--file` +
    `--base-url`, y se borra con `defer`.
  - Si el render falla: segunda pasada con `--js-external --no-js` (deja la
    entrada de historial) y `renderWarning`.
  - `lastRenderedPage` hace que `markdownForExport()` reconvierta el HTML
    renderizado.
  - `webURL(from:)` antepone `https://` a URLs sin esquema, como la CLI.
  - La tarea de `extract()` pasa de `Task.detached` + `MainActor.run` a
    `Task` en el MainActor. `WKWebView` lo exige, y `PythonBridge.run` ya
    era async y no bloquea el hilo.
- **`ContentView`**: fila de aviso (`exclamationmark.triangle`, `.callout`,
  `.secondary`) encima de la vista previa si hay `renderWarning`.
- **Tests Swift**
  - `PythonBridgeTests`: decodificación de `js_render_needed`, error con
    render devuelto, y argumentos de URL, App Store y HTML renderizado.
  - `ViewModelTests`: `extract()` limpia el aviso; `webURL(from:)`.
- **Test pytest**: HTML con BOM y `<meta charset="iso-8859-1">` → se lee como
  UTF-8.

## Desviaciones

- **BOM en el temporal:** `outerHTML` conserva el `<meta charset>` original.
  Sin BOM, `UnicodeDammit` decodificaría el UTF-8 con ese charset
  (comprobado: `Canción` → `CanciÃ³n`). Con BOM manda UTF-8. Hay un test
  pytest.
- **`webURL(from:)`:** el JSON devuelve la URL tal como se escribió
  (`quotes.toscrape.com/js/` sin esquema), y `WKWebView` necesita esquema.
- **`project.pbxproj`:** el Xcode del usuario lo reordenó y quitó los
  `.entitlements` de las excepciones. Commit aparte (`6f0fc59`), sin cambios
  de comportamiento. `WebRenderer.swift` entra en los dos targets por el
  grupo sincronizado, sin tocar el proyecto.

## Verificación aquí

- pytest: 109 passed.
- pylint: 10/10.
- mypy: sin errores.
- Swift: pendiente de ⌘B/⌘U en el Mac.
