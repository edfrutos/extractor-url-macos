#!/usr/bin/env bash
# package-dmg.sh — Crea un DMG firmado con Developer ID, notarizado y grapado
# con la app ya publicada por release-macos.sh, para la descarga directa
# desde https://efjdev.com/extractor-url/.
#
# No recompila nada: parte del .app que release-macos.sh ya firmó,
# notarizó y grapó. Por defecto usa .build-cache/release/export/ExtractorApp.app
# si es de la versión pedida; si no, extrae .build-cache/release/ExtractorApp-<version>.zip.
#
# REQUISITOS (los mismos que release-macos.sh, ver RELEASING.md):
#   - Certificado Developer ID Application en el Keychain.
#   - Perfil de notarización guardado:
#       xcrun notarytool store-credentials "ExtractorApp-Notary" ...
#
# USO:
#   scripts/package-dmg.sh <version> [ruta a ExtractorApp.app o .zip]
#   scripts/package-dmg.sh 2.3
#
# Resultado: .build-cache/release/ExtractorURL-<version>.dmg, más su SHA-256.
set -euo pipefail

# ── Configuración (mismos valores por defecto que release-macos.sh) ────────
NOTARY_PROFILE="${NOTARY_PROFILE:-ExtractorApp-Notary}"
# SHA-1 del certificado Developer ID Application, nunca por nombre: hay dos
# certificados con el mismo common name (ver release-macos.sh).
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:-68EB89B63EB50E9229ED253962950A8D9D13EBF0}"
SCHEME="ExtractorApp"
VOLUME_NAME="Extractor URL"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${PROJECT_DIR}/.build-cache/release"

VERSION="${1:?Uso: scripts/package-dmg.sh <version, ej. 2.3> [ruta .app o .zip]}"
SOURCE="${2:-}"
DMG_PATH="${CACHE_DIR}/ExtractorURL-${VERSION}.dmg"

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/extractor-dmg.XXXXXX")"
trap 'rm -rf "${WORK_DIR}"' EXIT

_fail() {
	echo "Error: $*" >&2
	exit 1
}

_app_version() {
	/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$1/Contents/Info.plist" 2>/dev/null || true
}

# ── Localizar el .app de origen ─────────────────────────────────────────────
_resolve_app() {
	local export_app="${CACHE_DIR}/export/${SCHEME}.app"
	local release_zip="${CACHE_DIR}/${SCHEME}-${VERSION}.zip"

	if [[ -z "${SOURCE}" ]]; then
		if [[ -d "${export_app}" && "$(_app_version "${export_app}")" == "${VERSION}" ]]; then
			SOURCE="${export_app}"
		elif [[ -f "${release_zip}" ]]; then
			SOURCE="${release_zip}"
		else
			_fail "no encuentro la app ${VERSION} en ${export_app} ni ${release_zip}. Pasa la ruta como segundo argumento."
		fi
	fi

	case "${SOURCE}" in
		*.zip)
			[[ -f "${SOURCE}" ]] || _fail "no existe ${SOURCE}"
			echo "Extrayendo ${SOURCE}…"
			# ditto, no unzip: conserva firma, atributos extendidos y el ticket grapado.
			ditto -x -k "${SOURCE}" "${WORK_DIR}/zip"
			APP_PATH="${WORK_DIR}/zip/${SCHEME}.app"
			;;
		*.app | *.app/)
			APP_PATH="${SOURCE%/}"
			;;
		*)
			_fail "el origen debe ser un .app o un .zip: ${SOURCE}"
			;;
	esac

	[[ -d "${APP_PATH}" ]] || _fail "no existe ${APP_PATH}"
	local found
	found="$(_app_version "${APP_PATH}")"
	[[ "${found}" == "${VERSION}" ]] || _fail "la app es la versión '${found}', no la ${VERSION}."
}

# ── Comprobar que la app ya está firmada, notarizada y grapada ─────────────
_check_app() {
	echo "Comprobando la firma de ${APP_PATH}…"
	codesign --verify --deep --strict "${APP_PATH}" ||
		_fail "la firma de la app no es válida. Vuelve a generarla con release-macos.sh."
	if ! xcrun stapler validate "${APP_PATH}" >/dev/null 2>&1; then
		_fail "la app no lleva el ticket de notarización grapado. Usa la app exportada por release-macos.sh."
	fi
	spctl --assess --type execute "${APP_PATH}" ||
		_fail "Gatekeeper rechaza la app."
}

# ── Crear el DMG ────────────────────────────────────────────────────────────
_create_dmg() {
	local staging="${WORK_DIR}/staging"
	mkdir -p "${staging}"
	ditto "${APP_PATH}" "${staging}/${SCHEME}.app"
	ln -s /Applications "${staging}/Applications"

	rm -f "${DMG_PATH}"
	echo "Creando ${DMG_PATH}…"
	# ULFO (LZFSE): buena compresión y se abre en cualquier macOS >= 10.11.
	hdiutil create \
		-volname "${VOLUME_NAME}" \
		-srcfolder "${staging}" \
		-fs HFS+ \
		-format ULFO \
		-ov \
		"${DMG_PATH}"
}

# ── Firmar, notarizar y grapar el DMG ──────────────────────────────────────
_sign_dmg() {
	echo "Firmando el DMG…"
	codesign --force --timestamp --sign "${CODESIGN_IDENTITY}" "${DMG_PATH}"
	codesign --verify --strict "${DMG_PATH}"
}

_notarize_dmg() {
	echo "Enviando el DMG a notarizar (puede tardar varios minutos)…"
	local notary_output
	notary_output="$(xcrun notarytool submit "${DMG_PATH}" --keychain-profile "${NOTARY_PROFILE}" --wait)"
	echo "${notary_output}"

	if ! grep -q "status: Accepted" <<<"${notary_output}"; then
		# El resumen de `submit --wait` no trae las razones del rechazo: hay
		# que pedir el log aparte (mismo caso que en release-macos.sh).
		local submission_id
		submission_id="$(grep -m1 '^  id:' <<<"${notary_output}" | awk '{print $2}')"
		echo "Error: notarización del DMG no aceptada." >&2
		if [[ -n "${submission_id}" ]]; then
			echo "Log detallado:" >&2
			xcrun notarytool log "${submission_id}" --keychain-profile "${NOTARY_PROFILE}" >&2 || true
		fi
		exit 1
	fi

	echo "Grapando el ticket al DMG…"
	xcrun stapler staple "${DMG_PATH}"
	xcrun stapler validate "${DMG_PATH}"
}

_final_checks() {
	echo "Comprobando el DMG con Gatekeeper…"
	spctl --assess --type open --context context:primary-signature --verbose=2 "${DMG_PATH}"
}

# ── Main ───────────────────────────────────────────────────────────────────
[[ "$(uname -s)" == "Darwin" ]] || _fail "este script solo funciona en macOS."

_resolve_app
_check_app
_create_dmg
_sign_dmg
_notarize_dmg
_final_checks

SIZE_BYTES="$(stat -f%z "${DMG_PATH}")"
SHA256="$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "DMG listo: ${DMG_PATH}"
echo "  Tamaño:  ${SIZE_BYTES} bytes"
echo "  SHA-256: ${SHA256}"
echo ""
echo "Súbelo por Plesk/SFTP a /httpdocs/wp-content/uploads/descargas/ y"
echo "quedará en:"
echo "  https://efjdev.com/wp-content/uploads/descargas/$(basename "${DMG_PATH}")"
echo "════════════════════════════════════════════════════════════════"
