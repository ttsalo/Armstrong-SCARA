/* Harmonic Drive NG by Tomi T. Salo <ttsalo@iki.fi> 2013 */

/* New Generation Harmonic Drive. 

   Design principles: 
   - Two relatively closely spaced round flanges, which rotate relative to each other
   - Flanges connect to the inner and outer rims of a large diameter bearing, offering
     good stability.
   - The flexspline fits inside the bearing, making the whole assembly compact.
   - The flexspline flange's outside surface is smooth, allowing mounting to a solid surface, 
     if necessary, and all the drive parts can be disassembled from the circspline side while 
     both flanges and the main bearing remain attached to the main application.
*/

/* Prototype notes:
   6012 bearing, size 60x95x18

*/   

tol = 0.25;

/* 6012 size bearing */
bearing_inner_r = 60/2;
bearing_outer_r = 95/2;
bearing_h = 18;
bearing_cone_l = 1; // Length of the bearing conical section 

flange_r = 40;
flange_h = 5;

flex_flange_r = flange_r;
flex_flange_h = flange_h;
flex_flange_sep = 5; // Distance from bearing to flange
flex_inner_t = 3; // Outer side thickness of the bearing support
flex_below_hook = 3;
flex_above_hook = 3;
flex_above_h = 3;
flex_base_t = 8;
flex_lockring_h = 2;
flex_lockring_t = 2;

circ_flange_r = flange_r;
circ_flange_h = flange_h;
circ_flange_sep = 5; // Distance from bearing to flange
circ_outer_t = 3; // Outer side thickness of the bearing support
circ_below_hook = 3;
circ_above_hook = 3;
circ_above_h = 3;
circ_base_t = 8;
circ_lockring_h = 2;
circ_lockring_t = 2;

module bearing() {
  color("blue")
  difference() {
    cylinder(r=bearing_outer_r, h=bearing_h);
    translate([0, 0, -1]) cylinder(r=bearing_inner_r, h=bearing_h+2);
    cylinder(r1=bearing_inner_r+bearing_cone_l, r2=bearing_inner_r, h=bearing_cone_l);
    translate([0, 0, bearing_h-bearing_cone_l])
      cylinder(r1=bearing_inner_r, r2=bearing_inner_r+bearing_cone_l, h=bearing_cone_l);
    difference() {
      cylinder(r=bearing_outer_r, h=bearing_cone_l);
      cylinder(r1=bearing_outer_r-bearing_cone_l, r2=bearing_outer_r, h=bearing_cone_l);
    }
    translate([0, 0, bearing_h-bearing_cone_l])
      difference() {
        cylinder(r=bearing_outer_r, h=bearing_cone_l);
        cylinder(r1=bearing_outer_r, r2=bearing_outer_r-bearing_cone_l, h=bearing_cone_l);
      }
  }
}

/* Flex and circ flange Z=0 is at the outer surface of the flange, with positive Z towards
   the flange. */

module flex_flange() {
    cylinder(r=flex_flange_r, h=flex_flange_h);
}

module circ_flange() {
    cylinder(r=circ_flange_r, h=circ_flange_h);
}

difference() {
  union() {
    bearing();
    translate([0, 0, -flex_flange_h-flex_flange_sep])
      flex_flange();
    translate([0, 0, bearing_h+circ_flange_sep+circ_flange_h])
      mirror([0, 0, -1]) circ_flange();
  }
  translate([0, 0, -50]) cube([100, 100, 100]);
}
