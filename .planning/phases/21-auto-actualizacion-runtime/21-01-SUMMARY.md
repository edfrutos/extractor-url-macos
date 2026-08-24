---
plan: 21-01
phase: 21-auto-actualizacion-runtime
status: complete
completed: "2026-08-24"
tasks_completed: 1
tasks_total: 1
requirements_covered:
  - PYRUNTIME-01
  - PYRUNTIME-02
---

# Summary: 21-01 — Auto-actualización del runtime Python embebido (deps puras)

## Investigación previa

Sin acceso a un Mac real, se investigó por búsqueda web el comportamiento
de Gatekeeper/notarización para binarios sueltos (no `.app`/`.pkg`/`.dmg`)
descargados y ejecutados en tiempo de ejecución — ver `21-RESEARCH.md`.
Hallazgo clave: los binarios sueltos no se pueden staplear y dependen de
verificación online, mientras que los archivos `.py` puros que un
intérprete ya confiable simplemente `import`ea como datos no pasan por
Gatekeeper en absoluto. Presentado al usuario, que confirmó explícitamente
acotar el alcance de v1 a las dependencias Python puras (`requests`,
`beautifulsoup4`, `markdownify`, `trafilatura`) — nunca el intérprete,
`lxml` (extensión compilada) ni Chromium, que siguen actualizándose solo
con un release completo de la app vía Sparkle.

## What Was Built

### scripts/build_runtime_update.py (nuevo)

Instala las 4 dependencias en un directorio limpio vía `pip install
--target`, **detecta automáticamente** (no por lista fija de nombres)
cualquier paquete con binarios compilados (`.so`/`.dylib`/`.pyd`) para
excluirlo del paquete de actualización, comprime el resto, y genera
`runtime-manifest.json` (version/download_url/sha256) en la raíz del
repo. No publica nada automáticamente — imprime el `gh release create` y
`git add/commit/push` exactos, mismo patrón que el appcast de la Fase 13.

### ExtractorApp/.../Services/RuntimeUpdater.swift (nuevo)

- Descarga el manifiesto remoto (`raw.githubusercontent.com`, mismo
  hosting que el appcast) y el zip si hay una versión más nueva que la
  activa.
- Verifica el SHA-256 contra el manifiesto antes de tocar nada.
- Extrae vía `/usr/bin/unzip` invocado directamente (no Archive
  Utility/Finder) a un directorio temporal, movido atómicamente al
  destino final solo si `unzip` termina con éxito.
- **Verificación funcional real** antes de activar: lanza el intérprete
  YA bundleado/notarizado con el override antepuesto al `PYTHONPATH` e
  intenta `import requests, bs4, markdownify, trafilatura` — si falla, la
  actualización se descarta y la versión activa no cambia (PYRUNTIME-02).
- Nunca toca un solo archivo dentro de `Contents/Resources/` del `.app`
  firmado — el override vive en `~/Library/Application Support/`.

### ExtractorApp/.../Services/PythonBridge.swift

Antepone el override activo (si existe y su directorio sigue en disco)
al `PYTHONPATH` del bundle. Si no hay override o su directorio
desapareció, el comportamiento es idéntico al de antes de esta fase —
degradación segura sin lógica de rollback explícita.

### ExtractorApp/.../ViewModels/SettingsViewModel.swift + Views/SettingsView.swift

Nueva sección "Dependencias del motor" en Preferencias (solo visible en
modo bundle) con botón manual "Buscar actualización". `Task.detached` +
`[weak self]`, mismo patrón que `refreshOperatingMode()` de la Fase 10,
para no bloquear MainActor con el `Process()` síncrono de la
verificación de importación.

### ExtractorAppTests/RuntimeUpdaterTests.swift (nuevo)

4 tests: decodificación del manifiesto JSON, decodificación fallida ante
un campo ausente, mensajes de error no vacíos para los 4 casos de
`UpdateError`, y ausencia de versión activa por defecto.

## Verification Status — ✅ VERIFICADO (checkpoint humano en Mac real)

- **`scripts/build_runtime_update.py`**: ejecutado de verdad tanto en el
  sandbox como en el Mac real del usuario — resultado idéntico en ambos
  (excluye `lxml`/`charset_normalizer`/`regex`, ~15MB, checksum
  correcto). `pylint`/`mypy` 10.00/10 limpios.
- **Build**: `Build Succeeded` sin necesitar tocar `project.pbxproj` — el
  proyecto usa grupos sincronizados de Xcode 16
  (`PBXFileSystemSynchronizedRootGroup`), los archivos Swift nuevos se
  recogieron automáticamente.
- **Tests**: los 4 tests de `RuntimeUpdaterTests` pasaron.
- **Camino sin actualización disponible**: antes de publicar ningún
  release real, "Buscar actualización" mostró correctamente "No se pudo
  comprobar si hay una actualización disponible." (404) — sin crash, sin
  colgarse.
- **Publicación real**: `runtime-2026-08-24` publicado en GitHub Releases,
  `runtime-manifest.json` commiteado y pusheado desde el Mac real del
  usuario.
- **Primer intento de aplicar la actualización**: timeout de red genuino
  (`NSURLErrorTimedOut`, código -1001) a los ~45s — descarga del asset
  recién publicado, probablemente propagación de CDN de GitHub. **No
  relacionado con Gatekeeper.** Detectado un bug real de UI durante este
  fallo: el estado interno sí transicionaba correctamente a `.failed`
  (el botón se reactivaba, el spinner paraba), pero el mensaje de error
  solo aparecía en una etiqueta secundaria diminuta (`caption2`) fácil de
  pasar por alto — **corregido**: el mensaje de error ahora aparece
  directamente en el texto de estado principal, en rojo.
- **Segundo intento (reintento inmediato)**: ✅ **"Dependencias
  actualizadas a 2026-08-24."** — aplicado correctamente.
- **Pregunta central de la fase — confirmada explícitamente por el
  usuario**: "¿apareció en algún momento un diálogo de 'no se puede
  verificar el desarrollador' o cualquier otro aviso de
  seguridad/Gatekeeper?" → **"No, ningún aviso en ningún momento."**
  Confirma el hallazgo 3 de `21-RESEARCH.md`: los archivos `.py` puros
  descargados y `import`eados por el intérprete ya bundleado/notarizado
  no disparan ninguna evaluación de Gatekeeper.
- **Extracción funcional con el override activo**: confirmada — el motor
  sigue funcionando con normalidad.
- **Degradación segura (PYRUNTIME-02)**: confirmada — al borrar a mano
  `~/Library/Application Support/ExtractorApp/python-packages-override/`,
  la extracción siguió funcionando sin intervención del usuario, cayendo
  automáticamente al runtime bundleado.

## Bug real encontrado y corregido durante el checkpoint

Mensaje de error de `.failed(message:)` relegado a una etiqueta
secundaria diminuta (`Text(message).font(.caption2)`) en vez de
mostrarse en el texto de estado principal — un timeout de red real
durante el checkpoint pasó casi desapercibido porque el usuario estaba
mirando la consola de Xcode y no reparó en la letra pequeña bajo el
botón. Corregido en `SettingsView.swift`: `statusText` ahora incluye
`"Error: \(message)"` para el caso `.failed`, con `statusColor` (`.red`)
aplicado directamente al texto principal.
