#!/usr/bin/env bash
# captura-appstore.sh — Fase 28: captura la ventana de Extractor URL a
# 2880×1800 px (16:10) para la ficha de la Mac App Store.
#
# Redimensiona la ventana a 1440×900 puntos y captura ese rectángulo. En una
# pantalla Retina salen 2880×1800 px; en una no Retina, 1440×900 px (también
# válido para App Store Connect).
#
# USO:
#   scripts/appstore/captura-appstore.sh <nombre>   # → ~/Desktop/appstore-<nombre>.png
#
# Requisitos:
#   - La app abierta (proceso «ExtractorApp»).
#   - Permiso de Accesibilidad para Terminal (Ajustes del Sistema →
#     Privacidad y seguridad → Accesibilidad), para mover la ventana.
#   - Permiso de Grabación de pantalla para Terminal, para capturar.
#   - Una pantalla de al menos 1440×900 puntos libres bajo la barra de menús
#     (p. ej., «Más espacio» en un portátil).
set -euo pipefail

NAME="${1:?Uso: $0 <nombre>   (p. ej. 1-articulo)}"
PROCESS="${PROCESS:-ExtractorApp}"
WIDTH=1440
HEIGHT=900
OUT="${HOME}/Desktop/appstore-${NAME}.png"

geometry="$(osascript <<OSA
tell application "System Events" to tell process "${PROCESS}"
	set frontmost to true
	set position of front window to {0, 0}
	set size of front window to {${WIDTH}, ${HEIGHT}}
	delay 0.5
	set {x, y} to position of front window
	set {w, h} to size of front window
	return (x as text) & "," & (y as text) & "," & (w as text) & "," & (h as text)
end tell
OSA
)"
IFS=, read -r x y w h <<<"${geometry}"

if ((w != WIDTH || h != HEIGHT)); then
	echo "Error: la ventana ha quedado en ${w}×${h} puntos, no ${WIDTH}×${HEIGHT}." >&2
	echo "La pantalla es demasiado pequeña: elige «Más espacio» en Ajustes del" >&2
	echo "Sistema → Pantallas, o usa un monitor externo." >&2
	exit 1
fi

# Deja que la app termine de redibujar tras el cambio de tamaño.
sleep 1
screencapture -x -R"${x},${y},${w},${h}" "${OUT}"

px_w="$(sips -g pixelWidth "${OUT}" | awk '/pixelWidth/ {print $2}')"
px_h="$(sips -g pixelHeight "${OUT}" | awk '/pixelHeight/ {print $2}')"
echo "Captura: ${OUT} (${px_w}×${px_h} px)"
case "${px_w}x${px_h}" in
2880x1800 | 1440x900) ;;
*)
	echo "Aviso: ${px_w}×${px_h} no es un tamaño que acepte App Store Connect." >&2
	exit 1
	;;
esac
