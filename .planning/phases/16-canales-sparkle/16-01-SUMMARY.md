---
plan: 16-01
phase: 16-canales-sparkle
status: complete
completed: "2026-08-21"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - CHANNEL-01
  - CHANNEL-02
---

# Summary: 16-01 — Canales beta de Sparkle

## What Was Built

### scripts/release-macos.sh / RELEASING.md

- `CHANNEL="${2:-}"` — canal opcional como 2º argumento posicional,
  `Uso: scripts/release-macos.sh <version> [canal]`.
- `_archive_and_generate_appcast()`: `channel_args=()` relleno con
  `(--channel "${CHANNEL}")` solo si `CHANNEL` no está vacío; sin canal,
  `generate_appcast` se invoca exactamente igual que antes de esta fase.
- `_publish_release()`: con `CHANNEL` no vacío, añade `--prerelease` a
  `gh release create` y refleja el canal en `--title`/`--notes`.
- `RELEASING.md` — nueva sección "3. Publicar un canal beta (opcional)"
  documentando el uso y el pitfall de versionado (usar un
  `MARKETING_VERSION` distinto para beta, ej. `1.1-beta.1`, para no
  colisionar con la versión estable "de verdad" más adelante).

### ExtractorAppApp.swift / SettingsViewModel.swift / SettingsView.swift

- `final class ExtractorUpdaterDelegate: NSObject, SPUUpdaterDelegate`
  con `func allowedChannels(for updater: SPUUpdater) -> Set<String>`,
  leyendo `UserDefaults.standard.bool(forKey: "betaChannelOptIn")` —
  `["beta"]` si el toggle está activo, `[]` si no. Retenida como
  `private let updaterDelegate` y pasada a
  `SPUStandardUpdaterController(updaterDelegate:)`.
- `SettingsViewModel`: `@AppStorage("betaChannelOptIn") var
  betaChannelOptIn: Bool = false`, mismo patrón que
  `pythonPath`/`scriptPath`.
- `SettingsView`: nueva sección "Actualizaciones" con
  `Toggle("Recibir actualizaciones beta", isOn: $vm.betaChannelOptIn)`.

### scripts/setup-sparkle-local.sh (utilidad añadida durante el checkpoint)

Script auxiliar no contemplado en el plan original, añadido para
mitigar el bug ya documentado (12-01-SUMMARY.md) del buscador de
paquetes SPM de Xcode 26.6 en esta máquina: descarga el
`Sparkle-for-Swift-Package-Manager.zip` de la versión pinneada
(`2.9.6`), verifica su checksum SHA-256, y parchea el `Package.swift`
local de `.build-cache/Sparkle` para referenciar el `.xcframework` por
path en vez de por URL remota. Idempotente. `shellcheck` limpio.

## Verification Status — ✅ VERIFICADO (checkpoint humano)

Checkpoint humano en Xcode real (no ejecutable en el sandbox, la parte
Swift):

- **Build**: `Build Succeeded` sin necesitar Fix-it — el nombre
  `allowedChannels(for:)` usado en la implementación fue aceptado tal
  cual por el compilador (queda resuelta la nota de confianza media del
  research; no hizo falta `allowedChannelsForUpdater`).
- **Persistencia del toggle**: confirmado — "Recibir actualizaciones
  beta" activado en Preferencias sigue activado tras cerrar y reabrir
  la ventana (`@AppStorage("betaChannelOptIn")` funcionando).
- **Paso 3 (delegado con toggle desactivado)**: no ejecutado
  explícitamente — opcional según el propio checkpoint, cubierto por
  tipo (`Set<String>` vacío por defecto) y por el framework Sparkle ya
  verificado en Fases 12/13.
- Ruido de consola observado (`com.apple.linkd.autoShortcut`,
  `NSCocoaErrorDomain Code=4097`) — no relacionado con Sparkle ni con
  este cambio; es un fallo conocido de registro del framework Intents/
  Shortcuts del sistema en sesiones de Xcode, ajeno al código del
  proyecto. Ignorado.

Verificación local en el sandbox (parte bash, no Swift):
`shellcheck scripts/release-macos.sh` sin errores nuevos;
`shellcheck scripts/setup-sparkle-local.sh` sin errores.

## Self-Check

- [x] Sin segundo argumento, `scripts/release-macos.sh` produce el
      mismo comportamiento que antes de esta fase.
- [x] Con canal `beta`, `generate_appcast` recibe `--channel beta` y
      `gh release create` recibe `--prerelease`.
- [x] `allowedChannels(for:)` compila tal cual, sin ajuste de nombre.
- [x] El toggle de opt-in persiste en `UserDefaults` tras reabrir
      Preferencias.
- [x] `RELEASING.md` documenta el uso y el pitfall de versionado.
- [x] Sin activar el toggle, el comportamiento por defecto no cambia
      (conjunto vacío de canales, mismo que v5.0).
