---
plan: 12-01
phase: 12-sparkle-integracion
status: complete
completed: "2026-08-20"
tasks_completed: 3
tasks_total: 3
requirements_covered:
  - UPDATE-01
  - UPDATE-02
  - UPDATE-03
---

# Summary: 12-01 — Integración Sparkle en la app

## What Was Built

Sparkle 2 integrado en ExtractorApp: la app inicializa el updater al
arrancar, comprueba actualizaciones automáticamente en segundo plano
(comportamiento por defecto de Sparkle), y expone un ítem de menú manual
"Buscar actualizaciones…".

### ExtractorAppApp.swift

- `private let updaterController: SPUStandardUpdaterController`, inicializado
  en `init()` con `startingUpdater: true`.
- `.commands { CommandGroup(after: .appInfo) { CheckForUpdatesView(...) } }`
  adjuntado al `WindowGroup`.

### Views/CheckForUpdatesView.swift (nuevo)

Patrón oficial de Sparkle para SwiftUI (dos capas: `CheckForUpdatesViewModel`
+ `CheckForUpdatesView`), citado casi literal de la documentación oficial.

### project.pbxproj

- `INFOPLIST_KEY_SUFeedURL` = `https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml`
- `INFOPLIST_KEY_SUPublicEDKey` = `"PENDIENTE-FASE-13-generate_keys"` (placeholder explícito)
- En ambas configuraciones (Debug/Release) del target ExtractorApp.
- Referencia local del paquete Sparkle: `XCLocalSwiftPackageReference "../../.build-cache/Sparkle"`.

## Bug encontrado y corregido durante el checkpoint

`CheckForUpdatesView.swift` no compilaba: `Type 'CheckForUpdatesViewModel'
does not conform to protocol 'ObservableObject'` + `Initializer
'init(wrappedValue:)' is not available due to missing import of defining
module 'Combine'`. Aunque `import SwiftUI` normalmente re-exporta lo
necesario de Combine, en este proyecto hizo falta `import Combine` explícito
para que `@Published` y `ObservableObject` resolvieran. Corregido añadiendo
`import Combine` al principio del archivo.

## Desviación del plan: paquete SPM añadido como LOCAL, no remoto

El plan original (`12-01-PLAN.md`, Task 0) preveía añadir Sparkle vía
`File → Add Package Dependencies…` con la URL remota de GitHub. En la
práctica, el buscador de paquetes de Xcode 26.6 devolvía **0 resultados
para cualquier URL** (se probó también con `apple/swift-argument-parser`,
un paquete trivialmente conocido) — un fallo aparentemente interno de Xcode
26.6, no de red: se descartaron uno por uno git CLI (`git ls-remote`
funciona), `curl` a `github.com` e `api.github.com` (IPv4 e IPv6, ambos
200 OK), firewalls/EDR conocidos, cuenta Apple ID en Xcode, y versión de
Command Line Tools (consistente, apunta a Xcode.app completo).

**Workaround aplicado**: se clonó Sparkle con
`git clone --depth 1 https://github.com/sparkle-project/Sparkle .build-cache/Sparkle`
(`.build-cache/` ya estaba en `.gitignore`, mismo patrón que
`scripts/bundle-python.sh`) y se añadió como paquete **local** vía el botón
"Add Local..." del mismo diálogo, que sí funcionó sin pasar por el buscador
roto.

**Trade-off a tener en cuenta**: una referencia de paquete local
(`XCLocalSwiftPackageReference`) guarda una ruta relativa/absoluta
específica de esta máquina, no una versión resuelta por SPM remoto — no se
actualizará sola a nuevas versiones de Sparkle, y si el repo se clona en
otra máquina sin `.build-cache/Sparkle` presente, el proyecto no resolverá
el paquete hasta que se repita el `git clone` local ahí. Revisar en el
futuro (cuando se entienda o se arregle el bug de búsqueda de Xcode 26.6)
si conviene migrar a una referencia remota real vía
`XCRemoteSwiftPackageReference` con versión pinneada.

## Verification Status — ✅ VERIFICADO (checkpoint humano 2026-08-20)

```
Build Succeeded (Xcode 26.6, macOS)
```

- 11 warnings preexistentes en `PythonBridge.swift`/`ExtractionViewModel.swift`/`SettingsViewModel.swift`
  (avisos de concurrencia Swift 6, `self` capturado en código concurrente) —
  **no introducidos por esta fase**, quedan fuera de su alcance.
- App arranca correctamente. "Buscar actualizaciones…" aparece en el menú
  de la app, justo tras "Acerca de ExtractorApp", **deshabilitado** — esperado
  sin un appcast/clave EdDSA reales todavía.
- Log de Console/Xcode al arrancar: `"Serving updates without an EdDSA key
  and only using Apple Code Signing is deprecated..."` — confirma que
  Sparkle está cargado y funcionando, y que detecta correctamente el
  placeholder de `SUPublicEDKey` como no válido (comportamiento previsto,
  no un bug). El resto de mensajes del log
  (`com.apple.linkd.autoShortcut`, Intents framework, Process Instance
  Registry, task name port) son ruido estándar de macOS al lanzar
  cualquier app desde el depurador de Xcode — sin relación con Sparkle ni
  con el código de esta fase.

## Self-Check

- [x] `SPUStandardUpdaterController` inicializado en `ExtractorAppApp.swift`
- [x] `CheckForUpdatesView` con el patrón oficial de dos capas
- [x] `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey` en Debug y Release
- [x] `xcodebuild build` — Build Succeeded (checkpoint humano 2026-08-20)
- [x] Verificación visual: ítem de menú presente, comportamiento de log esperado
- [ ] Actualización real vía Sparkle — pendiente Fase 13 (claves reales, appcast, notarización)
