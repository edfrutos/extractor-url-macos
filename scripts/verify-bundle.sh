#!/usr/bin/env bash
# verify-bundle.sh — Valida BUNDLE-01, BUNDLE-02, BUNDLE-03
# Uso: ./scripts/verify-bundle.sh [/path/to/ExtractorApp.app]
#
# Sin argumento: busca el .app más reciente en DerivedData de Xcode.
set -euo pipefail

PASS=0
FAIL=0

ok()   { echo "  OK : $*"; ((PASS++)) || true; }
fail() { echo "  FAIL: $*" >&2; ((FAIL++)) || true; }

# ── Localizar el .app ─────────────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
  APP="$1"
else
  APP=$(find ~/Library/Developer/Xcode/DerivedData -name "ExtractorApp.app" \
        -not -path "*/Index.noindex/*" \
        2>/dev/null | head -1)
  if [[ -z "$APP" ]]; then
    echo "ERROR: No se encontró ExtractorApp.app. Pasa la ruta como argumento." >&2
    echo "  Uso: $0 /path/to/ExtractorApp.app" >&2
    exit 1
  fi
fi

echo "Validando bundle: $APP"
echo ""

RESOURCES="${APP}/Contents/Resources"

# ── BUNDLE-01: Universal Python binary ───────────────────────────────────────
echo "=== BUNDLE-01: Intérprete Python universal (arm64+x86_64) ==="
PYTHON="${RESOURCES}/python/bin/python3.13"

if [[ -f "${PYTHON}" ]]; then
  if [[ -x "${PYTHON}" ]]; then
    ok "python3.13 existe y es ejecutable"
  else
    fail "python3.13 existe pero no es ejecutable"
  fi

  ARCHS=$(lipo -archs "${PYTHON}" 2>&1)
  if echo "${ARCHS}" | grep -q "x86_64"; then
    ok "arquitectura x86_64 presente (archs: ${ARCHS})"
  else
    fail "arquitectura x86_64 AUSENTE (archs: ${ARCHS})"
  fi

  if echo "${ARCHS}" | grep -q "arm64"; then
    ok "arquitectura arm64 presente"
  else
    fail "arquitectura arm64 AUSENTE"
  fi

  if codesign --verify --strict "${PYTHON}" 2>/dev/null; then
    ok "python3.13 tiene firma de código válida"
  else
    fail "python3.13 no tiene firma de código válida (puede fallar en distribución)"
  fi

  VERSION=$("${PYTHON}" --version 2>&1)
  ok "versión: ${VERSION}"
else
  fail "python3.13 NO encontrado en ${PYTHON}"
fi

echo ""

# ── BUNDLE-02: Scripts en Resources/scripts/ ──────────────────────────────────
echo "=== BUNDLE-02: Scripts Python en Resources/scripts/ ==="
SCRIPTS_DIR="${RESOURCES}/scripts"

for script in extractor_url.py core.py; do
  if [[ -f "${SCRIPTS_DIR}/${script}" ]]; then
    ok "${script} presente en scripts/"
  else
    fail "${script} NO encontrado en ${SCRIPTS_DIR}/"
  fi
done

echo ""

# ── BUNDLE-03: Deps vendorizadas importables ──────────────────────────────────
echo "=== BUNDLE-03: Deps Python vendorizadas importables ==="
VENDORED_LIB="${RESOURCES}/python/lib/python-packages"

if [[ -d "${VENDORED_LIB}" ]]; then
  ok "directorio python-packages existe"
else
  fail "directorio python-packages NO encontrado en ${VENDORED_LIB}"
fi

if [[ -x "${PYTHON}" ]]; then
  IMPORT_TEST=$(PYTHONPATH="${VENDORED_LIB}" "${PYTHON}" -c "
import sys
failed = []
for pkg in ['requests', 'bs4', 'lxml', 'markdownify', 'trafilatura']:
    try:
        m = __import__(pkg)
        ver = getattr(m, '__version__', 'unknown')
        print(f'OK: {pkg} {ver}')
    except ImportError as e:
        failed.append(f'{pkg}: {e}')
        print(f'FAIL: {pkg} — {e}', file=sys.stderr)
if failed:
    sys.exit(1)
" 2>&1) || true

  if echo "${IMPORT_TEST}" | grep -q "^FAIL:"; then
    fail "algunas deps no son importables:"
    echo "${IMPORT_TEST}" | grep "^FAIL:" | sed 's/^/    /' >&2
  else
    echo "${IMPORT_TEST}" | sed 's/^OK:/    ok :/'
    ((PASS += 5)) || true
  fi

  echo ""
  echo "=== Test funcional: extraer https://example.com ==="
  SCRIPT="${SCRIPTS_DIR}/extractor_url.py"
  if [[ -f "${SCRIPT}" ]]; then
    RESULT=$(PYTHONPATH="${VENDORED_LIB}" "${PYTHON}" "${SCRIPT}" \
      https://example.com --type text --json 2>&1) || true
    if echo "${RESULT}" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('status')=='success' or d.get('success') else 1)" 2>/dev/null; then
      ok "extracción de example.com devolvió JSON con success=true"
    else
      fail "extracción de example.com falló o no devolvió JSON válido"
      echo "  Output: ${RESULT:0:200}" >&2
    fi
  else
    fail "Script principal ${SCRIPT} no encontrado — omitiendo test funcional"
  fi
fi

# ── BUNDLEJS-01/02: Chromium vendorizado (Fase 17) ────────────────────────────
echo ""
echo "=== BUNDLEJS-01: Chromium vendorizado (arquitectura nativa) ==="
LOCAL_BROWSERS="${VENDORED_LIB}/playwright/driver/package/.local-browsers"

if [[ -d "${LOCAL_BROWSERS}" ]]; then
  CHROMIUM_COUNT=$(find "${LOCAL_BROWSERS}" -maxdepth 1 -type d -name "chromium-*" | wc -l | tr -d ' ')
  if [[ "${CHROMIUM_COUNT}" -eq 1 ]]; then
    ok "un único árbol chromium-* presente (alcance: arquitectura nativa)"
  else
    fail "se esperaba exactamente 1 árbol chromium-*, encontrados: ${CHROMIUM_COUNT}"
  fi

  CHROMIUM_DIR=$(find "${LOCAL_BROWSERS}" -maxdepth 1 -type d -name "chromium-*" | head -1)
  # El nombre del .app no está pinneado: Playwright distribuye "Chrome for
  # Testing" (bundle "Google Chrome for Testing.app"), no "Chromium.app" —
  # se descubre por patrón, igual que en bundle-playwright.sh.
  CHROMIUM_APP=$(find "${CHROMIUM_DIR}" -maxdepth 3 -name "*.app" -type d 2>/dev/null | head -1)

  if [[ -n "${CHROMIUM_APP}" ]]; then
    ok ".app de Chromium encontrado en ${CHROMIUM_APP}"

    if codesign --verify --deep --strict "${CHROMIUM_APP}" 2>/dev/null; then
      ok "$(basename "${CHROMIUM_APP}") tiene firma de código válida (--deep --strict)"
    else
      fail "$(basename "${CHROMIUM_APP}") NO tiene firma de código válida"
    fi

    CHROMIUM_FRAMEWORK=$(find "${CHROMIUM_APP}/Contents/Frameworks" -maxdepth 1 -name "*.framework" -type d 2>/dev/null | head -1)
    RENDERER_HELPER=$(find "${CHROMIUM_FRAMEWORK}/Versions/Current/Helpers" \
      -maxdepth 1 -name "*(Renderer)*.app" 2>/dev/null | head -1)
    if [[ -n "${RENDERER_HELPER}" ]]; then
      if codesign -d --entitlements - "${RENDERER_HELPER}" 2>/dev/null | grep -q "allow-jit"; then
        ok "Helper (Renderer) tiene com.apple.security.cs.allow-jit"
      else
        fail "Helper (Renderer) NO tiene com.apple.security.cs.allow-jit"
      fi
    else
      fail "No se encontró ningún Helper (Renderer).app dentro de $(basename "${CHROMIUM_FRAMEWORK}")/Versions/Current/Helpers"
    fi

    echo ""
    echo "=== BUNDLEJS-02: Fallback JS embebido funciona end-to-end ==="
    RENDER_TEST=$(PLAYWRIGHT_BROWSERS_PATH=0 PYTHONPATH="${VENDORED_LIB}" "${PYTHON}" -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.launch()
    page = b.new_page()
    page.goto('https://example.com')
    assert 'Example Domain' in page.content()
    b.close()
print('OK')
" 2>&1) || true
    if echo "${RENDER_TEST}" | grep -q "^OK$"; then
      ok "Chromium embebido renderiza example.com correctamente"
    else
      fail "Chromium embebido no pudo renderizar example.com"
      echo "  Output: ${RENDER_TEST:0:300}" >&2
    fi
  else
    fail "ningún .app de Chromium encontrado dentro de ${CHROMIUM_DIR}"
  fi
else
  fail "directorio .local-browsers NO encontrado en ${LOCAL_BROWSERS} — ¿bundle-playwright.sh no se ejecutó?"
fi

# ── Resumen ───────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════"
echo "  Resultado: ${PASS} OK  |  ${FAIL} FAIL"
echo "═══════════════════════════════════════════════════"

if [[ ${FAIL} -gt 0 ]]; then
  echo "  BUNDLE VALIDATION: FAILED" >&2
  exit 1
else
  echo "  BUNDLE VALIDATION: PASS — BUNDLE-01, BUNDLE-02, BUNDLE-03 satisfechos"
  exit 0
fi
