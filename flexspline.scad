include <common.scad>;

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

module flexspline_helix_2() {
  difference() {
     intersection() {
       flexspline_helix_gear(flex_h, 0.4, 0);
       union() {
          translate([0, 0, 2])
            cylinder(r=flex_inner_r+20, h=arm1_h-arm_flex_base_bottom_h-2, $fn=60);
          translate([0, 0, arm1_h-arm_flex_base_bottom_h])
            cylinder(r1=flex_inner_r+flex_wt+2, r2=flex_inner_r+flex_wt, h=2, $fn=60);
          cylinder(r1=flex_inner_r+flex_wt, r2=flex_inner_r+flex_wt+2, h=2, $fn=60);
          cylinder(r=flex_inner_r+flex_wt, h=flex_h, $fn=60);
          translate([0, 0, flex_h-tooth_overlap-2])
            cylinder(r1=flex_inner_r+flex_wt, r2=flex_inner_r+flex_wt+2, h=2, $fn=60);
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
