# Research: Fase 28 — App Store Connect y envío

*Investigado: 2026-10-23, sobre el código en `3a5e4c7`.*

## Qué hay ya hecho

| Req. | Estado | Falta |
|---|---|---|
| STORE-01 Certificados, perfil, registro | Hecho en la Fase 24: «Apple Distribution», «3rd Party Mac Developer Installer», perfil «Extractor URL AppStore» y ficha «Extractor URL» (es-ES, SKU `extractor-url-appstore`). El build 2.3 (13) ya está en TestFlight. | Solo comprobar que el certificado y el perfil siguen vigentes. |
| STORE-02 Ficha | Nombre «Extractor URL» registrado. `LSApplicationCategoryType` = Productividad, `ITSAppUsesNonExemptEncryption` = `false`. | Subtítulo, descripción, palabras clave, texto promocional, capturas, edades, precio. `NSHumanReadableCopyright` está vacío. |
| STORE-03 Privacidad y soporte | `PrivacyInfo.xcprivacy` sin datos recopilados ni tracking. | Las páginas web (el repo es público, sin GitHub Pages) y la etiqueta en App Store Connect. |
| STORE-04 Script de subida | `package-appstore.sh` archiva, firma y genera el `.pkg`. La subida es manual con Transporter. El número de build hay que subirlo a mano en Xcode. | Subida desde el script y número de build sin tocar el proyecto. |
| STORE-05 TestFlight | Probado solo el spike (Fase 24). | Probar el build final. |
| STORE-06 Revisión | — | Enviar y atender a App Review. |

## Decisiones

- **GitHub Pages desde `/docs` de `main`** (decisión del usuario).
  - URL: `https://edfrutos.github.io/extractor-url-macos/`, con
    `privacidad.html` y `soporte.html`.
  - HTML estático sin Jekyll (`.nojekyll`), sin JavaScript, sin
    analítica, sin fuentes externas. Así la página de privacidad no
    contradice lo que dice.
  - El soporte remite a los issues de GitHub. No se publica ningún correo.
  - Se activa con `gh api` (POST `/repos/…/pages`, `source.path=/docs`)
    tras subir `docs/` a `main`.
- **Política de privacidad** fiel a la app:
  - No recoge, no envía ni comparte datos personales. No hay cuentas,
    analítica, publicidad ni tracking.
  - Se conecta solo a las URL que escribe el usuario.
  - Caché e historial (solo metadatos) quedan en el contenedor de la app,
    en su Mac. Se borran al borrar la app.
  - Los archivos que el usuario elige con el panel se leen o escriben en
    su Mac y no salen de él.
  - Etiqueta de App Store Connect: «Datos no recopilados».
- **Subida con `xcrun altool --upload-app --type macos`** y una clave de la
  API de App Store Connect (`ASC_KEY_ID`, `ASC_ISSUER_ID`, y
  `AuthKey_<id>.p8` en `~/.appstoreconnect/private_keys/`).
  - Antes, `altool --validate-app` con la misma clave.
  - Es opcional (`UPLOAD=1`). Sin clave, el script sigue terminando en el
    `.pkg` y Transporter sigue valiendo.
  - Confirmar los flags con `xcrun altool --help` en el Mac. Apple no
    publica una sinopsis actual, y la de la guía de Tauri es de 2024.
- **Número de build** con `APPSTORE_BUILD=<n>`, pasado a `xcodebuild
  archive` como `CURRENT_PROJECT_VERSION`.
  - No edita el `.pbxproj`.
  - Si falta, se usa el del proyecto y el script avisa si es 13 o menor
    (el 13 ya está usado).
- **Copyright:** `NSHumanReadableCopyright` = «© 2026 Eugenio de Frutos
  Sánchez» en las dos variantes.
- **Ficha** en `appstore/FICHA.md`, versionada en el repo, con los límites
  de Apple:
  - nombre: 30 caracteres;
  - subtítulo: 30;
  - texto promocional: 170;
  - descripción: 4000;
  - palabras clave: 100 en total, separadas por comas sin espacio.
  - Incluye las notas para App Review: explicar el intérprete Python
    embebido (scripts incluidos y firmados, nada descargado, guideline
    2.5.2) y una URL de prueba.
- **Capturas**: 16:10, una de 1280×800, 1440×900, 2560×1600 o 2880×1800.
  Las hace el usuario en su Mac. La ficha propone 3–5 escenas.
- **Clasificación por edades:** todo «No» en el cuestionario. La app
  muestra contenido web que elige el usuario, pero no es un navegador de
  acceso libre. Si App Review pide «Acceso web sin restricciones», se marca
  y queda 17+.

## Riesgos

1. **App Review y el intérprete embebido** (2.5.2): la nota de revisión lo
   explica de antemano.
2. **«SPI file size > max»** de Transporter (Fase 24): Transporter omitió
   la comprobación local de API privadas. El servidor no avisó, pero App
   Review puede repetirla.
3. **Clasificación por edades** (ver arriba).

## Fuentes

- [Screenshot specifications — App Store Connect Help](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
- [Upload builds — App Store Connect Help](https://www.developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [altool — Get started](https://help.apple.com/asc/appsaltool/en.lproj/static.html)
- [Tauri — App Store distribution (altool --upload-app con clave de API)](https://v2.tauri.app/distribute/app-store/)
- [altool: fallo de autenticación al subir un pkg grande](https://developer.apple.com/forums/thread/742588)
