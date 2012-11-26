include <common.scad>;

// Flexspline made from a gear by making it hollow. Has full-length teeth.
module flexspline_helix() {
  difference() {
     flexspline_helix_gear(flex_h, 0.4, 0);
     translate([0, 0, flex_bottom_h])
       cylinder(r=flex_inner_r, h=flex_h - flex_bottom_h, $fn=60);
     cylinder(r=flex_bolthole_r, h=flex_bottom_h, $fn=24);
     translate([0, 0, flex_bottom_h-flex_bearing_indent])
       cylinder(r=bearing_r, h=flex_bearing_indent);
  }
}

// Improved flexspline. More flexible.
module flexspline_helix_2() {
  difference() {
     intersection() {
       flexspline_helix_gear(flex_h, 0.4, 0); // The main gear shape.
       union() {
          // The flexspline is made lighter by intersecting the main
          // gear shape with the union of the following shapes.

	 // The bottom toothing that fits into the arm base.
	 translate([0, 0, 2])             
	   cylinder(r=flex_inner_r+20, h=flex_bottom_tooth_h, 
		    $fn=60);
	 // Slope from the bottom toothing the flat area.
	 translate([0, 0, flex_bottom_tooth_h+2])
	   cylinder(r1=flex_inner_r+flex_wt+2, r2=flex_inner_r+flex_wt, 
		    h=6, $fn=60);

	 // Bottom slope, allows easier insertion into the arm base.
	 cylinder(r1=flex_inner_r+flex_wt, r2=flex_inner_r+flex_wt+2, 
		  h=2, $fn=60); 

	 // The flat area, thickness from the wall thickness parameter.
	 cylinder(r=flex_inner_r+flex_wt, h=flex_h, $fn=60);

	 // Slope from the flat area to the top teeth.
	 translate([0, 0, flex_h-tooth_overlap-6])
	   cylinder(r1=flex_inner_r+flex_wt, r2=flex_inner_r+flex_wt+2, 
		    h=6, $fn=60);

	 // Top tooth area
	 translate([0, 0, flex_h-tooth_overlap])
	   cylinder(r=flex_inner_r+flex_wt+2, h=tooth_overlap+1, $fn=60);
       }
     }
     difference() {
       translate([0, 0, flex_bottom_h])
         cylinder(r=flex_inner_r, h=flex_h - flex_bottom_h, $fn=60);
       difference() {
         translate([0, 0, flex_h-tooth_overlap-flex_lip])
           cylinder(r=flex_inner_r, h=flex_lip, $fn=60);
        translate([0, 0, flex_h-tooth_overlap-flex_lip])
           cylinder(r1=flex_inner_r, r2=flex_inner_r-flex_lip, h=flex_lip, $fn=60);
       }
    }
     cylinder(r=flex_bolthole_r, h=flex_bottom_h, $fn=24);
     translate([0, 0, flex_bottom_h-flex_bearing_indent])
       cylinder(r=bearing_r, h=flex_bearing_indent);
  }

}

module flexspline() {
  difference() {
     flexspline_gear(flex_h, 0.4, 0);
     translate([0, 0, flex_bottom_h])
       cylinder(r=flex_inner_r, h=flex_h - flex_bottom_h, $fn=60);
     cylinder(r=flex_bolthole_r, h=flex_bottom_h, $fn=24);
     translate([0, 0, flex_bottom_h-flex_bearing_indent])
       cylinder(r=bearing_r, h=flex_bearing_indent);
  }
}

module flexspline_base() {
  difference() {
    translate([0, 0, -3]) cylinder(r=circ_outer_r, h=3+5, $fn=60);
    flexspline_gear(flex_h, -0.4, -0.4);
    translate([0, 0, -3]) cylinder(r=flex_bolthole_r, h=3, $fn=24);
  }
}

flexspline_helix_2();
