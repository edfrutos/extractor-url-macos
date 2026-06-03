# AGENTS.md — extractor-url

Utilidad CLI en Python para extraer contenido legible (texto o HTML) desde una URL.

## Idioma

Comunícate siempre en **español de España** en este repositorio, salvo que el usuario pida otro idioma. Mantén en inglés nombres técnicos, comandos, librerías, errores literales y términos estándar: `pytest`, `pylint`, `requests`, `BeautifulSoup`, `pull request`.

## Estructura del proyecto

```
extractor_url.py          # módulo principal y único punto de entrada
.pylintrc                 # configuración local de Pylint
requirements.txt          # dependencias (limpiar a solo las necesarias)
DESIGN.md                 # notas de diseño
extractor contenido url.md  # referencia de implementación
```

No hay paquete, carpeta `tests/` ni `__init__.py`. Todo vive en un solo archivo.

## Comandos

### Entorno

```bash
python -m venv .venv && source .venv/bin/activate
pip install requests beautifulsoup4 lxml
```

### Ejecución

```bash
python extractor_url.py https://example.com                  # texto limpio
python extractor_url.py https://example.com --type html      # HTML completo
python extractor_url.py https://example.com --type markdown  # estructura en Markdown
python extractor_url.py https://example.com -o out.txt       # guardar en archivo
python extractor_url.py                                      # abrir interfaz gráfica
python extractor_url.py --gui                                # abrir interfaz gráfica
```

### Linting y tipado

```bash
pylint extractor_url.py       # lint con .pylintrc local
mypy extractor_url.py         # verificación de tipos
pyright extractor_url.py      # alternativa a mypy
```

### Pruebas

No hay tests aún. Cuando se creen:

```bash
pytest tests/                          # todas las pruebas
pytest tests/test_extractor_url.py     # un archivo concreto
pytest tests/ -k test_adds_https -v    # una sola prueba con verbosidad
pytest tests/ --cov=extractor_url      # con cobertura (instala pytest-cov)
```

Usa mocks de `requests.get` para pruebas deterministas. No dependas de webs reales en pruebas unitarias.

## Estilo de código

### General

- Python 3, indentación de 4 espacios, línea máx. 88 caracteres.
- Usa `from __future__ import annotations` en todos los archivos nuevos.
- Sin punto y coma. Una declaración por línea.

### Imports

Orden: stdlib → terceros → locales. Un grupo por línea, separados por línea en blanco.

```python
import argparse
import sys
from typing import Optional, Union

import requests
from bs4 import BeautifulSoup, FeatureNotFound
```

### Naming

| Elemento | Convención | Ejemplo |
|---|---|---|
| Módulos | `snake_case` | `extractor_url.py` |
| Funciones / variables | `snake_case` | `extract_formatted_content` |
| Constantes | `UPPER_CASE` | `EXAMPLE_URL`, `DEFAULT_TIMEOUT` |
| Clases | `PascalCase` | *(ninguna actualmente)* |

### Tipado

- Anotaciones de tipo en **todas las funciones públicas**.
- Usa `Optional[T]` cuando pueda retornar `None`.
- Usa `Union[A, B]` para retornos múltiples.
- Importa solo los tipos que necesites de `typing`.

### Docstrings

- Triple comilla doble en funciones públicas.
- Primera línea = resumen breve. Luego `Args:`, `Returns:`, `Raises:` si aplica.

### Error handling

- Captura excepciones específicas antes que genéricas.
- En la frontera CLI, permite `except Exception` con comentario `# pylint: disable=broad-exception-caught`.
- Imprime errores en `sys.stderr`, nunca en `stdout`.
- Retorna `None` en caso de fallo; usa `sys.exit(1)` en CLI.

```python
except requests.exceptions.RequestException as e:
    print(f"Error al acceder a la URL '{url}': {e}", file=sys.stderr)
    return None
except Exception as e:  # pylint: disable=broad-exception-caught
    print(f"Error inesperado: {e}", file=sys.stderr)
    return None
```

### Mensajes de usuario

- Ayudas CLI, errores y documentación en **español de España**.
- Nombres de librerías, comandos y términos técnicos en **inglés**.

## Commits

- Mensajes breves e imperativos en español: `Añade pruebas para extracción de URLs`.
- Un cambio lógico por commit. No mezcles refactor con features.

## Notas

- El `requirements.txt` actual es un `pip freeze` del entorno global. Debe limpiarse a solo `requests`, `beautifulsoup4` y `lxml`.
- No hay reglas de Cursor (`.cursor/`) ni Copilot (`.github/copilot-instructions.md`) en este repositorio.
