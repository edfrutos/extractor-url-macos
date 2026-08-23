---
plan: 20-01
phase: 20-rollouts-sparkle
status: complete
completed: "2026-08-23"
tasks_completed: 1
tasks_total: 1
requirements_covered:
  - ROLLOUT-01
  - ROLLOUT-02
---

# Summary: 20-01 — Rollouts por fases de Sparkle

Fase pequeña, mismo patrón que `--channel` de la Fase 16 — ejecutada
directamente en conversación tras confirmar el flag real de
`generate_appcast` inspeccionando el binario ya presente en
`.build-cache/sparkle-tools/bin/generate_appcast` (evita implementar a
ciegas sobre un flag supuesto).

## Investigación previa (sin research doc separado — verificación directa)

El binario `generate_appcast` (Mach-O universal, descargado en la Fase 12)
ya estaba en el repo (`.build-cache/sparkle-tools/`, gitignored). Se
extrajeron sus strings ASCII con Python (sin `strings` disponible en el
sandbox) para confirmar el flag real antes de codificar nada a ciegas:

- Flag confirmado: `--phased-rollout-interval <segundos>` → escribe
  `<sparkle:phasedRolloutInterval>` en el item nuevo del appcast.
- Documentación oficial de Sparkle (`sparkle-project.github.io/documentation/publishing/`)
  confirma la mecánica: **7 grupos hardcodeados**, un grupo nuevo elegible
  cada `phasedRolloutInterval` segundos desde el `pubDate` del item —
  duración total del rollout = `phasedRolloutInterval × 7`. Requiere
  `pubDate` (ya lo pone `generate_appcast` siempre). **No aplica** a
  comprobaciones manuales de actualización ni a updates críticos — ambos
  ven la versión más reciente sin restricción de grupo.
- Sin mecanismo oficial documentado de monitorización/aborto de un
  rollout en marcha.

## What Was Built

### scripts/release-macos.sh

- `ROLLOUT_INTERVAL_SECONDS="${ROLLOUT_INTERVAL_SECONDS:-}"` — variable de
  entorno opcional (no un 3er argumento posicional, para no reordenar
  `<version> [canal]` ya establecido en la Fase 16).
- `_preflight_checks()`: valida que, si se especifica, sea un entero
  positivo (`^[0-9]+$`) — falla explícito si no, mismo principio de
  "fallar explícito" ya establecido en el proyecto.
- `_archive_and_generate_appcast()`: nuevo `rollout_args=()`, rellenado
  con `(--phased-rollout-interval "${ROLLOUT_INTERVAL_SECONDS}")` solo si
  no está vacío — mismo patrón exacto que `channel_args`. Sin la
  variable, `generate_appcast` se invoca exactamente igual que antes de
  esta fase (Success Criterion 1).
- Comentario de cabecera del script actualizado con el nuevo uso y un
  resumen de la mecánica (7 grupos, duración total, limitación de
  comprobación manual).

### RELEASING.md

Nueva sección "3.6. Rollout por fases (opcional)": cómo activarlo, cómo
lo reparte Sparkle (7 grupos × intervalo = duración total), la limitación
de que la comprobación manual y los updates críticos lo saltan (para que
no se confunda con un bug al probar en el propio Mac), y la forma
práctica de "abortar" un rollout en marcha — editar `appcast.xml` a mano
quitando `<sparkle:phasedRolloutInterval>` del item y commitear/pushear,
aprovechando que el appcast ya es un archivo del repo revisado a mano
desde la Fase 13 (Success Criterion 2).

## Verification Status — ✅ VERIFICADO (sandbox, sin necesitar Mac)

Todo lo de esta fase es un script bash — verificable sin Xcode/macOS:

- `bash -n scripts/release-macos.sh` — sintaxis OK.
- `shellcheck scripts/release-macos.sh` — sin avisos nuevos.
- Lógica de construcción de `channel_args`/`rollout_args` probada de
  forma aislada (las 4 combinaciones: sin canal/sin rollout, solo canal,
  solo rollout, ambos) — confirma que `generate_appcast` recibe los
  flags correctos en cada caso, y que sin `ROLLOUT_INTERVAL_SECONDS` el
  comando es idéntico al de antes de esta fase.
- Validación del entero probada con casos límite: vacío (aceptado, no
  activa rollout), `86400` (aceptado), `abc`/`-5` (rechazados), `0`
  (aceptado — un rollout de 0 segundos es una elección válida del
  usuario, aunque poco útil en la práctica, no un caso a bloquear).
- **No se ejecutó el pipeline completo real** (necesita Xcode/notarización
  real, fuera de este sandbox) — el flag `--phased-rollout-interval` en
  sí mismo no se probó contra un `generate_appcast` ejecutándose de
  verdad. Recomendado no bloqueante: la próxima vez que se publique un
  release real con `ROLLOUT_INTERVAL_SECONDS` puesto, confirmar en el
  `appcast.xml` resultante que `<sparkle:phasedRolloutInterval>` aparece
  con el valor esperado.
