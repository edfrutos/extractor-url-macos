"""Pruebas de la interfaz pública CLI."""

from __future__ import annotations

import builtins
import json
import sys
from pathlib import Path
from typing import NoReturn

import pytest

import core
import extractor_url


def _use_tmp_history(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> None:
    monkeypatch.setattr(core, "_CACHE_DIR", tmp_path)
    monkeypatch.setattr(core, "_HISTORY_FILE", tmp_path / "history.jsonl")


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


# ---------------------------------------------------------------------------
# Historial y --batch (Fase 14)
# ---------------------------------------------------------------------------


def test_main_json_exitoso_escribe_entrada_de_historial(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """Una extracción exitosa con --json también queda en el historial."""
    _use_tmp_history(monkeypatch, tmp_path)
    monkeypatch.setattr(
        sys, "argv", ["extractor_url.py", "https://example.com", "--json", "--no-cache"]
    )
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content", lambda *_a, **_kw: "contenido"
    )

    with pytest.raises(SystemExit, match="0"):
        extractor_url.main()

    capsys.readouterr()
    entries = core.load_history()
    assert len(entries) == 1
    assert entries[0]["status"] == "success"
    assert entries[0]["url"] == "https://example.com"
    assert "content" not in entries[0]


def test_main_json_error_escribe_entrada_de_historial(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """Una extracción fallida también queda registrada en el historial."""
    _use_tmp_history(monkeypatch, tmp_path)
    monkeypatch.setattr(
        sys, "argv", ["extractor_url.py", "https://example.com", "--json"]
    )
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content", lambda *_a, **_kw: None
    )

    with pytest.raises(SystemExit, match="1"):
        extractor_url.main()

    capsys.readouterr()
    entries = core.load_history()
    assert len(entries) == 1
    assert entries[0]["status"] == "error"


def test_batch_sin_json_falla_explicito(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """--batch sin --json falla con código 2, sin procesar nada."""
    batch_file = tmp_path / "urls.txt"
    batch_file.write_text("https://a.com\n", encoding="utf-8")
    monkeypatch.setattr(
        sys, "argv", ["extractor_url.py", "--batch", str(batch_file)]
    )
    called = {"extracted": False}
    monkeypatch.setattr(
        extractor_url,
        "extract_formatted_content",
        lambda *_a, **_kw: called.__setitem__("extracted", True),
    )

    with pytest.raises(SystemExit, match="2"):
        extractor_url.main()

    assert "--batch requiere --json" in capsys.readouterr().err
    assert called["extracted"] is False


def test_batch_con_json_procesa_varias_urls_ndjson(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """--batch con --json imprime un JSON por línea, ignora líneas vacías."""
    _use_tmp_history(monkeypatch, tmp_path)
    batch_file = tmp_path / "urls.txt"
    batch_file.write_text(
        "https://a.com\n\n  \nhttps://b.com\nhttps://c.com\n", encoding="utf-8"
    )
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "--batch", str(batch_file), "--json", "--no-cache"],
    )
    monkeypatch.setattr(
        extractor_url, "extract_formatted_content", lambda *_a, **_kw: "contenido"
    )

    extractor_url.main()

    lines = capsys.readouterr().out.strip().splitlines()
    assert len(lines) == 3
    urls_procesadas = [json.loads(line)["url"] for line in lines]
    assert urls_procesadas == ["https://a.com", "https://b.com", "https://c.com"]
    assert all(json.loads(line)["status"] == "success" for line in lines)
    assert len(core.load_history()) == 3


def test_batch_continua_tras_una_url_fallida(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
    tmp_path: Path,
) -> None:
    """Si una URL del batch falla, las siguientes se siguen procesando."""
    _use_tmp_history(monkeypatch, tmp_path)
    batch_file = tmp_path / "urls.txt"
    batch_file.write_text("https://falla.com\nhttps://ok.com\n", encoding="utf-8")
    monkeypatch.setattr(
        sys,
        "argv",
        ["extractor_url.py", "--batch", str(batch_file), "--json", "--no-cache"],
    )

    def _fake_extract(url: str, **_kw: object) -> str | None:
        return None if "falla" in url else "contenido"

    monkeypatch.setattr(extractor_url, "extract_formatted_content", _fake_extract)

    extractor_url.main()

    lines = capsys.readouterr().out.strip().splitlines()
    results = [json.loads(line) for line in lines]
    assert results[0]["status"] == "error"
    assert results[1]["status"] == "success"
