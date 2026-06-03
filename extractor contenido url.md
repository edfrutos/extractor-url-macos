# ✅ Para extraer contenido formateado de una página web en Python, necesitaremos dos librerías principales:

1. **`requests`**: Para realizar la solicitud HTTP y obtener el contenido HTML de la URL.
2. **`BeautifulSoup4` (o `bs4`)**: Para analizar el HTML y extraer los elementos deseados de una manera sencilla y estructurada.

Aquí te presento una función completa con explicaciones y ejemplos:

```python
import requests
from bs4 import BeautifulSoup
from typing import Optional, Union
import argparse
import sys

def extract_formatted_content(
    url: str, return_type: str = "text"
) -> Optional[Union[str, BeautifulSoup]]:
    """
    Extrae el contenido formateado de una página web a partir de su URL.

    Args:
        url (str): La URL de la página web a extraer.
        return_type (str): El tipo de contenido a devolver:
                           - 'text': Devuelve el texto limpio de la página.
                           - 'html_string': Devuelve el HTML completo.
                           - 'soup_object': Devuelve el objeto BeautifulSoup.

    Returns:
        Optional[Union[str, BeautifulSoup]]: Contenido extraído o None si hay error.
    """
    if not url.startswith(("http://", "https://")):
        url = "https://" + url

    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
        
        # Mejorar detección de codificación
        response.encoding = response.apparent_encoding

        html_content = response.text
        
        # Intentar usar lxml si está disponible, si no, html.parser
        parser = "html.parser"
        try:
            import lxml
            parser = "lxml"
        except ImportError:
            pass

        soup = BeautifulSoup(html_content, parser)

        if return_type == "html_string":
            return html_content
        elif return_type == "soup_object":
            return soup
        elif return_type == "text":
            for script_or_style in soup(["script", "style", "header", "footer", "nav", "aside"]):
                script_or_style.decompose()

            text_content = soup.get_text(separator="\n", strip=True)
            cleaned_lines = [line.strip() for line in text_content.splitlines() if line.strip()]
            return "\n".join(cleaned_lines)

        return None

    except requests.exceptions.RequestException as e:
        print(f"Error al acceder a la URL '{url}': {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error inesperado: {e}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description="Extractor de contenido web")
    parser.add_argument("url", help="URL de la página web")
    parser.add_argument("-t", "--type", choices=["text", "html"], default="text", help="Tipo de salida (defecto: text)")
    parser.add_argument("-o", "--output", help="Archivo de salida (opcional)")

    args = parser.parse_args()

    content_type = "html_string" if args.type == "html" else "text"
    result = extract_formatted_content(args.url, return_type=content_type)

    if result:
        if args.output:
            try:
                with open(args.output, "w", encoding="utf-8") as f:
                    f.write(result)
                print(f"Contenido guardado en: {args.output}")
            except Exception as e:
                print(f"Error al guardar archivo: {e}", file=sys.stderr)
        else:
            print(result)
    else:
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
    else:
        # Mantener comportamiento de ejemplo si no hay argumentos
        example_url = "https://www.example.com"
        print(f"Extrayendo texto de: {example_url}\n")
        print(extract_formatted_content(example_url))

```

### Cómo funciona y qué incluye:

1. **Instalación de librerías:**
Asegúrate de tener las librerías instaladas. Si no las tienes, puedes instalarlas con pip:

```bash
pip install requests beautifulsoup4
```

(Opcional, para un parser HTML más rápido):

```bash
pip install lxml
```

2. **`requests.get(url, headers, timeout)`:**

   * `url`: La dirección de la página web.
   * `headers`: Se utiliza un `User-Agent` para simular que la solicitud proviene de un navegador web real. Esto puede ayudar a evitar que algunos sitios web bloqueen la solicitud si detectan que es un "bot" genérico.
   * `timeout`: Establece un tiempo máximo de espera para la respuesta del servidor. Si el servidor no responde dentro de este tiempo, la conexión se cancela, evitando que tu script se quede esperando indefinidamente.

3. __`response.raise_for_status()`:__
   Esta línea es crucial para el manejo de errores. Si la solicitud HTTP devuelve un código de estado que indica un error (como `404 Not Found`, `500 Internal Server Error`, etc.), esta función lanzará una excepción, lo que permite a nuestro bloque `try-except` capturarlo.

4. __`BeautifulSoup(html_content, 'html.parser')`:__

   * Crea un objeto `BeautifulSoup` que toma el contenido HTML (`html_content`) y lo analiza utilizando el parser `html.parser` (un parser integrado de Python). Si instalas `lxml`, puedes usar `'lxml'` en su lugar para un análisis más rápido y robusto.

5. __`return_type`:__
   La función es flexible y te permite elegir qué tipo de salida quieres:

   * **`'text'`**: Esta es la opción más común para "contenido formateado". Intenta devolver el texto principal de la página de la manera más legible posible.
      * Elimina etiquetas como `
