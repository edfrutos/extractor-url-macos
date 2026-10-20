# Research: Fase 25 — Variante de build App Store

*Investigado: 2026-10-20, sobre el código en `f8667e3` y los resultados del spike (Fase 24).*

## Punto de partida

- Un solo target `ExtractorApp` (Developer ID), con grupos sincronizados de
  Xcode (`PBXFileSystemSynchronizedRootGroup`): todo `.swift` de
  `ExtractorApp/ExtractorApp/` entra solo, salvo las excepciones de
  `membershipExceptions` (hoy solo `Info.plist`).
- Sparkle llega como paquete Swift local (`.build-cache/Sparkle`) enlazado
  en la fase *Frameworks* del target.
- Fases de build: Sources → Frameworks → CopyFiles (`core.py`,
  `extractor_url.py` a `Resources/scripts`) → Resources → «Bundle Python
  Runtime» (`scripts/bundle-python.sh`) → «Bundle Playwright Chromium»
  (`scripts/bundle-playwright.sh`).
- `release-macos.sh` archiva el esquema `ExtractorApp`, exporta con
  `developer-id` y re-firma el Python y el Chromium embebidos con hardened
  runtime (el export de Xcode no re-firma binarios sueltos de `Resources`).

## Qué depende de Sparkle / RuntimeUpdater / rutas externas

| Fichero | Uso | En la variante App Store |
|---|---|---|
| `ExtractorAppApp.swift` | `import Sparkle`, `SPUStandardUpdaterController`, delegado de canales, comando «Buscar actualizaciones…» | `#if !APPSTORE` |
| `Views/CheckForUpdatesView.swift` | Vista del menú de Sparkle | Fuera del target (excepción de membresía) |
| `Models/Services/RuntimeUpdater.swift` | Descarga dependencias Python (prohibido, guideline 2.5.2) | Fuera del target |
| `PythonBridge.swift` | `RuntimeUpdater.activeOverridePath()`; override `pythonPath`/`scriptPath`; `PLAYWRIGHT_BROWSERS_PATH` | `#if APPSTORE`: solo bundle, sin override, sin Playwright |
| `SettingsViewModel.swift` | `betaChannelOptIn`, `RuntimeUpdater.*`, selección de rutas | `#if !APPSTORE` en lo que toca a Sparkle/RuntimeUpdater |
| `SettingsView.swift` | Sección «Actualizaciones», «Dependencias del motor», pestaña «Avanzado» (rutas) | Solo pestaña General con «Modo de operación» |

## Decisión: segundo target, no solo una configuración

Una configuración de build (`Release-AppStore`) no basta: el enlace a un
producto de paquete Swift es por target, no por configuración, así que
Sparkle seguiría enlazado (`LC_LOAD_DYLIB`) aunque el código no lo importara.
Quitarlo a posteriori del `.app` rompería el arranque.

**Elegido:** target nuevo `ExtractorApp AppStore` con su propio esquema:

- Comparte el grupo sincronizado `ExtractorApp/` con excepciones para
  `RuntimeUpdater.swift`, `CheckForUpdatesView.swift`, `Info.plist` y
  `ExtractorApp.entitlements`.
- Sin Sparkle en *Frameworks*.
- Fases: Sources, Frameworks (vacía), CopyFiles (scripts), Resources y
  «Bundle Python Runtime» con `EXTRACTOR_VARIANT=appstore`. **Sin** la fase
  de Chromium.
- `SWIFT_ACTIVE_COMPILATION_CONDITIONS = APPSTORE $(inherited)`.
- `PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.ExtractorApp.appstore`,
  `PRODUCT_NAME = ExtractorApp` (mismo ejecutable), nombre visible
  «Extractor URL».
- `ENABLE_APP_SANDBOX = YES`, entitlements propios
  (`ExtractorApp/ExtractorApp-AppStore.entitlements`, fuera del target por
  excepción, igual que el actual).
- `Info.plist` propio (`ExtractorApp/AppStore-Info.plist`) sin `SUFeedURL`
  ni `SUPublicEDKey`; `LSApplicationCategoryType`,
  `ITSAppUsesNonExemptEncryption = NO` y `CFBundleDisplayName` vía
  `INFOPLIST_KEY_*`.

El target `ExtractorApp`, su esquema y `release-macos.sh` no cambian
(criterio 1 de la fase). Los tests siguen alojados en `ExtractorApp`.

## Python embebido en la variante App Store

`bundle-python.sh` con `EXTRACTOR_VARIANT=appstore` (lo exporta la fase de
build del target nuevo):

1. No instala `playwright` (ni arrastra `greenlet`/`pyee`).
2. Quita `_tkinter*.so`, `lib/python3.13/{tkinter,idlelib,turtledemo}`,
   `turtle.py` y las librerías Tcl/Tk (`tcl*`, `tk*`, `itcl*`, `thread*`,
   `libtcl*`, `libtk*`) — lo mismo que el spike, validado por App Store
   Connect.
3. Firma `python3.13` con `scripts/appstore/python-child.entitlements`
   (solo `app-sandbox` + `inherit`), el resto sin entitlements.

En la variante Developer ID el script se comporta exactamente igual que hoy.

## Escrituras dentro del bundle (MASBUILD-05)

- `core.py` solo escribe en `Path.home()/.cache/extractor-url` (caché e
  historial). Bajo sandbox, `HOME` del hijo es el contenedor de la app
  (`~/Library/Containers/com.edefrutos.ExtractorApp.appstore/Data`), así que
  no toca el bundle. La lectura del historial desde Swift es asunto de la
  Fase 27.
- La única escritura posible dentro del bundle son los `.pyc` en
  `__pycache__`. `PythonBridge` debe pasar `PYTHONDONTWRITEBYTECODE=1` cuando
  usa el Python del bundle (en las dos variantes: escribir dentro de un
  `.app` firmado también rompe su firma en Developer ID).

## Manifiesto de privacidad (MASBUILD-04)

Categorías de API con «required reason» que el bundle probablemente usa
(a confirmar contra la documentación de Apple «Describing use of required
reason API» al ejecutar):

| Categoría | Quién la usa | Razón candidata |
|---|---|---|
| `NSPrivacyAccessedAPICategoryUserDefaults` | `@AppStorage`/`UserDefaults` | `CA92.1` (datos solo de la app) |
| `NSPrivacyAccessedAPICategoryFileTimestamp` | `stat()` de libpython (caché con caducidad en `core.py`) | `C617.1` (ficheros dentro del contenedor) |
| `NSPrivacyAccessedAPICategorySystemBootTime` | `mach_absolute_time` de libpython (`time.monotonic`) | `35F9.1` (medir tiempo transcurrido) |
| `NSPrivacyAccessedAPICategoryDiskSpace` | Posible `statfs` en libpython | Solo si el escáner de Apple lo detecta |

Sin datos recogidos (`NSPrivacyCollectedDataTypes` vacío),
`NSPrivacyTracking = false`. El spike no recibió avisos de manifiesto, pero
el build se validó sin él; se añade igualmente porque es obligatorio desde
mayo de 2024.

## Mejora de errores (hallazgo de la Fase 24)

`ExtractionError.emptyOutput` no lleva detalle; en la Parte A ocultó el
`ModuleNotFoundError` real. Pasa a `emptyOutput(detail: String?)` con
`PythonBridge.stderrSummary(stderr)`. Afecta a las dos variantes.

## Riesgos

1. **Editar `project.pbxproj` a mano** (aquí no hay Xcode): se valida que el
   fichero se parsea y que los IDs son únicos; la prueba real es abrirlo y
   compilar los dos esquemas en el Mac (checkpoint humano).
2. **Firma del hijo en Debug:** Xcode inyecta `get-task-allow` en el `.app`,
   no en `python3.13`, que firma `bundle-python.sh` con sus propios
   entitlements → no debería romper la herencia. Se comprueba en el
   checkpoint.
3. **Export App Store** re-firma la app pero no los binarios sueltos de
   `Resources` (mismo problema que en Developer ID). El script de
   empaquetado App Store re-firma el Python con Apple Distribution y los
   entitlements de hijo, como hizo el spike. La subida real es de la Fase 28.

## Fuentes

- [Apple privacy manifest — .NET MAUI docs (códigos de razón)](https://learn.microsoft.com/dotnet/maui/ios/privacy-manifest)
- [The Privacy Manifest Deep Dive](https://blakecrosley.com/blog/privacy-manifest-deep-dive)
- `.planning/research/APPSTORE.md` y `24-01-SUMMARY.md` (evidencia del spike).
