# 3DPrints

OpenSCAD designs for 3D-printed mounting brackets, plus older STL-only designs.

**[Catalog](catalog.md)**: every model with its size and a thumbnail. Regenerate it with `python tools/make_thumbnails.py` and `python tools/make_catalog.py`.

## Parts

| Part                    | Source                    | STL                      | Holds                     |
|-------------------------|---------------------------|--------------------------|---------------------------|
| SVB power supply bracket | `svb_power_bracket.scad` | `svb_power_bracket.stl`  | 60 mm wide PCB, 1.6 mm thick |
| SVB bracket, small      | `svb_bracket_small.scad`  | `svb_bracket_small.stl`  | 64.9 mm wide PCB          |

Both are U-brackets with a slot in each upright for the PCB edge. The shared geometry is in `bracket_lib.scad`; each part file only sets its dimensions.

### Older designs (STL only)

Made in Tinkercad and other tools before the move to OpenSCAD. No source files.

| Folder                     | Contents                                              |
|----------------------------|-------------------------------------------------------|
| `brackets`                 | Mounting brackets for servos, decoders and boards     |
| `Diverse`                  | Holders, clamps, servo sliders and other small parts  |
| `DualSignalBox`            | Signal box enclosure and board brackets               |
| `Servo mount`              | Servo mount remixes (see the README in the folder)    |
| `Hjulbraketter`            | Wheel alignment brackets                              |
| `Ute`                      | Clamps and garden hose brackets                       |
| `Isabel`                   | Box, cover and flow bracket                           |
| `ballastspreaders`         | Ballast spreader tools                                |
| `Bracket for Uno-vertical`, `Powersupplybracket`, `RelayBoardBracket`, `Voltmeter`, `Platting` | Single parts |

## Building

Open a part file in [OpenSCAD](https://openscad.org) (a development snapshot with the Manifold backend is recommended), press F6 to render and F7 to export. From the command line:

```
openscad --backend=manifold --export-format binstl -o svb_power_bracket.stl svb_power_bracket.scad
```

The STLs in this repo are exported in print orientation. Re-export them after changing a `.scad` file.

## Printing

Print on its side, as exported, so the layers run across the uprights. Settings tuned for strength are listed in `bracket_lib.scad`, and `BracketStrong.curaprofile` is a matching Ultimaker Cura profile (Ultimaker 3, PLA, 0.2 mm layers).
