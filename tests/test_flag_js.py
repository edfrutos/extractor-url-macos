"""Pruebas de js_mode ("auto"/"force"/"off") en _fetch_raw (Fase 15)."""

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
# js_mode="force" — ignora la heurística, siempre invoca Playwright (FLAG-01)
# ---------------------------------------------------------------------------


def test_fetch_raw_js_mode_force_invoca_playwright_pese_a_html_rico(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_rico = _fixture_text("edefrutos_me.html")
    html_forzado = "<body>" + ("contenido forzado por playwright " * 10) + "</body>"

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_rico, url),
    )
    monkeypatch.setattr(
        core, "_fetch_via_playwright", lambda _url, _timeout: html_forzado
    )

    result = core._fetch_raw("https://example.com/rico", use_cache=False, js_mode="force")

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_forzado


def test_fetch_raw_js_mode_force_sin_playwright_degrada_a_estatico(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_rico = _fixture_text("edefrutos_me.html")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_rico, url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda _url, _timeout: None)

    result = core._fetch_raw("https://example.com/rico", use_cache=False, js_mode="force")

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_rico


# ---------------------------------------------------------------------------
# js_mode="off" — ignora la heurística, nunca invoca Playwright (FLAG-02)
# ---------------------------------------------------------------------------


def test_fetch_raw_js_mode_off_nunca_invoca_playwright_pese_a_html_pobre(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    html_pobre = _fixture_text("spa_vacia.html")

    def _unexpected_playwright(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("No debe llamarse a Playwright con js_mode='off'")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_pobre, url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", _unexpected_playwright)

    result = core._fetch_raw("https://example.com/spa", use_cache=False, js_mode="off")

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_pobre


# ---------------------------------------------------------------------------
# js_mode="auto" — no-regresión, comportamiento idéntico a v4.0
# ---------------------------------------------------------------------------


def test_fetch_raw_js_mode_auto_preserva_heuristica(
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

    result = core._fetch_raw("https://example.com/spa", use_cache=False, js_mode="auto")

    assert result is not None
    returned_html, _ = result
    assert returned_html == html_rico


# ---------------------------------------------------------------------------
# Bypass de caché: --js/--no-js deben tener efecto real aunque la URL ya
# esté cacheada (Pitfall 1 del research) — sin esto, un flag explícito no
# haría nada si la URL ya se descargó antes con js_mode="auto".
# ---------------------------------------------------------------------------


def test_fetch_raw_js_mode_force_bypassa_lectura_de_cache(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.setattr(core, "_CACHE_DIR", tmp_path)

    html_estatico = _fixture_text("edefrutos_me.html")
    html_forzado = "<body>" + ("render forzado tras cache hit " * 10) + "</body>"

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_estatico, url),
    )
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda _url, _timeout: html_forzado)

    url = "https://example.com/cacheada"

    # Primera llamada: js_mode="auto", cachea el HTML estático (heurística
    # no se activa, HTML rico).
    first = core._fetch_raw(url, use_cache=True, js_mode="auto")
    assert first is not None
    assert first[0] == html_estatico

    # Segunda llamada a la MISMA URL, ahora forzando: debe invocar
    # Playwright pese al cache hit disponible, no devolver lo cacheado.
    second = core._fetch_raw(url, use_cache=True, js_mode="force")
    assert second is not None
    assert second[0] == html_forzado


def test_fetch_raw_js_mode_auto_si_respeta_cache_hit(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    monkeypatch.setattr(core, "_CACHE_DIR", tmp_path)

    html_estatico = _fixture_text("edefrutos_me.html")

    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html_estatico, url),
    )

    url = "https://example.com/cacheada-auto"
    first = core._fetch_raw(url, use_cache=True, js_mode="auto")
    assert first is not None

    def _unexpected_get(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("No debe volver a descargar en cache hit con js_mode='auto'")

    monkeypatch.setattr(core._HTTP_SESSION, "get", _unexpected_get)

    second = core._fetch_raw(url, use_cache=True, js_mode="auto")
    assert second is not None
    assert second[0] == html_estatico
