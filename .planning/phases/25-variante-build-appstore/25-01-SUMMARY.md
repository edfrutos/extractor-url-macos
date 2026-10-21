---
phase: 25-variante-build-appstore
plan: 01
status: complete
completed: "2026-10-21"
requirements: [MASBUILD-02, MASBUILD-03, MASBUILD-04, MASBUILD-05]
---

# 25-01 — Resumen

## Hecho

- **T1 `#if APPSTORE`:** `ExtractorAppApp` (Sparkle, delegado, menú),
  `PythonBridge` (solo bundle, sin `RuntimeUpdater`, sin
  `PLAYWRIGHT_BROWSERS_PATH`), `SettingsViewModel` (beta, runtime update) y
  `SettingsView` (sin pestañas, solo «Modo de operación»; texto de
  `.unavailable` propio).
- **T2:** `ExtractionError.emptyOutput(detail:)` con `stderrSummary`; test
  Swift `testEmptyOutputCarriesStderrDetail_whenScriptOnlyWritesStderr`.
- **T3:** `PYTHONDONTWRITEBYTECODE=1` en la rama `.bundle` (las dos
  variantes); test pytest parametrizado que demuestra que con la variable el
  directorio de scripts no cambia y sin ella aparece `__pycache__`.
- **T4:** `bundle-python.sh` con `EXTRACTOR_VARIANT=appstore`: sin
  playwright, sin `_tkinter`/Tcl/Tk, `python3.13` con
  `python-child.entitlements` y comprobaciones finales. Variable desconocida
  → error. Arreglado de paso el aviso SC2295 que ya existía.
- **T5:** `ExtractorApp-AppStore.entitlements` (idéntico al del spike),
  `AppStore-Info.plist` (sin claves de Sparkle) y `PrivacyInfo.xcprivacy`.

## Manifiesto de privacidad

Códigos confirmados el 2026-10-21 en la página de Apple
`NSPrivacyAccessedAPITypeReasons`: `CA92.1` (UserDefaults), `C617.1` y
`3B52.1` (FileTimestamp: contenedor y archivo elegido por el usuario) y
`35F9.1` (SystemBootTime). La página de «required reason API» solo exige el
manifiesto en iOS/iPadOS/tvOS/visionOS/watchOS; en macOS se añade igualmente
porque no cuesta nada y Xcode lo incluye en el informe de privacidad.

## Verificación (sandbox Linux)

- Preprocesado simulado: con `APPSTORE` no queda ninguna referencia a
  Sparkle, `SPU*`, `RuntimeUpdater`, `CheckForUpdatesView` ni Playwright
  fuera de los dos ficheros excluidos; sin el flag, el código solo difiere de
  `HEAD` en el error con detalle y `PYTHONDONTWRITEBYTECODE`.
- `pytest tests/`: 94 passed. `pylint` 10/10, `mypy` limpio.
- `bash -n` y `shellcheck scripts/bundle-python.sh` sin avisos; bloque de
  borrado de Tcl/Tk probado sobre un árbol simulado.
- Los tres plists se cargan con `plistlib`.

## Pendiente

- Compilar Swift en el Mac (checkpoint tras 25-02).
- Duda abierta: si `python3.13` con sandbox heredado puede leer un HTML
  elegido con el panel de la app. Añadido al checkpoint (B.3).
