#!/usr/bin/env bash
# release-macos.sh — Pipeline de release para ExtractorApp: build, firma
# Developer ID, notarización, empaquetado, appcast Sparkle y publicación
# en GitHub Releases.
#
# REQUISITOS PREVIOS (una sola vez, ver RELEASING.md — nunca los hace este
# script):
#   1. Clave EdDSA de Sparkle generada y SUPublicEDKey ya sustituido en
#      project.pbxproj (no el placeholder PENDIENTE-FASE-13-generate_keys).
#   2. Credenciales de notarización guardadas en el Keychain:
#      xcrun notarytool store-credentials "ExtractorApp-Notary" \
#        --apple-id <tu-apple-id> --team-id <TU-TEAM-ID> --password <contraseña-específica-de-app>
#   3. `gh auth login` ya hecho.
#
# USO:
#   scripts/release-macos.sh <version>      # ej: scripts/release-macos.sh 1.1
#
# Tras terminar, el script deja appcast.xml actualizado en la raíz del
# repo e imprime el `git add/commit/push` exacto a ejecutar — no lo hace
# automáticamente (acción visible sobre un repo compartido).
set -euo pipefail

# ── Configuración ──────────────────────────────────────────────────────────
NOTARY_PROFILE="${NOTARY_PROFILE:-ExtractorApp-Notary}"
DEVELOPER_TEAM_ID="${DEVELOPER_TEAM_ID:-V29BTBRY6G}"
GITHUB_REPO="edfrutos/extractor-url-macos"
SCHEME="ExtractorApp"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODEPROJ="${PROJECT_DIR}/ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj"
PBXPROJ="${XCODEPROJ}/project.pbxproj"

CACHE_DIR="${PROJECT_DIR}/.build-cache/release"
SPARKLE_TOOLS_DIR="${PROJECT_DIR}/.build-cache/sparkle-tools"
ARCHIVE_DIR="${CACHE_DIR}/archive"

VERSION="${1:?Uso: scripts/release-macos.sh <version, ej. 1.1>}"

# ── Validaciones previas ───────────────────────────────────────────────────
# Fallan pronto y explícito — nunca a medio pipeline con secretos a medias.
_preflight_checks() {
	if grep -q 'PENDIENTE-FASE-13' "${PBXPROJ}"; then
		echo "Error: INFOPLIST_KEY_SUPublicEDKey sigue siendo el placeholder." >&2
		echo "Ejecuta '${SPARKLE_TOOLS_DIR}/bin/generate_keys' y sustituye la clave" >&2
		echo "pública en project.pbxproj (Debug y Release) antes de publicar. Ver RELEASING.md." >&2
		exit 1
	fi

	if ! xcrun notarytool history --keychain-profile "${NOTARY_PROFILE}" >/dev/null 2>&1; then
		echo "Error: no se encontró el perfil de notarización '${NOTARY_PROFILE}' en el Keychain." >&2
		echo "Ejecuta primero:" >&2
		echo "  xcrun notarytool store-credentials \"${NOTARY_PROFILE}\" --apple-id <tu-apple-id> --team-id <TU-TEAM-ID> --password <contraseña-específica-de-app>" >&2
		echo "Ver RELEASING.md para más detalle." >&2
		exit 1
	fi

	if ! gh auth status >/dev/null 2>&1; then
		echo "Error: gh no está autenticado. Ejecuta 'gh auth login' primero." >&2
		exit 1
	fi

	if gh release view "v${VERSION}" --repo "${GITHUB_REPO}" >/dev/null 2>&1; then
		echo "Error: ya existe un release 'v${VERSION}' en ${GITHUB_REPO}." >&2
		echo "Elige una versión nueva o borra el release existente si fue un error." >&2
		exit 1
	fi
}

# ── Herramientas CLI de Sparkle (generate_keys, sign_update, generate_appcast) ──
# El paquete SPM de la app (.build-cache/Sparkle, clon de código fuente de la
# Fase 12) NO trae estos binarios precompilados — vienen aparte, del tarball
# de distribución oficial. Se descargan una vez y se cachean.
_ensure_sparkle_tools() {
	if [[ -x "${SPARKLE_TOOLS_DIR}/bin/generate_appcast" ]]; then
		return 0
	fi

	echo "Descargando herramientas CLI de Sparkle (generate_keys/sign_update/generate_appcast)…"
	mkdir -p "${SPARKLE_TOOLS_DIR}"

	local sparkle_version
	sparkle_version="$(gh api repos/sparkle-project/Sparkle/releases/latest --jq '.tag_name')"

	gh release download "${sparkle_version}" \
		--repo sparkle-project/Sparkle \
		--pattern "Sparkle-*.tar.xz" \
		--dir "${SPARKLE_TOOLS_DIR}" \
		--clobber

	tar -xf "${SPARKLE_TOOLS_DIR}"/Sparkle-*.tar.xz -C "${SPARKLE_TOOLS_DIR}"
	rm -f "${SPARKLE_TOOLS_DIR}"/Sparkle-*.tar.xz

	if [[ ! -x "${SPARKLE_TOOLS_DIR}/bin/generate_appcast" ]]; then
		echo "Error: generate_appcast no apareció tras extraer el tarball de Sparkle ${sparkle_version}." >&2
		echo "Revisa el contenido de ${SPARKLE_TOOLS_DIR} a mano." >&2
		exit 1
	fi
}

# ── Version bump (MARKETING_VERSION + CURRENT_PROJECT_VERSION) ─────────────
_bump_version() {
	local current_build
	current_build="$(grep -o 'CURRENT_PROJECT_VERSION = [0-9]*;' "${PBXPROJ}" | head -1 | grep -o '[0-9]*')"
	local next_build=$((current_build + 1))

	echo "Actualizando versión: MARKETING_VERSION=${VERSION}, CURRENT_PROJECT_VERSION=${next_build}"

	sed -i '' \
		-e "s/MARKETING_VERSION = [0-9.]*;/MARKETING_VERSION = ${VERSION};/g" \
		-e "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = ${next_build};/g" \
		"${PBXPROJ}"
}

# ── Build + export (Developer ID) ───────────────────────────────────────────
_build_and_export() {
	rm -rf "${CACHE_DIR}/ExtractorApp.xcarchive" "${CACHE_DIR}/export"
	mkdir -p "${CACHE_DIR}"

	echo "Archivando (xcodebuild archive)…"
	xcodebuild archive \
		-project "${XCODEPROJ}" \
		-scheme "${SCHEME}" \
		-archivePath "${CACHE_DIR}/ExtractorApp.xcarchive" \
		-destination 'generic/platform=macOS'

	cat >"${CACHE_DIR}/exportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>developer-id</string>
	<key>teamID</key>
	<string>${DEVELOPER_TEAM_ID}</string>
	<key>signingStyle</key>
	<string>automatic</string>
</dict>
</plist>
PLIST

	echo "Exportando (xcodebuild -exportArchive, Developer ID)…"
	xcodebuild -exportArchive \
		-archivePath "${CACHE_DIR}/ExtractorApp.xcarchive" \
		-exportPath "${CACHE_DIR}/export" \
		-exportOptionsPlist "${CACHE_DIR}/exportOptions.plist"
}

# ── Re-firmar el runtime Python embebido con Hardened Runtime ──────────────
# El firmado final que aplica `xcodebuild -exportArchive` no añade
# `--options runtime` a binarios sueltos copiados vía Build Phase (como
# Contents/Resources/python/bin/python3.13 de la Fase 8) — solo a los
# componentes que reconoce en su propio grafo (ejecutable principal,
# frameworks embebidos). notarytool los rechaza sin hardened runtime.
# Se re-firma bottom-up (igual orden que bundle-python.sh: .so → .dylib →
# python3.13) con la MISMA identidad Developer ID que ya firmó el .app, y
# se vuelve a sellar el bundle completo al final (necesario tras modificar
# contenido firmado dentro de él).
_resign_bundled_python() {
	local app_path="${CACHE_DIR}/export/${SCHEME}.app"
	local python_dir="${app_path}/Contents/Resources/python"

	if [[ ! -d "${python_dir}" ]]; then
		echo "Aviso: ${python_dir} no existe — nada que re-firmar (¿bundle Python no presente en este build?)." >&2
		return 0
	fi

	local identity
	identity="$(codesign -dv --verbose=4 "${app_path}" 2>&1 | sed -n 's/^Authority=//p' | head -1)"
	if [[ -z "${identity}" ]]; then
		echo "Error: no se pudo determinar la identidad de firma Developer ID del .app exportado." >&2
		exit 1
	fi

	echo "Re-firmando el runtime Python embebido con hardened runtime (identidad: ${identity})…"

	find "${python_dir}" -name "*.so" -exec \
		codesign --force --timestamp --options runtime --sign "${identity}" {} \;
	find "${python_dir}" -name "*.dylib" -exec \
		codesign --force --timestamp --options runtime --sign "${identity}" {} \;
	codesign --force --timestamp --options runtime --sign "${identity}" \
		"${python_dir}/bin/python3.13"

	echo "Re-sellando el .app completo tras modificar contenido firmado…"
	codesign --force --deep --timestamp --options runtime --sign "${identity}" "${app_path}"
}

# ── Empaquetado (ditto, nunca zip/unzip genéricos — Pitfall 1) ─────────────
_package() {
	local zip_path="$1"
	rm -f "${zip_path}"
	ditto -c -k --sequesterRsrc --keepParent \
		"${CACHE_DIR}/export/${SCHEME}.app" \
		"${zip_path}"
}

# ── Notarizar + staplear (orden estricto — Pitfall 2) ───────────────────────
_notarize_and_staple() {
	local zip_path="${CACHE_DIR}/${SCHEME}-${VERSION}.zip"

	_package "${zip_path}"

	echo "Enviando a notarizar (esto puede tardar varios minutos)…"
	local notary_output
	notary_output="$(xcrun notarytool submit "${zip_path}" --keychain-profile "${NOTARY_PROFILE}" --wait)"
	echo "${notary_output}"

	if ! grep -q "status: Accepted" <<<"${notary_output}"; then
		echo "Error: notarización no aceptada. Log completo arriba." >&2
		exit 1
	fi

	echo "Grapando el ticket de notarización al .app…"
	xcrun stapler staple "${CACHE_DIR}/export/${SCHEME}.app"

	# Re-empaquetar: el zip publicado debe llevar el .app YA grapado.
	_package "${zip_path}"
}

# ── Archivar históricamente (para delta updates de generate_appcast) ──────
_archive_and_generate_appcast() {
	local zip_path="${CACHE_DIR}/${SCHEME}-${VERSION}.zip"
	local zip_name="${SCHEME}-${VERSION}.zip"
	mkdir -p "${ARCHIVE_DIR}"
	cp "${zip_path}" "${ARCHIVE_DIR}/"

	echo "Generando appcast.xml (incluye histórico completo en ${ARCHIVE_DIR})…"
	"${SPARKLE_TOOLS_DIR}/bin/generate_appcast" \
		--download-url-prefix "https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/" \
		-o "${ARCHIVE_DIR}/appcast.xml" \
		"${ARCHIVE_DIR}"

	# generate_appcast no siempre añade sparkle:edSignature al enclosure
	# (comportamiento verificado en el checkpoint humano — sign_update por
	# separado sí firma de forma fiable). Si falta, la añadimos a mano.
	if ! grep -q "${zip_name}\".*sparkle:edSignature" "${ARCHIVE_DIR}/appcast.xml"; then
		echo "generate_appcast no firmó el enclosure — firmando con sign_update…"
		local sig_output ed_sig
		sig_output="$("${SPARKLE_TOOLS_DIR}/bin/sign_update" "${ARCHIVE_DIR}/${zip_name}")"
		ed_sig="$(sed -n 's/.*\(sparkle:edSignature="[^"]*"\).*/\1/p' <<<"${sig_output}")"

		if [[ -z "${ed_sig}" ]]; then
			echo "Error: sign_update no devolvió una firma EdDSA utilizable." >&2
			echo "Salida de sign_update: ${sig_output}" >&2
			exit 1
		fi

		sed -i '' "/${zip_name}/s#length=\"#${ed_sig} length=\"#" "${ARCHIVE_DIR}/appcast.xml"

		if ! grep -q "sparkle:edSignature" "${ARCHIVE_DIR}/appcast.xml"; then
			echo "Error: no se pudo insertar sparkle:edSignature en appcast.xml." >&2
			exit 1
		fi
	fi
}

# ── Publicar en GitHub Releases ────────────────────────────────────────────
_publish_release() {
	local zip_path="${ARCHIVE_DIR}/${SCHEME}-${VERSION}.zip"
	echo "Publicando release v${VERSION} en ${GITHUB_REPO}…"
	gh release create "v${VERSION}" "${zip_path}" \
		--repo "${GITHUB_REPO}" \
		--title "${SCHEME} ${VERSION}" \
		--notes "Release ${VERSION}"
}

# ── Main ─────────────────────────────────────────────────────────────────
# _ensure_sparkle_tools va ANTES de _preflight_checks a propósito: la
# primera vez que se ejecuta este script, generate_keys (necesario para
# sustituir el placeholder de SUPublicEDKey) todavía no está descargado —
# si _preflight_checks corriera primero, nunca se llegaría a descargarlo.
_ensure_sparkle_tools
_preflight_checks
_bump_version
_build_and_export
_resign_bundled_python
_notarize_and_staple
_archive_and_generate_appcast
_publish_release

cp "${ARCHIVE_DIR}/appcast.xml" "${PROJECT_DIR}/appcast.xml"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Release v${VERSION} publicado en:"
echo "  https://github.com/${GITHUB_REPO}/releases/tag/v${VERSION}"
echo ""
echo "Para activar el feed de Sparkle, revisa y publica el appcast.xml:"
echo "  cd \"${PROJECT_DIR}\""
echo "  git add appcast.xml ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj"
echo "  git commit -m \"chore(release): v${VERSION}\""
echo "  git push"
echo "════════════════════════════════════════════════════════════════"
