from __future__ import annotations

from pathlib import Path

import pytest
from bs4 import BeautifulSoup

import core


FIXTURES_DIR = Path(__file__).parent / "fixtures"


def _fixture_text(name: str) -> str:
    return (FIXTURES_DIR / name).read_text(encoding="utf-8")


def test_clean_soup_elimina_ruido_y_resuelve_urls_relativas() -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")

    cleaned = core._clean_soup(soup, "https://edefrutos.me/base/")

    assert cleaned.find("nav") is None
    assert cleaned.find("footer") is None
    assert cleaned.find(string=lambda text: "comentario a eliminar" in str(text)) is None
    assert cleaned.find("a")["href"] == "https://edefrutos.me/plugins-de-membresia"
    assert cleaned.find("img")["src"] == "https://edefrutos.me/media/portada.jpg"


def test_main_content_prioriza_article_sobre_body() -> None:
    soup = BeautifulSoup(_fixture_text("edefrutos_me.html"), "html.parser")
    cleaned = core._clean_soup(soup, "https://edefrutos.me/")

    content = core._main_content(cleaned)

    assert getattr(content, "name", None) == "main"
    assert "Curiosa Actualidad" in content.get_text(" ", strip=True)


def test_post_process_markdown_normaliza_unicode_y_ruido() -> None:
    raw_markdown = "Cafe\u0301\n\n\n----\n\nLinea final   \n"

    result = core._post_process_markdown(raw_markdown)

    assert result == "Café\n\nLinea final"


def test_extract_markdown_con_selector_usa_html_controlado(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html = _fixture_text("sample_selector.html")

    monkeypatch.setattr(
        core,
        "_fetch_raw",
        lambda _url, **_kwargs: (html, "https://example.com/base/"),
    )

    def _unexpected_trafilatura(**_kwargs: object) -> str:
        raise AssertionError("No debe llamarse a trafilatura con selector explícito")

    monkeypatch.setattr(core.trafilatura, "extract", _unexpected_trafilatura)

    result = core.extract_html_structure_to_markdown(
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
        core,
        "_fetch_raw",
        lambda _url, **_kwargs: (html, "https://edefrutos.me/"),
    )
    monkeypatch.setattr(
        core.trafilatura,
        "extract",
        lambda *_args, **_kwargs: "corto",
    )

    result = core.extract_html_structure_to_markdown(
        "https://edefrutos.me/curiosa-actualidad"
    )

    assert result is not None
    assert "# Curiosa Actualidad" in result
    assert "[este enlace](https://edefrutos.me/plugins-de-membresia)" in result
    assert "Barra lateral que no debe aparecer" not in result


@pytest.mark.parametrize("selector", ["#inexistente", "article["])
def test_extract_markdown_con_selector_invalido_falla_explicitamente(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    selector: str,
) -> None:
    html = _fixture_text("sample_selector.html")
    monkeypatch.setattr(
        core,
        "_fetch_raw",
        lambda _url, **_kwargs: (html, "https://example.com/base/"),
    )

    result = core.extract_html_structure_to_markdown(
        "https://example.com/post", selector=selector
    )

    assert result is None
    assert "Selector" in capsys.readouterr().err


@pytest.mark.parametrize("return_type", ["text", "html_string"])
def test_extract_formatted_content_no_amplia_selector_inexistente(
    monkeypatch: pytest.MonkeyPatch,
    return_type: str,
) -> None:
    soup = BeautifulSoup(_fixture_text("sample_selector.html"), "html.parser")
    monkeypatch.setattr(core, "_fetch_soup", lambda *_args, **_kwargs: soup)

    result = core.extract_formatted_content(
        "https://example.com/post",
        return_type=return_type,
        selector="#inexistente",
    )

    assert result is None


@pytest.mark.parametrize(
    "url", ["https://example.com", "http://example.com", "HTTPS://example.com", "example.com"]
)
def test_url_scheme_error_acepta_http_https_y_sin_esquema(url: str) -> None:
    assert core.url_scheme_error(url) is None


@pytest.mark.parametrize("url", ["httpd://edefrutos.me", "ftp://example.com"])
def test_url_scheme_error_rechaza_esquemas_no_soportados(url: str) -> None:
    message = core.url_scheme_error(url)

    assert message is not None
    assert url.split("://", 1)[0] in message


def test_fetch_raw_con_esquema_invalido_no_hace_peticion(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    def _fail_get(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("no debería llegar a la red")

    monkeypatch.setattr(core._HTTP_SESSION, "get", _fail_get)

    assert core._fetch_raw("httpd://edefrutos.me", use_cache=False) is None
    assert "Esquema de URL no soportado" in capsys.readouterr().err
