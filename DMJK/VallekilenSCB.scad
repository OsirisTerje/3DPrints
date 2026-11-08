// VallekilenSCB: base plate carrying three boards, fastened to a bjelke with ears.
// Based on DualSignalBox/Small Motorboards.stl (plate 4 mm, 7 mm stands, ear layout).
// All sizes in mm. Prints flat, stands up, no supports.
//
//   +----+---------------------------------------+----+  <- ears with screw holes
//   | o  |                                       |  o |
//   +----+---------------------------------------+----+
//   |  [L9110]          [ power 40/60, upright ]      |
// o(|                   [                      ]      )o  <- round ears
//   |  [ Larger board  ]                              |
//   |  [ 17 columns    ]                              |
//   +-------------------------------------------------+
//  (0,0)
use <../boards.scad>

$fn = 48;

plate_t = 4;      // plate thickness
margin  = 5;      // plate edge to board edge
gap     = 5;      // between boards
stand_d = 8;
stand_h = 7;      // stand height above the plate, same for all boards
screw_hole = 2.5; // M2.5 self-tapping screws on all boards
frame   = 5;      // plate left around a cut-out, measured from the stand edges

// Larger board broken at column 17. Holes drilled at B2 and X2 now, B15 and X15 to come.
larger       = larger_board(17);
larger_holes = [for (c = [2, 15], r = ["B", "X"]) board_raster_xy(larger, c, raster_row(r))];

l9110   = l9110_driver();
power   = board_40_60();   // mounted upright: its 60 mm edge along y

plate_w = margin + max(board_length(larger), board_length(l9110) + gap + board_width(power)) + margin;
plate_l = margin + board_width(larger) + gap + board_length(power) + margin;

larger_pos = [margin, margin];
l9110_pos  = [margin, plate_l - margin - board_width(l9110)];
power_pos  = [plate_w - margin - board_width(power), plate_l - margin - board_length(power)];

ear_w      = 16;  // top-corner tabs
ear_l      = 12;
ear_hole   = 3.2;
side_ear_r = 10;  // round ears on the left and right edges
side_ear_y = 0.3 * plate_l;

// Board footprint in plate coordinates: rot 90 turns the board so its length runs along y.
function placed(p, rot, v) = rot == 90 ? p + [-v[1], v[0]] : p + v;
function power_xy(v) = placed(power_pos + [board_width(power), 0], 90, v);

module stands(points, h, screw) {
    for (q = points) translate([q[0], q[1], plate_t]) difference() {
        cylinder(d = stand_d, h = h);
        cylinder(d = screw, h = h + 1);
    }
}

// Rectangular hole through the plate from corner lo to corner hi; skipped if it has no area.
module window(lo, hi) {
    if (hi[0] > lo[0] && hi[1] > lo[1])
        translate([lo[0], lo[1], -1]) cube([hi[0] - lo[0], hi[1] - lo[1], plate_t + 2]);
}

// Cut-out inside a rectangle of stands, keeping `frame` of plate around each stand.
module cutout(points) {
    inset = stand_d / 2 + frame;
    window([min([for (q = points) q[0]]) + inset, min([for (q = points) q[1]]) + inset],
           [max([for (q = points) q[0]]) - inset, max([for (q = points) q[1]]) - inset]);
}

function min_axis(points, a) = min([for (q = points) q[a]]);
function max_axis(points, a) = max([for (q = points) q[a]]);
stand_clear = stand_d / 2 + frame;  // plate kept between a window and a stand center

module plate() {
    difference() {
        union() {
            cube([plate_w, plate_l, plate_t]);
            for (x = [0, plate_w - ear_w]) translate([x, plate_l, 0]) cube([ear_w, ear_l, plate_t]);
            for (x = [0, plate_w]) translate([x, side_ear_y, 0]) cylinder(r = side_ear_r, h = plate_t);
        }
        for (x = [ear_w / 2, plate_w - ear_w / 2])
            translate([x, plate_l + ear_l / 2, -1]) cylinder(d = ear_hole, h = plate_t + 2);
        for (x = [-side_ear_r / 2, plate_w + side_ear_r / 2])
            translate([x, side_ear_y, -1]) cylinder(d = ear_hole, h = plate_t + 2);
        cutout([for (v = larger_holes) larger_pos + v]);
        cutout([for (v = board_holes(power)) power_xy(v)]);
        // empty area right of the Larger board, below the power board
        window([larger_pos[0] + board_length(larger) + frame, frame],
               [plate_w - frame, min_axis(power_stands, 1) - stand_clear]);
        // empty area between the Larger board and the L9110, left of the power board
        window([frame, max_axis(larger_stands, 1) + stand_clear],
               [min_axis(power_stands, 0) - stand_clear, min_axis(l9110_stands, 1) - stand_clear]);
    }
}

larger_stands = [for (v = larger_holes) larger_pos + v];
l9110_stands  = [for (v = board_holes(l9110)) l9110_pos + v];
power_stands  = [for (v = board_holes(power)) power_xy(v)];
echo(plate = [plate_w, plate_l]);

plate();
stands(larger_stands, stand_h, screw_hole);
stands(l9110_stands, stand_h, screw_hole);
stands(power_stands, stand_h, screw_hole);

// Boards shown see-through in preview (F5) only
%translate([larger_pos[0], larger_pos[1], plate_t + stand_h]) board(larger);
%translate([l9110_pos[0], l9110_pos[1], plate_t + stand_h]) board(l9110);
%translate([power_pos[0] + board_width(power), power_pos[1], plate_t + stand_h]) rotate(90) board(power);
