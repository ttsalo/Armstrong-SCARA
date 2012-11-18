include <configuration.scad>;
use <includes/parametric_involute_gear_v5.0.scad>;
use <includes/SolidReplacementTruss.scad>;
include <includes/lm8uu-holder-slim_double-vertical.scad>;

// Generic spline gear with a herringbone section
module spline_gear(number_of_teeth, circular_pitch, pressure_angle,
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
  spline_gear(number_of_teeth=flex_teeth,
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
	     twist=0);
}

// Variation of the truss_platform, does not try to make the edges
// vertical but instead leaves them slanted.
module my_truss_platform(length, width, height, thickness,
			 element_width, radius) 
{ 
  segments = 2*floor(width/height)+1; 
  seg_width = width/(segments+1);
    
  if (segments > 0)
    for(i = [1 : segments])
      {
	translate([0, (seg_width)*(i-1)+2*seg_width*(1+pow(-1,i))/2, 
		   (height)*(1+pow(-1,i))/2])
	  {
	    rotate([180*(1+pow(-1, i))/2, 0, 0])
	      isoc_truss(length, seg_width*2, height, thickness, 
			 element_width, radius);
	  }
      }
}

module z_end_bottom_clamp_bolts() {
  translate([0, -7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);
  translate([0, 7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);  
}

