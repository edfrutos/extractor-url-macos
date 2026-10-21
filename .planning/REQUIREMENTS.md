


---

## Active (v11.0 — Mac App Store)

Decisiones del usuario (2026-10-20): conviven Developer ID/Sparkle y App Store;
JS en la variante App Store vía `WKWebView`; app gratuita. Ver
`.planning/research/APPSTORE.md`.

### SBX — Python embebido bajo App Sandbox (Phase 24)

- [x] **SBX-01**: Un build con App Sandbox activado lanza el intérprete Python embebido (firmado con `app-sandbox` + `inherit`) y completa una extracción de una URL estática.
- [x] **SBX-02**: El código nativo del runtime Python (intérprete, `.so`, `.dylib`) está en una ubicación del bundle que firma y valida correctamente; la decisión (`Resources` vs `Frameworks`/`Helpers`) queda documentada con evidencia.
- [x] **SBX-03**: El bundle App Store no contiene `_tkinter` ni Tcl/Tk.
- [x] **SBX-04**: El `.app` del spike pasa la validación de App Store Connect (`xcodebuild -exportArchive` método App Store + validación/subida) sin enviarse a revisión.

### MASBUILD — Variante de build App Store (Phase 25)

- [x] **MASBUILD-01**: Existe una configuración/esquema App Store con un flag de compilación propio; la variante Developer ID compila y se publica exactamente como antes.
- [x] **MASBUILD-02**: La variante App Store no incluye Sparkle, `RuntimeUpdater`, Chromium/Playwright ni la configuración de rutas a un Python/script externos.
- [x] **MASBUILD-03**: Entitlements mínimos de la variante App Store: sandbox, red cliente y ficheros elegidos por el usuario; el intérprete hijo, solo `app-sandbox` + `inherit`.
- [x] **MASBUILD-04**: La variante App Store incluye `PrivacyInfo.xcprivacy`, `LSApplicationCategoryType` e `ITSAppUsesNonExemptEncryption` según la documentación vigente de Apple.
- [x] **MASBUILD-05**: Python no escribe dentro del bundle (sin `.pyc` en tiempo de ejecución; cachés/logs en el contenedor de la app).

### WKJS — Renderizado JavaScript con WKWebView (Phase 26)

- [x] **WKJS-01**: La CLI acepta HTML ya renderizado junto con su URL de origen, y resuelve enlaces e imágenes contra esa URL; con tests.
- [x] **WKJS-02**: La variante App Store renderiza la página en un `WKWebView` oculto con timeout y pasa el HTML resultante a Python.
- [x] **WKJS-03**: El renderizado con `WKWebView` solo se usa cuando el contenido estático es insuficiente (misma heurística que hoy decide usar Chromium), respetando los modos de JS existentes.
- [x] **WKJS-04**: Si el renderizado falla o agota el tiempo, la extracción degrada al HTML estático con un aviso, sin abortar.

### SBXFEAT — Funciones de la app bajo sandbox (Phase 27)

- [ ] **SBXFEAT-01**: Exportar a Markdown, HTML y PDF funciona en la variante App Store.
- [ ] **SBXFEAT-02**: «Abrir HTML…» funciona con el acceso concedido por `NSOpenPanel`.
- [ ] **SBXFEAT-03**: El historial se guarda y se recupera dentro del contenedor de la app.
- [ ] **SBXFEAT-04**: Copiar al portapapeles usa `NSPasteboard` desde la app (sin `pbcopy`).
- [ ] **SBXFEAT-05**: Los errores (red, 403, selector, timeout) se muestran igual que en la variante Developer ID.

### STORE — App Store Connect y envío (Phase 28)

- [ ] **STORE-01**: Certificados Apple Distribution + Mac Installer Distribution y perfil Mac App Store listos; app registrada en App Store Connect.
- [ ] **STORE-02**: Ficha en español: nombre, subtítulo, descripción, palabras clave, capturas de Mac, categoría, clasificación por edades, precio gratuito.
- [ ] **STORE-03**: Política de privacidad y URL de soporte publicadas; etiqueta de privacidad «Datos no recopilados».
- [ ] **STORE-04**: Script reproducible de subida (archivar → exportar para App Store → subir), documentado en `RELEASING.md` junto al de Developer ID.
- [ ] **STORE-05**: Build probado por TestFlight en un Mac real antes del envío.
- [ ] **STORE-06**: La app es aprobada por App Review y queda publicada en la Mac App Store.

## Out of Scope (v11.0)

- Usar `WKWebView` en la variante Developer ID (sigue con Chromium); se puede valorar después.
- Compras in-app / StoreKit (la app es gratuita).
- Ficha de App Store en otros idiomas además del español.
- Exponer la CLI en la variante App Store.
- Retirar la distribución Developer ID/Sparkle.
