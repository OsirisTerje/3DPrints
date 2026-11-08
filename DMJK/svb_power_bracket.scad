// SVB power supply bracket. Print settings: see bracket_lib.scad.
use <../bracket_lib.scad>

slot_span  = 61;    // slot bottoms: PCB 60.0 + 0.5 play + 0.3 lost in print (60.3 printed as 60.0)
depth      = 20;
height     = 14.9;
base       = 3;
wall       = 7.64;
slot_z     = 8.3;
slot_h     = 2.1;   // PCB 1.6 + 0.15 play + 0.35 lost in print (1.8 printed as 1.45)
slot_depth = 2.3;
fillet_r   = 3;

bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r);
