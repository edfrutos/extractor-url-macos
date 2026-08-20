---
phase: 13-release-pipeline
type: research
status: complete
created: "2026-08-20"
---

# Phase 13: Pipeline de release y publicación — Research

## User Constraints

### Locked Decisions (desde v5.0 planning y Fase 12)

- `scripts/release-macos.sh` automatiza build → firma Developer ID → notarización → appcast → publicación en GitHub Releases (decisión explícita del usuario).
- Appcast alojado en GitHub Releases (`raw.githubusercontent.com` para `appcast.xml`, assets de Release para el binario).
- Usuario tiene cuenta Apple Developer Program de pago — notarización viable.
- La clave privada EdDSA y las credenciales de notarización NUNCA se commitean.

### Claude's Discretion

- Formato del archivo de distribución (`.zip` vs `.dmg`) — Sparkle soporta ambos.
- Estructura exacta del script (single-file bash vs varios scripts auxiliares).
- Dónde guardar el histórico de archivos de release para que `generate_appcast` pueda generar delta updates.

### Deferred Ideas (OUT OF SCOPE — v5.0)

- Delta updates garantizados entre todas las versiones históricas (se generan "gratis" si el histórico local existe, pero no es un requisito verificar que siempre estén disponibles).
- CI/CD automático (GitHub Actions) que dispare el release al hacer push de un tag — v6+ si hace falta; por ahora el script se ejecuta a mano en el Mac del usuario.

## Summary

Fase 13 cierra el ciclo abierto por la Fase 12: `INFOPLIST_KEY_SUPublicEDKey`
sigue siendo el placeholder `"PENDIENTE-FASE-13-generate_keys"`, y
`INFOPLIST_KEY_SUFeedURL` apunta a un `appcast.xml` que todavía no existe en
el repo. Esta fase genera la clave real, construye un pipeline reproducible
de publicación, y dispara la primera versión real navegable por Sparkle.

**Hallazgo clave de esta research**: el workaround de la Fase 12 (clonar
Sparkle con `git clone` en vez de dejar que Xcode resuelva el paquete
remoto) trae una consecuencia directa para esta fase — el clon de código
fuente en `.build-cache/Sparkle/bin/` **no contiene** los binarios
`generate_keys`/`sign_update`/`generate_appcast` precompilados (solo
`old_dsa_scripts/`, heredado de versiones DSA antiguas). Esos binarios
normalmente los descarga Xcode automáticamente como "artifacts" al resolver
el paquete remoto — algo que en esta máquina no funciona (el mismo bug de
búsqueda de paquetes de la Fase 12). La solución es descargar por separado
el **tarball de distribución** de Sparkle (`Sparkle-2.9.6.tar.xz`, última
release estable verificada en esta research vía `gh api
repos/sparkle-project/Sparkle/releases/latest`), que sí contiene esos
binarios listos para usar en `bin/`. Es una descarga independiente del
paquete SPM que usa la app — dos concerns distintos, dos soluciones
distintas.

## Análisis del Estado Actual del Código

### `project.pbxproj` — placeholders pendientes de esta fase

```
INFOPLIST_KEY_SUFeedURL = "https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml";
INFOPLIST_KEY_SUPublicEDKey = "PENDIENTE-FASE-13-generate_keys";
MARKETING_VERSION = 1.0;
CURRENT_PROJECT_VERSION = 1;
```

`MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` están duplicados en 2 bloques
(Debug/Release) del target `ExtractorApp` — el script debe actualizar
ambos, igual que se hizo a mano con `INFOPLIST_KEY_SU*` en la Fase 12. No
existe `agvtool`-compatible `Info.plist` físico (mismo hallazgo de la Fase
12: `GENERATE_INFOPLIST_FILE = YES`), así que `agvtool` no sirve aquí —
la actualización de versión debe hacerse por sustitución de texto en
`project.pbxproj`, con el mismo cuidado que ya se aplicó al añadir las
claves de Sparkle (verificar que el patrón de `old_string` sea único o que
`replace_all` afecte exactamente a los bloques esperados).

### `.build-cache/Sparkle` — qué hay y qué falta

Presente (clon de código fuente, Fase 12): framework Sparkle en sí,
`Package.swift`, `Documentation/`.
Ausente: binarios CLI (`generate_keys`, `sign_update`, `generate_appcast`)
— hay que descargarlos aparte (ver Standard Stack).

### Convenciones de `scripts/` ya establecidas

`scripts/bundle-python.sh` fija el patrón a seguir: `set -euo pipefail`,
comentario de cabecera con propósito + cómo actualizar versión, sección de
versiones al principio (única parte a tocar en actualizaciones futuras),
guard clauses (`: "${VAR:?mensaje}"`) para variables de entorno requeridas,
y un directorio de caché bajo `.build-cache/` para todo lo descargado
(reutilizable entre ejecuciones, gitignored).

## Standard Stack

- **`xcodebuild archive` + `xcodebuild -exportArchive`** — build reproducible desde línea de comandos, equivalente automatizable de `Product → Archive → Distribute App` en la UI de Xcode (documentación oficial de Sparkle lo menciona explícitamente como el camino de CI). Requiere un `exportOptionsPlist` con `method: developer-id`.
- **`xcrun notarytool`** (Xcode 13+, disponible en Xcode 26.6) — reemplaza el antiguo `altool`. Flujo en dos partes:
  1. **Configuración única, interactiva, NO en el script**: `xcrun notarytool store-credentials "<nombre-perfil>" --apple-id <email> --team-id <TEAMID> --password <contraseña-específica-de-app>` — guarda las credenciales cifradas en el Keychain del Mac bajo ese nombre de perfil. Se hace una vez, a mano, en el checkpoint humano — nunca en el script ni en el repo.
  2. **Uso repetido, sí en el script**: `xcrun notarytool submit <archivo.zip> --keychain-profile "<nombre-perfil>" --wait` (sube y espera el resultado sin polling manual) seguido de `xcrun stapler staple <ExtractorApp.app>` (grapa el ticket de notarización al bundle, para que Gatekeeper no necesite red la primera vez que se abre).
- **`generate_keys`** (una vez) / **`sign_update`** / **`generate_appcast`** (cada release) — del tarball de distribución oficial `Sparkle-2.9.6.tar.xz` (verificar versión más reciente en el momento de ejecutar, vía `gh api repos/sparkle-project/Sparkle/releases/latest`, no fijar 2.9.6 a fuego en el script).
- **`gh release create` / `gh release upload`** — ya usado indirectamente en este proyecto (el propio flujo de trabajo de Claude Code usa `gh`); publica el binario como asset de una GitHub Release nueva, con el tag como tarjeta de versión.
- **`ditto -c -k --sequesterRsrc --keepParent`** — empaquetado a `.zip` preservando symlinks y la firma de código de `Sparkle.framework` (recomendación explícita de la documentación oficial de Sparkle sobre `unzip`/`ditto`, y confirmada como pitfall real en el ejemplo de producción de CodexBar: `unzip` puede introducir archivos `._*` AppleDouble que rompen la firma sellada).

## Package Legitimacy Audit

Todas las herramientas son de Apple (`xcodebuild`, `notarytool`, `stapler`,
`gh` — GitHub oficial) o del propio proyecto Sparkle ya auditado en la Fase
12. Sin dependencias nuevas de terceros.

## Architecture Patterns

### Flujo completo del script `scripts/release-macos.sh`

```
1. Leer versión objetivo (argumento del script, ej. "1.1")
2. Actualizar MARKETING_VERSION y CURRENT_PROJECT_VERSION en project.pbxproj
   (ambos bloques Debug/Release del target ExtractorApp)
3. xcodebuild archive -scheme ExtractorApp -archivePath .build-cache/release/ExtractorApp.xcarchive
4. xcodebuild -exportArchive -archivePath ... -exportOptionsPlist ... -exportPath .build-cache/release/export/
   (exportOptionsPlist con method=developer-id, generado por el propio script o versionado como plantilla)
5. ditto -c -k --sequesterRsrc --keepParent ExtractorApp.app ExtractorApp-<version>.zip
6. xcrun notarytool submit ExtractorApp-<version>.zip --keychain-profile "<perfil>" --wait
7. Volver a extraer, stapler staple ExtractorApp.app, volver a comprimir a zip
   (staplear DESPUÉS de notarizar, ANTES del zip final que se publica — el
   stapler opera sobre el .app, no sobre el .zip)
8. Copiar el zip final a una carpeta histórica acumulativa (.build-cache/release/archive/)
   que conserva TODAS las versiones publicadas hasta ahora — generate_appcast
   la necesita completa para generar delta updates entre versiones antiguas
9. generate_appcast .build-cache/release/archive/ --download-url-prefix
   "https://github.com/edfrutos/extractor-url-macos/releases/download/v<version>/"
   → produce appcast.xml actualizado con TODAS las entradas históricas
10. gh release create "v<version>" .build-cache/release/archive/ExtractorApp-<version>.zip
    --title "ExtractorApp <version>" --notes "..."
11. Copiar el appcast.xml generado a la raíz del repo, git add + commit + push
    a main (para que raw.githubusercontent.com lo sirva actualizado)
```

### Por qué la carpeta histórica de archivos debe persistir entre ejecuciones

`generate_appcast` regenera el `appcast.xml` **completo** a partir de TODOS
los archivos presentes en la carpeta que se le indique — no solo el nuevo.
Si esa carpeta solo tuviera el archivo de la versión actual, el appcast
resultante perdería las entradas de versiones anteriores (aunque sigan
publicadas en GitHub Releases) y los delta updates dejarían de generarse.
Por eso el script debe guardar cada `.zip` publicado en
`.build-cache/release/archive/` de forma acumulativa (gitignored,
igual que el resto de `.build-cache/`) — y documentar en `RELEASING.md`
que si esa carpeta se pierde (Mac nuevo, `.build-cache/` borrado), hay que
redescargar los `.zip` de releases anteriores desde GitHub Releases para
reconstruirla antes de publicar la siguiente versión, o aceptar que el
appcast solo listará la versión nueva en adelante (funcionalmente correcto,
solo pierde delta updates e historial completo).

### `exportOptionsPlist` — plantilla mínima para Developer ID

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

## Don't Hand-Roll

- **No reimplementar el polling de notarización** — `notarytool submit --wait` ya bloquea hasta tener un resultado definitivo (`Accepted`/`Invalid`), evita reinventar un loop de `notarytool info <id>` con sleeps.
- **No firmar el appcast a mano** — `generate_appcast` ya calcula y añade las firmas EdDSA de cada `<enclosure>` automáticamente a partir de la clave en Keychain; escribir el XML del appcast a mano (como advierte la propia documentación oficial, "no recomendado") reintroduce la posibilidad de un error de firma silencioso.
- **No gestionar el número de build (`CURRENT_PROJECT_VERSION`) manualmente en cada release** — el script lo incrementa o lo deriva de la versión marketing de forma determinista (a decidir en el plan: incremento simple +1, o derivado de la propia versión semántica), para que nunca haya que recordar hacerlo a mano y arriesgar una versión duplicada que Sparkle no detecte como "nueva".

## Common Pitfalls

### Pitfall 1: `unzip` rompe la firma de código (AppleDouble `._*`)

Confirmado como problema real en producción (ejemplo CodexBar). Usar
siempre `ditto` para comprimir Y para descomprimir/verificar durante el
propio script — nunca `unzip`/`zip` genéricos sobre el `.app`.

### Pitfall 2: Staplear en el momento equivocado

`stapler staple` debe aplicarse al `.app` **después** de que notarytool
devuelva `Accepted`, y **antes** de volver a comprimir el `.zip` que se
sube a GitHub Releases y se referencia en el appcast. Si se staplea el
`.zip` en vez del `.app` dentro de él, o se comprime antes de staplear, el
usuario final recibe un binario notarizado pero sin el ticket grapado —
Gatekeeper necesitará red la primera vez que se abra (funciona, pero peor
experiencia y falla si el usuario está offline en ese momento).

### Pitfall 3: Notarización de componentes internos de Sparkle

El framework Sparkle embebe sus propios helpers (`Autoupdate`, `Updater.app`
XPC services `Downloader`/`InstallerLauncher` en Sparkle 2 con sandboxing,
aunque este proyecto tiene App Sandbox OFF así que probablemente no aplican
todos). Si `notarytool submit` devuelve `Invalid` señalando binarios dentro
de `Sparkle.framework` sin firmar correctamente, la causa casi siempre es
firma no-profunda (`codesign` sin `--deep --timestamp --options runtime`
en el momento de exportar el archive) — mitigado en este proyecto porque
`xcodebuild -exportArchive` con `method: developer-id` firma el árbol
completo automáticamente sin pasos manuales de `codesign`, pero es el
primer sitio a mirar si notarytool falla aquí.

### Pitfall 4: Version bump duplicado o no estrictamente creciente

Si `CURRENT_PROJECT_VERSION` no aumenta respecto al último publicado (por
un fallo del script al editar `project.pbxproj`, o por ejecutar el script
dos veces con el mismo argumento de versión), Sparkle en las instalaciones
existentes no detectará la "nueva" versión como una actualización real. El
script debe fallar explícitamente (no silenciosamente) si detecta que la
versión objetivo no es estrictamente mayor que la última publicada
conocida (leída del `appcast.xml` actual del repo, si existe).

### Pitfall 5: Caché de `raw.githubusercontent.com`

Ya documentado en `12-RESEARCH.md` — tras publicar, verificar con
`curl -I` que el `appcast.xml` servido refleja la nueva versión antes de
dar el release por terminado; si no, esperar unos minutos (CDN de GitHub)
antes de asumir que algo falló.

## Estrategia de Verificación de esta Fase

Esta fase, a diferencia de Fase 11 (Python, verificable con pytest en
cualquier entorno) y parcialmente Fase 12 (Swift, verificable con
`xcodebuild build` aunque sin credenciales reales), **no se puede verificar
de forma significativa fuera del Mac del usuario con sus credenciales
reales** — firma Developer ID, notarización y publicación en GitHub
Releases son, por diseño, acciones que requieren secretos que nunca deben
existir en este sandbox. El plan de esta fase debe escribir el script
completo y su documentación aquí, y delegar la ejecución real (incluida la
generación de la clave EdDSA y el primer release real) a un checkpoint
humano — mismo patrón que Fase 10 y Fase 12, pero con un paso adicional
irreducible: un release real es, en sí mismo, una acción visible
(publicación en GitHub) que requiere confirmación explícita antes de
ejecutarse, no solo una compilación local.

## Security Domain

- **Clave privada EdDSA**: generada una vez con `generate_keys`, vive en el
  Keychain del Mac — el script nunca la lee ni la expone; `sign_update`/
  `generate_appcast` acceden a ella directamente vía Keychain.
- **Credenciales de notarización**: guardadas una vez vía
  `notarytool store-credentials` bajo un nombre de perfil — el script
  referencia solo el nombre del perfil (`--keychain-profile`), nunca un
  email/contraseña/API key en texto plano.
- **Token de GitHub para `gh release`**: ya gestionado por la sesión de
  `gh auth login` del usuario en su Mac — el script no necesita gestionar
  credenciales nuevas para esto.
- Ninguna de estas tres piezas de secreto debe aparecer jamás en
  `scripts/release-macos.sh`, en el historial de git, ni en
  `RELEASING.md` — el script solo referencia nombres de perfil/Keychain,
  documentado explícitamente como requisito en `RELEASING.md`.

## Assumptions Log

- Se asume `.zip` (no `.dmg`) como formato de distribución — más simple de
  automatizar de forma fiable con `ditto`, sin depender de herramientas
  externas de creación de `.dmg`; la documentación oficial acepta ambos
  formatos sin preferencia funcional para el propósito de Sparkle.
- Se asume que el usuario ejecuta `notarytool store-credentials` y
  `generate_keys` como pasos de configuración de una sola vez ANTES de la
  primera ejecución del script — el script asume que ambos ya existen
  (Keychain) y falla con un mensaje explícito si no encuentra el perfil de
  notarización o si `SUPublicEDKey` sigue siendo el placeholder al momento
  de ejecutar.
- Se asume increment simple de `CURRENT_PROJECT_VERSION` (+1 respecto al
  valor actual en `project.pbxproj`) como estrategia de build number —
  determinista, sin necesidad de parsear el appcast existente; a confirmar
  en el plan si el usuario prefiere otra convención.

## Open Questions (RESOLVED)

- **¿`.zip` o `.dmg`?** → `.zip` vía `ditto`, más simple de automatizar sin dependencias externas.
- **¿Delta updates garantizados?** → No es un requisito verificado; se generan "gratis" si el histórico local en `.build-cache/release/archive/` existe, documentado el trade-off si se pierde.
- **¿CI/CD automático?** → Fuera de scope de v5.0; el script se ejecuta a mano en el Mac del usuario con sus credenciales.

## Sources

### Primary (HIGH confidence)

- `12-RESEARCH.md` (este mismo repo) — hallazgos ya verificados sobre Sparkle, reutilizados aquí (SUFeedURL, estructura de `project.pbxproj`, ausencia de `Info.plist` físico).
- `gh api repos/sparkle-project/Sparkle/releases/latest` — confirma la versión de distribución actual (`2.9.6`) y el nombre exacto del tarball (`Sparkle-2.9.6.tar.xz`) en el momento de esta research.
- Inspección directa de `.build-cache/Sparkle/bin/` en este mismo repo (vía el mismo mount de disco que usa la sesión del usuario) — confirma que el clon de código fuente de la Fase 12 NO trae los binarios CLI precompilados.
- `https://github.com/sparkle-project/sparkle-project.github.io/blob/master/documentation/publishing/index.md` (ya fetched en la research de Fase 12) — formato del appcast, `sign_update`, `generate_appcast`.

### Secondary (MEDIUM confidence)

- Búsqueda web sobre `notarytool submit --wait` / `store-credentials` — confirma el flujo de dos partes (configuración interactiva una vez, uso por perfil de Keychain en el script) y que `--wait` evita polling manual.
- `https://github.com/steipete/CodexBar/blob/main/docs/RELEASING.md` (ya fetched en la research de Fase 12) — confirma en un proyecto real de producción el pitfall de `unzip`/AppleDouble y el orden correcto notarizar→staplear→comprimir→publicar.

### Tertiary

- Ninguna fuente adicional consultada en esta sesión — la sintaxis exacta de `notarytool`/`stapler` en Xcode 26.6 concreto se confirma en el checkpoint humano (primera ejecución real), no aquí.

## Metadata

- Requirements cubiertos: UPDATE-04, UPDATE-05, UPDATE-06
- Depends on: Fase 12 completa (UPDATE-01..03 ya validados — `SUFeedURL` cableado, placeholder de `SUPublicEDKey` listo para sustituir)
- Bloquea: 13-01-PLAN.md (implementación del script) + checkpoint humano (generación de clave real + primer release real)
