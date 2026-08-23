---
plan: 19-01
phase: 19-flags-filtrado-cli
status: complete
completed: "2026-08-23"
tasks_completed: 1
tasks_total: 1
requirements_covered:
  - CONTENT-01
  - CONTENT-02
  - CLIP-01
---

# Summary: 19-01 — Flags de filtrado CLI (`--no-images`/`--no-links`/`--clipboard`)

Fase pequeña, sin dependencias nuevas y con patrones ya establecidos
(mismo estilo que `--js`/`--no-js` de la Fase 15) — ejecutada directamente
en conversación sin research/plan formales previos, con el visto bueno
explícito del usuario ("Fase 19").

## What Was Built

### core.py

- `_strip_images(soup)` / `_strip_links(soup)`: helpers que mutan un
  `BeautifulSoup`/`Tag` in situ — `decompose()` para `<img>`,
  `unwrap()` para `<a>` (conserva el texto, quita solo la etiqueta).
- `extract_formatted_content()` y `extract_html_structure_to_markdown()`
  ganan `no_images: bool = False, no_links: bool = False`, mismo patrón
  que `js_mode` de la Fase 15 (parámetros opcionales, sin cambiar el
  comportamiento por defecto).
- `_format_soup_content()` aplica el stripping antes de bifurcar por
  `return_type` — cubre `text`/`html_string`/`soup_object` con una sola
  llamada.
- `extract_html_structure_to_markdown()` aplica el stripping sobre el
  `soup` ya limpiado (`_clean_soup`) antes de la bifurcación
  selector/trafilatura — cubre el camino con selector (`md_convert`) y el
  camino de fallback (`_main_content` + `md_convert`) con la misma
  mutación. Para el camino rápido de `trafilatura.extract()` (sin
  selector), se usan sus propios kwargs nativos
  `include_images=not no_images` / `include_links=not no_links` en vez de
  mutar el soup — trafilatura opera sobre el `html_text` crudo, no sobre
  el objeto `soup`.

### extractor_url.py

- `--no-images`/`--no-links` (flags independientes, combinables entre sí
  y con `--js`/`--no-js`/`--batch`) propagados a `extract_formatted_content()`
  en `main()` y `_run_batch()`.
- `--clipboard`: nuevo `_copy_to_clipboard(text)` que invoca
  `subprocess.run(["pbcopy"], input=text.encode("utf-8"), check=True)` —
  falla explícito (`sys.exit(1)`) si `pbcopy` no existe (`FileNotFoundError`,
  plataforma no macOS) o si falla (`CalledProcessError`), mismo principio
  de "fallar explícito" ya establecido (selector CSS inválido, `--batch`
  sin `--json`). Es **aditivo**: se invoca justo después de calcular
  `result_str`, antes de las ramas `--json`/`-o`/stdout — no reemplaza
  ninguna de ellas, cumple el Success Criterion 4 (flags "independientes
  y combinables... sin romper ningún contrato previo").
- `_build_parser()` extraída de `main()` (refactor de la construcción del
  parser a una función propia) — `main()` había subido a 53 sentencias
  (límite pylint 50) al añadir los 3 flags nuevos; extraer la
  construcción del parser (15 líneas de `add_argument`) baja pylint de
  9.98 a 10.00/10 sin tocar comportamiento, mismo patrón que la
  extracción de `_lookup_title()` en la Fase 14-01.

### tests/test_content_filters.py (nuevo)

10 tests cubriendo `_strip_images`/`_strip_links` a nivel unitario, y
`extract_formatted_content`/`extract_html_structure_to_markdown` con
`no_images`/`no_links` en los tres caminos de Markdown (trafilatura sin
selector, selector con `md_convert`, fallback `_main_content` +
`md_convert`).

### tests/test_cli.py (ampliado)

6 tests nuevos bajo "# --no-images / --no-links / --clipboard (Fase 19)":
propagación de kwargs, comportamiento por defecto sin flags, propagación
en `--batch`, invocación real de `pbcopy` (mockeada), fallo explícito sin
`pbcopy`, y que `--clipboard` no interfiere con la salida `--json`.

## Verification Status — ✅ VERIFICADO (sandbox, sin necesitar Mac)

Todo lo de esta fase es lógica Python pura (motor CLI/core, sin tocar la
app SwiftUI) — verificable completamente en el sandbox, sin checkpoint
humano necesario:

- `pytest tests/` — **67/67 tests pasan** (51 preexistentes + 10 nuevos en
  `test_content_filters.py` + 6 nuevos en `test_cli.py`).
- `pylint extractor_url.py core.py` — **10.00/10**.
- `mypy extractor_url.py core.py` — **Success: no issues found**.
- `--clipboard` no se pudo probar contra un `pbcopy` real (sandbox Linux,
  sin macOS) — verificado con `subprocess.run` mockeado en los tests;
  el mecanismo (`subprocess.run(["pbcopy"], ...)`) es estándar de macOS,
  mismo enfoque usado en herramientas similares. Recomendado (no
  bloqueante): probar `python extractor_url.py <url> --clipboard` en un
  Mac real y confirmar que `pbcmd`/⌘V pega el contenido esperado.

## Notas de diseño

- `--no-images`/`--no-links` NO tienen efecto visible en `--type text`
  puro sin selector en la mayoría de casos (el texto plano ya excluye
  `src`/`href` por construcción de `get_text()`) — el flag sigue
  aceptándose sin error, simplemente no cambia nada observable en ese
  caso concreto; el efecto real es en `html_string` y `markdown`, tal
  como pedía el Success Criterion 1/2 ("donde aplique").
- `--clipboard` en `--batch` copia el resultado de cada URL sucesivamente
  — al terminar, el portapapeles contiene solo el de la última URL
  procesada (last-write-wins). No se documentó como caso especial porque
  es el comportamiento esperable de "copiar N veces seguidas", no una
  ambigüedad real.
