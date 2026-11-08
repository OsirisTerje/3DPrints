// SVB bracket, small. Dimensions from "SVB Bracket small.stl", plus fillets.
// Print settings: see bracket_lib.scad.
use <../bracket_lib.scad>

slot_span  = 65.7;  // slot bottoms: PCB 64.0 + 1.7 play; 66.7 let the board drop out of one slot
depth      = 10;
height     = 14.9;
base       = 3;
wall       = 7;     // 5 was thin behind the slot
slot_z     = 8.3;
slot_h     = 1.4;   // PCB 1.1; 1.5 (+0.4 flare) printed a bit loose and uneven, filed smooth
slot_depth = 2.45;  // board 1.6 into each slot when centred
slot_flare = 0.4;   // slot is 1.9 at the bottom; 1.5 straight printed as a wedge, 1.25 wire stuck
fillet_r   = 3;

bracket_printable(slot_span, depth, height, base, wall, slot_z, slot_h, slot_depth, fillet_r, slot_flare);
