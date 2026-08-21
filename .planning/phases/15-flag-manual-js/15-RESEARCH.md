---
phase: 15-flag-manual-js
type: research
status: complete
created: "2026-08-21"
---

# Phase 15: Flag manual `--js`/`--no-js` — Research

## User Constraints (from PROJECT.md / ROADMAP.md)

### Locked Decisions (desde v6.0 planning)

- Fase 15 **extiende** `core.py`/`extractor_url.py` de la Fase 11 (v4.0) — no la sustituye. Sin pasar ninguno de los dos flags, el comportamiento es exactamente el de v4.0 (heurística automática `_looks_insufficient()`, sin cambios).
- Alcance **solo CLI** — la app SwiftUI no cambia en esta fase (`UI hint: no` en ROADMAP.md). `PythonBridge` sigue llamando al CLI sin flags nuevos.
- Tests cubren los 2 flags con el mismo patrón de mocking que `tests/test_js_fallback.py` (Fase 11) — sin depender de un browser real.

### Claude's Discretion

- Nombre y forma exacta del parámetro interno que transporta el modo (string tri-estado vs. dos booleanos).
- Punto de integración exacto dentro de `_fetch_raw()` (cómo conviven `js_mode` con la heurística `_looks_insufficient()` ya existente).
- Cómo interactúan `--js`/`--no-js` con la caché HTTP existente (ver Pitfall 1 — decisión no trivial, no cubierta por FLAG-01/02 literalmente pero necesaria para que ambos flags tengan efecto real).

### Deferred Ideas (OUT OF SCOPE — Fase 15)

- Exponer el flag en la app SwiftUI (picker "Auto/Forzar JS/Sin JS") — v7+ si se pide; de momento la app sigue usando exclusivamente el modo `auto`.
- Ajustar el umbral `_MIN_VISIBLE_TEXT_LENGTH` o la heurística en sí — Fase 15 no toca `_looks_insufficient()`, solo añade caminos que la evitan.

## Summary

La Fase 11 (v4.0) ya implementó el fallback Playwright activado únicamente por heurística automática (`_looks_insufficient()`), con la decisión explícita en su momento de **no** añadir un flag manual. La Fase 15 revierte esa decisión diferida: añade `--js` (fuerza Playwright) y `--no-js` (lo desactiva) a la CLI, ambos opcionales y mutuamente excluyentes, sin cambiar el comportamiento por defecto (sin flag = heurística automática, idéntico a v4.0).

El punto de integración es el mismo que en la Fase 11: `_fetch_raw()`. Se añade un parámetro `js_mode: str = "auto"` (valores `"auto"` / `"force"` / "off"`) que se propaga desde `extractor_url.py` (vía `extract_formatted_content()` y `extract_html_structure_to_markdown()`) hasta `_fetch_raw()`, donde sustituye la única línea `if _looks_insufficient(html_text):` por una decisión de 3 vías.

**Hallazgo no trivial de este research**: la caché HTTP de `_fetch_raw()` se comprueba **antes** de cualquier lógica de heurística/Playwright — si una URL ya está cacheada (de una ejecución anterior, con o sin JS), `--js`/`--no-js` no tendrían ningún efecto observable porque la función devolvería el HTML cacheado sin llegar nunca a evaluar el modo. Esto rompería silenciosamente FLAG-01/FLAG-02 en el caso común de re-ejecutar el comando sobre la misma URL. La solución propuesta (ver Architecture Patterns) es que `js_mode != "auto"` **salte la lectura de caché** (pero siga escribiendo en ella al final, igual que hoy) — así un flag explícito siempre tiene efecto real, y el modo `auto` (por defecto) preserva el comportamiento exacto de v4.0 sin cambios.

## Análisis del Estado Actual del Código

### `_fetch_raw()` — punto de integración (core.py:116-171)

```python
def _fetch_raw(url: str, timeout: int = 15, use_cache: bool = True) -> Optional[tuple[str, str]]:
    ...
    if use_cache:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        if cache_file.exists():
            ...
            return cached_data["html"], cached_data["final_url"]   # <-- lectura de caché ANTES de cualquier lógica JS

    response = _HTTP_SESSION.get(url, ...)
    ...
    html_text = response.text
    ...
    if _looks_insufficient(html_text):          # <-- única línea que Fase 15 sustituye
        rendered = _fetch_via_playwright(url, timeout)
        if rendered is not None:
            html_text = rendered

    if use_cache:
        ... guardar en caché ...

    return html_text, final_url
```

### Cadena de propagación de `use_cache` — mismo patrón a replicar para `js_mode`

`use_cache` ya se propaga por toda la cadena de llamadas como parámetro opcional con default:

```
extractor_url.main() [args.use_cache]
  → extract_formatted_content(..., use_cache=args.use_cache)
      → extract_html_structure_to_markdown(..., use_cache=use_cache)   [si return_type == "markdown_structure"]
      → _fetch_soup(..., use_cache=use_cache)
          → _fetch_raw(..., use_cache=use_cache)
  → extract_html_structure_to_markdown(..., use_cache=use_cache)        [directo, si aplica]
      → _fetch_raw(..., use_cache=use_cache)
```

`js_mode` debe seguir exactamente esta misma cadena (mismo patrón, mismos puntos de propagación) — no hay ninguna razón para que se comporte distinto a `use_cache`.

`_lookup_title()` (extractor_url.py:29-34) también llama a `_fetch_raw()` directamente (segunda llamada, para el `<title>` en la salida `--json`) — necesita el mismo parámetro por consistencia, aunque en la práctica ya se beneficiará de la caché escrita por la primera llamada dentro del mismo proceso (ver Pitfall 2).

### `argparse` actual — grupo de flags existente como precedente (extractor_url.py:265-317)

`--no-cache` ya usa `action="store_false", dest="use_cache"` + `parser.set_defaults(use_cache=True)` — patrón de flag booleano con default ya establecido. Para `--js`/`--no-js` el precedente más cercano es un **grupo mutuamente excluyente** (`argparse` lo soporta nativamente vía `add_mutually_exclusive_group()`), algo que este archivo no usa todavía pero que es la solución estándar de `argparse` para "estos dos flags no pueden coexistir" — evita tener que validar la combinación a mano después de `parse_args()`.

### `tests/test_cli.py` — patrón de mocking a nivel de `extractor_url`, no de `core`

Los tests de `main()` monkeypatchean `extractor_url.extract_formatted_content` directamente (una función completa sustituida por un lambda), no `core._fetch_raw`. Esto significa que los tests de Fase 15 tienen dos niveles distintos que cubrir, igual que en la Fase 11:

- **Nivel `core.py`** — igual que `tests/test_js_fallback.py`: monkeypatchear `core._HTTP_SESSION.get` y `core._fetch_via_playwright`, verificar que `_fetch_raw(url, js_mode="force")` llama a Playwright pese a HTML rico, y que `_fetch_raw(url, js_mode="off")` nunca lo llama pese a HTML pobre.
- **Nivel `extractor_url.py`** — igual que `tests/test_cli.py`: monkeypatchear `sys.argv` con `--js`/`--no-js` y verificar que `extract_formatted_content` recibe el `js_mode` correcto (inspeccionando los kwargs de la llamada mockeada), y que pasar ambos flags a la vez falla con el mecanismo nativo de `argparse` (`SystemExit` código 2, mensaje de "not allowed with argument").

## Standard Stack

- Nada nuevo — reutiliza `argparse.add_mutually_exclusive_group()` (stdlib, ya usado indirectamente por el patrón `store_true`/`store_false` existente) y el mismo `playwright` ya declarado en `requirements.txt` desde la Fase 11.

## Architecture Patterns

### `core.py` — `_fetch_raw()` con `js_mode`

```python
def _fetch_raw(
    url: str,
    timeout: int = 15,
    use_cache: bool = True,
    js_mode: str = "auto",   # "auto" | "force" | "off"
) -> Optional[tuple[str, str]]:
    """Descarga una URL (con caché opcional) y devuelve (html_text, url_final).

    js_mode controla el fallback Playwright (Fase 11/15):
    - "auto" (defecto): heurística _looks_insufficient() decide, igual que v4.0.
    - "force": renderiza siempre con Playwright, ignorando la heurística.
    - "off": nunca renderiza con Playwright, ignorando la heurística.
    """
    if not url.startswith(("http://", "https://")):
        url = "https://" + url

    cache_key = hashlib.sha256(url.encode()).hexdigest()
    cache_file = _CACHE_DIR / f"{cache_key}.json"

    # --js/--no-js explícitos deben tener efecto real aunque la URL ya esté
    # cacheada de una ejecución anterior con el modo "auto" — se salta solo
    # la LECTURA de caché, la escritura al final se mantiene igual.
    if use_cache:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        if js_mode == "auto" and cache_file.exists():
            try:
                with cache_file.open("r", encoding="utf-8") as f:
                    cached_data = json.load(f)
                    return cached_data["html"], cached_data["final_url"]
            except (IOError, json.JSONDecodeError):
                pass

    try:
        response = _HTTP_SESSION.get(url, headers={"User-Agent": _USER_AGENT}, timeout=timeout)
        response.raise_for_status()
        response.encoding = response.apparent_encoding
        html_text = response.text
        final_url = response.url

        if js_mode == "force":
            rendered = _fetch_via_playwright(url, timeout)
            if rendered is not None:
                html_text = rendered
            # si rendered es None (Playwright no disponible), degrada al
            # HTML estático — mismo principio JS-03 de la Fase 11.
        elif js_mode != "off" and _looks_insufficient(html_text):
            rendered = _fetch_via_playwright(url, timeout)
            if rendered is not None:
                html_text = rendered

        if use_cache:
            try:
                with cache_file.open("w", encoding="utf-8") as f:
                    json.dump({"html": html_text, "final_url": final_url}, f)
            except IOError:
                pass

        return html_text, final_url
    ...  # manejo de errores sin cambios
```

`_fetch_soup()`, `extract_formatted_content()` y `extract_html_structure_to_markdown()` añaden `js_mode: str = "auto"` y lo reenvían, exactamente como ya hacen con `use_cache`.

### `extractor_url.py` — flags CLI + propagación

```python
js_group = parser.add_mutually_exclusive_group()
js_group.add_argument(
    "--js",
    action="store_true",
    help="Fuerza el render con Playwright (Chromium headless), "
         "aunque la heurística automática no lo active.",
)
js_group.add_argument(
    "--no-js",
    action="store_true",
    help="Desactiva el fallback Playwright, aunque la heurística "
         "automática sí lo activaría.",
)
```

Tras `parse_args()`, una función pequeña traduce los dos booleanos a un único `js_mode` (evita pasar `args.js`/`args.no_js` por separado a cada función):

```python
def _resolve_js_mode(args: argparse.Namespace) -> str:
    if args.js:
        return "force"
    if args.no_js:
        return "off"
    return "auto"
```

Y se pasa `js_mode=_resolve_js_mode(args)` en las 3 llamadas existentes a `extract_formatted_content(...)`/`_lookup_title(...)` (una en `main()`, dos en `_run_batch()` — mismo patrón que `use_cache=args.use_cache` ya replicado en esos 3 sitios).

## Don't Hand-Roll

- **No validar manualmente "no pasar `--js` y `--no-js` a la vez"** — `add_mutually_exclusive_group()` de `argparse` ya lo hace nativamente (`SystemExit(2)` con mensaje "argument --no-js: not allowed with argument --js"), consistente con el principio ya establecido en este proyecto de fallar explícito ante combinaciones inválidas.
- **No introducir un nuevo tipo `enum.Enum` para `js_mode`** — el resto del código (`return_type`, `output_type` del historial) ya usa `str` simple con valores fijos por convención, sin `Enum`; introducir uno aquí rompería la consistencia estilística sin aportar valor real (no hay validación de tipo en runtime en ningún otro parámetro string similar de este módulo).

## Common Pitfalls

### Pitfall 1: La caché HTTP anula silenciosamente ambos flags

Ver Summary — sin el ajuste de "saltar solo la lectura de caché cuando `js_mode != auto`", ejecutar `--js` sobre una URL ya cacheada de una ejecución anterior (con o sin `--js`) devolvería el HTML cacheado sin pasar nunca por Playwright, violando FLAG-01 de forma no evidente (no hay error, simplemente no hace lo que el flag promete). Cubrir explícitamente con un test que cachee primero con `js_mode="auto"` y compruebe que una segunda llamada con `js_mode="force"` sí invoca Playwright pese al cache hit.

### Pitfall 2: `_lookup_title()` como segunda llamada a `_fetch_raw()`

`_lookup_title()` ya hace una segunda llamada a `_fetch_raw()` para obtener el `<title>` en la salida `--json` (reutilizado de la Fase 14-01). Si no se le pasa el mismo `js_mode`, en el caso `js_mode="auto"` no hay problema (la primera llamada ya escribió en caché el HTML correcto, la segunda hace cache hit normal). Pero si `js_mode` fuese `"force"`/`"off"` y no se propagase, la segunda llamada saltaría la lectura de caché (por el propio diseño del Pitfall 1) y **repetiría la descarga/render innecesariamente** — desperdicio de red/Playwright, no un bug de corrección, pero sí de rendimiento. Propagar `js_mode` a `_lookup_title()` igual que ya se le propaga `use_cache`.

### Pitfall 3: `js_mode="force"` sin Playwright instalado no debe romper nada nuevo

`js_mode="force"` con Playwright no disponible debe degradar exactamente igual que hoy en modo `auto` (JS-03, Fase 11) — `_fetch_via_playwright()` ya devuelve `None` en ese caso y el código existente ya maneja `rendered is None` sin propagar excepción. No se necesita lógica nueva de degradación, solo asegurarse de que el camino `force` reutiliza la misma función sin duplicar el manejo de errores.

## Estrategia de Tests

Mismo patrón exacto que `tests/test_js_fallback.py` (Fase 11), añadiendo 2 ramas nuevas más el pitfall de caché:

1. **`js_mode="force"` invoca Playwright pese a HTML rico** — monkeypatch `_HTTP_SESSION.get` con HTML rico, `_fetch_via_playwright` mockeado para devolver un HTML distinto reconocible; `_fetch_raw(url, js_mode="force")` debe devolver el HTML del mock, no el rico original.
2. **`js_mode="off"` nunca invoca Playwright pese a HTML pobre** — monkeypatch `_HTTP_SESSION.get` con HTML pobre (SPA vacía), `_fetch_via_playwright` mockeado para lanzar `AssertionError` si se llama; `_fetch_raw(url, js_mode="off")` debe devolver el HTML pobre tal cual.
3. **`js_mode="force"` bypassa la lectura de caché** (Pitfall 1) — primera llamada con `js_mode="auto"` y `use_cache=True` cachea HTML estático; segunda llamada a la misma URL con `js_mode="force"` debe invocar Playwright pese al cache hit disponible.
4. **CLI: `--js` y `--no-js` a la vez falla explícito** — `monkeypatch.setattr(sys, "argv", [..., "--js", "--no-js"])`, esperar `SystemExit` con código 2 (comportamiento nativo de `argparse`, sin código propio que probar más allá del `pytest.raises`).
5. **CLI: `--js`/`--no-js` propagan el `js_mode` correcto** — monkeypatchear `extractor_url.extract_formatted_content` para capturar los kwargs de la llamada (mismo patrón que los tests de `use_cache`/`--no-cache` ya existentes en `test_cli.py`), verificar `kwargs["js_mode"] == "force"`/`"off"`/`"auto"` según los argumentos de `sys.argv`.
6. **Sin flags, comportamiento idéntico a v4.0** (no-regresión, FLAG success criterion 3) — reutilizar los 4 tests ya existentes de `tests/test_js_fallback.py` sin modificarlos; deben seguir pasando exactamente igual, confirmando que `js_mode="auto"` (el nuevo default explícito) no cambia nada observable frente al comportamiento implícito anterior.

## Security Domain

- Sin superficie nueva — mismos flags controlan un camino de código (Playwright) ya auditado en la Fase 11. `--js` no permite ejecutar código arbitrario adicional: sigue siendo "renderizar la misma URL con un browser headless", ya evaluado como riesgo equivalente a abrir la URL en cualquier browser.
- `--no-js` reduce superficie (nunca ejecuta Chromium) — estrictamente más seguro que el modo automático para el subconjunto de invocaciones donde se use, sin urgencia de análisis adicional.

## Assumptions Log

- Se asume que "saltar la lectura de caché pero seguir escribiendo en ella" (Pitfall 1) es el comportamiento deseado — es la única forma de que `--js`/`--no-js` tengan efecto garantizado sin añadir un tercer flag tipo `--no-cache` combinado a mano por el usuario cada vez. No fue una decisión explícita del usuario; queda documentada aquí para revisión en el plan/checkpoint si se prefiere otro comportamiento (p. ej. que el usuario deba combinar `--js --no-cache` manualmente).
- Se asume que `_run_batch()` aplica el mismo `js_mode` a **todas** las URLs del lote (una sola resolución de flags para todo el `--batch`), igual que ya hace con `--type`/`--selector`/`--timeout`/`--no-cache` — no hay per-URL override en el formato de archivo de entrada (una URL por línea, sin metadata adicional).

## Sources

### Primary (HIGH confidence)

- Lectura directa de este repo: `core.py` (`_fetch_raw`, `_fetch_soup`, `_looks_insufficient`, `_fetch_via_playwright`, `extract_formatted_content`, `extract_html_structure_to_markdown`), `extractor_url.py` (`main()`, `_run_batch()`, `_lookup_title()`, bloque `argparse` completo), `tests/test_js_fallback.py`, `tests/test_cli.py`.
- `.planning/phases/11-playwright-fallback/11-RESEARCH.md` y `11-01-SUMMARY.md` — decisiones ya tomadas en la Fase 11 que la Fase 15 extiende sin romper.

## Metadata

- Requirements cubiertos: FLAG-01, FLAG-02
- Depends on: Phase 11 (v4.0) — extiende `_fetch_raw()`/`_looks_insufficient()`/`_fetch_via_playwright()` ya existentes
- Bloquea: 15-01-PLAN.md (implementación)
