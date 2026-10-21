---
phase: 26-renderizado-js-wkwebview
plan: 01
status: complete
completed: "2026-10-21"
requirements: [WKJS-01, WKJS-03]
---

# 26-01 — Resumen

## Hecho

- **`core.py`**
  - **`ExternalRenderSession`**: context manager con `render_needed`. Alias
    `RenderSession = Union[PlaywrightSession, ExternalRenderSession]` en
    todas las firmas con `session`.
  - **`_download()`**: donde se llamaría a Playwright por la heurística (o
    `force`), con sesión externa solo marca `render_needed` y sigue con el
    estático. Ante 401/403 con sesión externa se propaga el error, sin pedir
    render.
  - **Caché:**
    - No se escribe si queda `render_needed`.
    - Al leer en `auto` con sesión externa, se vuelve a aplicar la
      heurística, por si la entrada la guardó una ejecución sin
      `--js-external`.
    - La lectura pasa a `_read_cache()`.
  - **`base_url`** opcional en `_read_local_html`, `_fetch_raw`,
    `_fetch_soup`, `extract_formatted_content` y
    `extract_html_structure_to_markdown`. Gana a canonical/og:url.
- **`extractor_url.py`**
  - Flags `--js-external` y `--base-url URL`.
  - Errores de argumentos (código 2):
    - `--base-url` sin `--file`;
    - `--base-url` sin esquema http/https;
    - `--js-external` con `--batch`.
  - `url` del JSON y del historial = `--base-url` si se pasa.
  - Con `--js-external`, el JSON (éxito y error) lleva `js_render_needed`.
    Sin el flag, la clave no aparece.
  - **Pasada provisional** (`render_needed`): sin `_lookup_title`, sin
    historial, y sin `--json` un aviso en stderr.
  - `main()` se divide en `_resolve_file_arg`, `_check_base_url` y
    `_write_output` para seguir en pylint 10/10.
- **Tests** en `tests/test_external_render.py` (14 tests) y fixture nuevo
  `tests/fixtures/renderizado_relativo.html`.
- **`CLAUDE.md`**: dos ejemplos nuevos en «Ejecución».

## Verificación

- pytest: 108 passed (94 + 14).
- pylint: 10.00/10.
- mypy: sin errores.

## Desviaciones

- **Test extra:** caché insuficiente guardada sin `--js-external` → también
  pide render. No estaba en el plan, pero sin esa comprobación la app se
  quedaría con la SPA vacía si alguien usó la CLI antes en la misma caché.
- **Ajuste del plan 26-02 (T1):** con `js_render_needed`, un payload de
  error (por ejemplo, un selector que aún no existe sin JS) no debe lanzar
  en `PythonBridge.run`. El render puede arreglarlo.
