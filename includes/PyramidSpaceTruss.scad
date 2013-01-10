/* Pyramid Space Truss by Tomi T. Salo <ttsalo@iki.fi> 2012 */

/* Box truss. */


module multi_pyramid_cube_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                                slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                                bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  z_pitch = (z_size - slat_z_thickness) / z_segs;

  for (z = [ 0 : z_segs - 1 ]) {
    translate([0, 0, z * z_pitch])
      pyramid_truss(x_size, y_size, z_pitch + slat_z_thickness, 
                        x_segs, y_segs,
                        slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                        bar_diameter, bar_fn, (z % 2));
  }
  for (z = [0 : z_segs / 2 - 1]) {
  translate([bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
    truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs, x_pitch, bar_diameter, bar_fn, 1);
  translate([bar_diameter/2, y_size - bar_diameter/2, z * 2 * z_pitch])
    truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs, x_pitch, bar_diameter, bar_fn, 1);
  translate([bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
    rotate([0, 0, 90])
      truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs, y_pitch, bar_diameter, bar_fn, 0);
  translate([x_size - bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
    rotate([0, 0, 90])
      truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs, y_pitch, bar_diameter, bar_fn, 0);
  }
}

module multi_pyramid_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                              slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                              bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  z_pitch = (z_size - slat_z_thickness) / z_segs;

  for (z = [ 0 : z_segs - 1 ]) {
    translate([z * x_pitch * 0.5, z * y_pitch * 0.5, z * z_pitch])
      pyramid_truss(x_size - x_pitch * z, y_size - y_pitch * z, z_pitch + slat_z_thickness, 
                        x_segs - z, y_segs - z,
                        slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                        bar_diameter, bar_fn, 0);
  }
}

module pyramid_truss(x_size, y_size, z_size, x_segs, y_segs,
                         slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                         bar_diameter, bar_fn, flip)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;

  translate([0, 0, z_size * flip])
  mirror([0, 0, flip])
  intersection () {
    cube([x_size, y_size, z_size]);
    union () {
      truss_lattice(x_size, y_size, x_segs, y_segs, x_pitch, y_pitch,
                   slat_z_thickness, slat_xy_thickness, slat_k_thickness);
      translate([x_pitch/2, y_pitch/2, z_size - slat_z_thickness])
        truss_lattice(x_size - x_pitch, y_size - y_pitch, x_segs - 1, y_segs - 1, x_pitch, y_pitch,
                      slat_z_thickness, slat_xy_thickness, slat_k_thickness);
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

/* One truss lattice layer. */
module truss_lattice(x_size, y_size, x_segs, y_segs, x_pitch, y_pitch,
                     slat_z_thickness, slat_xy_thickness, slat_k_thickness)
  difference() {
   cube([x_size, y_size, slat_z_thickness]);
   for (x = [ 0 : x_segs - 1]) {
     for (y = [ 0 : y_segs - 1]) {
       translate([x * x_pitch + slat_xy_thickness, y * y_pitch + slat_xy_thickness, 0])
         if (slat_k_thickness > 0) {
           difference() {
             cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
             if (x % 2 == 0) {
             rotate([0, 0, -atan(x_pitch / y_pitch)])
               translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                 cube([slat_k_thickness, sqrt(x_pitch * x_pitch + y_pitch * y_pitch), slat_z_thickness]);
             } else {
             translate([0, y_pitch - slat_xy_thickness, 0])
             rotate([0, 0, -180 + atan(x_pitch / y_pitch)])
               translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                 cube([slat_k_thickness, sqrt(x_pitch * x_pitch + y_pitch * y_pitch), slat_z_thickness]);               
             }
           }
         } else {
           cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, slat_z_thickness]);
         }
      }
    }
}

/* One side lattice. Arranged with centerline along the X axis. */
module truss_side_lattice(z_size, x_segs, x_pitch, bar_diameter, bar_fn, cornerbars)
{
  /* Vertical bars */
  for (x = [(cornerbars ? 0 : 1) : (cornerbars ? x_segs : x_segs - 1)]) {
    translate([x * x_pitch, 0, 0])
      cylinder(r=bar_diameter/2, h=z_size, $fn=bar_fn);
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

//pyramid_truss(180, 100, 30, 3, 2, 3.5, 5, 5, 5, 12, 0);

//multi_pyramid_truss(180, 100, 60, 4, 4, 3, 3.5, 5, 5, 5, 12);

multi_pyramid_cube_truss(180, 100, 60, 4, 3, 2, 3.5, 5, 5, 5, 12);
