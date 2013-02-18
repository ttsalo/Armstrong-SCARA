include <common.scad>;
	
/* module pyramid_box_truss(x, y, z, a, b, c, d, e, f) {
  cube([x, y, z]);
} */

module frame_extension_double_horizontal() {
  pyramid_box_truss(frame_back_width, frame_extend_height*2, frame_back_depth,
                                       2, 4, 2, frame_extend_truss_z_thickness, 
                                       frame_extend_truss_xy_thickness,
                                       frame_extend_truss_k_thickness,
                                       frame_extend_truss_bar_diameter, 
                                       frame_extend_truss_vert_thickness, true, true, 10);
          box_bolt_pattern_side(frame_back_width, frame_extend_height*2, frame_back_depth, 4.5,
                                 frame_extend_truss_vert_thickness, 2, 6, false);
          box_bolt_pattern_side(frame_back_width, frame_extend_height*2, frame_back_depth, 4.5,
                                 frame_extend_truss_vert_thickness, 2, 6, true);
}

frame_extension_double_horizontal();
