# Phase 6: Export PDF - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-12
**Phase:** 06-export-pdf
**Areas discussed:** Origen del render, Formato y apariencia, Nombre sugerido, Feedback de errores

---

## Origen del render

| Option | Description | Selected |
|--------|-------------|----------|
| Preview visible (Recomendado) | Llamar .pdf() sobre el WKWebView que ya muestra el contenido; WYSIWYG, contentReady ya lo protege, sin render duplicado | ✓ |
| WKWebView offscreen dedicado | WebView oculto con ancho fijo; PDF consistente pero segundo render y más timing | |
| Tú decides | Claude elige | |

| Option | Description | Selected |
|--------|-------------|----------|
| WYSIWYG estricto (Recomendado) | El ancho del PDF sigue al de la ventana; minWidth 500 + max-width 800px acotan el rango | ✓ |
| Ancho mínimo en el PDF | Forzar rect de captura con ancho mínimo 800pt | |

**User's choice:** Preview visible + WYSIWYG estricto.

---

## Formato y apariencia

| Option | Description | Selected |
|--------|-------------|----------|
| Página única continua (Recomendado) | Comportamiento natural de WKWebView.pdf(); texto seleccionable, cero páginas en blanco | ✓ |
| Paginado tipo A4 | Exigiría NSPrintOperation (contradice decisión de milestone) o post-proceso | |

| Option | Description | Selected |
|--------|-------------|----------|
| Forzar modo claro (Recomendado) | Fondo blanco/texto negro siempre; documento portable | ✓ |
| Respetar el tema del sistema | WYSIWYG total, PDFs con fondo oscuro | |

**User's choice:** Página única continua + modo claro forzado.
**Notes:** Forzar claro desde el webview visible implica override temporal de apariencia durante la captura (detalle para research).

---

## Nombre sugerido

| Option | Description | Selected |
|--------|-------------|----------|
| Añadir title al contrato JSON (Recomendado) | Ampliar CLI Python --json con el `<title>` + campo opcional en ExtractionResult; toca Python + Swift + tests | ✓ |
| Derivar del contenido (como MD/HTML) | Reutilizar suggestedFilename actual; reinterpreta el criterio del ROADMAP | |
| Derivar de la URL | host/path de la URL; requiere guardar la URL en el ViewModel | |

| Option | Description | Selected |
|--------|-------------|----------|
| Los tres formatos (Recomendado) | MD, HTML y PDF usan el título; suggestedFilename unificado | ✓ |
| Solo PDF | MD/HTML mantienen el prefijo de 50 chars | |

| Option | Description | Selected |
|--------|-------------|----------|
| Prefijo del contenido (Recomendado) | Fallback: 50 chars sanitizados; si vacío, "export" | ✓ |
| Nombre fijo "export" | Sin título → export.pdf | |

**User's choice:** Title en el contrato JSON, aplicado a los tres formatos, con fallback al prefijo de contenido.
**Notes:** Hallazgo previo a la pregunta: ExtractionResult no tiene campo title (verificado en código); el criterio del ROADMAP lo exigía implícitamente.

---

## Feedback de errores

| Option | Description | Selected |
|--------|-------------|----------|
| Alerta visible (Recomendado) | NSAlert con el mensaje de error; un fallo silencioso pierde el documento | ✓ |
| Solo consola (como MD/HTML) | Mantener print() de Phase 5 | |
| Alerta para los 3 formatos | Subir también MD/HTML a alerta | |

| Option | Description | Selected |
|--------|-------------|----------|
| Sin indicador (Recomendado) | .pdf() es sub-segundo; NSSavePanel ya marca el flujo | ✓ |
| Deshabilitar botón durante export | Estado isExporting anti doble clic | |

**User's choice:** NSAlert solo para PDF, sin indicador de progreso.

---

## Claude's Discretion

- Mecanismo para exponer el WKWebView del preview al flujo de export (Coordinator/callback/registro).
- Detalle del override de apariencia para modo claro y su restauración.
- Estructura y wording del NSAlert en español.
- Cómo extrae el `<title>` el lado Python (BeautifulSoup vs trafilatura metadata).

## Deferred Ideas

- Paginado A4 con márgenes para impresión — fuera de v2.0.
- Indicador isExporting con botón deshabilitado — descartado para v2.0.
- Alerta visible también para MD/HTML — se mantiene print(); reconsiderar si molesta.
