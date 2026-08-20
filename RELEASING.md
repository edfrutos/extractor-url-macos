# Publicar una versión de ExtractorApp

Guía para publicar releases de ExtractorApp con actualización automática vía
Sparkle. Cubre la configuración de una sola vez (nunca se repite salvo que
cambies de Mac o pierdas el Keychain) y el uso repetido de
`scripts/release-macos.sh` en cada release.

## 1. Configuración de una sola vez

No la hace `scripts/release-macos.sh` — son pasos manuales, interactivos,
que guardan secretos en el Keychain de tu Mac. **Nunca pegues ninguno de
estos valores en un archivo del repo.**

### 1.1 Clave EdDSA de Sparkle

La primera vez que ejecutes `scripts/release-macos.sh`, el propio script
descarga las herramientas CLI de Sparkle a `.build-cache/sparkle-tools/`.
Con ellas ya presentes:

```bash
.build-cache/sparkle-tools/bin/generate_keys
```

Genera un par de claves y las guarda en tu Keychain. Imprime la clave
**pública** — cópiala y sustitúyela en
`ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj`, en las
**dos** apariciones de `INFOPLIST_KEY_SUPublicEDKey` (bloques Debug y
Release), reemplazando el placeholder `"PENDIENTE-FASE-13-generate_keys"`.

La clave **privada** nunca sale del Keychain — no la necesitas copiar a
ningún sitio.

### 1.2 Credenciales de notarización

En [appleid.apple.com](https://appleid.apple.com) → Seguridad →
Contraseñas específicas de apps, genera una contraseña específica de app
(nunca uses tu contraseña normal de Apple ID para esto).

```bash
xcrun notarytool store-credentials "ExtractorApp-Notary" \
  --apple-id <tu-apple-id> \
  --team-id <TU-TEAM-ID> \
  --password <contraseña-específica-de-app>
```

Esto guarda las credenciales cifradas en tu Keychain bajo el perfil
`"ExtractorApp-Notary"` (el nombre que usa `scripts/release-macos.sh` por
defecto — puedes cambiarlo con la variable de entorno `NOTARY_PROFILE` si
usas otro).

Tu Team ID lo encuentras en
[developer.apple.com/account](https://developer.apple.com/account) →
Membership.

### 1.3 GitHub CLI autenticado

```bash
gh auth status
```

Si no lo está: `gh auth login`.

## 2. Publicar una versión nueva

Con los 3 pasos anteriores ya hechos una vez:

```bash
scripts/release-macos.sh 1.1
```

El script:

1. Comprueba que la clave EdDSA, el perfil de notarización y `gh auth` están listos — falla explícito y pronto si algo falta.
2. Sube `MARKETING_VERSION` y `CURRENT_PROJECT_VERSION` en `project.pbxproj`.
3. Archiva y exporta con firma Developer ID (`xcodebuild archive` + `-exportArchive`).
4. Empaqueta a `.zip` con `ditto` (nunca `zip`/`unzip` genéricos — rompen la firma de código, ver Troubleshooting).
5. Notariza (`notarytool submit --wait`) y graba el ticket al `.app` (`stapler staple`) — en ese orden, antes de crear el `.zip` final.
6. Guarda el `.zip` en el histórico local `.build-cache/release/archive/` (necesario para que `generate_appcast` genere delta updates) y genera `appcast.xml`.
7. Publica el `.zip` como asset de un GitHub Release nuevo.
8. Copia el `appcast.xml` a la raíz del repo e imprime el `git add`/`commit`/`push` exacto a ejecutar.

El script **no** hace el `git push` final por ti — revisa el resumen y
ejecuta tú mismo los comandos que imprime al terminar. Es la acción que
activa el feed de Sparkle para los usuarios existentes; queda bajo tu
control explícito.

## 3. Verificación post-release

```bash
curl -I https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml
```

Confirma que el feed responde `200` y (si lo abres) lista la versión nueva.
GitHub cachea `raw.githubusercontent.com` unos minutos — si ves la versión
antigua justo después de publicar, espera un poco antes de asumir que algo
falló.

Si tienes una instalación anterior de la app a mano, pulsa
"Buscar actualizaciones…" desde su menú y confirma que detecta e instala la
nueva versión sin avisos de Gatekeeper.

## 4. Seguridad

Ninguna de las tres piezas de secreto de este pipeline vive en el repo:

- **Clave privada EdDSA** — Keychain, generada por `generate_keys`.
- **Credenciales de notarización** — Keychain, guardadas por `notarytool store-credentials`.
- **Token de GitHub** — gestionado por tu sesión de `gh auth login`.

`scripts/release-macos.sh` solo referencia nombres de perfil de Keychain
(`NOTARY_PROFILE`) — nunca lee ni escribe el material secreto en sí.

## 5. Troubleshooting

**`unzip` o `zip` rompen la firma ("app is damaged")** — usa siempre
`ditto -c -k --sequesterRsrc --keepParent` para comprimir, y `ditto -x -k`
si necesitas descomprimir para inspeccionar algo a mano. Herramientas
genéricas pueden introducir archivos `._*` (AppleDouble) que rompen la
firma sellada del bundle.

**`notarytool` devuelve `Invalid`** — revisa el log completo que imprime
el script; si señala binarios dentro de `Sparkle.framework`, casi siempre
es un problema de firma no-profunda del archive — normalmente
`xcodebuild -exportArchive` con `method: developer-id` lo firma todo
automáticamente, así que si esto pasa, revisa que no haya un paso manual
de `codesign` intermedio rompiendo la firma completa.

**Sparkle no detecta la versión nueva** — confirma que
`CURRENT_PROJECT_VERSION` subió respecto a la versión ya publicada (el
script lo hace automáticamente, pero si se ejecutó dos veces con el mismo
argumento de versión sin querer, podría no haber subido lo esperado).
Sparkle compara por `CFBundleVersion`, no por `MARKETING_VERSION`.

**El appcast no refleja la versión nueva tras un rato razonable** —
confirma que de verdad hiciste el `git push` que el script imprimió al
final; es el paso manual que activa el feed.

**`.build-cache/release/archive/` se perdió (Mac nuevo, caché borrada)** —
`generate_appcast` seguirá funcionando, pero solo con las versiones que
tenga localmente; los delta updates entre versiones antiguas y la nueva no
se generarán (Sparkle usará la actualización completa igualmente, solo más
pesada). Si quieres reconstruir el histórico, descarga los `.zip` de
releases anteriores desde GitHub Releases a esa carpeta antes de publicar.
