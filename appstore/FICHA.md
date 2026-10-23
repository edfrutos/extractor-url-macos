# Ficha de la Mac App Store — Extractor URL

Textos para App Store Connect (idioma principal: Español de España). El
número entre paréntesis es el recuento de caracteres y el límite de Apple.

## Información de la app

| Campo | Valor |
|---|---|
| Nombre (13/30) | Extractor URL |
| Subtítulo (30/30) | Páginas web a Markdown y texto |
| Bundle ID | `com.edefrutos.ExtractorApp.appstore` |
| SKU | `extractor-url-appstore` |
| Versión | 2.3 (igual que `MARKETING_VERSION` del build; App Store Connect propone 1.0) |
| Categoría principal | Productividad |
| Categoría secundaria | Herramientas para desarrolladores |
| Copyright | © 2026 Eugenio de Frutos Sánchez |
| Precio | Gratis (sin compras dentro de la app) |
| URL de privacidad | https://edfrutos.github.io/extractor-url-macos/privacidad.html |
| URL de soporte | https://edfrutos.github.io/extractor-url-macos/soporte.html |
| URL de marketing | https://edfrutos.github.io/extractor-url-macos/ |

## Texto promocional (137/170)

```text
Convierte cualquier página web en Markdown, HTML o texto limpio en tu Mac. Sin cuentas, sin servicios externos y sin recoger ningún dato.
```

## Palabras clave (97/100)

Separadas por comas, sin espacios. No repiten el nombre ni la categoría,
ni usan marcas de terceros (guideline 2.3.7).

```text
markdown,html,web,extraer,texto,convertir,scraper,notas,artículo,lectura,selector,css,pdf,apuntes
```

## Descripción (1142/4000)

```text
Extractor URL convierte páginas web en Markdown, HTML o texto limpio. Pega una dirección, pulsa Extraer y obtén solo el contenido que importa, sin menús, anuncios ni pies de página.

Pensada para quien escribe, investiga o guarda notas: lleva artículos a tu editor de Markdown, a tu gestor de notas o a tu documentación en segundos.

QUÉ HACE
• Extrae el contenido principal de la página y descarta lo demás.
• Lo convierte a Markdown, HTML o texto plano, con títulos, listas, enlaces e imágenes.
• Renderiza las páginas que construyen su contenido con JavaScript.
• Acota la extracción con un selector CSS (por ejemplo, article o #contenido). Si el selector no existe, te avisa en vez de extraer otra cosa.
• Abre páginas HTML guardadas en tu Mac.
• Muestra una vista previa del resultado.
• Exporta a Markdown, HTML o PDF, o copia el resultado con ⇧⌘C.
• Guarda un historial para repetir una extracción con un clic.

PRIVADA POR DISEÑO
• No recoge ningún dato: sin cuentas, analítica ni publicidad.
• Solo se conecta a las direcciones que escribes tú.
• La caché y el historial se quedan en tu Mac.

Gratuita y sin compras dentro de la app.
```

## Novedades de esta versión

Solo se pide a partir de la segunda versión publicada.

## Capturas

Una de 1280×800, 1440×900, 2560×1600 o 2880×1800 (16:10), de 1 a 10.
`scripts/appstore/captura-appstore.sh <nombre>` deja la ventana en
1440×900 puntos y la captura (2880×1800 en Retina) en
`~/Desktop/appstore-<nombre>.png`.

Contenido propio para no mostrar marcas ni textos de terceros:

- Artículo de demostración (texto e ilustraciones originales):
  <https://edfrutos.github.io/extractor-url-macos/demo/articulo.html>
- `https://quotes.toscrape.com/js/`: sitio público pensado para practicar
  extracción.

| # | Escena | Cómo |
|---|---|---|
| 1 | Markdown de un artículo | URL del artículo de demostración, Markdown, sin selector → Extraer. |
| 2 | Página con JavaScript | `https://quotes.toscrape.com/js/`, Markdown → Extraer (salen las 10 citas). |
| 3 | Selector CSS | URL del artículo, selector `#receta` → Extraer (solo «Paso a paso»). |
| 4 | Historial | Tras las anteriores, abre el historial con las 3 entradas. |
| 5 | Exportar | Artículo extraído y una captura normal para fijar la ventana. Después, «Exportar como» en PDF → «Exportar» y, con el panel abierto, `captura-appstore.sh --sin-redimensionar 5-exportar`. |

Antes de capturar:

- Modo claro (Ajustes del Sistema → Apariencia).
- Historial limpio de pruebas antiguas o personales.
- Nada personal en el nombre de la carpeta del panel de guardar.

## Privacidad de la app

- ¿Recoges datos de esta app? **No** → «Datos no recopilados».
- Manifiesto: `ExtractorApp/ExtractorApp/ExtractorApp/PrivacyInfo.xcprivacy`
  (sin datos recopilados ni tracking).

## Clasificación por edades

En el cuestionario, todas las respuestas son «Ninguno» / «No». Debería dar
la clasificación mínima.

- Si App Review considera que muestra web sin restricciones, marcar
  «Acceso web sin restricciones» (sube a 17+/18+). No cambia nada más.

## Cumplimiento de exportación

`ITSAppUsesNonExemptEncryption = NO` en `AppStore-Info.plist`: solo usa el
HTTPS del sistema y de Python. App Store Connect no pregunta nada.

## Notas para App Review

Sin cuenta de prueba. Pegar en «Notas»:

```text
Extractor URL convierte páginas web en Markdown, HTML o texto limpio.

Prueba rápida:
1. Escribe https://example.com y pulsa «Extraer» (formato Markdown).
2. Escribe https://quotes.toscrape.com/js/ : la página usa JavaScript; la app la renderiza con WKWebView y extrae las 10 citas.
3. Usa «Abrir HTML…» con cualquier página guardada (.html).
4. Exporta el resultado o pulsa «Copiar».

Intérprete Python embebido (guideline 2.5.2):
La extracción la hace un motor en Python incluido dentro del bundle de la app (Contents/Resources/python), firmado con nuestro certificado y con el sandbox heredado (com.apple.security.inherit). Todo el código Python viaja en el paquete revisado: la app no descarga ni ejecuta código nuevo, no tiene actualizador propio y no permite al usuario ejecutar scripts. Python solo se usa como librería interna para descargar la URL que escribe el usuario y convertir el HTML.

No requiere cuenta ni inicio de sesión. No recoge datos.
```
