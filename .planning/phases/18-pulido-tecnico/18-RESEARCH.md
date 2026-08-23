---
phase: 18-pulido-tecnico
type: research
status: complete
created: "2026-08-23"
---

# Research: Fase 18 — Pulido técnico

## POLISH-01: `_bump_version` toca `ExtractorAppTests`

### Causa raíz confirmada

`scripts/release-macos.sh` (`_bump_version()`, antes de esta fase) usaba
`sed -i '' -e "s/MARKETING_VERSION = ...;/.../g" -e "s/CURRENT_PROJECT_VERSION = ...;/.../g"`
sobre el `.pbxproj` **completo**, sin ámbito. El `.pbxproj` real tiene 4
bloques `XCBuildConfiguration` con esas claves — 2 para el target
`ExtractorApp` (Debug/Release) y 2 para `ExtractorAppTests` (Debug/
Release) — y por coincidencia ambos targets comparten los mismos valores
(`CURRENT_PROJECT_VERSION = 6;` / `MARKETING_VERSION = 1.0;` al momento de
esta investigación). El `sed` global los tocaba a los 4 por igual.

Confirmado inspeccionando `ExtractorApp.xcodeproj/project.pbxproj`
directamente (sección `XCBuildConfiguration`, líneas ~395-518): cada
bloque es identificable de forma inequívoca por su
`PRODUCT_BUNDLE_IDENTIFIER` (`com.edefrutos.ExtractorApp;` vs.
`com.edefrutos.ExtractorAppTests;`).

### Fix aplicado

`_bump_version()` reescrita con un script `awk` que:

1. Bufferiza cada bloque `XCBuildConfiguration` (delimitado por la línea
   `\t\t<UUID> /* Debug|Release */ = {` de apertura y `\t\t};` de cierre,
   el formato estándar que Xcode escribe para entradas de estas
   secciones).
2. Solo aplica el `gsub` de `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION`
   si el bloque contiene `PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.ExtractorApp;`
   (match exacto, ancla en `;` — no coincide con `...ExtractorAppTests;`).
3. Bloques que no cumplen la condición (incluidos los de
   `ExtractorAppTests`) se reimprimen sin modificar.

### Verificación

Probado en el sandbox (sin Xcode — es una transformación de texto pura,
no requiere compilar) ejecutando la función aislada sobre una **copia** del
`project.pbxproj` real del repo, con `VERSION=1.2`:

```
ExtractorApp   Debug/Release  → CURRENT_PROJECT_VERSION = 7  MARKETING_VERSION = 1.2   (bumped)
ExtractorAppTests Debug/Release → CURRENT_PROJECT_VERSION = 6  MARKETING_VERSION = 1.0  (intacto)
```

`bash -n` y `shellcheck scripts/release-macos.sh` limpios (sin avisos
nuevos). No requiere checkpoint humano — es lógica de texto verificable
sin Xcode, y el próximo `scripts/release-macos.sh <version>` real la
ejercitará de nuevo en producción.

**Success Criterion 1 de la Fase 18: cumplido.**

## POLISH-02: bug de búsqueda de paquetes SPM de Xcode 26.6

### Contexto (de la Fase 12)

Durante el checkpoint humano de la Fase 12 (`12-01-SUMMARY.md`), el
buscador de paquetes de Xcode 26.6 (`File → Add Package Dependencies…`)
devolvía **0 resultados para cualquier URL**, incluidos paquetes
trivialmente conocidos (`apple/swift-argument-parser`). Se descartó como
causa: red (curl a `github.com`/`api.github.com` con 200 OK, IPv4 e IPv6),
`git ls-remote` funcionando desde terminal, firewall/EDR, cuenta Apple ID
en Xcode, versión de Command Line Tools. Apuntaba a un fallo interno de
Xcode 26.6 en el propio flujo de búsqueda de la UI. Workaround aplicado
entonces: clonar el paquete a mano (`git clone --depth 1`) y añadirlo como
paquete **local** (`XCLocalSwiftPackageReference`) vía "Add Local...",
que sí funciona. Ver también `scripts/setup-sparkle-local.sh` (Fase 16),
que automatiza ese mismo workaround.

### Investigación en esta fase (sin acceso a Mac/Xcode desde este sandbox)

Búsqueda web de reportes públicos coincidentes con el síntoma exacto (caja
de búsqueda vacía para CUALQUIER URL, incluidas conocidas) en Xcode 26:

- **No se encontró un reporte público que coincida exactamente** con el
  síntoma (0 resultados universal, git/curl funcionando). Es posible que
  sea un fallo específico de esta máquina/instalación, poco reportado, o
  cubierto bajo un título distinto.
- Sí hay reportes relacionados de fallos de resolución de paquetes en
  Xcode 26/26.x, con causas y síntomas parecidos pero no idénticos:
  - Xcode 26 tiene un default interno, `IDEPackageSupportUseBuiltinSCM`,
    que controla qué stack Git/SCM usa Xcode para paquetes Swift. Con el
    stack por defecto, la verificación de host-key SSH puede fallar
    silenciosamente para ciertos paquetes y Xcode "retrocede" devolviendo
    un resultado vacío — se manifiesta normalmente como el error
    *"unexpectedly did not find the new dependency in the package graph"*,
    no como una búsqueda vacía, pero es la pista más concreta encontrada
    de un fallo silencioso en el mismo subsistema (resolución SCM interna
    de SPM). Fix reportado: `defaults write com.apple.dt.Xcode
    IDEPackageSupportUseBuiltinSCM 1` (revertir con `defaults delete
    com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM`), reinicio de
    Xcode. [manueltgomes.com]
  - Un hilo sin resolver en Apple Developer Forums describe un spinner de
    búsqueda infinito que funciona una vez tras reinstalar Xcode y luego
    vuelve a fallar en el segundo intento — sin causa raíz confirmada por
    Apple ni por la comunidad. [developer.apple.com/forums/thread/766204]
  - Otros hilos apuntan a limpiar `~/Library/Caches/org.swift.swiftpm/`,
    borrar `IDESwiftPackageAdditionAssistantRecentlyUsedPackages` de
    `~/Library/Preferences/com.apple.dt.Xcode.plist`, o quitar/re-añadir
    la cuenta de GitHub en Xcode — ninguno confirmado como fix universal.
  - No se encontraron notas de versión de un Xcode 26.7+ (más reciente
    que 26.6) que mencionen explícitamente un fix de este bug — no está
    claro si existe ya una versión más nueva o si 26.6 sigue siendo la
    instalada.

### Conclusión (Success Criterion 2)

**No se identifica una causa raíz confirmada** — solo un candidato
plausible (`IDEPackageSupportUseBuiltinSCM`) que ataca un síntoma
relacionado pero no idéntico, y varios workarounds sin confirmar de la
comunidad. El bug **sigue documentado como no resuelto** desde esta
investigación (basada en búsqueda web, no en reproducción real — este
sandbox no tiene Xcode).

**Success Criterion 2: cumplido** (investigado y documentado; causa raíz
no identificada con certeza, confirmado que sigue sin una solución
verificada).

### Pendiente de checkpoint humano (opcional, no bloqueante)

Si el usuario quiere intentar destrabar esto en su Mac real (no
obligatorio para cerrar la Fase 18), puede probar, en este orden, sin
tocar nada del proyecto:

1. Comprobar la versión actual de Xcode (`Xcode → About Xcode`) — si ya
   es más reciente que 26.6, probar directamente `File → Add Package
   Dependencies…` con una URL conocida (`https://github.com/apple/swift-argument-parser`)
   antes de aplicar nada más.
2. Si sigue en 26.6 (o el bug persiste en una versión más nueva):
   `defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 1`,
   reiniciar Xcode, reintentar la búsqueda.
3. Si no funciona, revertir (`defaults delete com.apple.dt.Xcode
   IDEPackageSupportUseBuiltinSCM`) y probar borrar
   `~/Library/Caches/org.swift.swiftpm/` + `File → Packages → Reset
   Package Caches`.

**Success Criterion 3 (migrar Sparkle a paquete remoto) queda condicionado
a que el usuario confirme en su Mac que alguna de estas vías resuelve el
bug** — no se puede confirmar ni aplicar desde este sandbox sin Xcode. Si
el usuario no quiere invertir tiempo en esto ahora, la Fase 18 se cierra
igualmente con POLISH-01 completo y POLISH-02 documentado como
"investigado, sin causa raíz confirmada, sigue sin resolverse" — el
paquete local (`XCLocalSwiftPackageReference` + `scripts/setup-sparkle-local.sh`)
sigue siendo un workaround funcional y ya verificado en producción
(Fases 12/16).

## Fuentes consultadas

- https://manueltgomes.com/apple/xcode/how-to-fix-the-unexpectedly-did-not-find-the-new-dependency-in-the-package-graph/
- https://developer.apple.com/forums/thread/766204
- https://developer.apple.com/forums/thread/775538 (no cargó contenido útil vía WebFetch)
- https://forums.swift.org/t/xcode-26-unable-to-find-module-dependency/80516
- `.planning/phases/12-sparkle-integracion/12-01-SUMMARY.md` (contexto original del bug)
