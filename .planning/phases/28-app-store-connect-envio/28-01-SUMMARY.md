---
phase: 28-app-store-connect-envio
plan: 01
status: complete
completed: "2026-10-23"
commit: 8d7008e
requirements: [STORE-02, STORE-03, STORE-04]
---

# 28-01 — Resumen

- **GitHub Pages** desde `docs/` de `main`, activado con `gh api`:
  - <https://edfrutos.github.io/extractor-url-macos/> (inicio,
    `privacidad.html`, `soporte.html`);
  - HTML estático, sin JavaScript ni recursos externos, claro y oscuro.
- **Política de privacidad:**
  - no recoge datos;
  - solo se conecta a las URL del usuario;
  - caché, historial (solo metadatos) y ajustes quedan en el Mac;
  - la versión de descarga directa busca actualizaciones en GitHub, la de
    la App Store no.
- **`appstore/FICHA.md`:** todos los campos con recuento de caracteres
  (subtítulo 30/30, promo 137/170, palabras clave 97/100, descripción
  1142/4000), capturas propuestas, edades, privacidad, exportación y notas
  para App Review sobre el Python embebido (2.5.2).
  - Se quitó «Obsidian» de las palabras clave (marca de terceros, 2.3.7).
  - Se quitó «quitar imágenes / aplanar enlaces» de la descripción: solo
    existe en la CLI, no en la app.
- **Copyright** «© 2026 Eugenio de Frutos Sánchez» en los dos `Info.plist`.
- **`package-appstore.sh`:**
  - `APPSTORE_BUILD` (pasa `CURRENT_PROJECT_VERSION` a `xcodebuild
    archive`);
  - aviso si el build es 13 o menor, y con `UPLOAD=1` aborta;
  - paso 6 con `UPLOAD=1`: `altool --validate-app` y `--upload-app` con
    `ASC_KEY_ID`/`ASC_ISSUER_ID`.
  - `bash -n` y `shellcheck` limpios.
- **RELEASING.md §3.9:** clave de API, comando completo, Transporter como
  alternativa, enlaces a la ficha y a las páginas.

## Sin verificar aquí

- `xcrun altool` en el Mac: confirmar los flags con `xcrun altool --help`
  si la validación falla por argumentos.
- Que Xcode respete el `CURRENT_PROJECT_VERSION` de la línea de comandos
  en el `.app` archivado: el script imprime la versión leída del
  `Info.plist` del `.app`, que lo confirma.
