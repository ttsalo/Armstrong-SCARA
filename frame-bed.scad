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

/* Extension piece to keep the main bed adapter's size reasonable. */
module frame_bed_extend() {
      translate([-arm_spacing/2, 0, 0])
        box_bolt_pattern_side(arm_spacing, frame_bottom_length, frame_bottom_height,
                              4.5, frame_back_truss_xy_thickness, 2, 6, true);
      translate([-arm_spacing/2, 0, 0])
        box_bolt_pattern_side(arm_spacing, fr_unit*2, frame_bottom_height,
                              4.5, frame_back_truss_xy_thickness, 2, 6, false);
    translate([-fr_unit, 0, 0]) frame_bed_truss_piece(2, 2);
    
}

/* Frame to bed adapter. */
module frame_bed() {
    difference() {
    union() {
      translate([-arm_spacing/2, fr_unit*2, 0]) {
        box_bolt_pattern_side(arm_spacing, frame_bottom_length, frame_bottom_height,
                              3.4, frame_back_truss_xy_thickness, 2, 6, true);
        cube([arm_spacing, 3.4, frame_bottom_height/2]);
        
      }
      translate([-10, fr_unit*2, 0]) cube([20, 143, 5]);
      for (v = bed_bolts) {
        translate([-print_xmax/2, print_ymin_frame_offset-frame_bottom_length, 0])
          translate(v)
            cylinder(r=bed_bolt_r*2, h=frame_bottom_height);
        if (v[0] < print_xmax/2) {
          translate([-(print_xmax/2 - v[0]), 
              v[1] + (print_ymin_frame_offset-frame_bottom_length) - 4, 0])
            cube([print_xmax/2 - v[0], 8, 5]);
        } else {
          translate([0, v[1] + (print_ymin_frame_offset-frame_bottom_length) - 4, 0])
            cube([v[0] - print_xmax/2, 8, 5]);
        }
      }
    }
    for (v = bed_bolts) {
      translate([-print_xmax/2, print_ymin_frame_offset-frame_bottom_length, 0])
        translate(v)
          cylinder(r=bed_bolt_r, h=frame_bottom_height);
    }
  }
}

frame_bed_extend();
//frame_bed();