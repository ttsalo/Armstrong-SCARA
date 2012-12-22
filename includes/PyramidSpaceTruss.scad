/* Pyramid Space Truss by Tomi T. Salo <ttsalo@iki.fi> 2012 */

/* Box truss. */

module pyramid_box_truss(x_size, y_size, z_size, x_segs, y_segs,
                         slat_z_thickness, slat_xy_thickness, bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;

  intersection () {
    cube([x_size, y_size, z_size]);
    union () {
      difference() {
        cube([x_size, y_size, slat_z_thickness]);
   for (x = [ 0 : x_segs - 1]) {
     for (y = [ 0 : y_segs - 1]) {
       translate([x * x_pitch + slat_xy_thickness, y * y_pitch + slat_xy_thickness, 0])
         cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
      }
    }

      }
      difference () {
        translate([x_pitch/2, y_pitch/2, z_size - slat_z_thickness])
          cube([x_size - x_pitch, y_size - y_pitch, slat_z_thickness]);
          for (x = [ 0 : x_segs - 2]) {
     for (y = [ 0 : y_segs - 2]) {
       translate([(x+0.5) * x_pitch + slat_xy_thickness, (y+0.5) * y_pitch + slat_xy_thickness,
                  z_size - slat_z_thickness])
         cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
      }
    }

      }
      translate([slat_xy_thickness/2, slat_xy_thickness/2, slat_z_thickness/2])
        for (x = [ 0 : x_segs - 1]) {
          for (y = [ 0 : y_segs - 1]) {
            translate([x * x_pitch, y * y_pitch, 0])
              pyramid(x_pitch, y_pitch, z_size - slat_z_thickness, bar_diameter, bar_fn);
          }
        }
     }
  }
}

module pyramid_box_truss_orig(x_size, y_size, z_size, x_segs, y_segs,
                         slat_z_thickness, slat_xy_thickness, bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;

  intersection () {
    cube([x_size, y_size, z_size]);
  difference () {
    union () {
      cube([x_size, y_size, slat_z_thickness]);
      translate([x_pitch/2, y_pitch/2, z_size - slat_z_thickness])
        cube([x_size - x_pitch, y_size - y_pitch, slat_z_thickness]);

      translate([slat_xy_thickness/2, slat_xy_thickness/2, slat_z_thickness/2])
        for (x = [ 0 : x_segs - 1]) {
          for (y = [ 0 : y_segs - 1]) {
            translate([x * x_pitch, y * y_pitch, 0])
              pyramid(x_pitch, y_pitch, z_size - slat_z_thickness, bar_diameter, bar_fn);
          }
        }
     }
   for (x = [ 0 : x_segs - 1]) {
     for (y = [ 0 : y_segs - 1]) {
       translate([x * x_pitch + slat_xy_thickness, y * y_pitch + slat_xy_thickness, 0])
         cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
      }
    }
   for (x = [ 0 : x_segs - 2]) {
     for (y = [ 0 : y_segs - 2]) {
       translate([(x+0.5) * x_pitch + slat_xy_thickness, (y+0.5) * y_pitch + slat_xy_thickness,
                  z_size - slat_z_thickness])
         cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
      }
    }
  }
  }
}

/* One pyramid section. The xyz measurements are between the vertex
   centerpoints, so in use this should be translated to the desired
   vertex center. */
module pyramid(x_pitch, y_pitch, z_pitch, bar_diameter, bar_fn)
{
  /* The length of the projection of the slanted bar in XY-plane */
  bar_xy = sqrt(pow(x_pitch/2, 2) + pow(y_pitch/2, 2));

  /* The 3D length of the slanted bar */
  bar = sqrt(pow(bar_xy, 2) + pow(z_pitch, 2));
  
  z_rot = asin((y_pitch/2) / bar_xy);
  xy_rot = acos(z_pitch / bar);
  rotate([0, xy_rot, z_rot])
    cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, 0, 0]) rotate([0, xy_rot, 180-z_rot])
    cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, y_pitch, 0]) rotate([0, xy_rot, 180+z_rot])
    cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([0, y_pitch, 0]) rotate([0, xy_rot, -z_rot])
    cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
}

//pyramid_box_truss(150, 30, 12, 8, 2, 3, 4, 3, 12);
