---
plan: 17-01
phase: 17-playwright-chromium-embebido
status: complete
completed: "2026-08-22"
tasks_completed: 4
tasks_total: 4
requirements_covered:
  - BUNDLEJS-01
  - BUNDLEJS-02
---

# Summary: 17-01 — Playwright/Chromium embebido en el bundle

## What Was Built

### scripts/bundle-python.sh

- Vendoriza también el paquete `playwright==1.62.0` (llamada `pip install`
  separada, sin `--platform universal2` — Chromium solo se vendoriza para
  la arquitectura nativa del Mac de build, ver Decisión de alcance en
  `17-RESEARCH.md`).

### scripts/bundle-playwright.sh (nuevo)

- Instala Chromium (una sola pasada, `PLAYWRIGHT_BROWSERS_PATH=0`) vía el
  intérprete Python ya bundleado.
- Descubre el `.app` raíz y el `.framework` **por patrón** (`find ... -name
  "*.app"` / `"*.framework"`) en vez de hardcodear un nombre — corregido
  durante el checkpoint humano tras un fallo real de build (ver Bugs
  reales abajo).
- Codesigning bottom-up: Helpers (con `allow-jit` condicional para
  Renderer/GPU vía `scripts/chromium-helper-jit.entitlements`) →
  `crashpad_handler` → Framework → `.app` raíz.
- Quita quarantine (`xattr -rd`) en builds de desarrollo antes de firmar.

### scripts/chromium-helper-jit.entitlements (nuevo)

- Entitlements mínimos (`com.apple.security.cs.allow-jit`) para los
  Helpers Renderer/GPU — deliberadamente NO el `app-entitlements.plist`
  completo de Chromium (trae entitlements de App Sandbox que no aplican,
  `ExtractorApp` tiene sandbox OFF).

### ExtractorApp.xcodeproj/project.pbxproj

- Nueva Run Script Build Phase "Bundle Playwright Chromium", justo después
  de "Bundle Python Runtime".

### scripts/verify-bundle.sh

- BUNDLEJS-01: un único árbol `chromium-*`, `.app` firmado válido (`--deep
  --strict`), Helper (Renderer) con `allow-jit`.
- BUNDLEJS-02: extracción real de `example.com` vía Chromium embebido
  (`sync_playwright` + `PLAYWRIGHT_BROWSERS_PATH=0`).

### scripts/release-macos.sh

- Nueva `_resign_bundled_chromium()` — mismo patrón bottom-up que
  `bundle-playwright.sh` pero con `--options runtime` real (Developer ID),
  llamada tras `_resign_bundled_python` y antes de `_notarize_and_staple`.
  Reutiliza la identidad ya extraída, no la vuelve a pedir.

### ExtractorApp/Services/PythonBridge.swift

- `case .bundle:` inyecta `PLAYWRIGHT_BROWSERS_PATH=0` junto a
  `PYTHONPATH`.

### RELEASING.md

- Nueva sección "3.5. Chromium embebido" — alcance de una sola
  arquitectura, tamaño real medido, notarización más lenta de lo habitual.

## Bugs reales encontrados y corregidos durante el checkpoint humano

El plan original (escrito sin acceso a un Mac real) asumía la estructura
del `Chromium.app` clásico. El checkpoint humano reveló dos problemas
reales que no eran visibles desde el sandbox de planificación:

1. **Nombre del bundle cambiado**: Playwright 1.62.0 distribuye "Chrome
   for Testing", no Chromium clásico — el `.app` se llama `Google Chrome
   for Testing.app` (no `Chromium.app`), el framework `Google Chrome for
   Testing Framework.framework`, y los Helpers cuelgan de
   `Framework/Versions/Current/Helpers` (no de `Framework/Helpers`
   directamente). Confirmado descargando el zip real de
   `cdn.playwright.dev` (mac-arm64) e inspeccionando su estructura sin
   necesidad de macOS. Corregido en los tres scripts (`bundle-playwright.sh`,
   `verify-bundle.sh`, `release-macos.sh`) descubriendo `.app`/`.framework`
   por patrón (`find -name "*.app"` / `"*.framework"`) en vez de
   hardcodear el nombre — no debería volver a romperse ante otro cambio de
   naming aguas arriba de Playwright.
2. **Doble firmado borraba `allow-jit`**: el codesigning de cada Helper
   firmaba primero el ejecutable interno con `--entitlements`, y
   luego el `.app` del Helper por separado sin entitlements — ese segundo
   `codesign` resella el ejecutable interno como parte de sellar el
   bundle, borrando el `allow-jit` recién aplicado. Pasaba desapercibido
   en un build local ad-hoc (sin hardened runtime, AMFI no fuerza la
   restricción de JIT), pero habría roto el fallback JS en un release real
   firmado con Developer ID + `--options runtime`. `verify-bundle.sh`
   (BUNDLEJS-01) sí lo detectó (`FAIL: Helper (Renderer) NO tiene
   com.apple.security.cs.allow-jit`) aunque BUNDLEJS-02 (test funcional)
   pasaba igualmente por la misma razón. Corregido consolidando en una
   sola llamada `codesign` por Helper (firma bundle + ejecutable interno a
   la vez) en `bundle-playwright.sh` y `_resign_bundled_chromium()` de
   `release-macos.sh`.

## Verification Status — ✅ VERIFICADO (checkpoint humano, Mac real)

- **Build**: `Build Succeeded` tras las dos correcciones anteriores (dos
  iteraciones: primero fallo de nombre de bundle, luego `FAIL` de
  `allow-jit` detectado por `verify-bundle.sh`).
- **`verify-bundle.sh`**: 19 OK, 0 FAIL — BUNDLEJS-01 y BUNDLEJS-02 en
  verde, incluida la firma válida del Helper (Renderer) con `allow-jit` y
  el render real de `example.com` vía Chromium embebido.
- **Prueba end-to-end en la app real**: extracción de
  `https://quotes.toscrape.com/js/` (SPA de prueba pública, contenido
  inyectado vía JS) desde la app SwiftUI (⌘R) devolvió las citas
  correctamente — confirma el fallback JS embebido funcionando sin
  Playwright instalado a nivel de sistema, con el flujo real de la app
  (no solo el script de verificación).
- **Tamaño real**: 886MB (`.app` completo, build Debug local sin archivar,
  arm64 nativo) — ver nota en `RELEASING.md` 3.5, más alto que la
  estimación inicial del research (~250-350MB de incremento), documentado
  como cifra real en vez de corregir la estimación con otra suposición.
- **shellcheck**: limpio en los 4 scripts bash tocados
  (`bundle-python.sh`, `bundle-playwright.sh`, `verify-bundle.sh`,
  `release-macos.sh`) — sin avisos nuevos, solo 2 preexistentes sin
  relación (`SC2001` en `verify-bundle.sh`, `SC2295` en
  `bundle-python.sh`).
- **Paso 6 del checkpoint (release real con notarización) — omitido
  deliberadamente**: no gasta cuota de notarización ahora; queda para el
  próximo release real de la app. `_resign_bundled_chromium()` sigue el
  mismo patrón ya verificado de `_resign_bundled_python()` (Fase 13),
  ahora además corregido del bug de doble-firmado, así que el riesgo
  residual es bajo.
