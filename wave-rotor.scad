include <common.scad>;

module wave_rotor() {
  difference() {
    intersection() {
      translate([-flex_inner_r, -driver_w/2, 0])
         cube([2*flex_inner_r, driver_w, driver_h]);
      cylinder(r=drive_bearing_spacing_r+drive_bearing_r-2, h=driver_h, $fn=60);
    }
    translate([0, 0, -driver_h/2 + (stepper_shaft_l - stepper_shaft_mid_rot) + tol])
    # difference() {
      cylinder(r=2.5+tol, h=driver_h, $fn=12);
      translate([-2.5, 2+tol, 0]) cube([5, 5, driver_h]);
      translate([2+tol, -2.5, 0]) cube([5, 5, driver_h]);
    }
    for (i = [0 : 180 : 180]) {
    rotate([0, 0, i])
    translate([drive_bearing_spacing_r, 0, -tol])
      union() {
        cylinder(r=2, h=driver_h+1, $fn=12);
        translate([0, 0, (driver_h - drive_bearing_h) / 2])
          cylinder(r=drive_bearing_r + 1, h=drive_bearing_h+tol*2, $fn=12);
      }
    }
  }
}

wave_rotor();
