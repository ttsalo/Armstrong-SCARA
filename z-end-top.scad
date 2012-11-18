include <common.scad>;

module z_end_top() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_top_length, z_end_bottom_height]);
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
    translate([0, 10, -4]) rotate([90, 0, 0]) {
      translate([18, 24, 0]) cylinder(r=4, h=20);
      translate([-18, 24, 0]) cylinder(r=4, h=20);
    }
    // NEMA17 screw holes
    translate([0, z_end_rod_offset - carr_rod_offset + carr_drive_offset, 0]) {
      for (i = [45 : 90 : 315]) {
	rotate(i, [0, 0, 1])
	  translate([0, 21.8, 0])
	  union() {
	  cylinder(r = 1.5, h = z_end_bottom_thickness, $fn=8);
	  translate([0, 0, z_end_bottom_thickness - 1.5])
	    cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
	}
	cylinder(r = 12, h = z_end_bottom_thickness); // NEMA17 central hole
      }
    }
  }
}

z_end_top();
