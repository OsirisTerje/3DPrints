"""Write catalog.html and catalog.md in the repo root: one section per folder, one row per STL
with name, size (W x D x H in mm) and the thumbnail made by make_thumbnails.py.
catalog.md is the one GitHub renders; catalog.html is for local viewing.

Usage: python tools/make_catalog.py
"""
import html
import struct
from pathlib import Path
from urllib.parse import quote

REPO = Path(__file__).resolve().parent.parent


def stl_size(data: bytes) -> tuple[float, float, float]:
    """Bounding box size (x, y, z) of an ASCII or binary STL."""
    count = struct.unpack_from("<I", data, 80)[0] if len(data) >= 84 else -1
    if len(data) == 84 + count * 50:
        floats = [v for tri in struct.iter_unpack("<12fH", data[84:]) for v in tri[3:12]]
        verts = [floats[i:i + 3] for i in range(0, len(floats), 3)]
    else:
        verts = [list(map(float, line.split()[1:4])) for line in data.decode(errors="replace").splitlines()
                 if line.strip().startswith("vertex")]
    if not verts:
        return (0.0, 0.0, 0.0)
    return tuple(max(v[a] for v in verts) - min(v[a] for v in verts) for a in range(3))


def selftest() -> None:
    tri = [(0, 0, 0), (10, 0, 0), (0, 20, 5)]
    ascii_stl = "solid t\nfacet normal 0 0 1\nouter loop\n" + "".join(
        f"vertex {x} {y} {z}\n" for x, y, z in tri) + "endloop\nendfacet\nendsolid t\n"
    binary_stl = b"\0" * 80 + struct.pack("<I", 1) + struct.pack("<12fH", 0, 0, 1, *[c for v in tri for c in v], 0)
    assert stl_size(ascii_stl.encode()) == (10, 20, 5)
    assert stl_size(binary_stl) == (10, 20, 5)


def main() -> None:
    selftest()
    stls = sorted((p for p in REPO.rglob("*") if p.suffix.lower() == ".stl" and ".git" not in p.parts),
                  key=lambda p: (p.parent != REPO, str(p.parent).lower(), p.name.lower()))
    sections, md, current = [], ["# 3DPrints catalog", "", f"{len(stls)} models.", ""], None
    for stl in stls:
        folder = stl.parent.relative_to(REPO).as_posix()
        if folder != current:
            if current is not None:
                sections.append("</table>")
            title = "(root)" if folder == "." else folder
            sections.append(f"<h2>{html.escape(title)}</h2>\n<table>"
                            "<tr><th>Name</th><th>Size W × D × H (mm)</th><th>Thumbnail</th></tr>")
            md += ["", f"## {title}", "", "| Name | Size W × D × H (mm) | Thumbnail |", "|---|---|---|"]
            current = folder
        w, d, h = stl_size(stl.read_bytes())
        size = f"{w:.1f} × {d:.1f} × {h:.1f}"
        png = stl.with_suffix(".png")
        src = quote(png.relative_to(REPO).as_posix())
        img_html = f'<img src="{src}" alt="" loading="lazy">' if png.exists() else "no thumbnail"
        img_md = f'<img src="{src}" width="128">' if png.exists() else "no thumbnail"
        sections.append(f"<tr><td>{html.escape(stl.stem)}</td><td class=num>{size}</td><td>{img_html}</td></tr>")
        md.append(f"| {html.escape(stl.stem).replace('|', '&#124;')} | {size} | {img_md} |")
    sections.append("</table>")
    (REPO / "catalog.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    page = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>3DPrints catalog</title>
<style>
body {{ font-family: system-ui, sans-serif; margin: 2em; }}
table {{ border-collapse: collapse; margin-bottom: 2em; }}
th, td {{ border: 1px solid #ccc; padding: 4px 10px; text-align: left; vertical-align: middle; }}
td.num {{ font-variant-numeric: tabular-nums; white-space: nowrap; }}
img {{ width: 128px; height: 128px; }}
</style></head><body>
<h1>3DPrints catalog</h1>
<p>{len(stls)} models.</p>
{chr(10).join(sections)}
</body></html>
"""
    (REPO / "catalog.html").write_text(page, encoding="utf-8")
    print(f"catalog.html, catalog.md: {len(stls)} STLs")


if __name__ == "__main__":
    main()
