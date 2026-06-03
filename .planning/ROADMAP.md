# Roadmap: extractor-url

## v1.0 Stabilization

## Overview

Primero se estabiliza el extractor y su conversor Markdown con pruebas y documentación fiable. Después se abordarán robustez operativa, mejoras CLI y empaquetado macOS.

## Phases

- [x] **Phase 1: Validacion automatica del conversor** - Base de pruebas y validación de comportamiento actual.

## Phase Details

### Phase 1: Validacion automatica del conversor
**Goal**: Crear una base de tests locales que congele el comportamiento correcto del conversor Markdown y permita evolucionar el proyecto sin regresiones.
**Depends on**: Nothing (first phase)
**Requirements**: [REQ-01, REQ-02, REQ-03]
**Success Criteria** (what must be TRUE):
  1. Existe un directorio `tests/` con fixtures HTML locales y pruebas ejecutables.
  2. El flujo Markdown actual queda cubierto en los casos de limpieza DOM, selector CSS y URLs relativas.
  3. La documentación principal deja claro qué está implementado y qué queda pendiente.
**Plans**: 1 plan

Plans:
- [x] 01-01: Crear base de tests y alinear documentación de la fase

## Progress

**Execution Order:**
Phases execute in numeric order: 1

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Validacion automatica del conversor | 1/1 | Complete | 2026-06-03 |
