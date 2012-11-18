include <common.scad>;

module z_end_bottom() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_bottom_length, z_end_bottom_height]);
    }
    translate([-arm_spacing/2 + z_end_bottom_thickness, 
               z_end_bottom_thickness, z_end_bottom_thickness])
      cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, 
	    z_end_bottom_height]);
    translate([arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([-arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
    mirror([1, 0, 0])
      translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
    translate([18, 24, 0]) cylinder(r=4, h=20);
    translate([-18, 24, 0]) cylinder(r=4, h=20);
    translate([0, 10, -4]) rotate([90, 0, 0]) {
      translate([18, 24, 0]) cylinder(r=4, h=20);
      translate([-18, 24, 0]) cylinder(r=4, h=20);
    }
  }
}

z_end_bottom();
