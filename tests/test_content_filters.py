"""Pruebas de --no-images/--no-links en core.py (Fase 19)."""

from __future__ import annotations

from pathlib import Path

import pytest
from bs4 import BeautifulSoup

import core


FIXTURES_DIR = Path(__file__).parent / "fixtures"


def _fixture_text(name: str) -> str:
    return (FIXTURES_DIR / name).read_text(encoding="utf-8")


# ---------------------------------------------------------------------------
# _strip_images / _strip_links — unitarios
# ---------------------------------------------------------------------------


def test_strip_images_elimina_todas_las_img() -> None:
    soup = BeautifulSoup(
        "<p>Texto <img src='a.png'> más <img src='b.png'> texto</p>", "html.parser"
    )

    core._strip_images(soup)

    assert soup.find("img") is None
    assert soup.get_text(" ", strip=True) == "Texto más texto"


def test_strip_links_conserva_texto_elimina_etiqueta_a() -> None:
    soup = BeautifulSoup(
        "<p>Hola <a href='https://x.example'>mundo</a> final</p>", "html.parser"
    )

    core._strip_links(soup)

    assert soup.find("a") is None
    assert soup.get_text(" ", strip=True) == "Hola mundo final"


# ---------------------------------------------------------------------------
# extract_formatted_content — html_string/text (Success Criterion 1/2)
# ---------------------------------------------------------------------------


def test_extract_formatted_content_no_images_elimina_img_en_html(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")
    monkeypatch.setattr(core, "_fetch_soup", lambda *_a, **_kw: soup)

    result = core.extract_formatted_content(
        "https://edefrutos.me/", return_type="html_string", no_images=True
    )

    assert result is not None
    assert "<img" not in result


def test_extract_formatted_content_sin_no_images_conserva_img_en_html(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")
    monkeypatch.setattr(core, "_fetch_soup", lambda *_a, **_kw: soup)

    result = core.extract_formatted_content(
        "https://edefrutos.me/", return_type="html_string"
    )

    assert result is not None
    assert "<img" in result


def test_extract_formatted_content_no_links_elimina_a_en_html(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    soup = BeautifulSoup(_fixture_text("sample_selector.html"), "html.parser")
    monkeypatch.setattr(core, "_fetch_soup", lambda *_a, **_kw: soup)

    result = core.extract_formatted_content(
        "https://example.com/post", return_type="html_string", no_links=True
    )

    assert result is not None
    assert "<a " not in result and "<a>" not in result
    assert "enlace relativo" in result


# ---------------------------------------------------------------------------
# extract_html_structure_to_markdown — camino trafilatura (sin selector)
# ---------------------------------------------------------------------------


def test_markdown_sin_selector_no_images_pasa_include_images_false(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("edefrutos_me.html")
    monkeypatch.setattr(
        core, "_fetch_raw", lambda _url, **_kwargs: (html, "https://edefrutos.me/")
    )
    captured_kwargs: dict[str, object] = {}

    def _fake_trafilatura_extract(*_args: object, **kwargs: object) -> str:
        captured_kwargs.update(kwargs)
        return "contenido bastante largo " * 10

    monkeypatch.setattr(core.trafilatura, "extract", _fake_trafilatura_extract)

    core.extract_html_structure_to_markdown("https://edefrutos.me/", no_images=True)

    assert captured_kwargs["include_images"] is False
    assert captured_kwargs["include_links"] is True


def test_markdown_sin_selector_no_links_pasa_include_links_false(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("edefrutos_me.html")
    monkeypatch.setattr(
        core, "_fetch_raw", lambda _url, **_kwargs: (html, "https://edefrutos.me/")
    )
    captured_kwargs: dict[str, object] = {}

    def _fake_trafilatura_extract(*_args: object, **kwargs: object) -> str:
        captured_kwargs.update(kwargs)
        return "contenido bastante largo " * 10

    monkeypatch.setattr(core.trafilatura, "extract", _fake_trafilatura_extract)

    core.extract_html_structure_to_markdown("https://edefrutos.me/", no_links=True)

    assert captured_kwargs["include_images"] is True
    assert captured_kwargs["include_links"] is False


def test_markdown_sin_selector_fallback_no_links_aplana_enlaces(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Cuando trafilatura devuelve poco contenido, el fallback md_convert
    también debe respetar no_links (soup ya aplanado antes del fallback)."""
    html = _fixture_text("edefrutos_me.html")
    monkeypatch.setattr(
        core, "_fetch_raw", lambda _url, **_kwargs: (html, "https://edefrutos.me/")
    )
    monkeypatch.setattr(core.trafilatura, "extract", lambda *_a, **_kw: "corto")

    result = core.extract_html_structure_to_markdown("https://edefrutos.me/", no_links=True)

    assert result is not None
    assert "](https://edefrutos.me/plugins-de-membresia)" not in result
    assert "este enlace" in result


# ---------------------------------------------------------------------------
# extract_html_structure_to_markdown — camino con selector (md_convert)
# ---------------------------------------------------------------------------


def test_markdown_con_selector_no_images_elimina_imagen_antes_de_convertir(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = (
        "<html><body><article id='target'>"
        "<p>Texto <img src='foto.png'> con imagen</p>"
        "</article></body></html>"
    )
    monkeypatch.setattr(
        core, "_fetch_raw", lambda _url, **_kwargs: (html, "https://example.com/")
    )

    result = core.extract_html_structure_to_markdown(
        "https://example.com/post", selector="#target", no_images=True
    )

    assert result is not None
    assert "![" not in result
    assert "con imagen" in result


def test_markdown_con_selector_no_links_aplana_enlace_antes_de_convertir(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("sample_selector.html")
    monkeypatch.setattr(
        core, "_fetch_raw", lambda _url, **_kwargs: (html, "https://example.com/base/")
    )

    result = core.extract_html_structure_to_markdown(
        "https://example.com/post", selector="#target", no_links=True
    )

    assert result is not None
    assert "](https://example.com/guia)" not in result
    assert "enlace relativo" in result
