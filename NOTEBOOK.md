# NOTEBOOK.md — extractor-url → app macOS nativa

Análisis del estado actual, diagnóstico de problemas y plan de evolución hacia una utilidad macOS nativa de scraping HTML → Markdown.

---

## 1. Estado actual — Qué hay

### Arquitectura

Un único archivo Python (`extractor_url.py`, ~520 líneas) con cuatro capas:

| Función | Rol |
|---|---|
| `_fetch_raw(url)` + `_fetch_soup(url)` | Descarga HTTP con User-Agent, URL final tras redirecciones y fallback lxml→html.parser |
| `_clean_soup()` / `_main_content()` / `_apply_selector()` | Limpieza DOM, resolución de URLs relativas, auto-detección de contenido principal y selector CSS opcional |
| `extract_formatted_content()` / `extract_html_structure_to_markdown()` | Dispatcher y pipeline Markdown con `trafilatura` + fallback `markdownify` |
| `_run_gui()` / `main()` | GUI tkinter + CLI argparse; la extracción GUI corre en `threading.Thread` |

**Stack**: Python 3.12, requests, BeautifulSoup4, lxml, tkinter, `markdownify`, `trafilatura`.  
**Entorno**: `.venv` local; sigue pendiente dejar `requirements.txt` reducido a dependencias reales.  
**Artefactos de prueba**: fixtures HTML locales en `tests/fixtures/`, suite `pytest` en `tests/test_converter.py` y muestras históricas en `pruebas/`.

---

## 2. Diagnóstico — Pros y contras

### ✅ Pros

- Código limpio, bien tipado, con docstrings y manejo correcto de errores (`sys.stderr`, `sys.exit(1)`).
- Fallback automático de parser (lxml → html.parser).
- Detección de encoding con `apparent_encoding` (evita el problema más habitual de mojibake).
- Tres modos de salida ya definidos (texto, HTML, Markdown).
- GUI + CLI en el mismo archivo sin duplicación de lógica.
- `requirements.txt` mínimo y limpio.
- `.pylintrc` local para ignorar ficheros temporales de formateo.

### ❌ Contras y bugs detectados

#### Calidad del Markdown (crítico)

El fichero `pruebas/edefrutos_me.md` evidencia los problemas reales del conversor:

1. **Contenido duplicado**: el bloque de navegación aparece dos veces porque `_process_element` no elimina header/nav/footer (solo lo hace `extract_formatted_content` en modo `text`).
2. **Ítems de menú concatenados sin espacios**: `NY00.-New YorkNY01.-Primer Contacto…` — los `<li>` que contienen `<a>` no separan el texto del hijo.
3. **URLs de login filtradas**: `https://edefrutos.me/wp-login.php?redirect_to=…` aparece como enlace de primer nivel.
4. **Tablas rotas**: cabecera siempre `| Columna |` en lugar de las columnas reales; `soup.find_all("tr")` dentro de `_process_element` busca en todo el documento, no en la tabla actual.
5. **Listas ordenadas siempre `1.`**: no se incrementa el contador.
6. **Los `<a>` se extraen antes de que su `<p>` padre genere texto**: los enlaces inline dentro de párrafos se convierten en bloques sueltos, rompiendo el flujo narrativo.
7. **`depth` no sirve para nada**: se pasa a la recursión pero no afecta al comportamiento de `<a>`, `<img>`, `<hN>`, `<p>`.
8. **No se manejan**: `<strong>`, `<em>`, `<code>`, `<pre>`, `<blockquote>`, `<hr>`.
9. **Encoding residual en log**: `â€™` en lugar de `'` — `apparent_encoding` falla en algunos sitios; falta normalización Unicode explícita.

#### Funcionalidad (importante)

10. **Sin renderizado JavaScript**: no funciona con webs SPA/React/Vue.
11. ✅ **Resolución de URLs relativas ya implementada** en `_clean_soup()` con `urljoin`.
12. ✅ **GUI ya no se bloquea**: la extracción corre en `threading.Thread` y vuelve al hilo principal con `root.after(...)`.
13. ✅ **Selector de contenido ya implementado**: CLI y GUI aceptan selector CSS para acotar el contenido.
14. **Sin historial ni favoritos** en la GUI.
15. **Sin progreso en CLI** (solo silencio o error).

#### Empaquetado/UX macOS (relevante para el objetivo)

16. **tkinter no es nativo en macOS**: aspecto genérico, sin soporte de Dark Mode, sin integración con el sistema (drag & drop, Services, barra de menú nativa, etc.).
17. **No hay `.app` bundle**: el usuario debe ejecutar desde terminal.
18. **`ver_comprimido.sh` es ajeno al proyecto** — debe separarse o eliminarse.

---

## 3. Objetivo — Qué hay que hacer

### Visión

**Utilidad macOS nativa para scraping de páginas web a Markdown fiel**, con:
- Interfaz nativa (menú, atajos, Dark Mode, drag & drop de URLs).
- Conversor HTML→Markdown de alta fidelidad (inline formatting, bloques de código, tablas reales, listas numeradas, blockquotes).
- Soporte opcional de páginas JavaScript.
- Exportación a archivo, portapapeles o nota rápida.

---

## 4. Decisiones de arquitectura

### 4.1 Stack recomendado

| Capa | Opción recomendada | Alternativa |
|---|---|---|
| **Frontend / UI** | SwiftUI (app macOS nativa) | pywebview + HTML/CSS propio |
| **Backend / lógica** | Python (proceso local, FastAPI ligero) | Python puro empaquetado con py2app |
| **Conversor HTML→MD** | `markdownify` o `trafilatura` | `html2text` |
| **Renderizado JS** | `playwright` (Chromium headless) | `selenium` |
| **Empaquetado** | py2app (si solo Python) / Swift app + subprocess | PyInstaller |

#### Opción A — Solo Python, empaquetado como .app (camino mínimo)

```
extractor_url.py  →  pywebview (UI web moderna)  →  py2app (.app bundle)
```

- Ventajas: reutiliza todo el código actual, sin nuevo lenguaje.
- Desventajas: pywebview usa WKWebView pero la UI hay que construirla en HTML; no es 100% nativo.

#### Opción B — SwiftUI + backend Python (camino óptimo)

```
SwiftUI app  →  subprocess / local HTTP (FastAPI)  →  Python scraper
```

- Ventajas: UI 100% nativa, acceso a APIs del sistema, firma y distribución trivial.
- Desventajas: requiere aprender Swift/SwiftUI mínimo; más código.

**Recomendación: Opción A como MVP rápido, Opción B como versión 1.0.**

---

## 5. Plan de trabajo por fases

### Fase 0 — Arreglar el conversor HTML→Markdown ✅ COMPLETADA

**Pipeline implementado** (`extractor_url.py`, commit inicial Fase 0):

1. `_fetch_raw(url)` → `(html_text, url_final)` — nueva función base; `_fetch_soup` la reutiliza.
2. `_clean_soup(soup, base_url)` — elimina `_NOISE_TAGS` + comentarios HTML; resuelve URLs relativas con `urljoin`.
3. `_main_content(soup)` — detecta `main / article / [role="main"] / #content / .entry-content / …`
4. `_post_process_markdown(text)` — normalización NFC, máx. 2 líneas vacías, sin trailing spaces, elimina separadores de nav.
5. `extract_html_structure_to_markdown` — pipeline de dos pasos:
   - **Paso 1**: trafilatura (`output_format="markdown"`, `favor_recall=True`, `no_fallback=False`) → usa cuando devuelve > 150 chars.
   - **Paso 2**: markdownify (`heading_style="ATX"`, `bullets="-"`) sobre `_main_content` limpio.

**Resultado verificado** (edefrutos.me portada WordPress):
- Antes: 101 líneas con nav duplicado, URLs login, ítems de menú concatenados.
- Después: 14 líneas con solo los extractos reales y URLs absolutas resueltas.

**Tareas pendientes de esta fase:**

- [x] **Crear tests** en `tests/test_converter.py` con HTML fixtures locales (no webs reales).
- [ ] Ampliar la suite para más edge cases antes de abrir nuevas fases funcionales.

**Librerías a evaluar:**

| Librería | Ventaja | Inconveniente |
|---|---|---|
| `markdownify` | Fiel, mantenida, configurable | No extrae "contenido principal" automáticamente |
| `trafilatura` | Extrae el cuerpo del artículo, ignora nav/footer | Salida menos configurable; orientada a artículos |
| `html2text` | Muy simple | Output ruidoso, configuración limitada |
| `pandoc` (subprocess) | Calidad excelente | Dependencia externa, no pythónica |

**Recomendación**: `markdownify` para conversión fiel + `trafilatura` para extracción del cuerpo principal. Usar ambas en pipeline:

```
HTML → trafilatura (extrae <article>/<main>) → markdownify (convierte a Markdown)
```

---

### Fase 1 — Descarga robusta

- [x] **Threading**: la petición ya se mueve a un hilo separado (`threading.Thread`) para no bloquear la UI.
- [ ] **Renderizado JS opcional**: integrar `playwright` con flag `--js` / opción en UI. Playwright headless descarga la página tras ejecutar JavaScript.
- [ ] **Reintentos**: `requests` con `urllib3.Retry` (3 intentos, backoff exponencial).
- [ ] **Timeout configurable**: exponer el timeout en la UI / argumento CLI.
- [ ] **Caché local**: guardar el HTML descargado en `/tmp/extractor-url/<hash_url>.html` para reruns offline.
- [ ] **Respetar `robots.txt`** (opcional, flag `--respect-robots`).

---

### Fase 2 — CLI mejorado

- [x] **`--selector`**: ya disponible en CLI y GUI para apuntar a un selector CSS (`article`, `#content`, `.post-body`).
- [ ] **`--main-only`**: valorar si aporta algo distinto a la auto-detección actual.
- [ ] **`--no-images`**: omitir imágenes en el Markdown.
- [ ] **`--no-links`**: convertir enlaces a texto plano.
- [ ] **`--lang`**: forzar idioma para detección de encoding.
- [ ] **Progreso en stderr**: spinner o contador de bytes descargados.
- [ ] **Salida a portapapeles**: flag `--clipboard` (usa `pbcopy` en macOS).
- [ ] **Pipe amigable**: si `-o -`, escribir a stdout sin mensajes informativos mezclados.

---

### Fase 3 — Empaquetado como .app macOS (MVP)

Opción A con pywebview:

- [ ] Construir UI en HTML/CSS moderno (dentro del webview) con panel URL, opciones y área resultado.
- [ ] Comunicar Python ↔ webview mediante la API JS bridge de pywebview.
- [ ] Soporte de Dark Mode (CSS `prefers-color-scheme`).
- [ ] Empaquetar con `py2app`:
  ```
  python setup.py py2app
  ```
- [ ] Generar `setup.py` con metadata de la app (nombre, icono, bundle ID `me.edefrutos.extractor-url`).
- [ ] Icono `.icns` (diseñar con SF Symbols o Sketch).
- [ ] Firma y notarización con `codesign` + `notarytool` para distribución fuera del App Store.

---

### Fase 4 — UI nativa SwiftUI (v1.0)

- [ ] Proyecto Xcode: `ExtractorURL.xcodeproj`.
- [ ] Python backend como microservicio local (`FastAPI` en puerto aleatorio, lanzado como subprocess al arrancar la app).
- [ ] SwiftUI: `TextEditor` para URL, segmentado para modo, `TextEditor` readonly para resultado.
- [ ] Integración con servicios macOS:
  - Drag & drop de URL desde Safari / Chrome.
  - `NSUserActivity` / Handoff.
  - Share Sheet: "Extraer con ExtractorURL" desde Safari.
  - Barra de menú: opción "Extraer URL del portapapeles".
- [ ] Historial de extracciones en CoreData o JSON local.

---

## 6. Sugerencias técnicas adicionales para fidelidad del Markdown

### 6.1 Pipeline de extracción recomendado

```
URL
  ↓ requests (o playwright si --js)
HTML crudo
  ↓ BeautifulSoup: eliminar nav/footer/aside/script/style/form
HTML limpio
  ↓ trafilatura.extract(html, include_images=True, output_format="markdown")
Markdown bruto
  ↓ post-procesado: normalizar saltos de línea, eliminar líneas vacías múltiples
Markdown final
```

Si `trafilatura` no detecta bien el cuerpo principal (webs no-artículo):

```
HTML limpio
  ↓ markdownify(html, heading_style="ATX", bullets="-", convert_as_inline=["span"])
Markdown
```

### 6.2 Casos edge a cubrir en tests

| Caso | Problema actual | Solución |
|---|---|---|
| `<a>` dentro de `<p>` | Enlace extraído como bloque suelto | markdownify lo maneja inline |
| `<pre><code class="language-python">` | No detectado | Extraer atributo `class` para el fence |
| Imágenes con `srcset` | Ignorado | Tomar la URL más grande o la primera |
| `<table>` con `colspan`/`rowspan` | No soportado | Convertir a tabla simple o bloque de código |
| Caracteres especiales en URLs | Sin encoding | `urllib.parse.quote` en href |
| Páginas con meta `charset` distinto de UTF-8 | Mojibake | `response.encoding = response.apparent_encoding` ya lo mitiga; añadir normalización NFC |
| SPA sin SSR | Página vacía | Flag `--js` con playwright |
| Paywall / login required | Contenido truncado | Documentar limitación, no intentar bypassear |

### 6.3 Configuración de `markdownify` recomendada

```python
from markdownify import markdownify as md

MARKDOWNIFY_OPTIONS = {
    "heading_style": "ATX",          # ## Título
    "bullets": "-",                   # listas con guión
    "strip": ["script", "style", "nav", "footer", "header", "aside", "form"],
    "convert_as_inline": ["span", "div"],  # no crear bloques para inline containers
    "newline_style": "backslash",     # evitar espacios al final de línea
}

markdown_output = md(clean_html, **MARKDOWNIFY_OPTIONS)
```

### 6.4 Post-procesado del Markdown

```python
import re

def clean_markdown(md: str) -> str:
    # Reducir tres o más líneas vacías seguidas a dos
    md = re.sub(r"\n{3,}", "\n\n", md)
    # Eliminar espacios al final de línea
    md = "\n".join(line.rstrip() for line in md.splitlines())
    # Eliminar líneas que solo contienen guiones o barras (separadores de nav)
    md = re.sub(r"^\s*[-|/\\]{3,}\s*$", "", md, flags=re.MULTILINE)
    return md.strip()
```

---

## 7. Estructura de proyecto objetivo

```
extractor-url/
├── extractor_url/              # paquete Python (renombrar el módulo)
│   ├── __init__.py
│   ├── fetcher.py              # _fetch_soup, playwright wrapper
│   ├── converter.py            # HTML → Markdown (markdownify + trafilatura)
│   ├── cleaner.py              # filtrado de ruido DOM
│   └── cli.py                  # argparse main()
├── tests/
│   ├── fixtures/               # HTML estáticos para tests deterministas
│   └── test_converter.py
├── ui/                         # fase 3: pywebview HTML/CSS
│   ├── index.html
│   └── style.css
├── ExtractorURL/               # fase 4: proyecto SwiftUI (subdirectorio Xcode)
├── setup.py                    # py2app config
├── requirements.txt
├── requirements-dev.txt        # pytest, markdownify, trafilatura, playwright
├── .pylintrc
├── CLAUDE.md
└── NOTEBOOK.md
```

---

## 8. Prioridad recomendada

| Prioridad | Tarea | Impacto | Esfuerzo |
|---|---|---|---|
| 🔴 P0 | Sustituir conversor manual por markdownify + trafilatura | Alto | Bajo |
| 🔴 P0 | Filtrar nav/header/footer en modo markdown | Alto | Bajo |
| 🔴 P0 | Resolver URLs relativas | Alto | Bajo |
| 🟠 P1 | Threading en GUI (no bloquear UI) | Medio | Bajo |
| 🟠 P1 | Tests con fixtures HTML locales | Alto | Medio |
| 🟠 P1 | Selector CSS (`--selector`) | Medio | Bajo |
| 🟡 P2 | Empaquetado py2app (.app bundle) | Alto | Medio |
| 🟡 P2 | pywebview UI moderna | Medio | Medio |
| 🟢 P3 | playwright para JS | Medio | Medio |
| 🟢 P3 | SwiftUI native app | Alto | Alto |

---

## 9. Dependencias a añadir

```txt
# requirements.txt (producción)
requests
beautifulsoup4
lxml
markdownify
trafilatura
pywebview          # fase 3

# requirements-dev.txt
pytest
pytest-cov
responses           # mock de requests en tests
playwright          # para tests de renderizado JS
```

---

## 10. Notas y decisiones pendientes

- **`ver_comprimido.sh`**: utilidad no relacionada con el proyecto. Mover a `~/bin/` o a un repositorio de dotfiles/scripts.
- **Nombre del bundle**: `me.edefrutos.extractor-url` o `me.edefrutos.webmd` (si se renombra la app).
- **Distribución**: ¿solo uso personal o App Store? Condiciona firma, sandboxing y permisos de red.
- **`trafilatura` vs `markdownify`**: evaluar en los 4 HTML de muestra guardados (`01.*.html`…`04.*.html`) antes de decidir.
- **Icono**: diseñar antes de fase 3 para incluirlo en el .app desde el principio.
