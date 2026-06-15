---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Standalone App
status: executing
last_updated: "2026-06-15T10:05:00.000Z"
last_activity: 2026-06-15 -- Phase 8 planificada (3 planes PASS)
progress:
  total_phases: 3
  completed_phases: 0
  total_plans: 3
  completed_plans: 0
  percent: 5
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-06-14)

**Core value:** Convertir páginas web en Markdown útil y limpio de forma fiable, repetible y sin depender de servicios externos.
**Current focus:** Phase 8 — bundling Python runtime dentro del .app

## Current Position

Phase: 8 — Bundle Python Runtime
Plan: 08-01 (Wave 1, listo para ejecutar)
Status: Planned — ready to execute
Last activity: 2026-06-15 — Phase 8 planificada con research + 3 PLANs verificados

```
v3.0 Progress: [----------] 5%
Phase 8: [----------] 0/3 planes
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

### Pending Todos

- Ejecutar 08-01-PLAN.md: crear `scripts/bundle-python.sh` + actualizar `.gitignore`
- Ejecutar 08-02-PLAN.md: Copy Files Phase Xcode + Run Script Phase + bundledPythonPath() en PythonBridge
- Ejecutar 08-03-PLAN.md: verify-bundle.sh + BundlePathTests.swift + build Release + checkpoint humano

### Blockers/Concerns

- Ninguno. `--json` confirmado en extractor_url.py línea 250.

## Deferred Items (desde v2.0)

| Category | Item | Status |
|----------|------|--------|
| Funcionalidad | Soporte páginas JavaScript (Playwright) | v4+ |
| Funcionalidad | Historial y cola de extracciones | v4+ |
| Distribución | Notarización para terceros | v3 es personal; revisar en v4 |

## Session Continuity

Last session: 2026-06-14T19:42:00Z
Stopped at: Definiendo requirements para v3.0
Resume file: None
