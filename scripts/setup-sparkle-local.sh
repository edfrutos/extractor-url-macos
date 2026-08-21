#!/usr/bin/env bash
# setup-sparkle-local.sh — Prepara .build-cache/Sparkle como paquete SPM
# local, sin depender de red al abrir el proyecto en Xcode.
#
# CONTEXTO: el buscador de paquetes de Xcode 26.6 falla de forma universal
# en esta máquina (ver .planning/phases/12-sparkle-integracion/12-01-SUMMARY.md),
# así que Sparkle se añade como paquete SPM local. Pero el propio
# Package.swift de Sparkle declara un binaryTarget que descarga
# Sparkle-for-Swift-Package-Manager.zip por URL — la misma clase de fallo
# de red puede repetirse ahí. Este script descarga ese .xcframework una
# vez, verifica su checksum, y parchea Package.swift para referenciarlo
# por path local — sin más dependencia de red tras la primera ejecución.
#
# Requiere: git, gh (autenticado), shasum. Idempotente — se puede
# reejecutar sin problema (sobrescribe lo que ya hubiera).
#
# ACTUALIZAR PARA NUEVA VERSIÓN: cambiar SPARKLE_TAG y SPARKLE_CHECKSUM
# (ambos visibles en Package.swift de la versión nueva de Sparkle).
set -euo pipefail

SPARKLE_TAG="2.9.6"
SPARKLE_CHECKSUM="8d5fb41d960b43f4a68aa14126bf62b098544ec8d191cdcc73eb14e63a8e7606"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="${PROJECT_DIR}/.build-cache"
SPARKLE_DIR="${CACHE_DIR}/Sparkle"

# ── 1. Clonar el código fuente de Sparkle si no está ya ────────────────────
if [[ ! -d "${SPARKLE_DIR}/.git" ]]; then
	echo "Clonando Sparkle ${SPARKLE_TAG}..."
	git clone --depth 1 --branch "${SPARKLE_TAG}" \
		https://github.com/sparkle-project/Sparkle "${SPARKLE_DIR}"
fi

# ── 2. Descargar y verificar el .xcframework prebuilt ───────────────────────
ZIP_PATH="${CACHE_DIR}/Sparkle-for-Swift-Package-Manager.zip"
echo "Descargando Sparkle-for-Swift-Package-Manager.zip (${SPARKLE_TAG})..."
gh release download "${SPARKLE_TAG}" \
	--repo sparkle-project/Sparkle \
	--pattern "Sparkle-for-Swift-Package-Manager.zip" \
	--dir "${CACHE_DIR}" \
	--clobber

ACTUAL_CHECKSUM="$(shasum -a 256 "${ZIP_PATH}" | awk '{print $1}')"
if [[ "${ACTUAL_CHECKSUM}" != "${SPARKLE_CHECKSUM}" ]]; then
	echo "Error: checksum de ${ZIP_PATH} no coincide." >&2
	echo "  esperado: ${SPARKLE_CHECKSUM}" >&2
	echo "  obtenido: ${ACTUAL_CHECKSUM}" >&2
	exit 1
fi
echo "Checksum verificado OK."

# ── 3. Extraer y colocar el .xcframework junto al Package.swift local ──────
EXTRACT_DIR="${CACHE_DIR}/sparkle-xcframework-tmp"
rm -rf "${EXTRACT_DIR}"
unzip -q -o "${ZIP_PATH}" -d "${EXTRACT_DIR}"

rm -rf "${SPARKLE_DIR}/Sparkle.xcframework"
mv "${EXTRACT_DIR}/Sparkle.xcframework" "${SPARKLE_DIR}/Sparkle.xcframework"

rm -rf "${EXTRACT_DIR}" "${ZIP_PATH}"

# ── 4. Parchear Package.swift para referenciar el path local ───────────────
cat >"${SPARKLE_DIR}/Package.swift" <<'PKGSWIFT'
// swift-tools-version:5.5
import PackageDescription

// MODIFICADO localmente (setup-sparkle-local.sh): el binaryTarget original
// apuntaba a una URL remota, que Xcode 26.6 no siempre consigue resolver.
// Referenciado aquí por path local tras verificar el checksum del
// .xcframework descargado — ver la cabecera de este script para el
// contexto completo.
let package = Package(
    name: "Sparkle",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "Sparkle",
            targets: ["Sparkle"])
    ],
    targets: [
        .binaryTarget(
            name: "Sparkle",
            path: "Sparkle.xcframework"
        )
    ]
)
PKGSWIFT

echo ""
echo "Listo. ${SPARKLE_DIR} está preparado como paquete SPM local."
echo "En Xcode: File → Add Package Dependencies… → Add Local… → selecciona ${SPARKLE_DIR}"
