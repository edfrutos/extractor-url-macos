#!/usr/bin/env python3
"""build_runtime_update.py — Genera el paquete de actualización del
runtime Python embebido (Fase 21): las dependencias Python puras
vendorizadas (requests/beautifulsoup4/markdownify/trafilatura y sus
dependencias transitivas), excluyendo cualquier paquete con extensiones
compiladas (.so/.dylib/.pyd) — esas siguen viniendo solo del bundle
firmado del .app (lxml en particular; ver 21-RESEARCH.md, Decisión de
alcance — el intérprete y Chromium no se tocan en esta fase).

USO:
    python3 scripts/build_runtime_update.py <version>
    # ej: python3 scripts/build_runtime_update.py 2026-08-23

Deja el zip en .build-cache/runtime-update/python-packages-<version>.zip
y runtime-manifest.json actualizado en la raíz del repo. No publica nada
automáticamente — imprime el comando `gh release create` exacto a
ejecutar, mismo patrón que scripts/release-macos.sh con el appcast (el
commit/push del manifiesto queda bajo control explícito del usuario).
"""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
BUILD_CACHE = PROJECT_DIR / ".build-cache" / "runtime-update"
GITHUB_REPO = "edfrutos/extractor-url-macos"

# Paquetes de nivel superior que se intentan actualizar. pip resuelve sus
# dependencias transitivas puras automáticamente (soupsieve, urllib3,
# certifi, courlan, htmldate, justext, dateparser, etc.) — solo se
# excluyen las que traigan binarios compilados (ver _find_compiled_packages).
TOP_LEVEL_PACKAGES = ["requests", "beautifulsoup4", "markdownify", "trafilatura"]


def _find_compiled_packages(root: Path) -> set[str]:
    """Nombres de paquete de nivel superior que contienen binarios
    compilados (.so/.dylib/.pyd) — se excluyen del override; el intérprete
    los seguirá resolviendo desde el bundle firmado (fallback normal de
    PYTHONPATH, ver 21-RESEARCH.md)."""
    compiled = set()
    for path in root.rglob("*"):
        if path.suffix in (".so", ".dylib", ".pyd"):
            compiled.add(path.relative_to(root).parts[0])
    return compiled


def _copy_pure_packages(src: Path, dest: Path, exclude: set[str]) -> None:
    """Copia todo lo instalado salvo los paquetes excluidos y sus
    directorios *.dist-info/*.egg-info (identificados por prefijo)."""
    dest.mkdir(parents=True, exist_ok=True)
    for entry in sorted(src.iterdir()):
        name = entry.name
        if name in exclude or name == "__pycache__":
            continue
        if any(name.startswith(f"{pkg}-") for pkg in exclude):
            continue
        if entry.is_dir():
            shutil.copytree(entry, dest / name)
        else:
            shutil.copy2(entry, dest / name)


def main() -> None:
    """Punto de entrada: genera el zip de override y runtime-manifest.json."""
    if len(sys.argv) != 2:
        print("Uso: python3 scripts/build_runtime_update.py <version>", file=sys.stderr)
        sys.exit(2)
    version = sys.argv[1]

    BUILD_CACHE.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        install_dir = tmp_path / "install"
        print(f"Instalando {', '.join(TOP_LEVEL_PACKAGES)} en un directorio limpio…")
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "--quiet",
             "--target", str(install_dir), *TOP_LEVEL_PACKAGES],
            check=True,
        )

        compiled = _find_compiled_packages(install_dir)
        if compiled:
            print(f"Excluyendo paquetes con binarios compilados: {', '.join(sorted(compiled))}")
            print("  (se resolverán desde el bundle firmado del .app en tiempo de ejecución)")

        pure_dir = tmp_path / "pure"
        _copy_pure_packages(install_dir, pure_dir, compiled)

        zip_base = BUILD_CACHE / f"python-packages-{version}"
        zip_path = zip_base.with_suffix(".zip")
        if zip_path.exists():
            zip_path.unlink()
        shutil.make_archive(str(zip_base), "zip", root_dir=pure_dir)

    sha256 = hashlib.sha256(zip_path.read_bytes()).hexdigest()
    download_url = (
        f"https://github.com/{GITHUB_REPO}/releases/download/"
        f"runtime-{version}/python-packages-{version}.zip"
    )
    manifest = {"version": version, "download_url": download_url, "sha256": sha256}
    manifest_path = PROJECT_DIR / "runtime-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    print("")
    print(f"Zip generado: {zip_path} ({zip_path.stat().st_size / 1024:.0f} KB)")
    print(f"runtime-manifest.json actualizado en {manifest_path}")
    print("")
    print("Para publicar (revisa antes de ejecutar):")
    print(f"  gh release create 'runtime-{version}' '{zip_path}' \\")
    print(f"    --repo {GITHUB_REPO} \\")
    print("    --title 'Runtime update " + version + "' \\")
    print("    --notes 'Actualización de dependencias Python puras (Fase 21)'")
    print("  git add runtime-manifest.json && git commit -m 'chore(runtime): "
          + version + "' && git push")


if __name__ == "__main__":
    main()
