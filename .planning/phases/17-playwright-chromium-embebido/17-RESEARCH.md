# Phase 17: Playwright/Chromium embebido en el bundle - Research

**Researched:** 2026-08-21
**Domain:** macOS app bundle, Playwright browser binaries, Chromium codesigning, hardened runtime, notarización
**Confidence:** MEDIUM-HIGH (verificado contra el código fuente real de Chromium y el pipeline real del proyecto; tamaño final del bundle y lista exacta de helpers requieren confirmación en Mac real durante el plan de ejecución)

---

## Summary

Esta fase extiende el patrón ya establecido en la Fase 8 (bundling de Python) para
vendorizar Playwright + Chromium dentro de `ExtractorApp.app`, de modo que
`_fetch_via_playwright()` (`core.py:225-252`) funcione en cualquier Mac sin que
el usuario ejecute `pip install playwright` ni `playwright install chromium`
(hoy documentado como paso manual en `CLAUDE.md`).

**Hallazgo crítico — el Chromium de Playwright para macOS NO viene firmado.**
Confirmado en `microsoft/playwright#10642` y `#7937`: los binarios que descarga
`playwright install chromium` en macOS llegan sin firma de código alguna (ni
ad-hoc ni Developer ID de Google). Esto es en realidad una ventaja para esta
fase — no hay que lidiar con "ya está firmado, hay que quitar la firma antes de
re-firmar" (el problema real que sí sufren proyectos que embeben Electron con
Chromium ya firmado por otro certificado). Se firma desde cero, igual que ya
se hace con el runtime Python de la Fase 8.

**Hallazgo crítico — no existe build universal2 de Chromium.** Al contrario que
Python (que si tiene wheels/tarballs `universal2` fusionables con `lipo`),
Playwright distribue Chromium como dos paquetes completamente separados
(`chromium-mac-arm64` y `chromium-mac`/x64), cada uno una `Chromium.app`
completa con su propio `Contents/Frameworks/Chromium Framework.framework/`
(binarios, recursos, `.pak`, ICU data, etc.). **No se recomienda intentar un
`lipo -create` sobre el árbol de Chromium** (a diferencia de Python en la Fase
8) — el framework de Chromium no es solo binarios Mach-O sencillos, sino un
grafo grande de recursos, `.pak`, Info.plist anidados y quirks de layout
propios; fusionar dos instalaciones completas con lipo no es un patrón
documentado ni usado por ningún proyecto real encontrado en esta research (a
diferencia de lipomerge para Python, que sí es una herramienta madura para
ese caso concreto). La alternativa recomendada es vendorizar **ambos árboles
completos, uno junto al otro** (`chromium-arm64/` y `chromium-x64/`), y que
`PythonBridge.swift`/`core.py` seleccionen la carpeta correcta según
`ProcessInfo`/`platform.machine()` en tiempo de ejecución — mismo principio
que ya usa la app para universal binary (Fase 7), pero a nivel de directorio
en vez de a nivel de arquitectura Mach-O fusionada.

**Impacto en el tamaño estimado.** El ROADMAP.md fija "~300MB+" como cifra de
referencia (Success Criteria 4). Con la estrategia de dos árboles completos
(no fusionados), la cifra real sería más alta: cada `chromium-mac(-arm64).zip`
descargado por Playwright ronda 130-165 MB comprimido (variando por versión;
[VERIFIED contra varios releases de Playwright, ver Sources]), lo que
descomprimido suele rondar 250-350 MB por arquitectura — 500-700 MB si se
vendorizan ambas.

**Decisión del usuario (post-research): reducción de alcance a un solo
árbol.** Presentado este hallazgo, el usuario ha decidido vendorizar
**únicamente la arquitectura nativa del Mac de build** (no dos árboles
arm64+x64) — descartando explícitamente el Pattern 1 original (instalación
doble vía Rosetta 2) de esta research. Esto:

- Reduce el tamaño real a **250-350 MB** (un solo árbol), mucho más cerca de
  la cifra de referencia del ROADMAP que la alternativa dual-arch.
- Elimina la dependencia de Rosetta 2 en el Mac de build (Assumption A2 de
  este research queda sin efecto — no aplica).
- **Trade-off aceptado explícitamente**: en un Mac de arquitectura distinta a
  la del Mac de build (ej. build en Apple Silicon, ejecución en un Intel Mac
  real), el fallback JS embebido simplemente no estará disponible —
  `_fetch_via_playwright()` (`core.py:225-252`) ya captura `PlaywrightError`
  y degrada a `None` → HTML estático, el mismo comportamiento que existe hoy
  cuando Playwright no está instalado en absoluto. No es una regresión de
  robustez, es la misma ruta de fallback ya probada desde la Fase 11, solo
  que activada por un motivo distinto (arquitectura no coincide) en vez de
  "Playwright no instalado".
- Success Criteria 1 del ROADMAP ("universal, o con la estrategia de
  arquitectura que corresponda según lo que ofrezca Playwright") ya admitía
  esta alternativa sin necesitar reabrir el ROADMAP — solo se actualiza aquí
  la sección de Architecture Patterns/Assumptions Log más abajo para reflejar
  la estrategia real a implementar.

Los Patterns 1/2/3 de esta research más abajo quedan simplificados en
consecuencia (un solo árbol, sin doble pasada Rosetta ni lógica de selección
de arquitectura en runtime).

**Recomendación de arquitectura de firma:** extender el mismo patrón bottom-up
ya usado en `bundle-python.sh`/`_resign_bundled_python()` de
`scripts/release-macos.sh` (firma `.so`/`.dylib`/ejecutable en ese orden, más
un re-firmado final tras el export de Xcode porque `xcodebuild -exportArchive`
no aplica `--options runtime` a binarios sueltos en Resources). Para Chromium
esto se traduce en: firmar cada `Chromium Helper*.app` (de dentro hacia
fuera: ejecutable → bundle `.app`), luego `Chromium Framework.framework`
completo, luego `Chromium.app` en sí — con `helper-renderer-entitlements.plist`
(`com.apple.security.cs.allow-jit`) para el/los helper(s) Renderer y GPU, y
**sin** entitlements adicionales para el resto (el `app-entitlements.plist`
real de Chromium trae entitlements de App Sandbox — cámara, Bluetooth, USB,
ubicación — que no aplican aquí porque `ExtractorApp` tiene App Sandbox
desactivado, ver Assumptions Log).

---

## User Constraints (from PROJECT.md / ROADMAP.md)

### Locked Decisions (desde v6.0/ROADMAP.md)

- Vendorizar Chromium dentro del bundle es el objetivo fijado — la alternativa
  de detectar un Chrome/Chromium ya instalado en el sistema del usuario está
  descartada por el propio ROADMAP (Success Criteria 1: "el pipeline de
  bundling descarga y vendoriza Chromium... de forma que el fallback JS
  funciona sin que el usuario instale nada por separado").
- Reutiliza el patrón de bundling de la Fase 8 y el patrón de
  firma/notarización de la Fase 13 — no reinventa ninguno de los dos desde
  cero (decisión v6.0 en `STATE.md`).
- Todos los binarios internos relevantes de Chromium deben quedar firmados
  con Developer ID + hardened runtime — el `.app` debe seguir siendo
  notarizable (Success Criteria 2).
- El incremento de tamaño del bundle debe quedar documentado y aceptado
  explícitamente, no es un límite duro (Success Criteria 4).
- Orden fijado por el usuario: Fase 17 va después de la 16, antes de la 18.
- **Aviso de alcance explícito en ROADMAP.md**: esta fase es "sustancialmente
  más grande que el resto" — tratarla como su propio sub-ciclo de
  research/plan/checkpoint, no asumir la misma velocidad que las Fases 14-16.
- **[Decisión post-research, confirmada por el usuario]**: vendorizar
  únicamente la arquitectura nativa del Mac de build (un solo árbol
  Chromium), no arm64+x64. Trade-off aceptado explícitamente: en la
  arquitectura no nativa, el fallback JS embebido no está disponible y
  degrada a HTML estático (mismo comportamiento que Playwright no instalado,
  ya cubierto por `_fetch_via_playwright()` desde la Fase 11). Ver Summary.

### Claude's Discretion

- Estrategia exacta de arquitectura (universal fusionado vs. dos árboles
  separados) — resuelta en este research: dos árboles separados,
  seleccionados en runtime (ver Summary y Architecture Patterns).
- Versión exacta de Playwright a pinnear en el bundle.
- Nombre/ubicación exacta del script de bundling (extender
  `bundle-python.sh` vs. script nuevo `bundle-playwright.sh`) — resuelto en
  este research: script nuevo, invocado como una Run Script Phase adicional
  (ver Architecture Patterns), para no acoplar dos dominios de build
  (runtime Python vs. browser binario) en un único script cada vez más
  largo — mismo principio de separación que ya existe entre
  `bundle-python.sh` y `release-macos.sh`.
- Variable de entorno exacta para que `core.py` encuentre el Chromium
  bundleado (`PLAYWRIGHT_BROWSERS_PATH`) — resuelta: `PLAYWRIGHT_BROWSERS_PATH=0`
  en tiempo de build (para que `playwright install chromium` deje los
  binarios dentro del propio paquete `playwright` vendorizado, sin ruta
  absoluta hardcodeada) + el mismo valor `"0"` inyectado por
  `PythonBridge.swift` en tiempo de ejecución (mismo patrón que ya existe
  para `PYTHONPATH`).

### Deferred Ideas (OUT OF SCOPE — Fase 17)

- Firefox/WebKit vendorizados — el proyecto solo usa `p.chromium.launch()`
  (`core.py:240`), no hay necesidad de vendorizar los otros dos motores que
  trae Playwright por defecto.
- Actualización automática del runtime Chromium embebido — ya diferido
  explícitamente a v7+ en `PROJECT.md` ("Actualización automática del
  runtime Python bundleado", mismo principio aplica aquí: la versión queda
  fija hasta el siguiente ciclo de build de la app).
- Notarización para distribución pública (App Store, web pública a
  terceros) — sigue fuera de alcance de todo v6.0 (ya en Out of Scope del
  milestone), esta fase no lo cambia.
- Detectar un navegador del sistema como fallback si el embebido falla —
  no es parte del objetivo fijado (ver Locked Decisions); el fallback
  actual (degradar a HTML estático sin Playwright, `_fetch_via_playwright()`
  devuelve `None`) ya cubre el caso de que Chromium no esté disponible por
  cualquier motivo, sin necesidad de una ruta adicional de detección.

---

## Standard Stack

### Core

| Componente | Versión (a confirmar en plan) | Propósito | Por qué este |
|------------|-------------------------------|-----------|--------------|
| playwright (PyPI) | pinnear última estable al implementar (≥1.55, ver Sources) | Driver que descarga/lanza Chromium | Ya es la dependencia usada por `core.py`; sin alternativa a evaluar, ya está en producción desde la Fase 11 |
| Chromium (via `playwright install chromium`) | La que fije la versión de `playwright` pinneada | Motor de renderizado headless | Descargado automáticamente por el CLI de Playwright, versión atada 1:1 a la versión del paquete `playwright` — no se pinnea por separado |
| `PLAYWRIGHT_BROWSERS_PATH=0` | — (sentinel, no una versión) | Controla dónde `playwright install`/el runtime buscan los binarios | Mecanismo oficial documentado de Playwright para bundling — mantiene los binarios dentro del árbol del propio paquete `playwright`, mismo patrón que `pip install --target` ya usa la Fase 8 [VERIFIED: playwright.dev/python/docs/browsers] |

### Alternatives Considered

| En lugar de | Podría usarse | Tradeoff |
|-------------|---------------|----------|
| Vendorizar Chromium completo (decisión fijada) | Detectar Chrome/Chromium instalado en el sistema del usuario | Descartado por el ROADMAP — además, no es fiable (el usuario puede no tener ningún Chromium-based browser instalado; el propósito de la fase es "cero dependencias externas", igual que la Fase 8 hizo con Python) |
| Dos árboles Chromium completos, uno por arquitectura | `lipo -create` sobre el árbol completo de Chromium | Sin herramienta madura equivalente a `lipomerge` para el grafo completo de un `.app` de Chromium (recursos `.pak`, ICU data, Info.plist anidados); alto riesgo de binarios corruptos o firma inválida sin beneficio claro sobre simplemente incluir ambos árboles y seleccionar en runtime |
| `PLAYWRIGHT_BROWSERS_PATH=0` (ruta relativa al paquete) | Ruta absoluta custom (ej. `Contents/Resources/chromium/`) | Ambas son válidas y documentadas oficialmente; `=0` se prefiere porque mantiene el browser "dentro" del árbol `python-packages/playwright/` ya vendorizado por la Fase 8, sin inventar una convención de ruta nueva ni duplicar la lógica de resolución de rutas que `PythonBridge.swift` ya tiene para `python-packages` |

---

## Package Legitimacy Audit

> No se añade ninguna dependencia Python nueva — `playwright` ya está en
> producción desde la Fase 11 (v4.0), auditado entonces. Esta fase solo
> cambia CUÁNDO/CÓMO se instalan sus binarios de Chromium (build time,
> vendorizados) en vez de un paso manual del usuario.

| Package | Registry | Estado | Disposición |
|---------|----------|--------|-------------|
| playwright | PyPI | Ya en uso desde Fase 11, sin incidencias | Aprobado — sin cambios de superficie de dependencia, solo de empaquetado |
| Chromium (binario, no paquete PyPI) | Descargado por el CLI de `playwright install` desde el CDN oficial de Microsoft (`cdn.playwright.dev`) | Binario de terceros (proyecto open-source Chromium, redistribuido por Microsoft) sin firma de Apple | Aceptado — mismo modelo de confianza que python-build-standalone en la Fase 8 (binario de terceros descargado y luego firmado localmente por el propio pipeline del proyecto, no por el proveedor upstream) |

---

## Architecture Patterns

### System Architecture Diagram

```
                    ┌───────────────────────────────────────────────────────────┐
                    │            BUILD TIME (Xcode Run Script, nuevo)          │
                    │                                                           │
  cdn.playwright.dev─┤→ python -m playwright install chromium                 │
                    │  (con PLAYWRIGHT_BROWSERS_PATH=0 y el python bundleado   │
                    │   de la Fase 8; UN SOLO árbol, arquitectura nativa del   │
                    │   Mac de build — decisión de alcance del usuario, ver    │
                    │   Summary. Sin pasada x64/Rosetta.)                      │
                    │                                                           │
                    │→ árbol único en:                                         │
                    │  .../python-packages/playwright/driver/package/          │
                    │      .local-browsers/chromium-<rev>/                     │
                    │                                                           │
                    │  ┌── codesign bottom-up (un único árbol) ──────────────┐  │
                    │  │ 1. Chromium Helper*.app (ejecutable → bundle)      │  │
                    │  │    - Helper (Renderer): allow-jit                 │  │
                    │  │    - Helper (GPU): allow-jit                      │  │
                    │  │    - Helper / Helper (Alerts): sin extra          │  │
                    │  │ 2. crashpad_handler (ejecutable suelto)            │  │
                    │  │ 3. Chromium Framework.framework (bundle completo) │  │
                    │  │ 4. Chromium.app (ejecutable → bundle final)        │  │
                    │  └─────────────────────────────────────────────────────┘  │
                    └───────────────────────────────────────────────────────────┘
                                             │
                                             ↓
                    ┌───────────────────────────────────────────────────────────┐
                    │               RUNTIME (ExtractorApp.app)                  │
                    │                                                           │
                    │  PythonBridge.swift                                       │
                    │    env["PLAYWRIGHT_BROWSERS_PATH"] = "0"  (bundle mode)   │
                    │    (mismo bloque switch paths.source que ya inyecta       │
                    │     PYTHONPATH para el caso .bundle)                      │
                    │                                                           │
                    │  core.py: _fetch_via_playwright()                         │
                    │    sync_playwright() → p.chromium.launch()                │
                    │    Playwright resuelve el árbol correcto                  │
                    │    (arm64 o x64) automáticamente vía                      │
                    │    PLAYWRIGHT_BROWSERS_PATH=0 + arquitectura del propio   │
                    │    intérprete Python que lo invoca (ya universal,         │
                    │    Fase 8) — sin lógica adicional en core.py              │
                    └───────────────────────────────────────────────────────────┘
```

**Nota sobre alcance (revisado tras decisión del usuario)**: a diferencia de
Python (donde `lipo` fusiona dos tarballs en un build universal), aquí no hay
fusión posible ni necesaria — con la reducción de alcance a un solo árbol,
`playwright install chromium` se ejecuta una única vez, con la arquitectura
nativa del Mac de build (normalmente arm64 en Apple Silicon). Sin Rosetta 2,
sin doble pasada, sin lógica de selección de árbol en runtime.

### Recommended Project Structure

```
ExtractorApp/ExtractorApp/
├── ExtractorApp/
│   └── Services/PythonBridge.swift   # añadir bloque PLAYWRIGHT_BROWSERS_PATH
│
└── (Xcode project: nueva Run Script Build Phase)
    └── invoca scripts/bundle-playwright.sh

# En el repo raíz:
scripts/
├── bundle-python.sh          # sin cambios (Fase 8)
├── bundle-playwright.sh      # NUEVO — descarga, coloca y firma Chromium
└── verify-bundle.sh          # extender con BUNDLEJS-01/02 (ver Estrategia de Verificación)
```

### Pattern 1: Instalar Chromium con ruta controlada (`PLAYWRIGHT_BROWSERS_PATH=0`)

**Qué hace:** Fuerza a Playwright a instalar/buscar los binarios de Chromium
dentro del propio árbol del paquete `playwright` (`.local-browsers/`) en vez
de `~/Library/Caches/ms-playwright/` (ruta por-usuario, no reproducible ni
embebible en un bundle).

**Cuándo usar:** Siempre que se quiera un bundle autocontenido — es el patrón
oficial documentado para "zipping a deployment artifact" [VERIFIED:
playwright.dev/python/docs/browsers].

**Ejemplo — fragmento de `scripts/bundle-playwright.sh` (nuevo):**
```bash
#!/usr/bin/env bash
# bundle-playwright.sh — Descarga y firma Chromium (Playwright) para ExtractorApp
set -euo pipefail

RESOURCES="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
BUNDLED_PYTHON="${RESOURCES}/python/bin/python3.13"
VENDORED_LIB="${RESOURCES}/python/lib/python-packages"

# Playwright debe estar vendorizado como dep más (bundle-python.sh lo instala
# junto a requests/bs4/lxml/etc. — ver Task de actualización de esa lista).
export PYTHONPATH="${VENDORED_LIB}"
export PLAYWRIGHT_BROWSERS_PATH=0   # binarios dentro de playwright/driver/package/.local-browsers/

echo "Instalando Chromium (arquitectura nativa del Mac de build)..."
"${BUNDLED_PYTHON}" -m playwright install chromium
```

**Nota (alcance reducido, decisión del usuario):** una única pasada, sin
Rosetta 2, sin árbol x64 — se vendoriza solo el árbol que corresponde a la
arquitectura nativa del Mac de build. En la arquitectura no nativa el
fallback JS embebido no está disponible (degrada a HTML estático, ver
Summary) — trade-off aceptado explícitamente.

### Pattern 2: Firma bottom-up con entitlements diferenciados por tipo de proceso

**Qué hace:** Extiende el Pattern 3 de la Fase 8 (`.so`→`.dylib`→ejecutable)
al grafo de un `.app` de Chromium: helpers (Renderer/GPU necesitan
`allow-jit`, el resto no) → framework → app principal.

**Cuándo usar:** Obligatorio para que `notarytool` acepte el `.app` — mismo
motivo que ya documentó la Fase 8 (Pattern 3) y que `_resign_bundled_python()`
en `scripts/release-macos.sh` ya tuvo que resolver: `xcodebuild
-exportArchive` no aplica `--options runtime` a binarios sueltos en
`Resources/` fuera de su propio grafo de firma.

**Ejemplo — fragmento de `bundle-playwright.sh` (firma, tras la instalación):**
```bash
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-}"
[[ -z "${IDENTITY}" ]] && IDENTITY="-"

RENDERER_ENTITLEMENTS="${PROJECT_DIR}/scripts/chromium-helper-renderer.entitlements"
GPU_ENTITLEMENTS="${PROJECT_DIR}/scripts/chromium-helper-gpu.entitlements"

# (ambos archivos son una copia local mínima de
#  chrome/app/helper-renderer-entitlements.plist / helper-gpu-entitlements.plist
#  del repo real de Chromium — solo com.apple.security.cs.allow-jit)

for chromium_app in "${LOCAL_BROWSERS_DIR}"/chromium-*/chrome-mac*/Chromium.app; do
  helpers_dir="${chromium_app}/Contents/Frameworks/Chromium Framework.framework/Helpers"

  # 1. Helpers (de dentro hacia fuera: ejecutable → .app bundle)
  find "${helpers_dir}" -maxdepth 1 -name "*.app" | while IFS= read -r helper; do
    entitlements=""
    [[ "${helper}" == *"(Renderer)"* ]] && entitlements="${RENDERER_ENTITLEMENTS}"
    [[ "${helper}" == *"(GPU)"* ]]      && entitlements="${GPU_ENTITLEMENTS}"

    exe="${helper}/Contents/MacOS/$(basename "${helper}" .app)"
    if [[ -n "${entitlements}" ]]; then
      codesign --force --timestamp --options runtime \
        --entitlements "${entitlements}" --sign "${IDENTITY}" "${exe}"
    else
      codesign --force --timestamp --options runtime --sign "${IDENTITY}" "${exe}"
    fi
    codesign --force --timestamp --options runtime --sign "${IDENTITY}" "${helper}"
  done

  # 2. crashpad_handler (ejecutable suelto, sin entitlements especiales)
  codesign --force --timestamp --options runtime --sign "${IDENTITY}" \
    "${helpers_dir}/chrome_crashpad_handler"

  # 3. El framework completo
  codesign --force --timestamp --options runtime --sign "${IDENTITY}" \
    "${chromium_app}/Contents/Frameworks/Chromium Framework.framework"

  # 4. Chromium.app en sí
  codesign --force --timestamp --options runtime --sign "${IDENTITY}" "${chromium_app}"
done
```

**Nota de confianza MEDIA sobre el listado exacto de helpers**: la lista de
`Chromium Helper*.app` (Renderer/GPU/Plugin/Alerts/base) puede variar entre
versiones de Chromium — `helper-plugin-entitlements.plist` ya no existe en
`main` (probablemente por la retirada de NPAPI), pero `helper-alerts-Info.plist`
sí sigue presente [VERIFIED contra el listado real del directorio
`chrome/app/` en `chromium.googlesource.com`, ver Sources]. El bucle `find
... -name "*.app"` de arriba es deliberadamente genérico (no hardcodea
nombres) para no romperse si la lista cambia entre versiones — solo aplica
entitlements especiales por coincidencia de substring cuando el nombre lo
indica, y firma el resto sin ellos. Confirmar el listado real contra la
versión de Chromium concreta que instale `playwright install chromium` en el
Mac de build, durante el checkpoint humano de esta fase.

### Pattern 3: Re-firmado final tras `xcodebuild -exportArchive` (extensión de `_resign_bundled_python`)

**Qué hace:** Igual que la Fase 13 ya tuvo que añadir `_resign_bundled_python()`
para el runtime Python (porque el export de Xcode no propaga
`--options runtime` a binarios sueltos en Resources), `scripts/release-macos.sh`
necesita un `_resign_bundled_chromium()` análogo, invocado en el mismo punto
del pipeline (`_build_and_export` → `_resign_bundled_python` →
`_resign_bundled_chromium` → `_notarize_and_staple`), reutilizando la MISMA
identidad Developer ID ya extraída de `codesign -dv --verbose=4 "${app_path}"`.

**Ejemplo — extensión de `scripts/release-macos.sh`:**
```bash
_resign_bundled_chromium() {
	local app_path="${CACHE_DIR}/export/${SCHEME}.app"
	local browsers_dir="${app_path}/Contents/Resources/python/lib/python-packages/playwright/driver/package/.local-browsers"

	if [[ ! -d "${browsers_dir}" ]]; then
		echo "Aviso: ${browsers_dir} no existe — nada que re-firmar." >&2
		return 0
	fi

	local identity
	identity="$(codesign -dv --verbose=4 "${app_path}" 2>&1 | sed -n 's/^Authority=//p' | head -1)"
	# ... mismo bucle bottom-up del Pattern 2, con $identity en vez de
	# $EXPANDED_CODE_SIGN_IDENTITY, y el mismo re-sellado final del .app
	# completo con --deep tras modificar contenido firmado dentro de él.
}
```

Y en `_main`, tras `_resign_bundled_python`:
```bash
_resign_bundled_python
_resign_bundled_chromium
_notarize_and_staple
```

### Pattern 4: `PLAYWRIGHT_BROWSERS_PATH` en `PythonBridge.swift`

**Qué hace:** Mismo bloque `switch paths.source { case .bundle: ... }` que ya
inyecta `PYTHONPATH` (líneas 58-65 de `PythonBridge.swift`), extendido con
una línea más.

```swift
case .bundle:
    if let libPath = Self.bundledVendoredLibPath() {
        let existing = env["PYTHONPATH"] ?? ""
        env["PYTHONPATH"] = existing.isEmpty ? libPath : libPath + ":" + existing
    }
    env["PLAYWRIGHT_BROWSERS_PATH"] = "0"
    process.currentDirectoryURL = URL(fileURLWithPath: scriptFile)
        .deletingLastPathComponent()
```

**Nota importante (hallazgo de research, no obvio):** Playwright lee
`PLAYWRIGHT_BROWSERS_PATH` una sola vez, en el momento en que su driver
Node.js interno arranca — **no** en el momento del `import playwright` de
Python. Como `core.py` solo hace el import dentro de
`_fetch_via_playwright()` (import perezoso, no a nivel de módulo), y el
proceso Python entero arranca ya con `PLAYWRIGHT_BROWSERS_PATH=0` en su
entorno (inyectado por `PythonBridge.swift` ANTES de `process.run()`), esto
funciona sin ningún ajuste adicional — pero es una restricción real a tener
en cuenta si en el futuro alguien intenta fijar la variable con
`os.environ[...] = "0"` dentro del propio script Python después de que el
proceso ya haya arrancado: no tendría efecto. [VERIFIED:
qaskills.sh/blog/playwright-browsers-path-environment-variable-reference]

### Anti-Patterns to Avoid

- **`lipo -create` sobre el árbol de Chromium** — sin herramienta madura
  equivalente a lipomerge para este caso, alto riesgo, sin precedente
  documentado encontrado en esta research (ver Summary).
- **`codesign --deep` como único mecanismo de firma** — mismo motivo que la
  Fase 8 ya documentó como anti-patrón para Python: no procesa
  correctamente binarios/bundles anidados con distintos requisitos de
  entitlements (los Helpers de Renderer/GPU necesitan `allow-jit`, el resto
  no) — hay que firmar explícitamente de dentro hacia fuera. `--deep` solo
  se usa aquí para el re-sellado FINAL del `.app` completo tras modificar
  contenido ya firmado dentro de él (mismo uso puntual que
  `_resign_bundled_python` ya hace).
- **Aplicar `app-entitlements.plist` (el de Chromium-el-navegador) tal cual
  al `Chromium.app` embebido** — ese archivo trae entitlements de App
  Sandbox (cámara, Bluetooth, USB, ubicación, fototeca) pensados para
  Chrome-el-navegador completo con esas APIs web activas. `ExtractorApp`
  tiene App Sandbox desactivado y Chromium se usa exclusivamente headless
  para renderizar HTML — ninguno de esos entitlements aplica ni debería
  copiarse sin verificar (ver Assumptions Log).
- **Instalar Chromium en tiempo de ejecución (`playwright install` lanzado
  por la propia app)** — requeriría red y escritura en el propio bundle
  firmado en el primer arranque del usuario, rompiendo la firma del `.app`.
  Todo el binario debe existir ya en build time, igual que Python.

---

## Common Pitfalls

### Pitfall 1: Firmar el `.app` de Chromium antes que sus Helpers/Framework internos

**Qué falla:** `notarytool` rechaza el envío con "the code signature is
invalid" o binarios internos reportados como "not signed at all", o
`codesign --verify` local ya falla antes de llegar a notarización.

**Por qué ocurre:** El orden de firma en macOS es estrictamente de dentro
hacia fuera — firmar el `.app` contenedor sella su Info.plist/recursos, y
cualquier binario interno modificado (firmado) DESPUÉS de eso invalida la
firma del contenedor. [VERIFIED: múltiples fuentes Apple Developer Forums,
ver Sources — mismo patrón que ya provocó el pitfall análogo en la Fase 8
con Python].

**Cómo evitar:** Seguir el orden exacto del Pattern 2/3: Helpers →
`crashpad_handler` → Framework → `Chromium.app` → (tras el export de Xcode)
re-sellar el `.app` de `ExtractorApp` completo una última vez.

**Señal de alerta:** `codesign --verify --deep --strict
"ExtractorApp.app"` falla localmente antes de intentar notarizar.

### Pitfall 2: Helpers Renderer/GPU sin `com.apple.security.cs.allow-jit`

**Qué falla:** El renderizado con Chromium falla en runtime con un crash o
un `SIGKILL` silencioso al ejecutar JavaScript (el motor V8 no puede marcar
memoria como ejecutable), y `_fetch_via_playwright()` captura la excepción
como "Playwright no disponible o falló el render" (`core.py:247-252`) sin
que quede claro que la causa real es de entitlements, no de instalación.

**Por qué ocurre:** Hardened Runtime bloquea por defecto la generación de
código ejecutable en memoria (`MAP_JIT`), que V8 necesita para JIT de
JavaScript — verificado directamente contra
`chrome/app/helper-renderer-entitlements.plist` y
`helper-gpu-entitlements.plist` del propio repo de Chromium, que declaran
únicamente `com.apple.security.cs.allow-jit` [VERIFIED, HIGH confidence,
fuente primaria].

**Cómo evitar:** Aplicar el entitlements file correcto (Pattern 2) a cada
Helper (Renderer)/(GPU) — nunca a ciegas a todo el árbol ni con `--deep`.

**Señal de alerta:** `codesign -d --entitlements - "Chromium Helper
(Renderer).app"` no muestra `com.apple.security.cs.allow-jit`.

### Pitfall 3: Confundir `PLAYWRIGHT_BROWSERS_PATH=0` con una ruta absoluta

**Qué falla:** El build funciona en la máquina de desarrollo (donde
`playwright install` ya dejó los binarios en `~/Library/Caches/ms-playwright/`
de una sesión anterior sin la variable puesta) pero falla en la app
distribuida a otro Mac, porque `PLAYWRIGHT_BROWSERS_PATH=0` en build time
solo tiene efecto si TAMBIÉN estaba puesta durante la instalación
(`playwright install chromium`), no solo en runtime.

**Por qué ocurre:** El sentinel `0` cambia dónde Playwright BUSCA los
binarios instalados, comparando con dónde los INSTALÓ — ambos pasos deben
usar el mismo valor de la variable, consistente entre build time y runtime.

**Cómo evitar:** Exportar `PLAYWRIGHT_BROWSERS_PATH=0` tanto en
`bundle-playwright.sh` (antes de `playwright install chromium`) como en
`PythonBridge.swift` (antes de lanzar el proceso Python en runtime) — nunca
solo uno de los dos lados.

**Señal de alerta:** `python -m playwright install --dry-run chromium`
imprime una ruta de instalación distinta a
`.../python-packages/playwright/driver/package/.local-browsers/` esperada.

### Pitfall 4: Tamaño del bundle infravalorado en la planificación

**Qué falla:** El plan de ejecución se diseña asumiendo la cifra de
referencia del ROADMAP ("~300MB+") y se sorprende al final con un `.app`
sustancialmente más grande, afectando tiempos de `ditto`/subida a
notarización/publicación en GitHub Releases (límite de 2GB por asset de
GitHub Release, no cerca de alcanzarse aquí pero sí a tener en cuenta si en
el futuro se añaden más binarios).

**Por qué ocurre (relevancia reducida tras la decisión de alcance):** con un
único árbol Chromium (arquitectura nativa), la cifra ronda 250-350 MB —
cerca de la referencia del ROADMAP. Este pitfall aplicaría si en el futuro
se revirtiera la decisión de alcance y se vendorizaran ambos árboles
(500-700 MB combinados).

**Cómo evitar:** Documentar la cifra real (medida contra el `.app`
exportado real, no estimada) en el `17-0X-SUMMARY.md` de esta fase, y
confirmar explícitamente con el usuario que sigue siendo aceptable antes de
publicar el primer release con Chromium embebido (mismo principio que
Success Criteria 4 ya pide).

**Señal de alerta:** `du -sh ExtractorApp.app` tras el build completo.

### Pitfall 5: Notarización más lenta de lo habitual por el tamaño

**Qué falla:** `xcrun notarytool submit --wait` tarda sensiblemente más que
los ~1-3 minutos habituales que la Fase 13 ya documentó para el bundle solo
con Python.

**Por qué ocurre:** Apps mucho más grandes (casos documentados en Apple
Developer Forums en el rango de decenas de GB) han reportado notarizaciones
de 3.5-4.5 horas, con la causa dominante siendo el procesamiento del lado
del servidor de Apple, no la subida en sí [VERIFIED, MEDIUM confidence —
caso extremo de ~100GB, no directamente comparable a los ~400-700MB
esperados aquí, pero establece que el tamaño SÍ es un factor documentado].

**Cómo evitar:** No hay mitigación de código — es un límite del servicio de
Apple. Ejecutar el primer release con Chromium embebido con margen de
tiempo (no en el último momento antes de necesitar publicar), y no asumir
que seguirá tardando lo mismo que el pipeline actual sin Chromium.

**Señal de alerta:** `notarytool submit --wait` sin devolver resultado
pasados 15-20 minutos (frente a los ~1-3 min habituales de la Fase 13).

---

## Estrategia de Verificación

Como en la Fase 8: parte del cambio es un script bash nuevo
(`scripts/bundle-playwright.sh`, verificable con `shellcheck` y ejecución
real en un Mac) y parte requiere el checkpoint humano en Xcode/Mac real que
domina esta fase entera — no hay forma de verificar `codesign`/notarización
real en este sandbox (sin macOS, sin Xcode, sin certificado Developer ID).

Extender `scripts/verify-bundle.sh` (ya existe desde la Fase 8) con:

```bash
echo "=== BUNDLEJS-01: Chromium vendorizado (arquitectura nativa del build) ==="
LOCAL_BROWSERS="${RESOURCES}/python/lib/python-packages/playwright/driver/package/.local-browsers"
find "${LOCAL_BROWSERS}" -maxdepth 1 -type d -name "chromium-*" | wc -l  # esperado: 1 (alcance reducido, ver Summary)

echo "=== BUNDLEJS-01: Firma + hardened runtime de cada Chromium.app ==="
find "${LOCAL_BROWSERS}" -name "Chromium.app" -maxdepth 4 | while read -r app; do
  codesign --verify --deep --strict "${app}" || { echo "FAIL: firma inválida en ${app}"; exit 1; }
  codesign -d --entitlements - "${app}/Contents/Frameworks/Chromium Framework.framework/Versions/Current/Helpers/Chromium Helper (Renderer).app" \
    | grep -q "allow-jit" || { echo "FAIL: falta allow-jit en Helper (Renderer)"; exit 1; }
done

echo "=== BUNDLEJS-02: Fallback JS embebido funciona end-to-end ==="
PLAYWRIGHT_BROWSERS_PATH=0 PYTHONPATH="${RESOURCES}/python/lib/python-packages" \
  "${RESOURCES}/python/bin/python3.13" -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch()
    page = b.new_page()
    page.goto('https://example.com')
    assert 'Example Domain' in page.content()
    b.close()
print('OK: Chromium embebido renderiza correctamente')
"
```

La verificación DEFINITIVA de Success Criteria 3 (una SPA real desde la app
SwiftUI, sin Playwright instalado en el sistema del usuario) requiere el
checkpoint humano: un Mac limpio (o al menos sin `playwright install
chromium` ejecutado a nivel de sistema) ejecutando el `.app` exportado,
extrayendo una SPA real — mismo patrón de verificación humana que ya usaron
las Fases 12/13/16.

---

## Security Domain

- Sin superficie de credenciales nueva — reutiliza exactamente las mismas
  claves de firma/notarización ya auditadas en la Fase 13.
- **Superficie de ataque nueva real**: Chromium con `allow-jit` es un motor
  de ejecución de JavaScript arbitrario de páginas web de terceros,
  corriendo dentro de un proceso hijo del `.app` del usuario. Esto ya era
  cierto desde la Fase 11 (cuando el usuario instalaba Playwright a mano),
  pero ahora queda embebido y activo por defecto para cualquier usuario de
  la app, no solo para quien opcionalmente instaló Playwright. Mitigación
  ya existente y suficiente para el alcance de este proyecto (herramienta
  personal, no expuesta a terceros): Chromium se lanza siempre headless,
  sin persistencia de perfil entre ejecuciones (`p.chromium.launch()` sin
  `user_data_dir`, ver `core.py:240`), y el hardened runtime + entitlements
  mínimos (solo `allow-jit` donde hace falta) siguen aplicando el principio
  de mínimo privilegio ya usado en el resto del proyecto.
- `com.apple.security.cs.allow-unsigned-executable-memory` y
  `com.apple.security.cs.disable-library-validation` (mencionados en varias
  guías de Electron) **no están confirmados como necesarios** para Chromium
  puro sin Node.js embebido (Electron necesita `disable-library-validation`
  para cargar módulos nativos de Node firmados con certificados distintos —
  este proyecto no tiene ese problema, Chromium no carga código Python).
  Recomendación: NO añadirlos preventivamente; solo si el checkpoint humano
  revela un fallo real de carga de librería (ver Assumptions Log).

---

## Assumptions Log

| # | Claim | Sección | Riesgo si incorrecto | Confianza |
|---|-------|---------|----------------------|-----------|
| A1 | El listado exacto de `Chromium Helper*.app` (Renderer/GPU/Plugin/Alerts) puede variar según la versión de Chromium que instale `playwright install chromium` en el momento de implementar esta fase | Pattern 2 | El bucle genérico (`find *.app`, sin hardcodear nombres) mitiga esto — riesgo bajo aunque la lista cambie | MEDIA |
| A2 | ~~`playwright install chromium` bajo Rosetta 2 descarga correctamente el árbol x64~~ — **superseded**: descartado por la decisión de alcance del usuario (un solo árbol, sin Rosetta 2, ver Summary) | Pattern 1 | N/A — ya no aplica | N/A |
| A3 | `app-entitlements.plist` de Chromium (cámara/Bluetooth/USB/ubicación/fototeca) no es necesario porque son entitlements de App Sandbox y `ExtractorApp` tiene sandbox OFF | Anti-Patterns, Security Domain | Si Chromium falla por algún motivo TCC-relacionado inesperado en el checkpoint humano, revisar si alguno de esos entitlements sí aplica fuera de sandbox (poco probable pero no verificado empíricamente) | MEDIA-ALTA (verificado contra el propio código fuente de Chromium, pero no probado en runtime real en este sandbox) |
| A4 | El tamaño de un único árbol Chromium (arquitectura nativa) ronda 250-350 MB, cerca de la cifra de referencia del ROADMAP ("~300MB+") | Summary, Pitfall 4 | Riesgo bajo tras la reducción de alcance — a confirmar con `du -sh` en el `.app` exportado real durante el plan | MEDIA (extrapolado de tamaños comprimidos verificados, no de una medición directa del árbol descomprimido+firmado real) |
| A5 | `PLAYWRIGHT_BROWSERS_PATH=0` funciona igual de bien para un bundle de app nativa macOS que para los casos documentados (Lambda, Docker, Electron) | Pattern 1/4 | Riesgo bajo — el mecanismo es genérico a nivel del driver de Playwright, no específico de un tipo de despliegue | ALTA |

**A4 es el riesgo restante más relevante** — requiere confirmación directa
en un Mac real durante la ejecución del plan (medición real del `.app`
exportado), no se puede verificar desde este sandbox sin macOS/Xcode. A2
queda resuelto por la decisión de alcance (ya no aplica Rosetta 2).

---

## Sources

### Primary (HIGH confidence)

- `chrome/app/helper-renderer-entitlements.plist`,
  `chrome/app/helper-gpu-entitlements.plist`,
  `chrome/app/app-entitlements.plist` — leídos directamente del repositorio
  fuente real de Chromium
  (`chromium.googlesource.com/chromium/src/+/main/chrome/app/`, verificado
  además contra el mirror `raw.githubusercontent.com/chromium/chromium`
  para `app-entitlements.plist`) — confirma el entitlement exacto
  (`com.apple.security.cs.allow-jit`) de cada tipo de proceso y que
  `app-entitlements.plist` es de App Sandbox, no de hardened runtime.
- `https://playwright.dev/python/docs/browsers` — comportamiento oficial de
  `PLAYWRIGHT_BROWSERS_PATH`, incluyendo el sentinel `=0`.
- Lectura directa de este repo: `core.py` (`_fetch_via_playwright()`,
  líneas 225-252), `CLAUDE.md`, `scripts/bundle-python.sh`,
  `scripts/release-macos.sh` (`_resign_bundled_python`),
  `ExtractorApp.entitlements`, `PythonBridge.swift`.
- `.planning/phases/08-bundle-python-runtime/08-RESEARCH.md` — patrón base
  de bundling/firma bottom-up que esta fase extiende.
- `microsoft/playwright#10642` ("Chromium binary is not signed") —
  confirma que el Chromium descargado por Playwright en macOS llega sin
  ninguna firma de código.

### Secondary (MEDIUM confidence)

- `microsoft/playwright#7937` — reporte de usuario sobre el mismo problema
  de firma, sin respuesta oficial de mantenedores encontrada en el
  contenido accesible.
- Resultados de búsqueda sobre tamaños de `chromium-mac-arm64.zip`/`Chrome
  for Testing` (130-165 MB comprimidos según versión) — cifras de
  distintas versiones de Playwright, no una medición directa de la versión
  que se pinneará en el plan de ejecución.
- Apple Developer Forums (`developer.apple.com/forums/thread/813586`) sobre
  notarizaciones lentas — caso de referencia de ~100GB, escala muy distinta
  a la de este proyecto, usado solo para establecer que el tamaño SÍ es un
  factor documentado por Apple, no para predecir un tiempo concreto.
- Búsquedas generales sobre entitlements de Electron
  (`electron/notarize`, `electron-builder` docs) — usadas solo como
  contexto de por qué proyectos similares necesitan `allow-jit`/
  `disable-library-validation`, NO como fuente de qué necesita Chromium
  puro (para eso se usó la fuente primaria de Chromium, más fiable).

### Tertiary (LOW confidence)

- Estructura interna exacta de `Chromium Framework.framework/Helpers/`
  (nombres exactos de cada `Chromium Helper*.app`) — reconstruida de
  fragmentos de búsqueda + conocimiento general de la estructura pública de
  apps basadas en Chromium/CEF, no de una inspección directa del zip real
  de una versión pinneada concreta (no descargable en este sandbox sin
  acceso a `cdn.playwright.dev` verificado). Confirmar contra el árbol real
  en el plan de ejecución.

---

## Metadata

- Requirements cubiertos: BUNDLEJS-01, BUNDLEJS-02
- Depends on: Phase 8 (patrón de bundling Python/lipo/codesign bottom-up),
  Phase 13 (pipeline de firma Developer ID/notarización/`_resign_bundled_*`
  ya existente en `scripts/release-macos.sh`)
- Bloquea: plan(es) de ejecución de la Fase 17 + checkpoint humano en Mac
  real (build, firma, notarización y verificación end-to-end con una SPA
  real) — fase marcada explícitamente como sub-ciclo propio en ROADMAP.md,
  no asumir un único plan como en las Fases 14-16.
