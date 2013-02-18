include <common.scad>;

module frame_top() {
  difference() {
    union() {
      translate([-arm_spacing/2, -z_end_top_thickness/2, 0])
        cube([arm_spacing, z_end_top_length, z_end_top_height]);
    }
    translate([-arm_spacing/2 + z_end_top_thickness, 
               z_end_top_thickness/2, z_end_top_thickness])
      cube([arm_spacing - z_end_top_thickness * 2, z_end_top_length, 
	    z_end_top_height]);
    translate([arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([-arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
    mirror([1, 0, 0])
      translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
    // NEMA17 screw holes
    translate([0, z_end_rod_offset - carr_rod_offset + carr_drive_offset, 0]) {
      for (i = [45 : 90 : 315]) {
	rotate(i, [0, 0, 1])
	  translate([0, 21.8, 0])
	  union() {
	  cylinder(r = 1.5, h = z_end_top_thickness, $fn=8);
	  translate([0, 0, z_end_top_thickness - 1.5])
	    cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
	}
	cylinder(r = 12, h = z_end_top_thickness); // NEMA17 central hole
      }
    }
  }
        /* Vertical truss. */
        translate([-arm_spacing/2, -frame_back_depth, 0]) {
          pyramid_box_truss(frame_back_width, frame_back_depth,
                                       frame_top_height,
                                       2, 1, 4, frame_top_truss_z_thickness, 
                                       frame_top_truss_xy_thickness,
                                       frame_top_truss_k_thickness,
                                       frame_back_truss_bar_diameter, true, true, 10);
          box_bolt_pattern_upper(frame_back_width, frame_back_depth, frame_top_height, 
                                 frame_top_truss_xy_thickness, 5, 2, 4, 6, 0.3);
  }
}

frame_top();
