---
plan: 22-01
phase: 22-notarizacion-distribucion-publica
status: complete
completed: "2026-08-24"
tasks_completed: 1
tasks_total: 1
requirements_covered:
  - PUBLISH-01
  - PUBLISH-02
---

# Summary: 22-01 — Notarización para distribución pública (web)

## Hallazgo previo a la implementación

Antes de escribir nada, se revisó qué de esto ya existía: desde la Fase
13, `scripts/release-macos.sh` ya notariza + staplea el `.app` y lo
publica en GitHub Releases de `edfrutos/extractor-url-macos` — un
repositorio **ya público** (confirmado indirectamente desde la Fase 13:
`curl` sin credenciales ya podía leer `appcast.xml` en vivo). Es decir,
el mecanismo técnico central de PUBLISH-01/02 ya existía; lo que faltaba
era **verificarlo explícitamente desde la perspectiva de un descargador
nuevo** y **corregir la documentación**, que todavía decía lo contrario
("la notarización no implica distribución pública a terceros",
`README.md` heredado de v5.0).

Esta fase no necesitó ningún pipeline nuevo ni cambios en
`scripts/release-macos.sh`.

## What Was Built (documentación + verificación, sin cambios de pipeline)

### RELEASING.md — nueva sección 3.8

Documenta que el `.zip` que Sparkle ya usa para las actualizaciones
automáticas es el mismo artefacto de descarga directa para quien no
tiene la app instalada — diferenciado explícitamente del flujo de
Sparkle (Success Criterion 3 de la Fase 22). Incluye el comando de
verificación con `spctl`.

### README.md

- Corregida la afirmación de que la notarización "no implica
  distribución pública a terceros" — ya no es cierto desde esta fase.
- Nueva línea "Descarga" apuntando a GitHub Releases.
- Tabla de milestones actualizada con v6.0 (completo) y v7.0 (en
  marcha) — estaba parada en v5.0 desde hacía varias fases, corregida
  de paso al tocar esta sección (no una limpieza completa del README,
  solo lo directamente contradicho por esta fase).

## Verification Status — ✅ VERIFICADO (Mac real, release ya publicado)

**Success Criterion 1** (`.app` en ubicación pública descargable sin
configuración especial): ya cumplido de antes — `gh release list
--repo edfrutos/extractor-url-macos` confirma releases públicos
existentes (`v1.0`, entre otros), descargables con `gh release download`
sin autenticación especial más allá de lo que cualquier usuario de
GitHub ya tiene.

**Success Criterion 2** (Mac limpio abre el `.app` sin avisos de
Gatekeeper) — verificado con `spctl`, que evalúa la firma/notarización
del binario en sí, no el estado de confianza de la máquina que lo
ejecuta (por eso no hace falta un Mac limpio de verdad para esta
prueba):

```
$ gh release download v1.0 --repo edfrutos/extractor-url-macos
$ unzip -q *.zip
$ spctl -a -vvv --type execute ExtractorApp.app
ExtractorApp.app: accepted
source=Notarized Developer ID
origin=Developer ID Application: Eugenio de Frutos Sanchez (V29BTBRY6G)
```

`accepted` + `source=Notarized Developer ID` es exactamente el
veredicto que Gatekeeper daría a cualquier usuario abriendo el `.app`
por primera vez — sin diálogo de "no se puede verificar el
desarrollador".

**Success Criterion 3** (proceso documentado, diferenciado del appcast
de Sparkle): cumplido en `RELEASING.md` §3.8.

## Notas

- No fue necesario un checkpoint humano formal separado (build en
  Xcode) — esta fase es documentación + una verificación con `spctl`
  contra un release ya publicado, ejecutada directamente en el Mac real
  del usuario durante la conversación.
- Se mantiene la decisión de alcance de la definición de v7.0: web
  pública (GitHub Releases), explícitamente NO Mac App Store.
