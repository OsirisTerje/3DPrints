"""Render a PNG thumbnail next to every STL in the repo, using the OpenSCAD CLI.
First exports each board in boards.scad to boards/<function>.stl, so the board library
gets thumbnails and catalog rows too.

Usage: python tools/make_thumbnails.py [--size 256] [--force]
Skips STLs whose PNG is newer than the STL, and boards whose STL is newer than boards.scad,
unless --force.
"""
import argparse
import os
import re
import subprocess
import tempfile
from pathlib import Path

OPENSCAD = os.environ.get("OPENSCAD", r"C:\Program Files\OpenSCAD (Nightly)\openscad.com")
REPO = Path(__file__).resolve().parent.parent
BOARDS_SCAD = REPO / "boards.scad"
BOARDS_DIR = REPO / "boards"


def board_functions(scad_text: str) -> list[str]:
    """Names of the board functions: those callable without arguments (accessors take a board)."""
    names = []
    for name, params in re.findall(r"^function (\w+)\(([^)]*)\)\s*=", scad_text, re.MULTILINE):
        if all("=" in p for p in params.split(",") if p.strip()):
            names.append(name)
    return names


def selftest() -> None:
    text = "function a() = 1;\nfunction b(n = 5) = n;\nfunction c(b) = b[0];\nfunction d(b, n = 1) = n;\n"
    assert board_functions(text) == ["a", "b"]


def export_boards(force: bool, tmp: Path) -> None:
    BOARDS_DIR.mkdir(exist_ok=True)
    scad = tmp / "board.scad"
    for name in board_functions(BOARDS_SCAD.read_text(encoding="utf-8")):
        stl = BOARDS_DIR / f"{name}.stl"
        if not force and stl.exists() and stl.stat().st_mtime >= BOARDS_SCAD.stat().st_mtime:
            continue
        scad.write_text(f"use <{BOARDS_SCAD.as_posix()}>\nboard({name}());\n")
        cmd = [OPENSCAD, "--backend=manifold", "--export-format", "binstl", "-o", str(stl), str(scad)]
        result = subprocess.run(cmd, capture_output=True, text=True)
        print(f"{'ok' if result.returncode == 0 else 'FAILED':6} {stl.relative_to(REPO)}")


def render(stl: Path, png: Path, size: int, scad: Path) -> bool:
    cmd = [OPENSCAD, "-o", str(png), f"--imgsize={size},{size}", "--viewall", "--autocenter",
           "--colorscheme=Tomorrow", "-D", f'file="{stl.as_posix()}"', str(scad)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"FAILED {stl.relative_to(REPO)}\n{result.stderr.strip()[-500:]}")
    return result.returncode == 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, default=256)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    selftest()

    with tempfile.TemporaryDirectory() as tmp:
        export_boards(args.force, Path(tmp))
    stls = sorted(p for p in REPO.rglob("*") if p.suffix.lower() == ".stl" and ".git" not in p.parts)
    with tempfile.TemporaryDirectory() as tmp:
        scad = Path(tmp) / "thumb.scad"
        scad.write_text("import(file);\n")
        done = failed = 0
        for stl in stls:
            png = stl.with_suffix(".png")
            if not args.force and png.exists() and png.stat().st_mtime >= stl.stat().st_mtime:
                continue
            if render(stl, png, args.size, scad):
                done += 1
                print(f"ok     {png.relative_to(REPO)}")
            else:
                failed += 1
    print(f"{done} rendered, {failed} failed, {len(stls)} STLs total")


if __name__ == "__main__":
    main()
