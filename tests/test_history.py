"""Pruebas del historial de extracciones (Fase 14)."""

from __future__ import annotations

from pathlib import Path

import pytest

import core


def _use_tmp_history(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> Path:
    history_file = tmp_path / "history.jsonl"
    monkeypatch.setattr(core, "_CACHE_DIR", tmp_path)
    monkeypatch.setattr(core, "_HISTORY_FILE", history_file)
    return history_file


def test_record_history_entry_escribe_linea_json(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    history_file = _use_tmp_history(monkeypatch, tmp_path)

    core.record_history_entry({"url": "https://example.com", "status": "success"})

    lines = history_file.read_text(encoding="utf-8").splitlines()
    assert len(lines) == 1
    assert '"url": "https://example.com"' in lines[0]


def test_record_history_entry_dos_llamadas_no_se_sobrescriben(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    history_file = _use_tmp_history(monkeypatch, tmp_path)

    core.record_history_entry({"url": "https://a.com", "status": "success"})
    core.record_history_entry({"url": "https://b.com", "status": "success"})

    lines = history_file.read_text(encoding="utf-8").splitlines()
    assert len(lines) == 2


def test_record_history_entry_nunca_lanza_si_no_se_puede_escribir(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    _use_tmp_history(monkeypatch, tmp_path)

    def _fail_mkdir(*_args: object, **_kwargs: object) -> None:
        raise OSError("sin permisos")

    monkeypatch.setattr(Path, "mkdir", _fail_mkdir)

    core.record_history_entry({"url": "https://example.com", "status": "success"})


def test_load_history_devuelve_mas_reciente_primero(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    _use_tmp_history(monkeypatch, tmp_path)

    core.record_history_entry({"url": "https://a.com", "status": "success"})
    core.record_history_entry({"url": "https://b.com", "status": "success"})
    core.record_history_entry({"url": "https://c.com", "status": "success"})

    entries = core.load_history()

    assert [e["url"] for e in entries] == [
        "https://c.com",
        "https://b.com",
        "https://a.com",
    ]


def test_load_history_respeta_limit(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    _use_tmp_history(monkeypatch, tmp_path)

    for i in range(5):
        core.record_history_entry({"url": f"https://{i}.com", "status": "success"})

    entries = core.load_history(limit=2)

    assert len(entries) == 2
    assert entries[0]["url"] == "https://4.com"


def test_load_history_ignora_linea_corrupta(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    history_file = _use_tmp_history(monkeypatch, tmp_path)

    core.record_history_entry({"url": "https://a.com", "status": "success"})
    with history_file.open("a", encoding="utf-8") as f:
        f.write("esto no es JSON válido\n")
    core.record_history_entry({"url": "https://b.com", "status": "success"})

    entries = core.load_history()

    assert [e["url"] for e in entries] == ["https://b.com", "https://a.com"]


def test_load_history_archivo_inexistente_devuelve_lista_vacia(
    monkeypatch: pytest.MonkeyPatch, tmp_path: Path
) -> None:
    history_file = _use_tmp_history(monkeypatch, tmp_path)

    entries = core.load_history()

    assert entries == []
    assert not history_file.exists()
