"""Pruebas del render externo: --js-external y --file + --base-url (Fase 26)."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any, NoReturn

import pytest
import requests

import core
import extractor_url


FIXTURES_DIR = Path(__file__).parent / "fixtures"
RENDERIZADO = FIXTURES_DIR / "renderizado_relativo.html"


def _fixture_text(name: str) -> str:
    return (FIXTURES_DIR / name).read_text(encoding="utf-8")


class _FakeResponse:
    """Sustituto mínimo de requests.Response para monkeypatchear _HTTP_SESSION.get."""

    def __init__(self, text: str, url: str, status_code: int = 200) -> None:
        self.text = text
        self.url = url
        self.status_code = status_code
        self.apparent_encoding = "utf-8"
        self.encoding = None

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise requests.exceptions.HTTPError(
                f"{self.status_code} Client Error", response=self,  # type: ignore[arg-type]
            )


def _no_playwright(*_args: Any, **_kwargs: Any) -> NoReturn:
    raise AssertionError("con --js-external no debe usarse Playwright")


@pytest.fixture(name="entorno")
def _entorno(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> Path:
    """Caché e historial en tmp_path, y Playwright prohibido."""
    monkeypatch.setattr(core, "_CACHE_DIR", tmp_path)
    monkeypatch.setattr(core, "_HISTORY_FILE", tmp_path / "history.jsonl")
    monkeypatch.setattr(core, "_fetch_via_playwright", _no_playwright)
    return tmp_path


def _serve(monkeypatch: pytest.MonkeyPatch, html: str, status_code: int = 200) -> None:
    monkeypatch.setattr(
        core._HTTP_SESSION,
        "get",
        lambda url, **_kwargs: _FakeResponse(html, url, status_code),
    )


def _run_cli(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    *arguments: str,
) -> tuple[int, dict[str, Any]]:
    """Ejecuta main() con --json y devuelve (código de salida, JSON)."""
    monkeypatch.setattr(sys, "argv", ["extractor_url.py", *arguments, "--json"])
    with pytest.raises(SystemExit) as exit_info:
        extractor_url.main()
    return int(exit_info.value.code or 0), json.loads(capsys.readouterr().out)


def _history_lines(cache_dir: Path) -> list[dict[str, Any]]:
    history = cache_dir / "history.jsonl"
    if not history.exists():
        return []
    return [json.loads(line) for line in history.read_text(encoding="utf-8").splitlines()]


def _cache_files(cache_dir: Path) -> list[Path]:
    return [p for p in cache_dir.glob("*.json") if p.name != "history.jsonl"]


# ---------------------------------------------------------------------------
# --js-external: la CLI avisa en vez de renderizar (WKJS-03)
# ---------------------------------------------------------------------------


def test_spa_vacia_pide_render_sin_playwright_ni_cache_ni_historial(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,
) -> None:
    _serve(monkeypatch, _fixture_text("spa_vacia.html"))

    code, output = _run_cli(
        monkeypatch, capsys, "https://example.com/spa", "--js-external",
    )

    assert code == 0
    assert output["status"] == "success"
    assert output["js_render_needed"] is True
    assert output["title"] is None
    assert not _cache_files(entorno)
    assert not _history_lines(entorno)


def test_pagina_rica_no_pide_render_y_deja_historial(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,
) -> None:
    _serve(monkeypatch, _fixture_text("edefrutos_me.html"))

    code, output = _run_cli(
        monkeypatch, capsys, "https://example.com/rica", "--js-external",
    )

    assert code == 0
    assert output["js_render_needed"] is False
    assert output["title"]
    assert len(_history_lines(entorno)) == 1


def test_no_js_nunca_pide_render(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
) -> None:
    _serve(monkeypatch, _fixture_text("spa_vacia.html"))

    _, output = _run_cli(
        monkeypatch, capsys, "https://example.com/spa", "--js-external", "--no-js",
    )

    assert output["js_render_needed"] is False


def test_js_siempre_pide_render(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
) -> None:
    _serve(monkeypatch, _fixture_text("edefrutos_me.html"))

    _, output = _run_cli(
        monkeypatch, capsys, "https://example.com/rica", "--js-external", "--js",
    )

    assert output["js_render_needed"] is True


@pytest.mark.parametrize("status_code", [401, 403])
def test_bloqueo_http_no_pide_render(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
    status_code: int,
) -> None:
    _serve(monkeypatch, "<html><body>Access Denied</body></html>", status_code)

    code, output = _run_cli(
        monkeypatch, capsys, "https://example.com/bloqueada", "--js-external",
    )

    assert code == 1
    assert output["status"] == "error"
    assert output["js_render_needed"] is False


def test_cache_insuficiente_tambien_pide_render(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,
) -> None:
    """Una SPA cacheada por una ejecución sin --js-external no salta la heurística."""
    url = "https://example.com/spa"
    _serve(monkeypatch, _fixture_text("spa_vacia.html"))
    monkeypatch.setattr(core, "_fetch_via_playwright", lambda *_a, **_kw: None)
    assert core._fetch_raw(url) is not None
    assert _cache_files(entorno)

    monkeypatch.setattr(core, "_fetch_via_playwright", _no_playwright)
    _, output = _run_cli(monkeypatch, capsys, url, "--js-external")

    assert output["js_render_needed"] is True


def test_sin_js_external_el_json_no_cambia(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
) -> None:
    _serve(monkeypatch, _fixture_text("edefrutos_me.html"))

    _, output = _run_cli(monkeypatch, capsys, "https://example.com/rica")

    assert "js_render_needed" not in output


def test_sin_json_avisa_en_stderr(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
) -> None:
    _serve(monkeypatch, _fixture_text("spa_vacia.html"))
    monkeypatch.setattr(
        sys, "argv", ["extractor_url.py", "https://example.com/spa", "--js-external"],
    )

    extractor_url.main()

    assert "necesitar JavaScript" in capsys.readouterr().err


# ---------------------------------------------------------------------------
# --file + --base-url: HTML ya renderizado (WKJS-01)
# ---------------------------------------------------------------------------


def test_base_url_resuelve_enlaces_e_imagenes_y_gana_a_canonical(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,
) -> None:
    base = "https://quotes.example/js/"

    code, output = _run_cli(
        monkeypatch, capsys,
        "--file", str(RENDERIZADO), "--base-url", base, "--type", "markdown",
    )

    assert code == 0
    assert output["url"] == base
    assert output["title"] == "Citas renderizadas"
    assert "(https://quotes.example/autor/einstein)" in output["content"]
    assert "(https://quotes.example/js/img/retrato.png)" in output["content"]
    assert "otro-sitio.example" not in output["content"]
    history = _history_lines(entorno)
    assert len(history) == 1
    assert history[0]["url"] == base


def test_base_url_con_html_usa_la_base_en_la_url_del_json(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    entorno: Path,  # pylint: disable=unused-argument
) -> None:
    base = "https://quotes.example/js/"

    _, output = _run_cli(
        monkeypatch, capsys,
        "--file", str(RENDERIZADO), "--base-url", base, "--type", "html",
    )

    assert output["url"] == base
    assert "Citas renderizadas" in output["content"]


@pytest.mark.parametrize(
    "arguments, mensaje",
    [
        (["https://example.com", "--base-url", "https://example.com/"], "requiere --file"),
        (["--file", str(RENDERIZADO), "--base-url", "ftp://example.com/"], "http://"),
        (["--batch", "urls.txt", "--json", "--js-external"], "--batch"),
    ],
)
def test_argumentos_invalidos_salen_con_codigo_2(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    arguments: list[str],
    mensaje: str,
) -> None:
    monkeypatch.setattr(sys, "argv", ["extractor_url.py", *arguments])

    with pytest.raises(SystemExit, match="2"):
        extractor_url.main()

    assert mensaje in capsys.readouterr().err
