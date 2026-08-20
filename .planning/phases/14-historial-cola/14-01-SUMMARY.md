---
plan: 14-01
phase: 14-historial-cola
status: complete
completed: "2026-08-20"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - HIST-01
  - HIST-03
---

# Summary: 14-01 — Historial y cola (motor Python)

## What Was Built

### core.py

- `_HISTORY_FILE = _CACHE_DIR / "history.jsonl"` — reutiliza el mismo
  directorio que la caché HTTP existente, sin nueva convención de rutas.
- `record_history_entry(entry: dict) -> None` — append de una línea JSON
  por entrada, best-effort (nunca lanza; `OSError` se traga en silencio,
  mismo principio que la caché HTTP).
- `load_history(limit: Optional[int] = None) -> list[dict]` — lee y
  parsea `history.jsonl`, ignora líneas corruptas sin fallar las demás,
  devuelve más reciente primero.

Las entradas **no incluyen el contenido extraído** — solo metadatos
(`timestamp`, `url`, `output_type`, `selector`, `status`, `char_count`,
`title`, `error_message`). Reabrir una entrada reextrae vía la caché HTTP
ya existente en vez de duplicar datos.

### extractor_url.py

- `_history_entry(...)` — construye el dict de una entrada con timestamp
  ISO 8601 UTC.
- `_lookup_title(url, timeout, use_cache)` — extraída de código antes
  duplicado entre `main()` y el nuevo `_run_batch()` (lookup de `<title>`
  vía segunda llamada a `_fetch_raw`, hit de caché).
- `record_history_entry` alimentado desde los 3 caminos CLI/GUI: éxito
  con `--json`, error, y GUI tkinter (`_worker()`).
- `--batch <archivo>` — nuevo flag, exige `--json` explícitamente (falla
  con `sys.exit(2)` si no, mensaje claro en stderr — mismo principio que
  "selector CSS inválido falla explícito" ya establecido en el proyecto).
  Lee URLs una por línea (ignora vacías), procesa cada una de forma
  independiente vía `_run_batch()`, imprime NDJSON (un JSON por línea).
  Si una URL falla, la siguiente se sigue procesando — nunca aborta el
  lote completo por un fallo individual.

**El contrato JSON de una extracción individual no cambió** — el
historial es un efecto secundario en disco, no un campo nuevo en la
salida impresa.

## Bug de calidad encontrado y corregido durante la implementación

El primer pase dejó `pylint` en 9.95/10 (`too-many-statements` en
`main()`, por la lógica de título+historial duplicada inline en dos
sitios). Corregido extrayendo `_lookup_title()` como función compartida
entre `main()` y `_run_batch()` — reduce el tamaño de `main()` y elimina
la duplicación real, no es solo un `# pylint: disable` cosmético.
`_history_entry()` sí lleva un disable puntual de `too-many-arguments`
(7 parámetros con nombre, todos legítimos para un builder de un dict con
varios campos opcionales — restructurar a un dict de entrada habría
perdido claridad en los call sites).

## Verification Status — ✅ VERIFICADO

Verificado en el mismo venv Python 3.14 ad-hoc de este sandbox usado en
fases anteriores (el `.venv` del repo es macOS-específico):

```
pytest tests/       → 40 passed (28 previos + 7 test_history.py + 5 nuevos en test_cli.py)
pylint core.py extractor_url.py → 10.00/10
mypy core.py extractor_url.py   → Success: no issues found
```

Recomendado (no bloqueante): repetir en el `.venv` real del Mac, mismo
patrón que en fases anteriores.

## Self-Check

- [x] `record_history_entry()`/`load_history()` en `core.py`, best-effort, reutilizan `_CACHE_DIR`
- [x] Entradas sin el campo `content`
- [x] `load_history()` ignora líneas corruptas
- [x] `--batch` exige `--json`, falla con `sys.exit(2)` si no
- [x] NDJSON — un objeto JSON por línea, uno por URL
- [x] Una URL fallida en `--batch` no aborta las siguientes
- [x] Contrato JSON de una extracción individual sin cambios
- [x] pytest + pylint + mypy en verde, sin regresiones
- [ ] HIST-02 (vista de historial en la app SwiftUI) — pendiente de una Fase 14-02 separada
