---
phase: 12-sparkle-integracion
type: research
status: complete
created: "2026-08-19"
---

# Phase 12: Integración Sparkle en la app — Research

## User Constraints (from conversación de definición del milestone v5.0)

### Locked Decisions

- Framework: **Sparkle 2.x** (único candidato serio para auto-update en macOS fuera del App Store).
- Hosting del feed: **GitHub Releases** — `appcast.xml` committeado en el repo, servido vía `raw.githubusercontent.com`; binarios (`.dmg`/`.zip`) como assets de GitHub Release. Sin infraestructura nueva.
- Comprobación de actualizaciones: **automática en segundo plano (comportamiento por defecto de Sparkle, cada 24h) + manual** desde un ítem de menú "Buscar actualizaciones...".
- El usuario **tiene cuenta Apple Developer Program de pago** — notarización y firma Developer ID son viables.
- Existe (por decisión ya tomada) un script `scripts/release-macos.sh` que automatiza build→firma→notarización→appcast→publicación (cubierto en Fase 13, no en esta fase).

### Claude's Discretion

- Punto exacto de inicialización de `SPUStandardUpdaterController` en el entry point SwiftUI de la app.
- Si añadir o no un toggle en Preferencias para desactivar la comprobación automática (Sparkle ya expone esto vía `SUEnableAutomaticChecks` + UI estándar, así que probablemente no hace falta UI propia).
- Cómo estructurar el `CheckForUpdatesView` para que encaje con el estilo visual ya existente en `SettingsView`/`ContentView`.

### Deferred Ideas (OUT OF SCOPE — v5.0)

- Canales beta/nightly (Sparkle 2 soporta `channels`, pero no hay pedido de build beta separada).
- Rollouts por fases (`sparkle:phasedRolloutInterval`) — innecesario para una app de uso personal con pocos usuarios.
- Delta updates — Sparkle los genera automáticamente vía `generate_appcast` sin trabajo adicional, así que llegan "gratis", pero no es un requisito explícito a verificar.

## Summary

Sparkle 2 se integra sin tocar la arquitectura existente: es un framework SPM que se añade al proyecto Xcode, se inicializa una vez en el punto de entrada de la app (`@main struct ... App`), y expone un botón "Buscar actualizaciones..." vía un componente SwiftUI ya documentado oficialmente (`SPUStandardUpdaterController` + `SPUUpdater` + un `ObservableObject` que publica `canCheckForUpdates`). No requiere cambios en `PythonBridge`, `ContentView` ni el flujo de extracción — es ortogonal al resto de la app.

Como la app tiene **App Sandbox OFF** (decisión de Fase 7, v2.0), la [guía de sandboxing de Sparkle](https://sparkle-project.org/documentation/sandboxing) no aplica — evita una capa entera de complejidad (XPC entitlements, etc.) que sí sería necesaria si el sandbox estuviera activo.

La firma actual del proyecto es `CODE_SIGN_STYLE = Automatic` sin `DEVELOPMENT_TEAM` fijado en el `.pbxproj` (se configura localmente en Xcode). Para que Sparkle + notarización funcionen sin fricción, la distribución debe hacerse vía `Product → Archive → Distribute App → Developer ID` (o el equivalente `xcodebuild archive`/`-exportArchive` para el script de Fase 13) — esto lo cubre la Fase 13, pero condiciona cómo se prueba esta fase: **el "Check for Updates" solo tiene sentido probarlo de verdad contra un build Developer ID + notarizado real**, no contra un build de desarrollo firmado ad-hoc.

## Análisis del Estado Actual del Código

### Entry point SwiftUI — dónde inicializar el updater

Necesita confirmarse el archivo exacto (`ExtractorAppApp.swift` o similar, con `@main struct ExtractorAppApp: App`). El patrón oficial (ver "Architecture Patterns" abajo) inicializa `SPUStandardUpdaterController` como `private let` en el `init()` de la struct `App`, y añade el botón vía `.commands { CommandGroup(after: .appInfo) { ... } }` — esto coloca el ítem de menú junto a "Acerca de ExtractorApp", en la posición estándar de macOS para "Buscar actualizaciones...".

### `SettingsView` / `SettingsViewModel` — sin modificación necesaria

Sparkle gestiona su propio estado (última comprobación, frecuencia, etc.) internamente vía `NSUserDefaults` con claves propias (`SUEnableAutomaticChecks`, `SULastCheckTime`) — no comparte namespace con `pythonPath`/`scriptPath` de `SettingsViewModel`. No hace falta tocar el `@MainActor final class SettingsViewModel` existente.

### `project.pbxproj` — estado de firma actual

`CODE_SIGN_STYLE = Automatic`, `PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.ExtractorApp`, `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1`. Sparkle usa `CFBundleVersion` (`CURRENT_PROJECT_VERSION`) para comparar versiones — **debe incrementarse en cada release** (Fase 13 se encarga de esto en el script, no aquí).

## Standard Stack

- **Sparkle 2.x** vía Swift Package Manager — `File → Add Packages…` con URL `https://github.com/sparkle-project/Sparkle`. Xcode gestiona actualizaciones de versión automáticamente con las opciones por defecto.
- Requisito de runtime: **macOS 12.0+** en la rama `2.x` de Sparkle (macOS 10.13+ solo en la rama de mantenimiento `2.9.3`). El deployment target de este proyecto es **macOS 13.0+** (Fase 7) — compatible sin ajustes.
- Las herramientas CLI de Sparkle (`generate_keys`, `sign_update`, `generate_appcast`) se instalan junto con el paquete SPM en `<DerivedData>/.../artifacts/sparkle/Sparkle/bin/` — no hace falta descargarlas aparte (aunque Fase 13 también puede usar una copia fija en `scripts/vendor/sparkle-tools/` si conviene reproducibilidad del script de release; a decidir en Fase 13).

## Package Legitimacy Audit

`sparkle-project/Sparkle` — proyecto open source de referencia para auto-update en macOS desde 2006, ampliamente usado (Xcode mismo lo lista como ejemplo de referencia en su documentación de distribución), mantenido activamente (rama `2.x` con actividad continua). Sin alternativas serias fuera de WinSparkle/NetSparkle (otras plataformas) — no hay señales de alerta ni necesidad de auditoría adicional.

## Architecture Patterns

### Patrón oficial recomendado — SwiftUI (fuente: documentación oficial de Sparkle, "Setting up Sparkle programmatically")

```swift
import SwiftUI
import Sparkle

// Publica cuándo el usuario puede pulsar "Buscar actualizaciones..."
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

// Vista del ítem de menú — la vista intermedia es necesaria para que el
// estado disabled del NSMenuItem funcione correctamente antes de Monterey.
struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        Button("Buscar actualizaciones…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}

@main
struct ExtractorAppApp: App {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil
        )
    }

    var body: some Scene {
        WindowGroup { ContentView() }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
        Settings { SettingsView() }   // si ya existe una Scene de Preferencias
    }
}
```

Este patrón es literalmente el ejemplo oficial — no hay margen de interpretación aquí, solo adaptarlo al nombre real del entry point y a si `Settings { }` ya existe como `Scene` separada o si Preferencias se abre por otra vía (`NSApp.sendAction` / `openWindow`, como sugiere el patrón `⌘,` ya usado en fases anteriores — confirmar en la lectura del archivo real durante el plan de ejecución).

### Info.plist — claves requeridas

**Hallazgo específico de este proyecto**: no existe un archivo `Info.plist` físico —
`GENERATE_INFOPLIST_FILE = YES` en `project.pbxproj`, con claves custom ya
inyectadas vía `INFOPLIST_KEY_*` en Build Settings (ver
`INFOPLIST_KEY_NSHumanReadableCopyright` como precedente exacto en las 4
configuraciones del target `ExtractorApp`, líneas 380/419 del `.pbxproj`).
Las claves de Sparkle deben añadirse de la misma forma, **no** como un
`.plist` editado a mano:

```
INFOPLIST_KEY_SUFeedURL = "https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml";
INFOPLIST_KEY_SUPublicEDKey = "{{clave pública generada por generate_keys en Fase 13}}";
```

Equivalente conceptual a lo que la documentación oficial describe como
"añadir `SUFeedURL`/`SUPublicEDKey` al Info.plist" — mismo efecto en runtime,
distinto mecanismo de Xcode. `SUPublicEDKey` quedará con un valor placeholder
hasta que la Fase 13 genere la clave real; el plan de esta fase debe dejarlo
señalado explícitamente (comentario o valor vacío), no inventar una clave.

`SUEnableAutomaticChecks` no hace falta declararlo explícitamente — Sparkle lo activa por defecto (comprobación en segundo plano cada 24h) salvo que el usuario lo desactive desde la UI estándar de Sparkle (que aparece automáticamente en la ventana de "Buscar actualizaciones..." la primera vez, preguntando permiso — comportamiento nativo, no hay que construir esa UI).

### Estructura de archivos afectados

- `ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj` — añadir dependencia SPM Sparkle.
- Entry point de la app (`@main struct ... App` — confirmar nombre exacto de archivo al ejecutar el plan) — inicializar `SPUStandardUpdaterController`, añadir `CheckForUpdatesView` al `.commands`.
- `Info.plist` (o las claves equivalentes en Build Settings si el proyecto las gestiona ahí — confirmar) — `SUFeedURL`, `SUPublicEDKey`.
- Nuevo archivo `CheckForUpdatesView.swift` (o añadido al mismo archivo del entry point, si es pequeño — a decidir en el plan según convención del proyecto).

## Don't Hand-Roll

- **No implementar comprobación de versión manual** (comparar `CFBundleVersion` contra un JSON propio, descargar y reemplazar el `.app` a mano) — exactamente el problema que Sparkle resuelve de forma segura (firma EdDSA, verificación de código, manejo de permisos/relanzamiento). Reimplementarlo sería reintroducir todos los problemas de seguridad que Sparkle ya resolvió (ver `Documentation/Security.md` del propio proyecto Sparkle).
- **No construir una UI de progreso/diálogo propia** para el proceso de actualización — `SPUStandardUserDriver` (usado internamente por `SPUStandardUpdaterController`) ya provee la ventana estándar de macOS para esto. Una UI custom (`SPUUserDriver` propio) es una opción documentada de Sparkle pero fuera de scope — no hay pedido de un diseño de update visualmente distinto al estándar del sistema.

## Common Pitfalls

### Pitfall 1: Library Validation bloquea Sparkle en firma ad-hoc de desarrollo

Con Hardened Runtime + Library Validation activos (ya el caso de este proyecto desde Fase 7), si el build de **desarrollo** se firma ad-hoc (sin certificado), macOS puede impedir que la app cargue `Sparkle.framework`. La documentación oficial recomienda firmar con un certificado `Apple Development` (requiere estar en el programa de desarrolladores — ya cumplido) para builds de desarrollo, o desactivar Library Validation solo en la configuración Debug. Para Release/Developer ID esto no es un problema.

### Pitfall 2: "Check for Updates..." solo prueba algo real contra un build Developer ID + notarizado

Un build de desarrollo (firma automática/ad-hoc) puede compilar y mostrar el menú, pero el flujo real de descarga+instalación de Sparkle depende de comprobaciones de firma de código que solo se comportan de forma representativa con un build firmado Developer ID. La verificación completa de esta fase (más allá de "compila y el menú aparece") requiere el pipeline de Fase 13.

### Pitfall 3: `CFBundleVersion` debe ser numérico-creciente y distinto en cada build de prueba

Si se prueba el flujo de update dos veces seguidas sin cambiar `CURRENT_PROJECT_VERSION`, Sparkle no detectará una versión nueva (comportamiento correcto, no un bug). Al probar manualmente, hay que bajar temporalmente el `CFBundleVersion` del build instalado o subir el del appcast de prueba — documentado ya en la guía oficial ("Test Sparkle out").

### Pitfall 4: El ítem de menú puede no reflejar el estado disabled correctamente en macOS < Monterey

La documentación oficial señala explícitamente que la vista intermedia (`CheckForUpdatesView` con su propio `ObservedObject`) es necesaria "para que el estado disabled del ítem de menú funcione correctamente antes de Monterey" — no simplificar a un `Button` inline sin el view model, aunque parezca redundante. El deployment target de este proyecto es macOS 13 (Ventura) así que en la práctica no debería manifestarse, pero seguir el patrón oficial tal cual evita divergencias no documentadas.

### Pitfall 5: `raw.githubusercontent.com` cachea — un appcast recién publicado puede tardar en propagarse

GitHub cachea agresivamente el contenido servido vía `raw.githubusercontent.com` (CDN de Fastly, TTL variable, normalmente unos minutos). Al probar un release nuevo, si Sparkle sigue viendo la versión anterior, no es necesariamente un bug — puede ser caché de CDN. Esto es un pitfall de Fase 13 (publicación), pero afecta directamente cómo se verifica esta fase de integración cuando se prueba end-to-end.

## Security Domain

- **Clave privada EdDSA**: vive en el llavero (Keychain) del Mac que ejecuta `generate_keys`/`sign_update` — nunca debe committearse al repo ni exportarse a un archivo dentro del working tree. Cubierto formalmente en Fase 13, pero es una restricción que ya condiciona esta fase: `SUPublicEDKey` (la clave PÚBLICA) sí va en `Info.plist` y sí se commitea — es información no sensible por diseño (firma de verificación, no de creación).
- **Superficie de ataque nueva**: un appcast/feed comprometido podría en teoría dirigir a los usuarios a un binario malicioso, pero la firma EdDSA de cada `<enclosure>` hace que un feed servido por HTTPS (GitHub) sin comprometer también la clave privada no sea explotable — la app rechaza binarios cuya firma no coincida con `SUPublicEDKey`.
- Notarización + firma Developer ID (Fase 13) añaden una segunda capa independiente de verificación (Gatekeeper), redundante mecánicamente con la firma EdDSA de Sparkle pero exigida por el sistema operativo para que el usuario no vea advertencias.

## Assumptions Log

- Se asume que el archivo `@main struct ... App` existe en un único punto de entrada identificable (patrón estándar SwiftUI de macOS 13+) — se confirmará al leer el código real durante la ejecución del plan, no asumido a ciegas en el plan mismo.
- Se asume que no hay ya una dependencia SPM en conflicto ni un `Package.resolved` que requiera merge manual — proyecto pequeño, sin dependencias SPM previas detectadas en esta investigación.
- Se asume `CommandGroup(after: .appInfo)` como la posición de menú correcta (patrón oficial) — no se ha pedido una posición distinta.

## Open Questions (RESOLVED)

- **¿Toggle propio en Preferencias para desactivar auto-check?** → No necesario: Sparkle ya expone su propia UI nativa para esto la primera vez que se ejecuta un check, y persiste la preferencia del usuario vía `SUEnableAutomaticChecks` en `UserDefaults` sin que la app tenga que construir nada.
- **¿Sandboxing?** → No aplica, App Sandbox está OFF desde Fase 7 — se evita toda la complejidad de XPC entitlements de la guía de sandboxing de Sparkle.
- **¿Canales beta?** → Fuera de scope de v5.0, ver Deferred Ideas arriba.

## Sources

### Primary (HIGH confidence)

- `https://github.com/sparkle-project/sparkle-project.github.io/blob/master/documentation/programmatic-setup/index.md` — ejemplo oficial SwiftUI completo (código citado casi literal arriba).
- `https://github.com/sparkle-project/sparkle-project.github.io/blob/master/documentation/index.md` — guía "Basic Setup" oficial (SPM, Info.plist, Library Validation, distribución Developer ID).
- `https://github.com/sparkle-project/Sparkle` — README del repo principal (requisitos de runtime macOS 12+/2.x, herramientas `generate_appcast`/`sign_update`).
- Lectura directa de este repo: `ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj` (CODE_SIGN_STYLE, MARKETING_VERSION, CURRENT_PROJECT_VERSION), `SettingsViewModel.swift`, `scripts/bundle-python.sh` (convenciones de estilo).

### Secondary (MEDIUM confidence)

- `https://github.com/steipete/CodexBar/blob/main/docs/RELEASING.md` — ejemplo real de un proyecto macOS Developer-ID + Sparkle + GitHub Releases en producción; usado para contrastar pitfalls de notarización/firma, más relevante para Fase 13 que para esta fase, pero confirma que el patrón "appcast en raw.githubusercontent.com + enclosures en GitHub Release" es viable y usado en la práctica.

### Tertiary

- Búsqueda web general sobre integraciones Sparkle + GitHub Releases (varios artículos de blog) — usada solo para confirmar que el patrón de hosting es común, no como fuente de código.

## Metadata

- Requirements cubiertos: UPDATE-01, UPDATE-02, UPDATE-03
- Depends on: nada nuevo — extiende la app SwiftUI existente (v2.0/v3.0), sin tocar `core.py`/motor Python
- Bloquea: 12-01-PLAN.md (implementación); Fase 13 (pipeline de release) depende de que `SUFeedURL`/`SUPublicEDKey` ya existan en `Info.plist`
