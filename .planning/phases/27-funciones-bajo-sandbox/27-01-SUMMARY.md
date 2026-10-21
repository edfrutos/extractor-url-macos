---
phase: 27-funciones-bajo-sandbox
plan: 01
status: complete
completed: "2026-10-21"
requirements: [SBXFEAT-01, SBXFEAT-02, SBXFEAT-03, SBXFEAT-04, SBXFEAT-05]
---

# 27-01 — Resumen

Sin compilar: el sandbox de Linux no tiene Swift. Se compila y prueba en el
Mac (`CHECKPOINT-HUMANO.md`).

## Hecho

- **Copiar (SBXFEAT-04)**
  - `ExtractionViewModel.copyResult(to:)` usa `NSPasteboard`: `.string`
    siempre y `.html` si se extrajo como HTML.
  - `didCopy` muestra «Copiado» durante 1,5 s. Si se vuelve a copiar, se
    cancela la tarea anterior.
  - Botón «Copiar» (`.bordered`, ⇧⌘C) junto a «Exportar», en las dos
    variantes.
- **Reabrir desde el historial (SBXFEAT-02)**
  - `ExtractionViewModel.reopen(_:)`: si la entrada es `file://` y
    `isReadableFile` es falso, abre el panel en la carpeta del archivo con
    el mensaje «Vuelve a elegir el archivo para darle permiso a la app».
  - `openLocalHTML()` y `reopen` comparten `chooseHTMLFile(message:in:)`.
  - `ContentView` delega en `reopen`.
- **Errores (SBXFEAT-05)**: «Abrir Ajustes…» de `isPythonPathError` va en
  `#if !APPSTORE`.
- **Tests**
  - Swift (`ViewModelTests`), con un `NSPasteboard` propio:
    - copiar texto;
    - copiar HTML;
    - sin contenido no hace nada;
    - `reopen` de una URL http.
  - pytest: el JSON de error de red y de selector inexistente es idéntico
    con y sin `--js-external`, salvo `js_render_needed`.

## Desviaciones

- **Archivo preseleccionado:** `NSOpenPanel` no permite preseleccionar un
  archivo concreto. El panel se abre en la carpeta del archivo, y basta con
  elegirlo.

## Verificación aquí

- pytest: 111 passed.
- pylint: 10/10.
- mypy: sin errores.
