include <common.scad>;

module circspline_carr_mount() {
  translate([0, circ_mount_r, drive_h-8-8]) difference() { 
    intersection() {
      translate([0, 0, -circ_mount_h]) cylinder(r=8, h=circ_mount_h*2, $fn=16);
      translate([0, -12, -16])
        cylinder(r1=0, r2=30, h=24);
    }
    cylinder(r=2, h=circ_mount_h, $fn=16);
  }
}

module circspline_carr_mount_void() {
  translate([0, circ_mount_r, -circ_mount_h+drive_h-8-8])
    cylinder(r=4, h=circ_mount_h-lh, $fn=6);    
}

module arm_mount() {
  translate([0, 0, -carr_floor-carr_truss_depth])
    cylinder(r=4+carr_wt, h=carr_floor+carr_truss_depth);
  translate([0, 0, -carr_floor]) 
    cylinder(r=circ_outer_r+1+carr_wt, h=drive_h+carr_floor-8);
}

module arm_mount_2() {
  rotate([0, 0, -circ_mount_1]) circspline_carr_mount();
  rotate([0, 0, -circ_mount_2]) circspline_carr_mount();
  rotate([0, 0, -circ_mount_3]) circspline_carr_mount();
}

module arm_mount_void() {
  cylinder(r=bearing_r + 1, h=bearing_h + washer_h);
  difference() {
    translate([0, 0, -carr_floor]) {
      rotate([0, 0, 20]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt, 
			       drive_h+carr_floor]);
      rotate([0, 0, 90]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt, 
			       drive_h+carr_floor]);
      rotate([0, 0, 165]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt,
				drive_h+carr_floor]);
    }
    translate([0, 0, -carr_floor])
      cylinder(r=bearing_r + 2, h=carr_floor);
    /* translate([circ_outer_r/2, -circ_outer_r/2, -circ_outer_r])
       cylinder(r1=0, r2=circ_outer_r*2, h=circ_outer_r*3); */
    translate([-circ_outer_r*0.5, -circ_outer_r*2.72, 0]) 
      rotate([0, 0, -45]) rotate([0, -58, 0])
      cube([circ_outer_r*4, circ_outer_r*4, circ_outer_r*4]);      
  }
  translate([circ_outer_r*1+8, circ_outer_r*1+8, 0]) rotate([0, 0, -45])
    cube([circ_outer_r*4, circ_outer_r*4, circ_outer_r*4]);      
}

module arm_mount_void_2() {
  translate([0, 0, -carr_truss_depth-carr_floor-0.5])
    cylinder(r=4, h=carr_truss_depth+carr_floor+1);
  cylinder(r=circ_outer_r+1, h=drive_h+1);
  translate([0, 0, bearing_h+washer_h+arm_flex_base_bottom_h+assy_h]) 
  rotate([0, 180, 0]) {
    rotate([0, 0, circ_mount_1]) circspline_mount(extra=1);
    rotate([0, 0, circ_mount_2]) circspline_mount(extra=1);
    rotate([0, 0, circ_mount_3]) circspline_mount(extra=1);
  }
  rotate([0, 0, -circ_mount_1]) circspline_carr_mount_void();
  rotate([0, 0, -circ_mount_2]) circspline_carr_mount_void();
  rotate([0, 0, -circ_mount_3]) circspline_carr_mount_void();
}

module carriage(use_truss) {
  difference() {
    union() {
      difference() {
        union() {
          translate([-arm_spacing/2, 0, 0])
            arm_mount();
          translate([arm_spacing/2, 0, 0])
            mirror([-1, 0, 0]) arm_mount();
          translate([-carr_truss_width/2, bearing_r + 2 - carr_truss_length, 
		     -carr_floor])
            rotate([180, 0, 90])
	    if (use_truss) {
	      my_truss_platform(carr_truss_length, carr_truss_width, 
				carr_truss_depth, truss_thickness, 
				truss_thickness*truss_width_coeff, 
				truss_radius);
	    } else {
	      cube([carr_truss_length, carr_truss_width, carr_truss_depth]);
	    }              
          translate([0, carr_drive_offset, -carr_floor-carr_truss_depth]) 
            cylinder(r=4 + carr_wt, h=carr_floor + carr_truss_depth);
          translate([0, carr_drive_offset, -carr_floor-carr_truss_depth]) 
            cylinder(r=15/2 + carr_wt, h=6.8+carr_wt, $fn=6);
          translate([-carr_top_support_width/2, -carr_top_support_length/2, 
                     bearing_h+washer_h+arm_flex_base_bottom_h+assy_h
                     -carr_top_support_thickness-circ_mount_h])
            cube([carr_top_support_width, carr_top_support_length, 
		  carr_top_support_thickness]);
        }
        translate([-arm_spacing/2, 0, 0])
          arm_mount_void();
        translate([arm_spacing/2, 0, 0])
          mirror([-1, 0, 0]) arm_mount_void();
      }
      translate([0, -(circ_outer_r + 1 + carr_wt) / 2, -carr_floor/2])
        cube([arm_spacing + bearing_r * 2 + 4, circ_outer_r + carr_wt + 1, 
	      carr_floor], center=true);
      translate([0, 0, -carr_floor/2])
        cube([arm_spacing + bearing_r * 2 + 4, (bearing_r + 2) * 2, 
	      carr_floor], center=true);
      translate([-arm_spacing/2, 0, 0])
        arm_mount_2();
      translate([arm_spacing/2, 0, 0])
        mirror([-1, 0, 0]) arm_mount_2();
      translate([-arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth])
        rotate([0, 0, 180]) mirror([-1, 0, 0]) 
	lm8uu_holder_slim_double_vertical();
      translate([arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth])
        rotate([0, 0, 180]) lm8uu_holder_slim_double_vertical();
    }
    translate([-arm_spacing/2, 0, 0])
      arm_mount_void_2();
    translate([arm_spacing/2, 0, 0])
      mirror([-1, 0, 0]) arm_mount_void_2();
    translate([-arm_spacing/2, carr_rod_offset, 
	       -carr_floor-carr_truss_depth-1]) cylinder(r=15.4/2, h=200);
    translate([arm_spacing/2, carr_rod_offset, 
	       -carr_floor-carr_truss_depth-1]) cylinder(r=15.4/2, h=200);
    translate([0, carr_drive_offset, -carr_floor-carr_truss_depth+6.8]) 
      cylinder(r=4+tol, h=carr_floor + carr_truss_depth+2);
    translate([0, carr_drive_offset, -carr_floor-carr_truss_depth-1]) 
      cylinder(r=15/2, h=6.8-lh+1, $fn=6);
  }
  // translate([0, carr_drive_offset, 0]) 
  //   color("blue") cylinder(r=4, h=100); // drive rod
}

carriage(1);
