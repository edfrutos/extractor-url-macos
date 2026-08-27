---
plan: 23-01
phase: 23-verificacion-release-real
status: complete
completed: "2026-08-27"
tasks_completed: 1
tasks_total: 1
requirements_covered:
  - MAINT-01
  - MAINT-02
  - MAINT-03
  - MAINT-05
requirements_conditional:
  - MAINT-04
  - MAINT-06
---

# Summary: 23-01 — Verificación de release real y cierre de deuda técnica

Fase de mantenimiento, sin funcionalidad nueva. Ejecutada como plan
informal (sin `PLAN.md` formal) — el trabajo salió de inspeccionar el
estado real del repo tras el release `v2.1`, no de un research previo.
Los 6 Success Criteria eran verificaciones que solo podían hacerse
contra un release real; `v2.1` ya existía publicado, así que la mayor
parte se cerró verificando ese release en lugar de lanzar uno nuevo.

## Qué se hizo

### Endurecimiento del pipeline de firma/notarización (`af48439`)

Partía de 3 scripts modificados en el working tree que corregían
rechazos reales de `notarytool` de un intento previo de `v2.1`:

- **`scripts/bundle-playwright.sh` + `scripts/release-macos.sh`**: firma
  de ejecutables de Chromium **por descubrimiento**
  (`find -type f -perm -u+x`) en vez de por nombre fijo. Firmar solo
  `chrome_crashpad_handler` a mano dejaba sin hardened runtime
  `web_app_shortcut_copier`/`app_mode_loader` y cualquier otro que
  "Chrome for Testing" añada aguas arriba. Añadida también la firma de
  las instalaciones hermanas bajo `.local-browsers/`
  (`chromium_headless_shell-*`, `ffmpeg-*`) — árboles planos sin `.app`
  ni Framework — que el patrón `chromium-*` nunca cazaba.
- **`scripts/release-macos.sh`**:
  - `ditto` de empaquetado sin `--sequesterRsrc` (un `.app` moderno
    firmado no usa resource forks HFS+; con el flag, `ditto` mete un
    `__MACOSX/` en el zip que `notarytool` intenta notarizar → decenas
    de avisos de ruido).
  - Ante rechazo, se pide `xcrun notarytool log <id>` explícitamente —
    el resumen de `submit --wait` solo trae `id`/`status`, no las
    razones (el mensaje anterior decía "log completo arriba", falso).
  - `"${array[@]+"${array[@]}"}"` en las expansiones de arrays opcionales
    (`channel_args`, `rollout_args`, `gh_flags`) — bajo `set -u`, bash
    3.2 (el de macOS de serie) aborta con "unbound variable" ante un
    array vacío. Invisible en `bash -n`/shellcheck.
- **`scripts/verify-bundle.sh`**: comprueba que los ejecutables de las
  instalaciones hermanas tengan alguna firma.
- **`.gitignore`**: ignora el recurso de icono de carpeta de macOS
  (`Icon?`); se eliminó el `Icon\r` suelto del working tree.

### Fix del tagging del release (`cc1af03`)

Causa raíz del tag `v2.1` mal ubicado (apuntaba a `c662647` en vez de a
`ec071d9 chore(release): v2.1`): `release-macos.sh` **no commitea** por
diseño (deja el `git add/commit/push` como paso manual), pero
`_publish_release()` llama a `gh release create "v${VERSION}"` **antes**
de que exista el commit `chore(release)`, así que `gh` crea el tag sobre
el HEAD de `origin` previo al bump.

Arreglo (opción mínima que respeta "el script no commitea/pushea solo"):
el eco final del script ahora imprime también

```
git tag -f "vX.Y"
git push -f origin "vX.Y"
```

tras el `git commit`/`git push` manual, para reubicar el tag recién
creado en el commit del release. Documentado en `RELEASING.md` §2 y en
el comentario de cabecera del script. `bash -n` + `shellcheck -S
warning` OK.

## Verification Status — ✅ VERIFICADO (Mac real del usuario + sandbox)

### En el Mac real, contra el release público `v2.1`

- **SC1 (MAINT-01)** — `.app` Release/notarizado descomprimido de
  `ExtractorApp-2.1.zip` (~387 MB comprimido) = **882 MB** en disco,
  casi idéntico a los 886 MB del Debug local. El strip y la eliminación
  de artefactos de Debug apenas mueven la aguja porque el peso lo domina
  "Chrome for Testing" (locales de decenas de idiomas + helpers), no el
  binario propio ni los símbolos. Documentado en `RELEASING.md` §3.5.
- **SC2 (MAINT-02)** — notarización real con Chromium embebido:
  - `spctl -a -vvv --type execute` → `accepted`, `source=Notarized
    Developer ID` (Eugenio de Frutos Sanchez, V29BTBRY6G).
  - `xcrun stapler validate` → ticket grapado OK.
  - `codesign --verify --deep --strict` → `valid on disk` + `satisfies
    its Designated Requirement`.
  - Barrido de todos los Mach-O del bundle sin flag `runtime` →
    **vacío** (Chromium `chrome-headless-shell`/`ffmpeg` y ejecutables
    sueltos de `Helpers/` incluidos).
  - Conclusión: el binario público de `v2.1` es correcto — **no hubo que
    rehacerlo**. El rechazo de `notarytool` que originó `af48439` fue un
    intento previo que se arregló a mano; `af48439` deja eso automatizado.
    Residual no bloqueante: ejercitar el pipeline *scriptado* (con
    `af48439`) end-to-end en el próximo release que toque por otro motivo.
- **SC3 (MAINT-03)** — `python extractor_url.py <url> --clipboard` copia
  a `pbcopy` real (`pbpaste` devuelve el contenido extraído); combinado
  con `-o` es **aditivo** (fichero de 142 B escrito *y* portapapeles
  actualizado). Ya no solo con mocks (Fase 19).

### En sandbox (Python 3.14 Linux, venv temporal — código Python puro, platform-independent)

- `pytest tests/` → **67/67 pasan**.
- `pylint extractor_url.py core.py` → **10.00/10**.
- `mypy extractor_url.py core.py` → **Success: no issues found**.

### Limpieza de deuda

- **SC5 (MAINT-05)** — `scripts/setup-sparkle-local.sh`: ya estaba
  trackeado desde `5c3d663` (cierre de la Fase 16). La decisión efectiva
  fue "sí, commitear" y ya había ocurrido. Cerrado.
- Tag local espurio `v3.1` → `af96740` (`Añade icono de app`, junio),
  que no estaba en `origin` ni correspondía a ningún milestone:
  **borrado** (`git tag -d v3.1`).
- Tag `v2.1` mal ubicado: **decisión del usuario — dejarlo**; el release
  y su asset son correctos, no merece reescribir un tag publicado. La
  causa raíz queda arreglada para v2.2+ (ver `cc1af03`).

## Condicionales — no verificables sin lanzar un release nuevo

- **SC4 (MAINT-04)** — `<sparkle:phasedRolloutInterval>` en el
  `appcast.xml` cuando se usa `ROLLOUT_INTERVAL_SECONDS`: solo aplica si
  un release futuro activa el rollout. El mecanismo (Fase 20) no se ha
  tocado; queda por confirmar en un release real que lo use.
- **SC6 (MAINT-06)** — bug sospechado de Xcode 27.0 beta GOLD
  (corrupción de `Info.plist` con `CFBundleIdentifier` conteniendo un
  log interno de Sparkle): solo observable durante un build. No hubo
  build nuevo en esta fase, así que no se pudo confirmar ni descartar
  su reaparición. Sigue como concern a vigilar en `STATE.md`.

## Notas

- La Fase 23 se cierra con SC1/SC2/SC3/SC5 verificados y SC4/SC6
  anotados como **diferidos-condicionales** (son criterios "si/cuando un
  release futuro haga X", no bloqueos). El usuario aprobó cerrar así.
- `pbxproj` queda en `MARKETING_VERSION 2.1` / `CURRENT_PROJECT_VERSION
  10`; el próximo release sube a `2.2`+.
- Commits de la fase: `af48439`, `e2962d6`, `3b2b3d8`, `d78784c`,
  `055e7bd`, `50383d4`, `cc1af03` — todos en `origin/main`.
