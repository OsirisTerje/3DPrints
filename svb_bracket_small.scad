// SVB bracket, small. Dimensions from "SVB Bracket small.stl", plus fillets.
// Print settings: see bracket_lib.scad.
use <bracket_lib.scad>

slot_span  = 64.9;  // distance between slot bottoms (critical)
depth      = 10;
height     = 14.9;
base       = 3;
wall       = 5;
slot_z     = 8.3;
slot_h     = 1.2;
slot_depth = 2.45;
fillet_r   = 3;

bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r);
