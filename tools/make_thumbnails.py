"""Render a PNG thumbnail next to every STL in the repo, using the OpenSCAD CLI.

Usage: python tools/make_thumbnails.py [--size 256] [--force]
Skips STLs whose PNG is newer than the STL, unless --force.
"""
import argparse
import os
import subprocess
import tempfile
from pathlib import Path

OPENSCAD = os.environ.get("OPENSCAD", r"C:\Program Files\OpenSCAD (Nightly)\openscad.com")
REPO = Path(__file__).resolve().parent.parent


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
