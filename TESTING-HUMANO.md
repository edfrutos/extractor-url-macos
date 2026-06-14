# Testing Visual Humano — ExtractorApp v2.0

Guía de verificación manual de la interfaz. Cubre todos los estados visibles, animaciones, validaciones y flujos de exportación. Ejecutar con la app compilada en Xcode (esquema Release o Debug).

---

## Prerequisitos

- [ ] Xcode abierto con el proyecto `ExtractorApp.xcodeproj`
- [ ] Entorno virtual Python activo con `extractor_url.py` accesible
- [ ] Conocida la ruta al intérprete: `which python` (con venv activo)
- [ ] Conocida la ruta al script: ruta absoluta a `extractor_url.py`

---

## 1. Primer arranque — estado inicial

**Pasos:** Lanzar la app (⌘R en Xcode o doble clic en el `.app`).

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 1.1 | Hero section | LogoMark (círculo azul con nodo y 3 ramas) aparece deslizándose desde la izquierda con spring animation |
| 1.2 | Título | "Extractor URL" en semibold + subtítulo "Extrae contenido web en texto, HTML o Markdown" en gris |
| 1.3 | Campo URL | Vacío, placeholder "https://example.com", icono de cadena (link) a la izquierda |
| 1.4 | Picker de formato | Segmented control con "Texto / HTML / Markdown", selección por defecto en "Texto" |
| 1.5 | Botón Extraer | Deshabilitado (gris) porque el campo URL está vacío |
| 1.6 | Opciones avanzadas | Colapsadas, solo visible el encabezado "Opciones avanzadas" con icono sliders |
| 1.7 | Área de resultado | Estado vacío: LogoMark semitransparente centrado + "Introduce una URL y pulsa Extraer" |
| 1.8 | Barra de exportar | Visible en la parte inferior, picker MD/HTML/PDF y botón Exportar deshabilitados |
| 1.9 | Fondo general | `windowBackgroundColor` del sistema — se adapta automáticamente al modo claro/oscuro |

---

## 2. Configuración de Preferencias

**Pasos:** Menú `ExtractorApp › Preferencias…` o `⌘,`

### 2A. Rutas vacías (estado inicial)

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2A.1 | Campos de ruta | Ambos vacíos, sin badge visible (`.empty` → `EmptyView`) |
| 2A.2 | Botón "Verificar configuración" | Deshabilitado (requiere pythonPath no vacío) |
| 2A.3 | Sección "Advertencias" | No aparece (se muestra solo cuando hay rutas inválidas) |
| 2A.4 | Banner naranja en "Ayuda" | Visible: "Configura ambas rutas correctamente para poder extraer contenido" |
| 2A.5 | Pasos de ayuda | 3 filas numeradas (1 activar venv, 2 which python, 3 localizar script) con icono de acento |

### 2B. Ruta Python inválida

**Pasos:** Escribir `/ruta/falsa/python` en el campo Intérprete Python.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2B.1 | Badge validación Python | Cápsula roja "No encontrado" con icono ✕ aparece inmediatamente (reactividad `didSet`) |
| 2B.2 | Sección "Advertencias" | Aparece con mensaje descriptivo para el intérprete |
| 2B.3 | Campo script | Sin cambios independientes |

### 2C. Ruta Python válida

**Pasos:** Pulsar el botón Examinar (📁) del campo Intérprete Python → seleccionar el binario Python del venv.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2C.1 | NSOpenPanel | Se abre con el Finder para seleccionar archivo |
| 2C.2 | Badge tras selección | Cápsula verde "OK" con icono ✓ |
| 2C.3 | Sección "Advertencias" | Desaparece si el script también es válido |

### 2D. Ruta script válida

**Pasos:** Pulsar Examinar del campo Script → seleccionar `extractor_url.py`.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2D.1 | Badge tras selección | Cápsula verde "OK" |
| 2D.2 | Banner naranja "Ayuda" | Desaparece (ambas rutas válidas) |
| 2D.3 | Sección "Advertencias" | No visible |

### 2E. Verificación del intérprete

**Pasos:** Con pythonPath válido, pulsar "Verificar configuración".

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2E.1 | Durante la verificación | Spinner mini + texto "Comprobando intérprete..." |
| 2E.2 | Botón durante verificación | Deshabilitado |
| 2E.3 | Resultado correcto | Texto monospaced con `Python 3.x.x` sobre fondo `textBackgroundColor` |
| 2E.4 | Resultado con error | Texto en rojo comenzando por "Error:" |

### 2F. Persistencia

**Pasos:** Cerrar Preferencias, volver a abrirlas.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 2F.1 | Rutas guardadas | Ambos campos conservan los valores configurados (`@AppStorage` via `UserDefaults`) |

---

## 3. Flujo principal de extracción

### 3A. Activar botón Extraer

**Pasos:** Escribir cualquier texto en el campo URL.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 3A.1 | Botón Extraer | Se habilita (`.borderedProminent`) con animación suave |
| 3A.2 | Icono botón | `arrow.down.circle.fill` |

### 3B. Estado "Extrayendo"

**Pasos:** Introducir una URL válida (p.ej. `https://example.com`) y pulsar Extraer.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 3B.1 | Animación botón | Escala a 0.94 al pulsar, rebota de vuelta con spring |
| 3B.2 | Hero section | Aparece spinner mini + "Extrayendo..." con transición de opacidad |
| 3B.3 | Result card — header | Icono `arrow.down.circle` en azul acento + "Extrayendo..." |
| 3B.4 | Result card — contenido | `ProgressView` grande centrado + texto "Extrayendo contenido…" |
| 3B.5 | Campo URL | Deshabilitado mientras extrae |
| 3B.6 | Picker formato | Deshabilitado mientras extrae |
| 3B.7 | Ventana | Responde a eventos (redimensionable, menús accesibles) — no se congela |

### 3C. Resultado exitoso

**Pasos:** Esperar a que la extracción complete.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 3C.1 | Hero section | Spinner desaparece con transición de opacidad |
| 3C.2 | Result card — header | Icono `checkmark.circle.fill` verde + "Resultado — X caracteres" |
| 3C.3 | Badge de formato | Pill con el tipo en mayúsculas (TEXT / HTML / MARKDOWN) en color acento |
| 3C.4 | Preview | `WKWebView` carga el HTML renderizado del contenido extraído |
| 3C.5 | Export card | Picker MD/HTML/PDF y botón Exportar se habilitan |
| 3C.6 | Icono botón Extraer | Vuelve a `arrow.down.circle.fill` (no está en estado `isExtracting`) |

---

## 4. Formatos de extracción

Repetir la extracción de la misma URL con cada formato del picker principal.

| Formato | Qué verificar en el preview |
|---------|-----------------------------|
| **Texto** | Texto plano sin etiquetas HTML, legible, sin ruido de código |
| **HTML** | HTML renderizado en WKWebView — estilos del sitio original aplicados |
| **Markdown** | Texto con sintaxis MD visible (`# Título`, `**negrita**`, `- lista`) |

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 4.1 | Badge en result card | Cambia a TEXT / HTML / MARKDOWN según el picker |
| 4.2 | Recuento de caracteres | Número varía según el formato elegido |
| 4.3 | Preview HTML | No hay activos rotos (imágenes, CSS) para HTML autocontenido |

---

## 5. Opciones avanzadas

### 5A. Expandir / colapsar

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 5A.1 | Pulsar encabezado "Opciones avanzadas" | Se expande mostrando campo Selector CSS y Tiempo límite |
| 5A.2 | Volver a pulsar | Se colapsa suavemente |

### 5B. Selector CSS

**Pasos:** Expandir opciones, escribir `article` en el campo selector, extraer una URL.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 5B.1 | Campo | Fuente monospaced, fondo diferenciado `textBackgroundColor` |
| 5B.2 | Extracción | Solo el contenido del elemento `<article>` aparece en el resultado |
| 5B.3 | Selector inválido (`!!@@`) | Error explícito — no amplía el alcance silenciosamente |

### 5C. Tiempo límite

**Pasos:** Cambiar el timeout a `5` y extraer una URL lenta.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 5C.1 | Campo | Solo acepta números, ancho reducido (~80 pt) |
| 5C.2 | Timeout alcanzado | Error `ExtractionError.timeout` visible en result card |

---

## 6. Estado de error

### 6A. Error genérico (URL inalcanzable)

**Pasos:** Introducir `https://url-que-no-existe-9999.xyz` y extraer.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 6A.1 | Result card — header | Icono `exclamationmark.triangle.fill` naranja + "Error" |
| 6A.2 | Result card — contenido | Icono triángulo naranja + "Error de extraccion" en bold + mensaje descriptivo en caption |
| 6A.3 | Botón "Abrir Preferencias" | No aparece (el error no es de ruta Python) |

### 6B. Error de ruta Python

**Pasos:** Ir a Preferencias, borrar la ruta del intérprete Python, volver a ContentView y extraer.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 6B.1 | Mensaje error | Describe que Python no se encuentra en la ruta configurada |
| 6B.2 | Botón "Abrir Preferencias" | Aparece como link bajo el mensaje de error |
| 6B.3 | Pulsar "Abrir Preferencias" | Abre la ventana de Preferencias |

---

## 7. Exportación

Con resultado exitoso cargado (preview visible, `contentReady = true`):

### 7A. Export Markdown

| # | Pasos | Resultado esperado |
|---|-------|--------------------|
| 7A.1 | Picker exportar → "Markdown", pulsar Exportar | `NSSavePanel` con extensión `.md` y nombre sugerido derivado del título |
| 7A.2 | Guardar el archivo | Archivo `.md` creado en la ubicación elegida |
| 7A.3 | Abrir en editor de texto | Sintaxis Markdown legible y sin ruido HTML |

### 7B. Export HTML

| # | Pasos | Resultado esperado |
|---|-------|--------------------|
| 7B.1 | Picker exportar → "HTML", pulsar Exportar | `NSSavePanel` con extensión `.html` |
| 7B.2 | Guardar y abrir en Safari | Página renderizada sin assets externos rotos |
| 7B.3 | Dark mode en Safari | Si el sistema está en oscuro, el HTML aplica estilos oscuros |

### 7C. Export PDF

| # | Pasos | Resultado esperado |
|---|-------|--------------------|
| 7C.1 | Picker exportar → "PDF", pulsar Exportar | `NSSavePanel` con extensión `.pdf` y nombre sugerido |
| 7C.2 | Guardar y abrir en Vista Previa | PDF vectorial, texto seleccionable, sin páginas en blanco |
| 7C.3 | Zoom al 200% | Texto nítido, sin pixelación (vectorial) |
| 7C.4 | Modo claro forzado | El PDF se genera siempre en modo claro (sin fondo negro) |

---

## 8. Dark Mode

**Pasos:** Cambiar a modo oscuro (`Ajustes del Sistema › Apariencia › Oscuro`) con la app abierta.

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 8.1 | Fondo ventana | `windowBackgroundColor` invierte automáticamente — sin parpadeo |
| 8.2 | Cards | `controlBackgroundColor` adapta su tono al modo oscuro |
| 8.3 | Campo URL | `textBackgroundColor` con el contraste correcto en oscuro |
| 8.4 | Texto | `.primary` y `.secondary` invierten sin cambios de código |
| 8.5 | LogoMark | Visible y con buen contraste (usa `Color.accentColor`) |
| 8.6 | Hero section | Fondo `controlBackgroundColor.opacity(0.6)` diferenciado del fondo principal |
| 8.7 | Badges de validación | Rojo/verde/naranja mantienen legibilidad en oscuro (colores con opacidad 0.15) |

---

## 9. Animaciones y micro-interacciones

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 9.1 | Apertura de la app | LogoMark entra desde la izquierda (spring), título baja suavemente con 0.1s delay |
| 9.2 | Pulsar Extraer | Botón escala a 0.94 y rebota de vuelta (spring) antes de lanzar |
| 9.3 | Inicio extracción | Spinner en hero aparece con `.opacity + .scale(0.9)` |
| 9.4 | Fin extracción | Spinner desaparece con la misma transición |
| 9.5 | Escribir en URL | Botón Extraer se habilita con `easeInOut(0.2)` |
| 9.6 | ContentReady | Botón Exportar se habilita con `easeInOut(0.2)` |
| 9.7 | Opciones avanzadas | DisclosureGroup expande/colapsa con animación nativa del sistema |

---

## 10. Redimensionado de ventana

| # | Qué comprobar | Resultado esperado |
|---|---------------|--------------------|
| 10.1 | Reducir al mínimo | Ventana no baja de 560×480 pt |
| 10.2 | Ampliar horizontalmente | Las cards se extienden, el preview ocupa más ancho |
| 10.3 | Ampliar verticalmente | El ScrollView aprovecha el espacio; el hero section queda fijo arriba |
| 10.4 | Preview con mucho contenido | El WKWebView hace scroll internamente sin romper el layout |

---

## 11. Casos límite

| # | Escenario | Resultado esperado |
|---|----------|--------------------|
| 11.1 | URL sin scheme (`example.com`) | Error explícito de Python CLI — no cuelga |
| 11.2 | URL con espacios | Campo URL los acepta; el CLI reporta error explícito |
| 11.3 | Pulsar Extraer dos veces rápido | La segunda pulsación es ignorada (`isExtracting` guard) |
| 11.4 | Cerrar Preferencias con rutas a medias | ContentView no crashea; si faltan rutas, el error de extracción lo indica |
| 11.5 | URL que devuelve página vacía | `ExtractionError.emptyOutput` visible en result card |
| 11.6 | Timeout = 0 | El ViewModel usa el fallback de 15 s |

---

## Checklist de firma final

Marcar todos antes de declarar v2.0 apta para distribución:

- [ ] Todos los estados de ContentView verificados (vacío, extrayendo, resultado, error)
- [ ] Preferencias: validación reactiva de badges funcionando
- [ ] Preferencias: "Verificar configuración" muestra versión Python real
- [ ] Exportación MD, HTML y PDF generan archivos correctos y legibles
- [ ] Dark mode sin colores rotos ni artefactos visuales
- [ ] Animaciones de apertura y botón Extraer fluidas
- [ ] Sin cuelgues durante extracción (ventana responde)
- [ ] Redimensionado sin roturas de layout
- [ ] Botón "Abrir Preferencias" aparece solo en errores de ruta Python
