---
gsd_state_version: 1.0
milestone: v5.0
milestone_name: Auto-actualización (Sparkle)
status: executing
last_updated: "2026-08-20T00:00:00.000Z"
last_activity: 2026-08-20 -- Fase 12 (integración Sparkle) verificada en checkpoint humano: Build Succeeded, menú "Buscar actualizaciones…" visible. Fase 13 (pipeline de release) pendiente de research.
progress:
  total_phases: 2
  completed_phases: 1
  total_plans: 1
  completed_plans: 1
  percent: 50
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Fase 12 completa y verificada. Siguiente: Fase 13 — pipeline de release (claves EdDSA, firma Developer ID, notarización, `scripts/release-macos.sh`, `appcast.xml` real). Sin research todavía.

## Current Position

Phase: 12 — Integración Sparkle en la app — **Complete**
Plan: 12-01 (Wave 1) — completo, verificado
Status: Complete — checkpoint humano pasado en Xcode 26.6 el 2026-08-20
Last activity: 2026-08-20 — Checkpoint humano: Build Succeeded (tras corregir un bug real: faltaba `import Combine` en `CheckForUpdatesView.swift`). App arranca, "Buscar actualizaciones…" visible en el menú (deshabilitado, esperado sin clave/appcast reales). Log de Sparkle confirma carga correcta ("Serving updates without an EdDSA key..." — exactamente lo previsto con el placeholder). Desviación relevante: el buscador remoto de paquetes de Xcode 26.6 devolvía 0 resultados para CUALQUIER paquete SPM (se probó con swift-argument-parser también) tras descartar red/DNS/IPv4/IPv6/git/API GitHub/cuenta Xcode — workaround: Sparkle clonado a `.build-cache/Sparkle` (gitignored) y añadido como paquete SPM **local** en vez de remoto. Ver `12-01-SUMMARY.md` para el detalle completo del troubleshooting y el trade-off de mantenimiento futuro.

```
v5.0 Progress: [=====     ] 50% — Fase 12 completa, Fase 13 sin empezar
Phase 12: [==========] 1/1 plan — Complete
Phase 13: [          ] 0/? planes (research pendiente)
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

### Pending Todos

- Iniciar research de Fase 13 (pipeline de release): `generate_keys` (clave EdDSA), firma Developer ID, `notarytool submit --wait` + `stapler staple`, `generate_appcast`, publicación en GitHub Releases (`gh release create`/`upload`), y el script `scripts/release-macos.sh` que lo automatiza todo.
- Al generar la clave EdDSA real, sustituir el placeholder `INFOPLIST_KEY_SUPublicEDKey = "PENDIENTE-FASE-13-generate_keys"` por la clave pública real en `project.pbxproj` (Debug y Release).
- Decidir en algún momento (no bloqueante) si migrar el paquete Sparkle de referencia local a remota, una vez se entienda o se resuelva el bug del buscador de Xcode 26.6.

### Blockers/Concerns

- Ninguno bloqueante para empezar Fase 13. Nota de mantenimiento: `.build-cache/Sparkle` debe existir en cualquier checkout donde se vaya a compilar el proyecto (no viaja con git, está en `.gitignore`) — si se clona el repo en una máquina nueva, hay que repetir `git clone --depth 1 https://github.com/sparkle-project/Sparkle .build-cache/Sparkle` antes de abrir el proyecto en Xcode, o el paquete no resolverá.

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
Stopped at: Fase 12 completa y verificada. Pendiente: iniciar research de Fase 13 (pipeline de release) o preguntar al usuario si quiere commitear/pushear primero.
Resume file: .planning/phases/12-sparkle-integracion/12-01-SUMMARY.md
