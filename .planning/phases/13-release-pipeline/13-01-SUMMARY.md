---
plan: 13-01
phase: 13-release-pipeline
status: complete
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

## Verification Status — ✅ VERIFICADO (checkpoint humano 2026-08-20)

Primer release real completado de principio a fin:
`https://github.com/edfrutos/extractor-url-macos/releases/tag/v1.0`, con
`appcast.xml` publicado y firmado, confirmado en vivo vía
`curl https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml`
(devuelve el XML con `sparkle:edSignature` correcto sobre el enclosure).

### Bugs reales encontrados y corregidos durante el checkpoint

1. **Bootstrap roto**: `_preflight_checks` exigía la clave real ANTES de
   que `_ensure_sparkle_tools` descargara `generate_keys` — imposible
   arrancar desde cero. Corregido reordenando el `Main` del script
   (`_ensure_sparkle_tools` primero).
2. **`error: exportArchive No Team Found in Archive`** — faltaba `teamID`
   en `exportOptions.plist`. Añadido `DEVELOPER_TEAM_ID` (con el Team ID
   real del usuario, `V29BTBRY6G`, como default del script) inyectado en
   el plist.
3. **Notarización rechazada**: `Contents/Resources/python/bin/python3.13`
   (runtime embebido de la Fase 8) sin hardened runtime — el firmado
   final de `xcodebuild -exportArchive` no lo aplica a binarios sueltos
   fuera del grafo de frameworks de Xcode. Añadida `_resign_bundled_python()`:
   re-firma bottom-up (`.so` → `.dylib` → `python3.13`) con
   `--timestamp --options runtime` usando la identidad Developer ID real
   (extraída del `.app` ya exportado, no asumida), y re-sella el `.app`
   completo con `--deep` tras modificar contenido interno.
   - Bug menor en la extracción de esa identidad: primer intento con
     `awk -F'"'` fallaba porque `codesign -dv` no encierra la identidad
     entre comillas; segundo intento con `sed` fallaba porque faltaba
     `--verbose=4` (sin él, `codesign -dv` sobre un `.app` no imprime la
     línea `Authority=` en absoluto, a diferencia de un binario suelto).
4. **`generate_appcast` no añadía `sparkle:edSignature` al enclosure**,
   pese a que `sign_update` (mismos valores por defecto de cuenta de
   Keychain, `ed25519`) firma correctamente en aislamiento. Se descartaron
   como causa: caché de `~/Library/Caches/Sparkle_generate_appcast`,
   reutilización de un `appcast.xml` previo en el directorio de archivos,
   y discrepancia de `--account`. Causa raíz no determinada. Fix aplicado:
   el script ahora firma explícitamente con `sign_update` y si
   `generate_appcast` no incluyó la firma, la inyecta en el XML por
   post-procesado (`sed` dirigido a la línea del `<enclosure>` de esa
   versión).

### Efecto colateral menor (no bloqueante)

`_bump_version` usa `sed` sin acotar a los bloques del target
`ExtractorApp` — de rebote también subió `CURRENT_PROJECT_VERSION` del
target `ExtractorAppTests` (de 1 a 6). Inofensivo (ese número no se usa
para nada en el target de tests), pendiente de pulir en una futura
revisión si se quiere evitar el ruido en el diff.

### Verificación estructural (sandbox, previa al checkpoint)

```
bash -n scripts/release-macos.sh          → sintaxis OK
grep secretos literales                    → ninguno encontrado
orden notarytool submit / stapler staple   → correcto
grep git push/commit ejecutados            → 0 (solo impresos como instrucción)
```

## Self-Check

- [x] `scripts/release-macos.sh` sintácticamente válido
- [x] 3 validaciones previas antes de cualquier paso costoso
- [x] Orden notarizar → staplear → empaquetar final respetado
- [x] Histórico acumulativo en `.build-cache/release/archive/`
- [x] Sin secretos literales en el script ni en `RELEASING.md`
- [x] `RELEASING.md` documenta configuración de una sola vez vs uso repetido
- [x] Ejecución real del script — release v1.0 publicado con éxito
- [x] `appcast.xml` publicado y verificado en vivo con la firma EdDSA correcta
- [ ] Verificación end-to-end de una instalación anterior detectando la actualización vía Sparkle — no probado (no había un build antiguo con clave real disponible para la prueba; el pipeline en sí ya quedó demostrado funcional de principio a fin)
