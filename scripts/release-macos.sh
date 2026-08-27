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
#   scripts/release-macos.sh <version> [canal]   # ej: scripts/release-macos.sh 1.1
#                                                 #     scripts/release-macos.sh 1.1-beta.1 beta
#
# El canal es opcional. Sin él, el comportamiento es el de siempre (canal
# estable/por defecto). Con un canal (ej. "beta"), el release solo es
# visible para apps cuyo SPUUpdaterDelegate haya optado a ese canal — los
# releases estables ya publicados nunca se re-etiquetan (ver 16-RESEARCH.md).
#
# Rollout por fases (Fase 20, opcional, vía variable de entorno — no un
# argumento posicional, para no reordenar <version> [canal]):
#   ROLLOUT_INTERVAL_SECONDS=86400 scripts/release-macos.sh 1.2
# Sparkle reparte el update en 7 grupos hardcodeados; el intervalo dado es
# el tiempo entre grupo y grupo, así que la duración total del rollout es
# ROLLOUT_INTERVAL_SECONDS × 7. Ver RELEASING.md 3.6 para el detalle
# completo (incluida la limitación de "Buscar actualizaciones..." manual,
# que siempre ve la versión más reciente sin pasar por el rollout).
#
# Tras terminar, el script deja appcast.xml actualizado en la raíz del
# repo e imprime el `git add/commit/push` exacto a ejecutar — no lo hace
# automáticamente (acción visible sobre un repo compartido).
#
# IMPORTANTE sobre el tag: `gh release create "v${VERSION}"` crea el tag
# sobre el HEAD del `origin` de ese momento, que todavía NO contiene el
# commit `chore(release): v${VERSION}` (el bump de versión + appcast va en
# el paso manual de después). Por eso el eco final incluye un `git tag -f`
# + `git push -f origin "v${VERSION}"` para MOVER el tag al commit del
# release una vez commiteado. Sin ese paso, el tag apunta al commit
# anterior (fue el caso de v2.1 -> c662647 en vez de ec071d9).
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

VERSION="${1:?Uso: scripts/release-macos.sh <version, ej. 1.1> [canal, ej. beta]}"
CHANNEL="${2:-}"

# Rollout por fases (Fase 20) — opcional, vía variable de entorno (no un
# 3er argumento posicional, para no romper `<version> [canal]` ya
# establecido). Ej: ROLLOUT_INTERVAL_SECONDS=86400 scripts/release-macos.sh 1.2
ROLLOUT_INTERVAL_SECONDS="${ROLLOUT_INTERVAL_SECONDS:-}"

# ── Validaciones previas ───────────────────────────────────────────────────
# Fallan pronto y explícito — nunca a medio pipeline con secretos a medias.
_preflight_checks() {
	if [[ -n "${ROLLOUT_INTERVAL_SECONDS}" ]] && ! [[ "${ROLLOUT_INTERVAL_SECONDS}" =~ ^[0-9]+$ ]]; then
		echo "Error: ROLLOUT_INTERVAL_SECONDS debe ser un entero positivo de segundos (recibido: '${ROLLOUT_INTERVAL_SECONDS}')." >&2
		exit 1
	fi
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

	# Solo los bloques XCBuildConfiguration del target ExtractorApp — un
	# sed global sobre todo el archivo también bumpea ExtractorAppTests,
	# que comparte los mismos valores de MARKETING_VERSION/
	# CURRENT_PROJECT_VERSION por coincidencia. Cada bloque se identifica
	# por su PRODUCT_BUNDLE_IDENTIFIER exacto (no por UUID, frágil ante
	# reordenamientos de Xcode).
	local tmp
	tmp="$(mktemp)"
	awk -v version="${VERSION}" -v build="${next_build}" '
		BEGIN { in_block = 0; block = "" }
		/^\t\t[0-9A-Fa-f]+ \/\* (Debug|Release) \*\/ = \{$/ {
			in_block = 1
			block = $0 "\n"
			next
		}
		in_block && /^\t\t\};$/ {
			block = block $0 "\n"
			if (block ~ /PRODUCT_BUNDLE_IDENTIFIER = com\.edefrutos\.ExtractorApp;/) {
				gsub(/MARKETING_VERSION = [0-9.]*;/, "MARKETING_VERSION = " version ";", block)
				gsub(/CURRENT_PROJECT_VERSION = [0-9]*;/, "CURRENT_PROJECT_VERSION = " build ";", block)
			}
			printf "%s", block
			in_block = 0
			block = ""
			next
		}
		in_block {
			block = block $0 "\n"
			next
		}
		{ print }
	' "${PBXPROJ}" >"${tmp}"
	mv "${tmp}" "${PBXPROJ}"
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

# ── Re-firmar el Chromium embebido con Hardened Runtime (Fase 17) ──────────
# Mismo motivo y mismo orden bottom-up que _resign_bundled_python: el
# firmado del export de Xcode no aplica --options runtime a binarios sueltos
# en Resources/. Se firma de dentro hacia fuera: Helpers (Renderer/GPU con
# allow-jit) -> crashpad_handler -> Framework -> .app raíz -> re-sellado
# final del .app completo. Usa la MISMA identidad ya extraída por
# _resign_bundled_python (no vuelve a extraerla).
#
# Alcance: un solo árbol Chromium (arquitectura nativa del Mac de build,
# ver 17-RESEARCH.md) — si el bundle no incluye Chromium (build sin la Run
# Script Phase "Bundle Playwright Chromium", o Fase 17 aún no implementada
# en este checkout), no hay nada que re-firmar y la función no falla.
_resign_bundled_chromium() {
	local app_path="${CACHE_DIR}/export/${SCHEME}.app"
	local local_browsers="${app_path}/Contents/Resources/python/lib/python-packages/playwright/driver/package/.local-browsers"

	if [[ ! -d "${local_browsers}" ]]; then
		echo "Aviso: ${local_browsers} no existe — nada que re-firmar (¿Chromium no vendorizado en este build?)." >&2
		return 0
	fi

	local identity
	identity="$(codesign -dv --verbose=4 "${app_path}" 2>&1 | sed -n 's/^Authority=//p' | head -1)"
	if [[ -z "${identity}" ]]; then
		echo "Error: no se pudo determinar la identidad de firma Developer ID del .app exportado." >&2
		exit 1
	fi

	local chromium_dir
	chromium_dir="$(find "${local_browsers}" -maxdepth 1 -type d -name "chromium-*" | head -1)"
	# El nombre del .app no está pinneado: Playwright distribuye "Chrome for
	# Testing" (bundle "Google Chrome for Testing.app"), no "Chromium.app" —
	# se descubre por patrón, igual que en bundle-playwright.sh.
	local chromium_app
	chromium_app="$(find "${chromium_dir}" -maxdepth 3 -name "*.app" -type d 2>/dev/null | head -1)"
	if [[ -z "${chromium_app}" ]]; then
		echo "Error: ${local_browsers} existe pero no se encontró ningún .app dentro." >&2
		exit 1
	fi

	echo "Re-firmando Chromium embebido con hardened runtime (identidad: ${identity})…"

	local framework
	framework="$(find "${chromium_app}/Contents/Frameworks" -maxdepth 1 -name "*.framework" -type d 2>/dev/null | head -1)"
	local helpers_dir="${framework}/Versions/Current/Helpers"
	local renderer_entitlements="${PROJECT_DIR}/scripts/chromium-helper-jit.entitlements"

	# Una sola llamada codesign por Helper .app (firma el ejecutable interno
	# Y sella el bundle a la vez) — firmar el ejecutable y luego el .app por
	# separado resella el ejecutable sin entitlements la segunda vez,
	# borrando el allow-jit recién aplicado.
	if [[ -d "${helpers_dir}" ]]; then
		find "${helpers_dir}" -maxdepth 1 -name "*.app" | while IFS= read -r helper; do
			if [[ "${helper}" == *"(Renderer)"* || "${helper}" == *"(GPU)"* ]]; then
				codesign --force --timestamp --options runtime \
					--entitlements "${renderer_entitlements}" --sign "${identity}" "${helper}"
			else
				codesign --force --timestamp --options runtime --sign "${identity}" "${helper}"
			fi
		done

		# Cualquier ejecutable suelto en Helpers/ — por descubrimiento, no por
		# nombre fijo. Bug real (Fase 23): firmar solo chrome_crashpad_handler
		# a mano dejaba sin firmar web_app_shortcut_copier/app_mode_loader (y
		# cualquier otro que Chrome for Testing añada en el futuro) —
		# notarytool rechazó el release real v2.1 por esto exactamente
		# ("The executable does not have the hardened runtime enabled").
		find "${helpers_dir}" -maxdepth 1 -type f -perm -u+x | while IFS= read -r loose_exe; do
			codesign --force --timestamp --options runtime --sign "${identity}" "${loose_exe}"
		done
	fi

	[[ -d "${framework}" ]] && codesign --force --timestamp --options runtime --sign "${identity}" "${framework}"
	codesign --force --timestamp --options runtime --sign "${identity}" "${chromium_app}"

	# Instalaciones hermanas bajo .local-browsers/ (chromium_headless_shell-*,
	# ffmpeg-*, y cualquier otra que `playwright install chromium` traiga en
	# el futuro) — mismo bug real: el patrón `chromium-*` no cazaba
	# `chromium_headless_shell-*` (guion bajo, no guion) y `ffmpeg-*` nunca se
	# contempló; notarytool rechazó chrome-headless-shell y ffmpeg-mac del
	# release real v2.1. Son árboles planos (sin .app ni Framework) — basta
	# con firmar cada ejecutable suelto que contengan.
	find "${local_browsers}" -mindepth 1 -maxdepth 1 -type d ! -samefile "${chromium_dir}" 2>/dev/null | while IFS= read -r sibling_dir; do
		find "${sibling_dir}" -type f -perm -u+x | while IFS= read -r loose_exe; do
			codesign --force --timestamp --options runtime --sign "${identity}" "${loose_exe}"
		done
	done

	echo "Re-sellando el .app completo tras modificar contenido firmado…"
	codesign --force --deep --timestamp --options runtime --sign "${identity}" "${app_path}"
}

# ── Empaquetado (ditto, nunca zip/unzip genéricos — Pitfall 1) ─────────────
# Sin --sequesterRsrc: un .app moderno completamente firmado no usa
# resource forks HFS+ para nada — con --sequesterRsrc, ditto crea un
# __MACOSX/ paralelo dentro del zip que notarytool intenta (y no puede)
# notarizar, generando decenas de avisos "Unable to notarize __MACOSX/..."
# de puro ruido (no bloquean por sí solos, pero mejor no generarlos).
# Mismo comando que la guía oficial de notarización de Apple.
_package() {
	local zip_path="$1"
	rm -f "${zip_path}"
	ditto -c -k --keepParent \
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
		# El resumen de `submit --wait` (arriba) NO trae las razones reales
		# del rechazo, solo el id/status — hace falta pedir el log aparte.
		# Bug real (Fase 23): el mensaje anterior decía "Log completo
		# arriba", que era falso — el log de verdad no se pedía nunca.
		local submission_id
		submission_id="$(grep -m1 '^  id:' <<<"${notary_output}" | awk '{print $2}')"
		echo "Error: notarización no aceptada." >&2
		if [[ -n "${submission_id}" ]]; then
			echo "Log detallado (razones exactas del rechazo):" >&2
			xcrun notarytool log "${submission_id}" --keychain-profile "${NOTARY_PROFILE}" >&2 || true
		fi
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

	# --channel y --phased-rollout-interval solo etiquetan el item NUEVO que
	# se añade en esta ejecución (generate_appcast compara contra el
	# appcast.xml existente y solo los aplica cuando crea un item que no
	# existía — los releases ya publicados nunca se re-etiquetan, ver
	# 16-RESEARCH.md para --channel; mismo mecanismo para el rollout).
	local channel_args=()
	if [[ -n "${CHANNEL}" ]]; then
		channel_args=(--channel "${CHANNEL}")
		echo "Generando appcast.xml en el canal '${CHANNEL}' (incluye histórico completo en ${ARCHIVE_DIR})…"
	else
		echo "Generando appcast.xml (canal por defecto/estable, incluye histórico completo en ${ARCHIVE_DIR})…"
	fi

	local rollout_args=()
	if [[ -n "${ROLLOUT_INTERVAL_SECONDS}" ]]; then
		rollout_args=(--phased-rollout-interval "${ROLLOUT_INTERVAL_SECONDS}")
		echo "Rollout por fases activado: ${ROLLOUT_INTERVAL_SECONDS}s/grupo × 7 grupos (Sparkle los hardcodea) — ver RELEASING.md 3.6."
	fi

	# "${array[@]+"${array[@]}"}" (no "${array[@]}" a secas): bajo `set -u`,
	# /bin/bash 3.2 (la versión que trae macOS de serie, sin actualizar por
	# licencia GPLv2) trata un array vacío como variable no definida y
	# aborta con "unbound variable" — bash 4.4+ no tiene este problema, pero
	# no podemos asumir qué bash usa quien ejecute este script. Bug real
	# encontrado en un release real (Fase 23): ni `bash -n` ni el linter
	# estático lo detectan porque solo se manifiesta en tiempo de ejecución
	# con un array genuinamente vacío.
	"${SPARKLE_TOOLS_DIR}/bin/generate_appcast" \
		--download-url-prefix "https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}/" \
		"${channel_args[@]+"${channel_args[@]}"}" \
		"${rollout_args[@]+"${rollout_args[@]}"}" \
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
	local title="${SCHEME} ${VERSION}"
	local notes="Release ${VERSION}"
	local gh_flags=()

	if [[ -n "${CHANNEL}" ]]; then
		title="${title} (${CHANNEL})"
		notes="${notes} — canal ${CHANNEL}"
		gh_flags=(--prerelease)
	fi

	echo "Publicando release v${VERSION} en ${GITHUB_REPO}…"
	# Ver el comentario sobre "${array[@]+"${array[@]}"}" en
	# _archive_and_generate_appcast() — mismo bug real de bash 3.2 con
	# arrays vacíos bajo `set -u`.
	gh release create "v${VERSION}" "${zip_path}" \
		--repo "${GITHUB_REPO}" \
		--title "${title}" \
		--notes "${notes}" \
		"${gh_flags[@]+"${gh_flags[@]}"}"
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
_resign_bundled_chromium
_notarize_and_staple
_archive_and_generate_appcast
_publish_release

cp "${ARCHIVE_DIR}/appcast.xml" "${PROJECT_DIR}/appcast.xml"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Release v${VERSION} publicado en:"
echo "  https://github.com/${GITHUB_REPO}/releases/tag/v${VERSION}"
echo ""
echo "Para activar el feed de Sparkle, revisa y publica el appcast.xml"
echo "y MUEVE el tag v${VERSION} al commit del release:"
echo "  cd \"${PROJECT_DIR}\""
echo "  git add appcast.xml ExtractorApp/ExtractorApp/ExtractorApp.xcodeproj/project.pbxproj"
echo "  git commit -m \"chore(release): v${VERSION}\""
echo "  git push"
echo "  git tag -f \"v${VERSION}\"            # gh lo creó sobre el commit anterior"
echo "  git push -f origin \"v${VERSION}\"    # deja el tag en el commit del release"
echo "════════════════════════════════════════════════════════════════"
