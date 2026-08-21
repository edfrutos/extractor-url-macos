---
phase: 16-canales-sparkle
type: checkpoint-humano
status: pending
created: "2026-08-21"
---

# Checkpoint Humano — Fase 16 (Canales beta de Sparkle)

## Objetivo

Compilar y verificar el opt-in de canal beta: nuevo `SPUUpdaterDelegate`
en `ExtractorAppApp.swift`, toggle en Preferencias, y confirmar que el
nombre Swift exacto de `allowedChannelsForUpdater:` es el que se ha usado
aquí (`allowedChannels(for:)` — ver nota de confianza media en
`16-RESEARCH.md`).

## Estado de partida

- `ExtractorAppApp.swift`: nueva clase `ExtractorUpdaterDelegate: NSObject,
  SPUUpdaterDelegate` con `func allowedChannels(for updater: SPUUpdater) ->
  Set<String>`, retenida como `private let updaterDelegate` y pasada a
  `SPUStandardUpdaterController`.
- `SettingsViewModel.swift`: `@AppStorage("betaChannelOptIn") var
  betaChannelOptIn: Bool = false`.
- `SettingsView.swift`: nueva sección "Actualizaciones" con el toggle.
- `scripts/release-macos.sh`/`RELEASING.md`: canal opcional como 2º
  argumento — verificado con `shellcheck` y simulación de ambas ramas en
  este sandbox, sin checkpoint humano necesario para esa parte (es bash,
  no Swift).
- Nada de esto está commiteado todavía.

## Paso 1 — Build

1. Abre `ExtractorApp.xcodeproj` en Xcode.
2. `Product → Clean Build Folder` (⇧⌘K), luego `Product → Build` (⌘B).

**Resultado esperado:** `Build Succeeded`.

**Si falla en `allowedChannels(for:)` con un error de "does not conform to
protocol SPUUpdaterDelegate" o similar:** copia el error exacto — es muy
probable que sea solo un desajuste de nombre (`allowedChannelsForUpdater`
en vez de `allowedChannels(for:)`, o un tipo de retorno ligeramente
distinto). Xcode suele ofrecer un botón "Fix" con el nombre correcto vía
autocompletado/Fix-it; acepta esa corrección y recompila. Pégame el nombre
final que Xcode aceptó para que lo deje anotado en el summary.

## Paso 2 — Verificar el toggle

1. Con la app corriendo (⌘R), abre Preferencias (⌘,).
2. Busca la sección "Actualizaciones" con el toggle "Recibir
   actualizaciones beta" — debería estar **desactivado** por defecto.
3. Actívalo, cierra Preferencias, y vuelve a abrirla.

**Repórtame:** ¿el toggle sigue activado tras cerrar y reabrir Preferencias
(persistencia en `UserDefaults` confirmada)?

## Paso 3 — Verificar el delegado (opcional, sin publicar nada real)

Este paso es opcional — no requiere publicar un release beta de verdad.
Si quieres verificarlo con confianza alta, puedes:

1. Con el toggle **desactivado**, pulsar "Buscar actualizaciones…" — debe
   comportarse exactamente igual que antes de esta fase (compara contra
   `appcast.xml` del canal estable, sin cambios).
2. No hace falta un release beta real para cerrar esta fase — la lógica
   de `allowedChannels(for:)` es trivial (lee un booleano) y su
   corrección ya está garantizada por el tipo (`Set<String>` vacío vs.
   `["beta"]`). La verificación de que Sparkle respeta esto de verdad ya
   está cubierta por el propio framework (Fase 12/13), no por este plan.

## Paso 4 — Cierre (lo hago yo, no tú)

Cuando confirmes Build Succeeded + toggle persistente, yo:

1. Escribo `16-01-SUMMARY.md` con los resultados reales.
2. Marco la Fase 16 completa (CHANNEL-01, CHANNEL-02 validados) en
   ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md.
3. Te pregunto si quieres commitear/pushear, y si seguimos con la Fase 17
   (Playwright/Chromium embebido — fase grande, ver aviso de alcance en
   ROADMAP.md).

## Plan de contingencia

- **`allowedChannels(for:)` no compila** → ver Paso 1, probablemente solo
  un ajuste de nombre vía Fix-it de Xcode.
- **El toggle no aparece en Preferencias** → revisa que la sección
  "Actualizaciones" esté en el `Form` de `SettingsView.swift`, podría ser
  un problema de layout — pégame una captura si es más fácil que
  describirlo.
- **El toggle no persiste tras reabrir Preferencias** → revisa que
  `@AppStorage("betaChannelOptIn")` esté bien escrito (mismo string key
  usado en `ExtractorUpdaterDelegate` y en `SettingsViewModel`) — un typo
  en la key haría que cada uno lea un valor distinto de `UserDefaults`.
