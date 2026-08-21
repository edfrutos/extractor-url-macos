---
plan: 15-01
phase: 15-flag-manual-js
status: complete
completed: "2026-08-21"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - FLAG-01
  - FLAG-02
---

# Summary: 15-01 — Flag manual `--js`/`--no-js`

## What Was Built

### core.py

- `_fetch_raw(url, timeout=15, use_cache=True, js_mode="auto")` — nuevo
  parámetro `js_mode` con 3 valores:
  - `"auto"` (defecto): heurística `_looks_insufficient()` decide, idéntico
    a v4.0 (Fase 11), sin cambios de comportamiento.
  - `"force"`: renderiza siempre con Playwright, ignorando la heurística;
    degrada a HTML estático sin excepción si Playwright no está disponible
    (mismo principio JS-03 ya establecido).
  - `"off"`: nunca renderiza con Playwright, ignorando la heurística.
- La lectura de caché ahora se salta cuando `js_mode != "auto"` (la
  escritura al final no cambia) — sin esto, `--js`/`--no-js` no tendrían
  ningún efecto sobre una URL ya cacheada de una ejecución anterior.
- `_fetch_soup()`, `extract_formatted_content()` y
  `extract_html_structure_to_markdown()` propagan `js_mode` en paralelo a
  como ya propagan `use_cache`.

### extractor_url.py

- `--js`/`--no-js` — grupo mutuamente excluyente de `argparse`
  (`add_mutually_exclusive_group()`), sin código de validación manual;
  pasar ambos falla nativo con `SystemExit(2)`.
- `_resolve_js_mode(args)` — traduce los 2 booleanos a `"force"`/`"off"`/`"auto"`,
  calculado una sola vez en `main()` y en `_run_batch()`.
- `_lookup_title()` gana el parámetro `js_mode` (reenviado a su `_fetch_raw()`
  interno) para no repetir descarga/render en la segunda llamada que hace
  la salida `--json` al buscar el `<title>`.
- `--batch` aplica el mismo `js_mode` (una sola resolución) a todas las
  URLs del lote, igual que ya hace con `--type`/`--selector`/`--timeout`.

**El contrato JSON de una extracción individual no cambió** — `js_mode`
es un parámetro interno de control, no un campo nuevo en la salida.

## Verification Status — ✅ VERIFICADO

Verificado en un venv ad-hoc de este sandbox (Python 3.14, dependencias
instaladas vía pip: `requests`, `beautifulsoup4`, `lxml`, `markdownify`,
`trafilatura`, `pytest`, `pylint`, `mypy` — el `.venv` del repo es
macOS-específico, mismo patrón que fases anteriores):

```
pytest tests/                    → 51 passed (37 previos + 6 test_flag_js.py + 5 nuevos en test_cli.py)
pylint core.py extractor_url.py  → 10.00/10
mypy core.py extractor_url.py    → Success: no issues found
```

Smoke test manual adicional (CLI real, no mocks): `--help` muestra
`[--js | --no-js]` como grupo mutuamente excluyente; `--js --no-js` a la
vez falla con `error: argument --no-js: not allowed with argument --js`,
código de salida 2.

Recomendado (no bloqueante): repetir en el `.venv` real del Mac.

## Bug de calidad encontrado y corregido durante la implementación

`extract_formatted_content()` subió a 6 parámetros con el nuevo `js_mode`,
disparando `too-many-arguments`/`too-many-positional-arguments` de pylint
(9.95/10). Corregido con un disable puntual justificado — los 6 parámetros
son todos legítimos para la función pública principal del módulo, mismo
principio ya aplicado a `_history_entry()` en la Fase 14-01.

## Self-Check

- [x] Sin flags, comportamiento idéntico a v4.0 (confirmado: los 4 tests de `tests/test_js_fallback.py` pasan sin modificarlos)
- [x] `--js` fuerza Playwright aunque la heurística no lo active
- [x] `--no-js` desactiva Playwright aunque la heurística lo activaría
- [x] `--js`/`--no-js` tienen efecto real sobre una URL ya cacheada (bypass de lectura, no de escritura)
- [x] `--js` y `--no-js` a la vez fallan con `SystemExit(2)` vía `argparse`, sin validación manual
- [x] `js_mode` propagado a `_lookup_title()` en `main()` y `_run_batch()`
- [x] `--batch` aplica el mismo `js_mode` a todas las URLs del lote
- [x] pytest + pylint + mypy en verde, sin regresiones
