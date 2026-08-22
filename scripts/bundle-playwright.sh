#!/usr/bin/env bash
# bundle-playwright.sh — Instala y firma Chromium (Playwright) para ExtractorApp
#
# ALCANCE: UNA sola arquitectura — la nativa del Mac de build (normalmente
# arm64). Decisión de alcance explícita del usuario tras 17-RESEARCH.md
# (dos árboles arm64+x64 sin fusionar rondan 500-700MB y requieren Rosetta 2
# en el Mac de build). En la arquitectura NO nativa, el fallback JS embebido
# simplemente no está disponible: _fetch_via_playwright() en core.py ya
# captura ese fallo y degrada a HTML estático, mismo comportamiento que
# Playwright no instalado (sin cambios necesarios en core.py).
#
# ACTUALIZAR PARA NUEVA VERSIÓN: cambiar PLAYWRIGHT_VERSION en
# bundle-python.sh (playwright==X.Y.Z) — Chromium queda 1:1 atado a esa
# versión, no se pinnea por separado aquí.
#
# Requiere: el intérprete Python bundleado por bundle-python.sh, que debe
# haberse ejecutado ANTES (Run Script Phase "Bundle Python Runtime" precede
# a "Bundle Playwright Chromium" en project.pbxproj).
# Se invoca desde Xcode Run Script Build Phase.
set -euo pipefail

# Xcode elimina /opt/homebrew/bin del PATH — restaurarlo para xattr/codesign.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

: "${BUILT_PRODUCTS_DIR:?BUILT_PRODUCTS_DIR no definido — este script se ejecuta desde Xcode}"
: "${CONTENTS_FOLDER_PATH:?CONTENTS_FOLDER_PATH no definido}"
: "${PROJECT_DIR:?PROJECT_DIR no definido}"

RESOURCES="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
BUNDLED_PYTHON="${RESOURCES}/python/bin/python3.13"
VENDORED_LIB="${RESOURCES}/python/lib/python-packages"

if [[ ! -x "${BUNDLED_PYTHON}" ]]; then
  echo "Error: ${BUNDLED_PYTHON} no existe o no es ejecutable." >&2
  echo "  bundle-python.sh debe ejecutarse antes que este script." >&2
  exit 1
fi

# ── Instalar Chromium (una sola pasada, arquitectura nativa) ────────────────
export PYTHONPATH="${VENDORED_LIB}"
export PLAYWRIGHT_BROWSERS_PATH=0   # binarios dentro de playwright/driver/package/.local-browsers/

echo "Instalando Chromium (arquitectura nativa del Mac de build)..."
"${BUNDLED_PYTHON}" -m playwright install chromium

LOCAL_BROWSERS="${VENDORED_LIB}/playwright/driver/package/.local-browsers"
CHROMIUM_DIR=$(find "${LOCAL_BROWSERS}" -maxdepth 1 -type d -name "chromium-*" 2>/dev/null | head -1)
if [[ -z "${CHROMIUM_DIR}" ]]; then
  echo "Error: no se encontró ningún directorio chromium-* en ${LOCAL_BROWSERS}" >&2
  exit 1
fi

# El nombre del .app no está pinneado: Playwright 1.62.0 distribuye
# "Chrome for Testing" (bundle "Google Chrome for Testing.app"), no el
# "Chromium.app" clásico de versiones anteriores — se descubre por patrón
# en vez de hardcodear el nombre, para no romper de nuevo ante otro cambio
# de naming aguas arriba.
CHROMIUM_APP=$(find "${CHROMIUM_DIR}" -maxdepth 3 -name "*.app" -type d 2>/dev/null | head -1)
if [[ -z "${CHROMIUM_APP}" ]]; then
  echo "Error: no se encontró ningún .app dentro de ${CHROMIUM_DIR}" >&2
  exit 1
fi

# ── Quitar quarantine (builds de desarrollo) ─────────────────────────────────
echo "Eliminando quarantine..."
xattr -rd com.apple.quarantine "${CHROMIUM_DIR}" 2>/dev/null || true

# ── Codesigning bottom-up (BUNDLEJS-01) ──────────────────────────────────────
# Orden obligatorio: Helpers -> crashpad_handler -> Framework -> .app raíz
# EXPANDED_CODE_SIGN_IDENTITY: "-" en builds locales, Developer ID en release/archive.
IDENTITY="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [[ -z "${IDENTITY}" ]]; then
  echo "AVISO: EXPANDED_CODE_SIGN_IDENTITY no definido, usando ad-hoc (-)"
  IDENTITY="-"
fi

# Ad-hoc ("-") no admite --timestamp ni --options runtime.
if [[ "${IDENTITY}" == "-" ]]; then
  CSIGN_EXTRA=""
else
  CSIGN_EXTRA="--timestamp --options runtime"
fi

RENDERER_ENTITLEMENTS="${PROJECT_DIR}/../../scripts/chromium-helper-jit.entitlements"

echo "Codesigning bottom-up del árbol Chromium (identity: ${IDENTITY})..."

# Igual que el .app, el nombre del .framework no está pinneado (mismo
# motivo). Los Helpers cuelgan de Versions/Current/Helpers -- la
# convención estándar de framework versioning de macOS, no de
# Framework/Helpers directamente.
FRAMEWORK=$(find "${CHROMIUM_APP}/Contents/Frameworks" -maxdepth 1 -name "*.framework" -type d 2>/dev/null | head -1)
if [[ -z "${FRAMEWORK}" ]]; then
  echo "Error: no se encontró ningún .framework dentro de ${CHROMIUM_APP}/Contents/Frameworks" >&2
  exit 1
fi
HELPERS_DIR="${FRAMEWORK}/Versions/Current/Helpers"

# 1. Helpers — una sola llamada codesign por bundle .app (firma el
#    ejecutable interno Y sella el bundle a la vez). Firmar el ejecutable
#    y luego el .app por separado resella el ejecutable sin entitlements
#    la segunda vez, borrando el allow-jit recién aplicado.
#    Solo (Renderer)/(GPU) reciben allow-jit — el resto se firma sin
#    entitlements adicionales (ver Anti-Patterns en 17-RESEARCH.md: el
#    app-entitlements.plist completo de Chromium trae entitlements de App
#    Sandbox que no aplican, ExtractorApp tiene sandbox OFF).
if [[ -d "${HELPERS_DIR}" ]]; then
  find "${HELPERS_DIR}" -maxdepth 1 -name "*.app" | while IFS= read -r helper; do
    if [[ "${helper}" == *"(Renderer)"* || "${helper}" == *"(GPU)"* ]]; then
      # shellcheck disable=SC2086
      codesign --force $CSIGN_EXTRA --entitlements "${RENDERER_ENTITLEMENTS}" \
        --sign "${IDENTITY}" "${helper}" 2>/dev/null || true
    else
      # shellcheck disable=SC2086
      codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${helper}" 2>/dev/null || true
    fi
  done

  # 2. crashpad_handler (ejecutable suelto, sin entitlements especiales).
  if [[ -f "${HELPERS_DIR}/chrome_crashpad_handler" ]]; then
    # shellcheck disable=SC2086
    codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" \
      "${HELPERS_DIR}/chrome_crashpad_handler" 2>/dev/null || true
  fi
else
  echo "AVISO: ${HELPERS_DIR} no encontrado — omitiendo firma de Helpers" >&2
fi

# 3. El framework completo.
if [[ -d "${FRAMEWORK}" ]]; then
  # shellcheck disable=SC2086
  codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${FRAMEWORK}"
fi

# 4. El .app raíz en sí.
# shellcheck disable=SC2086
codesign --force $CSIGN_EXTRA --sign "${IDENTITY}" "${CHROMIUM_APP}"

echo "Codesigning Chromium: OK"

# ── Validación de salida (informativa, no bloqueante) ────────────────────────
echo "Chromium bundle listo en: ${CHROMIUM_DIR}"
du -sh "${CHROMIUM_DIR}" 2>/dev/null || true

echo "=== bundle-playwright.sh: COMPLETADO ==="
