---
gsd_state_version: 1.0
milestone: v5.0
milestone_name: Auto-actualización (Sparkle)
status: complete
last_updated: "2026-08-20T00:00:00.000Z"
last_activity: 2026-08-20 -- Fase 13 verificada con un release real (v1.0 publicado, appcast.xml firmado y en vivo) — milestone v5.0 cerrado
progress:
  total_phases: 2
  completed_phases: 2
  total_plans: 2
  completed_plans: 2
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone v5.0 completado y cerrado. Sin foco activo — pendiente que el usuario indique el siguiente milestone (v6+: historial de extracciones, flag manual --js/--no-js, notarización pública) o pida alguna otra tarea.

## Current Position

Phase: 13 — Pipeline de release y publicación — **Complete**
Plan: 13-01 (Wave 1) — completo, verificado con release real
Status: Complete — checkpoint humano pasado en el Mac del usuario el 2026-08-20
Last activity: 2026-08-20 — Checkpoint humano completo: generación de clave EdDSA real, configuración de notarización, y primer release real de principio a fin (`v1.0`, https://github.com/edfrutos/extractor-url-macos/releases/tag/v1.0). 4 bugs reales encontrados y corregidos en `scripts/release-macos.sh` durante el proceso: (1) bootstrap roto — `_ensure_sparkle_tools` debía ir antes de `_preflight_checks`; (2) `exportOptions.plist` sin `teamID` → "No Team Found in Archive"; (3) el Python embebido de la Fase 8 sin hardened runtime tras exportar (binario suelto fuera del grafo de frameworks de Xcode) → `_resign_bundled_python()` nuevo; (4) `generate_appcast` no firmaba el enclosure pese a que `sign_update` sí funciona en aislamiento → fallback explícito con `sign_update` + inyección de la firma en el XML. `appcast.xml` verificado en vivo vía `curl` con la firma EdDSA correcta.

```
v5.0 Progress: [==========] 100% — verificado con release real, milestone cerrado
Phase 12: [==========] 1/1 plan — Complete
Phase 13: [==========] 1/1 plan — Complete
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v5.0:

- [v5.0]: Sparkle 2.x (no WinSparkle/NetSparkle/manual) — único framework de referencia para auto-update en macOS fuera del App Store.
- [v5.0]: Appcast alojado en GitHub Releases (`raw.githubusercontent.com` + assets de release) — sin infraestructura de hosting nueva. Confirmado en vivo.
- [v5.0]: Comprobación automática (24h, comportamiento por defecto de Sparkle) + manual vía menú — sin toggle propio en Preferencias.
- [v5.0]: `INFOPLIST_KEY_SUFeedURL`/`INFOPLIST_KEY_SUPublicEDKey` como build settings, no un `.plist` físico — este proyecto usa `GENERATE_INFOPLIST_FILE = YES` (Xcode 16+).
- [v5.0]: Sparkle añadido como paquete SPM **local** (`.build-cache/Sparkle`, gitignored) en vez de remoto — el buscador de paquetes de Xcode 26.6 fallaba universalmente. Trade-off: no se actualiza solo de versión.
- [v5.0]: `exportOptions.plist` necesita `teamID` explícito (`V29BTBRY6G`) — `xcodebuild -exportArchive` con Automatic sin team fijo falla "No Team Found in Archive" desde línea de comandos.
- [v5.0]: `_resign_bundled_python()` re-firma el Python embebido (Fase 8) con `--options runtime` tras exportar — `xcodebuild -exportArchive` no aplica hardened runtime a binarios sueltos fuera del grafo de frameworks de Xcode; notarytool los rechaza sin ello.
- [v5.0]: `sign_update` explícito como fallback si `generate_appcast` no firma el enclosure automáticamente — causa raíz no determinada, pero el fallback garantiza que el appcast siempre queda firmado.
- [v5.0]: `_ensure_sparkle_tools` debe ejecutarse ANTES de `_preflight_checks` — bootstrap roto si no (generate_keys no descargado la primera vez que se necesita).

### Pending Todos

- Ninguno pendiente de v5.0. Decidir siguiente milestone (v6+) o pulir el efecto colateral menor: `_bump_version` sube `CURRENT_PROJECT_VERSION` también en el target `ExtractorAppTests` (inofensivo, pero se podría acotar el `sed` al target `ExtractorApp` únicamente).
- Opcional, no bloqueante: probar el flujo end-to-end de Sparkle detectando una actualización desde una instalación antigua (no se hizo en este checkpoint por no haber un build antiguo con clave real disponible).
- Decidir en algún momento si migrar el paquete Sparkle de referencia local a remota, una vez se entienda/arregle el bug del buscador de Xcode 26.6.

### Blockers/Concerns

- Nada bloqueante. Release v1.0 público y funcional: https://github.com/edfrutos/extractor-url-macos/releases/tag/v1.0

## Deferred Items (desde v5.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Historial y cola de extracciones | v6+ |
| Funcionalidad | Flag manual `--js`/`--no-js` | v6+ si la heurística automática de v4.0 resulta insuficiente |
| Funcionalidad | Canales beta/nightly, rollouts por fases (Sparkle) | v6+ si hay demanda |
| Distribución | Embeber Playwright/Chromium en el `.app` bundle | v6+ si hay demanda real, pese al coste de +300MB |
| Distribución | Notarización para distribución pública (App Store, web pública) | Sigue fuera de alcance — v5.0 solo notariza para uso propio vía Sparkle |
| Técnico | Migrar Sparkle de paquete local a remoto (SPM) | Cuando se entienda/arregle el bug del buscador de Xcode 26.6 |
| Técnico | Acotar `_bump_version` al target ExtractorApp únicamente | Pulido menor, no bloqueante |

## Session Continuity

Last session: 2026-08-20T00:00:00Z
Stopped at: Milestone v5.0 cerrado tras el primer release real (v1.0) verificado de principio a fin. Pendiente: preguntar al usuario si quiere definir el siguiente milestone (v6+) o hacer alguna otra tarea.
Resume file: .planning/phases/13-release-pipeline/13-01-SUMMARY.md
