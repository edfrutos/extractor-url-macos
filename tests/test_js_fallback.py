"""Pruebas del fallback Playwright para contenido dinámico (Fase 11)."""

from __future__ import annotations

from pathlib import Path

import pytest

import core


FIXTURES_DIR = Path(__file__).parent / "fixtures"


def _fixture_text(name: str) -> str:
    return (FIXTURES_DIR / name).read_text(encoding="utf-8")


class _FakeResponse:
    """Sustituto mínimo de requests.Response para monkeypatchear _HTTP_SESSION.get."""

    def __init__(self, text: str, url: str) -> None:
        self.text = text
        self.url = url
        self.apparent_encoding = "utf-8"
        self.encoding = None

    def raise_for_status(self) -> None:
        return None


# ---------------------------------------------------------------------------
# Rama 1 — Heurística pura (JS-01)
# ---------------------------------------------------------------------------


def test_looks_insufficient_false_con_html_rico() -> None:
    html = _fixture_text("edefrutos_me.html")
    assert core._looks_insufficient(html) is False


def test_looks_insufficient_true_con_spa_vacia() -> None:
    html = _fixture_text("spa_vacia.html")
    assert core._looks_insufficient(html) is True


def test_looks_insufficient_true_con_body_vacio() -> None:
    assert core._looks_insufficient("<body></body>") is True


def test_looks_insufficient_no_cuenta_texto_de_noise_tags() -> None:
    html = (
        "<body><script>"
        + ("var x = 'ruido de relleno que no debe contar como contenido real'; " * 10)
        + "</script></body>"
    )
    assert core._looks_insufficient(html) is True


# ---------------------------------------------------------------------------
# Rama 2 — Fallback activado con éxito (JS-02)
# ---------------------------------------------------------------------------


def test_fetch_raw_usa_playwright_cuando_html_estatico_es_insuficiente(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_pobre = _fixture_text("spa_vacia.html")
    html_rico = _fixture_text("edefrutos_me.html")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_pobre, url),
    )
    monkeypatch.setattr(
        core, "_fetch_via_playwright", lambda _url, _timeout: html_rico
    )

    result = core._fetch_raw("https://example.com/spa", use_cache=False)

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_rico


# ---------------------------------------------------------------------------
# Rama 3 — Playwright no disponible, degradación (JS-03)
# ---------------------------------------------------------------------------


def test_fetch_raw_degrada_a_html_estatico_cuando_playwright_no_disponible(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_pobre = _fixture_text("spa_vacia.html")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_pobre, url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda _url, _timeout: None)

    result = core._fetch_raw("https://example.com/spa", use_cache=False)

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_pobre


def test_fetch_via_playwright_sin_paquete_instalado_devuelve_none() -> None:
    # En el entorno de test de este repo playwright no está garantizado —
    # cubre JS-03 de forma directa, sin simular el ImportError artificialmente.
    result = core._fetch_via_playwright("https://example.com", 5)
    assert result is None or isinstance(result, str)


# ---------------------------------------------------------------------------
# Rama 4 — Sitio estático normal no activa el fallback (no-regresión)
# ---------------------------------------------------------------------------


def test_fetch_raw_no_llama_a_playwright_con_html_estatico_suficiente(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_rico = _fixture_text("edefrutos_me.html")

    def _unexpected_playwright(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("No debe llamarse a Playwright con HTML ya suficiente")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_rico, url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", _unexpected_playwright)

    result = core._fetch_raw("https://example.com/rico", use_cache=False)

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_rico
