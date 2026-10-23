---
phase: 28-app-store-connect-envio
type: checkpoint-humano
status: pending
created: "2026-10-23"
---

# Checkpoint humano — Fase 28 (tras 28-01)

## A. Antes de subir

1. En Acceso a Llaveros, «Apple Distribution» y «3rd Party Mac Developer
   Installer» siguen vigentes.
2. El perfil «Extractor URL AppStore» sigue activo en developer.apple.com.
   Si caducó, descárgalo de nuevo.
3. Crea una clave de API en App Store Connect: Usuarios y acceso →
   Integraciones → App Store Connect API, rol «Developer».
   - Guarda `AuthKey_<ID>.p8` en `~/.appstoreconnect/private_keys/`.
   - Anota el Key ID y el Issuer ID.

## B. Subida (STORE-04)

```bash
APPSTORE_IDENTITY="Apple Distribution: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
INSTALLER_IDENTITY="3rd Party Mac Developer Installer: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
APPSTORE_BUILD=14 UPLOAD=1 ASC_KEY_ID=<id> ASC_ISSUER_ID=<issuer> \
scripts/package-appstore.sh
```

**Esperado:** la validación y la subida sin errores, y el build 2.3 (14) en
TestFlight tras el procesado.

## C. TestFlight (STORE-05)

Instala el 14 desde TestFlight y repite las pruebas B, C y D de
`27-funciones-bajo-sandbox/CHECKPOINT-HUMANO.md`.

## D. Ficha y envío (STORE-02/03/06)

1. Rellena la ficha con `appstore/FICHA.md` y sube las capturas.
2. Envía a revisión.
3. Pégame cualquier respuesta de App Review.

**Fin del checkpoint:** app aprobada y publicada, con la URL de la Mac App
Store.

## Progreso

- **2026-10-23:** ficha rellenada (textos de `appstore/FICHA.md`, versión
  2.3, capturas con `captura-appstore.sh` y la página de demostración) y
  «Publicar esta versión manualmente». **«Añadir a revisión» rechazado**
  por tres campos: sin build seleccionado, sin precio y sin derechos sobre
  el contenido.
- **Pendiente:** respuesta de App Review → publicar → enlace de la Mac App
  Store en `docs/index.html` y `README.md` → cerrar v11.0.
