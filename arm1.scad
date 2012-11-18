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
        // Use the arm full height for the flexspline base, but cut out material
        // from the backside where it's not needed (much) (disabled, made it too weak)
        cylinder(r=circ_outer_r, h=arm1_h, $fn=60);
        /* translate([0, -circ_outer_r * 1.5, arm_flex_base_h])
          rotate([0, -15, 0])
            cube([circ_outer_r * 2, circ_outer_r * 3, arm1_h]);
        translate([-circ_outer_r * 2, -circ_outer_r * 1.5, arm_flex_base_h])
          cube([circ_outer_r * 2, circ_outer_r * 3, arm1_h]); */
      }
      translate([0, -arm_w/2, 0])
        if (use_truss == 0) { cube([length, arm_w, arm1_h]); }
        else { my_truss_platform(length, arm_w, arm1_h, truss_thickness*truss_arm1, 
                                 truss_thickness*truss_width_coeff*truss_arm1, 
                                 truss_radius); }
      translate([length, 0, 0]) cylinder(r=arm_joint1_base_r, h=arm_joint1_base_h);
    }
    translate([0, 0, arm_flex_base_bottom_h]) flexspline_gear(flex_h, -0.6, -0.6);
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

