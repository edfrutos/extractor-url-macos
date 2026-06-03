# Roadmap: extractor-url

## v1.0 Stabilization

## Overview

Primero se estabiliza el extractor y su conversor Markdown con pruebas y documentación fiable. Después se abordarán robustez operativa, mejoras CLI y empaquetado macOS.

## Phases

- [x] **Phase 1: Validacion automatica del conversor** - Base de pruebas y validación de comportamiento actual.
- [ ] **Phase 2: Robustez CLI y manejo explícito de errores** - Endurecer interfaz pública, salidas de error y cobertura de CLI.

## Phase Details

### Phase 1: Validacion automatica del conversor
**Goal**: Crear una base de tests locales que congele el comportamiento correcto del conversor Markdown y permita evolucionar el proyecto sin regresiones.
**Depends on**: Nothing (first phase)
**Requirements**: [REQ-01, REQ-02, REQ-03]
**Success Criteria** (what must be TRUE):
  1. Existe un directorio `tests/` con fixtures HTML locales y pruebas ejecutables.
  2. El flujo Markdown actual queda cubierto en los casos de limpieza DOM, selector CSS y URLs relativas.
  3. La documentación principal deja claro qué está implementado y qué queda pendiente.
**Plans**: 2 plans

Plans:
- [x] 01-01: Crear base de tests y alinear documentación de la fase
- [x] 01-02: Cerrar gaps de `pytest tests/` y desajuste documental en `NOTEBOOK.md`

## Progress

**Execution Order:**
Phases execute in numeric order: 1

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Validacion automatica del conversor | 2/2 | Complete | 2026-06-03 |

### Phase 2: Robustez CLI y manejo explícito de errores

**Goal:** Corregir las regresiones y silencios peligrosos de la CLI pública para que la herramienta falle de forma explícita, soporte `--gui` como está documentado y quede cubierta por pruebas sobre sus caminos de error principales.
**Requirements**: [REQ-04, REQ-05, REQ-06]
**Depends on:** Phase 1
**Success Criteria** (what must be TRUE):
  1. `python extractor_url.py --gui` abre la interfaz sin exigir URL posicional.
  2. Un fallo al guardar con `-o/--output` devuelve exit code distinto de cero.
  3. Un selector CSS inválido no amplía silenciosamente el alcance de extracción.
  4. Existen pruebas automatizadas sobre la CLI pública y sus caminos de error principales.
**Plans:** 0 plans

Plans:
- [ ] TBD (run /gsd-plan-phase 2 to break down)
