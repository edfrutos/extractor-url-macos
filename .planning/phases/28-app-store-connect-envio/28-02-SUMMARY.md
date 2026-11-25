---
phase: 28-app-store-connect-envio
plan: 02
status: complete
completed: "2026-11-25"
requirements: [STORE-01, STORE-02, STORE-03, STORE-05, STORE-06]
---

# 28-02 — Resumen

Extractor URL 2.3 (15) publicada en la Mac App Store, gratis, desde el
2026-11-19: <https://apps.apple.com/es/app/extractor-url/id6825046299?mt=12>.

- **2026-10-23:** 2.3 (14) subida y enviada a App Review.
- **2026-11-01:** rechazada por la 2.5.2 (`itms-services` en
  `urllib/parse.py`). Corregido en `bundle-python.sh` y
  `package-appstore.sh` (`a5c68bd`); build 15 subida y reenviada.
- **2026-11-03:** rechazada por la 4.3 y la 4.2.6. Contestadas las 9
  preguntas de App Review sin enviar otra build.
- **2026-11-19:** publicada.

## Verificación

- Ficha pública y API de búsqueda de Apple (2026-11-25): versión 2.3, gratis,
  bundle `com.edefrutos.ExtractorApp.appstore`, «No se recopilan datos».
- Confirmado por el usuario (2026-11-25): la 2.3 (15) funciona en la App
  Store y en TestFlight. No consta la fecha de la prueba en TestFlight.

## Desviaciones

- El enlace a la tienda está en `README.md` y en efjdev.com, no en
  `docs/index.html`, que desde `b61c12a` solo redirige a efjdev.com.

## Pendiente para la próxima versión

- Cambiar en App Store Connect las URL de github.io por las de
  `appstore/FICHA.md`.
