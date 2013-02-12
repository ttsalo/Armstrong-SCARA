include <configuration.scad>;
use <includes/parametric_involute_gear_v5.0.scad>;
use <includes/PyramidSpaceTruss.scad>;
include <includes/lm8uu-holder-slim_double-vertical.scad>;

// Generic spline gear with a herringbone section
module spline_helix_gear(number_of_teeth, circular_pitch, pressure_angle,
                   height, helix_height, twist, backlash, clearance) {
  gear(number_of_teeth=number_of_teeth,
       circular_pitch=circular_pitch,
       pressure_angle=pressure_angle,
       clearance = clearance,
       gear_thickness = height - helix_height,
       rim_thickness = height - helix_height,
       rim_width = 5,
       hub_thickness = height - helix_height,
       hub_diameter=0,
       bore_diameter=0,
       circles=0,
       backlash=backlash,
       twist=0);
  translate([0, 0, height - helix_height])
    gear(number_of_teeth=number_of_teeth,
	 circular_pitch=circular_pitch,
	 pressure_angle=pressure_angle,
	 clearance = clearance,
	 gear_thickness = helix_height/2,
	 rim_thickness = helix_height/2,
	 rim_width = 5,
	 hub_thickness = helix_height/2,
	 hub_diameter=0,
         bore_diameter=0,
	 circles=0,
         backlash=backlash,
	 twist=twist);
  rotate([0, 0, -twist])
    translate([0, 0, height - helix_height/2])
    gear(number_of_teeth=number_of_teeth,
	 circular_pitch=circular_pitch,
	 pressure_angle=pressure_angle,
	 clearance = clearance,
	 gear_thickness = helix_height/2,
	 rim_thickness = helix_height/2,
	 rim_width = 5,
	 hub_thickness = helix_height/2,
	 hub_diameter=0,
         bore_diameter=0,
	 circles=0,
         backlash=backlash,
	 twist=-twist);
}

// Simplified module for creating flexsplines (with helix section)
module flexspline_helix_gear(height, backlash, clearance) {
  spline_helix_gear(number_of_teeth=flex_teeth,
		    circular_pitch=pitch,
		    pressure_angle=press_angle,
		    height=height,
		    helix_height=tooth_overlap,
		    backlash=backlash,
		    clearance = clearance,
		    twist=-helix_twist);
}

// Simplified module for creating flexsplines (without helix section)
module flexspline_gear(height, backlash, clearance) {
  gear(number_of_teeth=flex_teeth,
       circular_pitch=pitch,
       pressure_angle=press_angle,
       clearance = clearance,
       gear_thickness = height,
       rim_thickness = height,
       rim_width = 5,
       hub_thickness = height,
       hub_diameter=0,
       bore_diameter=0,
       circles=0,
       backlash=backlash,
       twist=0 //,
       //involute_facets=3
       );
}

module z_end_bottom_clamp_bolts() {
  translate([0, -7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);
  translate([0, 7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);  
}

module circspline_mount(extra=0) {
  translate([0, circ_mount_r, 0]) cylinder(r=8+extra, h=circ_mount_h, $fn=16);
  translate([-8-extra, 0, 0]) cube([16+extra*2, circ_mount_r, circ_mount_h]);
}

module circspline_mount_void() {
  translate([0, circ_mount_r, 0]) cylinder(r=2, h=circ_mount_h, $fn=16);
}
