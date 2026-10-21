# Research: Fase 27 — Funciones de la app bajo sandbox

*Investigado: 2026-10-21, sobre el código en `3ab4adf`.*

## Estado de cada requisito

| Req. | Qué hace hoy la app | Bajo sandbox | Trabajo |
|---|---|---|---|
| SBXFEAT-01 Exportar MD/HTML/PDF | `NSSavePanel` + `write(to:)`. PDF con `createPDF` del `WKWebView` visible. MD reconvierte con la CLI. | El panel da acceso de escritura (`files.user-selected.read-write`). La reconversión a MD ya funciona (Fase 26, B.4). | Solo verificar HTML y PDF en el Mac. |
| SBXFEAT-02 «Abrir HTML…» | `NSOpenPanel` → `file://` → la CLI lo lee. | Verificado en la Fase 25 (B.3): el hijo hereda el permiso. | **Hueco:** reabrir desde el historial un `file://` tras relanzar la app. El permiso del panel solo dura la sesión, así que Python no puede leerlo. |
| SBXFEAT-03 Historial | Python escribe en `Path.home()/.cache/extractor-url/history.jsonl`. `HistoryEntry.loadAll()` lee de `homeDirectoryForCurrentUser`. | Con sandbox, las dos rutas resuelven al contenedor (`~/Library/Containers/com.edefrutos.ExtractorApp.appstore/Data`). Verificado en la Fase 26: la entrada aparece. | Solo verificar que persiste tras relanzar. El historial de Developer ID no se ve en App Store: son apps distintas, y es lo esperado. |
| SBXFEAT-04 Portapapeles | **La app no copia nada.** Solo la CLI tiene `--clipboard` (`pbcopy`), y la app no lo usa. | `NSPasteboard` funciona con sandbox sin entitlements. | **Añadir** un botón «Copiar» en la app (las dos variantes). |
| SBXFEAT-05 Errores iguales | `PythonBridge` → «El extractor Python devolvió un error: … Detalle: <stderr>». | Mismo formato. Diferencias conocidas: (a) con 401/403, Developer ID reintenta con Chromium antes de fallar, así que el «Detalle» cambia; (b) con `pythonNotFound` se muestra «Abrir Ajustes…», y en App Store Ajustes no tiene rutas. | Ocultar «Abrir Ajustes…» en App Store. Test pytest: el JSON de error es idéntico con y sin `--js-external`, salvo la clave nueva. |

## Decisiones

- **Copiar en las dos variantes.**
  - Es una mejora de la app, no algo propio del sandbox. Mantener las dos
    variantes iguales evita más `#if`.
  - Copia `resultContent` tal como se extrajo (texto, HTML o Markdown) como
    texto plano. Si el tipo es HTML, también lo copia como `.html`.
  - Atajo ⌘⇧C. Confirmación breve «Copiado».
- **Reabrir un `file://` sin permiso:** si `FileManager.isReadableFile` es
  falso, la app abre un `NSOpenPanel` ya situado en esa carpeta y con el
  archivo preseleccionado, con el mensaje «Vuelve a elegir el archivo para
  darle permiso a la app».
  - **Descartado: marcadores de seguridad** (`bookmarks.app-scope`). Exigen
    otro entitlement y guardar los marcadores en otro sitio, porque el
    historial lo escribe Python. Es mucho para un caso raro.
  - En Developer ID el archivo es legible y nada cambia.
- **Errores:** no se intenta igualar el «Detalle» del 403. Depende de
  Chromium, que no existe en App Store. Lo que se iguala es el formato y el
  mensaje principal.

## Fuera de alcance

- Sincronizar o migrar el historial entre las dos variantes.
- Arrastrar archivos a la ventana (no existe hoy).
