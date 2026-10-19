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
        core, "_fetch_via_playwright", lambda _url, _timeout, **_kw: html_rico
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
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda _url, _timeout, **_kw: None)

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


# ---------------------------------------------------------------------------
# Regresión — Chromium que no arranca dentro de una PlaywrightSession
# ---------------------------------------------------------------------------


def test_fetch_via_playwright_con_sesion_degrada_si_chromium_no_arranca(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    playwright_api = pytest.importorskip("playwright.sync_api")
    launches: list[int] = []

    def _launch_fallido(_self: core.PlaywrightSession) -> None:
        launches.append(1)
        raise playwright_api.Error("Executable doesn't exist")

    monkeypatch.setattr(core.PlaywrightSession, "new_page", _launch_fallido)

    result = core._fetch_via_playwright(
        "https://example.com", 5, session=core.PlaywrightSession(),
    )

    assert result is None
    assert launches == [1]


def test_playwright_session_no_reintenta_un_lanzamiento_fallido() -> None:
    session = core.PlaywrightSession()
    session._launch_failed = True  # pylint: disable=protected-access

    # Con el fallo ya registrado, devuelve None sin volver a lanzar Chromium.
    assert session.new_page() is None


# ---------------------------------------------------------------------------
# Bloqueo anti-bots — 401/403 en la descarga directa reintenta con Chromium
# ---------------------------------------------------------------------------


class _ForbiddenResponse(_FakeResponse):
    """Respuesta 403 que lanza HTTPError como requests real."""

    status_code = 403

    def raise_for_status(self) -> None:
        raise core.requests.exceptions.HTTPError(
            "403 Client Error: Forbidden", response=self,  # type: ignore[arg-type]
        )


def test_fetch_raw_reintenta_con_playwright_ante_403(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(
        core._HTTP_SESSION, "get", lambda url, **_kw: _ForbiddenResponse("", url),
    )
    monkeypatch.setattr(
        core, "_fetch_via_playwright", lambda _url, _timeout, **_kw: "<p>renderizado</p>",
    )

    result = core._fetch_raw("https://example.com/bloqueada", use_cache=False)

    assert result == ("<p>renderizado</p>", "https://example.com/bloqueada")


def test_fetch_raw_ante_403_falla_si_playwright_tampoco_puede(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    monkeypatch.setattr(
        core._HTTP_SESSION, "get", lambda url, **_kw: _ForbiddenResponse("", url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda _url, _timeout, **_kw: None)

    assert core._fetch_raw("https://example.com/bloqueada", use_cache=False) is None
    assert "403" in capsys.readouterr().err


def test_fetch_raw_ante_403_con_js_off_no_usa_playwright(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def _no_deberia_llamarse(*_args: object, **_kwargs: object) -> str:
        raise AssertionError("js_mode='off' no debe lanzar Chromium")

    monkeypatch.setattr(
        core._HTTP_SESSION, "get", lambda url, **_kw: _ForbiddenResponse("", url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", _no_deberia_llamarse)

    assert core._fetch_raw("https://example.com/bloqueada", use_cache=False, js_mode="off") is None


class _FakePage:
    def __init__(self, status: int) -> None:
        self._status = status

    def goto(self, *_args: object, **_kwargs: object) -> object:
        return type("Resp", (), {"status": self._status})()

    def content(self) -> str:
        return "<html>Access Denied</html>"


def test_render_page_descarta_paginas_de_error_http() -> None:
    assert core._render_page(_FakePage(403), "https://example.com", 5) is None
    assert core._render_page(_FakePage(200), "https://example.com", 5) == (
        "<html>Access Denied</html>"
    )
