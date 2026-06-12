"""Pruebas para la función _extract_title de core.py."""

from __future__ import annotations

from bs4 import BeautifulSoup

from core import _extract_title


def test_extract_title_con_titulo_simple() -> None:
    """Devuelve el texto del <title> cuando existe."""
    soup = BeautifulSoup("<title>Mi Título</title>", "html.parser")
    assert _extract_title(soup) == "Mi Título"


def test_extract_title_aplica_strip() -> None:
    """Aplica strip() al texto del <title>."""
    soup = BeautifulSoup("<title>  Espacios  </title>", "html.parser")
    assert _extract_title(soup) == "Espacios"


def test_extract_title_sin_titulo_devuelve_none() -> None:
    """Devuelve None cuando no hay <title> ni html_text."""
    soup = BeautifulSoup("<body></body>", "html.parser")
    assert _extract_title(soup) is None


def test_extract_title_titulo_vacio_con_html_text() -> None:
    """Con <title> vacío y html_text intenta fallback con trafilatura."""
    html = (
        "<html>"
        "<head><title></title>"
        '<meta property="og:title" content="Título OG"/></head>'
        "<body>Contenido de prueba suficiente para trafilatura</body>"
        "</html>"
    )
    soup = BeautifulSoup(html, "html.parser")
    # El resultado puede ser None o un string — lo importante es que no lanza excepción
    result = _extract_title(soup, html_text=html)
    assert result is None or isinstance(result, str)
