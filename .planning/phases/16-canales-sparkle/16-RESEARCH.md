---
phase: 16-canales-sparkle
type: research
status: complete
created: "2026-08-21"
---

# Phase 16: Canales beta de Sparkle — Research

## User Constraints (from PROJECT.md / ROADMAP.md)

### Locked Decisions (desde v6.0 planning)

- Reutiliza el pipeline de la Fase 13 (`scripts/release-macos.sh`) — no un pipeline paralelo nuevo.
- Un usuario que NO ha optado al canal beta nunca ve ni recibe una versión beta — el canal por defecto sigue funcionando exactamente igual que en v5.0.
- Orden fijado por el usuario: Fase 16 va después de la 15, antes de la 17.

### Claude's Discretion

- Mecanismo exacto para etiquetar una versión como `beta` en `appcast.xml` (resuelto en este research: flag `--channel` de `generate_appcast`, ver Summary).
- Dónde vive el toggle de opt-in en la UI (`SettingsView`, sección nueva).
- Convención de versionado para releases beta (recomendado, no forzado por código).

### Deferred Ideas (OUT OF SCOPE — Fase 16)

- Rollouts por fases (`sparkle:phasedRolloutInterval`) — ya diferido explícitamente a v7+ en `PROJECT.md`/`REQUIREMENTS.md` Out of Scope de v6.0.
- Múltiples canales más allá de `beta` (p.ej. `nightly`) — el mecanismo que se implementa aquí es genérico (cualquier nombre de canal), pero solo se cablea `beta` en la UI por ahora.

## Summary

Sparkle 2 soporta canales nativamente: un `<item>` de `appcast.xml` con
`<sparkle:channel>beta</sparkle:channel>` solo es visible para updaters
cuyo `SPUUpdaterDelegate` opte explícitamente a ese canal vía
`allowedChannelsForUpdater:`. Un `<item>` **sin** esa etiqueta pertenece al
canal por defecto y lo ve todo el mundo, opte o no.

**Hallazgo clave verificado contra el código fuente real de Sparkle**
(clonado en `.build-cache/Sparkle/generate_appcast/`, no memoria): el flag
`--channel <nombre>` de `generate_appcast` (`main.swift:141-142`) etiqueta
**únicamente los items nuevos** que se crean en esa ejecución concreta —
`FeedXML.swift:333-343` calcula `createNewItem = (existingItems.count ==
0)` comparando contra el `appcast.xml` ya existente en el path de salida, y
el bloque que añade `<sparkle:channel>` (`FeedXML.swift:401-405`) está
**dentro** del `if createNewItem`. Los items ya existentes en el feed
(releases estables anteriores) nunca se re-etiquetan ni se tocan. Esto
descarta cualquier necesidad de una convención de nombre de archivo o de
separar el pipeline — basta con pasar `--channel beta` a la MISMA llamada
a `generate_appcast` que ya existe en `_archive_and_generate_appcast()`
cuando el release es beta, y omitir el flag cuando es estable.

Sin flag `--channel`, el comportamiento es idéntico al actual (v5.0) —
satisface directamente el requisito "un usuario no-beta no ve nunca una
versión beta" sin lógica adicional, porque Sparkle nunca considera un item
con canal fuera de `allowedChannelsForUpdater:` (que por defecto es un
conjunto vacío → solo canal por defecto).

## Análisis del Estado Actual del Código

### `scripts/release-macos.sh` — punto de integración

`_archive_and_generate_appcast()` (líneas 220-254) ya contiene la única
llamada a `generate_appcast` del pipeline:

```bash
"${SPARKLE_TOOLS_DIR}/bin/generate_appcast" \
    --download-url-prefix "https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/" \
    -o "${ARCHIVE_DIR}/appcast.xml" \
    "${ARCHIVE_DIR}"
```

Necesita un `--channel "${CHANNEL}"` condicional (solo si `CHANNEL` no está
vacío/es `stable`). `_publish_release()` (líneas 257-264) crea el GitHub
Release con `gh release create "v${VERSION}" ...` — sin cambios
estructurales, pero el título/notas deberían reflejar que es un release
beta para que quede claro en GitHub Releases (evita confundir a un usuario
que navegue la lista de releases a mano).

`VERSION="${1:?...}"` (línea 37) es el único argumento posicional hoy —
un segundo argumento posicional opcional (`CHANNEL="${2:-}"`) es el patrón
más simple, consistente con cómo el script ya usa variables de entorno
con default (`NOTARY_PROFILE`, `DEVELOPER_TEAM_ID`) para otras opciones.

### `ExtractorAppApp.swift` — `updaterDelegate: nil` hoy

```swift
updaterController = SPUStandardUpdaterController(
    startingUpdater: true,
    updaterDelegate: nil,
    userDriverDelegate: nil
)
```

Necesita un objeto delegado retenido (mismo patrón que `updaterController`
ya es `private let` retenido por la struct `App`) que implemente
`allowedChannelsForUpdater:`, leyendo un `@AppStorage` booleano.

### `SettingsView.swift`/`SettingsViewModel.swift` — sin sección de Sparkle hoy

`SettingsViewModel` ya usa `@AppStorage` para `pythonPath`/`scriptPath`
(líneas 63-75) — mismo mecanismo a replicar para el opt-in de canal beta,
sin necesidad de un `ObservableObject` nuevo si se implementa como
`@AppStorage` directamente en una vista o en `SettingsViewModel`.
`SettingsView` no tiene hoy ninguna sección relacionada con
actualizaciones/Sparkle — sección nueva "Actualizaciones" en el `Form`,
independiente de la sección "Configuración avanzada" ya existente (esta
última es específica de rutas Python, no de Sparkle).

## Standard Stack

- **`SPUUpdaterDelegate.allowedChannelsForUpdater:`** (verificado en
  `.build-cache/Sparkle/Sparkle/SPUUpdaterDelegate.h:113`, doc en líneas
  95-113) — único mecanismo soportado por Sparkle 2 para canales, sin
  alternativa a evaluar.
- **`generate_appcast --channel <nombre>`** (verificado en
  `.build-cache/Sparkle/generate_appcast/main.swift:141-142`) — mecanismo
  CLI ya presente en las herramientas que el pipeline ya descarga
  (`_ensure_sparkle_tools`), sin dependencia nueva.

## Package Legitimacy Audit

No aplica — no se añade ninguna dependencia nueva, solo se usa superficie
ya presente de Sparkle 2 (ya auditado en la Fase 12).

## Architecture Patterns

### `scripts/release-macos.sh` — channel opcional

```bash
VERSION="${1:?Uso: scripts/release-macos.sh <version, ej. 1.1> [canal, ej. beta]}"
CHANNEL="${2:-}"   # vacío = canal por defecto (estable), "beta" = canal beta
```

En `_archive_and_generate_appcast()`:

```bash
_archive_and_generate_appcast() {
    local zip_path="${CACHE_DIR}/${SCHEME}-${VERSION}.zip"
    local zip_name="${SCHEME}-${VERSION}.zip"
    mkdir -p "${ARCHIVE_DIR}"
    cp "${zip_path}" "${ARCHIVE_DIR}/"

    local channel_args=()
    if [[ -n "${CHANNEL}" ]]; then
        channel_args=(--channel "${CHANNEL}")
        echo "Generando appcast.xml en el canal '${CHANNEL}'…"
    else
        echo "Generando appcast.xml (canal por defecto / estable)…"
    fi

    "${SPARKLE_TOOLS_DIR}/bin/generate_appcast" \
        --download-url-prefix "https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/" \
        "${channel_args[@]}" \
        -o "${ARCHIVE_DIR}/appcast.xml" \
        "${ARCHIVE_DIR}"
    # ... resto sin cambios (fallback sign_update si falta sparkle:edSignature)
}
```

`_publish_release()` — título del GitHub Release refleja el canal:

```bash
_publish_release() {
    local zip_path="${ARCHIVE_DIR}/${SCHEME}-${VERSION}.zip"
    local title="${SCHEME} ${VERSION}"
    [[ -n "${CHANNEL}" ]] && title="${title} (${CHANNEL})"
    echo "Publicando release v${VERSION} en ${GITHUB_REPO}…"
    gh release create "v${VERSION}" "${zip_path}" \
        --repo "${GITHUB_REPO}" \
        --title "${title}" \
        --notes "Release ${VERSION}$([[ -n "${CHANNEL}" ]] && echo " — canal ${CHANNEL}")" \
        $([[ -n "${CHANNEL}" ]] && echo "--prerelease")
}
```

`--prerelease` en `gh release create` marca el Release como pre-release en
la UI de GitHub (cosmético, no afecta a Sparkle en absoluto — Sparkle solo
lee `appcast.xml`, no el flag de GitHub) — útil para que un humano
navegando releases a mano vea de inmediato cuáles son beta.

### `ExtractorAppApp.swift` — delegado de canal

```swift
final class ExtractorUpdaterDelegate: NSObject, SPUUpdaterDelegate {
    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        UserDefaults.standard.bool(forKey: "betaChannelOptIn") ? ["beta"] : []
    }
}

@main
struct ExtractorAppApp: App {
    private let updaterDelegate = ExtractorUpdaterDelegate()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: updaterDelegate,
            userDriverDelegate: nil
        )
    }
    // ... resto sin cambios
}
```

**Nota de confianza MEDIA sobre el nombre exacto en Swift**: el header
Objective-C declara `- (NSSet<NSString *> *)allowedChannelsForUpdater:
(SPUUpdater *)updater;`. El nombre Swift más probable, siguiendo la regla
estándar del Clang importer para el patrón `<verbo><Sustantivo>For
<Sustantivo2>:`, es `func allowedChannels(for updater: SPUUpdater) ->
Set<String>` — no se ha podido confirmar contra un `.swiftinterface`
generado (no presente en este sandbox, sin Xcode). Verificar con
autocompletado de Xcode en el checkpoint humano; si el nombre difiere,
es un ajuste de una línea.

### `SettingsView.swift` — toggle de opt-in

```swift
// SettingsViewModel o @AppStorage directo en la vista:
@AppStorage("betaChannelOptIn") var betaChannelOptIn: Bool = false
```

Nueva `Section` en el `Form` de `SettingsView`, en paralelo a la de "Modo
de operación":

```swift
Section {
    Toggle("Recibir actualizaciones beta", isOn: $vm.betaChannelOptIn)
    Text("Las versiones beta pueden ser menos estables. Puedes desactivar esto en cualquier momento.")
        .font(.caption2)
        .foregroundStyle(.tertiary)
} header: {
    Label("Actualizaciones", systemImage: "arrow.down.circle")
        .font(.headline)
}
```

## Don't Hand-Roll

- **No implementar filtrado de canal a mano en la app** (comparar
  `sparkle:channel` del XML manualmente) — `allowedChannelsForUpdater:` ya
  es el mecanismo nativo soportado por Sparkle 2, filtra en el propio
  framework antes de que la app vea nada.
- **No separar `appcast.xml` en dos archivos** (uno por canal) — el mismo
  archivo con items mixtos (con y sin `<sparkle:channel>`) es el patrón
  soportado nativamente y ya lo que produce `generate_appcast` con
  `--channel`; un segundo archivo duplicaría infraestructura sin necesidad.
- **No reimplementar el pipeline de release para beta** — mismo script,
  mismo flujo de firma/notarización/publicación; el canal es un parámetro
  más, no una rama de código nueva.

## Common Pitfalls

### Pitfall 1: Reutilizar el mismo `MARKETING_VERSION` para beta y estable

`generate_appcast` identifica items existentes por versión
(`sparkle:version`/`CFBundleVersion`, ver `FeedXML.swift:333-336`) — si se
publica `1.1` como beta y más tarde se publica `1.1` "de verdad" como
estable, la segunda ejecución encontrará el item ya existente
(`createNewItem = false`) y **no** le aplicará ningún canal nuevo, dejando
el item con el canal `beta` de la primera publicación — el release
"estable" quedaría invisible para usuarios no-beta. `CURRENT_PROJECT_VERSION`
(el build number real que compara Sparkle) siempre sube automáticamente
vía `_bump_version` así que en la práctica nunca colisiona, pero se
recomienda igualmente una convención de `MARKETING_VERSION` distinta para
betas (p.ej. `1.1-beta.1`) — documentar en `RELEASING.md`, no forzar en
código (el usuario decide sus números de versión).

### Pitfall 2: Título/tag de GitHub Release beta vs. estable

Publicar dos releases con el mismo `MARKETING_VERSION` (uno beta, otro
luego estable) haría que `gh release create "v${VERSION}"` falle en el
preflight existente (`gh release view "v${VERSION}"` ya detecta el tag
duplicado) — de nuevo, la mitigación es una convención de versión, no un
cambio de código; el preflight existente ya protege contra la colisión
silenciosa (falla explícito, no sobrescribe).

### Pitfall 3: El toggle de opt-in no fuerza una comprobación inmediata

Activar "Recibir actualizaciones beta" no dispara una comprobación de
Sparkle al momento — `allowedChannelsForUpdater:` se consulta la próxima
vez que Sparkle compruebe (automático en 24h, o al pulsar "Buscar
actualizaciones…" manualmente). Esto es el comportamiento esperado y
correcto, no un bug — no hace falta lógica adicional para "refrescar" tras
tocar el toggle.

## Estrategia de Verificación

Como en las Fases 12/13/14-02: parte del cambio es Swift (checkpoint
humano en Xcode obligatorio — `allowedChannelsForUpdater` no se puede
compilar/verificar en este sandbox) y parte es un script bash
(`scripts/release-macos.sh`, verificable con un dry-run local que no
publique de verdad, o inspección manual del diff del comando
`generate_appcast` generado). No hay tests automatizados existentes para
`scripts/release-macos.sh` (es un script de release ejecutado manualmente,
no cubierto por `pytest tests/`) — la verificación real de "un item beta
solo lo ve un updater opt-in" requiere dos builds reales de la app (una
con el toggle activo, otra sin) contra un `appcast.xml` de prueba con un
item marcado `beta`, mismo patrón de verificación humana ya usado en la
Fase 13.

## Security Domain

- Sin superficie nueva de credenciales — reutiliza exactamente las mismas
  claves/perfiles ya auditados en la Fase 13 (EdDSA, notarización, `gh
  auth`).
- Un usuario que activa el opt-in beta explícitamente asume el riesgo de
  builds menos probadas — mismo modelo de confianza que cualquier canal
  beta de cualquier software, sin mitigación adicional necesaria más allá
  de que sea opt-in y reversible en cualquier momento (Pitfall 3).

## Assumptions Log

- Se asume que el nombre Swift exacto de `allowedChannelsForUpdater:` es
  `allowedChannels(for updater: SPUUpdater) -> Set<String>` — confianza
  MEDIA, verificar con autocompletado de Xcode (ver nota en Architecture
  Patterns).
- Se asume que un segundo argumento posicional (`CHANNEL="${2:-}"`) en
  `release-macos.sh` es preferible a una variable de entorno — más
  descubrible (`scripts/release-macos.sh 1.1 beta` se lee solo) que
  `CHANNEL=beta scripts/release-macos.sh 1.1`, aunque el script ya usa el
  patrón de env var para otras opciones (`NOTARY_PROFILE`); se prioriza
  legibilidad del comando más común (publicar un beta) sobre consistencia
  interna con opciones de configuración menos frecuentes.
- Se asume que la convención de versión beta (`1.1-beta.1`) es
  responsabilidad del usuario al invocar el script, no algo que el código
  deba validar/forzar — coherente con que `release-macos.sh` nunca ha
  validado el formato de `VERSION` hasta ahora.

## Sources

### Primary (HIGH confidence)

- Lectura directa del código fuente real de Sparkle 2, clonado en este
  repo (`.build-cache/Sparkle/`, dependencia ya presente de la Fase 12/13):
  `Sparkle/SPUUpdaterDelegate.h` (doc completa de `allowedChannelsForUpdater:`,
  líneas 95-113), `generate_appcast/main.swift` (definición de `--channel`,
  líneas 141-142), `generate_appcast/FeedXML.swift` (lógica exacta de
  merge incremental y por qué `--channel` solo afecta a items nuevos,
  líneas 320-405).
- Lectura directa de este repo: `scripts/release-macos.sh`, `RELEASING.md`,
  `appcast.xml`, `ExtractorAppApp.swift`, `SettingsView.swift`/
  `SettingsViewModel.swift`.

### Secondary (MEDIUM confidence)

- Nombre exacto del método Swift bridged de `allowedChannelsForUpdater:`
  (ver Assumptions Log) — inferido de la regla estándar del Clang importer,
  no confirmado contra un `.swiftinterface` real (sin Xcode en este
  sandbox).

## Metadata

- Requirements cubiertos: CHANNEL-01, CHANNEL-02
- Depends on: Phase 13 (pipeline de release y publicación ya existente)
- Bloquea: 16-01-PLAN.md (implementación) + checkpoint humano en Xcode
