include <common.scad>;

/* Joint3 type 1 is the bearing side, type 2 is the tube and groove
   they run in. */
module arm2(length, joint3_type, groovemount, use_truss) {
  difference() {
    union() {
      cylinder(r=arm_joint2_base_r, h=arm_joint2_base_h, $fn=30);
      translate([0, -arm_w/2, 0])
        if (use_truss == 1) {
	   pyramid_box_truss(length, arm_w, arm2_h, 
			     10, 3, truss_z_thickness, truss_xy_thickness,
			     truss_bar_diameter, 10);
        } else {
          cube([length, arm_w, arm2_h]); 
        }
      if (joint3_type == 1) {
        translate([length, 0, 0]) cylinder(r=arm_joint31_base_r, 
					   h=arm_joint31_base_h, $fn=30);
        translate([length, 25, 0]) cylinder(r=6, h=arm_joint31_base_h, $fn=30);
        translate([length, -25, 0]) cylinder(r=6, h=arm_joint31_base_h, $fn=30);
        translate([length-6, -25, 0]) cube([12, 50, arm_joint31_base_h]);
        translate([length, 0, 0]) 
          for (i = [90 : 120 : 360]) {
            rotate(i, [0, 0, 1])
              translate([0, arm_joint31_bearing_spacing - tol, 0])
	      union() {
	      cylinder(r = 8, h = arm_joint31_base_h);
	      translate([-8, -16, 0])
		cube([16, 16, arm_joint31_base_h]);
	    }
          }
      } else {
        translate([length, 0, 0]) 
	  cylinder(r=arm_joint32_base_r, h=arm_joint32_base_h);
        translate([length, 0, 0]) 
	  cylinder(r=arm_joint3_hollow_r + arm_joint32_tube_wt, 
		   h=arm_joint31_base_h + arm_separation 
		   - arm_joint32_tube_h_clearance, $fn=60);
        translate([length, 0, arm_joint31_base_h + arm_separation 
		   - arm_joint32_tube_h_clearance - arm_joint31_bearing_h * 2])
	  difference() { // The slew bearing groove at the top of the
			 // tube, with printability cones
          union() {
            cylinder(r = arm_joint3_hollow_r + arm_joint32_tube_wt 
		     + arm_joint32_tube_groove_depth,
                     h = arm_joint31_bearing_h * 2);
            translate([0, 0, -arm_joint32_tube_groove_depth])
	      cylinder(r1 = arm_joint3_hollow_r + arm_joint32_tube_wt,
		       r2 = arm_joint3_hollow_r + arm_joint32_tube_wt 
		       + arm_joint32_tube_groove_depth,
		       h = arm_joint32_tube_groove_depth);
          }
          translate([0, 0, arm_joint31_bearing_h / 2])
            difference() {
            cylinder(r = arm_joint3_hollow_r + arm_joint32_tube_wt 
		     + arm_joint32_tube_groove_depth,
                     h = arm_joint31_bearing_h + arm_joint32_tube_groove_depth);
            translate([0, 0, arm_joint31_bearing_h])
	      cylinder(r1 = arm_joint3_hollow_r + arm_joint32_tube_wt,
		       r2 = arm_joint3_hollow_r + arm_joint32_tube_wt 
		       + arm_joint32_tube_groove_depth,
		       h = arm_joint32_tube_groove_depth);
	  }
        }
      }
    }
    cylinder(r=arm_bolthole_r, h=arm_joint2_base_h+1, $fn=24);
    translate([length, 0, 0]) 
      if (joint3_type == 1) {
        translate([0, 0, groovemount * 4])
          cylinder(r=arm_joint3_hollow_r, h=arm_joint31_base_h + 1);
        cylinder(r=6, h=arm_joint31_base_h + 1);
        if (groovemount == 1) {
          translate([0, -6, 0])
            cube([arm_joint31_base_r * 2, 12, arm_joint31_base_h]);
          translate([0, -9, 4])
            cube([arm_joint31_base_r * 2, 18, arm_joint31_base_h]);
        }
        for (i = [90 : 120 : 360]) {
          rotate(i, [0, 0, 1])
            translate([0, arm_joint31_bearing_spacing - tol, 0])
	    union() {
	    cylinder(r = 2, h = arm_joint31_base_h, $fn=8); 
	    translate([0, 0, arm_joint31_base_h - 4])
	      cylinder(r = 4, h = 5, $fn=16);
	  }
          translate([0, 25, 0]) cylinder(r=2, h=arm_joint31_base_h, $fn=8);
          translate([0, -25, 0]) cylinder(r=2, h=arm_joint31_base_h, $fn=8);
        } 
      } else {
        cylinder(r=arm_joint3_hollow_r, h=arm_joint31_base_h + arm_separation);
      }
  }
}

