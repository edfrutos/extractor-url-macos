"""Pruebas de la interfaz pública CLI."""

from __future__ import annotations

import builtins
import json
import sys
from typing import NoReturn

import pytest

import extractor_url


@pytest.mark.parametrize("arguments", [[], ["--gui"]])
def test_main_abre_gui_sin_url(
    monkeypatch: pytest.MonkeyPatch,
    arguments: list[str],
) -> None:
    """Comprueba que la GUI puede abrirse sin una URL posicional."""
    called = {"gui": False}
    monkeypatch.setattr(sys, "argv", ["extractor_url.py", *arguments])
    monkeypatch.setattr(
        extractor_url,
        "_run_gui",
        lambda: called.__setitem__("gui", True),
    )

    extractor_url.main()

    assert called["gui"] is True


def test_main_json_devuelve_salida_estructurada(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba el contrato JSON de una extracción correcta."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"],
    )
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["status"] == "success"
    assert output["url"] == "https://example.com"
    assert output["content"] == "contenido"
    assert "title" in output  # campo siempre presente (puede ser null)


def test_main_json_incluye_title_cuando_hay_titulo(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba que --json incluye title con el texto del <title> de la página."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"],
    )
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )
    # Monkeypatch sobre el binding local del módulo (no sobre core directamente)
    monkeypatch.setattr(
        extractor_url,
        "_fetch_raw",
        lambda *_a, **_kw: (
            "<html><title>Mi Título</title></html>",
            "https://example.com",
        ),
    )
    monkeypatch.setattr(
        extractor_url,
        "_extract_title",
        lambda *_a, **_kw: "Mi Título",
    )

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["title"] == "Mi Título"


def test_main_json_title_null_sin_titulo(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba que title es null en JSON cuando la página no tiene <title>."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "https://example.com", "--json", "--no-cache"],
    )
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )
    # Monkeypatch sobre el binding local del módulo (no sobre core directamente)
    monkeypatch.setattr(
        extractor_url,
        "_fetch_raw",
        lambda *_a, **_kw: (
            "<html><body>sin título</body></html>",
            "https://example.com",
        ),
    )
    monkeypatch.setattr(
        extractor_url,
        "_extract_title",
        lambda *_a, **_kw: None,
    )

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["title"] is None


def test_main_propaga_fallo_de_guardado(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba que un fallo de escritura termina con código de error."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "https://example.com", "-o", "salida.txt"],
    )
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_args, **_kwargs: "contenido",
    )

    def _fail_open(*_args: object, **_kwargs: object) -> NoReturn:
        raise OSError("sin permisos")

    monkeypatch.setattr(builtins, "open", _fail_open)

    with pytest.raises(SystemExit, match="1"):
        extractor_url.main()

    assert "Error al guardar archivo: sin permisos" in capsys.readouterr().err


def test_main_json_de_error_termina_con_codigo_uno(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Comprueba el contrato JSON cuando la extracción falla."""
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "https://example.com", "--json"],
    )
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_args, **_kwargs: None,
    )

    with pytest.raises(SystemExit, match="1"):
        extractor_url.main()

    output = json.loads(capsys.readouterr().out)
    assert output["status"] == "error"
    assert output["url"] == "https://example.com"
