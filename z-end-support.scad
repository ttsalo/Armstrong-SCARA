include <common.scad>;

module z_end_support() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_bottom_length, z_end_bottom_height]);
    }
    translate([-arm_spacing/2 + z_end_bottom_thickness, 
               z_end_bottom_thickness, z_end_bottom_thickness])
      cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, 
	    z_end_bottom_height]);
    translate([18, 24, 0]) cylinder(r=4, h=20);
    translate([-18, 24, 0]) cylinder(r=4, h=20);
    translate([0, 10, -4]) rotate([90, 0, 0]) {
      translate([18, 24, 0]) cylinder(r=4, h=20);
      translate([-18, 24, 0]) cylinder(r=4, h=20);
    }
  }
}

z_end_support();

