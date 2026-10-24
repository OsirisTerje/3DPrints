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
//   Adhesion          Brim, 5 mm (the 3 mm floor strip is the thin edge that can lift)

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
module bracket(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r) {
    length = slot_span - 2 * slot_depth + 2 * wall;
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
        for (x = [wall - slot_depth, length - wall - 0.01])
            translate([x, -1, slot_z]) cube([slot_depth + 0.01, depth + 2, slot_h]);
    }
}

// Same bracket, rotated into print orientation (on its side).
module bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r) {
    rotate([90, 0, 0])
        bracket(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r);
}
