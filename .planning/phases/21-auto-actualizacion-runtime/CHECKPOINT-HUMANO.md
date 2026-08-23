---
phase: 21-auto-actualizacion-runtime
type: checkpoint-humano
status: pending
created: "2026-08-23"
---

# Checkpoint Humano — Fase 21 (Auto-actualización del runtime Python)

## Objetivo

Compilar el código Swift nuevo (`RuntimeUpdater.swift` + los cambios en
`PythonBridge.swift`/`SettingsViewModel.swift`/`SettingsView.swift`) y
confirmar la pregunta central de esta fase: **¿una actualización de
dependencias Python puras, descargada y extraída en tiempo de ejecución,
se aplica sin ningún aviso de Gatekeeper?** (ver `21-RESEARCH.md`,
hallazgo 3 — alta confianza pero sin prueba directa en un Mac real).

## Estado de partida

- `ExtractorApp/ExtractorApp/ExtractorApp/Services/RuntimeUpdater.swift`
  (nuevo): descarga, verifica checksum SHA-256, extrae a
  `~/Library/Application Support/ExtractorApp/python-packages-override/<version>/`,
  y verifica que el intérprete bundleado puede importar los 4 paquetes
  desde ahí antes de activar el override.
- `PythonBridge.swift`: antepone el override al `PYTHONPATH` si existe.
- `SettingsViewModel.swift`/`SettingsView.swift`: nueva sección
  "Dependencias del motor" en Preferencias (solo visible en modo bundle)
  con botón "Buscar actualización".
- `scripts/build_runtime_update.py` (nuevo, ejecutado y verificado en el
  sandbox — genera el zip + `runtime-manifest.json` correctamente, sin
  binarios compilados dentro).
- Este proyecto usa grupos sincronizados de Xcode 16
  (`PBXFileSystemSynchronizedRootGroup`) — los archivos nuevos ya están
  en las carpetas correctas (`Services/`, `ExtractorAppTests/`) y Xcode
  debería recogerlos automáticamente, **sin editar `project.pbxproj`**
  (a diferencia de la Fase 17, que sí necesitó tocarlo a mano).
- Nada de esto está commiteado todavía. No existe todavía un
  `runtime-manifest.json` publicado en GitHub — el manifiesto real solo
  se genera si completas el Paso 4 (opcional) de este checkpoint.

## Paso 1 — Build

1. Abre `ExtractorApp.xcodeproj` en Xcode.
2. `Product → Clean Build Folder` (⇧⌘K).
3. `Product → Build` (⌘B).

**Resultado esperado:** `Build Succeeded`, sin que haga falta añadir
manualmente `RuntimeUpdater.swift` al target (los grupos sincronizados
deberían recogerlo solos — si Xcode se queja de que no encuentra el
tipo `RuntimeUpdater`, o el archivo no aparece en el navegador de
proyecto, avísame con el error exacto).

## Paso 2 — Tests unitarios

`Product → Test` (⌘U), o específicamente `RuntimeUpdaterTests`.

**Resultado esperado:** los 4 tests nuevos pasan (decodificación del
manifiesto, mensajes de error, sin override activo por defecto). Estos
son deterministas y no requieren red.

## Paso 3 — Camino "sin actualización disponible" (mínimo, sin publicar nada)

Como todavía no hay ningún `runtime-manifest.json` real publicado en
GitHub, este paso confirma que la ausencia de manifiesto se maneja bien
(sin crash, sin colgarse):

1. Ejecuta la app (⌘R).
2. Ve a Preferencias → sección "Dependencias del motor" (debería
   aparecer, ya que por defecto operas en modo bundle).
3. Pulsa "Buscar actualización".

**Resultado esperado:** tras un momento, aparece un mensaje de error
tipo "No se pudo comprobar si hay una actualización disponible." (404 al
no existir `runtime-manifest.json` todavía en el repo) — **sin crash, sin
quedarse colgado indefinidamente**.

**Repórtame:** ¿apareció el mensaje esperado? ¿algún comportamiento raro?

## Paso 4 (opcional, más completo) — Publicar una actualización real y aplicarla

Este paso SÍ confirma la pregunta central de la fase (Gatekeeper), pero
publica un asset real en GitHub Releases. Solo hazlo si quieres verificar
el flujo completo ahora:

```bash
cd /Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url
python3 scripts/build_runtime_update.py 2026-08-23
```

Copia y ejecuta el `gh release create ...` y el `git add/commit/push`
que imprime el script (revísalos primero). Tras publicar:

1. Vuelve a la app, pulsa "Buscar actualización" otra vez.
2. **Resultado esperado:** "Dependencias actualizadas a 2026-08-23." —
   **sin ningún diálogo de "no se puede verificar el desarrollador" ni
   aviso de Gatekeeper.**
3. Haz una extracción normal (cualquier URL) para confirmar que el motor
   sigue funcionando con el override activo.
4. Repite el build/extracción tras **cerrar sesión y volver a entrar** (o
   reiniciar el Mac) — confirma que Gatekeeper no vuelve a preguntar en
   una sesión nueva (el hallazgo 3 de la research dice que no debería,
   al no ser un "lanzamiento", pero conviene confirmarlo dos veces).

**Repórtame:** ¿apareció algún aviso de seguridad en cualquier momento
de este paso? Es la pregunta más importante de todo el checkpoint.

## Paso 5 (opcional) — Confirmar degradación segura

Para probar `PYRUNTIME-02` de verdad:

1. Con un override ya aplicado (Paso 4 completado), borra a mano el
   directorio `~/Library/Application Support/ExtractorApp/python-packages-override/`.
2. Haz una extracción normal.

**Resultado esperado:** la extracción sigue funcionando (cae
automáticamente al runtime bundleado, sin que tengas que hacer nada en
la app) — confirma que `RuntimeUpdater.activeOverridePath()` degrada bien
cuando el directorio desaparece.

## Paso 6 — Cierre (lo hago yo, no tú)

Cuando confirmes Build Succeeded + tests pasando + el Paso 3 (mínimo) o
idealmente el Paso 4 (Gatekeeper confirmado sin avisos), yo:

1. Escribo `21-01-SUMMARY.md` con los resultados reales.
2. Marco la Fase 21 completa en ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md.
3. Te pregunto si quieres commitear/pushear, y si seguimos con la Fase 22
   (notarización para distribución pública — la última de v7.0).

## Plan de contingencia

- **Xcode no encuentra `RuntimeUpdater`/no compila** → pégame el error
  exacto; probablemente necesite añadir el archivo manualmente al target
  si el grupo sincronizado no lo recogió como se esperaba (raro, pero no
  descartable sin probarlo).
- **Aparece un aviso de Gatekeeper en el Paso 4** → sería el hallazgo más
  importante de esta fase: significaría que el hallazgo 3 de la research
  (los `.py` puros no disparan Gatekeeper) no aplica tal cual esperaba a
  este flujo concreto. Pégame el mensaje exacto del diálogo — con eso
  puedo investigar si es el `unzip` vía Finder vs. `Process()` directo, o
  algo específico de este caso.
- **`Process()` de `/usr/bin/unzip` falla** → revisa que `unzip` exista
  en esa ruta en tu Mac (`which unzip` en Terminal); si está en otra
  ruta, dímelo y ajusto `RuntimeUpdater.extract()`.
