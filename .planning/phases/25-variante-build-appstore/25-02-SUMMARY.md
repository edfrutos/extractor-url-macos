---
phase: 25-variante-build-appstore
plan: 02
status: complete-pending-checkpoint
completed: "2026-10-21"
requirements: [MASBUILD-01, MASBUILD-02, MASBUILD-03, MASBUILD-04]
---

# 25-02 — Resumen

## Hecho

- **T1 target `ExtractorApp AppStore`** en `project.pbxproj` (IDs
  `25A5000130000000000000xx`):
  - Fases Sources, Frameworks vacía (sin Sparkle), CopyFiles de `core.py` y
    `extractor_url.py`, Resources y «Bundle Python Runtime (App Store)» con
    `EXTRACTOR_VARIANT=appstore`. Sin fase de Chromium.
  - Excepciones del grupo sincronizado: el target nuevo excluye `Info.plist`,
    `AppStore-Info.plist`, los dos `.entitlements`, `RuntimeUpdater.swift` y
    `CheckForUpdatesView.swift`. El de siempre excluye además
    `AppStore-Info.plist`, `ExtractorApp-AppStore.entitlements` y
    `PrivacyInfo.xcprivacy`.
  - Ajustes: los del target actual más `APPSTORE`, bundle ID `.appstore`,
    `ENABLE_APP_SANDBOX = YES`, `ENABLE_USER_SELECTED_FILES = readwrite` y
    `ENABLE_OUTGOING_NETWORK_CONNECTIONS = YES` (coherentes con el fichero de
    entitlements), nombre visible y categoría vía `INFOPLIST_KEY_*`.
  - `ITSAppUsesNonExemptEncryption` va en `AppStore-Info.plist`, no como
    `INFOPLIST_KEY_*`: no hay garantía de que Xcode admita esa clave por ajuste.
- **Desviación:** `CONFIGURATION_BUILD_DIR = $(BUILD_DIR)/$(CONFIGURATION)-appstore`.
  Los dos targets generan `ExtractorApp.app` (mismo ejecutable que el
  validado en el spike); sin directorio propio se pisarían en DerivedData, y
  los tests (`TEST_HOST`) podrían cargar la variante equivocada.
- **T2 esquema** `ExtractorApp AppStore.xcscheme`: build/run/profile/archive
  del target nuevo, sin tests.
- **T3 `scripts/package-appstore.sh`**, que sustituye a `spike-appstore.sh`
  (borrado). **Desviación:** no usa `-exportArchive`: en macOS, el export
  `app-store-connect` genera el `.pkg` directamente y no deja re-firmar el
  Python de Resources con los entitlements de hijo. Toma el `.app` del
  archivo y firma igual que el spike, que App Store Connect ya aceptó.
  Comprueba bundle ID, ausencia de `SUFeedURL`/Sparkle/Tcl/Playwright,
  `inherit` del intérprete, presencia de `PrivacyInfo.xcprivacy` y que no haya
  cuarentena.
- **T4** `RELEASING.md` §3.9 «Variante App Store».

## Verificación (sandbox Linux)

- `project.pbxproj` se analiza con `openstep_parser`/`pbxproj`. Todos los IDs
  referenciados existen y no hay duplicados. Los objetos previos solo cambian
  en el grupo de excepciones, el grupo Products, la lista de targets y
  `TargetAttributes`.
- `bash -n` y `shellcheck` limpios en `package-appstore.sh`.
- El esquema es XML válido y no referencia el target Developer ID.

## Pendiente

Checkpoint humano (`CHECKPOINT-HUMANO.md`): compilar los dos esquemas,
ejecutar la variante App Store con sandbox (incluido «Abrir HTML…») y
generar el `.pkg`.
