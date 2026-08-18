---
phase: 10-ux-zero-config
type: checkpoint-humano
status: pending
created: "2026-08-18"
---

# Checkpoint Humano — Fase 10 (UX Zero-Config) y cierre de v3.0

## Objetivo

Compilar y validar en un Mac real (con Xcode) el código de la Fase 10, escrito
en un sandbox Linux sin toolchain de Swift. Hasta que este checkpoint pase,
la Fase 10 y el milestone v3.0 quedan marcados como "código completo, sin
verificar" en `PROJECT.md` / `ROADMAP.md` / `STATE.md`.

## Estado de partida

- El sandbox trabaja en **modo directo**: el volumen `/Volumes/ESSAGER/...`
  es el mismo disco que ves en tu Mac. Los archivos ya están modificados en
  tu filesystem local — **no hace falta hacer `git pull` ni sincronizar
  nada**, solo abrir el proyecto en Xcode tal cual está.
- Nada de esto está commiteado todavía (lo verás en `git status` como
  cambios sin confirmar). No hagas commit hasta que el checkpoint pase —
  así, si algo falla, es más fácil descartar solo lo que no funciona.
- Archivos tocados por la Fase 10:
  - `ExtractorApp/ExtractorApp/ExtractorApp/Services/PythonBridge.swift`
  - `ExtractorApp/ExtractorApp/ExtractorApp/ViewModels/SettingsViewModel.swift`
  - `ExtractorApp/ExtractorApp/ExtractorApp/Views/SettingsView.swift`
  - `ExtractorApp/ExtractorApp/ExtractorAppTests/SettingsViewModelTests.swift`

## Requisitos previos

- [ ] Xcode instalado (el mismo usado en fases anteriores; macOS 13.0+ como deployment target del proyecto).
- [ ] El bundle Python de la Fase 8 ya construido al menos una vez en este checkout (si no, `bundledPythonPath()` devolverá `nil` y verás el modo "Python no disponible" en vez de "Python incluido" — no es un fallo del código de la Fase 10, es esperado sin bundle).

## Paso 1 — Abrir el proyecto

1. Abre Finder o Xcode y navega a:
   `/Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url/ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj`
2. Ábrelo con Xcode (doble clic, o `File → Open...` desde Xcode).
3. Espera a que Xcode termine de indexar (barra de progreso arriba).

**Repórtame:** confirma que el proyecto abre sin diálogos de error de configuración.

## Paso 2 — Build limpio

1. Menú `Product → Clean Build Folder` (⇧⌘K) — evita falsos positivos de una build cacheada.
2. `Product → Build` (⌘B).
3. Observa el panel de errores (icono ⚠️/❌ en la barra de navegación izquierda, o `⌘5` para el Report Navigator).

**Resultado esperado:** `Build Succeeded` sin errores. Puede haber warnings — no son bloqueantes salvo que digan explícitamente algo sobre `PathSource`, `PythonOperatingMode`, `Equatable` o concurrencia (`Sendable`, `@MainActor`).

**Si falla:** no intentes arreglarlo tú — copia el texto **exacto** del error (archivo, número de línea, mensaje completo) y pégamelo aquí. Yo no puedo compilar en este entorno, así que tu build es la única señal real que tengo; con el error exacto puedo corregir el código a ciegas y tú vuelves a intentar el build.

## Paso 3 — Ejecutar la suite de tests

Opción A (Xcode): `Product → Test` (⌘U) — ejecuta toda la suite.

Opción B (Terminal, más fácil de copiar/pegar el resultado):

```bash
cd "/Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url/ExtractorApp/ExtractorApp"

xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' \
  -only-testing:ExtractorAppTests/SettingsViewModelTests 2>&1 | tail -40

xcodebuild test -scheme ExtractorApp -destination 'platform=macOS' \
  -only-testing:ExtractorAppTests/PythonBridgeTests 2>&1 | tail -40
```

**Resultado esperado:**
- `SettingsViewModelTests`: todos los tests en verde, incluidos los 4 nuevos (`testOperatingMode_isOverride_whenUserDefaultsPathsAreValid`, `testOperatingMode_isBundleOrUnavailable_whenUserDefaultsEmpty`, `testOperatingMode_returnsToBundleOrUnavailable_whenOverrideCleared`, `testOperatingMode_isOverride_notBundle_whenPartialOverrideCompletedAfterwards`).
- `PythonBridgeTests`: sin regresiones respecto a Fase 9 (13 tests, 0 fallos, hasta 3 `skipped` si el bundle está presente — esto ya pasaba antes de la Fase 10).

**Repórtame:** el recuento final de cada suite (`Executed N tests, with X skipped and Y failures`). Si hay fallos, copia el nombre del test y el mensaje de aserción.

## Paso 4 — Checklist visual manual

Con la app corriendo (⌘R desde Xcode), sigue `TESTING-HUMANO.md`, sección
**"2. Configuración de Preferencias"**, subsecciones **2-0 a 2D** (son las
que se reescribieron para la Fase 10). Resumen rápido de qué mirar:

- [ ] **2-0** — Preferencias sin overrides: badge verde "Usando Python incluido (Python X.X.X)" arriba del todo, sección "Configuración avanzada" colapsada.
- [ ] **2A** — Al pulsar "Configuración avanzada" se despliega y las rutas están vacías sin badges.
- [ ] **2B** — Escribir una ruta Python inválida en el override: badge rojo "No encontrado" en el campo, pero el badge de "Modo de operación" sigue en verde (el override inválido no debe tumbar el modo bundle).
- [ ] **2C** — Configurar un override válido (Python + script reales): badge de "Modo de operación" cambia a azul "Usando configuración manual".
- [ ] **2D** — Borrar el override: el badge vuelve a verde "Usando Python incluido" sin reiniciar la app.

Al final de esa sección hay también el bloque **"Checklist v3.0 — Fase 10"**
al final de `TESTING-HUMANO.md` — márcalo también.

**Repórtame:** qué viste en cada punto (especialmente el número de versión real que aparece en el badge, p.ej. "Python 3.13.14") y si algo no coincide con lo esperado (capturas de pantalla si algo se ve raro son bienvenidas pero no imprescindibles).

## Paso 5 — Cierre (lo hago yo, no tú)

Cuando confirmes Build Succeeded + tests en verde + checklist visual OK, yo:

1. Actualizo `ROADMAP.md` / `STATE.md` / `PROJECT.md` quitando las notas de "pendiente de verificación" y anotando el recuento real de tests que me reportes.
2. Escribo el `10-01-SUMMARY.md` definitivo con los resultados reales (sustituyendo el actual, que dice explícitamente "sin compilar").
3. Cierro el milestone v3.0 si no queda nada más pendiente.
4. Te pregunto si quieres que haga el commit de todo (Fase 9 + Fase 10 + docs), ya que no hago commits sin que me lo pidas explícitamente.

## Plan de contingencia

- **Build falla** → Paso 2, repórtame el error exacto, corrijo, repites Paso 2.
- **Tests fallan** → Paso 3, repórtame el test y el mensaje, corrijo, repites Paso 3 (y de propina Paso 2).
- **Algo visual no coincide** (p.ej. el badge no cambia de color al configurar el override) → dime exactamente qué esperabas vs. qué viste; puede ser un bug real de lógica (no solo de compilación) y lo reviso.
- **No tienes el bundle de la Fase 8 compilado en este checkout** → verás "Python no disponible" en vez de "Python incluido"; es esperado, no es un fallo de la Fase 10. Si quieres probar el modo bundle real, hay que correr `scripts/bundle-python.sh` primero (Fase 8) — dímelo si quieres que te guíe por ese paso también.
