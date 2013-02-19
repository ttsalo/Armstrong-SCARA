include <common.scad>;
	
/* module pyramid_box_truss(x, y, z, a, b, c, d, e, f) {
  cube([x, y, z]);
} */

fr_unit = arm_spacing/2;

/* Hardcoded for the bed mounting and other parameters */
module frame_bed_truss_piece(width, length) {
  pyramid_box_truss(fr_unit*width, fr_unit*length,
                    frame_bottom_height,
                    width, length, 2, frame_bottom_truss_z_thickness, 
                    frame_bottom_truss_xy_thickness,
                    frame_bottom_truss_k_thickness,
                    frame_bottom_truss_bar_diameter, true, true, 10);
}

/* The part of frame that attaches to the main bottom piece and has the
   print bed attachment points. */
module frame_bed() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        box_bolt_pattern_side(arm_spacing, frame_bottom_length, frame_bottom_height,
                              5, frame_back_truss_xy_thickness, 2, 6, true);
      translate([-arm_spacing/2, 0, 0])
        box_bolt_pattern_side(arm_spacing, fr_unit*2, frame_bottom_height,
                              5, frame_back_truss_xy_thickness, 2, 6, false);
      for (v = bed_bolts) {
        translate([-print_xmax/2, print_ymin_frame_offset-frame_bottom_length, 0])
          translate(v)
            cylinder(r=bed_bolt_r*2, h=frame_bottom_height);
      }
    translate([-fr_unit, 0, 0]) frame_bed_truss_piece(2, 2);
    
    //translate([-fr_unit/2, fr_unit, 0]) frame_bed_truss_piece(1, 3);
    }
    for (v = bed_bolts) {
      translate([-print_xmax/2, print_ymin_frame_offset-frame_bottom_length, 0])
        translate(v)
          cylinder(r=bed_bolt_r, h=frame_bottom_height);
    }
  }
}

frame_bed();
