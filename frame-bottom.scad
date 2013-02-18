include <common.scad>;
	
/* module pyramid_box_truss(x, y, z, a, b, c, d, e, f) {
  cube([x, y, z]);
} */

module frame_bottom() {
    difference() {
    union() {
      translate([-arm_spacing/2, 0, 0]) {
        /* The solid brace for the Z-rod grooves and bolt pattern. */
        translate([0, -z_end_bottom_thickness/2, 0])
        difference() {
          cube([arm_spacing, z_end_bottom_length, frame_bottom_height + 10]);
          translate([z_end_bottom_thickness, z_end_bottom_thickness, 0])
            cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, 
	              frame_bottom_height + 10]);
        }
        /* Horizontal truss. */
        pyramid_box_truss(arm_spacing, frame_bottom_length,
                                       frame_bottom_height,
                                       3, 3, 2, frame_bottom_truss_z_thickness, 
                                       frame_bottom_truss_xy_thickness,
                                       frame_bottom_truss_k_thickness,
                                       frame_bottom_truss_bar_diameter, true, true, 10);
        box_bolt_pattern_side(arm_spacing, frame_bottom_length, frame_bottom_height,
                               5, frame_back_truss_xy_thickness, 2, 6, false);
        /* Vertical truss. */
        translate([0, -frame_back_depth, 0]) {
          pyramid_box_truss(frame_back_width, frame_back_depth,
                                       frame_back_height,
                                       2, 1, 4, frame_back_truss_z_thickness, 
                                       frame_back_truss_xy_thickness,
                                       frame_back_truss_k_thickness,
                                       frame_back_truss_bar_diameter, true, true, 10);
          box_bolt_pattern_upper(frame_back_width, frame_back_depth, frame_back_height, 
                                 frame_back_truss_xy_thickness, 5, 2, 4, 6, 0.3);
          box_bolt_pattern_lower(frame_back_width, frame_back_depth + frame_bottom_length - 28, 
                                 5, frame_back_truss_xy_thickness, 2, 6);
        }       
      }
		/* Z drive rod passthrough solid */
           translate([0, z_end_rod_offset - carr_rod_offset + carr_drive_offset, 0])
             cylinder(r=12, h=frame_bottom_height);
    }
    translate([arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([-arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([arm_spacing/2 - 10, z_end_rod_offset, frame_bottom_height + 5])
      z_end_bottom_clamp_bolts();
    mirror([1, 0, 0])
      translate([arm_spacing/2 - 10, z_end_rod_offset, frame_bottom_height + 5])
      z_end_bottom_clamp_bolts();
		/* Z drive rod passthrough void */
           translate([0, z_end_rod_offset - carr_rod_offset + carr_drive_offset, 0])
             cylinder(r=12-3.4, h=frame_bottom_height);
  }
}

frame_bottom();
