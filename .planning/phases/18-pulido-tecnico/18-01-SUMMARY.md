---
plan: 18-01
phase: 18-pulido-tecnico
status: complete
completed: "2026-08-23"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - POLISH-01
  - POLISH-02
---

# Summary: 18-01 — Pulido técnico

## What Was Built

### scripts/release-macos.sh — `_bump_version()` acotada al target `ExtractorApp`

El `sed -e "s/.../g"` original operaba sobre el `.pbxproj` completo,
bumpeando por igual los 4 bloques `XCBuildConfiguration` con
`MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` — 2 de `ExtractorApp` y 2 de
`ExtractorAppTests`, que comparten los mismos valores por coincidencia.
Reescrita con un script `awk` que bufferiza cada bloque
`XCBuildConfiguration` y solo aplica el `gsub` si el bloque contiene
`PRODUCT_BUNDLE_IDENTIFIER = com.edefrutos.ExtractorApp;` (match exacto,
no confundible con `...ExtractorAppTests;`). `ExtractorAppTests` queda
intacto.

### .planning/phases/18-pulido-tecnico/18-RESEARCH.md

Investigación del bug de búsqueda de paquetes SPM de Xcode 26.6
(POLISH-02, ver `12-01-SUMMARY.md` para el contexto original). Búsqueda
web sin encontrar un reporte público que coincida exactamente con el
síntoma; se documenta un candidato relacionado plausible (default interno
`IDEPackageSupportUseBuiltinSCM` de Xcode 26, fallo silencioso de
verificación SSH en resolución de paquetes) y varios workarounds de
comunidad sin confirmar. Sin causa raíz confirmada.

## Verification Status — ✅ VERIFICADO (sin checkpoint humano necesario)

- **POLISH-01**: probado en el sandbox (transformación de texto pura, no
  requiere Xcode) ejecutando `_bump_version()` de forma aislada sobre una
  **copia** del `project.pbxproj` real del repo con `VERSION=1.2`:
  `ExtractorApp` Debug/Release → `CURRENT_PROJECT_VERSION = 7`,
  `MARKETING_VERSION = 1.2` (bumpeado); `ExtractorAppTests` Debug/Release →
  sin cambios (`CURRENT_PROJECT_VERSION = 6`, `MARKETING_VERSION = 1.0`).
  `bash -n` y `shellcheck scripts/release-macos.sh` limpios, sin avisos
  nuevos. El archivo real del repo no se tocó durante la prueba — la
  función se ejercitará de nuevo en producción en el próximo release real.
- **POLISH-02**: investigado por búsqueda web (sin acceso a Mac/Xcode
  desde este sandbox). Sin causa raíz confirmada — documentado en
  `18-RESEARCH.md` como "investigado, sigue sin resolverse". El usuario
  decidió explícitamente no invertir tiempo ahora en probar el ajuste
  candidato (`IDEPackageSupportUseBuiltinSCM`) en su Mac real — el
  paquete local (`XCLocalSwiftPackageReference` +
  `scripts/setup-sparkle-local.sh`, Fases 12/16) sigue siendo el mecanismo
  de producción, ya verificado y funcionando. Success Criterion 3
  (migrar a paquete remoto) queda sin cumplir por esta decisión explícita,
  no por fallo técnico — puede revisarse en cualquier fase futura si el
  usuario actualiza Xcode o quiere reintentar el diagnóstico.
- Sin cambios en código Swift ni en `project.pbxproj` — Fase 18 no
  requería build de Xcode, por eso no hubo checkpoint humano.
