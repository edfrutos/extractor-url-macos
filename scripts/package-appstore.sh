#!/usr/bin/env bash
# package-appstore.sh — Fase 25: archiva el esquema «ExtractorApp AppStore»
# y genera el .pkg firmado para App Store Connect. Sustituye a
# spike-appstore.sh (Fase 24), del que hereda la firma ya validada.
#
# Qué hace:
#   1. xcodebuild archive del esquema «ExtractorApp AppStore» (sin Sparkle
#      ni Chromium; bundle-python.sh ya quita Tcl/Tk y Playwright).
#   2. Copia el .app del archivo y le embebe el perfil de aprovisionamiento.
#   3. Firma de dentro a fuera con Apple Distribution: librerías sin
#      entitlements, ejecutables de Resources (python3.13) con app-sandbox +
#      inherit, y el .app con sus entitlements + application-identifier.
#   4. Comprobaciones (firma, sin Sparkle/Tcl/Playwright, inherit, sin
#      cuarentena, manifiesto de privacidad).
#   5. productbuild firmado → .build-cache/appstore/ExtractorURL-<versión>-<build>.pkg
#   6. Con UPLOAD=1, valida y sube el .pkg a App Store Connect con altool y
#      una clave de la API de App Store Connect (Fase 28).
#
# No usa `xcodebuild -exportArchive`: en macOS, el export app-store-connect
# produce directamente el .pkg y no deja re-firmar el Python de Resources,
# que el export no firma con los entitlements de hijo.
#
# Sin UPLOAD=1, la subida es manual con Transporter.
# Cada subida necesita un número de build nuevo: APPSTORE_BUILD lo fija sin
# tocar el proyecto (ver RELEASING.md).
#
# USO:
#   APPSTORE_IDENTITY="Apple Distribution: …" \
#   INSTALLER_IDENTITY="3rd Party Mac Developer Installer: …" \
#   APPSTORE_BUILD=14 UPLOAD=1 ASC_KEY_ID=… ASC_ISSUER_ID=… \
#   scripts/package-appstore.sh
#
# Variables de entorno:
#   APPSTORE_IDENTITY     "Apple Distribution: …" o su hash SHA-1.
#   INSTALLER_IDENTITY    "3rd Party Mac Developer Installer: …" /
#                         "Mac Installer Distribution: …" o su hash.
#   PROVISIONING_PROFILE  .provisionprofile Mac App Store del bundle ID
#                         com.edefrutos.ExtractorApp.appstore (por defecto,
#                         ~/Downloads/Extractor_URL_AppStore.provisionprofile).
#   APPSTORE_BUILD        Número de build (CFBundleVersion) para este archivo.
#                         Si falta, se usa el CURRENT_PROJECT_VERSION del target.
#   UPLOAD                1 para validar y subir el .pkg con altool.
#   ASC_KEY_ID            Key ID de la clave de API de App Store Connect; su
#                         .p8 debe estar en ~/.appstoreconnect/private_keys/
#                         como AuthKey_<ASC_KEY_ID>.p8 (solo con UPLOAD=1).
#   ASC_ISSUER_ID         Issuer ID de esa clave (solo con UPLOAD=1).
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODEPROJ="${PROJECT_DIR}/ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj"
SCHEME="ExtractorApp AppStore"

BUNDLE_ID="com.edefrutos.ExtractorApp.appstore"
TEAM_ID="V29BTBRY6G"
OUT_DIR="${PROJECT_DIR}/.build-cache/appstore"
ARCHIVE="${OUT_DIR}/ExtractorApp-AppStore.xcarchive"
APP="${OUT_DIR}/ExtractorApp.app"
PY="${APP}/Contents/Resources/python"
APP_ENTITLEMENTS_SRC="${PROJECT_DIR}/ExtractorApp/ExtractorApp/ExtractorApp/ExtractorApp-AppStore.entitlements"
CHILD_ENTITLEMENTS="${PROJECT_DIR}/scripts/appstore/python-child.entitlements"
PLISTBUDDY="/usr/libexec/PlistBuddy"

IDENTITY="${APPSTORE_IDENTITY:?Define APPSTORE_IDENTITY (Apple Distribution)}"
: "${INSTALLER_IDENTITY:?Define INSTALLER_IDENTITY (3rd Party Mac Developer Installer)}"
PROVISIONING_PROFILE="${PROVISIONING_PROFILE:-${HOME}/Downloads/Extractor_URL_AppStore.provisionprofile}"
[[ -f "${PROVISIONING_PROFILE}" ]] || {
	echo "Error: no existe ${PROVISIONING_PROFILE}" >&2
	echo "Descárgalo de developer.apple.com (perfil «Extractor URL AppStore») o" >&2
	echo "indica su ruta con PROVISIONING_PROFILE=…" >&2
	exit 1
}

UPLOAD="${UPLOAD:-0}"
if [[ "${UPLOAD}" == "1" ]]; then
	: "${ASC_KEY_ID:?Define ASC_KEY_ID (clave de API de App Store Connect)}"
	: "${ASC_ISSUER_ID:?Define ASC_ISSUER_ID (Issuer ID de la clave)}"
	ASC_KEY_FILE="${HOME}/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
	[[ -f "${ASC_KEY_FILE}" ]] || {
		echo "Error: no existe ${ASC_KEY_FILE}" >&2
		echo "Descarga la clave de App Store Connect (Usuarios y acceso →" >&2
		echo "Integraciones) y guárdala con ese nombre." >&2
		exit 1
	}
fi

BUILD_OVERRIDE=()
if [[ -n "${APPSTORE_BUILD:-}" ]]; then
	[[ "${APPSTORE_BUILD}" =~ ^[0-9]+$ ]] || {
		echo "Error: APPSTORE_BUILD debe ser un número entero (es «${APPSTORE_BUILD}»)." >&2
		exit 1
	}
	BUILD_OVERRIDE=("CURRENT_PROJECT_VERSION=${APPSTORE_BUILD}")
fi

# ── 1. Archivo ───────────────────────────────────────────────────────────────
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

echo "Archivando (xcodebuild archive, esquema «${SCHEME}»)…"
xcodebuild archive \
	-project "${XCODEPROJ}" \
	-scheme "${SCHEME}" \
	-archivePath "${ARCHIVE}" \
	-destination 'generic/platform=macOS' \
	${BUILD_OVERRIDE[@]+"${BUILD_OVERRIDE[@]}"}

ditto "${ARCHIVE}/Products/Applications/ExtractorApp.app" "${APP}"

INFO="${APP}/Contents/Info.plist"
VERSION="$("${PLISTBUDDY}" -c "Print :CFBundleShortVersionString" "${INFO}")"
BUILD="$("${PLISTBUDDY}" -c "Print :CFBundleVersion" "${INFO}")"
echo "Versión ${VERSION} (${BUILD})"
# Los builds hasta el 13 ya están usados en App Store Connect (spike de la
# Fase 24).
if ((BUILD <= 13)); then
	echo "Aviso: el build ${BUILD} ya está usado en App Store Connect y lo" >&2
	echo "rechazará. Usa APPSTORE_BUILD=<n> con un número mayor." >&2
	if [[ "${UPLOAD}" == "1" ]]; then
		exit 1
	fi
fi

# ── 2. Perfil y entitlements ─────────────────────────────────────────────────
APP_ENTITLEMENTS="${OUT_DIR}/app.entitlements"
cp "${APP_ENTITLEMENTS_SRC}" "${APP_ENTITLEMENTS}"
"${PLISTBUDDY}" -c "Add :com.apple.application-identifier string ${TEAM_ID}.${BUNDLE_ID}" "${APP_ENTITLEMENTS}"
"${PLISTBUDDY}" -c "Add :com.apple.developer.team-identifier string ${TEAM_ID}" "${APP_ENTITLEMENTS}"
cp "${PROVISIONING_PROFILE}" "${APP}/Contents/embedded.provisionprofile"

# App Store Connect rechaza ficheros con el atributo de cuarentena (error 91109).
# Se limpia ya con todo copiado: el perfil recién descargado también lo trae.
xattr -cr "${APP}"

# ── 3. Firma de dentro a fuera ───────────────────────────────────────────────
echo "Firmando con: ${IDENTITY}"
SIGN_FLAGS=(--force --options runtime --timestamp --sign "${IDENTITY}")

# Todo el código nativo de Resources, del más profundo al menos profundo.
# Ejecutables → entitlements de hijo (sandbox heredado); librerías → sin
# entitlements.
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

# ── 4. Comprobaciones ────────────────────────────────────────────────────────
echo ""
echo "Verificando firma…"
codesign --verify --deep --strict --verbose=2 "${APP}"

if [[ "$("${PLISTBUDDY}" -c "Print :CFBundleIdentifier" "${INFO}")" != "${BUNDLE_ID}" ]]; then
	echo "Error: el identificador del .app no es ${BUNDLE_ID}." >&2
	exit 1
fi
if "${PLISTBUDDY}" -c "Print :SUFeedURL" "${INFO}" >/dev/null 2>&1; then
	echo "Error: Info.plist sigue teniendo SUFeedURL (Sparkle)." >&2
	exit 1
fi
main_libs="$(otool -L "${APP}/Contents/MacOS/ExtractorApp")"
if [[ -e "${APP}/Contents/Frameworks/Sparkle.framework" || "${main_libs}" == *Sparkle* ]]; then
	echo "Error: el .app sigue llevando o enlazando Sparkle." >&2
	exit 1
fi
echo "Sin Sparkle: OK"

leftover="$(find "${APP}" \( -name '_tkinter*' -o -iname 'libtcl*' -o -iname 'libtk*' \
	-o -path '*/python-packages/playwright' \) -print)"
if [[ -n "${leftover}" ]]; then
	echo "Error: siguen quedando restos de Tcl/Tk o Playwright:" >&2
	echo "${leftover}" >&2
	exit 1
fi
while IFS= read -r f; do
	if otool -L "${f}" 2>/dev/null | grep -qi 'tcl\|libtk'; then
		echo "Error: ${f} sigue enlazando Tcl/Tk." >&2
		exit 1
	fi
done <"${macho_list}"
echo "Sin _tkinter, Tcl/Tk ni Playwright: OK"

python_bin="${PY}/bin/python3.13"
child_ents="$(codesign -d --entitlements - "${python_bin}" 2>/dev/null || true)"
if [[ "${child_ents}" != *com.apple.security.inherit* ]]; then
	echo "Error: el intérprete no tiene com.apple.security.inherit." >&2
	exit 1
fi
echo "Intérprete con app-sandbox + inherit: OK"

if [[ ! -f "${APP}/Contents/Resources/PrivacyInfo.xcprivacy" ]]; then
	echo "Error: falta PrivacyInfo.xcprivacy en Resources." >&2
	exit 1
fi
echo "Manifiesto de privacidad: OK"

if xattr -lr "${APP}" | grep -q 'com.apple.quarantine'; then
	echo "Error: quedan ficheros con com.apple.quarantine en el .app." >&2
	exit 1
fi
echo "Sin atributo de cuarentena: OK"
echo "Tamaño del .app: $(du -sh "${APP}" | cut -f1)"

# ── 5. Paquete para App Store Connect ───────────────────────────────────────
PKG="${OUT_DIR}/ExtractorURL-${VERSION}-${BUILD}.pkg"
productbuild --component "${APP}" /Applications --sign "${INSTALLER_IDENTITY}" "${PKG}"
echo ""
echo "Paquete listo: ${PKG}"

if [[ "${UPLOAD}" != "1" ]]; then
	echo "Para subirlo: open -a Transporter \"${PKG}\" y pulsa «Entregar»,"
	echo "o vuelve a ejecutar con UPLOAD=1 (ver RELEASING.md)."
	echo "Recuerda: App Store Connect rechaza un build (${BUILD}) ya subido."
	exit 0
fi

# ── 6. Validación y subida ──────────────────────────────────────────────────
# altool busca el .p8 en ~/.appstoreconnect/private_keys/ por su Key ID.
ALTOOL_ARGS=(--type macos -f "${PKG}" --apiKey "${ASC_KEY_ID}" --apiIssuer "${ASC_ISSUER_ID}")

echo ""
echo "Validando en App Store Connect…"
xcrun altool --validate-app "${ALTOOL_ARGS[@]}"

echo ""
echo "Subiendo ${VERSION} (${BUILD})…"
xcrun altool --upload-app "${ALTOOL_ARGS[@]}"

echo ""
echo "Subido. El build aparecerá en TestFlight cuando App Store Connect lo"
echo "procese (suele tardar unos minutos; llega un correo al terminar)."
