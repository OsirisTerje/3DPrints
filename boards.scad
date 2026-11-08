// Board library: prototype boards and veroboards to build brackets around. All sizes in mm.
// Part files load this with: use <boards.scad>
// A board is a function, because use<> imports functions and modules but not variables.
//
// Board data: [length (x), width (y), thickness, hole diameter, [hole centers [x, y]],
//              optional raster [pitch, columns (along x), rows (along y), first center [x, y]]]
// Origin is the board corner at the end with the wider hole margin; x runs along the long edge.

// "40/60 board": Double Side Prototype PCB Bread board Tinned Universal 40x60 mm FR4, 2.54 raster.
// Measured: holes 2.2; gap from hole edge to board edge 1.0 at one short edge, 0.5 at the
// other, 0.7-0.8 at the long edges (0.75 used). Thickness 1.3 measured (sold as 1.6).
function board_40_60() = let (r = 2.2 / 2, x0 = 1.0 + r, x1 = 60 - 0.5 - r, y0 = 0.75 + r, y1 = 40 - y0)
    [60, 40, 1.3, 2.2, [[x0, y0], [x0, y1], [x1, y0], [x1, y1]]];

// "25/65 board": prototype board 65.6 x 25.5, 2.54 raster, 25 columns x 9 rows, no mounting holes
// (drill one of the raster holes). Grid assumed centered on the board. Thickness 1.1 measured.
function board_25_65() = let (pitch = 2.54, cols = 25, rows = 9, l = 65.6, w = 25.5)
    [l, w, 1.1, 0, [], [pitch, cols, rows, [(l - (cols - 1) * pitch) / 2, (w - (rows - 1) * pitch) / 2]]];

// "Larger board": prototype board 145.2 x 63.9, 2.54 raster, 56 columns x 24 rows, no mounting
// holes (drill raster holes). Rows are marked A-X along the short edge. Often broken into pieces
// across the long edge; a piece keeps the 63.9 width. Thickness 0.86 measured.
// columns: holes along the length; a piece is assumed to keep one original end (2.75 margin)
// and be broken midway between columns at the other (1.27 margin).
function larger_board(columns = 56) = let (pitch = 2.54, rows = 24, w = 63.9, end = 2.75,
                                           far_end = columns == 56 ? end : pitch / 2)
    [end + (columns - 1) * pitch + far_end, w, 0.86, 0, [],
     [pitch, columns, rows, [end, (w - (rows - 1) * pitch) / 2]]];

// Arduino Uno R3 (Geekcreit and other clones use the same layout). From Arduino's official
// Eagle file arduino_Uno_Rev3-02-TH.brd. Origin: corner below the power jack; x along the
// 68.58 edge, USB and power jack on the x = 0 edge. The USB connector sticks out to x = -6.3,
// the power jack to x = -1.8. The x = 68.58 edge has chamfered corners: full length only
// for y 5.08-37.85. Thickness 1.6 is the standard, not in the file.
//
//  y=53.34  +--------------------------------------------+
//           |  o (15.24, 50.8)  digital header 0-13      \   cut-off corners
//     USB ==|                                o (66.04, 35.56)
//           |                                            |
//   power ==|                                o (66.04, 7.62)
//    jack   |  o (13.97, 2.54)  power/analog header      /
//  (0,0)    +--------------------------------------------+  x=68.58
function arduino_uno() = [68.58, 53.34, 1.6, 3.2, [[13.97, 2.54], [15.24, 50.8], [66.04, 7.62], [66.04, 35.56]]];

// Proto shield R3: prototype board that stacks on the Arduino Uno. Uses 3 of the Uno's holes:
// both at the end away from the USB, and the one at the USB end next to the digital pin header.
// Outline assumed the same as the Uno. Thickness 1.23 measured.
//
//  y=53.34  +--------------------------------------------+
//           |  o (15.24, 50.8)  digital header 0-13      |
//     USB   |                                o (66.04, 35.56)
//   (Uno)   |                                            |
//           |                                o (66.04, 7.62)
//           |                   power/analog header      |
//  (0,0)    +--------------------------------------------+  x=68.58
function arduino_proto_shield() = let (u = board_holes(arduino_uno()))
    [68.58, 53.34, 1.23, 3.2, [u[1], u[2], u[3]]];

// L9110 dual motor driver board (one of several versions sold under this name).
// Measured: 28.9 x 22.5 x 1.65, holes 2.5. Outer hole edge to outer hole edge 16.0 along
// the length and 20.65 across the width, so hole centers 13.5 x 18.15 apart.
// Holes centered on the board along the length (checked on the board).
function l9110_driver() = let (l = 28.9, w = 22.5, d = 2.5, dx = 16.0 - d, dy = 20.65 - d,
                               x0 = (l - dx) / 2, y0 = (w - dy) / 2)
    [l, w, 1.65, d, [[x0, y0], [x0, y0 + dy], [x0 + dx, y0], [x0 + dx, y0 + dy]]];

function board_length(b)    = b[0];
function board_width(b)     = b[1];
function board_thickness(b) = b[2];
function board_hole_d(b)    = b[3];
function board_holes(b)     = b[4];

// Center of raster hole at column col and row row, both counted from 1 at the origin corner.
function board_raster_xy(b, col, row) =
    assert(len(b) > 5, "board has no raster")
    assert(col >= 1 && col <= b[5][1] && row >= 1 && row <= b[5][2], "raster position outside the board")
    b[5][3] + b[5][0] * [col - 1, row - 1];

// Row number for a row letter marked on the board: "A" is 1.
function raster_row(letter) = ord(letter) - ord("A") + 1;

// The board itself, for checking a bracket against it in preview (F5), e.g. %board(board_40_60());
module board(b) {
    difference() {
        cube([board_length(b), board_width(b), board_thickness(b)]);
        for (h = board_holes(b))
            translate([h[0], h[1], -1]) cylinder(d = board_hole_d(b), h = board_thickness(b) + 2, $fn = 32);
    }
}
