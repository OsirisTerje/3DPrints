// SVB power supply bracket. Print settings: see bracket_lib.scad.
use <bracket_lib.scad>

slot_span  = 60.3;  // distance between slot bottoms = PCB width + clearance (critical)
depth      = 20;
height     = 14.9;
base       = 3;
wall       = 7.64;
slot_z     = 8.3;
slot_h     = 1.8;   // PCB 1.6 + clearance for PLA shrink
slot_depth = 2.3;
fillet_r   = 3;

bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r);
