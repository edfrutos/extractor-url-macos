---
phase: 11-playwright-fallback
type: research
status: complete
created: "2026-08-18"
---

# Phase 11: Playwright Fallback para Contenido Dinámico — Research

## User Constraints (from PROJECT.md / conversación de definición del milestone)

### Locked Decisions (desde v4.0 planning)

- Fallback **automático por heurística** — sin flag manual `--js`/`--no-js` en v4.0.
- Playwright/Chromium **no se embebe** en el `.app` bundle SwiftUI — v4.0 es solo motor Python (CLI/venv).
- Si Playwright no está disponible en el entorno, la extracción **degrada al resultado estático** sin excepción no controlada (JS-03).
- Sin dependencia de un browser real en el pipeline de tests estándar (JS-04) — el CI de este repo no debe requerir `playwright install chromium` para pasar `pytest tests/`.

### Claude's Discretion

- Heurística exacta de "contenido insuficiente" (umbral de caracteres, qué se cuenta como texto visible).
- Punto de integración dentro de `core.py` (qué función envuelve/extiende).
- API de Playwright a usar (sync vs async) y manejo de timeouts/errores.
- Estructura de los tests de fallback (mocking vs. marker opcional para browser real).

### Deferred Ideas (OUT OF SCOPE — v4.0)

- Flag manual `--js`/`--no-js` (v5+ si la heurística resulta insuficiente en uso real).
- Embeber Playwright en la app SwiftUI (v5+).
- Selenium / WKWebView headless como alternativas — se descartan, Playwright es el único motor de rendering.

## Summary

El motor actual (`core.py`) descarga HTML con `requests` y lo parsea con `BeautifulSoup`/`trafilatura`. Esto falla silenciosamente en contenido (no lanza excepción, pero devuelve texto vacío o casi vacío) en páginas cuyo contenido real se inyecta vía JavaScript tras la carga inicial (SPAs con React/Vue/Angular, sitios con hidratación client-side). La Fase 11 añade una heurística de detección de "contenido insuficiente" tras la descarga estática, y si se activa, reintenta la misma URL renderizándola con Playwright (Chromium headless) antes de devolver un resultado pobre.

El punto de integración natural es `_fetch_raw()`: es la única función que hace la petición HTTP real, la usan tanto `extract_formatted_content` (vía `_fetch_soup`) como `extract_html_structure_to_markdown` directamente, y ya tiene la lógica de caché — el HTML renderizado por Playwright se cachea exactamente igual que el HTML estático, sin tocar el resto del pipeline.

## Análisis del Estado Actual del Código

### `_fetch_raw()` — situación exacta (core.py:76-124)

```python
def _fetch_raw(url: str, timeout: int = 15, use_cache: bool = True) -> Optional[tuple[str, str]]:
    ...
    response = _HTTP_SESSION.get(url, headers={"User-Agent": _USER_AGENT}, timeout=timeout)
    response.raise_for_status()
    response.encoding = response.apparent_encoding
    html_text = response.text
    final_url = response.url
    # ... guarda en caché, devuelve (html_text, final_url)
```

Devuelve `Optional[tuple[str, str]]` — `None` en error de red, o `(html_text, final_url)` en éxito. No hay ningún punto donde se evalúe si `html_text` tiene contenido real: un `<div id="root"></div>` vacío de una SPA es un "éxito" HTTP 200 indistinguible de una página real en el código actual.

### Precedente de heurística de "contenido insuficiente" ya existente

`extract_html_structure_to_markdown()` (core.py:308-318) ya tiene exactamente este patrón, pero aplicado *después* del fetch, para decidir entre `trafilatura` y el fallback a `_main_content()`:

```python
trafilatura_result = trafilatura.extract(html_text, ...)
if trafilatura_result and len(trafilatura_result.strip()) > 150:
    return _post_process_markdown(trafilatura_result)
# fallback a _main_content() + markdownify
```

Esto confirma que un umbral de longitud de texto ya es el patrón aceptado en este código para "¿hay contenido de verdad aquí?" — la Fase 11 reutiliza la misma idea, pero un nivel más abajo (sobre el HTML crudo, no sobre el markdown ya extraído), para que **todos** los `return_type` (text/html/markdown/soup_object) se beneficien del fallback, no solo el camino markdown.

### `_clean_soup()` / `_NOISE_TAGS` — reutilizables para medir contenido

`_NOISE_TAGS = ["script", "style", "nav", "header", "footer", "aside", "form", "noscript", "iframe"]` ya define qué tags no cuentan como contenido real. La heurística de JS-01 debe reutilizar esta misma lista (no inventar una nueva) para medir el texto visible del `<body>` tras quitar ruido — consistente con cómo `_format_soup_content` ya decide qué es "texto" para `return_type="text"`.

### Tests existentes — patrón de mocking (tests/test_converter.py)

Los tests monkeypatchean `core._fetch_raw` o `core._fetch_soup` **enteros** para aislar el resto del pipeline (`monkeypatch.setattr(core, "_fetch_raw", lambda _url, **_kwargs: (html, url))`). Esto significa que los tests actuales **no pasan por dentro de `_fetch_raw`** — la nueva lógica de fallback vive *dentro* de esa función, así que los tests de Fase 11 no pueden reusar ese patrón para probar el fallback en sí; necesitan una capa más abajo:

- Tests de la heurística pura (`_looks_insufficient`) — sin red, sin Playwright, input directo.
- Tests del wrapper Playwright (`_fetch_via_playwright`) — con la función de Playwright monkeypatcheada (no un browser real).
- Test de integración de `_fetch_raw` — monkeypatcheando `_HTTP_SESSION.get` (para simular el HTML estático pobre) y `_fetch_via_playwright` (para simular el render enriquecido), verificando que el resultado final es el de Playwright.
- Test de degradación (JS-03) — monkeypatcheando `_fetch_via_playwright` para que lance la excepción "Playwright no disponible" y verificando que `_fetch_raw` devuelve igualmente el HTML estático pobre, sin propagar la excepción.

## Standard Stack

- **`playwright`** (paquete oficial de Microsoft, PyPI: `playwright`) — único candidato serio para rendering headless controlado desde Python. Selenium es más pesado de configurar (webdriver managers externos) y no aporta nada que Playwright no resuelva mejor aquí; WKWebView headless no es portable fuera de macOS y este motor es multiplataforma (`core.py` no asume macOS).
- **API síncrona** (`playwright.sync_api`) — `core.py` es 100% síncrono (usa `requests`, no `asyncio`); mezclar la API async de Playwright obligaría a introducir un event loop solo para esta función, complejidad injustificada. La API sync bloquea el hilo igual que `requests.get()` ya hace — comportamiento consistente con el resto del módulo.
- **Instalación en dos pasos** (pitfall conocido de Playwright, no específico de este proyecto): `pip install playwright` instala solo el paquete Python; los binarios del browser se instalan aparte con `playwright install chromium`. Ambos pasos deben documentarse en `CLAUDE.md`/README — un `pip install -r requirements.txt` no basta.
- **Versión**: no fijar una versión exacta en este research — verificar `pip index versions playwright` en el momento de implementar y pinnear la última estable en `requirements.txt` (evitar fabricar aquí un número de versión que puede haber quedado desactualizado).

## Package Legitimacy Audit

`playwright` (PyPI) — mantenido por Microsoft, mismo equipo que el proyecto Playwright (Node/Java/.NET/Python), cientos de millones de descargas, release cadence activo. Sin señales de alerta (no es un paquete de terceros con nombre similar) — es la elección estándar de la industria para browser automation headless, sin alternativa que justifique un audit adicional.

## Architecture Patterns

### Diagrama de flujo — `_fetch_raw()` extendido

```
_fetch_raw(url)
  │
  ├─ cache hit? ──yes──► devolver (html_cacheado, url_cacheada)
  │                       (el HTML cacheado ya puede venir de Playwright
  │                        de una ejecución anterior — no se re-evalúa)
  │
  no
  │
  ▼
requests.get(url) ──error──► devolver None (comportamiento actual, sin cambios)
  │
  éxito → html_text, final_url
  │
  ▼
_looks_insufficient(html_text)?
  │
  no ──► guardar en caché, devolver (html_text, final_url)   [camino actual, 100% preservado]
  │
  sí
  ▼
_fetch_via_playwright(url, timeout) disponible y funciona?
  │
  ├─ sí, y el render NO es insuficiente ──► guardar en caché el HTML renderizado, devolver ese
  ├─ sí, pero el render SIGUE siendo insuficiente ──► guardar y devolver el render igual
  │    (mejor esfuerzo — no hay un tercer nivel de fallback; evita loop infinito)
  └─ no disponible / falla ──► aviso en stderr (una vez), devolver (html_text, final_url) original
                                 [JS-03: degradación, nunca una excepción no controlada]
```

### Patrón recomendado — funciones nuevas en `core.py`

```python
_MIN_VISIBLE_TEXT_LENGTH = 200  # constante junto a _NOISE_TAGS / _MAIN_SELECTORS

def _looks_insufficient(html_text: str) -> bool:
    """Heurística: ¿el HTML estático tiene contenido visible real?

    Reutiliza _NOISE_TAGS para no contar script/nav/footer/etc. como
    contenido. Un documento vacío, o casi vacío (SPA sin hidratar), da
    menos de _MIN_VISIBLE_TEXT_LENGTH caracteres de texto visible.
    """
    try:
        soup = BeautifulSoup(html_text, "lxml")
    except FeatureNotFound:
        soup = BeautifulSoup(html_text, "html.parser")
    for tag in soup(_NOISE_TAGS):
        tag.decompose()
    body = soup.find("body") or soup
    visible_text = body.get_text(strip=True)
    return len(visible_text) < _MIN_VISIBLE_TEXT_LENGTH


def _fetch_via_playwright(url: str, timeout: int) -> Optional[str]:
    """Renderiza `url` con Chromium headless y devuelve el HTML final.

    Devuelve None si Playwright no está instalado (paquete pip ausente)
    o si los binarios del browser no están instalados
    (`playwright install chromium` nunca ejecutado) — ambos casos son
    "no disponible", no un error fatal (JS-03).
    """
    try:
        from playwright.sync_api import Error as PlaywrightError
        from playwright.sync_api import sync_playwright
    except ImportError:
        return None

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            try:
                page = browser.new_page()
                page.goto(
                    url,
                    timeout=timeout * 1000,
                    wait_until="networkidle",
                )
                return page.content()
            finally:
                browser.close()
    except PlaywrightError as e:
        # Incluye "Executable doesn't exist" (browser no instalado) y
        # timeouts de navegación — ambos degradan, no propagan.
        print(f"Playwright no disponible o falló el render: {e}", file=sys.stderr)
        return None
```

Y en `_fetch_raw()`, tras obtener `html_text` de `requests` con éxito, insertar antes de cachear:

```python
if _looks_insufficient(html_text):
    rendered = _fetch_via_playwright(url, timeout)
    if rendered is not None:
        html_text = rendered
```

### Estructura de archivos afectados

- `core.py` — `_MIN_VISIBLE_TEXT_LENGTH`, `_looks_insufficient()`, `_fetch_via_playwright()`, e integración de 3 líneas en `_fetch_raw()`.
- `requirements.txt` — añadir `playwright`.
- `tests/test_converter.py` (o un nuevo `tests/test_js_fallback.py`) — tests de la heurística, del wrapper (mockeado) y de la integración.
- `tests/fixtures/` — un fixture HTML mínimo tipo SPA vacía (`<div id="root"></div>` + `<script src="bundle.js">`) para los tests de `_looks_insufficient`.
- `CLAUDE.md` / `README.md` — documentar el paso adicional `playwright install chromium`.

## Don't Hand-Roll

- **No reimplementar detección de "es una SPA"** vía parsing de `<script>` tags o frameworks conocidos (React/Vue/Angular signatures) — es frágil y se desactualiza; el umbral de texto visible es más robusto y ya es el patrón aceptado en este código (ver precedente de trafilatura arriba).
- **No gestionar el ciclo de vida del browser a mano** (pool de procesos, reintentos de arranque) — `sync_playwright()` como context manager ya garantiza cleanup; un `try/finally` sobre `browser.close()` es suficiente, no hace falta más infraestructura para un uso de "un fetch a la vez, bloqueante".
- **No usar `asyncio` en `core.py`** para dar soporte a la API async de Playwright — la API sync cubre el caso de uso exacto (bloquear hasta tener el HTML) sin tocar la arquitectura síncrona del resto del módulo.

## Common Pitfalls

### Pitfall 1: Confundir "paquete no instalado" con "browser no instalado"

`import playwright` puede tener éxito (el paquete pip está instalado) mientras que `p.chromium.launch()` falla en runtime con `Error: Executable doesn't exist at ...` porque nunca se corrió `playwright install chromium`. **Ambos** casos deben degradar sin excepción (JS-03) — el `try/except ImportError` en la importación NO es suficiente por sí solo; hace falta también capturar el `PlaywrightError` de `sync_playwright()/launch()/goto()` en un bloque separado.

### Pitfall 2: Timeout en segundos vs. milisegundos

El resto de `core.py` (`timeout: int = 15`) está en segundos; la API de Playwright (`page.goto(timeout=...)`) espera **milisegundos**. Olvidar el `* 1000` deja timeouts de Playwright de ~15ms en vez de 15s, causando fallos de timeout constantes y aparentando que "Playwright no funciona".

### Pitfall 3: `wait_until="networkidle"` puede colgarse en sitios con polling/websockets

Algunas SPAs mantienen conexiones long-polling o websockets abiertas indefinidamente, por lo que la red nunca queda "idle" y `page.goto()` puede tardar el timeout completo en cada llamada (varios segundos de más por extracción, solo en el subconjunto de URLs que activan el fallback). Es un trade-off aceptado explícitamente para v4.0 — no hay solución perfecta sin un flag manual (diferido a v5+); mitigar solo con el `timeout` explícito para que como mucho tarde `timeout` segundos, nunca cuelgue indefinidamente.

### Pitfall 4: Falsos positivos/negativos de la heurística

Páginas legítimamente cortas (una landing con una sola imagen y poco texto) pueden activar el fallback innecesariamente (falso positivo → latencia extra); SPAs que renderizan un esqueleto de carga con más de `_MIN_VISIBLE_TEXT_LENGTH` caracteres de texto de placeholder ("Cargando...", banners de cookies, etc.) pueden evadir la detección (falso negativo → sigue devolviendo contenido pobre). Es una heurística de mejor esfuerzo, documentada como tal — no es un objetivo de v4.0 conseguir precisión perfecta, solo cubrir el caso común (SPA con `<div id="root">` casi vacío).

### Pitfall 5: Tests que requieren un browser real bloquean CI

Si los tests de Playwright lanzan un browser real, `pytest tests/` deja de poder ejecutarse en cualquier entorno sin `playwright install chromium` corrido antes (varios cientos de MB de descarga) — inaceptable para JS-04 y para el flujo actual de este repo (`pytest tests/` sin pasos previos). Todos los tests salvo, como mucho, uno explícitamente marcado y saltable (`@pytest.mark.skipif` si el browser no está instalado) deben monkeypatchear `_fetch_via_playwright` o las funciones internas de `playwright.sync_api`, nunca lanzar Chromium de verdad.

## Estrategia de Tests para las 4 Ramas (JS-01..04)

### Rama 1 — Heurística pura (JS-01)

`_looks_insufficient()` probado directamente con fixtures: HTML rico (fixture ya existente, ej. `edefrutos_me.html`) → `False`; HTML de SPA vacía (`<div id="root"></div>` + script) → `True`. Sin red, sin Playwright, sin monkeypatch.

### Rama 2 — Fallback activado con éxito (JS-02)

`monkeypatch.setattr(core, "_fetch_via_playwright", lambda *_a, **_k: html_rico)` + `monkeypatch.setattr(core._HTTP_SESSION, "get", ...)` simulando respuesta HTTP con HTML pobre → `_fetch_raw()` debe devolver el HTML rico del mock de Playwright, no el pobre original.

### Rama 3 — Playwright no disponible, degradación (JS-03)

`monkeypatch.setattr(core, "_fetch_via_playwright", lambda *_a, **_k: None)` (simula ImportError o browser no instalado) + HTML pobre en la respuesta HTTP mockeada → `_fetch_raw()` debe devolver igualmente `(html_pobre, url)`, sin lanzar excepción.

### Rama 4 — Sitio estático normal no activa el fallback (regresión, no en el requirement pero crítico)

Con HTML rico ya en la respuesta HTTP mockeada, `_fetch_via_playwright` monkeypatcheado para lanzar `AssertionError` si se llama — verifica que sitios normales nunca pagan el coste de Playwright.

## Security Domain

- Sin superficie nueva de credenciales/secretos — Playwright solo renderiza páginas públicas, mismo modelo de confianza que `requests.get()` ya usado.
- Chromium headless ejecuta JavaScript arbitrario de la página objetivo — riesgo ya inherente a "renderizar contenido de terceros", equivalente a abrir la URL en un browser real; no hay sandboxing adicional que este proyecto deba implementar (Chromium headless ya corre en su propio proceso/sandbox de sistema operativo estándar). Sin acceso a filesystem/red interna desde la página renderizada más allá de lo que ya implica visitar esa URL en cualquier browser.
- El timeout explícito (`timeout * 1000` ms) actúa también como mitigación básica contra páginas maliciosas que intenten colgar el proceso indefinidamente.

## Assumptions Log

- Se asume que el umbral `_MIN_VISIBLE_TEXT_LENGTH = 200` es un punto de partida razonable, no un valor validado empíricamente contra un corpus de SPAs reales — ajustar en implementación si los tests con fixtures reales lo justifican.
- Se asume Chromium (no Firefox/WebKit) como browser de Playwright — es el más rápido de arrancar en headless y el más probado en CI de terceros; no hay requisito del proyecto que exija otro motor.
- Se asume que cachear el HTML renderizado por Playwright con la misma clave/TTL que el HTML estático es correcto — no se ha pedido invalidación diferenciada.

## Open Questions (RESOLVED)

- **¿Flag manual para forzar/desactivar el fallback?** → No en v4.0 (decisión explícita del usuario); queda en Future Requirements para v5+.
- **¿La app SwiftUI necesita cambios?** → No; v4.0 es exclusivamente `core.py`/`extractor_url.py`. `PythonBridge` seguirá funcionando igual — si el entorno bundleado no tiene Playwright, JS-03 garantiza que la extracción no se rompe, solo pierde la capacidad de renderizar SPAs (comportamiento idéntico al actual desde el punto de vista de la app).
- **¿Dónde vive el umbral de longitud?** → Constante módulo-level en `core.py`, junto a `_NOISE_TAGS`/`_MAIN_SELECTORS` — no un argumento de CLI (eso sería un flag manual, fuera de scope).

## Sources

### Primary (HIGH confidence)

- Lectura directa de `core.py` (este repo) — funciones `_fetch_raw`, `_fetch_soup`, `_clean_soup`, `_main_content`, `extract_html_structure_to_markdown`.
- Lectura directa de `tests/test_converter.py` (este repo) — patrón de mocking con `monkeypatch.setattr(core, ...)`.

### Secondary (MEDIUM confidence)

- Conocimiento general de la API pública de `playwright` (paquete Python oficial, `sync_api`, `sync_playwright()`, `chromium.launch()`, `page.goto(timeout=...)` en ms, `page.content()`) — basado en el diseño estable y ampliamente documentado del proyecto Playwright; no verificado contra la versión exacta que se instale en implementación (ver nota en Standard Stack sobre pinnear versión en el momento de implementar).

### Tertiary

- Ninguna fuente externa consultada en esta sesión (sin acceso a red en el research) — verificar en implementación el mensaje de error exacto de `Executable doesn't exist` y la firma exacta de `PlaywrightError`/`Error` en la versión instalada.

## Metadata

- Requirements cubiertos: JS-01, JS-02, JS-03, JS-04
- Depends on: nada nuevo — extiende `core.py` de v1.0, independiente de la app SwiftUI
- Bloquea: 11-01-PLAN.md (implementación)
