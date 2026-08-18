---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Standalone App
status: complete
last_updated: "2026-08-18T00:00:00.000Z"
last_activity: 2026-08-18 -- Checkpoint humano Fase 10 pasado en Xcode (Build Succeeded, 49 tests/3 skipped/0 fallos, checklist visual OK) — milestone v3.0 cerrado
progress:
  total_phases: 3
  completed_phases: 3
  total_plans: 3
  completed_plans: 3
  percent: 100
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-18)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Milestone v3.0 (Standalone App) completado y cerrado. Sin foco activo — pendiente que el usuario indique el siguiente milestone (v4+: soporte JS/Playwright, historial de extracciones, o commit de todo lo pendiente).

## Current Position

Phase: 10 — UX Zero-Config
Plan: 10-01 (Wave 1)
Status: Complete — checkpoint humano pasado en Xcode el 2026-08-18
Last activity: 2026-08-18 — Checkpoint humano: Build Succeeded (tras corregir 2 bugs reales encontrados durante la verificación: warnings de Sendable en IOCollector, y Task.detached para bundledPythonVersion() que corría erróneamente en @MainActor), 49 tests ejecutados/3 skipped/0 fallos, checklist visual 2-0 a 2D confirmado (badge "Python 3.13.14" real).

```
v3.0 Progress: [==========] 100% — verificado con xcodebuild real, milestone cerrado
Phase 8: [==========] 3/3 planes
Phase 9: [==========] 1/1 plan
Phase 10: [==========] 1/1 plan (checkpoint humano completo)
```

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Decisiones relevantes para v3.0:

- [v3.0]: python-build-standalone (astral-sh, release 20260610) + Python 3.13.14 como runtime embebido — `install_only` tarballs arm64 + x86_64, fusionados con lipomerge + segundo pase lipo para lib-dynload .so.
- [v3.0]: App Sandbox OFF simplifica el bundling — sin entitlements adicionales para subprocess con binario embebido.
- [v3.0]: Bundle size ~30-60 MB añadido es aceptable para uso personal.
- [v3.0]: Python en `Contents/Resources/python/bin/` (NO en `Contents/MacOS/`) — evita Local Network Privacy dialog de TCC.
- [v3.0]: `PYTHONPATH` env var desde PythonBridge para encontrar deps vendorizadas (NO .pth file — rutas variables según instalación del usuario).
- [v3.0]: `pip install --target ... --platform macosx_13_0_universal2 --only-binary :all:` para forzar wheels universal2 (lxml 6.1.1 tiene wheel universal2 para cp313).
- [v3.0]: Codesigning bottom-up manual — `find .so/.dylib` → `python3.13` → Xcode firma `.app`. Sin `--deep`.
- [v3.0]: SettingsView mantiene override de rutas para uso avanzado — no se elimina, se hace opcional (Fase 10).
- [v3.0]: `PathSource` (PythonBridge) y `PythonOperatingMode` (SettingsViewModel) declarados `Equatable` explícitamente — necesario para que `XCTAssertEqual`/`==` compilen; Swift no sintetiza Equatable en enums sin declaración explícita, aunque no tengan asociados.
- [v3.0]: `SettingsViewModel.operatingMode` reutiliza `PythonBridge.resolvedPaths()` (misma lógica que `run()`) en vez de reimplementar la prioridad UserDefaults/bundle — evita que el badge de Preferencias se desincronice del comportamiento real.
- [v3.0]: Sección "Configuración avanzada" en SettingsView colapsada por defecto solo en modo bundle; se auto-expande la primera vez si el modo activo es override o unavailable (UX-03).
- [v3.0]: `IOCollector: @unchecked Sendable` en vez de `nonisolated` — el `NSLock` interno ya protege el estado; `nonisolated` no suprime los warnings de captura no-Sendable en closures `@Sendable`. Encontrado en el checkpoint humano de Fase 10.
- [v3.0]: `refreshOperatingMode()` lanza `Task.detached` (no `Task {}`) para `bundledPythonVersion()` — `SettingsViewModel` es `@MainActor` y un `Task {}` normal hereda ese aislamiento, así que el subprocess bloqueante `--version` corría en el hilo principal pese al comentario original. Encontrado en el checkpoint humano de Fase 10.

### Pending Todos

- Ninguno pendiente de v3.0. Decidir siguiente milestone (v4+) o hacer commit de Fases 9+10 y docs (ver Blockers/Concerns).

### Blockers/Concerns

- Nada bloqueante. Todos los cambios de Fase 9 y Fase 10 (código Swift + docs de planning) siguen sin commitear en `git status` — el usuario no ha pedido aún hacer el commit; preguntar antes de commitear (ver flujo de cierre en `.planning/phases/10-ux-zero-config/CHECKPOINT-HUMANO.md`, Paso 5.4).

## Deferred Items (desde v2.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Soporte páginas JavaScript (Playwright) | v4+ |
| Funcionalidad | Historial y cola de extracciones | v4+ |
| Distribución | Notarización para terceros | v3 es personal; revisar en v4 |

## Session Continuity

Last session: 2026-08-18T00:00:00Z
Stopped at: Milestone v3.0 cerrado tras checkpoint humano en Xcode (Build Succeeded, 49 tests/3 skipped/0 fallos, checklist visual OK). Pendiente: preguntar al usuario si quiere commitear Fase 9 + Fase 10 + docs.
Resume file: .planning/phases/10-ux-zero-config/10-01-SUMMARY.md
