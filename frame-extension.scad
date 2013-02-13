include <common.scad>;
	
/* module pyramid_box_truss(x, y, z, a, b, c, d, e, f) {
  cube([x, y, z]);
} */

module frame_extension() {
  pyramid_box_truss(frame_back_width, frame_back_depth,
                                       frame_extend_height,
                                       2, 1, 4, frame_extend_truss_z_thickness, 
                                       frame_extend_truss_xy_thickness,
                                       frame_extend_truss_k_thickness,
                                       frame_extend_truss_bar_diameter, true, true, 10);
          box_bolt_pattern_upper(frame_back_width, frame_back_depth, frame_extend_height, 5,
                                 frame_extend_truss_xy_thickness, 2, 4, 6, 0.3);
          box_bolt_pattern_lower(frame_back_width, frame_back_depth, 5,
                                 frame_extend_truss_xy_thickness, 2, 6);
}

frame_extension();
