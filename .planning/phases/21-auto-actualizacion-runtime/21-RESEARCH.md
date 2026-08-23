---
phase: 21-auto-actualizacion-runtime
type: research
status: complete
created: "2026-08-23"
---

# Research: Fase 21 — Auto-actualización del runtime Python embebido

## Objetivo

`PYRUNTIME-01`/`PYRUNTIME-02`: actualizar el runtime Python embebido en el
`.app` sin obligar a un release completo de la app, sin romper la firma
de código/notarización del bundle, y con degradación segura si la
actualización falla.

## Hallazgos clave (búsqueda web, sin poder probar en Mac real)

### 1. Los binarios sueltos no se pueden "staplear"

`xcrun stapler staple` solo acepta contenedores: `.app`, `.pkg` (flat,
firmado), `.dmg` (UDIF). Un ejecutable Mach-O suelto (el intérprete
`python3.13`, o un `.dylib`) **no tiene dónde grabar el ticket de
notarización**. Sin staple, Gatekeeper valida el ticket por red la
primera vez que el binario se ejecuta — funciona, pero depende de
conectividad en ese momento (aceptable si la app ya requirió red para
descargarlo, pero es una dependencia real que no existe para el `.app`
principal, que sí queda stapleado desde la Fase 13).

### 2. Un intérprete descargado y ejecutado vía `Process()` probablemente dispara Gatekeeper

macOS pone `com.apple.quarantine` automáticamente en archivos descargados
por la app (vía `URLSession` u otras APIs estándar). Gatekeeper evalúa
binarios Mach-O quarantineados **al ejecutarlos**, sea vía Terminal,
LaunchServices, o (con alta probabilidad, aunque sin confirmación directa
para este caso concreto) vía `Foundation.Process()` — el mecanismo de
bloqueo actúa a nivel de `execve`/AMFI, no solo en el flujo de doble-clic
de Finder. Sin limpiar el atributo de quarantine a mano (`xattr -d
com.apple.quarantine`) o sin que el binario esté correctamente firmado +
notarizado, la primera ejecución fallaría con "no se puede verificar el
desarrollador" — o peor, fallaría en silencio dentro de `Process().run()`
sin diálogo visible (comportamiento exacto no confirmado sin un Mac real).

### 3. Los archivos `.py` puros NO pasan por Gatekeeper

Gatekeeper evalúa cosas que se **lanzan** (bundles `.app`, binarios
Mach-O ejecutados directamente, scripts invocados vía su propio shebang).
Un archivo `.py` que el intérprete YA arrancado (el `python3.13`
bundleado, firmado y notarizado desde la Fase 8/13) simplemente lee vía
`import` — una llamada `open()`/`read()` normal, no un "lanzamiento" — no
activa ninguna evaluación de Gatekeeper. Esto es consistente con el
comportamiento cotidiano observable: instalar/actualizar paquetes pip
puros nunca dispara avisos de Gatekeeper, a diferencia de descargar y
abrir un `.app` o un binario de terminal.

### 4. Confianza de los hallazgos

- **Alta**: (3) — comportamiento ampliamente observable y consistente con
  cómo Gatekeeper documenta su propio alcance ("evalúa código en el
  momento del lanzamiento").
- **Media**: (1) y (2) — confirmados por múltiples fuentes de terceros
  (foros de Apple Developer, blogs técnicos) pero sin una prueba directa
  en un Mac real dentro de esta investigación.

## Decisión de alcance (confirmada explícitamente por el usuario)

**v1 de esta fase actualiza SOLO las dependencias Python puras**
(`requests`, `beautifulsoup4`, `markdownify`, `trafilatura`) — nunca el
intérprete, `lxml` (extensión compilada) ni Chromium/Playwright. Esto:

- Evita por completo la incertidumbre de Gatekeeper de los hallazgos (1)
  y (2) — la actualización nunca ejecuta un binario nuevo, solo cambia
  qué archivos `.py` lee el intérprete ya confiable y bundleado.
- Cubre el caso de uso real con más valor: parches de seguridad/bugs en
  las librerías HTTP/parsing, que cambian con más frecuencia que el
  intérprete o Chromium.
- Deja el intérprete/`lxml`/Chromium exactamente como hoy — se siguen
  actualizando solo con un release completo de la app vía Sparkle (Fase
  12/13/17), sin cambios de comportamiento ni regresión de robustez.
- `core.py` ya degrada `lxml → html.parser` si `lxml` no está disponible
  (decisión de v1.0) — la app ya tolera un `lxml` desactualizado o
  ausente sin romperse, así que no dejarlo fuera de esta fase no reduce
  robustez real.

## Diseño propuesto

### Mecanismo de override — PYTHONPATH, no reemplazo de archivos

`PythonBridge.run()` (caso `.bundle`) ya construye `PYTHONPATH` apuntando
a `python/lib/python-packages/` dentro del bundle firmado. Se añade un
directorio ANTES de ese, en
`~/Library/Application Support/ExtractorApp/python-packages-override/<version>/`
— si existe y pasa la verificación, Python resuelve `import requests`
desde ahí primero (precedencia estándar de `PYTHONPATH`), sin tocar ni
sobrescribir un solo archivo dentro del `.app` firmado. El bundle original
queda intacto siempre.

**Esto resuelve PYRUNTIME-02 (degradación segura) de forma casi gratuita**:
si el directorio override no existe, está corrupto, o falla la
verificación, `PythonBridge` simplemente no lo añade al `PYTHONPATH` —
el intérprete cae automáticamente a los paquetes bundleados, sin lógica
de rollback explícita que pueda tener bugs propios.

### Manifiesto de versión — mismo hosting que el appcast (Fase 13)

Un archivo `runtime-manifest.json` en la raíz del repo, servido vía
`raw.githubusercontent.com` (cero infraestructura nueva, mismo patrón que
`appcast.xml`):

```json
{
  "version": "2026-08-23",
  "download_url": "https://github.com/edfrutos/extractor-url-macos/releases/download/runtime-2026-08-23/python-packages.zip",
  "sha256": "…"
}
```

### Publicación — extensión de `scripts/release-macos.sh` (o script propio)

El zip de dependencias puras se genera empaquetando
`python/lib/python-packages/{requests,bs4,markdownify,trafilatura,...}`
del build ya vendorizado, y se publica como asset de un GitHub Release
dedicado (no el mismo release que la app, para no mezclar el ciclo de
vida de ambos) — reutiliza `gh release create`, mismo patrón ya
establecido, sin pipeline paralelo nuevo.

### Comprobación y aplicación — Swift, `RuntimeUpdater` nuevo

- Comprobación manual desde Preferencias (botón, mismo patrón que
  "Buscar actualizaciones…" de Sparkle) — v1 sin comprobación automática
  en segundo plano, para mantener el alcance acotado y no duplicar el
  mecanismo de scheduling que Sparkle ya tiene para el resto de la app.
- Descarga el manifiesto, compara `version` contra la versión activa
  (guardada en `UserDefaults`), descarga el zip si hay una más nueva,
  **verifica SHA-256 contra el manifiesto antes de extraer nada**, extrae
  a un directorio nuevo versionado, y solo entonces actualiza el puntero
  de versión activa en `UserDefaults`.
- Si la verificación de checksum falla, el directorio descargado se
  descarta y la versión activa no cambia — el override existente (o su
  ausencia) sigue tal cual.

## Anti-patterns (a evitar explícitamente)

- **No** limpiar `com.apple.quarantine` a mano de nada en esta fase — al
  no descargar ni ejecutar ningún binario nuevo, no hace falta, y hacerlo
  "por si acaso" sería tocar un mecanismo de seguridad del sistema sin
  necesidad real.
- **No** reemplazar/sobrescribir archivos dentro de
  `Contents/Resources/python/` del `.app` firmado — rompería la firma de
  código del bundle (el mismo problema que `_resign_bundled_python`/
  `_resign_bundled_chromium` ya mitigan para los binarios compilados, pero
  aquí se evita del todo no tocando el bundle en absoluto).
- **No** intentar cubrir el intérprete/`lxml`/Chromium en esta fase — ver
  Decisión de alcance arriba.

## Pendiente de verificar en checkpoint humano (Mac real)

- Confirmar que `PYTHONPATH` con el override antepuesto realmente hace
  que Python resuelva `import requests` desde ahí antes que desde el
  bundle (comportamiento estándar de Python, pero sin confirmar contra el
  intérprete `python-build-standalone` concreto que usa este proyecto).
- Confirmar que la descarga/extracción de un `.zip` de archivos `.py`
  puros no dispara ningún aviso de Gatekeeper (hallazgo (3), alta
  confianza pero sin prueba directa).
