# extractor-url

Utilidad local para extraer contenido legible desde una URL y convertirlo en
texto limpio, HTML o Markdown, sin depender de servicios externos.

El proyecto tiene dos capas:

1. **Motor Python** (`core.py` + `extractor_url.py`) — CLI + GUI `tkinter`,
   funciona de forma independiente en cualquier plataforma con Python 3.
2. **App macOS nativa** (`ExtractorApp/`, SwiftUI) — envuelve el motor Python
   vía subprocess y añade preview, export a Markdown/HTML/PDF, con un runtime
   Python embebido (desde v3.0) para funcionar sin instalación previa.

## Funcionalidad

### Motor Python

- Descarga y parseo con `requests` + `BeautifulSoup` (fallback `lxml` →
  `html.parser`).
- Conversión a Markdown vía `trafilatura` (principal) con fallback a
  `markdownify` sobre el contenido limpiado.
- Fallback automático a Playwright (Chromium headless) cuando la extracción
  estática detecta contenido insuficiente (posible SPA sin hidratar) — sin
  flag manual; si Playwright no está instalado, degrada al resultado
  estático sin fallar (v4.0).
- Selector CSS opcional para acotar la extracción a un fragmento concreto;
  un selector inexistente o mal formado falla explícitamente en vez de
  ampliar el alcance en silencio.
- Caché de peticiones en `~/.cache/extractor-url` (desactivable).
- Salida como texto plano, HTML completo, Markdown o JSON estructurado
  (`--json`, usado como contrato por la app Swift).

```bash
python extractor_url.py https://example.com                  # texto limpio (stdout)
python extractor_url.py https://example.com --type html      # HTML completo
python extractor_url.py https://example.com --type markdown  # estructura Markdown
python extractor_url.py https://example.com --type markdown --selector article
python extractor_url.py https://example.com -o salida.txt    # guardar en archivo
python extractor_url.py https://example.com --json           # contrato JSON (usado por la app Swift)
python extractor_url.py                                      # GUI tkinter
python extractor_url.py --gui                                # GUI tkinter (explícito)
```

Otras opciones: `--timeout SEGUNDOS`, `--no-cache`.

### App macOS (ExtractorApp)

SwiftUI + `Foundation.Process()`. El motor Python no se modifica: Swift
gestiona la UI, el filesystem y la exportación.

- Campo URL, selector de tipo (text/html/markdown), selector CSS y timeout
  configurables desde la interfaz.
- Extracción asíncrona (`Task.detached`) sin bloquear la ventana; progreso y
  errores visibles inline.
- Preview del Markdown renderizado en `WKWebView`.
- Export a `.md`, `.html` autocontenido (CSS/JS inline, dark mode automático)
  y `.pdf` vectorial con texto seleccionable.
- Universal binary (arm64 + x86_64), Hardened Runtime ON, App Sandbox OFF,
  deployment target macOS 13.0+.
- Runtime Python embebido en el propio `.app`: el usuario no necesita
  instalar Python ni configurar rutas — funciona de serie desde el primer
  lanzamiento (v3.0). Playwright/Chromium (fallback JS del motor) queda
  fuera del bundle por su peso; la app sigue funcionando igual sin él.
- Auto-actualización vía Sparkle 2: comprobación automática en segundo
  plano (cada 24h) + ítem de menú "Buscar actualizaciones…"; releases
  firmados con EdDSA y notarizados por Apple, publicados en GitHub
  Releases (v5.0, ver `RELEASING.md`).

## Entorno de desarrollo (motor Python)

```bash
source .venv/bin/activate
pip install requests beautifulsoup4 lxml markdownify trafilatura playwright pytest
playwright install chromium        # binarios del browser — paso aparte, opcional para pasar los tests
```

```bash
pylint extractor_url.py core.py    # usa .pylintrc local
mypy extractor_url.py core.py      # verificación de tipos
pytest tests/                      # 28 tests: conversor, CLI, título, fallback JS
pytest tests/ -k nombre_del_test -v
pytest tests/ --cov=extractor_url
```

Para la app Swift, abrir `ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj`
en Xcode. Suite de tests con `Cmd+U` o:

```bash
xcodebuild test -scheme ExtractorApp -destination 'platform=macOS'
```

## Estructura del repositorio

```text
extractor_url.py          # punto de entrada CLI y GUI (tkinter)
core.py                   # descarga, caché, limpieza, conversión y fallback JS (Playwright)
tests/                    # pytest: conversor, CLI, título, fallback JS; fixtures HTML locales
scripts/                  # bundle-python.sh, verify-bundle.sh (v3.0), release-macos.sh (v5.0)
ExtractorApp/              # proyecto Xcode de la app macOS SwiftUI
.planning/                 # metodología GSD: PROJECT.md, ROADMAP.md, STATE.md, fases
TESTING-HUMANO.md          # guía de verificación manual de la app macOS
RELEASING.md               # cómo publicar una versión nueva (Sparkle, notarización)
AGENTS.md / CLAUDE.md      # guía para agentes IA que trabajan en este repo
```

## Situación de desarrollo

El repositorio sigue una metodología de planificación por fases (GSD) en
`.planning/`: `PROJECT.md` define alcance y decisiones, `ROADMAP.md` detalla
fases y criterios de éxito, `STATE.md` es el punto de retomo entre sesiones.

**Milestones:**

| Milestone | Estado | Resumen |
|---|---|---|
| v1.0 — Stabilization | ✅ Completado | Suite pytest, pylint 10/10, contratos CLI explícitos |
| v2.0 — SwiftUI Native App | ✅ Completado | App macOS nativa, bridge Python async, export MD/HTML/PDF, universal binary, UI premium |
| v3.0 — Standalone App | ✅ Completado | Runtime Python embebido en el `.app`, zero-config desde el primer lanzamiento, verificado con `xcodebuild` real (49 tests) |
| v4.0 — Contenido Dinámico (JS) | ✅ Completado | Fallback automático a Playwright para SPAs sobre el motor Python, verificado con `pytest` real (28 tests) |
| v5.0 — Auto-actualización (Sparkle) | ✅ Completado | Sparkle 2 integrado en la app, pipeline de release (`scripts/release-macos.sh`) con firma Developer ID + notarización + appcast EdDSA, primer release real publicado |

**Fuera de alcance (decisión explícita):** distribución en App Store,
historial/cola de extracciones, flag manual `--js`/`--no-js` (el fallback
JS es solo automático), embeber Playwright/Chromium en el `.app` bundle
SwiftUI (+300MB), canales beta/rollouts por fases de Sparkle — todo
diferido a v6+ o descartado por ser una herramienta de uso personal. La
notarización de v5.0 es solo para que las actualizaciones vía Sparkle no
muestren avisos de Gatekeeper en las instalaciones del autor — no implica
distribución pública a terceros.

## Idioma

Este repositorio se documenta y comunica en español de España; nombres de
librerías, comandos y términos técnicos estándar se mantienen en inglés.
