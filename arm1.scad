include <common.scad>;

module arm1_dummy(length) {
  difference() {
    union() {
      cylinder(r=circ_outer_r, h=arm1_h, $fn=60);
      intersection() {
        cylinder(r=circ_outer_r, h=arm1_h+2, $fn=60);
        translate([0, -arm_w/2, 0])
          cube([length, arm_w, arm1_h+2]);
      }
    }
    translate([0, 0, arm_flex_base_bottom_h]) flexspline_gear(flex_h, -0.4, -0.4);
    cylinder(r=arm_large_bolthole_r, h=arm_flex_base_bottom_h + 1, $fn=24);
    
  }
}

module arm1(length, type, use_truss) {
  difference() {
    union() {
      difference() {
        cylinder(r=circ_outer_r, h=arm_flex_base_h, $fn=60);
      }
      translate([0, -arm_w/2, 0])
        if (use_truss == 0) { cube([length, arm_w, arm1_h]); }
        else { pyramid_box_truss(length, arm_w, arm1_h, 
					10, 3, truss_z_thickness, truss_xy_thickness,
					truss_bar_diameter, 1);
	}
      translate([length, 0, 0]) cylinder(r=arm_joint1_base_r, h=arm_joint1_base_h);
    }
    translate([0, 0, arm_flex_base_bottom_h]) 
      gear(number_of_teeth=flex_bottom_teeth,
	   circular_pitch=flex_bottom_pitch,
	   pressure_angle=bottom_press_angle,
	   clearance = -0.6,
	   gear_thickness = flex_h/2,
	   rim_thickness = flex_h/2,
	   rim_width = 5,
	   hub_thickness = flex_h/2,
	   hub_diameter=0,
	   bore_diameter=0,
	   circles=0,
	   backlash=-0.6,
	   twist=0);
    cylinder(r=arm_large_bolthole_r, h=arm_flex_base_bottom_h + 1, $fn=24);
    if (type == 1) {
      translate([length, 0, 0])
        cylinder(r=arm_large_bolthole_r, h=arm_joint1_base_h + 1, $fn=24);
      translate([length, 0, arm_joint1_base_h-arm_joint1_bearing_indent])
         cylinder(r=bearing_r+tol, h=arm_joint1_bearing_indent + 1);
    } else {
      translate([length, 0, arm_joint1_bearing_indent + lh])
        cylinder(r=arm_large_bolthole_r, h=arm_joint1_base_h + 1, $fn=24);
      translate([length, 0, 0])
         cylinder(r=bearing_r+tol, h=arm_joint1_bearing_indent);
    }
  }
}

