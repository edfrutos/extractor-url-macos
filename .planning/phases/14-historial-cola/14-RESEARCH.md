---
phase: 14-historial-cola
type: research
status: complete
created: "2026-08-20"
---

# Phase 14: Historial y cola de extracciones — Research

## User Constraints

### Locked Decisions (desde v6.0 planning)

- Alcance fijado por el usuario: historial + cola, en ese orden dentro de la propia fase (persistencia primero, cola después).
- Sin depender de servicios externos — el historial vive en almacenamiento local, consistente con el core value del proyecto.

### Claude's Discretion

- Formato exacto de persistencia (JSON, JSONL, SQLite) y ubicación del archivo.
- Si la cola se implementa en el motor Python (CLI), en la app SwiftUI, o en ambos.
- Qué datos exactos guarda cada entrada del historial (¿contenido completo o solo metadatos?).

### Deferred Ideas (OUT OF SCOPE — Fase 14)

- Búsqueda/filtrado avanzado del historial (por fecha, dominio, formato) — v7+ si hace falta.
- Sincronización del historial entre dispositivos — fuera de alcance total del proyecto (sin servicios externos).
- Límite de tamaño/purga automática del historial — v7+ si crece demasiado en uso real.

## Summary

El historial se implementa como un archivo JSON Lines (`history.jsonl`, una
entrada JSON por línea) en `~/.cache/extractor-url/` — el mismo directorio
que ya usa `_CACHE_DIR` para la caché HTTP (core.py:61), sin inventar una
ubicación nueva. Cada entrada guarda **metadatos**, no el contenido
completo de la extracción (evita duplicar datos ya cubiertos por la caché
HTTP existente, y mantiene el archivo de historial pequeño y rápido de
leer/parsear tanto desde Python como desde Swift).

El motor Python (`core.py`) posee la lógica de lectura/escritura
(`record_history_entry()`, `load_history()`); `extractor_url.py` la invoca
desde los puntos de entrada CLI (un único call site en `main()`, tras
construir el resultado, antes de imprimir salida) — consistente con el
patrón ya establecido del proyecto: `core.py` = lógica reutilizable,
`extractor_url.py` = orquestación de interfaz.

La cola (HIST-03) se resuelve en dos niveles independientes, sin cambiar
el contrato JSON de una extracción individual (que `PythonBridge.run()` ya
consume tal cual):

1. **CLI**: nuevo flag `--batch <archivo.txt>` (una URL por línea) que
   reutiliza `extract_formatted_content()`/`extract_html_structure_to_markdown()`
   URL a URL, imprimiendo NDJSON (un objeto JSON por línea) — solo válido
   combinado con `--json`, para mantener el alcance acotado a un caso de
   uso claro (automatización/scripting).
2. **App SwiftUI**: la cola es responsabilidad de la propia app — itera
   sobre una lista de URLs llamando a `PythonBridge.run()` una vez por
   URL (el bridge no cambia), actualizando el historial que ya escribe el
   motor Python en cada llamada individual. No hace falta un nuevo modo
   "batch" en el bridge — cubierto en la Fase 14-02 (Swift, checkpoint
   humano en Xcode), separada de esta primera mitad Python.

## Análisis del Estado Actual del Código

### `_CACHE_DIR` — precedente directo a reutilizar (core.py:61)

```python
_CACHE_DIR = Path.home() / ".cache" / "extractor-url"
```

Ya usado por `_fetch_raw()` para cachear `(html_text, final_url)` por URL
(hash SHA-256 como nombre de archivo). El historial vive en el mismo
directorio, archivo nuevo `history.jsonl` — sin nueva convención de rutas
que mantener.

### `extractor_url.py main()` — único punto de integración CLI

`main()` (extractor_url.py:208-321) ya construye un dict de resultado para
el modo `--json` (líneas 301-309: `status`, `url`, `selector`,
`output_type`, `char_count`, `content`, `title`) y tiene un camino de
error explícito (líneas 279-286). Es el único sitio que necesita llamar a
`record_history_entry()` — una vez por invocación CLI, tanto en éxito como
en error, antes de `_print_json_output()`/`sys.exit()`.

La GUI tkinter (`_ExtractorGui._extract()`, extractor_url.py:132-154) usa
`extract_formatted_content()` directamente, sin pasar por `main()`. Para
que el historial cubra también el uso desde GUI, `_worker()` debe llamar
igualmente a `record_history_entry()` tras `extract_formatted_content()`
— mismo dato disponible (`url`, `return_type`, `selector`, resultado),
salvo `title` (no se calcula en el camino GUI actual; puede quedar `None`
en las entradas de historial generadas desde GUI, aceptable — no es un
requisito que HIST-01 pida title obligatorio).

### `ExtractionResult` (Swift) — contrato ya usado por la app

`Models/ExtractionResult.swift` decodifica exactamente los campos que ya
imprime `--json` (`status`, `url`, `selector`, `output_type`, `char_count`,
`content`, `error_message`, `title`). El historial (Fase 14-02, Swift) leerá
`history.jsonl` de forma independiente al bridge — no pasa por
`PythonBridge.run()` ni por `ExtractionResult`, es un archivo que la app
lee directamente del disco.

## Standard Stack

- **JSON Lines (`.jsonl`)** — formato de facto para logs/historiales
  append-only: cada línea es un objeto JSON válido e independiente,
  append es una operación de una sola escritura (`open(path, "a")`), sin
  necesidad de reescribir el archivo entero ni de un parser JSON
  streaming complejo. Estándar, sin librería nueva que añadir (ya se usa
  `json` de la stdlib).
- **`datetime.now(timezone.utc).isoformat()`** — timestamp ISO 8601 UTC,
  parseable de forma nativa tanto por Python (`datetime.fromisoformat`)
  como por Swift (`ISO8601DateFormatter`) sin ambigüedad de zona horaria.

## Package Legitimacy Audit

Sin dependencias nuevas — todo con la stdlib de Python (`json`, `pathlib`,
`datetime`) y Foundation en Swift (`ISO8601DateFormatter`, `JSONDecoder`)
para la Fase 14-02.

## Architecture Patterns

### Esquema de una entrada de historial

```json
{
  "timestamp": "2026-08-20T12:34:56.789012+00:00",
  "url": "https://example.com/articulo",
  "output_type": "markdown",
  "selector": null,
  "status": "success",
  "char_count": 4231,
  "title": "Título del artículo",
  "error_message": null
}
```

Deliberadamente **sin el campo `content`** — reabrir una entrada del
historial reextrae desde la caché HTTP existente (`_fetch_raw` ya
devuelve el HTML cacheado si `use_cache=True` y la entrada no ha
expirado/sido purgada), no desde una copia duplicada del contenido dentro
del propio historial. Mantiene `history.jsonl` pequeño y evita el caso de
error donde el historial y la caché HTTP quedan desincronizados.

### `core.py` — nuevas funciones (sección "Historial", tras la de Caché)

```python
_HISTORY_FILE = _CACHE_DIR / "history.jsonl"

def record_history_entry(entry: dict) -> None:
    """Añade una entrada al historial de extracciones (best-effort).

    Nunca lanza — un fallo al escribir el historial no debe romper el
    flujo principal de extracción (mismo principio que la caché HTTP).
    """
    try:
        _CACHE_DIR.mkdir(parents=True, exist_ok=True)
        with _HISTORY_FILE.open("a", encoding="utf-8") as f:
            f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    except OSError:
        pass


def load_history(limit: Optional[int] = None) -> list[dict]:
    """Devuelve las entradas del historial, más reciente primero.

    limit: si se indica, devuelve como mucho las `limit` más recientes.
    Entradas con JSON corrupto (línea parcial por escritura interrumpida)
    se ignoran sin fallar la carga completa.
    """
    if not _HISTORY_FILE.exists():
        return []
    entries = []
    with _HISTORY_FILE.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    entries.reverse()
    return entries[:limit] if limit else entries
```

### `extractor_url.py main()` — punto de integración (ambos caminos, éxito y error)

```python
from datetime import datetime, timezone
from core import record_history_entry  # nuevo import

def _history_entry(url, output_type, selector, status, *, char_count=None, title=None, error_message=None) -> dict:
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "url": url,
        "output_type": output_type,
        "selector": selector,
        "status": status,
        "char_count": char_count,
        "title": title,
        "error_message": error_message,
    }
```

Llamada tras el `if result is None:` (camino de error) y tras construir
`page_title`/`result_str` (camino de éxito) — un único `record_history_entry(...)`
en cada rama, antes de `sys.exit()`/`_print_json_output()`/`print()`.

### `--batch` — flujo CLI

```python
parser.add_argument(
    "--batch",
    metavar="ARCHIVO",
    help="Archivo con una URL por línea; procesa todas secuencialmente (requiere --json)",
)
```

Si `args.batch` está presente: valida que `args.json` también lo esté
(si no, `sys.exit(2)` con mensaje explícito — mismo principio que
"selector CSS inválido falla explícito" ya establecido en el proyecto:
no ampliar silenciosamente el comportamiento). Lee las URLs no vacías del
archivo, y por cada una repite exactamente el mismo camino que ya existe
para una URL individual con `--json` (incluida la llamada a
`record_history_entry`), imprimiendo un objeto JSON por línea (NDJSON) en
vez de un único `json.dumps(..., indent=2)` — cambia el formato de salida
solo en modo `--batch`, el modo de una sola URL no cambia.

### Estructura de archivos afectados

- `core.py` — `_HISTORY_FILE`, `record_history_entry()`, `load_history()`.
- `extractor_url.py` — `_history_entry()` helper, llamada en `main()` (2 caminos) y en `_ExtractorGui._extract()._worker()` (GUI), nuevo flag `--batch`.
- `tests/test_history.py` (nuevo) — tests de `record_history_entry`/`load_history` con `tmp_path`/monkeypatch de `_CACHE_DIR` (nunca escribir en el `~/.cache` real durante tests, mismo principio que el resto de la suite).
- `tests/test_cli.py` — tests nuevos para `--batch` (NDJSON, error si falta `--json`).

## Don't Hand-Roll

- **No usar SQLite** para esto — un archivo JSONL append-only cubre el caso de uso (lectura secuencial, sin queries complejas) sin añadir una dependencia de esquema/migraciones para un historial de una sola tabla.
- **No reimplementar el parseo de fechas a mano** — `datetime.isoformat()`/`fromisoformat()` (Python) e `ISO8601DateFormatter` (Swift) ya cubren el formato sin lógica custom de parsing propensa a errores de zona horaria.
- **No añadir un modo "batch" nuevo al contrato JSON de `PythonBridge.run()`** — la cola de la app SwiftUI se resuelve reutilizando el bridge existente en un bucle, evitando cambiar un contrato ya estable y testeado (13 tests de `PythonBridgeTests` dependen de la forma actual de `run()`).

## Common Pitfalls

### Pitfall 1: Escribir el historial ANTES de saber si la extracción tuvo éxito

Si `record_history_entry()` se llama antes de que `result`/`page_title`
estén completamente resueltos, una entrada de historial podría quedar
con datos parciales o inconsistentes. Llamar siempre DESPUÉS de tener el
resultado final (éxito o error) completamente determinado — nunca en
medio del proceso de extracción.

### Pitfall 2: Historial corrompido por escritura concurrente

Si en el futuro se ejecutan extracciones en paralelo (no es el caso hoy:
CLI es un proceso por invocación, GUI usa un solo `threading.Thread` a la
vez), dos escrituras simultáneas a `history.jsonl` podrían entrelazar
líneas. Mitigado por diseño: cada `open(path, "a")` + `write()` de una
línea completa terminada en `\n` es atómico a nivel de sistema de
archivos para escrituras pequeñas en la mayoría de filesystems POSIX
(incluido APFS) — no se necesita locking explícito para el volumen de
escritura de este caso de uso (una entrada por extracción, invocaciones
secuenciales).

### Pitfall 3: `--batch` sin `--json` ampliando el comportamiento en silencio

Si `--batch` funcionara también sin `--json` (imprimiendo N resultados en
texto plano mezclados sin separador claro), sería exactamente el tipo de
"ampliación silenciosa del alcance" que el proyecto ya evita explícitamente
para selectores CSS inválidos (ver CLAUDE.md). Por eso `--batch` exige
`--json` y falla con `sys.exit(2)` si no se cumple, en vez de intentar
inventar un formato de salida de texto plano para múltiples resultados.

### Pitfall 4: Historial creciendo sin límite

No hay purga automática en esta fase (ver Deferred Ideas) — un uso muy
intensivo podría hacer crecer `history.jsonl` indefinidamente. Aceptado
como limitación conocida de v6.0; `load_history(limit=N)` ya soporta
limitar cuántas entradas se leen (para que la UI no tenga que cargar un
archivo enorme entero), pero el archivo en sí no se trunca. Documentar
como ítem diferido, no bloqueante para cerrar la fase.

## Estrategia de Tests

- `record_history_entry`/`load_history`: monkeypatch de `core._CACHE_DIR`
  y `core._HISTORY_FILE` a un `tmp_path` de pytest — nunca tocar
  `~/.cache/extractor-url/history.jsonl` real durante los tests (mismo
  principio que `use_cache=False` ya aplicado en `tests/test_js_fallback.py`).
- Caso de línea corrupta: escribir una línea JSON inválida a mano en el
  archivo de test y verificar que `load_history()` la salta sin fallar
  las demás entradas válidas.
- Caso `limit`: verificar que devuelve como mucho `limit` entradas, las
  más recientes primero.
- `--batch` sin `--json`: verificar `sys.exit(2)` y mensaje explícito en
  stderr (patrón ya usado en `test_cli.py` con `capsys`).
- `--batch` con `--json`: verificar NDJSON — tantas líneas como URLs en el
  archivo, cada línea un JSON válido decodificable por separado.

## Security Domain

- El historial guarda URLs visitadas por el usuario en texto plano local
  — mismo nivel de sensibilidad que el historial de cualquier navegador;
  no se transmite a ningún servicio externo (consistente con el core
  value del proyecto). No requiere cifrado adicional para un uso personal
  de un solo usuario en su propio Mac.
- `record_history_entry()` no interpola las URLs ni ningún campo en
  comandos de shell ni en queries — solo `json.dumps()`, sin superficie
  de inyección.

## Assumptions Log

- Se asume que las entradas de historial NO guardan el contenido completo
  extraído — solo metadatos, reextrayendo desde la caché HTTP existente
  si el usuario quiere reabrir una entrada. Si en el futuro se necesita
  "ver el resultado exacto de entonces" sin depender de que la caché HTTP
  siga viva (puede expirar/purgarse independientemente), habría que
  reconsiderar esta decisión — anotado como trade-off consciente, no un
  descuido.
- Se asume que `--batch` requiere `--json` — decisión de acotar el
  alcance, no una limitación técnica insalvable; se puede relajar en v7+
  si se pide explícitamente un modo texto plano para batch.
- Se asume que la GUI tkinter también debe alimentar el historial (no
  solo el camino `--json` que usa la app SwiftUI) — consistente con que
  "historial de extracciones" es una función general del motor, no
  específica de un frontend.

## Open Questions (RESOLVED)

- **¿SQLite o archivo plano?** → JSONL, más simple para el volumen de datos esperado (uso personal, no miles de extracciones/día).
- **¿Guardar el contenido completo en el historial?** → No, solo metadatos; reabrir reextrae vía la caché HTTP ya existente.
- **¿Dónde vive la cola — CLI, app, o ambos?** → Ambos, mecanismos independientes: `--batch` en CLI (requiere `--json`) y bucle sobre el bridge existente en la app (Fase 14-02, no cambia el contrato de `PythonBridge.run()`).

## Sources

### Primary (HIGH confidence)

- Lectura directa de este repo: `core.py` (`_CACHE_DIR`, `_fetch_raw`), `extractor_url.py` completo (`main()`, `_ExtractorGui`), `ExtractionViewModel.swift` (integración `bridge.run()`), `Models/ExtractionResult.swift` (contrato JSON ya establecido).

### Secondary / Tertiary

- Ninguna fuente externa consultada — JSON Lines y `datetime.isoformat()` son estándares de la librería estándar de Python bien conocidos, sin necesidad de verificación externa.

## Metadata

- Requirements cubiertos por esta research: HIST-01, HIST-03 (motor Python); HIST-02 (app SwiftUI) queda para una Fase 14-02 separada tras verificar el lado Python.
- Depends on: nada nuevo — extiende `core.py`/`extractor_url.py` de v1.0, reutiliza `_CACHE_DIR` ya existente.
- Bloquea: 14-01-PLAN.md (implementación Python, autónoma y testeable en este sandbox)
