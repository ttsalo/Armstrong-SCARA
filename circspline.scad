include <configuration.scad>;
include <common.scad>;

module circspline_helix() {
  difference() {
    cylinder(r=circ_outer_r, h=circ_h, $fn=60);
    spline_gear(number_of_teeth=flex_teeth + teeth_diff,
	     circular_pitch=pitch,
	     pressure_angle=press_angle,
	     height=circ_h,
         helix_height=tooth_overlap,
         backlash=-0.2,
         clearance = circ_tooth_clearance,
	     twist=helix_twist);
  }
}

module circspline() {
  difference() {
    cylinder(r=circ_outer_r, h=circ_h, $fn=60);
    gear(number_of_teeth=flex_teeth + teeth_diff,
	     circular_pitch=pitch,
	     pressure_angle=press_angle,
	     clearance = circ_tooth_clearance,
	     gear_thickness = circ_h,
   	     rim_thickness = circ_h,
	     rim_width = 5,
	     hub_thickness = circ_h,
	     hub_diameter=0,
         bore_diameter=0,
	     circles=0,
         backlash=-0.2,
	     twist=0);
  }
}

module circspline_block() {
  difference() {
    union() {
      circspline();
      cylinder(r=circ_outer_r, h=circ_bottom_h, $fn=60);
      if (demo_mount) {
        difference() {
          translate([-demo_mount/2, -demo_mount/2, 0])
            cube([demo_mount, demo_rod2 + demo_mount, demo_mount]);
          cylinder(r=circ_outer_r-0.1, h=circ_h, $fn=60);
          translate([0, demo_rod1, 0]) cylinder(r=4, h=circ_h, $fn=20);
          translate([0, demo_rod2, 0]) cylinder(r=4, h=circ_h, $fn=20);
          translate([-demo_mount/2-1, demo_rodh, demo_mount/2]) 
            rotate([0, 90, 0]) cylinder(r=4, h=circ_h, $fn=20);
        }
      }
    }
    // NEMA17 screw holes
    for (i = [45 : 90 : 315]) {
      rotate(i, [0, 0, 1])
      translate([0, 21.8, 0])
      union() {
        cylinder(r = 1.5, h = circ_bottom_h, $fn=8);
        translate([0, 0, circ_bottom_h - 1.5])
          cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
      }
    }
    cylinder(r = 12, h = circ_bottom_h); // NEMA17 central hole
  }
}

// Circspline that mounts to the carriage.
module circspline_unit() {
  difference() {
    union() {
      circspline();
      cylinder(r=circ_outer_r, h=circ_bottom_h, $fn=60);
      difference() {
        union() {
          rotate([0, 0, circ_mount_1]) circspline_mount();
          rotate([0, 0, circ_mount_2]) circspline_mount();
          rotate([0, 0, circ_mount_3]) circspline_mount();
        }
        cylinder(r=circ_outer_r-1, h=circ_h, $fn=60);
      }
    }
    // Cut out unnecessary toothing
    translate([0, 0, circ_bottom_h])
      cylinder(r=circ_inner_r, h=circ_h-circ_bottom_h-tooth_overlap-2);
    translate([0, 0, circ_h-tooth_overlap-2])
      cylinder(r1=circ_inner_r, r2=circ_inner_r-2, h=2);
    // NEMA17 screw holes
    for (i = [45 : 90 : 315]) {
      rotate(i, [0, 0, 1])
      translate([0, 21.8, 0])
      union() {
        cylinder(r = 1.5, h = circ_bottom_h, $fn=8);
        translate([0, 0, circ_bottom_h - 1.5])
          cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
      }
    }
    // Lightening the construction. Also peepholes.
    for (i = [0 : 90 : 360]) {
      rotate(i, [0, 0, 1])
      translate([0, 21, 0])
      cylinder(r = 7, h = circ_bottom_h, $fn=24);
    }
    cylinder(r = 12, h = circ_bottom_h); // NEMA17 central hole
    rotate([0, 0, circ_mount_1]) circspline_mount_void();
    rotate([0, 0, circ_mount_2]) circspline_mount_void();
    rotate([0, 0, circ_mount_3]) circspline_mount_void();
  }
}

module circspline_unit_spline() {
  difference() {
    circspline_unit();
    cylinder(r=circ_outer_r*2, h=circ_bottom_h, $fn=60);
  }
}

module circspline_unit_motor_mount() {
  intersection() {
    circspline_unit();
    cylinder(r=circ_outer_r*2, h=circ_bottom_h, $fn=60);
  }
}

circspline_unit();
