---
phase: 25-variante-build-appstore
type: checkpoint-humano
status: passed
verified: "2026-10-21"
created: "2026-10-20"
---

# Checkpoint humano — Fase 25 (tras 25-01 y 25-02)

## A. La variante Developer ID no ha cambiado (MASBUILD-01)

1. En Xcode, abre el proyecto con el esquema **ExtractorApp**, haz ⌘B y luego
   ⌘U. **Esperado:** compila y los tests pasan como antes (53, con 3 skipped).
2. Ejecuta la app (⌘R) y extrae `https://example.com` como Markdown. El menú
   debe seguir teniendo «Buscar actualizaciones…» y Ajustes, sus dos pestañas.

## B. La variante App Store compila y funciona con sandbox (MASBUILD-02/03/05)

1. Cambia al esquema **ExtractorApp AppStore**, haz ⌘B y luego ⌘R.
   Si Xcode pide equipo de firma para el target nuevo, elige el mismo que
   el de **ExtractorApp**.
2. **Esperado:**
   - El nombre que se muestra es «Extractor URL».
   - No hay «Buscar actualizaciones…».
   - Ajustes solo muestra «Modo de operación».
3. Extrae `https://example.com` como Markdown y como HTML.
   Después, «Abrir HTML…» con una página guardada. Es la duda
   abierta: el panel da permiso a la app, y hay que ver si `python3.13`
   (que hereda el sandbox) también puede leer ese archivo. Si falla, pégame
   el mensaje de error.
4. Monitor de Actividad → columna «Zona protegida»: `ExtractorApp` y
   `python3.13` deben mostrar **Sí**.
5. Comprueba que no se escribe nada dentro de la app **al extraer**. Los
   `__pycache__` que ya trae el bundle los crea `pip install` durante la
   compilación (quedan firmados con la app); lo que importa es que no
   aparezca ninguno nuevo al usarla. Con la app ya compilada y abierta:

   ```bash
   touch /tmp/antes-de-extraer
   # … extrae una URL y abre un HTML en la app …
   find ~/Library/Developer/Xcode/DerivedData/ExtractorApp-*/Build/Products/Debug-appstore/ExtractorApp.app -newer /tmp/antes-de-extraer
   ```

   La salida debe ser vacía.

## C. Empaquetado (MASBUILD-03/04)

```bash
APPSTORE_IDENTITY="Apple Distribution: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
INSTALLER_IDENTITY="3rd Party Mac Developer Installer: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
scripts/package-appstore.sh
```

Usa el perfil de `~/Downloads/Extractor_URL_AppStore.provisionprofile`;
si lo tienes en otro sitio, añade `PROVISIONING_PROFILE=/ruta/al/perfil`.

**Esperado:** todas las comprobaciones en OK y un `.pkg` en
`.build-cache/appstore/`. No hace falta subirlo: el build 13 ya está usado y
la subida real es de la Fase 28.

## Resultado (2026-10-21)

- **A:** OK en Xcode. Los dos avisos de los tests (XCTest para macOS 14.0 y
  la conformidad `Decodable` de `ManifestInfo` aislada al MainActor) ya
  existían antes y se corrigieron en `e042590`.
- **B:** OK. «Extractor URL», sin «Buscar actualizaciones…», Ajustes solo
  con «Modo de operación». Markdown y HTML de `example.com` y «Abrir HTML…»
  funcionan con sandbox (el hijo lee el archivo elegido en el panel; no hace
  falta pasar el HTML desde Swift). `ExtractorApp` y `python3.13` con
  «Zona protegida: Sí». Al extraer no se escribe nada en el bundle (los
  `__pycache__` presentes los crea `pip install` al compilar; el punto 5 se
  corrigió en `e21f4d1` para comprobar solo lo escrito al usar la app).
- **C:** OK. Todas las comprobaciones de `package-appstore.sh` pasan;
  13 Mach-O en Resources (1 ejecutable con sandbox heredado), `.app` de
  179 MB, `ExtractorURL-2.3-13.pkg` firmado con el instalador (mín. macOS
  13.5). No se sube: el build 13 ya está usado.
