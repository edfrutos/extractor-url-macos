---
plan: 24-01
phase: 24-spike-python-sandbox
status: complete
completed: "2026-10-20"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - SBX-01
  - SBX-02
  - SBX-03
  - SBX-04
---

# Summary: 24-01 — Spike: Python embebido bajo App Sandbox

**Resultado: éxito.** El Python embebido funciona dentro de App Sandbox y App
Store Connect acepta el paquete. Las fases 25–28 siguen como están; no hace
falta replantear el diseño.

## Qué se hizo

- `scripts/spike-appstore.sh` (`local` | `package`) transforma una copia del
  `.app` Developer ID de v2.3 en una variante App Store sin tocar Xcode:
  quita Chromium/Playwright, `_tkinter` + Tcl/Tk y los auxiliares de Sparkle
  (888 MB → ~180 MB), cambia el bundle ID a
  `com.edefrutos.ExtractorApp.appstore` y firma de dentro a fuera (intérprete
  con solo `app-sandbox` + `inherit`).
- Entitlements en `scripts/appstore/`.

## Parte A — Mac real, firma local (SBX-01, SBX-03)

- Primer intento: «El proceso terminó sin producir salida». Con
  `pythonBridgeDebug` el stderr mostró `ModuleNotFoundError: No module named
  'tkinter'`: **Python sí arrancaba bajo el sandbox**; el fallo era el import
  incondicional de tkinter en `extractor_url.py`.
- `6d660d7`: tkinter opcional (`_TKINTER_AVAILABLE`), 2 tests nuevos; el
  spike copia el `core.py`/`extractor_url.py` del repo.
- Segundo intento: `https://example.com` extraído como Markdown y HTML,
  stderr vacío. Confirmado por el usuario.

## Parte B — App Store Connect (SBX-02, SBX-04)

- App ID explícito, certificados Apple Distribution + 3rd Party Mac
  Developer Installer, perfil «Mac App Store Connect» y ficha «Extractor URL»
  (Español de España, SKU `extractor-url-appstore`) creados por el usuario.
- Primera entrega con Transporter rechazada: **ITMS 91109**, atributo
  `com.apple.quarantine` en `embedded.provisionprofile` (el perfil recién
  descargado lo trae y el script limpiaba antes de copiarlo). Corregido en
  `739d9b5`: `xattr -cr` justo antes de firmar + comprobación final.
- Segunda entrega: «UPLOAD SUCCEEDED with no errors» y el build **2.3 (13)**
  aparece en TestFlight tras el procesado. No se envió a revisión.
- **SBX-02 decidido con evidencia:** el runtime Python puede quedarse en
  `Contents/Resources/python` (13 ficheros Mach-O: `python3.13`,
  `libpython3.13.dylib` y 11 `.so`); App Store Connect lo valida sin errores
  ni avisos. No hace falta moverlo a `Frameworks`/`Helpers`.

## Pendiente para fases siguientes

- **Fase 25:**
  - `PythonBridge.swift`: el error `.emptyOutput` debe incluir el resumen de
    stderr (ocultó la causa real en la Parte A).
  - `PYTHONDONTWRITEBYTECODE=1` en el entorno del intérprete.
  - Sparkle y `RuntimeUpdater` fuera por flag (el spike solo quita los
    ejecutables auxiliares de Sparkle).
  - `PrivacyInfo.xcprivacy`.
  - Limpiar la cuarentena tras copiar cualquier fichero al bundle (lección
    del 91109).
- **Fase 28:** el build 2.3 (13) ya está usado en App Store Connect; la
  primera subida real necesita un número de build mayor.
- Transporter omitió la comprobación local de API privadas («SPI file size
  > max»); el procesado del servidor no dio avisos, pero App Review puede
  revisarlo de nuevo en el envío real.
