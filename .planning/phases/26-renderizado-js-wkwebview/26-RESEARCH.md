# Research: Fase 26 — Renderizado JavaScript con WKWebView

*Investigado: 2026-10-21, sobre el código en `25b9a0e`.*

## Punto de partida

- **Python decide cuándo hace falta JS.** `core._download()` descarga con
  `requests` y, si `js_mode == "force"` o (`"auto"` y
  `_looks_insufficient(html)`: menos de 100 caracteres de texto visible),
  llama a `_fetch_via_playwright()`. Si Playwright no está o falla, devuelve
  `None` y se queda con el HTML estático (degradación ya existente).
- **Otro reintento con Chromium:** ante HTTP 401/403, `_download()` reintenta
  con Chromium salvo en `"off"`.
- **La variante App Store no lleva Playwright** (Fase 25). Hoy una SPA allí
  sale con el contenido estático casi vacío, y en stderr «Playwright no
  disponible…».
- **La app no expone los modos de JS:** siempre usa `auto`. `--js`/`--no-js`
  solo existen en la CLI.
- **`--file RUTA` (y `file://`)** lee un HTML local sin red ni caché. Usa como
  base de enlaces la URL original si el HTML la declara (canonical,
  `og:url`, «saved from»); si no, el propio `file://`.
- **`PlaywrightSession`** se pasa como `session` por toda la cadena
  (`extract_formatted_content` → `_fetch_raw` → `_download` →
  `_fetch_via_playwright`).
- **Swift:** `PythonBridge.run(url:outputType:selector:timeout:)` lanza la
  CLI con `--json`. `ExtractionViewModel.extract()` la llama una vez.
  `markdownForExport()` la vuelve a llamar con la misma URL para reconvertir
  a Markdown al exportar.
- **`WKWebView`** ya se usa para la vista previa y el PDF (`WebPreviewView`),
  así que `WebKit` ya está enlazado. Bajo sandbox, el proceso WebContent
  funciona (Fase 25, B; el log de la consola es ruido del sistema).

## Decisión: Python sigue decidiendo y Swift renderiza

**Alternativa descartada:** copiar la heurística en Swift. Habría dos
fuentes de verdad, y WKJS-03 pide «la misma heurística».

**Diseño elegido:** dos pasadas solo cuando hace falta.

1. **Primera pasada:** Swift llama a la CLI como siempre más `--js-external`.
   - Con ese flag, Python no usa Playwright.
   - Donde lo usaría (`force`, o `auto` + `_looks_insufficient`), anota que
     hace falta renderizar y sigue con el HTML estático.
   - El JSON añade `"js_render_needed": true|false`. Solo aparece con
     `--js-external`, así que el contrato actual no cambia.
2. **Si `js_render_needed`:** Swift carga la URL en un `WKWebView` oculto,
   con un tiempo límite igual al timeout de la extracción.
   - Saca `document.documentElement.outerHTML` y lo escribe en un temporal
     de su contenedor.
   - Llama a la CLI con `--file TEMP --base-url URL_FINAL`.
3. **Si el render falla o agota el tiempo** (WKJS-04), se muestra el
   resultado de la primera pasada con un aviso.

Ventajas:

- Las páginas normales cuestan lo mismo que hoy: una pasada, ningún
  `WKWebView`.
- La CLI sigue siendo la única que decide. Los modos `--js`/`--no-js` se
  respetan solos: `force` siempre pide render y `off` nunca.

### Detalles de Python

- **`ExternalRenderSession`**, en lugar de `PlaywrightSession`: misma forma
  (context manager) y un atributo `render_needed: bool`.
  - `_fetch_via_playwright()`, si recibe esta sesión, marca `render_needed`
    y devuelve `None` sin importar `playwright`.
  - El resto del flujo ya trata `None` como «quedarse con el estático».
- **401/403 en modo externo:** no se pide render, se propaga el error como
  hoy en `"off"`. WKJS no lo pide, y reintentar una página que bloquea
  clientes no es objetivo del proyecto (no evasión anti-bots). Si no se
  excluye, `_download()` marcaría `render_needed` y relanzaría el error, y
  la app reintentaría con `WKWebView` un sitio que la ha bloqueado.
- **Caché:** si se marcó `render_needed`, el HTML estático **no** se guarda
  en caché. Si se guardara, la siguiente lectura en `auto` devolvería el
  estático sin pasar por la heurística, y no se pediría render.
- **Historial y título:** con `render_needed` la primera pasada es
  provisional.
  - No llama a `_lookup_title()`, que sería otra descarga sin caché.
  - No escribe en el historial: la segunda pasada escribe la entrada buena,
    con la URL de origen gracias a `--base-url`.
  - Si el render falla, Swift relanza la CLI con `--js-external --no-js`.
    Así queda la entrada de historial del resultado estático y el contrato
    sigue simple, a costa de una descarga más solo en ese caso.
- **`--base-url URL`** (solo con `--file`):
  - Base para resolver enlaces e imágenes.
  - Es la `url` del JSON y del historial, en lugar de `file:///…/tmp…`.
  - Tiene prioridad sobre canonical/og:url, porque es la URL que se cargó de
    verdad.
  - Con esquema distinto de http/https → error claro, código 2.

### Detalles de Swift

- **`WebRenderer`** (`@MainActor`, nuevo, `Models/Services/WebRenderer.swift`):
  - `WKWebView` fuera de pantalla con `WKWebViewConfiguration` no
    persistente (`.nonPersistent()`), sin cookies del usuario ni caché
    compartida.
  - `render(url:timeout:) async throws -> (html: String, finalURL: URL)`.
  - **Estado HTTP:** `decidePolicyFor navigationResponse` guarda el código;
    ≥ 400 → error, como `_render_page()` de Playwright.
  - **Espera:** tras `didFinish`, sondea cada 0,5 s
    `document.body.innerText.length` hasta que se cumple una de estas
    condiciones:
    - (a) ≥ 100 caracteres y dos lecturas seguidas iguales;
    - (b) se agota el tiempo; si ya hay algo de HTML, se devuelve igual
      (mejor que el estático);
    - (c) `didFail`.

    Es el equivalente práctico de `networkidle`, que WebKit no expone.
  - Tiempo límite total: el `timeout` de la extracción.
- **Orquestación** en `ExtractionViewModel` (sin `Task.detached` para el
  render: `WKWebView` vive en el MainActor; `PythonBridge.run` sigue fuera):

  ```
  r1 = bridge.run(url, …, externalJS: true)      // solo APPSTORE
  if r1.jsRenderNeeded:
      do  { (html, final) = WebRenderer.render(url, timeout)
            r = bridge.run(file: temp(html), baseURL: final, …) }
      catch { r = bridge.run(url, …, externalJS: true, jsMode: off)
              aviso = "No se pudo ejecutar el JavaScript de la página…" }
  ```

  En Developer ID nada cambia (`externalJS: false`): sigue Playwright.
- **El export a Markdown** reconvierte con `bridge.run(url:…)`. Si la
  extracción usó render, debe reconvertir **el mismo HTML renderizado**, no
  volver a descargar el estático. El view model guarda el HTML renderizado
  de la última extracción (en memoria) y `markdownForExport()` lo reutiliza
  con `--file`/`--base-url`.
- **Temporales:** `FileManager.default.temporaryDirectory`, que bajo sandbox
  está en el contenedor y el hijo lo hereda. Se borran con `defer` al
  terminar cada llamada.
- **`ExtractionResult`:** campo opcional `jsRenderNeeded`
  (`js_render_needed`). Sin el campo → `nil` → `false`.

## Riesgos

- **`WKWebView` sin ventana:** en macOS ejecuta JS fuera de pantalla, pero
  WebKit puede frenar temporizadores de vistas ocultas. Mitigación: si el
  checkpoint muestra páginas a medio hidratar, añadirlo a una ventana
  invisible (`NSWindow` 1×1 fuera de pantalla). Se decide en el checkpoint.
- **Paridad con Chromium:** algunas SPA renderizan distinto en WebKit.
  Aceptado en la investigación del milestone (APPSTORE.md, riesgo 2).
- **Página de prueba:** `https://quotes.toscrape.com/js/` (estática con
  < 100 caracteres visibles, contenido generado por JS). Ya se usó en la
  Fase 11.

## Fuera de alcance

- Reintento con `WKWebView` ante 401/403 (ver arriba).
- Exponer `--js`/`--no-js` en la app.
- Cambios en la variante Developer ID.
