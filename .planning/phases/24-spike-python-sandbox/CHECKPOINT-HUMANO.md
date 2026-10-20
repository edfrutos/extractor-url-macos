---
phase: 24-spike-python-sandbox
type: checkpoint-humano
status: pending
created: "2026-10-20"
---

# Checkpoint humano — Fase 24 (Python embebido bajo App Sandbox)

Todo en el Terminal, desde la carpeta del proyecto, en el Mac.

## Parte A — Prueba local con sandbox (no requiere nada de Apple)

1. Genera la variante con sandbox a partir del `.app` de v2.3:

   ```bash
   scripts/spike-appstore.sh local
   ```

   Termina con «Sin _tkinter ni Tcl/Tk: OK», «Intérprete con app-sandbox +
   inherit: OK» y el tamaño del `.app`.

2. Cierra cualquier ExtractorApp abierta y lanza la variante:

   ```bash
   open .build-cache/spike-appstore/ExtractorApp.app
   ```

   Si sale un aviso de Sparkle sobre actualizaciones, ciérralo: es esperado
   (sus ayudantes se han quitado; Sparkle desaparece en la Fase 25).

3. Extrae `https://example.com` como Markdown. **Esperado:** el resultado
   aparece como siempre.

4. Monitor de Actividad → menú Visualización → Columnas → activa **Sandbox**.
   Mientras extraes otra URL, `ExtractorApp` y `python3.13` deben mostrar
   **Sí**.

5. Recoge las violaciones de sandbox de los últimos minutos y pégalas:

   ```bash
   log show --last 10m --style compact --predicate 'sender == "Sandbox"' | grep -i -E "python|extractor" | tail -40
   ```

6. Opcional (adelanta la Fase 27): prueba exportar a Markdown, «Abrir HTML…»
   y el historial, y anota lo que falle.

## Parte B — Validación en App Store Connect (sin enviar a revisión)

1. **App ID** — [developer.apple.com → Identifiers](https://developer.apple.com/account/resources/identifiers/list) → **+** → App IDs → App →
   plataforma macOS, *Explicit*: `com.edefrutos.ExtractorApp.appstore`,
   descripción «Extractor URL». Sin capabilities extra.

2. **Certificados** — Xcode → Ajustes → Cuentas → tu equipo → *Gestionar
   certificados* → **+** → **Apple Distribution** y **Mac Installer
   Distribution**. Comprueba sus nombres exactos:

   ```bash
   security find-identity -v | grep "Apple Distribution"
   security find-identity -v -p basic | grep -i installer
   ```

3. **Perfil** — [Profiles](https://developer.apple.com/account/resources/profiles/list) → **+** → Distribution → **Mac App Store Connect** →
   App ID `com.edefrutos.ExtractorApp.appstore` → certificado Apple
   Distribution → descárgalo (p. ej. `~/Downloads/ExtractorURL_AppStore.provisionprofile`).

4. **Ficha** — [App Store Connect](https://appstoreconnect.apple.com) → Apps → **+** → Nueva app → macOS,
   nombre **Extractor URL**, idioma principal Español (España), bundle ID
   `com.edefrutos.ExtractorApp.appstore`, SKU `extractor-url-appstore`.
   Si el nombre está ocupado, dímelo y elegimos otro (se puede cambiar luego).

5. **Paquete** (sustituye los nombres por los del paso 2):

   ```bash
   APPSTORE_IDENTITY="Apple Distribution: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
   INSTALLER_IDENTITY="3rd Party Mac Developer Installer: Eugenio de Frutos Sanchez (V29BTBRY6G)" \
   PROVISIONING_PROFILE=~/Downloads/ExtractorURL_AppStore.provisionprofile \
   scripts/spike-appstore.sh package
   ```

   Si alguna identidad sale como ambigua (como pasó con Developer ID), usa
   su hash SHA-1 de `security find-identity -v`.

6. **Transporter** (gratis en la Mac App Store) → inicia sesión → arrastra
   `.build-cache/spike-appstore/ExtractorURL-spike.pkg` → **Entregar**.
   Transporter valida antes de subir. Esto **no** envía nada a revisión:
   como mucho, el build aparece en TestFlight.

7. Pega aquí el resultado: los errores de Transporter, o «Entregado» más el
   correo que Apple envía tras procesar el build (puede avisar, por ejemplo,
   de que falta el manifiesto de privacidad; eso es de la Fase 25).
