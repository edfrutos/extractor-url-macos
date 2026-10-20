# Research: distribución en Mac App Store (v11.0)

*Investigado: 2026-10-20 — base para REQUIREMENTS/ROADMAP de v11.0.*

## Decisiones del usuario (2026-10-20)

- **Conviven las dos distribuciones**: el release Developer ID + Sparkle de
  GitHub sigue igual (con Chromium, CLI y runtime updater); se añade una
  variante App Store con App Sandbox.
- **JavaScript en la variante App Store**: se sustituye Chromium/Playwright
  por un `WKWebView` oculto que renderiza la página y entrega el HTML a Python.
- **Precio**: gratis, sin compras in-app (sin StoreKit).

## Qué choca hoy con la Mac App Store

| Pieza actual | Problema | Tratamiento en la variante App Store |
|---|---|---|
| `com.apple.security.app-sandbox = false` | Guideline 2.4.5(i): las apps del Mac App Store deben estar en sandbox | Sandbox ON + entitlements mínimos (red cliente, ficheros elegidos por el usuario) |
| Sparkle (`CheckForUpdatesView`, `SPUStandardUpdaterController`) | 2.4.5(vii): las actualizaciones solo por la App Store | Excluido por flag de compilación |
| `RuntimeUpdater` (override de `PYTHONPATH` descargado) | 2.4.5(iv) / 2.5.2: no se puede descargar código que añada o cambie funcionalidad | Excluido por flag de compilación |
| Chromium embebido (~780 MB, sandbox propio) | Muy difícil de ejecutar bajo App Sandbox; tamaño | No se empaqueta; JS vía `WKWebView` |
| Rutas configurables a un Python/script externos (Ajustes) | El sandbox no deja ejecutar binarios fuera del bundle | Ocultas: solo el intérprete embebido |
| Python en `Contents/Resources/python` con `.so`/`.dylib` | Código nativo en `Resources` es frágil para firma/validación; ubicación convencional = `Frameworks`/`Helpers` | Verificar en el spike (Fase 24); mover si App Store Connect lo rechaza |
| `_tkinter*.so` + Tcl/Tk en python-build-standalone | Rechazo real documentado: símbolos Tcl marcados como API no pública ([foro Apple 758567](https://developer.apple.com/forums/thread/758567)) | Eliminar `_tkinter` y Tcl/Tk del bundle App Store (la GUI tkinter no se usa en la app) |
| `--clipboard` vía `pbcopy` | Lanzar `/usr/bin/pbcopy` desde el sandbox no está garantizado | La app copia con `NSPasteboard`; no usar `--clipboard` desde la app |

## Python embebido bajo App Sandbox

- El intérprete hijo lanzado con `Process()` hereda el sandbox si se firma
  **solo** con `com.apple.security.app-sandbox` + `com.apple.security.inherit`.
  Cualquier otra clave de sandbox (o `get-task-allow`) en el hijo hace que
  `libsecinit` aborte el proceso ([foro Apple 706390](https://developer.apple.com/forums/thread/706390),
  [770046](https://developer.apple.com/forums/thread/770046)).
- Un hijo con esas claves lanzado por un padre **sin** sandbox falla con
  «Process is not in an inherited sandbox» → la variante Developer ID no
  debe usar esa firma del intérprete (firmas distintas por variante).
- El bundle es de solo lectura: `PYTHONDONTWRITEBYTECODE=1` (o `.pyc`
  precompilados) y cualquier caché/log en el contenedor de la app
  (`~/Library/Containers/<bundle-id>/…`), nunca junto al script.
- Los scripts Python incluidos en el bundle y revisados con la app no
  infringen 2.5.2; sí lo haría descargarlos después (motivo de excluir el
  runtime updater).

## Requisitos de envío (estado a 2026-10)

- Desde el 28-abr-2026, las subidas deben compilarse con **Xcode 26+** y SDK
  de la generación 26 ([Apple — upcoming requirements](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)).
  El proyecto ya usa Xcode 27 → cumple.
- macOS: los ficheros subidos no pueden llevar el atributo extendido de
  cuarentena ([Apple — upcoming requirements](https://www.developer.apple.com/news/upcoming-requirements/)).
  `bundle-python.sh` ya hace `xattr -rd com.apple.quarantine`; habrá que
  aplicarlo a todo el bundle App Store.
- Pendiente de confirmar en la Fase 25 con la documentación vigente:
  `PrivacyInfo.xcprivacy` (APIs con «required reason» usadas por la app y
  por el Python embebido), `ITSAppUsesNonExemptEncryption`,
  `LSApplicationCategoryType`.
- Certificados: **Apple Distribution** + **Mac Installer Distribution**,
  perfil de aprovisionamiento Mac App Store para el bundle ID, registro de
  la app en App Store Connect. El equipo (V29BTBRY6G) ya está en el
  Apple Developer Program (firma Developer ID existente).
- Ficha: nombre, subtítulo, descripción, palabras clave, capturas de Mac,
  URL de política de privacidad (obligatoria aunque no se recojan datos),
  URL de soporte, clasificación por edades, «Datos no recopilados».

## Riesgos principales (por orden)

1. **Python embebido en sandbox + validación de App Store Connect** (ubicación
   del código nativo, firma por capas, `_tkinter`). Si falla, cambia el
   diseño de todo el milestone → se valida primero con un spike.
2. **Paridad de extracción sin Chromium**: `WKWebView` no es Chromium; algunas
   SPAs pueden renderizar distinto. Aceptable si la heurística actual
   (`_looks_insufficient`) sigue decidiendo cuándo renderizar.
3. **Revisión de Apple**: una app que ejecuta un intérprete embebido puede
   recibir preguntas; tener preparada la explicación (scripts incluidos,
   nada descargado).

## Fuentes

- [Mac App That Embed Python Interpreter Rejected from App Store — Apple Developer Forums](https://developer.apple.com/forums/thread/758567)
- [Resolving App Sandbox Inheritance Problems — Apple Developer Forums](https://developer.apple.com/forums/thread/706390)
- [Re: Resolving App Sandbox Inheritance — Apple Developer Forums](https://developer.apple.com/forums/thread/770046)
- [electron/electron #5248 — Process is not in an inherited sandbox](https://github.com/electron/electron/issues/5248)
- [SDK minimum requirements — Apple Developer](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)
- [Upcoming requirements — Apple Developer](https://www.developer.apple.com/news/upcoming-requirements/)
- [Mac App Store apps must be sandboxed (2.4.5) — resumen de la guideline](https://conductatlas.com/platform/apple/apple-app-store-review-guidelines/provision/CA-P-018850/mac-app-store-apps-must-be-sandboxed/)
- [Mac App Store apps must use the Mac App Store for updates — resumen](https://conductatlas.com/platform/apple/apple-app-store-review-guidelines/provision/CA-P-018856/mac-app-store-apps-must-use-mac-app-store-for-updates/)
