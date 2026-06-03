from __future__ import annotations

from pathlib import Path

import pytest
from bs4 import BeautifulSoup

import extractor_url


FIXTURES_DIR = Path(__file__).parent / "fixtures"


def _fixture_text(name: str) -> str:
    return (FIXTURES_DIR / name).read_text(encoding="utf-8")


def test_clean_soup_elimina_ruido_y_resuelve_urls_relativas() -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")

    cleaned = extractor_url._clean_soup(soup, "https://edefrutos.me/base/")

    assert cleaned.find("nav") is None
    assert cleaned.find("footer") is None
    assert cleaned.find(string=lambda text: "comentario a eliminar" in str(text)) is None
    assert cleaned.find("a")["href"] == "https://edefrutos.me/plugins-de-membresia"
    assert cleaned.find("img")["src"] == "https://edefrutos.me/media/portada.jpg"


def test_main_content_prioriza_article_sobre_body() -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")
    cleaned = extractor_url._clean_soup(soup, "https://edefrutos.me/")

    content = extractor_url._main_content(cleaned)

    assert getattr(content, "name", None) == "main"
    assert "Curiosa Actualidad" in content.get_text(" ", strip=True)


def test_post_process_markdown_normaliza_unicode_y_ruido() -> None:
    raw_markdown = "Cafe\u0301\n\n\n----\n\nLinea final   \n"

    result = extractor_url._post_process_markdown(raw_markdown)

    assert result == "Café\n\nLinea final"


def test_extract_markdown_con_selector_usa_html_controlado(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("sample_selector.html")

    monkeypatch.setattr(
        extractor_url,
        "_fetch_raw",
        lambda _url: (html, "https://example.com/base/"),
    )

    def _unexpected_trafilatura(**_kwargs: object) -> str:
        raise AssertionError("No debe llamarse a trafilatura con selector explícito")

    monkeypatch.setattr(extractor_url.trafilatura, "extract", _unexpected_trafilatura)

    result = extractor_url.extract_html_structure_to_markdown(
        "https://example.com/post", selector="#target"
    )

    assert result is not None
    assert "# Contenido objetivo" in result
    assert "[enlace relativo](https://example.com/guia)" in result
    assert "- Primer punto" in result
    assert "Bloque secundario" not in result


def test_extract_markdown_sin_selector_hace_fallback_a_main_content(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("edefrutos_me.html")

    monkeypatch.setattr(
        extractor_url,
        "_fetch_raw",
        lambda _url: (html, "https://edefrutos.me/"),
    )
    monkeypatch.setattr(
        extractor_url.trafilatura,
        "extract",
        lambda *_args, **_kwargs: "corto",
    )

    result = extractor_url.extract_html_structure_to_markdown(
        "https://edefrutos.me/curiosa-actualidad"
    )

    assert result is not None
    assert "# Curiosa Actualidad" in result
    assert "[este enlace](https://edefrutos.me/plugins-de-membresia)" in result
    assert "Barra lateral que no debe aparecer" not in result
