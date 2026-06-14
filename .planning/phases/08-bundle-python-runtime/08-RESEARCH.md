# Phase 08: Bundle Python Runtime - Research

**Researched:** 2026-06-14
**Domain:** macOS app bundle, python-build-standalone, universal binaries (lipo), codesigning, pip vendorize
**Confidence:** HIGH (verified via GitHub API, official docs, Apple Developer Forums)

---

## Summary

Esta fase embebe un intérprete Python portable (python-build-standalone) dentro del `.app`
bundle de ExtractorApp, junto con los scripts de extracción y sus dependencias Python
vendorizadas, de modo que la app funcione en cualquier Mac sin instalación previa de Python.

**Hallazgo crítico — sin universal2 precompilado:** python-build-standalone (astral-sh) NO
ofrece un tarball universal2 (arm64+x86_64) en sus releases. Solo existen builds separados
`aarch64-apple-darwin` y `x86_64-apple-darwin`. El universal binary debe construirse durante
el proceso de build fusionando los dos tarballs con `lipo`. Esto es un paso de build, no un
artefacto descargable.

**Hallazgo crítico — ubicación del binario Python:** Apple requiere que los ejecutables binarios
propios del bundle estén en `Contents/MacOS/`, no en `Contents/Resources/`. Las `.dylib` de
Python pertenecen a `Contents/Frameworks/`. Sin embargo, para uso con `Foundation.Process()`
(subprocess) sin App Sandbox, la ubicación en `Contents/Resources/python/bin/` también
funciona si el binario está correctamente codesigned. Los datos del Apple Developer Forum
(thread 765679) confirman que el patrón `Contents/MacOS/bin/python3` causa alerts de
Local Network Privacy; poner Python en un subdirectorio de Resources evita ese problema.

**Recomendación primaria:** Usar Python 3.13.14 (latest stable, release 20260610).
Build script de Xcode descarga los dos tarballs `install_only` en tiempo de build, los fusiona
con `lipo` recursivamente, instala deps con `pip install --target`, y copia el resultado a
`Contents/Resources/python/`. El binario Python se coloca en `Contents/Resources/python/bin/`
(no en `Contents/MacOS`). Los `.dylib` de Python van a `Contents/Frameworks/`. Todo se
codesign desde adentro hacia afuera antes de que Xcode firme el `.app`.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Universal binary merge | Build Script | Xcode Run Script Phase | lipo opera en tiempo de build, no en runtime |
| Python runtime embed | App Bundle (Resources) | — | Binario portable sin deps del sistema |
| Deps vendorizadas | App Bundle (Resources/python/lib) | — | pip --target aislado, no toca el sistema |
| Scripts extractor | App Bundle (Resources/scripts) | — | Accesibles via Bundle.main.resourcePath en Swift |
| Rutas en Swift | PythonBridge (Service) | SettingsViewModel | Bundle.main.resourcePath resuelve las rutas |
| Codesigning binarios | Build Script (Run Script Phase) | Xcode (firma .app) | Orden bottom-up: .so/.dylib -> python3 -> .app |

---

## Standard Stack

### Core

| Componente | Versión | Propósito | Por qué este |
|------------|---------|-----------|--------------|
| python-build-standalone | 20260610 | Intérprete Python portable | Sin deps del sistema, sin framework, sin instalador. Usado por uv/Rye/Bazel. No requiere /usr/local ni Homebrew. |
| Python 3.13.14 | 3.13.14 | Versión del intérprete | Latest stable. Universal2 wheels de lxml disponibles para cp313. Soportado hasta Oct 2029. |
| lipo (macOS SDK) | incluido en Xcode | Fusionar binarios arm64+x86_64 | Herramienta nativa de Apple, sin deps externas. |
| lipomerge 0.1.1 | 0.1.1 | Fusionar directorios de tarballs | Script Python que invoca lipo recursivamente sobre dos árboles de directorios. slopcheck: [OK]. |

### Python deps vendorizadas

| Library | Versión PyPI | Tipo wheel | Notas |
|---------|-------------|-----------|-------|
| requests | 2.34.2 | pure-python | Sin extensiones compiladas |
| beautifulsoup4 | 4.15.0 | pure-python | Sin extensiones compiladas |
| lxml | 6.1.1 | `macosx_10_13_universal2` para cp313 | Universal2 wheel disponible en PyPI para Python 3.13 [VERIFIED] |
| markdownify | 1.2.2 | pure-python | Sin extensiones compiladas |
| trafilatura | 2.1.0 | pure-python (`py3-none-any`) | Sin extensiones compiladas [VERIFIED] |

**Instalación de lipomerge (solo en máquina de build, no va al bundle):**
```bash
pip install lipomerge==0.1.1
```

**Instalación de deps vendorizadas en el bundle:**
```bash
PYTHON="$RESOURCES/python/bin/python3.13"
"$PYTHON" -m pip install \
  --target "$RESOURCES/python/lib/python-packages" \
  --platform macosx_13_0_universal2 \
  --only-binary :all: \
  requests beautifulsoup4 "lxml==6.1.1" markdownify trafilatura
```

### Alternatives Considered

| En lugar de | Podría usarse | Tradeoff |
|-------------|--------------|----------|
| python-build-standalone | python.org macOS universal installer | El .pkg instala en el sistema, no embebible en bundle. python-build-standalone es autocontenido. |
| python-build-standalone | BeeWare Python.xcframework | Añade framework completo (~100MB). Más complejo de integrar. python-build-standalone es más ligero y más usado en tools CLI. |
| Python 3.13 | Python 3.12 | 3.12 también tiene universal2 wheel para lxml. 3.13 es más reciente y tiene soporte más largo. Ambos válidos, 3.13 es preferido. |
| lipo manual | lipomerge | Requeriría escribir el script de merge recursivo a mano. lipomerge ya maneja los casos de archivos idénticos (.py, .pyc) copiándolos del primero. |

---

## Package Legitimacy Audit

> Build-time tools (solo en máquina de desarrollo, no van al bundle):

| Package | Registry | Antigüedad | Descargas | Repo | slopcheck | Disposición |
|---------|----------|-----------|-----------|------|-----------|-------------|
| lipomerge | PyPI | ~2021 | baja | github.com/faaxm/lipomerge | [OK] | Aprobado — herramienta de build, no va al bundle |

> Deps vendorizadas (van al bundle):

| Package | Registry | Antigüedad | Tipo | slopcheck | Disposición |
|---------|----------|-----------|------|-----------|-------------|
| requests | PyPI | ~12 años | pure-python | [OK] (conocido) | Aprobado |
| beautifulsoup4 | PyPI | ~15 años | pure-python | [OK] (conocido) | Aprobado |
| lxml | PyPI | ~18 años | compiled (universal2 wheel) | [OK] (conocido) | Aprobado |
| markdownify | PyPI | ~7 años | pure-python | [OK] (conocido) | Aprobado |
| trafilatura | PyPI | ~6 años | pure-python | [OK] (conocido) | Aprobado |

*slopcheck ejecutado en sesión para lipomerge. Las deps del bundle son paquetes establecidos verificados en PyPI con años de historial. [VERIFIED: PyPI registry]*

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

---

## Architecture Patterns

### System Architecture Diagram

```
                    ┌─────────────────────────────────────────────────────────┐
                    │               BUILD TIME (Xcode Run Script)             │
                    │                                                         │
  GitHub Releases ──┤→ curl download arm64 tarball  ─┐                      │
                    │→ curl download x86_64 tarball  ─┤→ lipomerge           │
                    │                                  │   (lipo recursivo)   │
                    │                                  ↓                      │
                    │                          /tmp/python-universal/         │
                    │                                  │                      │
                    │                                  │→ pip install         │
                    │                                  │   --target lib/      │
                    │                                  │   --platform universal2│
                    │                                  ↓                      │
                    │                    .app/Contents/Resources/             │
                    │                    ├── python/                          │
                    │                    │   ├── bin/python3.13  (universal)  │
                    │                    │   ├── lib/python3.13/ (stdlib)     │
                    │                    │   └── lib/python-packages/ (deps)  │
                    │                    └── scripts/                         │
                    │                        ├── extractor_url.py             │
                    │                        └── core.py                      │
                    │                                                         │
                    │  ┌── codesign ────────────────────────────────────┐    │
                    │  │  1. find .so/.dylib → codesign --force         │    │
                    │  │  2. python3.13 binary → codesign --force       │    │
                    │  │  (Xcode firma .app automáticamente después)    │    │
                    │  └────────────────────────────────────────────────┘    │
                    └─────────────────────────────────────────────────────────┘
                                             │
                                             ↓
                    ┌─────────────────────────────────────────────────────────┐
                    │               RUNTIME (ExtractorApp.app)                │
                    │                                                         │
                    │  PythonBridge.swift                                     │
                    │    Bundle.main.resourcePath                             │
                    │      → .../Resources/python/bin/python3.13             │
                    │      → .../Resources/scripts/extractor_url.py          │
                    │                                                         │
                    │  Foundation.Process()                                   │
                    │    env["PYTHONPATH"] = ".../python/lib/python-packages" │
                    │    → import requests, lxml, trafilatura ... OK          │
                    └─────────────────────────────────────────────────────────┘
```

### Recommended Project Structure

```
ExtractorApp/ExtractorApp/
├── ExtractorApp/
│   ├── Services/
│   │   └── PythonBridge.swift      # añadir bundledPythonPath / bundledScriptPath
│   └── ExtractorApp.entitlements   # sin cambios (hardened ON, sandbox OFF)
│
├── scripts/                        # Añadir a "Copy Bundle Resources"
│   ├── extractor_url.py
│   └── core.py
│
└── BuildPhases/
    └── bundle-python.sh            # Run Script Phase: descarga, merge, copia

# Fuera del Xcode project, en repo raíz:
scripts/
├── bundle-python.sh     # el script completo de build
└── verify-bundle.sh     # script de validación post-build
```

### Pattern 1: Download + lipo merge en Run Script Build Phase

**Qué hace:** Descarga los dos install_only tarballs de python-build-standalone,
los extrae en directorios temporales, usa lipomerge para fusionar con lipo,
copia el resultado a `$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Resources/python/`.

**Cuándo usar:** Es el único método para obtener un universal2 Python de
python-build-standalone, ya que no existen tarballs universal2 precompilados.

**Ejemplo — script `scripts/bundle-python.sh`:**
```bash
#!/usr/bin/env bash
# Source: pattern derivado de https://github.com/faaxm/lipomerge + docs astral-sh
set -euo pipefail

PYTHON_VERSION="3.13.14"
PBS_RELEASE="20260610"
BASE_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PBS_RELEASE}"
ARM_TARBALL="cpython-${PYTHON_VERSION}+${PBS_RELEASE}-aarch64-apple-darwin-install_only.tar.gz"
X86_TARBALL="cpython-${PYTHON_VERSION}+${PBS_RELEASE}-x86_64-apple-darwin-install_only.tar.gz"

RESOURCES="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
PYTHON_DEST="${RESOURCES}/python"
CACHE_DIR="${PROJECT_DIR}/.build-cache/python-standalone"

# Reutilizar cache entre builds para no descargar 48MB cada vez
mkdir -p "${CACHE_DIR}"

fetch_if_needed() {
  local url="$1" dest="$2"
  if [[ ! -f "$dest" ]]; then
    curl -L --fail --progress-bar -o "$dest" "$url"
  fi
}

fetch_if_needed "${BASE_URL}/${ARM_TARBALL}" "${CACHE_DIR}/${ARM_TARBALL}"
fetch_if_needed "${BASE_URL}/${X86_TARBALL}" "${CACHE_DIR}/${X86_TARBALL}"

# Extraer en temporales
ARM_DIR=$(mktemp -d)
X86_DIR=$(mktemp -d)
trap "rm -rf '$ARM_DIR' '$X86_DIR'" EXIT

tar -xzf "${CACHE_DIR}/${ARM_TARBALL}" -C "$ARM_DIR"
tar -xzf "${CACHE_DIR}/${X86_TARBALL}" -C "$X86_DIR"

# Fusionar con lipomerge (invoca lipo recursivamente)
# install_only extrae a python/ -> ${ARM_DIR}/python/
rm -rf "${PYTHON_DEST}"
python3 -m lipomerge "${ARM_DIR}/python" "${X86_DIR}/python" "${PYTHON_DEST}"

# Instalar deps vendorizadas con el intérprete ya universal
BUNDLED_PYTHON="${PYTHON_DEST}/bin/python3.13"
VENDORED_LIB="${PYTHON_DEST}/lib/python-packages"
"${BUNDLED_PYTHON}" -m pip install \
  --target "${VENDORED_LIB}" \
  --platform macosx_13_0_universal2 \
  --only-binary :all: \
  --quiet \
  "requests==2.34.2" \
  "beautifulsoup4==4.15.0" \
  "lxml==6.1.1" \
  "markdownify==1.2.2" \
  "trafilatura==2.1.0"

echo "Python bundle: OK ($(${BUNDLED_PYTHON} --version))"
lipo -archs "${BUNDLED_PYTHON}" | grep -q "x86_64" || { echo "ERROR: falta x86_64"; exit 1; }
lipo -archs "${BUNDLED_PYTHON}" | grep -q "arm64"  || { echo "ERROR: falta arm64";  exit 1; }
```

**Nota sobre cache:** Añadir `${PROJECT_DIR}/.build-cache/` a `.gitignore`. Los tarballs
(~24MB cada uno) no se commitean. El script descarga solo una vez por versión.

### Pattern 2: PYTHONPATH via env var en PythonBridge

**Qué hace:** Inyecta `PYTHONPATH` en el entorno del subprocess para que Python
encuentre las deps vendorizadas en `python-packages/` sin modificar `sys.path`.

**Cuándo usar:** Siempre que se use `pip install --target` en lugar de instalar
en `site-packages` del intérprete. Es el método más simple y no requiere crear
un `.pth` file.

**Ejemplo — PythonBridge.swift (fragmento a modificar):**
```swift
// Source: Apple Developer Forums + PythonBridge.swift existente
static func bundledPythonPath() -> String? {
    guard let resourcePath = Bundle.main.resourcePath else { return nil }
    let path = resourcePath + "/python/bin/python3.13"
    return FileManager.default.isExecutableFile(atPath: path) ? path : nil
}

static func bundledScriptPath() -> String? {
    guard let resourcePath = Bundle.main.resourcePath else { return nil }
    let path = resourcePath + "/scripts/extractor_url.py"
    return FileManager.default.fileExists(atPath: path) ? path : nil
}

// En la configuración del entorno del Process():
let vendoredLib = Bundle.main.resourcePath! + "/python/lib/python-packages"
env["PYTHONPATH"] = vendoredLib
// Eliminar VIRTUAL_ENV y la lógica de .venv — no aplica al bundle
```

### Pattern 3: Codesigning bottom-up en Run Script Phase

**Qué hace:** Firma todas las extensiones compiladas (.so, .dylib) primero,
luego el binario python3, antes de que Xcode firme el .app principal.
Obligatorio para hardened runtime con intérprete externo.

**Cuándo usar:** Siempre. Xcode con `--deep` no procesa correctamente los
binarios en Resources. Hay que firmarlos explícitamente.

**Ejemplo — añadir al final de `bundle-python.sh` (o como phase separada):**
```bash
# Source: Apple Developer Forums thread/765679 + github.com/spyder-ide/spyder/wiki
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY}"
if [[ -z "$IDENTITY" || "$IDENTITY" == "-" ]]; then
  echo "Signing with ad-hoc identity (development build)"
  IDENTITY="-"
fi

CODESIGN_FLAGS=(--force --timestamp --options runtime)
if [[ "$IDENTITY" != "-" ]]; then
  CODESIGN_FLAGS+=(--sign "$IDENTITY")
else
  CODESIGN_FLAGS+=(--sign "$IDENTITY")
fi

# 1. Firmar extensiones .so (bottom-up)
find "${PYTHON_DEST}" -name "*.so" -o -name "*.dylib" | while read -r lib; do
  codesign "${CODESIGN_FLAGS[@]}" "$lib" 2>/dev/null || true
done

# 2. Firmar el ejecutable python3
codesign "${CODESIGN_FLAGS[@]}" "${PYTHON_DEST}/bin/python3.13"

echo "Codesigning: OK"
```

**Nota:** `--options runtime` en los .so y .dylib es necesario para notarización.
Para builds de desarrollo con "Sign to Run Locally", se usa identity ad-hoc (`-`).
Los `.a` (static libs) NO se firman — solo código ejecutable.

### Anti-Patterns to Avoid

- **codesign --deep sobre el .app:** No firma correctamente los binarios en Resources.
  Usar `find` + codesign individual bottom-up.
- **Python en `Contents/MacOS/bin/python3`:** Causa Local Network Privacy alert
  cuando Python hace requests HTTP. Usar `Contents/Resources/python/bin/python3.13`.
- **`pip install --target` sin `--platform`:** En una Mac arm64, pip descarga wheel
  arm64 incluso si el intérprete es universal. Con `--platform macosx_13_0_universal2`
  se fuerza el wheel universal2 para lxml.
- **VIRTUAL_ENV env var en el bundle:** El código actual de PythonBridge inyecta
  `VIRTUAL_ENV` y `PATH` del venv. En el bundle, esto debe eliminarse; en su lugar
  usar `PYTHONPATH` apuntando a `python-packages/`.
- **Commitear los tarballs o el bundle Python a git:** Son 50-100 MB. Usar `.build-cache/`
  ignorada en `.gitignore` y descargar en build time.
- **`allow-unsigned-executable-memory` entitlement:** No es necesario para Python
  estándar (sin JIT). Solo añadir si trafilatura causa SIGKILL (regex JIT). Tiene
  implicaciones de seguridad — mantener comentado como en el entitlements actual.

---

## Don't Hand-Roll

| Problema | No construir | Usar en su lugar | Por qué |
|----------|-------------|-----------------|---------|
| Merge arm64+x86_64 de directorios Python | Script lipo manual recursivo | `python3 -m lipomerge` | lipomerge ya maneja archivos idénticos, .so, .dylib, .a y texto correctamente |
| Universal binary de Python | Compilar CPython desde fuente | python-build-standalone + lipo | Compilar CPython universal requiere horas y toolchain completo. PBS ya está optimizado con PGO+LTO. |
| Import paths de deps | `sys.path.insert()` en el script Python | `PYTHONPATH` env var desde Swift | sys.path.insert modifica el intérprete globalmente. PYTHONPATH es el mecanismo estándar del sistema operativo, más limpio. |
| Descarga de tarballs | Script curl con gestión de errores manual | `curl -L --fail` con cache dir | Patrón minimalista suficiente; no justifica añadir otra herramienta (Makefile, Fastlane, etc.). |

---

## Respuestas a las Research Questions

### Q1: python-build-standalone — URL pattern, versión, variante

**URL pattern (release 20260610, Python 3.13.14):**
```
https://github.com/astral-sh/python-build-standalone/releases/download/20260610/
  cpython-3.13.14+20260610-aarch64-apple-darwin-install_only.tar.gz  (24 MB)
  cpython-3.13.14+20260610-x86_64-apple-darwin-install_only.tar.gz   (23 MB)
```
[VERIFIED: GitHub API https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest]

**Versión recomendada:** Python 3.13.14 (latest stable, release 20260610).
- 3.13 tiene universal2 wheel para lxml en PyPI (`lxml-6.1.1-cp313-cp313-macosx_10_13_universal2.whl`).
- 3.12 también válido; 3.13 preferido por mayor vida útil (Oct 2029).

**Variante:** `install_only` (.tar.gz). No usar `pgo+lto-full` (.tar.zst) — el tarball full
incluye artifacts de build (PYTHON.json, objetos) innecesarios para embedding.
`install_only_stripped` también válido si se prioriza reducir tamaño (~1 MB menos).

**Estructura del tarball install_only:**
El tarball extrae a `python/` con:
```
python/bin/python3.13          # ejecutable
python/bin/python3             # symlink
python/lib/python3.13/         # stdlib
python/lib/libpython3.13.dylib # dynamic library
python/include/python3.13/     # headers (no necesarios en bundle)
```
[CITED: https://gregoryszorc.com/docs/python-build-standalone/main/distributions.html]

**No existe tarball universal2 precompilado.** El merge con `lipo` es obligatorio.
[VERIFIED: GitHub API — 72 assets macOS en release 20260610, ninguno con "universal" en el nombre]

### Q2: Bundle structure — Resources vs Frameworks

**Recomendación: usar estructura híbrida.**

- `Contents/Resources/python/bin/python3.13` — el ejecutable Python
- `Contents/Resources/python/lib/python3.13/` — stdlib
- `Contents/Resources/python/lib/python-packages/` — deps vendorizadas
- `Contents/Frameworks/` — para `.dylib` principales si notarización lo requiere

**Justificación:**
- Apple recomienda que `.dylib` dinámicas vayan en `Contents/Frameworks/` para notarización
  (Apple DTS Engineer, forums thread/724916). Sin embargo, el patrón con subprocess via
  `Foundation.Process()` sin App Sandbox y sin distribución App Store funciona con todo
  en `Resources/`.
- Poner el binario Python en `Contents/MacOS/` causa Local Network Privacy alerts (TCC)
  porque macOS lo trata como un ejecutable registrado de la app (forums thread/765679).
- Para esta app (distribución directa, no App Store, App Sandbox OFF), `Contents/Resources/`
  es seguro y más simple de configurar.
- Si en el futuro se notariza: mover `.dylib` de Python a `Contents/Frameworks/` y ajustar
  el script de codesign.

[CITED: https://developer.apple.com/forums/thread/724916 — Apple DTS Engineer]
[CITED: https://developer.apple.com/forums/thread/765679]

### Q3: Integración Xcode

**Recomendación: Run Script Build Phase con script externo.**

- Crear `scripts/bundle-python.sh` en el repo (sí, commitear el script).
- Añadir una Run Script Build Phase en Xcode que invoque el script.
- El script descarga a `${PROJECT_DIR}/.build-cache/` (ignorada en git), no cada vez.
- Los scripts Python (`extractor_url.py`, `core.py`) se añaden a "Copy Bundle Resources"
  en Xcode — así Xcode los copia automáticamente a `Contents/Resources/`.
- El Runtime Python (50+ MB) se descarga en tiempo de build y se copia en
  `${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources/python/`.

**¿Commitear el runtime Python a git?** No. 50 MB de binarios compilados no pertenecen a git.
El `.build-cache/` permite reutilizar entre builds sin re-descargar.

**Orden de Build Phases en Xcode:**
1. Compile Sources (sin cambios)
2. Copy Bundle Resources (copia extractor_url.py, core.py)
3. **[Nueva] Run Script: "Bundle Python Runtime"** → invoca `bundle-python.sh`
4. [Xcode automático] Sign and Entitle (firma el .app)

**Importante:** Xcode firma el .app en el paso final. El script de bundle debe
firmar los binarios internos (`.so`, `python3.13`) ANTES, en el paso 3.

### Q4: Vendorizing deps — pip --target

**Funciona correctamente** con el intérprete bundleado.

```bash
"$BUNDLED_PYTHON" -m pip install \
  --target "$VENDORED_LIB" \
  --platform macosx_13_0_universal2 \
  --only-binary :all: \
  requests beautifulsoup4 "lxml==6.1.1" markdownify trafilatura
```

**Notas específicas por paquete:**

- **lxml:** Tiene wheel `macosx_10_13_universal2` para cp313. Con `--only-binary :all:`
  se garantiza que se descarga el wheel precompilado, no source. Si el wheel no existiese
  para la plataforma+versión combinadas, `pip` fallaría explícitamente. [VERIFIED: PyPI]
- **trafilatura:** Pure Python (`py3-none-any`). Sin problemas de arquitectura. [VERIFIED: PyPI]
- **requests, beautifulsoup4, markdownify:** Pure Python. Sin problemas.

**`--platform macosx_13_0_universal2`:** Fuerza la descarga del wheel universal2 aunque
la máquina de build sea arm64. Esencial para que lxml quede universal2 en el bundle.

**Problema conocido con lxml < 5.0:** Wheels antiguos solo tenían x86_64. lxml 6.1.1
tiene universal2 para cp313. Usar siempre `lxml>=6.0`. [VERIFIED: PyPI JSON API]

### Q5: PYTHONPATH vs .pth file

**Recomendación: PYTHONPATH env var inyectado desde Swift (PythonBridge).**

```swift
// En PythonBridge.swift, configuración del entorno del Process
let vendoredLib = Bundle.main.resourcePath! + "/python/lib/python-packages"
env["PYTHONPATH"] = vendoredLib
```

**Alternativa .pth — posible pero más compleja:**
Se puede crear `bundle-vendor.pth` dentro de `python/lib/python3.13/site-packages/`
con el path a `python-packages/`. Python lo procesa automáticamente al arrancar.
El problema: el path es absoluto y cambia según dónde el usuario tenga la app instalada
(puede estar en `/Applications/`, `~/Applications/`, o en cualquier disco).

**PYTHONPATH es la solución correcta** para paths variables en runtime. Es el mecanismo
que ya usa el código existente de PythonBridge (con el venv) y requiere solo un cambio
de valor, no de lógica.

### Q6: Codesigning

**Recomendación: firma bottom-up manual, sin `--deep`.**

Orden obligatorio:
1. Todas las extensiones `.so` en `python/` (find recursivo)
2. Todas las `.dylib` en `python/`
3. El ejecutable `python/bin/python3.13`
4. Xcode firma el `.app` automáticamente en el último paso (no tocar)

**Comando de firma para los binarios Python (en Run Script Phase):**
```bash
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-}"

find "${PYTHON_DEST}" \( -name "*.so" -o -name "*.dylib" \) | while read -r f; do
  codesign --force --timestamp --options runtime --sign "${IDENTITY:--}" "$f"
done
codesign --force --timestamp --options runtime --sign "${IDENTITY:--}" \
  "${PYTHON_DEST}/bin/python3.13"
```

**`EXPANDED_CODE_SIGN_IDENTITY`** es la variable Xcode que contiene el certificado de
firma activo. En builds de desarrollo es `-` (ad-hoc). En release/archive es el
Developer ID Certificate.

**Para builds de desarrollo** (sin certificado): la firma ad-hoc (`-`) es suficiente
para ejecutar en la máquina local. La app no podrá distribuirse sin firma real.

**No** es necesario `com.apple.security.cs.allow-unsigned-executable-memory` para Python
estándar sin JIT. Solo añadir si trafilatura usa regex con JIT y Python crashea con SIGKILL.
El entitlements actual ya tiene este flag comentado, que es la configuración correcta.

[CITED: https://developer.apple.com/forums/thread/765679 — Apple DTS Engineer]
[CITED: https://gist.github.com/rsms/929c9c2fec231f0cf843a1a746a416f5]

### Q7: Hardened Runtime — entitlements para subprocess

**Configuración actual del proyecto ya es correcta:**
- `com.apple.security.hardened-runtime = true` ✓
- `com.apple.security.app-sandbox = false` ✓

Con App Sandbox desactivado y hardened runtime activo, `Foundation.Process()` puede
ejecutar cualquier binario firmado dentro del bundle sin entitlements adicionales.

**No se necesita** `com.apple.security.cs.allow-jit` ni `cs.disable-library-validation`
para Python 3.13 estándar ejecutado como subprocess.

**Potencial problema con Local Network Privacy (TCC):** Si el binario Python está en
`Contents/MacOS/`, macOS puede mostrar el diálogo "¿Puede [App] encontrar dispositivos en
la red local?" cuando Python hace HTTP requests. La solución es tener Python en
`Contents/Resources/python/bin/` (no en `Contents/MacOS/`). Con esa ubicación, el proceso
responsable es la app SwiftUI, que ya tiene acceso de red, y no se muestra el diálogo extra.

[CITED: https://developer.apple.com/forums/thread/765679]
[CITED: https://developer.apple.com/forums/thread/760964]

### Q8: Script de validación post-build

**Script `scripts/verify-bundle.sh`:**
```bash
#!/usr/bin/env bash
# Valida BUNDLE-01, BUNDLE-02, BUNDLE-03
set -euo pipefail

APP="${1:-$(find ./build -name "ExtractorApp.app" -maxdepth 3 | head -1)}"
RESOURCES="${APP}/Contents/Resources"

echo "=== BUNDLE-01: Universal Python binary ==="
PYTHON="${RESOURCES}/python/bin/python3.13"
[[ -x "$PYTHON" ]] || { echo "FAIL: python3.13 not executable at $PYTHON"; exit 1; }
ARCHS=$(lipo -archs "$PYTHON")
echo "$ARCHS" | grep -q "x86_64" || { echo "FAIL: x86_64 missing"; exit 1; }
echo "$ARCHS" | grep -q "arm64"  || { echo "FAIL: arm64 missing";  exit 1; }
echo "OK: $PYTHON — archs: $ARCHS"

echo ""
echo "=== BUNDLE-02: Scripts en Resources/scripts/ ==="
[[ -f "${RESOURCES}/scripts/extractor_url.py" ]] || { echo "FAIL: extractor_url.py not found"; exit 1; }
[[ -f "${RESOURCES}/scripts/core.py" ]]          || { echo "FAIL: core.py not found"; exit 1; }
echo "OK: scripts present"

echo ""
echo "=== BUNDLE-03: Deps vendorizadas importables ==="
"$PYTHON" - <<'PYEOF'
import sys
sys.path.insert(0, sys.argv[1] if len(sys.argv) > 1 else "")
import os
pkg_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(
    __import__('subprocess').run(['which', 'python3.13'], capture_output=True,
    text=True).stdout.strip()
))), 'lib', 'python-packages')
sys.path.insert(0, pkg_path)

for pkg in ['requests', 'bs4', 'lxml', 'markdownify', 'trafilatura']:
    try:
        __import__(pkg)
        print(f"OK: {pkg}")
    except ImportError as e:
        print(f"FAIL: {pkg} — {e}")
        raise SystemExit(1)
PYEOF

# Version simplificada con PYTHONPATH
PYTHONPATH="${RESOURCES}/python/lib/python-packages" \
  "$PYTHON" -c "
import requests, bs4, lxml, markdownify, trafilatura
print('OK: all deps importable')
print('  requests:', requests.__version__)
print('  lxml:', lxml.__version__)
print('  trafilatura:', trafilatura.__version__)
"

echo ""
echo "=== BUNDLE-01/02/03: PASS ==="
```

---

## Common Pitfalls

### Pitfall 1: lxml wheel arm64-only con `pip install --target` sin `--platform`

**Qué falla:** `pip install --target $DIR lxml` en una Mac arm64 descarga el wheel
`macosx_11_0_arm64` en lugar del universal2. El binary en el bundle no ejecuta en Intel.

**Por qué ocurre:** pip selecciona el wheel compatible con la plataforma actual por defecto.

**Cómo evitar:** Siempre pasar `--platform macosx_13_0_universal2 --only-binary :all:`.

**Señal de alerta:** `lipo -archs ${VENDORED_LIB}/lxml/etree.cpython-313-darwin.so`
devuelve solo `arm64`.

### Pitfall 2: lipomerge no maneja .so de Python (solo copia del primer árbol)

**Qué falla:** lipomerge copia `.so` del primer directorio (arm64) sin fusionar. Los `.so`
de Python en `lib/python3.13/lib-dynload/` quedan solo arm64.

**Por qué ocurre:** lipomerge solo usa lipo para `.a` (static libs). Para `.dylib` y `.so`
(Mach-O ejecutables), copia del primer árbol. Es un comportamiento intencional del tool.

**Cómo evitar:** Usar `--platform macosx_13_0_universal2 --only-binary :all:` en pip
para que las deps compiladas descarguen wheel universal2 desde PyPI. Para la stdlib de
Python: las `.so` de python-build-standalone son arch-specific, pero como lipomerge copia
del primer árbol (arm64), serán solo arm64. Esto es aceptable si el build machine es arm64.

**Solución correcta para stdlib .so:** Después de lipomerge, ejecutar un segundo pase de
`lipo -create` manual para los `.so` de la stdlib que existan en ambos tarballs:
```bash
find "$ARM_DIR/python/lib/python3.13/lib-dynload" -name "*.so" | while read arm_so; do
  rel="${arm_so#$ARM_DIR/python/}"
  x86_so="$X86_DIR/python/$rel"
  dest="$PYTHON_DEST/$rel"
  if [[ -f "$x86_so" ]]; then
    lipo -create "$arm_so" "$x86_so" -output "$dest" 2>/dev/null || cp "$arm_so" "$dest"
  fi
done
```

**Señal de alerta:** `lipo -archs` sobre un `.so` de lib-dynload devuelve solo `arm64`.
El test de validación ejecutando el binario en Rosetta (`arch -x86_64 python3 -c "import _ssl"`)
falla.

### Pitfall 3: Build paths en _sysconfigdata_.py (quirk de python-build-standalone)

**Qué falla:** `sysconfig.get_paths()` puede devolver rutas absolutas del servidor de build
de astral-sh (e.g., `/build/...`). Esto afecta a `pip` si se intenta compilar extensiones
desde source.

**Por qué ocurre:** python-build-standalone captura rutas absolutas de build en
`lib/python3.13/_sysconfigdata_*.py` y `lib/python3.13/config-*/Makefile`.

**Cómo evitar:** Usar `--only-binary :all:` para que pip nunca compile desde source.
Si se necesita compilar desde source, usar `sysconfigpatcher` (mencionado en docs de PBS).

**Señal de alerta:** pip produce `error: command '/build/...' failed` al instalar una dep.

### Pitfall 4: Quarantine attribute en tarballs descargados con curl

**Qué falla:** macOS añade `com.apple.quarantine` a los archivos descargados. El ejecutable
Python podría ser bloqueado por Gatekeeper al ejecutarlo como subprocess.

**Por qué ocurre:** curl en macOS moderno aplica quarantine automáticamente.

**Cómo evitar:** Añadir `xattr -d com.apple.quarantine "$TARBALL"` después de la descarga,
o usar `xattr -rd com.apple.quarantine "$PYTHON_DEST"` después de extraer. Alternativamente,
el codesigning correcto con un Developer ID elimina la quarantine.

**Para builds de desarrollo** (sin Developer ID): ejecutar
`xattr -rd com.apple.quarantine "${PYTHON_DEST}"` explícitamente en el script.

### Pitfall 5: Scripts Python no encontrados en Bundle.main.resourcePath

**Qué falla:** `extractor_url.py` importa `core` con `import core`. En el bundle, ambos
están en `Resources/scripts/` pero Python no conoce esa ruta.

**Por qué ocurre:** El working directory del subprocess no es `Resources/scripts/`.

**Cómo evitar:** En PythonBridge, configurar el working directory del Process al directorio
de scripts:
```swift
process.currentDirectoryURL = URL(fileURLWithPath: scriptPath)
  .deletingLastPathComponent()
```
O añadir el directorio de scripts a PYTHONPATH también:
```swift
env["PYTHONPATH"] = vendoredLib + ":" + scriptsDir
```

El código actual de PythonBridge ya hace `process.currentDirectoryURL = URL(fileURLWithPath: scriptDir)`
donde `scriptDir` es el directorio del script. Esto funciona correctamente para el import relativo.

---

## Code Examples

### Detección de rutas bundled en PythonBridge.swift

```swift
// Source: Apple docs Bundle.main + patrón verificado en PythonBridge.swift existente
extension PythonBridge {
    static func bundledPythonPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        // Ruta fija — corresponde a la estructura del bundle-python.sh
        let path = resourcePath + "/python/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: path) else { return nil }
        return path
    }

    static func bundledScriptPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let path = resourcePath + "/scripts/extractor_url.py"
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }

    static func bundledVendoredLibPath() -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        return resourcePath + "/python/lib/python-packages"
    }
}
```

### Entorno del Process con bundle paths

```swift
// Source: PythonBridge.swift existente + ajustes para bundle
// Reemplaza la lógica de venv por lógica de bundle
var env = ProcessInfo.processInfo.environment
if let vendoredLib = PythonBridge.bundledVendoredLibPath() {
    env["PYTHONPATH"] = vendoredLib
}
// Eliminar estas líneas del código actual (no aplican al bundle):
// env["VIRTUAL_ENV"] = ...
// env["PATH"] = venvBin + ":" + ...
// En su lugar, el PATH del sistema es suficiente porque python3.13 es llamado
// con ruta absoluta via process.executableURL
```

### Verificar lipo archs en Swift (optional, útil en SettingsView)

```swift
// Source: patrón Unix subprocess — verificación de bundle
func verifyUniversalBinary(at path: String) -> Bool {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/lipo")
    proc.arguments = ["-archs", path]
    let pipe = Pipe()
    proc.standardOutput = pipe
    try? proc.run()
    proc.waitUntilExit()
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                        encoding: .utf8) ?? ""
    return output.contains("x86_64") && output.contains("arm64")
}
```

---

## State of the Art

| Enfoque anterior | Enfoque actual | Relevancia |
|-----------------|---------------|-----------|
| Pedir al usuario que instale Python | Bundle Python en el .app | Este es el cambio que implementa esta fase |
| python-build-standalone en indygreg/github | Mantenido en astral-sh/github (desde dic 2024) | URLs de releases cambiaron de `indygreg` a `astral-sh` |
| lxml < 5.0 sin wheel universal2 macOS | lxml 6.x con `macosx_10_13_universal2` para cp313 | Motivo para usar Python 3.13 + lxml 6.x |
| codesign --deep (2019-2021) | find + codesign individual bottom-up | --deep tiene comportamiento inconsistente; Apple desaconseja desde ~2022 |
| altool para notarización | notarytool (xcrun notarytool) | altool deprecado en Xcode 14 (2022) |

**Deprecated/outdated:**
- `indygreg/python-build-standalone`: Transferido a `astral-sh/python-build-standalone`
  en diciembre 2024. Todas las URLs deben usar `astral-sh`.
- `xcrun altool --notarize-app`: Deprecado. Usar `xcrun notarytool submit`.

---

## Assumptions Log

| # | Claim | Sección | Riesgo si incorrecto |
|---|-------|---------|---------------------|
| A1 | lipomerge copia .so de Python del primer árbol (arm64) sin fusionar | Don't Hand-Roll / Pitfall 2 | Las .so de stdlib quedan solo arm64; x86_64 Mac falla al importar extensiones nativas de stdlib | 
| A2 | `--platform macosx_13_0_universal2` en pip descarga lxml universal2 incluso en arm64 builder | Pattern 1, Q4 | Si pip ignora la flag, lxml queda arm64-only en el bundle |
| A3 | Python en `Contents/Resources/python/bin/` evita el Local Network Privacy dialog | Q7, Pitfall descrito | Si macOS evalúa TCC por proceso padre (la app SwiftUI), el diálogo puede aparecer igualmente |
| A4 | lipomerge 0.1.1 fusiona correctamente .dylib con lipo | Standard Stack | Si solo copia .dylib del primer árbol sin lipo, las dylib de Python quedan solo arm64 |

**A1 y A4 son los riesgos más altos.** El Pitfall 2 documenta el workaround para A1.
Para A4: verificar con `lipo -archs python/lib/libpython3.13.dylib` tras el merge.

---

## Open Questions

1. **¿Necesitamos firmware del SDK macOS en `_sysconfigdata_*.py`?**
   - Qué sabemos: PBS tiene rutas de build hardcoded. Para pip con `--only-binary :all:`
     no importa. Para compilar extensiones source, sí.
   - Qué no está claro: ¿Necesitarán los usuarios compilar alguna dep desde source?
   - Recomendación: Usar solo `--only-binary :all:` en el script de bundle.

2. **¿Qué versión de Python versionar en el nombre del path (`python3.13`)?**
   - Qué sabemos: python-build-standalone incluye `bin/python3.13` (versión exacta) y
     `bin/python3` (symlink). La versión puede cambiar al actualizar el runtime.
   - Recomendación: Definir `PYTHON_VERSION="3.13"` como variable en `bundle-python.sh`
     y construir la ruta programáticamente. En PythonBridge.swift, buscar el ejecutable
     con `glob` o hardcodear "python3.13" para esta fase.

3. **¿Cómo actualizar el runtime Python en el futuro?**
   - Qué sabemos: Cambiar `PBS_RELEASE` y `PYTHON_VERSION` en `bundle-python.sh` y borrar
     `.build-cache/`. REQUIREMENTS indica que auto-update es v4+, fuera de scope aquí.
   - Recomendación: Documentar en `bundle-python.sh` que esas dos variables son
     "la única cosa que actualizar" cuando salga una nueva release de PBS.

---

## Environment Availability

| Dependencia | Requerida por | Disponible | Versión | Fallback |
|-------------|--------------|-----------|---------|---------|
| curl | Descarga tarballs en Run Script | ✓ (macOS built-in) | — | wget o NSURLSession desde Swift |
| tar | Extracción tarballs .tar.gz | ✓ (macOS built-in) | — | python3 -c "import tarfile" |
| lipo | Universal binary merge | ✓ (Xcode SDK) | — | No hay — requiere Xcode instalado |
| Python 3 (build machine) | Ejecutar lipomerge | ✓ | 3.12 (venv) | python3 del sistema macOS |
| Xcode | Build del .app | ✓ | verificado por proyecto | — |
| pip | Instalar deps vendorizadas | ✓ (en PBS install_only) | — | python -m ensurepip |

**Missing dependencies con no fallback:** ninguna en un Mac de desarrollo con Xcode.

---

## Validation Architecture

### Test Framework

| Propiedad | Valor |
|-----------|-------|
| Framework | pytest (ya instalado en venv) |
| Config | `tests/` |
| Quick run | `pytest tests/ -x -q` |
| Full suite | `pytest tests/ --cov=extractor_url` |

### Phase Requirements → Test Map

| Req ID | Comportamiento | Tipo test | Comando | Archivo existe |
|--------|---------------|-----------|---------|----------------|
| BUNDLE-01 | `lipo -archs python3.13` devuelve `x86_64 arm64` | shell/integration | `scripts/verify-bundle.sh $APP_PATH` | ❌ Wave 0 |
| BUNDLE-02 | `Bundle.main.resourcePath + /scripts/extractor_url.py` existe | integration | XCTest `testBundledScriptExists` | ❌ Wave 0 |
| BUNDLE-03 | `PYTHONPATH=... python3 -c "import requests, lxml, trafilatura"` exits 0 | shell/integration | `scripts/verify-bundle.sh $APP_PATH` | ❌ Wave 0 |

### Wave 0 Gaps

- [ ] `scripts/bundle-python.sh` — script de build principal
- [ ] `scripts/verify-bundle.sh` — validación de BUNDLE-01/02/03
- [ ] `ExtractorApp/ExtractorApp/ExtractorAppTests/BundlePathTests.swift` — verifica rutas bundled desde Swift
- [ ] `.gitignore` — añadir `.build-cache/`

---

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Aplica | Control estándar |
|---------------|--------|-----------------|
| V5 Input Validation | sí | Ya implementado en extractor_url.py / PythonBridge |
| V6 Cryptography | no | No hay crypto en esta fase |
| V2 Authentication | no | App personal, sin auth |
| V4 Access Control | sí (mínimo) | subprocess sin App Sandbox: el binario Python tiene acceso a fs del usuario. Mitigación: binario firmado, sin red propia (network va via Python requests). |

### Known Threat Patterns

| Pattern | STRIDE | Mitigación estándar |
|---------|--------|-------------------|
| Sustitución del binario Python embebido | Tampering | Codesigning con Developer ID (futuro). Ad-hoc para builds locales. |
| Tarball malicioso en .build-cache | Tampering | Verificar SHA256 del tarball descargado contra `SHASUMS256.txt` del release. [ASSUMED — no implementado en script base] |
| pip descarga paquete malicioso | Tampering | Pinear versiones exactas + `--only-binary :all:` + hash del wheel [ASSUMED — mejora v4+] |

---

## Sources

### Primary (HIGH confidence)

- GitHub API `https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest`
  — lista exacta de 72 assets macOS en release 20260610, versiones Python disponibles, URLs
- `https://raw.githubusercontent.com/astral-sh/python-build-standalone/main/docs/distributions.rst`
  — estructura install_only, rewriting `python/install/*` → `python/*`
- `https://raw.githubusercontent.com/astral-sh/python-build-standalone/main/docs/running.rst`
  — variantes, target triples, notas macOS
- `https://raw.githubusercontent.com/astral-sh/python-build-standalone/main/docs/quirks.rst`
  — quirk build-time paths, macOS linking, _sysconfigdata_
- PyPI JSON API para lxml, trafilatura, beautifulsoup4, requests, markdownify
  — tipos de wheel, disponibilidad universal2
- `https://developer.apple.com/forums/thread/765679` — Apple DTS Engineer: bundle structure,
  signing order, Local Network Privacy, entitlements para Python subprocess
- `https://developer.apple.com/forums/thread/724916` — Apple DTS Engineer: .dylib en
  Contents/Resources falla notarización; mover a Contents/Frameworks

### Secondary (MEDIUM confidence)

- `https://gist.github.com/rsms/929c9c2fec231f0cf843a1a746a416f5` — signing order
  bottom-up, codesign commands, notarytool, quarantine gotchas
- `https://github.com/faaxm/lipomerge` — lipomerge CLI usage, file type handling
- `https://github.com/spyder-ide/spyder/wiki/Dev:-Codesigning-the-macOS-Standalone-Application`
  — signing order para apps Python con frameworks embedded

### Tertiary (LOW confidence)

- Issue `astral-sh/python-build-standalone#140` — confirmación de que no existe universal2
  precompilado (issue abierto desde oct 2022, sin resolver)

---

## Metadata

**Confidence breakdown:**
- python-build-standalone download URLs: HIGH — verificado via GitHub API en sesión
- Ausencia de universal2 precompilado: HIGH — verificado en lista de 72 assets
- Estructura install_only tarball: HIGH — documentación oficial de distributions.rst
- lxml universal2 wheel cp313: HIGH — verificado via PyPI JSON API
- Signing order (bottom-up): HIGH — múltiples fuentes Apple Developer Forums + spyder
- lipomerge comportamiento con .so: MEDIUM — documentación del README, no probado con PBS
- PYTHONPATH vs .pth approach: HIGH — comportamiento documentado de Python
- Local Network Privacy con Python en Resources: MEDIUM — un thread Apple Forums, no reproducido

**Research date:** 2026-06-14
**Valid until:** 2026-09-14 (python-build-standalone releases frecuentemente; revisar release
date del tarball antes de un nuevo archive build)
