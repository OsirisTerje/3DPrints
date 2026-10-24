# 3DPrints

OpenSCAD designs for 3D-printed mounting brackets.

## Parts

| Part                    | Source                    | STL                      | Holds                     |
|-------------------------|---------------------------|--------------------------|---------------------------|
| SVB power supply bracket | `svb_power_bracket.scad` | `svb_power_bracket.stl`  | 60 mm wide PCB, 1.6 mm thick |
| SVB bracket, small      | `svb_bracket_small.scad`  | `svb_bracket_small.stl`  | 64.9 mm wide PCB          |

Both are U-brackets with a slot in each upright for the PCB edge. The shared geometry is in `bracket_lib.scad`; each part file only sets its dimensions.

## Building

Open a part file in [OpenSCAD](https://openscad.org) (a development snapshot with the Manifold backend is recommended), press F6 to render and F7 to export. From the command line:

```
openscad --backend=manifold --export-format binstl -o svb_power_bracket.stl svb_power_bracket.scad
```

The STLs in this repo are exported in print orientation. Re-export them after changing a `.scad` file.

## Printing

Print on its side, as exported, so the layers run across the uprights. Settings tuned for strength are listed in `bracket_lib.scad`, and `BracketStrong.curaprofile` is a matching Ultimaker Cura profile (Ultimaker 3, PLA, 0.2 mm layers).
