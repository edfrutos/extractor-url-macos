---
phase: 01-validacion-automatica-del-conversor
reviewed: 2026-06-03T12:16:19Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - extractor_url.py
  - tests/test_converter.py
  - tests/fixtures/edefrutos_me.html
  - tests/fixtures/sample_selector.html
  - CLAUDE.md
  - NOTEBOOK.md
findings:
  critical: 0
  warning: 4
  info: 1
  total: 5
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-06-03T12:16:19Z
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

Se ha revisado un proyecto Python de un solo archivo con CLI + GUI tkinter y pipeline de extracción `requests` → `BeautifulSoup` → `trafilatura`/`markdownify`, junto con su suite inicial de `pytest` y la documentación principal.

La base de la fase es buena: los tests usan fixtures locales, no dependen de red real y cubren los helpers principales del flujo Markdown. Aun así, hay cuatro riesgos funcionales relevantes: una regresión clara en el comando documentado `--gui`, salida de error con código de retorno incorrecto al fallar el guardado, una política peligrosa cuando falla un selector CSS explícito y documentación técnica que vuelve a describir bugs de una implementación ya eliminada. Además, faltan pruebas sobre la interfaz pública CLI, así que varias de estas regresiones no quedarían detectadas automáticamente.

## Warnings

### WR-01: `--gui` explícito está roto por el argumento posicional obligatorio

**File:** `extractor_url.py:465-492`
**Issue:** `main()` declara `url` como argumento posicional obligatorio antes de evaluar `args.gui`. Eso hace que `python extractor_url.py --gui`, comando documentado en `AGENTS.md` y `CLAUDE.md`, falle en `argparse` con exit code 2 en vez de abrir la interfaz.
**Fix:** Haz que `url` sea opcional y valida su presencia solo cuando no se use `--gui`.

```python
def main() -> None:
    parser = argparse.ArgumentParser(description="Extractor de contenido web")
    parser.add_argument("url", nargs="?", help="URL de la página web")
    parser.add_argument("--gui", action="store_true", help="Abrir interfaz gráfica")
    # resto de argumentos...

    args = parser.parse_args()

    if args.gui:
        _run_gui()
        return

    if not args.url:
        parser.error("La URL es obligatoria salvo con --gui")
```

### WR-02: fallo al guardar en `-o/--output` no propaga error al proceso

**File:** `extractor_url.py:509-516`
**Issue:** Si la escritura del fichero falla, el programa imprime el error en `stderr`, pero no termina con código distinto de cero. Para scripts o automatizaciones, eso se interpreta como ejecución correcta aunque el resultado no se haya guardado.
**Fix:** Sal con `sys.exit(1)` tras el `OSError`.

```python
if args.output:
    try:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(result_str)
        print(f"Contenido guardado en: {args.output}")
    except OSError as e:
        print(f"Error al guardar archivo: {e}", file=sys.stderr)
        sys.exit(1)
```

### WR-03: un selector CSS inválido amplía silenciosamente el alcance de extracción

**File:** `extractor_url.py:153-172`
**Issue:** `_apply_selector()` devuelve el documento completo cuando el selector no encuentra nada. En un flujo con selector explícito, un typo o un cambio de DOM puede terminar extrayendo contenido no deseado en lugar de fallar de forma visible. Eso oculta regresiones y puede mezclar contenido fuera del bloque que el usuario quería acotar.
**Fix:** Devuelve `None` o lanza una excepción controlada cuando el selector no resuelva, y haz que los llamadores fallen de forma explícita.

```python
def _apply_selector(soup: BeautifulSoup, selector: str) -> Optional[Tag]:
    found = soup.select_one(selector)
    if found and isinstance(found, Tag):
        return found
    print(
        f"Selector '{selector}' no encontró ningún elemento.",
        file=sys.stderr,
    )
    return None
```

### WR-04: `NOTEBOOK.md` vuelve a documentar bugs de un conversor ya retirado

**File:** `NOTEBOOK.md:38-52`
**Issue:** La sección “Contras y bugs detectados” sigue describiendo problemas de `_process_element`, `depth`, tablas manuales y listas ordenadas de una implementación anterior que ya no existe en `extractor_url.py`. Eso contradice el objetivo de la fase (“alinear documentación técnica con la implementación actual”) y puede desviar siguientes fases hacia deuda ya cerrada.
**Fix:** Reescribe esa sección para reflejar limitaciones reales del código actual o muévela a un bloque histórico explícito.

```markdown
### ❌ Limitaciones actuales

1. `--gui` explícito falla si no se hace opcional la URL en argparse.
2. Si un selector CSS no encuentra nodo, hoy se amplía al documento completo.
3. No hay renderizado JavaScript ni reintentos HTTP.
4. La suite aún no cubre la interfaz pública CLI.
```

## Info

### IN-01: la suite no cubre la interfaz pública CLI ni varios caminos de error

**File:** `tests/test_converter.py:48-98`
**Issue:** La suite actual cubre bien helpers y flujo Markdown con fixtures, pero no comprueba `main()`, el caso `--gui` sin URL, el fallo de escritura con `-o` ni el comportamiento cuando un selector explícito no encuentra coincidencias. Varias regresiones visibles para usuario final no quedarían atrapadas por `pytest`.
**Fix:** Añade tests de CLI con `monkeypatch` sobre `sys.argv`, `_run_gui`, `capsys` y rutas no escribibles.

```python
def test_main_abre_gui_sin_url(monkeypatch: pytest.MonkeyPatch) -> None:
    called = {"gui": False}
    monkeypatch.setattr(sys, "argv", ["extractor_url.py", "--gui"])
    monkeypatch.setattr(extractor_url, "_run_gui", lambda: called.__setitem__("gui", True))
    extractor_url.main()
    assert called["gui"] is True
```

---

_Reviewed: 2026-06-03T12:16:19Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
