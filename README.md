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
python extractor_url.py --file pagina.html --type markdown   # HTML local (página guardada)
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
- Botón «Abrir HTML…» para convertir un archivo HTML local (p. ej. una página
  guardada desde el navegador cuando la web bloquea el acceso automatizado).
- Extracción asíncrona (`Task.detached`) sin bloquear la ventana; progreso y
  errores visibles inline.
- Preview del Markdown renderizado en `WKWebView`.
- Export a `.md`, `.html` autocontenido (CSS/JS inline, dark mode automático)
  y `.pdf` vectorial con texto seleccionable.
- Universal binary (arm64 + x86_64), Hardened Runtime ON, deployment target
  macOS 13.5+. App Sandbox OFF en la descarga directa y ON en la variante de
  la Mac App Store.
- Runtime Python embebido en el propio `.app`: el usuario no necesita
  instalar Python ni configurar rutas — funciona de serie desde el primer
  lanzamiento (v3.0). La descarga directa incluye además Playwright/Chromium
  para el fallback JS, en la arquitectura del Mac de build (v6.0); la
  variante de la Mac App Store usa `WKWebView`.
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
| v6.0 — Historial y Distribución Completa | ✅ Completado | Historial/cola de extracciones, flag manual `--js`/`--no-js`, canales beta de Sparkle, Chromium embebido en el bundle, pulido técnico |
| v7.0 — Flags CLI, rollouts, auto-actualización, distribución pública | ✅ Completado | `--no-images`/`--no-links`/`--clipboard`, rollouts por fases de Sparkle, actualización de dependencias Python puras sin release completo, distribución pública notarizada vía descarga directa |
| v8.0 — Verificación de release real | ✅ Completado | Release público v2.1 verificado, firma y notarización del Chromium embebido endurecidas |
| v9.0 — Release v2.2 | ✅ Completado | Caché y JS corregidos, accesibilidad y HIG en SwiftUI, icono actualizado |
| v10.0 — Release v2.3 | ✅ Completado | Conversión de HTML local (`--file` y «Abrir HTML…»), reintento ante 401/403, errores con detalle |
| v11.0 — Mac App Store | ✅ Completado | Variante con App Sandbox y `WKWebView`, publicada gratis en la Mac App Store (2.3) |

**Mac App Store:** la app está publicada, gratis, en la
[Mac App Store](https://apps.apple.com/es/app/extractor-url/id6825046299?mt=12).
Es una variante con App Sandbox: sin Sparkle ni Chromium, y con
`WKWebView` para las páginas con JavaScript (ver `RELEASING.md` §3.9).

**Descarga directa:** el `.app` firmado con Developer ID y notarizado por Apple
se publica en
[GitHub Releases](https://github.com/edfrutos/extractor-url-macos/releases)
— descarga directa, sin configuración adicional (ver `RELEASING.md`
§3.8). Las instalaciones existentes reciben actualizaciones
automáticamente vía Sparkle.

## Idioma

Este repositorio se documenta y comunica en español de España; nombres de
librerías, comandos y términos técnicos estándar se mantienen en inglés.
