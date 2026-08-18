# extractor-url

Utilidad local para extraer contenido legible desde una URL y convertirlo en
texto limpio, HTML o Markdown, sin depender de servicios externos.

El proyecto tiene dos capas:

1. **Motor Python** (`core.py` + `extractor_url.py`) — CLI + GUI `tkinter`,
   funciona de forma independiente en cualquier plataforma con Python 3.
2. **App macOS nativa** (`ExtractorApp/`, SwiftUI) — envuelve el motor Python
   vía subprocess y añade preview, export a Markdown/HTML/PDF y (desde v3.0)
   un runtime Python embebido para funcionar sin instalación previa.

## Funcionalidad

### Motor Python

- Descarga y parseo con `requests` + `BeautifulSoup` (fallback `lxml` →
  `html.parser`).
- Conversión a Markdown vía `trafilatura` (principal) con fallback a
  `markdownify` sobre el contenido limpiado.
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
- Runtime Python embebido en el propio `.app` (en construcción, ver estado
  más abajo): el usuario no necesita instalar Python ni configurar rutas.

## Entorno de desarrollo (motor Python)

```bash
source .venv/bin/activate
pip install requests beautifulsoup4 lxml markdownify trafilatura pytest
```

```bash
pylint extractor_url.py core.py    # usa .pylintrc local
mypy extractor_url.py core.py      # verificación de tipos
pytest tests/                      # 17 tests: conversor, CLI, título
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
core.py                   # descarga, caché, limpieza y conversión
tests/                    # pytest: conversor, CLI, título; fixtures HTML locales
scripts/                  # bundle-python.sh, verify-bundle.sh (empaquetado runtime v3.0)
ExtractorApp/              # proyecto Xcode de la app macOS SwiftUI
.planning/                 # metodología GSD: PROJECT.md, ROADMAP.md, STATE.md, fases
TESTING-HUMANO.md          # guía de verificación manual de la app macOS
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
| v3.0 — Standalone App | 🚧 En curso | Empaquetar el runtime Python dentro del `.app` para eliminar la configuración manual de rutas |

**v3.0 — fases:**

| Fase | Objetivo | Estado |
|---|---|---|
| 8. Bundle Python Runtime | Python universal + dependencias vendorizadas dentro de `Contents/Resources/` | ✅ Completada y verificada (verify-bundle 14 OK, 7/7 BundlePathTests) |
| 9. Bridge Auto-detección | `PythonBridge` resuelve rutas del bundle automáticamente, con fallback desde overrides de `UserDefaults` (v2.0) | ✅ Completada y verificada (13/13 PythonBridgeTests, 45/45 suite completa) |
| 10. UX Zero-Config | Badge "Usando Python incluido (Python X.X.X)" en `SettingsView` + sección de override colapsable como opción avanzada | ⚠️ Código completo, **sin compilar** — ver nota abajo |

> **Fase 10 — pendiente de verificación en Xcode.** El código (`PythonOperatingMode`
> en `SettingsViewModel`, `bundledPythonVersion()` en `PythonBridge`, badge +
> sección colapsable en `SettingsView`, 4 tests nuevos) se escribió en un
> entorno sin Xcode ni `swiftc`, así que a diferencia de las fases 3-9 no se ha
> podido ejecutar `xcodebuild build`/`test` para confirmarlo. De paso se
> corrigió `enum PathSource` (Fase 9) para declarar `Equatable` explícitamente
> — Swift no sintetiza esa conformidad aunque el enum no tenga valores
> asociados, y los tests existentes de `PythonBridgeTests` dependen de ella.
> Antes de dar la Fase 10 (y el milestone v3.0) por cerrados, hay que compilar
> y correr la suite en un Mac real — comandos exactos en
> `.planning/phases/10-ux-zero-config/10-01-SUMMARY.md`.

**Fuera de alcance (decisión explícita):** distribución en App Store, soporte
de páginas con renderizado JavaScript (Playwright), historial/cola de
extracciones, notarización para terceros — todo diferido a v4+ o descartado
por ser una herramienta de uso personal.

## Idioma

Este repositorio se documenta y comunica en español de España; nombres de
librerías, comandos y términos técnicos estándar se mantienen en inglés.
