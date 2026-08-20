---
phase: 13-release-pipeline
type: checkpoint-humano
status: pending
created: "2026-08-20"
---

# Checkpoint Humano — Fase 13 (Pipeline de release)

## Objetivo

Hacer la configuración de una sola vez (clave EdDSA, credenciales de
notarización) y ejecutar `scripts/release-macos.sh` para publicar el
**primer release real** de ExtractorApp — esto crea un tag y un release
públicos en `github.com/edfrutos/extractor-url-macos`, visibles para
cualquiera.

**Importante — a diferencia de los checkpoints de Fase 10 y Fase 12, este
no es solo "compila y verifica"**: el último paso (`gh release create`)
publica algo real y visible. Léelo entero antes de ejecutar el script.

## Estado de partida

- `scripts/release-macos.sh` y `RELEASING.md` están escritos y listos —
  ver `.planning/phases/13-release-pipeline/13-01-SUMMARY.md`.
- `INFOPLIST_KEY_SUPublicEDKey` sigue siendo el placeholder
  `"PENDIENTE-FASE-13-generate_keys"` — el script se niega a publicar
  mientras siga así (validación previa, `_preflight_checks`).
- Nada de la Fase 13 está commiteado todavía.

## Paso 1 — Configuración de una sola vez

Sigue `RELEASING.md`, sección "1. Configuración de una sola vez", completa:

1. Generar la clave EdDSA (`generate_keys` — el script la descarga la
   primera vez que lo ejecutes, o puedes hacerlo antes a mano si
   prefieres verificar el flujo por partes).
2. Sustituir el placeholder de `SUPublicEDKey` en `project.pbxproj` (2
   sitios: Debug y Release) por la clave pública real.
3. `xcrun notarytool store-credentials "ExtractorApp-Notary" ...`
4. Confirmar `gh auth status`.

**Repórtame:** confirma que completaste los 3 pasos. Si algo fue distinto
de lo esperado (`generate_keys` no apareció donde tocaba, `notarytool`
pidió algo raro, etc.), cuéntamelo antes de seguir.

## Paso 2 — Decidir la versión

La app está en `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1`
(sin publicar nunca). Para el primer release real, lo natural es
`scripts/release-macos.sh 1.0` (mantener 1.0 como primera versión pública)
o `1.1` si prefieres marcar que es la primera versión "con auto-update"
como un hito propio — tu decisión, ninguna es incorrecta.

**Pregúntame si tienes dudas antes de decidir**, o dime directamente qué
versión vas a usar.

## Paso 3 — Ejecutar el release

```bash
cd "/Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url"
scripts/release-macos.sh <la_version_que_decidiste>
```

Esto va a tardar varios minutos (el paso de notarización en particular
puede tardar 1-15 minutos dependiendo de la cola de Apple). El script
imprime progreso en cada etapa.

**Si falla en cualquier punto**, copia el error exacto y pégamelo — el
script está diseñado para fallar explícito y pronto (antes de gastar
tiempo en build/notarización) si algo de la configuración previa no está
bien, así que un fallo temprano probablemente señala algo del Paso 1.

**Si notarytool devuelve `Invalid`** en vez de `Accepted`, pégame el log
completo que imprime — no es necesariamente un fallo del script, puede ser
un problema real de firma que hay que diagnosticar.

## Paso 4 — Revisar antes de publicar el feed

Cuando el script termine con éxito, imprime un resumen con:
- La URL del release ya publicado en GitHub.
- El `git add`/`commit`/`push` exacto para publicar `appcast.xml`.

**Antes de ejecutar ese `git push`**: abre la URL del release en un
navegador y confirma que el `.zip` subido tiene buena pinta (tamaño
razonable, no vacío). El release en sí ya está público en ese punto — el
`push` del appcast es lo que hace que las instalaciones existentes de la
app (si las hay) empiecen a verlo como una actualización disponible.

**Repórtame:** pégame el resumen final que imprime el script, y confirma
si quieres que yo mismo haga el `git push` del appcast (con tu
confirmación explícita aquí, como con cualquier otro push de este repo) o
prefieres hacerlo tú directamente en tu terminal.

## Paso 5 — Verificación end-to-end (opcional pero recomendado)

Si tienes a mano una copia de la app ya instalada con una versión anterior
(por ejemplo, la que compilaste en el checkpoint de la Fase 12, todavía
sin la clave EdDSA real — probablemente haga falta un build nuevo con la
clave ya puesta para que esto funcione de verdad), ábrela y pulsa "Buscar
actualizaciones…" — confirma que detecta la versión publicada, la
descarga, y se instala sin avisos de Gatekeeper.

**Repórtame** qué tal fue esa prueba — es la confirmación final de que
todo el pipeline (Fase 12 + Fase 13) funciona de principio a fin tal y
como se diseñó.

## Cierre (lo hago yo, no tú)

Cuando confirmes que el release se publicó y (si lo probaste) que Sparkle
detectó la actualización, yo:

1. Escribo el resultado real en `13-01-SUMMARY.md`.
2. Marco la Fase 13 y el milestone v5.0 como completos en
   `ROADMAP.md`/`STATE.md`/`PROJECT.md`/`REQUIREMENTS.md`/`MILESTONES.md`.
3. Te pregunto si quieres que haga el commit de todo lo demás pendiente
   (documentación de planning, etc. — el `appcast.xml`/`project.pbxproj`
   del release en sí ya lo habrás commiteado tú en el Paso 4).

## Plan de contingencia

- **`generate_keys` no aparece / el tarball de Sparkle no se descarga** →
  puede que `gh api repos/sparkle-project/Sparkle/releases/latest` esté
  fallando por algo específico de tu red (recuerda el bug de búsqueda de
  paquetes de Xcode de la Fase 12 — si algo similar afecta a `gh`/`curl`
  aquí, dímelo con el error exacto).
- **Notarización rechazada (`Invalid`)** → pégame el log completo, casi
  siempre apunta a un componente concreto sin firmar correctamente.
- **El release se publicó pero quieres deshacerlo** → `gh release delete
  "v<version>" --repo edfrutos/extractor-url-macos` borra el release de
  GitHub (pregúntame si quieres que lo haga yo, es una acción destructiva
  sobre algo público). El tag de git puede quedar huérfano — decide con
  calma, no hay prisa por limpiar esto a medias.
- **Quieres probar el pipeline sin publicar nada real todavía** → dímelo
  antes de ejecutar el script; podemos hablar de si tiene sentido un
  "dry run" (comentar temporalmente el paso `gh release create` para
  probar solo build+firma+notarización) antes del primer release real.
