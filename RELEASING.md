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

## 3. Publicar un canal beta (opcional)

`scripts/release-macos.sh` acepta un segundo argumento opcional con el
nombre del canal:

```bash
scripts/release-macos.sh 1.1-beta.1 beta
```

Sin ese segundo argumento, el comportamiento es exactamente el de
siempre (canal por defecto/estable). Con él:

- `generate_appcast` recibe `--channel beta`, que etiqueta **solo el item
  nuevo** que se añade en esta ejecución con `<sparkle:channel>beta</sparkle:channel>`
  — los releases estables ya publicados nunca se re-etiquetan ni se tocan.
- El GitHub Release se marca `--prerelease` y su título/notas incluyen
  `(beta)`, para que quede claro navegando la lista de releases a mano.
- Solo las apps cuyo usuario haya activado "Recibir actualizaciones beta"
  en Preferencias verán y podrán instalar esta versión — el resto sigue
  viendo únicamente el canal estable, sin cambios.

**Usa un `MARKETING_VERSION` distinto para cada beta** (ej. `1.1-beta.1`,
`1.1-beta.2`, …), nunca el mismo que la versión estable que planeas
publicar después. `generate_appcast` identifica los items existentes por
build number (`CURRENT_PROJECT_VERSION`, que este script ya sube
automáticamente y nunca colisiona) pero si reutilizas literalmente el
mismo `MARKETING_VERSION` para una beta y luego para el release "de
verdad", el segundo `gh release create "v${VERSION}"` fallaría por tag
duplicado (el preflight ya lo detecta explícito) — evita la confusión
usando un sufijo `-beta.N` mientras pruebas.

## 3.5. Chromium embebido (fallback JS)

Desde la Fase 17, cada build incluye Chromium vendorizado (vía Playwright)
para el fallback JS de SPAs sin hidratar — el usuario ya no necesita
`pip install playwright` + `playwright install chromium` a mano.

**Alcance: una sola arquitectura, la nativa del Mac de build** (normalmente
arm64 en Apple Silicon), no arm64+x64. Decisión de alcance explícita — ver
`.planning/phases/17-playwright-chromium-embebido/17-RESEARCH.md`. En un Mac
de la arquitectura NO nativa, el fallback JS embebido no está disponible y
la extracción degrada a HTML estático, exactamente igual que cuando
Playwright no está instalado — no es un error, es el comportamiento
esperado.

**Tamaño real medido:** 886MB para el `.app` completo (build Debug local sin
archivar/sin strip, DerivedData, arquitectura nativa arm64) — sensiblemente
por encima de la estimación inicial de ~250-350MB adicionales, que asumía
un snapshot de Chromium más ligero. Playwright 1.62.0 distribuye "Chrome for
Testing" (`Google Chrome for Testing.app`), un build más pesado que incluye
locales de decenas de idiomas y helpers duplicados. No es un límite duro del
proyecto, pero sí una cifra a tener muy presente al planificar la subida a
notarización/GitHub Releases. La cifra de un build Release/archivado real
(con strip y sin artefactos de Debug) queda pendiente de medir en el
próximo release real — normalmente algo menor, pero del mismo orden de
magnitud.

**Notarización más lenta de lo habitual:** con Chromium embebido, `xcrun
notarytool submit --wait` puede tardar sensiblemente más que los ~1-3
minutos habituales del bundle solo con Python (Apple procesa apps grandes
más despacio del lado del servidor). No hay mitigación de código — deja
margen de tiempo al publicar el primer release con esta fase, en vez de
hacerlo en el último momento.

## 3.6. Rollout por fases (opcional)

Desde la Fase 20, `scripts/release-macos.sh` acepta un rollout progresivo
en vez de publicar la actualización a todos los usuarios de golpe — vía
la variable de entorno `ROLLOUT_INTERVAL_SECONDS` (no un argumento
posicional, para no reordenar `<version> [canal]` ya establecido):

```bash
ROLLOUT_INTERVAL_SECONDS=86400 scripts/release-macos.sh 1.2
```

**Cómo lo reparte Sparkle:** `generate_appcast` recibe
`--phased-rollout-interval <segundos>`, que etiqueta **solo el item
nuevo** de esta ejecución con `<sparkle:phasedRolloutInterval>` —
igual que `--channel`, los releases ya publicados nunca se re-etiquetan.
Sparkle **hardcodea 7 grupos** de usuarios (identificados por un
`SUUpdateGroupIdentifier` aleatorio guardado en las preferencias de cada
instalación) y libera la actualización a un grupo nuevo cada
`ROLLOUT_INTERVAL_SECONDS` a partir de la fecha de publicación del item
(`pubDate`, que `generate_appcast` siempre incluye). **La duración total
del rollout es `ROLLOUT_INTERVAL_SECONDS × 7`** — con el ejemplo de
arriba (86400s = 1 día), el rollout completo tarda 7 días.

**Limitación importante — no confundir con un bug:** el rollout por fases
**no aplica** a comprobaciones manuales ("Buscar actualizaciones…" desde
el menú) ni a updates marcados como críticos — un usuario que pulse
"Buscar actualizaciones…" verá y podrá instalar la versión más reciente
de inmediato, salte el grupo que salte. Solo la comprobación automática
en segundo plano respeta el rollout. Si pruebas un release con rollout en
tu propio Mac usando el menú manual, verás la versión nueva al momento —
eso es el comportamiento esperado de Sparkle, no un fallo del pipeline.

**Monitorización/aborto:** Sparkle no expone un mecanismo oficial para
monitorizar el progreso de un rollout ni para abortarlo a mitad de
camino. Como este proyecto ya deja `appcast.xml` como un archivo del repo
para revisar y commitear a mano (decisión de la Fase 13), la forma
práctica de "abortar" un rollout en marcha es editar `appcast.xml`
directamente: quita el elemento `<sparkle:phasedRolloutInterval>` del
item en cuestión (deja el resto del item intacto) y commitea/pushea —
en el siguiente check automático de cualquier instalación, la
actualización deja de estar restringida por grupo y pasa a estar
disponible para todos de inmediato, igual que un release sin rollout.

## 4. Verificación post-release

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

## 5. Seguridad

Ninguna de las tres piezas de secreto de este pipeline vive en el repo:

- **Clave privada EdDSA** — Keychain, generada por `generate_keys`.
- **Credenciales de notarización** — Keychain, guardadas por `notarytool store-credentials`.
- **Token de GitHub** — gestionado por tu sesión de `gh auth login`.

`scripts/release-macos.sh` solo referencia nombres de perfil de Keychain
(`NOTARY_PROFILE`) — nunca lee ni escribe el material secreto en sí.

## 6. Troubleshooting

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
