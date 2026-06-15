#!/usr/bin/env bash
# bundle-python.sh — Descarga, merge universal y vendorize de Python para ExtractorApp
#
# ACTUALIZAR PARA NUEVA VERSIÓN: cambiar PYTHON_VERSION y PBS_RELEASE.
# Borrar .build-cache/python-standalone/ para forzar re-descarga.
#
# Requiere: lipo (Xcode SDK), lipomerge (pip install lipomerge==0.1.1)
# Se invoca desde Xcode Run Script Build Phase.
set -euo pipefail

# Xcode elimina /opt/homebrew/bin del PATH — restaurarlo para python3/lipomerge
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# ── Versiones (única sección a tocar en actualizaciones) ─────────────────────
PYTHON_VERSION="3.13.14"
PYTHON_MINOR="3.13"          # para paths lib/python3.13/
PBS_RELEASE="20260610"

# ── Variables de entorno Xcode ────────────────────────────────────────────────
# Cuando se invoca desde Xcode, estas variables están disponibles.
# Cuando se invoca manualmente para testing, el usuario debe exportarlas.
: "${BUILT_PRODUCTS_DIR:?BUILT_PRODUCTS_DIR no definido — este script se ejecuta desde Xcode}"
: "${CONTENTS_FOLDER_PATH:?CONTENTS_FOLDER_PATH no definido}"
: "${PROJECT_DIR:?PROJECT_DIR no definido}"

BASE_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PBS_RELEASE}"
ARM_TARBALL="cpython-${PYTHON_VERSION}+${PBS_RELEASE}-aarch64-apple-darwin-install_only.tar.gz"
X86_TARBALL="cpython-${PYTHON_VERSION}+${PBS_RELEASE}-x86_64-apple-darwin-install_only.tar.gz"

RESOURCES="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
PYTHON_DEST="${RESOURCES}/python"
CACHE_DIR="${PROJECT_DIR}/.build-cache/python-standalone"

# ── Cache y venv para lipomerge ───────────────────────────────────────────────
mkdir -p "${CACHE_DIR}"

# lipomerge se instala en un venv propio en .build-cache/ para no tocar
# ni el Homebrew Python (externally-managed) ni el sistema.
LIPOMERGE_VENV="${PROJECT_DIR}/.build-cache/lipomerge-venv"
if [[ ! -x "${LIPOMERGE_VENV}/bin/python3" ]]; then
  echo "Creando venv para lipomerge (primera vez)..."
  /opt/homebrew/bin/python3 -m venv "${LIPOMERGE_VENV}"
  "${LIPOMERGE_VENV}/bin/pip" install lipomerge==0.1.1 --quiet
fi
LIPOMERGE_PYTHON="${LIPOMERGE_VENV}/bin/python3"

fetch_if_needed() {
  local url="$1" dest="$2"
  if [[ ! -f "$dest" ]]; then
    echo "Descargando: $(basename "$dest")..."
    curl -L --fail --progress-bar -o "$dest" "$url"
  else
    echo "Cache hit: $(basename "$dest")"
  fi
}

fetch_if_needed "${BASE_URL}/${ARM_TARBALL}" "${CACHE_DIR}/${ARM_TARBALL}"
fetch_if_needed "${BASE_URL}/${X86_TARBALL}" "${CACHE_DIR}/${X86_TARBALL}"

# ── Extracción en directorios temporales ──────────────────────────────────────
ARM_DIR=$(mktemp -d)
X86_DIR=$(mktemp -d)
# shellcheck disable=SC2064
trap "rm -rf '${ARM_DIR}' '${X86_DIR}'" EXIT

echo "Extrayendo tarballs..."
tar -xzf "${CACHE_DIR}/${ARM_TARBALL}" -C "${ARM_DIR}"
tar -xzf "${CACHE_DIR}/${X86_TARBALL}" -C "${X86_DIR}"

# ── Merge con lipomerge (lipo recursivo) ──────────────────────────────────────
# lipomerge copia archivos idénticos (.py, .pyc, .h) del primer árbol.
# Para .a (static libs) invoca lipo -create.
# Para .so y .dylib: SOLO copia del primer árbol (arm64) — ver segundo pase.
echo "Fusionando con lipomerge..."
rm -rf "${PYTHON_DEST}"
"${LIPOMERGE_PYTHON}" -m lipomerge "${ARM_DIR}/python" "${X86_DIR}/python" "${PYTHON_DEST}"

# ── Segundo pase: lipo -create para .so de lib-dynload ───────────────────────
# Pitfall: lipomerge copia .so del primer árbol (arm64) sin fusionar.
# Este pase crea binarios universales para la stdlib de Python.
echo "Segundo pase lipo para lib-dynload .so..."
LIBDYNLOAD_ARM="${ARM_DIR}/python/lib/python${PYTHON_MINOR}/lib-dynload"
LIBDYNLOAD_X86="${X86_DIR}/python/lib/python${PYTHON_MINOR}/lib-dynload"

if [[ -d "${LIBDYNLOAD_ARM}" && -d "${LIBDYNLOAD_X86}" ]]; then
  while IFS= read -r arm_so; do
    rel="${arm_so#${ARM_DIR}/python/}"
    x86_so="${X86_DIR}/python/${rel}"
    dest="${PYTHON_DEST}/${rel}"
    if [[ -f "${x86_so}" ]]; then
      lipo -create "${arm_so}" "${x86_so}" -output "${dest}" 2>/dev/null \
        || cp "${arm_so}" "${dest}"
    fi
  done < <(find "${LIBDYNLOAD_ARM}" -name "*.so")
  echo "lib-dynload .so: segundo pase completado"
else
  echo "AVISO: lib-dynload no encontrado — omitiendo segundo pase"
fi

# Fusionar libpython .dylib (puede quedar solo arm64 tras lipomerge)
LIBPYTHON_ARM="${ARM_DIR}/python/lib/libpython${PYTHON_MINOR}.dylib"
LIBPYTHON_X86="${X86_DIR}/python/lib/libpython${PYTHON_MINOR}.dylib"
LIBPYTHON_DEST="${PYTHON_DEST}/lib/libpython${PYTHON_MINOR}.dylib"
if [[ -f "${LIBPYTHON_ARM}" && -f "${LIBPYTHON_X86}" ]]; then
  lipo -create "${LIBPYTHON_ARM}" "${LIBPYTHON_X86}" -output "${LIBPYTHON_DEST}" 2>/dev/null \
    && echo "libpython dylib: fusionada" \
    || echo "AVISO: libpython dylib no pudo fusionarse (usando arm64)"
fi

# ── Quitar quarantine (builds de desarrollo) ──────────────────────────────────
echo "Eliminando quarantine..."
xattr -rd com.apple.quarantine "${PYTHON_DEST}" 2>/dev/null || true

# ── Deps vendorizadas (BUNDLE-03) ─────────────────────────────────────────────
# --platform macosx_13_0_universal2: fuerza wheel universal2 para lxml
#   aunque la máquina de build sea arm64.
# --only-binary :all: garantiza que pip nunca compila desde source
#   (evita errores por _sysconfigdata_ paths del servidor de astral-sh).
BUNDLED_PYTHON="${PYTHON_DEST}/bin/python${PYTHON_MINOR}"
VENDORED_LIB="${PYTHON_DEST}/lib/python-packages"

echo "Instalando deps vendorizadas..."
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

# ── Codesigning bottom-up (BUNDLE-01) ────────────────────────────────────────
# Orden obligatorio: .so → .dylib → python3.13 → (Xcode firma el .app)
# EXPANDED_CODE_SIGN_IDENTITY: "-" en builds locales, Developer ID en release/archive.
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [[ -z "${IDENTITY}" ]]; then
  echo "AVISO: EXPANDED_CODE_SIGN_IDENTITY no definido, usando ad-hoc (-)"
  IDENTITY="-"
fi

echo "Codesigning bottom-up (identity: ${IDENTITY})..."

# Ad-hoc ("-") no admite --timestamp ni --options runtime.
# Con identidad real (Developer ID) se añaden ambos flags.
# Nota: se usa cadena en lugar de array para compatibilidad con bash 3.2 (macOS).
if [[ "${IDENTITY}" == "-" ]]; then
  CSIGN_EXTRA=""
else
  CSIGN_EXTRA="--timestamp --options runtime"
fi

# 1. Extensiones compiladas .so (incluye python-packages vendorizadas)
find "${PYTHON_DEST}" -name "*.so" | while IFS= read -r f; do
  # shellcheck disable=SC2086
  codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${f}" 2>/dev/null || true
done

# 2. Librerías dinámicas .dylib
find "${PYTHON_DEST}" -name "*.dylib" | while IFS= read -r f; do
  # shellcheck disable=SC2086
  codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${f}" 2>/dev/null || true
done

# 3. Ejecutable python3.13
# shellcheck disable=SC2086
codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${BUNDLED_PYTHON}"

echo "Codesigning: OK"

# ── Validación de salida ───────────────────────────────────────────────────────
ARCHS=$(lipo -archs "${BUNDLED_PYTHON}" 2>&1)
echo "Python ${PYTHON_VERSION} bundle listo — archs: ${ARCHS}"

echo "${ARCHS}" | grep -q "x86_64" || { echo "ERROR BUNDLE-01: falta x86_64 en python${PYTHON_MINOR}"; exit 1; }
echo "${ARCHS}" | grep -q "arm64"  || { echo "ERROR BUNDLE-01: falta arm64 en python${PYTHON_MINOR}";  exit 1; }

VENDORED_COUNT=$(find "${VENDORED_LIB}" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
echo "Deps vendorizadas: ${VENDORED_COUNT} paquetes en ${VENDORED_LIB}"

echo "=== bundle-python.sh: COMPLETADO ==="
