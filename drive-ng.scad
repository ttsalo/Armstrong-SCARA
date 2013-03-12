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

use <includes/parametric_involute_gear_v5.0.scad>;

tol = 0.1;

/* 6012 size bearing */
bearing_inner_r = 60/2;
bearing_outer_r = 95/2;
bearing_h = 18;
bearing_cone_l = 1.25; // Length of the bearing conical section 

flange_r = 45;
flange_h = 2;

/* Flexspline side flange details. */
flex_flange_r = flange_r;
flex_flange_h = flange_h;
flex_flange_sep = 5; // Distance from bearing to flange
flex_inner_t = 2.5; // Outer side thickness of the bearing support
flex_below_hook = 3;
flex_above_hook = 2;
flex_above_h = 3;
flex_base_t = 8;
flex_lockring_h = 2;
flex_lockring_t = 2;
flex_conn_w = 5;
flex_conn_n = 6;

/* Circspline side flange details. */
circ_flange_r = flange_r;
circ_flange_cut_r = 30;
circ_flange_h = flange_h;
circ_flange_sep = 5; // Distance from bearing to flange
circ_outer_t = 3; // Outer side thickness of the bearing support
circ_below_hook = 3;
circ_above_hook = 2;
circ_above_h = 3;
circ_base_t = 8;
circ_lockring_h = 2;
circ_lockring_t = 3;
circ_conn_w = 5;
circ_conn_n = 6;

/* Flexspline details. */
flexspl_h = 36;
flexspl_tooth_h = 6;
flexspl_bottom_h = 2;
flexspl_slope_h = 6;
flexspl_inner_r = 25.3;
flexspl_outer_r = 27.3;
flexspl_wall_t = 0.81;
flexspl_extra_wall_t = 0.4;
flexspl_lip = 1.4;

/* Drive tooth profile main variables. */
press_angle = 35;
flex_teeth = 80;
teeth_diff = 2;
pitch = 120.5;

$fn=64;

echo(str("Inner clearance diameter: ", (bearing_inner_r-flex_inner_t)*2));

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
  difference() {
    cylinder(r=flex_flange_r, h=flex_flange_h);
  }
  for (i = [0 : 360/flex_conn_n : 360]) {
    intersection() {
    rotate([0, 0, i])
    translate([0, -flex_conn_w/2, -50])
      cube([bearing_outer_r, flex_conn_w, 100]);
  rotate_extrude(convexity=10)
    polygon([[bearing_inner_r-flex_inner_t, 0],
             [bearing_inner_r-flex_inner_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h-flex_lockring_h],
             [bearing_inner_r-flex_inner_t+flex_lockring_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h-flex_lockring_h],
             [bearing_inner_r-flex_inner_t+flex_lockring_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h],
             [bearing_inner_r+flex_above_hook,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h],
             [bearing_inner_r+flex_above_hook,
              flex_flange_h+flex_flange_sep+bearing_h+tol],
             [bearing_inner_r+bearing_cone_l-tol*0.7,
              flex_flange_h+flex_flange_sep+bearing_h+tol],
             [bearing_inner_r-tol,
              flex_flange_h+flex_flange_sep+bearing_h-bearing_cone_l+tol*0.7],
             [bearing_inner_r-tol,
              flex_flange_h+flex_flange_sep+bearing_cone_l-tol*0.7],
             [bearing_inner_r+bearing_cone_l-tol*0.7,
              flex_flange_h+flex_flange_sep-tol],
             [bearing_inner_r+flex_below_hook,
              flex_flange_h+flex_flange_sep-tol],
             [bearing_inner_r+flex_base_t, flex_flange_h],
             [bearing_inner_r+flex_base_t, 0],
            ]);
   }
  }
}

module circ_flange() {
  difference() {
    cylinder(r=circ_flange_r, h=circ_flange_h);
    translate([0, 0, -0.5]) cylinder(r=circ_flange_cut_r, h=flex_flange_h+1);
  }
  for (i = [0 : 360/circ_conn_n : 360]) {
    intersection() {
    rotate([0, 0, i])
    translate([0, -circ_conn_w/2, -50])
      cube([bearing_outer_r+50, circ_conn_w, 100]);
  rotate_extrude(convexity=10)
    polygon([[bearing_outer_r+circ_outer_t-circ_base_t, circ_flange_h],
             [bearing_outer_r+circ_outer_t-circ_base_t, 0],
             [bearing_outer_r+circ_outer_t, 0],
             [bearing_outer_r+circ_outer_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h-circ_lockring_h],
             [bearing_outer_r+circ_outer_t-circ_lockring_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h-circ_lockring_h],
             [bearing_outer_r+circ_outer_t-circ_lockring_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h],
             [bearing_outer_r-circ_above_hook,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h],
             [bearing_outer_r-circ_above_hook,
              circ_flange_h+circ_flange_sep+bearing_h+tol],
             [bearing_outer_r-bearing_cone_l+tol*0.7,
              circ_flange_h+circ_flange_sep+bearing_h+tol],
             [bearing_outer_r+tol,
              circ_flange_h+circ_flange_sep+bearing_h-bearing_cone_l+tol*0.7],
             [bearing_outer_r+tol,
              circ_flange_h+circ_flange_sep+bearing_cone_l-tol*0.7],
             [bearing_outer_r-bearing_cone_l+tol*0.7,
              circ_flange_h+circ_flange_sep-tol],
             [bearing_outer_r-circ_below_hook,
              circ_flange_h+circ_flange_sep-tol],
            ]);
    }
  }
}

module flex_lockring() {
  difference() {
    cylinder(r=bearing_inner_r-flex_inner_t+flex_lockring_t-tol,
             h=flex_lockring_h-tol);
    translate([0, 0, -.5]) cylinder(r=bearing_inner_r-flex_inner_t,
             h=flex_lockring_h-tol+1);
  }
}

module circ_lockring() {
  difference() {
    cylinder(r=bearing_outer_r+circ_outer_t,
             h=circ_lockring_h-tol);
    translate([0, 0, -.5]) cylinder(r=bearing_outer_r+circ_outer_t-circ_lockring_t+tol,
             h=circ_lockring_h-tol+1);
  }
}

module spline_gear(height, backlash, clearance) {
  gear(number_of_teeth=flex_teeth,
       circular_pitch=pitch,
       pressure_angle=press_angle,
       clearance = clearance,
       gear_thickness = height,
       rim_thickness = height,
       rim_width = 5,
       hub_thickness = height,
       hub_diameter=0,
       bore_diameter=0,
       circles=0,
       backlash=backlash,
       twist=0
       );
}

module flexspline() {
  difference() {
    intersection() {
      spline_gear(flexspl_h, 0.4, 0);
      union() {
        // The flexspline is made lighter by intersecting the main
        // gear shape with the union of the following shapes.
        
        // The flat area, thickness from the wall thickness parameter.
        cylinder(r=flexspl_inner_r+flexspl_wall_t, h=flexspl_h, $fn=60);
        
        // Slope from the flat area to the top teeth.
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_slope_h])
          cylinder(r1=flexspl_inner_r+flexspl_wall_t, r2=flexspl_outer_r, 
                   h=flexspl_slope_h, $fn=60);
        
        // Top tooth area
        translate([0, 0, flexspl_h-flexspl_tooth_h])
          cylinder(r=flexspl_outer_r, h=flexspl_tooth_h+1, $fn=60);
      }
    }
    
    /* The inner hollow is made by subtracting the following from the lightened gear shape */
    difference() {
      union () {
        translate([0, 0, flexspl_bottom_h])
          cylinder(r=flexspl_inner_r, 
                   h=flexspl_h - flexspl_bottom_h - flexspl_tooth_h, $fn=60);
        translate([0, 0, flexspl_h-flexspl_tooth_h])
          cylinder(r=flexspl_inner_r-flexspl_extra_wall_t, 
                   h=flexspl_tooth_h, $fn=60);
      }
      difference() {
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_lip])
          cylinder(r=flexspl_inner_r, h=flexspl_lip, $fn=60);
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_lip])
           cylinder(r1=flexspl_inner_r, r2=flexspl_inner_r-flexspl_lip, 
                    h=flexspl_lip, $fn=60);
      }
    }
    
    // Hole
    cylinder(r=5, h=5);
  }
}

module assembly() {
difference() {
  union() {
    bearing();
    translate([0, 0, -flex_flange_h-flex_flange_sep])
      flex_flange();
    translate([0, 0, bearing_h+circ_flange_sep+circ_flange_h])
      mirror([0, 0, -1]) circ_flange();
    translate([0, 0, -circ_above_h]) circ_lockring();
    translate([0, 0, bearing_h+flex_above_h-flex_lockring_h+tol]) flex_lockring();
    translate([0, 0, -flex_flange_sep]) flexspline();
  }
  translate([0, 0, -50]) cube([100, 100, 100]);
}
}

assembly();

//circ_flange();
