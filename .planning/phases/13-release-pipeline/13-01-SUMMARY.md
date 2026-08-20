---
plan: 13-01
phase: 13-release-pipeline
status: code-complete-unverified
completed: "2026-08-20"
tasks_completed: 2
tasks_total: 2
requirements_covered:
  - UPDATE-04
  - UPDATE-05
  - UPDATE-06
---

# Summary: 13-01 — Pipeline de release y publicación

## What Was Built

### scripts/release-macos.sh

Pipeline completo de 7 etapas (`_preflight_checks`, `_ensure_sparkle_tools`,
`_bump_version`, `_build_and_export`, `_notarize_and_staple`,
`_archive_and_generate_appcast`, `_publish_release`), siguiendo el estilo
ya establecido de `scripts/bundle-python.sh` (`set -euo pipefail`,
cabecera con requisitos previos, sección de configuración al principio).

Puntos clave:

- **3 validaciones previas** que fallan pronto y explícito: placeholder de
  `SUPublicEDKey` sin sustituir, perfil de notarización ausente en
  Keychain, `gh` no autenticado, o versión ya publicada — todas ANTES de
  gastar tiempo en build/notarización.
- **Descarga automática de las herramientas CLI de Sparkle**
  (`generate_appcast`, `sign_update`) desde el tarball de distribución
  oficial más reciente — necesario porque el paquete SPM de la app (clon
  de código fuente, Fase 12) no las trae precompiladas (hallazgo del
  research, ver `13-RESEARCH.md`).
- **Orden estricto notarizar → staplear → empaquetar final** (Pitfall 2
  del research): el `.zip` se genera dos veces, la segunda ya con el
  `.app` staplereado.
- **Histórico acumulativo** en `.build-cache/release/archive/` para que
  `generate_appcast` pueda seguir generando delta updates entre versiones.
- **Nunca ejecuta `git push`/`git commit` automáticamente** — imprime las
  instrucciones exactas al final, dejando esa acción (visible sobre un
  repo compartido) bajo control explícito del usuario.
- **Sin secretos en ningún punto** — solo referencia el nombre del perfil
  de notarización (`NOTARY_PROFILE`, configurable por variable de
  entorno); la clave EdDSA y las credenciales de notarización viven
  exclusivamente en el Keychain del Mac que ejecuta el script.

### RELEASING.md (nuevo, raíz del repo)

Documenta la configuración de una sola vez (generación de clave EdDSA,
`notarytool store-credentials`, `gh auth login`) como pasos manuales
explícitos que el script NO ejecuta, más el uso repetido del script en
cada release, verificación post-release (incluido el pitfall de caché de
`raw.githubusercontent.com`), sección de seguridad, y troubleshooting
basado en los 5 pitfalls documentados en el research (AppleDouble/`unzip`,
orden de staplear, `CURRENT_PROJECT_VERSION` no creciente, etc.).

## Verification Status — ⚠️ SIN EJECUTAR (checkpoint humano pendiente)

Este entorno sandbox no tiene macOS, Xcode, `notarytool`, `stapler`, ni
credenciales de Apple Developer/Keychain — nada de esto se puede ejecutar
ni verificar de principio a fin aquí, a diferencia de la Fase 11 (Python,
verificable con pytest en cualquier entorno). Verificado en este sandbox:

```
bash -n scripts/release-macos.sh          → sintaxis OK
grep secretos literales                    → ninguno encontrado
orden notarytool submit / stapler staple   → correcto
grep git push/commit ejecutados            → 0 (solo impresos como instrucción)
```

**Pendiente del checkpoint humano** (ver `CHECKPOINT-HUMANO.md`):
generación real de la clave EdDSA, configuración real de credenciales de
notarización, y un primer release real de principio a fin — incluida la
verificación de que una instalación anterior de la app detecta la
actualización vía Sparkle sin avisos de Gatekeeper.

## Self-Check

- [x] `scripts/release-macos.sh` sintácticamente válido
- [x] 3 validaciones previas antes de cualquier paso costoso
- [x] Orden notarizar → staplear → empaquetar final respetado
- [x] Histórico acumulativo en `.build-cache/release/archive/`
- [x] Sin secretos literales en el script ni en `RELEASING.md`
- [x] `RELEASING.md` documenta configuración de una sola vez vs uso repetido
- [ ] Ejecución real del script — **pendiente checkpoint humano**
- [ ] Verificación end-to-end de Sparkle detectando la actualización — **pendiente checkpoint humano**
