---
phase: 06-export-pdf
plan: "01"
subsystem: python-core
tags: [title-extraction, json-contract, tdd, trafilatura, beautifulsoup]
dependency_graph:
  requires: []
  provides: [core._extract_title, json-title-field]
  affects: [extractor_url.main, tests/test_cli.py]
tech_stack:
  added: []
  patterns: [guard-doble-soup-title, trafilatura-metadata-fallback, monkeypatch-binding-local]
key_files:
  created:
    - tests/test_extract_title.py
  modified:
    - core.py
    - extractor_url.py
    - tests/test_cli.py
decisions:
  - "Monkeypatch sobre extractor_url._fetch_raw/_extract_title (binding local), no sobre core directamente"
  - "Guard doble soup.title and soup.title.string para evitar AttributeError con <title> vacío"
  - "Fallback trafilatura en bloque try/except broad con pylint:disable"
metrics:
  duration: "~8 min efectivos de implementación"
  completed: "2026-06-12"
  tasks_completed: 3
  files_modified: 4
---

# Phase 6 Plan 1: Python JSON title contract Summary

**One-liner:** Campo `title` añadido al contrato JSON CLI con extracción BeautifulSoup + fallback trafilatura y tests de contrato TDD.

## What Was Built

Implementación completa del requisito D-05 (campo `title` en `--json`) y D-07 (fallback):

1. **`core._extract_title(soup, html_text)`** — nueva función helper privada con dos caminos:
   - Camino 1: guard doble `soup.title and soup.title.string` + `.strip()` (Pitfall #5 RESEARCH)
   - Camino 2: `trafilatura.extract_metadata(html_text)` dentro de `try/except Exception` con `pylint: disable=broad-exception-caught`
   - Devuelve `Optional[str]`; pylint 10.00/10

2. **`extractor_url.py` bloque JSON de éxito ampliado** — imports `_fetch_raw`, `_extract_title`, `FeatureNotFound`; extracción de title antes del dict de éxito (segunda llamada = hit de caché); campo `"title": page_title`; bloque de error intacto.

3. **Tests del contrato JSON** — test existente ampliado con `assert "title" in output`; dos tests nuevos (`test_main_json_incluye_title_cuando_hay_titulo`, `test_main_json_title_null_sin_titulo`) con monkeypatch del binding local de `extractor_url`.

## Commits

| Task | Commit | Descripción |
|------|--------|-------------|
| Task 1 RED | `80ac79c` | test(06-01): add failing tests for _extract_title (RED) |
| Task 1 GREEN | `05078b6` | feat(06-01): implement _extract_title in core.py (GREEN) |
| Task 2 | `4c1f785` | feat(06-01): add title field to CLI JSON success output |
| Task 3 | `0a4616b` | test(06-01): add JSON contract tests for title field (GREEN) |

## Verification Results

- `pytest tests/ -x -q`: **20 passed** (14 previos + 4 nuevos en test_extract_title + 2 nuevos en test_cli)
- `python -c "import extractor_url, core"`: sin errores
- `pylint core.py`: 10.00/10
- `pylint extractor_url.py`: 10.00/10
- JSON de éxito incluye `title`; JSON de error no incluye `title`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Monkeypatch binding local en vez de core directamente**
- **Found during:** Task 3 — primer intento de test fallaba con `AssertionError: assert 'Example Domain' == 'Mi Título'`
- **Issue:** `extractor_url.py` importa `_fetch_raw` y `_extract_title` con `from core import ...`, creando un binding local. El `monkeypatch.setattr(core, "_fetch_raw", ...)` afecta a `core._fetch_raw` pero no al binding `extractor_url._fetch_raw` ya resuelto en el namespace del módulo.
- **Fix:** Cambiar todos los `monkeypatch.setattr(core, ...)` a `monkeypatch.setattr(extractor_url, ...)` en los tests nuevos. Se eliminó también el `import core` local dentro del test (era innecesario).
- **Files modified:** `tests/test_cli.py`
- **Commit:** `0a4616b`

## Known Stubs

Ninguno — toda la funcionalidad está implementada y conectada.

## Threat Flags

Ninguno — sin nuevas superficies de red, auth o esquema más allá de lo cubierto por el threat model del plan (T-06-01, T-06-02, T-06-03 todos aceptados o mitigados).

## Self-Check: PASSED

- [x] `core.py` contiene `def _extract_title(` en línea 197
- [x] `extractor_url.py` contiene `"title": page_title` en línea 308
- [x] `tests/test_cli.py` contiene `test_main_json_incluye_title_cuando_hay_titulo` y `test_main_json_title_null_sin_titulo`
- [x] `tests/test_extract_title.py` existe con 4 tests
- [x] Commits `80ac79c`, `05078b6`, `4c1f785`, `0a4616b` presentes en el log
- [x] `pytest tests/ -x -q`: 20 passed
