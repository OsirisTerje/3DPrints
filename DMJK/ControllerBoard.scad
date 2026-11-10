// ControllerBoard: base plate carrying an Arduino Uno, a proto shield and a 25/65 power board side by side,
// fastened to a bjelke with ears. Plate and ears as VallekilenSCB, plus a middle top ear and two screw holes in the lower half.
// All sizes in mm. Prints flat, stands up, no supports.
//
//   +----+-------------------------+----+------------------------+----+  <- ears with screw holes
//   | o  |                         | o  |                        |  o |
//   +----+-------------------------+----+------------------------+----+
//   | [ Arduino Uno ]        [ proto shield  ]        [25/65]          |
//   | [  upright    ]        [  upright      ]        [power]          |
// o(| [             ] <-10-> [               ] <-10-> [     ]          )o  <- round ears
//   | [    USB      ]        [               ]        [     ]          |
//   |                 o                       o                       |  <- screw holes in the gaps
//   +-------------------------------------------------------------------+
//  (0,0)          USB end of the Arduino boards at the bottom
use <../boards.scad>

$fn = 48;

plate_t  = 4;      // plate thickness
margin   = 5;      // plate edge to board edge
gap      = 10;     // between boards
stand_d  = 8;
hole     = 4;      // stand hole, sized for heat-set inserts
fillet_r = 2;      // rounded foot where a stand meets the plate
frame    = 5;      // plate left around a cut-out, measured from the stand edges

uno      = arduino_uno();
uno_h    = 7;      // stand height above the plate
power    = board_25_65();
power_h  = 7;
// no mounting holes: drill the corner raster holes
power_holes = [for (c = [1, 25], r = [1, 9]) board_raster_xy(power, c, r)];
shield   = arduino_proto_shield();
shield_h = 12;
support_d    = 4;  // solid stand opposite the shield's single hole at the USB end
support_edge = 10; // support center to the shield's long edge

plate_w = margin + board_width(uno) + gap + board_width(power) + gap + board_width(shield) + margin;
plate_l = margin + max(board_length(uno), board_length(power), board_length(shield)) + margin;

uno_pos    = [margin, margin];
shield_pos = [margin + board_width(uno) + gap, margin];
power_pos  = [shield_pos[0] + board_width(shield) + gap, margin];

ear_w      = 16;  // top tabs: both corners and the middle
ear_l      = 12;
ear_hole   = 4;
ear_x      = [0, (plate_w - ear_w) / 2, plate_w - ear_w];  // left edge of each top tab
side_ear_r = 10;  // round ears on the left and right edges
side_ear_y = 0.3 * plate_l;
// Screw holes in the gaps between the boards, reachable from above. y keeps an 8 mm screw head
// clear of the stand feet: the right hole sits higher, above the power board's bottom-left stand.
gap_holes  = [[shield_pos[0] - gap / 2, 8], [power_pos[0] - gap / 2, 15]];

// All boards turned 90 degrees: board x (length) runs along plate y, x = 0 edge (USB) at the bottom.
function placed(pos, b, v) = pos + [board_width(b) - v[1], v[0]];

uno_stands    = [for (v = board_holes(uno)) placed(uno_pos, uno, v)];
power_stands  = [for (v = power_holes) placed(power_pos, power, v)];
shield_stands = [for (v = board_holes(shield)) placed(shield_pos, shield, v)];
// shield hole 0 is the single one at the USB end, 2.54 from the far long edge
support       = placed(shield_pos, shield, [board_holes(shield)[0][0], support_edge]);

// Stand with a concave rounded foot; hole = 0 for a solid stand.
module standoff(d, h, hole) {
    difference() {
        union() {
            cylinder(d = d, h = h);
            rotate_extrude() translate([d / 2, 0]) difference() {
                square(fillet_r);
                translate([fillet_r, fillet_r]) circle(r = fillet_r);
            }
        }
        if (hole > 0) cylinder(d = hole, h = h + 1);
    }
}

module stands(points, h) {
    for (q = points) translate([q[0], q[1], plate_t]) standoff(stand_d, h, hole);
}

// Cut-out inside the bounding box of a group of stands, keeping `frame` of plate around each stand.
// inset_x = 0 lets a narrow board's cut-out reach out to its stand centers across x; the y inset
// alone keeps the plate around the stands then.
module cutout(points, inset_x = stand_d / 2 + fillet_r + frame) {
    inset = stand_d / 2 + fillet_r + frame;
    lo = [min([for (q = points) q[0]]) + inset_x, min([for (q = points) q[1]]) + inset];
    hi = [max([for (q = points) q[0]]) - inset_x, max([for (q = points) q[1]]) - inset];
    if (hi[0] > lo[0] && hi[1] > lo[1])
        translate([lo[0], lo[1], -1]) cube([hi[0] - lo[0], hi[1] - lo[1], plate_t + 2]);
}

module plate() {
    difference() {
        union() {
            cube([plate_w, plate_l, plate_t]);
            for (x = ear_x) translate([x, plate_l, 0]) cube([ear_w, ear_l, plate_t]);
            for (x = [0, plate_w]) translate([x, side_ear_y, 0]) cylinder(r = side_ear_r, h = plate_t);
        }
        for (x = [for (e = ear_x) e + ear_w / 2])
            translate([x, plate_l + ear_l / 2, -1]) cylinder(d = ear_hole, h = plate_t + 2);
        for (q = gap_holes) translate([q[0], q[1], -1]) cylinder(d = ear_hole, h = plate_t + 2);
        for (x = [-side_ear_r / 2, plate_w + side_ear_r / 2])
            translate([x, side_ear_y, -1]) cylinder(d = ear_hole, h = plate_t + 2);
        cutout(uno_stands);
        cutout(concat(shield_stands, [support]));
        cutout(power_stands, inset_x = 0);
    }
}

echo(plate = [plate_w, plate_l]);

plate();
stands(uno_stands, uno_h);
stands(power_stands, power_h);
stands(shield_stands, shield_h);
translate([support[0], support[1], plate_t]) standoff(support_d, shield_h, 0);

// Boards shown see-through in preview (F5) only
%translate([uno_pos[0] + board_width(uno), uno_pos[1], plate_t + uno_h]) rotate(90) board(uno);
%translate([power_pos[0] + board_width(power), power_pos[1], plate_t + power_h]) rotate(90) board(power);
%translate([shield_pos[0] + board_width(shield), shield_pos[1], plate_t + shield_h]) rotate(90) board(shield);
