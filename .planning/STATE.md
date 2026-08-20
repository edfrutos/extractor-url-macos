---
gsd_state_version: 1.0
milestone: v5.0
milestone_name: Auto-actualización (Sparkle)
status: executing
last_updated: "2026-08-20T00:00:00.000Z"
last_activity: 2026-08-20 -- Fase 13 (pipeline de release) código y RELEASING.md completos — pendiente checkpoint humano del primer release real (genera secretos, publica en GitHub)
progress:
  total_phases: 2
  completed_phases: 1
  total_plans: 2
  completed_plans: 1
  percent: 75
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fase 13 — pipeline de release. Código y documentación completos (`scripts/release-macos.sh`, `RELEASING.md`); pendiente checkpoint humano: configuración de una sola vez (clave EdDSA, credenciales de notarización) + primer release real, verificable solo en el Mac del usuario con sus credenciales.

## Current Position

Phase: 13 — Pipeline de release y publicación
Plan: 13-01 (Wave 1) — código completo, sin ejecutar
Status: Implemented — pendiente checkpoint humano (configuración de una sola vez + primer release real)
Last activity: 2026-08-20 — Research completa (`13-RESEARCH.md`, hallazgo clave: el clon local de Sparkle de la Fase 12 no trae los binarios CLI `generate_keys`/`sign_update`/`generate_appcast`, hace falta descargar el tarball de distribución aparte). Plan 13-01 escrito y ejecutado: `scripts/release-macos.sh` (7 funciones: preflight, descarga de herramientas Sparkle, version bump, build+export Developer ID, notarizar+staplear en orden estricto, archivar+generar appcast, publicar en GitHub Releases) + `RELEASING.md` (configuración de una sola vez documentada, sin secretos). `CHECKPOINT-HUMANO.md` escrito con aviso explícito de que este checkpoint publica algo público real, a diferencia de los anteriores.

```
v5.0 Progress: [=======   ] 75% — Fase 12 completa, Fase 13 código completo/checkpoint pendiente
Phase 12: [==========] 1/1 plan — Complete
Phase 13: [========  ] 1/1 plan (código) — checkpoint humano pendiente (primer release real)
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v5.0:

- [v5.0]: Sparkle 2.x (no WinSparkle/NetSparkle/manual) — único framework de referencia para auto-update en macOS fuera del App Store.
- [v5.0]: Appcast alojado en GitHub Releases (`raw.githubusercontent.com` + assets de release) — sin infraestructura de hosting nueva.
- [v5.0]: Comprobación automática (24h, comportamiento por defecto de Sparkle) + manual vía menú — sin toggle propio en Preferencias, Sparkle ya expone su propia UI para esto.
- [v5.0]: `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey` como build settings, no un `.plist` físico — este proyecto usa `GENERATE_INFOPLIST_FILE = YES` (Xcode 16+).
- [v5.0]: `scripts/release-macos.sh` (Fase 13) automatiza el pipeline completo de publicación — decisión explícita del usuario, seguirá el patrón de estilo de `scripts/bundle-python.sh` ya existente.
- [v5.0]: El usuario confirmó tener cuenta Apple Developer Program de pago — notarización y firma Developer ID son viables para Fase 13.
- [v5.0]: Sparkle añadido como paquete SPM **local** (`.build-cache/Sparkle`, gitignored) en vez de remoto — el buscador de paquetes de Xcode 26.6 fallaba universalmente (0 resultados para cualquier URL, no solo Sparkle) tras descartar exhaustivamente causas de red. Trade-off: no se actualiza solo de versión; revisar si Xcode arregla el bug en el futuro.
- [v5.0]: `import Combine` explícito necesario en `CheckForUpdatesView.swift` — `import SwiftUI` no lo re-exportó lo suficiente para que `@Published`/`ObservableObject` compilaran en este proyecto/versión de Xcode.
- [v5.0]: Herramientas CLI de Sparkle (`generate_keys`/`sign_update`/`generate_appcast`) NO vienen en el clon local de código fuente de la Fase 12 — se descargan aparte del tarball de distribución oficial (`Sparkle-X.Y.Z.tar.xz`), cacheadas en `.build-cache/sparkle-tools/`. `scripts/release-macos.sh` lo hace automáticamente.
- [v5.0]: `.zip` (no `.dmg`) como formato de distribución, vía `ditto -c -k --sequesterRsrc --keepParent` — nunca `zip`/`unzip` genéricos, rompen la firma de código (AppleDouble `._*`).
- [v5.0]: `scripts/release-macos.sh` nunca ejecuta `git push`/`git commit` — solo imprime las instrucciones exactas al final, dejando la publicación del appcast bajo control explícito del usuario.

### Pending Todos

- Checkpoint humano Fase 13: configuración de una sola vez (`generate_keys`, sustituir placeholder de `SUPublicEDKey`, `notarytool store-credentials`, `gh auth login`) + primer release real con `scripts/release-macos.sh <version>` — ver `.planning/phases/13-release-pipeline/CHECKPOINT-HUMANO.md`.
- Tras el checkpoint: escribir el resultado real en `13-01-SUMMARY.md`, marcar Fase 13 y el milestone v5.0 como completos en ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md/MILESTONES.md.
- Decidir en algún momento (no bloqueante) si migrar el paquete Sparkle de referencia local a remota, una vez se entienda o se resuelva el bug del buscador de paquetes de Xcode 26.6.

### Blockers/Concerns

- Ninguno bloqueante. Nota de mantenimiento: `.build-cache/Sparkle` debe existir en cualquier checkout donde se vaya a compilar el proyecto (no viaja con git, está en `.gitignore`) — si se clona el repo en una máquina nueva, hay que repetir `git clone --depth 1 https://github.com/sparkle-project/Sparkle .build-cache/Sparkle` antes de abrir el proyecto en Xcode, o el paquete no resolverá.
- El checkpoint de Fase 13, a diferencia de los anteriores, publica algo público real (un GitHub Release) — no es solo "compila y verifica". `CHECKPOINT-HUMANO.md` lo señala explícitamente antes del Paso 3.

## Deferred Items (desde v5.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Historial y cola de extracciones | v6+ |
| Funcionalidad | Flag manual `--js`/`--no-js` | v6+ si la heurística automática de v4.0 resulta insuficiente |
| Funcionalidad | Canales beta/nightly, rollouts por fases (Sparkle) | v6+ si hay demanda |
| Distribución | Embeber Playwright/Chromium en el `.app` bundle | v6+ si hay demanda real, pese al coste de +300MB |
| Distribución | Notarización para distribución pública (App Store, web pública) | Sigue fuera de alcance — v5.0 solo notariza para uso propio vía Sparkle |
| Técnico | Migrar Sparkle de paquete local a remoto (SPM) | Cuando se entienda/arregle el bug del buscador de Xcode 26.6 |

## Session Continuity

Last session: 2026-08-20T00:00:00Z
Stopped at: Fase 13 código y documentación completos (scripts/release-macos.sh, RELEASING.md). Pendiente: checkpoint humano del primer release real, o preguntar al usuario si quiere commitear/pushear el código primero (sin ejecutar el release todavía).
Resume file: .planning/phases/13-release-pipeline/CHECKPOINT-HUMANO.md
