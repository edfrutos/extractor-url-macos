---
plan: 11-01
phase: 11-playwright-fallback
status: complete
completed: "2026-08-18"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - JS-01
  - JS-02
  - JS-03
  - JS-04
---

# Summary: 11-01 — Playwright Fallback para Contenido Dinámico

## What Was Built

`core.py` ahora detecta cuando la extracción estática devuelve contenido
insuficiente (posible SPA sin hidratar) y reintenta automáticamente con
Playwright antes de devolver un resultado pobre — sin flag manual, sin
tocar la app SwiftUI, y sin romper el comportamiento en sitios estáticos
normales ni en entornos donde Playwright no está instalado.

### core.py

- `_MIN_VISIBLE_TEXT_LENGTH = 100` — constante módulo-level junto a
  `_NOISE_TAGS`/`_MAIN_SELECTORS`. Ajustada de 200 a 100 durante la
  implementación: la fixture de test "HTML rico" ya existente
  (`edefrutos_me.html`) tiene solo 145 caracteres de texto visible real,
  por debajo del umbral original — el research ya preveía este ajuste
  como probable ("Assumptions Log").
- `_looks_insufficient(html_text: str) -> bool` — parsea el HTML, quita
  `_NOISE_TAGS`, mide el texto visible de `<body>`. Reutiliza el mismo
  patrón de fallback `lxml → html.parser` que `_fetch_soup`.
- `_fetch_via_playwright(url: str, timeout: int) -> Optional[str]` —
  import perezoso de `playwright.sync_api` (no es dependencia dura a
  nivel de módulo). Devuelve `None` si el paquete no está instalado
  (`ImportError`) **o** si el browser no está instalado / el render
  falla por timeout (`PlaywrightError`, capturado en un segundo nivel).
  Usa la API síncrona (`sync_playwright()`), `chromium.launch()`,
  `page.goto(timeout=timeout * 1000, wait_until="networkidle")` — nota
  la conversión segundos→milisegundos (Pitfall 2 del research).
- Integración en `_fetch_raw()`: 4 líneas insertadas entre la descarga
  HTTP y el guardado en caché — si `_looks_insufficient(html_text)` es
  `True`, se reintenta con `_fetch_via_playwright`; si devuelve contenido,
  sustituye `html_text` antes de cachear. El resto de la función (caché,
  return, manejo de errores de red) no cambia.

### requirements.txt

- Añadida la línea `playwright` (sin versión pinneada — el research
  dejó explícitamente esta decisión para el momento de instalar).

### CLAUDE.md

- Sección "Arquitectura": documentado el comportamiento del fallback en
  la descripción de `_fetch_raw()`.
- Sección "Entorno": añadido el paso `playwright install chromium` como
  paso aparte tras `pip install`, con nota de que sin él el fallback
  degrada en silencio (no rompe nada).

### tests/fixtures/spa_vacia.html (nueva)

HTML mínimo de una SPA sin hidratar (`<div id="root"></div>` + un
`<script src="...">`), usado como caso "insuficiente" en los tests de
la heurística.

### tests/test_js_fallback.py (nuevo)

8 tests cubriendo las 4 ramas:

- **Rama 1 (JS-01, heurística pura)**: HTML rico → `False`; SPA vacía →
  `True`; `<body></body>` → `True`; texto dentro de `<script>` no cuenta
  como contenido.
- **Rama 2 (JS-02, fallback exitoso)**: HTML estático pobre +
  `_fetch_via_playwright` mockeado devolviendo HTML rico → `_fetch_raw()`
  devuelve el HTML rico.
- **Rama 3 (JS-03, degradación)**: `_fetch_via_playwright` mockeado
  devolviendo `None` → `_fetch_raw()` devuelve el HTML estático original
  sin excepción. Más un test directo (sin mockear) que llama a
  `_fetch_via_playwright` en el entorno real de test (sin `playwright`
  instalado) y confirma que no propaga `ImportError`.
- **Rama 4 (no-regresión)**: HTML ya rico + `_fetch_via_playwright`
  mockeado para lanzar `AssertionError` si se invoca → confirma que
  sitios estáticos normales nunca pagan el coste de Playwright.

Todos los tests usan `monkeypatch.setattr(core, ...)` (mismo patrón que
`tests/test_converter.py`), nunca `unittest.mock.patch`, y ninguno lanza
un browser Chromium real.

## Bug encontrado y corregido durante la implementación

El umbral inicial (`_MIN_VISIBLE_TEXT_LENGTH = 200`, propuesto en el
research) hacía fallar `test_looks_insufficient_false_con_html_rico` y
`test_fetch_raw_no_llama_a_playwright_con_html_estatico_suficiente`: la
fixture de referencia `edefrutos_me.html` mide 145 caracteres de texto
visible tras quitar `_NOISE_TAGS`, por debajo del umbral original.
Corregido a `100` — deja margen bajo el contenido real más corto de la
suite sin dejar de detectar una SPA vacía (0 caracteres).

También se necesitó reordenar `# type: ignore[import-not-found]` **antes**
de `# pylint: disable=...` en la misma línea — mypy no reconoce la
directiva `type: ignore` si aparece después de otro comentario en la
misma línea física.

## Verification Status — ✅ VERIFICADO

Verificado en un venv Python 3.14 limpio creado en este sandbox
(`/tmp/claude-1000/test-venv`, deps instaladas vía `pip install -r
requirements.txt`-equivalente, **sin** `playwright` instalado a
propósito — confirma JS-03/JS-04 en su forma más real, no solo mockeada):

```
pytest tests/       → 28 passed (incluye los 8 nuevos de test_js_fallback.py)
pylint core.py      → 10.00/10
mypy core.py        → Success: no issues found
```

Nota: el `.venv` del propio repo (macOS, Python 3.12 vía symlink al
framework de Python.org) no es utilizable en este sandbox Linux — la
primera verificación se hizo con un venv equivalente creado ad-hoc.

**Confirmado también en el `.venv` real del Mac** (Python 3.12.4,
pytest-9.0.3, playwright 1.62.0 ya presente): `pytest tests/` → 28
passed en 2.48s, sin fallos. Doble verificación superada.

## Self-Check

- [x] `_looks_insufficient()` distingue HTML rico de SPA vacía (JS-01)
- [x] `_fetch_raw()` invoca Playwright solo cuando la heurística lo pide (JS-02)
- [x] Degradación sin excepción cuando Playwright no está disponible, verificada real (no solo mockeada) (JS-03)
- [x] Suite completa (`pytest tests/`) pasa sin `playwright` instalado — sin dependencia de browser real (JS-04)
- [x] `requirements.txt` y `CLAUDE.md` documentan la dependencia nueva y su instalación en dos pasos
- [x] pylint 10/10, mypy limpio
- [x] Sin regresiones en los 20 tests preexistentes
