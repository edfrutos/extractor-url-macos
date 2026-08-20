---
phase: 12-sparkle-integracion
type: checkpoint-humano
status: pending
created: "2026-08-19"
---

# Checkpoint Humano — Fase 12 (Integración Sparkle)

## Objetivo

Añadir el paquete SPM Sparkle (paso que solo se puede hacer desde la UI de
Xcode) y compilar/verificar el código ya escrito en este sandbox
(`ExtractorAppApp.swift`, `Views/CheckForUpdatesView.swift`, 2 claves nuevas
en `project.pbxproj`).

## Estado de partida

- Igual que en checkpoints anteriores (Fase 10): modo directo, el volumen
  `/Volumes/ESSAGER/...` es el mismo disco que ves en tu Mac — no hace falta
  sincronizar nada.
- Nada de esto está commiteado todavía.
- Archivos tocados por la Fase 12:
  - `ExtractorApp/ExtractorApp/ExtractorApp/ExtractorAppApp.swift` (modificado)
  - `ExtractorApp/ExtractorApp/ExtractorApp/Views/CheckForUpdatesView.swift` (nuevo)
  - `ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj` (2 claves nuevas, Debug + Release)

## Paso 1 — Añadir el paquete SPM Sparkle (ESTE PASO NO ESTÁ HECHO TODAVÍA)

A diferencia de fases anteriores, esta vez el código que escribí **no
compilará** hasta que hagas esto primero — `import Sparkle` no existe todavía
como dependencia del proyecto:

1. Abre `ExtractorApp.xcodeproj` en Xcode.
2. Menú `File → Add Package Dependencies…`
3. Pega la URL: `https://github.com/sparkle-project/Sparkle`
4. Deja la regla de versión por defecto que proponga Xcode ("Up to Next
   Major Version", desde la 2.x más reciente disponible) — no fijes un
   número exacto a mano.
5. En el diálogo de selección de producto, añade **"Sparkle"** al target
   **ExtractorApp** únicamente (no lo añadas a `ExtractorAppTests`).
6. Confirma. Xcode debería resolver el paquete y generar `Package.resolved`
   automáticamente (puede tardar unos segundos, necesita red).

**Repórtame:** confirma que el paquete se añadió sin errores de resolución,
y si Xcode te preguntó algo que no esperaba este checklist (permisos de
red, confianza en el paquete, etc.), cuéntamelo tal cual.

## Paso 2 — Build limpio

1. `Product → Clean Build Folder` (⇧⌘K).
2. `Product → Build` (⌘B).
3. Observa el panel de errores (`⌘5` para el Report Navigator).

**Resultado esperado:** `Build Succeeded`. Puede haber warnings — no son
bloqueantes salvo que mencionen explícitamente `Sparkle`, `SPUStandardUpdaterController`,
`CheckForUpdatesView`, o algo de concurrencia (`Sendable`, `@MainActor`) — esos sí
quiero verlos.

**Si falla:** copia el texto **exacto** del error (archivo, línea, mensaje
completo) y pégamelo. Con eso corrijo el código a ciegas y vuelves a
intentar el build. Un error plausible de primera vez: si Library Validation
bloquea la carga de `Sparkle.framework` en un build de desarrollo firmado
ad-hoc (ver Pitfall 1 en `12-RESEARCH.md`) — si ves algo sobre "Library
not loaded" o code signing al ejecutar (no al compilar), dímelo, es un caso
previsto y tiene solución conocida.

## Paso 3 — Ejecutar la app y verificar el menú

1. `Product → Run` (⌘R).
2. Abre el menú de la aplicación (junto al menú  de macOS, donde está
   "Acerca de ExtractorApp", "Preferencias…", "Salir de ExtractorApp").
3. Busca el ítem **"Buscar actualizaciones…"** — debería aparecer justo
   después de "Acerca de ExtractorApp".

**Repórtame:**
- ¿Aparece el ítem de menú en la posición esperada?
- ¿Está habilitado o deshabilitado (gris)? Ambos son resultados válidos en
  esta fase — sin un appcast real todavía (eso es la Fase 13), es posible
  que Sparkle tarde un momento en marcarlo como disponible, o que al
  pulsarlo veas un error de red/feed (esperado: `SUFeedURL` apunta a
  `https://raw.githubusercontent.com/edfrutos/extractor-url-macos/main/appcast.xml`,
  que todavía no existe como archivo en el repo).
- Si pulsas el ítem y ves algún diálogo de Sparkle (aunque sea de error),
  cuéntame qué dice — confirma que el framework está realmente cargado y
  funcionando, que es lo que esta fase necesita verificar.

## Paso 4 — Cierre (lo hago yo, no tú)

Cuando confirmes: paquete añadido sin errores + Build Succeeded + el ítem de
menú aparece (habilitado o no), yo:

1. Escribo `12-01-SUMMARY.md` con los resultados reales.
2. Actualizo `ROADMAP.md`/`STATE.md`/`PROJECT.md` marcando la Fase 12 como
   completa.
3. Empezamos la Fase 13 (pipeline de release: claves EdDSA, firma
   Developer ID, notarización, `appcast.xml` real, publicación en GitHub
   Releases) — ahí es donde `INFOPLIST_KEY_SUPublicEDKey` deja de ser un
   placeholder y el "Buscar actualizaciones…" empieza a funcionar de
   verdad.
4. Te pregunto si quieres que haga el commit, igual que en fases anteriores.

## Plan de contingencia

- **El paquete SPM no resuelve** (error de red, URL incorrecta) → verifica
  que copiaste exactamente `https://github.com/sparkle-project/Sparkle`
  sin espacios ni `.git` al final.
- **Build falla** → Paso 2, repórtame el error exacto, corrijo, repites.
- **La app no arranca / crashea al lanzar** → dime el mensaje de Console.app
  bajo el proceso ExtractorApp — Sparkle imprime ahí diagnósticos detallados
  según su propia documentación.
- **El ítem de menú no aparece en absoluto** → puede ser un problema real de
  `.commands` mal adjuntado a la Scene equivocada — dímelo, no lo descartes
  como "ya se arreglará en Fase 13", sería un bug de esta fase.
