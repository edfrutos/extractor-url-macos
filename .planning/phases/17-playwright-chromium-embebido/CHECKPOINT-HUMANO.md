---
phase: 17-playwright-chromium-embebido
type: checkpoint-humano
status: done
created: "2026-08-21"
completed: "2026-08-22"
---

**COMPLETADO 2026-08-22** — ver `17-01-SUMMARY.md` para el detalle completo
(build succeeded, `verify-bundle.sh` 19 OK/0 FAIL, extracción real de SPA
confirmada, dos bugs reales encontrados y corregidos en el proceso, Paso 6
omitido deliberadamente). Este archivo queda como referencia histórica de
los pasos seguidos.

# Checkpoint Humano — Fase 17 (Playwright/Chromium embebido)

## Objetivo

Compilar el bundle con Chromium vendorizado (una sola arquitectura — la
nativa de tu Mac, normalmente arm64), confirmar que `verify-bundle.sh` pasa
en verde (BUNDLEJS-01/02), y probar una extracción real de una SPA vía el
fallback JS embebido — sin que tengas `playwright install chromium`
instalado a nivel de sistema, para confirmar que el bundle es realmente
autocontenido.

## Estado de partida

- `scripts/bundle-python.sh`: vendoriza también el paquete `playwright==1.62.0` (llamada `pip install` separada, sin `--platform universal2`).
- `scripts/bundle-playwright.sh` (nuevo): instala Chromium (una pasada, arquitectura nativa) con `PLAYWRIGHT_BROWSERS_PATH=0`, y lo firma bottom-up (Helpers Renderer/GPU con `allow-jit` vía `scripts/chromium-helper-jit.entitlements` → `crashpad_handler` → Framework → `Chromium.app`).
- `ExtractorApp.xcodeproj/project.pbxproj`: nueva Run Script Build Phase "Bundle Playwright Chromium", después de "Bundle Python Runtime" — editada como texto en este sandbox (sin Xcode para verificarla); balance de llaves/paréntesis comprobado, pero la validación real es que Xcode abra el proyecto sin queja.
- `scripts/verify-bundle.sh`: extendido con BUNDLEJS-01 (árbol único, firma válida, `allow-jit` en el Helper Renderer) y BUNDLEJS-02 (extracción real de `example.com` vía Chromium embebido).
- `scripts/release-macos.sh`: nueva `_resign_bundled_chromium()`, llamada tras `_resign_bundled_python` y antes de `_notarize_and_staple` — reutiliza la misma identidad Developer ID ya extraída.
- `PythonBridge.swift`: `case .bundle:` inyecta `PLAYWRIGHT_BROWSERS_PATH=0` junto a `PYTHONPATH`.
- `RELEASING.md`: nueva sección "3.5. Chromium embebido" documentando alcance, tamaño e impacto en notarización.
- Nada de esto está commiteado todavía.

## Paso 1 — Abrir el proyecto y confirmar que Xcode acepta el `.pbxproj` editado

1. Abre `ExtractorApp.xcodeproj` en Xcode.
2. Si Xcode lo abre sin ningún diálogo de "The project ... cannot be opened because it is damaged" o similar, la edición del `.pbxproj` es válida — puedes pasar al Paso 2.
3. Ve a la pestaña **Build Phases** del target `ExtractorApp` y confirma que aparecen, en este orden: "Bundle Python Runtime" y, justo después, **"Bundle Playwright Chromium"**.

**Si Xcode se queja de proyecto corrupto:** copia el error exacto y pégamelo — es probable que sea un desajuste sutil de sintaxis en el bloque que añadí a mano (sin Xcode para generarlo, edité el `.pbxproj` como texto). Puedo corregirlo con el error concreto.

## Paso 2 — Build

1. `Product → Clean Build Folder` (⇧⌘K).
2. `Product → Build` (⌘B).

**Ten en cuenta:** esta build va a **descargar Chromium de verdad** (~130-165MB comprimidos) la primera vez, y puede tardar bastante más que un build normal. Necesitas conexión a internet.

**Resultado esperado:** `Build Succeeded`.

**Si falla en la Run Script Phase "Bundle Playwright Chromium":** revisa el log de esa fase en el panel de Report Navigator (⌘9) — el script falla explícito con un mensaje claro si el Python bundleado no existe o si no aparece ningún `chromium-*` tras la instalación. Pégame el mensaje exacto.

## Paso 3 — Verificar el bundle con `verify-bundle.sh`

Con el build ya hecho (no necesitas archivar, solo compilar):

```bash
cd /Volumes/ESSAGER/__01.-Proyectos/__Herramientas_Desktop/extractor-url
./scripts/verify-bundle.sh
```

**Resultado esperado:** todas las líneas `OK`, incluidas las nuevas
`BUNDLEJS-01`/`BUNDLEJS-02` — en particular la línea final
"Chromium embebido renderiza example.com correctamente".

**Repórtame:** el resumen final (`X OK | Y FAIL`) y, si hay algún `FAIL`,
cópiame la línea completa.

## Paso 4 — Prueba real: una SPA sin Playwright instalado en el sistema

Este es el paso que confirma de verdad BUNDLEJS-02 con el flujo real de la
app (no solo el script de verificación):

1. Si tienes Playwright instalado a nivel de sistema/en tu `.venv` de
   desarrollo, no hace falta desinstalarlo — la app usa el binario
   bundleado, no el del sistema, mientras no hayas configurado rutas
   manuales en Preferencias (`pythonPath`/`scriptPath` vacíos = usa el
   bundle).
2. Ejecuta la app (⌘R) y extrae una URL que sepas que es una SPA sin
   hidratar (algo con mucho contenido renderizado por JavaScript — si no
   tienes una a mano, dime y te sugiero una URL de prueba conocida).
3. Confirma que el contenido extraído es el renderizado real (no una página
   casi vacía como devolvería el HTML estático de una SPA sin JS).

**Repórtame:** ¿la extracción devolvió contenido con sentido, o quedó vacía/parcial?

## Paso 5 — (Opcional, no bloqueante) Medir el tamaño real del `.app`

```bash
du -sh $(find ~/Library/Developer/Xcode/DerivedData -name "ExtractorApp.app" -not -path "*/Index.noindex/*" 2>/dev/null | head -1)
```

Pégame la cifra — la necesito para el summary de esta fase (Success
Criteria 5 del plan pide medir, no solo estimar).

## Paso 6 — (Opcional, más costoso — solo si quieres verificar notarización real)

Este paso NO es necesario para cerrar la Fase 17 — usa cuota real de
notarización y, si lo completas hasta el final, publica un asset en GitHub
Releases. Solo hazlo si quieres verificar `_resign_bundled_chromium()` con
un release de verdad:

```bash
scripts/release-macos.sh <version-de-prueba>
```

Si prefieres no gastar esa cuota ahora, lo dejamos para el próximo release
real de la app — `_resign_bundled_chromium()` sigue exactamente el mismo
patrón ya verificado de `_resign_bundled_python()` en la Fase 13, así que el
riesgo de que falle específicamente por Chromium (vs. por algo ya cubierto)
es bajo.

## Paso 7 — Cierre (lo hago yo, no tú)

Cuando confirmes Build Succeeded + `verify-bundle.sh` en verde + extracción
real de una SPA, yo:

1. Escribo `17-01-SUMMARY.md` con los resultados reales (incluida la cifra
   de tamaño del Paso 5).
2. Marco la Fase 17 completa (BUNDLEJS-01, BUNDLEJS-02 validados) en
   ROADMAP.md/STATE.md/PROJECT.md/REQUIREMENTS.md.
3. Te pregunto si quieres commitear/pushear, y si seguimos con la Fase 18
   (pulido técnico — la última de v6.0).

## Plan de contingencia

- **Xcode dice que el proyecto está corrupto** → ver Paso 1, probablemente
  un desajuste de sintaxis en la edición manual del `.pbxproj` — pégame el
  error exacto.
- **La Run Script Phase falla descargando Chromium** → revisa conexión a
  internet; si el error es de `cdn.playwright.dev` inaccesible, puede ser un
  problema de red puntual, reintenta el build.
- **`verify-bundle.sh` falla en BUNDLEJS-01 (firma inválida)** → probable
  que `EXPANDED_CODE_SIGN_IDENTITY` no esté definido en tu build local (ad-hoc,
  `-`) — normal en un build de desarrollo sin archivar; la firma real con
  Developer ID solo se aplica en `scripts/release-macos.sh` vía
  `_resign_bundled_chromium()`. Si en cambio SÍ tienes una identidad Developer
  ID configurada para builds locales y aun así falla, pégame el output
  completo de `codesign --verify --deep --strict` sobre `Chromium.app`.
- **`verify-bundle.sh` falla en BUNDLEJS-02 (extracción no renderiza)** →
  probable causa: `allow-jit` no se aplicó al Helper Renderer (revisa con
  `codesign -d --entitlements - "Chromium Helper (Renderer).app"` si tienes
  a mano la ruta) — pégame el output completo del error de Playwright.
