// Shared U-bracket holding a PCB in a slot in each upright. All sizes in mm.
// Part files load this with: use <bracket_lib.scad>
//
// Print settings (Ultimaker Cura, PLA, 0.4 mm nozzle), tuned for strength, not looks.
// Cura profile: BracketStrong.curaprofile
//   Orientation       On its side: U-profile flat on the plate, depth upward.
//                     bracket_printable() already rotates it this way.
//                     Layers then run across the uprights, not up them. No supports needed.
//   Layer Height      0.2 mm (thicker layers bond better than fine ones)
//   Wall Line Count   5 (walls carry most of the load; 2 mm shell each side)
//   Top/Bottom        1.2 mm
//   Infill            40 %, Gyroid (strong in all directions)
//   Printing Temp     +5..10 °C over your normal PLA profile, for better layer bonding
//   Fan Speed         reduce to ~50 %, same reason
//   Adhesion          Skirt. The 5 mm brim is part of the model (bracket_printable),
//                     because Cura cannot leave the brim out at the slot mouths.

// Concave fillet along Y, filling the corner at the origin towards +X and +Z.
module fillet(r, depth) {
    difference() {
        cube([r, depth, r]);
        translate([r, -1, r]) rotate([-90, 0, 0]) cylinder(r = r, h = depth + 2, $fn = 64);
    }
}

// slot_span:  distance between slot bottoms = PCB width + clearance (critical)
// depth:      along Y; height: top of uprights; base: floor thickness
// wall:       upright thickness
// slot_z:     bottom of slot from floor underside; slot_h: slot height
// slot_depth: how far the slot cuts into the upright, from the inside
// fillet_r:   inside corner floor/upright, 0 for none; keep below slot_z - base
// slot_flare: extra slot height at the slot bottom, tapering to 0 at the mouth. Narrow slots
//             print as a wedge (the nozzle turn at the closed end overfills it); this compensates.
function bracket_length(slot_span, wall, slot_depth) = slot_span - 2 * slot_depth + 2 * wall;

module bracket(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r, slot_flare = 0) {
    length = bracket_length(slot_span, wall, slot_depth);
    echo(length = length);
    difference() {
        union() {
            cube([length, depth, base]);                       // floor
            cube([wall, depth, height]);                       // left upright
            translate([length - wall, 0, 0]) cube([wall, depth, height]);  // right upright
            if (fillet_r > 0) {
                translate([wall, 0, base]) fillet(fillet_r, depth);
                translate([length - wall, 0, base]) mirror([1, 0, 0]) fillet(fillet_r, depth);
            }
        }
        // slots, cut from the inside face; 0.01 overlap avoids zero-thickness skins
        for (m = [0, 1])
            translate([m * length, 0, 0]) mirror([m, 0, 0])
                translate([0, depth + 1, 0]) rotate([90, 0, 0]) linear_extrude(depth + 2)
                    polygon([[wall - slot_depth, slot_z - slot_flare / 2], [wall + 0.01, slot_z],
                             [wall + 0.01, slot_z + slot_h], [wall - slot_depth, slot_z + slot_h + slot_flare / 2]]);
    }
}

// Same bracket, rotated into print orientation (on its side), with a one-layer brim
// that keeps brim_keepout clear around each slot mouth so it cannot fill the slot.
// brim_w = 0 for no brim.
module bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r,
                         slot_flare = 0, brim_w = 5, brim_keepout = 5, brim_h = 0.2) {
    module part() rotate([90, 0, 0])
        bracket(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r, slot_flare);
    length = bracket_length(slot_span, wall, slot_depth);
    part();
    if (brim_w > 0)
        linear_extrude(brim_h) difference() {
            offset(r = brim_w) projection(cut = true) translate([0, 0, -0.1]) part();
            // printed orientation: original z becomes -y
            for (x = [wall - slot_depth / 2, length - wall + slot_depth / 2])
                translate([x, -(slot_z + slot_h / 2)]) square(2 * brim_keepout, center = true);
        }
}
