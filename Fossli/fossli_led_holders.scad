// LED holder plates for the Fossli control panel, mounted on the underside.
// Hole positions come from C:\repos\mj\H0mFossli\Fossli 20260220-2.svg (A4, 1:1, mm),
// layers "Lys", "Signaler" (LEDs) and "Brytere Stamme" (switch bodies).
//
// Modelled in top view (as the SVG), recesses on top, then exported upside down so the
// panel side prints against the bed (smooth). After printing, turn the plate over and
// mount it recess side up. No mirroring needed.
// Each LED: a recess for the LED collar and two leg holes. Legs run along the group line
// (across it puts one leg hole 0.09 mm from a switch cut-out). Turn the anodes inward
// and neighbouring anodes end up ~3 mm apart, easy to bridge for the soldered string.
//
// Export one plate: openscad -D 'part="left"' -o left.stl fossli_led_holders.scad
$fn = 48;

part          = "both";  // "left", "right" or "both"
thick         = 3;       // plate thickness (2 was too flexible)
recess_d      = 4.2;     // LED collar 3.2; printed as ~4.0
recess_depth  = 1.0;     // collar height; 0 for a flat plate
leg_d         = 1.4;     // legs are 0.45; small holes print ~0.4 undersize, 1.0 closed up
leg_pitch     = 2.54;
pad_r         = 3.2;     // material around each LED before the switch cut-outs
switch_clear  = 0.5;     // gap between plate and switch bodies

// LED centers per group, SVG coordinates
left_groups = [
    [[32.19, 104.08], [37.19, 104.08], [42.19, 104.08]],  // signal
    [[62.61, 103.43], [60.31, 108.72]],
    [[94.17, 111.82], [92.99, 117.03]],
    [[107.79, 125.73], [106.82, 130.86]],
];
right_groups = [
    [[201.44, 125.73], [201.50, 132.05], [201.56, 139.76]],
    [[202.82, 93.77], [200.52, 99.04]],
    [[214.48, 111.76], [214.78, 118.87]],
    [[227.17, 99.04], [229.26, 104.39]],
];
// Switch bodies: center x, y, width, height, SVG coordinates
switches = [
    [42.18, 122.92, 13, 7], [69.00, 109.00, 7, 13], [86.90, 111.76, 7, 13], [99.68, 123.72, 7, 13],
    [192.51, 139.90, 7, 13], [211.56, 99.04, 7, 13], [220.82, 111.76, 7, 13], [235.03, 98.81, 7, 13],
    [243.50, 140.00, 7, 13],
];

function p(v) = [v[0], -v[1]];  // SVG has y down, OpenSCAD y up

function group_angle(g) = let (a = p(g[0]), b = p(g[len(g) - 1])) atan2(b[1] - a[1], b[0] - a[0]);

module plate(groups) {
    difference() {
        linear_extrude(thick) difference() {
            hull() for (g = groups, v = g) translate(p(v)) circle(r = pad_r);
            for (s = switches)
                translate(p(s)) square([s[2] + 2 * switch_clear, s[3] + 2 * switch_clear], center = true);
        }
        for (g = groups, v = g)
            translate(p(v)) rotate(group_angle(g)) {
                if (recess_depth > 0)
                    translate([0, 0, thick - recess_depth]) cylinder(d = recess_d, h = recess_depth + 1);
                for (side = [-1, 1])
                    translate([side * leg_pitch / 2, 0, -1]) cylinder(d = leg_d, h = thick + 2);
            }
    }
}

translate([0, 0, thick]) rotate([180, 0, 0]) {  // print orientation: panel side down
    if (part != "right") plate(left_groups);
    if (part != "left") plate(right_groups);
}
