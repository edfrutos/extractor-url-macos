#!/usr/bin/env bash
# spike-appstore.sh — Fase 24 (spike): convierte un ExtractorApp.app ya
# compilado (Developer ID) en una variante App Store con App Sandbox, sin
# tocar el proyecto de Xcode (eso es la Fase 25).
#
# Qué hace sobre una COPIA del .app:
#   1. Quita Chromium/Playwright, _tkinter + Tcl/Tk y los ejecutables
#      auxiliares de Sparkle (incompatibles con la App Store).
#   2. Cambia el identificador a com.edefrutos.ExtractorApp.appstore y añade
#      las claves de Info.plist que exige la App Store.
#   3. Firma de dentro a fuera: librerías sin entitlements, el intérprete
#      Python con app-sandbox + inherit, y el .app con sandbox.
#   4. En modo `package`, embebe el perfil de aprovisionamiento y genera el
#      .pkg firmado para validarlo/subirlo con Transporter.
#
# USO:
#   scripts/spike-appstore.sh local   [ruta/ExtractorApp.app]
#   scripts/spike-appstore.sh package [ruta/ExtractorApp.app]
#
# Por defecto usa el .app exportado por el último release
# (.build-cache/release/export/ExtractorApp.app).
#
# Variables de entorno:
#   LOCAL_IDENTITY        (local)   identidad para firmar; por defecto el hash
#                                   Developer ID de release-macos.sh.
#   APPSTORE_IDENTITY     (package) "Apple Distribution: …" o su hash SHA-1.
#   INSTALLER_IDENTITY    (package) "3rd Party Mac Developer Installer: …" /
#                                   "Mac Installer Distribution: …" o su hash.
#   PROVISIONING_PROFILE  (package) ruta al .provisionprofile Mac App Store
#                                   del bundle ID com.edefrutos.ExtractorApp.appstore.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:?Uso: scripts/spike-appstore.sh <local|package> [ruta/ExtractorApp.app]}"
SRC_APP="${2:-${PROJECT_DIR}/.build-cache/release/export/ExtractorApp.app}"

BUNDLE_ID="com.edefrutos.ExtractorApp.appstore"
DISPLAY_NAME="Extractor URL"
TEAM_ID="V29BTBRY6G"
OUT_DIR="${PROJECT_DIR}/.build-cache/spike-appstore"
APP="${OUT_DIR}/ExtractorApp.app"
PY="${APP}/Contents/Resources/python"
APP_ENTITLEMENTS_SRC="${PROJECT_DIR}/scripts/appstore/app.entitlements"
CHILD_ENTITLEMENTS="${PROJECT_DIR}/scripts/appstore/python-child.entitlements"
PLISTBUDDY="/usr/libexec/PlistBuddy"

case "${MODE}" in
local)
	IDENTITY="${LOCAL_IDENTITY:-68EB89B63EB50E9229ED253962950A8D9D13EBF0}"
	;;
package)
	IDENTITY="${APPSTORE_IDENTITY:?Define APPSTORE_IDENTITY (Apple Distribution)}"
	: "${INSTALLER_IDENTITY:?Define INSTALLER_IDENTITY (Mac Installer Distribution)}"
	: "${PROVISIONING_PROFILE:?Define PROVISIONING_PROFILE (.provisionprofile Mac App Store)}"
	[[ -f "${PROVISIONING_PROFILE}" ]] || {
		echo "Error: no existe ${PROVISIONING_PROFILE}" >&2
		exit 1
	}
	;;
*)
	echo "Error: modo desconocido '${MODE}' (usa local o package)." >&2
	exit 1
	;;
esac

if [[ ! -d "${SRC_APP}" ]]; then
	echo "Error: no existe ${SRC_APP}." >&2
	echo "Compila primero (release-macos.sh deja el .app en .build-cache/release/export/)" >&2
	echo "o pasa la ruta de un ExtractorApp.app como segundo argumento." >&2
	exit 1
fi

# ── 1. Copia ─────────────────────────────────────────────────────────────────
echo "Copiando ${SRC_APP} → ${APP}"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
ditto "${SRC_APP}" "${APP}"

# Los scripts del .app de origen pueden ser anteriores a los cambios de la
# variante App Store (p. ej. el import opcional de tkinter): se usan los del repo.
echo "Copiando core.py y extractor_url.py del repo…"
cp "${PROJECT_DIR}/core.py" "${PROJECT_DIR}/extractor_url.py" "${APP}/Contents/Resources/scripts/"

# ── 2. Quitar lo incompatible con la App Store ──────────────────────────────
echo "Quitando Playwright/Chromium…"
find "${PY}/lib/python-packages" -maxdepth 1 \( -iname 'playwright*' -o -iname 'greenlet*' -o -iname 'pyee*' \) \
	-exec rm -rf {} +

# Rechazo real documentado: _tkinter enlaza Tcl, cuyos símbolos App Review
# marca como API no pública (foro Apple 758567). La app no usa la GUI tkinter.
echo "Quitando _tkinter y Tcl/Tk…"
find "${PY}" -name '_tkinter*.so' -delete
rm -rf "${PY}/lib/python3.13/tkinter" "${PY}/lib/python3.13/idlelib" \
	"${PY}/lib/python3.13/turtledemo" "${PY}/lib/python3.13/turtle.py"
find "${PY}/lib" -maxdepth 1 \( -iname 'tcl*' -o -iname 'tk*' -o -iname 'itcl*' \
	-o -iname 'thread*' -o -iname 'libtcl*' -o -iname 'libtk*' \) -exec rm -rf {} +

# Sparkle se queda enlazado (la app lo importa hasta la Fase 25), pero sin sus
# ejecutables auxiliares: no tienen sandbox y no pintan nada en la App Store.
echo "Quitando ejecutables auxiliares de Sparkle…"
for version_dir in "${APP}/Contents/Frameworks/Sparkle.framework/Versions/"*/; do
	rm -rf "${version_dir}XPCServices" "${version_dir}Autoupdate" "${version_dir}Updater.app"
done
rm -f "${APP}/Contents/Frameworks/Sparkle.framework/XPCServices" \
	"${APP}/Contents/Frameworks/Sparkle.framework/Autoupdate" \
	"${APP}/Contents/Frameworks/Sparkle.framework/Updater.app"
rm -rf "${APP}/Contents/_CodeSignature" "${APP}/Contents/CodeResources"

# ── 3. Info.plist ────────────────────────────────────────────────────────────
INFO="${APP}/Contents/Info.plist"
"${PLISTBUDDY}" -c "Set :CFBundleIdentifier ${BUNDLE_ID}" "${INFO}"
"${PLISTBUDDY}" -c "Delete :CFBundleDisplayName" "${INFO}" 2>/dev/null || true
"${PLISTBUDDY}" -c "Add :CFBundleDisplayName string ${DISPLAY_NAME}" "${INFO}"
"${PLISTBUDDY}" -c "Delete :LSApplicationCategoryType" "${INFO}" 2>/dev/null || true
"${PLISTBUDDY}" -c "Add :LSApplicationCategoryType string public.app-category.productivity" "${INFO}"
"${PLISTBUDDY}" -c "Delete :ITSAppUsesNonExemptEncryption" "${INFO}" 2>/dev/null || true
"${PLISTBUDDY}" -c "Add :ITSAppUsesNonExemptEncryption bool false" "${INFO}"

# App Store Connect rechaza ficheros con el atributo de cuarentena.
xattr -cr "${APP}"

# ── 4. Entitlements del .app ─────────────────────────────────────────────────
APP_ENTITLEMENTS="${OUT_DIR}/app.entitlements"
cp "${APP_ENTITLEMENTS_SRC}" "${APP_ENTITLEMENTS}"
if [[ "${MODE}" == "package" ]]; then
	"${PLISTBUDDY}" -c "Add :com.apple.application-identifier string ${TEAM_ID}.${BUNDLE_ID}" "${APP_ENTITLEMENTS}"
	"${PLISTBUDDY}" -c "Add :com.apple.developer.team-identifier string ${TEAM_ID}" "${APP_ENTITLEMENTS}"
	cp "${PROVISIONING_PROFILE}" "${APP}/Contents/embedded.provisionprofile"
fi

# ── 5. Firma de dentro a fuera ───────────────────────────────────────────────
echo "Firmando con: ${IDENTITY}"
SIGN_FLAGS=(--force --options runtime --sign "${IDENTITY}")
if [[ "${IDENTITY}" != "-" ]]; then
	SIGN_FLAGS+=(--timestamp)
fi

# Todo el código nativo de Resources (runtime Python), del más profundo al
# menos profundo. Ejecutables → entitlements de hijo (sandbox heredado);
# librerías/bundles → sin entitlements.
macho_list="${OUT_DIR}/macho.txt"
find "${APP}/Contents/Resources" -type f -print0 |
	while IFS= read -r -d '' f; do
		if file -b "${f}" | grep -q 'Mach-O'; then
			printf '%s\t%s\n' "$(awk -F/ '{print NF}' <<<"${f}")" "${f}"
		fi
	done | sort -rn | cut -f2- >"${macho_list}"

child_count=0
while IFS= read -r f; do
	if file -b "${f}" | grep -q 'executable'; then
		codesign "${SIGN_FLAGS[@]}" --entitlements "${CHILD_ENTITLEMENTS}" "${f}"
		child_count=$((child_count + 1))
	else
		codesign "${SIGN_FLAGS[@]}" "${f}"
	fi
done <"${macho_list}"
echo "Código nativo en Resources: $(wc -l <"${macho_list}" | tr -d ' ') ficheros (${child_count} ejecutables con sandbox heredado)"

for fw in "${APP}/Contents/Frameworks/"*; do
	[[ -e "${fw}" ]] || continue
	codesign "${SIGN_FLAGS[@]}" "${fw}"
done

codesign "${SIGN_FLAGS[@]}" --entitlements "${APP_ENTITLEMENTS}" "${APP}"

# ── 6. Comprobaciones ────────────────────────────────────────────────────────
echo ""
echo "Verificando firma…"
codesign --verify --deep --strict --verbose=2 "${APP}"

leftover_tcl="$(find "${APP}" \( -name '_tkinter*' -o -iname 'libtcl*' -o -iname 'libtk*' \) -print)"
if [[ -n "${leftover_tcl}" ]]; then
	echo "Error: siguen quedando restos de Tcl/Tk:" >&2
	echo "${leftover_tcl}" >&2
	exit 1
fi
while IFS= read -r f; do
	if otool -L "${f}" 2>/dev/null | grep -qi 'tcl\|libtk'; then
		echo "Error: ${f} sigue enlazando Tcl/Tk." >&2
		exit 1
	fi
done <"${macho_list}"
echo "Sin _tkinter ni Tcl/Tk: OK"

python_bin="${PY}/bin/python3.13"
if ! codesign -d --entitlements - "${python_bin}" 2>/dev/null | grep -q 'com.apple.security.inherit'; then
	echo "Error: el intérprete no tiene com.apple.security.inherit." >&2
	exit 1
fi
echo "Intérprete con app-sandbox + inherit: OK"
echo "Tamaño del .app: $(du -sh "${APP}" | cut -f1)"

if [[ "${MODE}" == "local" ]]; then
	echo ""
	echo "Listo para probar en local:"
	echo "  open \"${APP}\""
	exit 0
fi

# ── 7. Paquete para App Store Connect ───────────────────────────────────────
PKG="${OUT_DIR}/ExtractorURL-spike.pkg"
productbuild --component "${APP}" /Applications --sign "${INSTALLER_IDENTITY}" "${PKG}"
echo ""
echo "Paquete listo: ${PKG}"
echo "Ábrelo con Transporter y pulsa «Entregar»: valida el paquete y, si lo"
echo "acepta, lo deja en App Store Connect (TestFlight) SIN enviarlo a revisión."
