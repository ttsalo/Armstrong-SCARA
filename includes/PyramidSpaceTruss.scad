/* Pyramid Space Truss by Tomi T. Salo <ttsalo@iki.fi> 2012 */

/* Regular rectangular truss composed of pyramid layers with
   alternating orientation.

   x_size, y_size, z_size: the total size of the structure

   x_segs, y_segs, z_segs: the number of segments in each dimension
     z_segs should be divisible by two. If z_segs is 1, falls back to
     basic pyramid truss without the side lattices.

   slat_z_thickness: the vertical thickness of the rectangular bars

   slat_xy_thickness: the horizontal thickness of the rectangular bars

   bar_diameter: the diameter of the vertical and slanted round bars

   crossbars1, crossbars2: each 0 or 1 depending on if crossbars are
     wanted at the sides

   bar_fn: used as the $fn parameter for the round bars
   */
module 
pyramid_box_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                         slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                         bar_diameter, crossbars1, crossbars2, bar_fn)
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
  if (z_segs > 1) {
  intersection () {
    cube([x_size, y_size, z_size]);

    for (z = [0 : z_segs / 2 - 1]) {
	  /* The side lattice sections will use a slightly different pitch
         than the main truss
         if the bar diameter differs from the XY slat thickness. This is
         necessary to get the bars positioned correctly in the corners
         of the box structure. */
      translate([bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
        truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                           (x_size - bar_diameter) / x_segs, 
                           bar_diameter, bar_fn, 1, crossbars1, crossbars2);
      translate([bar_diameter/2, y_size - bar_diameter/2, z * 2 * z_pitch])
        truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                           (x_size - bar_diameter) / x_segs, 
                           bar_diameter, bar_fn, 1, crossbars1, crossbars2);
      translate([bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
        rotate([0, 0, 90])
        truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                          (y_size - bar_diameter) / y_segs, 
                           bar_diameter, bar_fn, 0, crossbars1, crossbars2);
      translate([x_size - bar_diameter/2, bar_diameter/2, z * 2 * z_pitch])
        rotate([0, 0, 90])
        truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                          (y_size - bar_diameter) / y_segs, 
                           bar_diameter, bar_fn, 0, crossbars1, crossbars2);
    }
  }
  }
}

/* Multi-layer pyramid truss. Same as pyramid_truss but has several
   sections stacked on each other, with sections becoming one segment
   smaller each step up. */
module multi_pyramid_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                           slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                           bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  z_pitch = (z_size - slat_z_thickness) / z_segs;
  
  for (z = [ 0 : z_segs - 1 ]) {
    translate([z * x_pitch * 0.5, z * y_pitch * 0.5, z * z_pitch])
      pyramid_truss(x_size - x_pitch * z, y_size - y_pitch * z, 
                    z_pitch + slat_z_thickness, 
                    x_segs - z, y_segs - z,
                    slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                    bar_diameter, bar_fn, 0);
  }
}

/* One layer pyramid truss. Made from x_segs*y_segs pyramid sections
   with a lattice on the top and the bottom (top lattice being one
   section smaller than the bottom one) */
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
            truss_lattice(x_size - x_pitch, y_size - y_pitch, x_segs - 1, 
                          y_segs - 1, x_pitch, y_pitch,
                          slat_z_thickness, slat_xy_thickness, slat_k_thickness);
          translate([slat_xy_thickness/2, slat_xy_thickness/2, 
                     slat_z_thickness/2])
            for (x = [ 0 : x_segs - 1]) {
              for (y = [ 0 : y_segs - 1]) {
                translate([x * x_pitch, y * y_pitch, 0])
                  pyramid(x_pitch, y_pitch, z_size - slat_z_thickness, 
                          bar_diameter, bar_fn);
              }
            }
        }
     }
}

/* One truss lattice layer. Horizontal rectangular grid, with given Z
   and XY slat dimensions and optionally diagonal cross slats if the K
   thickness is more than 0. */
module truss_lattice(x_size, y_size, x_segs, y_segs, x_pitch, y_pitch,
                     slat_z_thickness, slat_xy_thickness, slat_k_thickness)
  difference() {
    cube([x_size, y_size, slat_z_thickness]);
    for (x = [ 0 : x_segs - 1]) {
      for (y = [ 0 : y_segs - 1]) {
        translate([x * x_pitch + slat_xy_thickness, 
                   y * y_pitch + slat_xy_thickness, 0])
          if (slat_k_thickness > 0) {
            difference() {
              cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, 
                    slat_z_thickness]);
              if (x % 2 == 0) {
                rotate([0, 0, -atan(x_pitch / y_pitch)])
                  translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                    cube([slat_k_thickness, sqrt(x_pitch * x_pitch + y_pitch *
                                                 y_pitch), slat_z_thickness]);
              } else {
                translate([0, y_pitch - slat_xy_thickness, 0])
                  rotate([0, 0, -180 + atan(x_pitch / y_pitch)])
                    translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                      cube([slat_k_thickness, sqrt(x_pitch * x_pitch + 
                                                   y_pitch * y_pitch), 
                            slat_z_thickness]);               
              }
            }
          } else {
            cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, 
                  slat_z_thickness]);
          }
    }
  }
}

/* Side lattice. Arranged with centerline along the X axis. Optionally
   can include of omit the corner bars (used when creating all four
   sides to avoid doubling the corner bars).  Also can optionally
   create one or two diagonal crossbars between each section. */
module truss_side_lattice(z_size, x_segs, x_pitch, bar_diameter, bar_fn, 
                          cornerbars, crossbars1=0, crossbars2=0)
{
  /* Vertical bars */
  for (x = [(cornerbars ? 0 : 1) : (cornerbars ? x_segs : x_segs - 1)]) {
    translate([x * x_pitch, 0, 0])
      pyramid_cylinder(r=bar_diameter/2, h=z_size, $fn=bar_fn);
  }
  /* Slanted crossbars */
  if (crossbars1)
    for (x = [0 : x_segs - 1]) {
      translate([x * x_pitch, 0, 0])
        rotate([0, atan2(x_pitch, z_size), 0])
          pyramid_cylinder(r=bar_diameter/2, h=sqrt(x_pitch * x_pitch + 
                                                    z_size * z_size), 
                           $fn=bar_fn);
    }  
  if (crossbars2)
    for (x = [1 : x_segs]) {
      translate([x * x_pitch, 0, 0])
        rotate([0, -atan2(x_pitch, z_size), 0])
        pyramid_cylinder(r=bar_diameter/2, h=sqrt(x_pitch * x_pitch + 
                                                  z_size * z_size), $fn=bar_fn);
    }
}

/* One pyramid section. The xyz measurements are between the truss
   vertex centerpoints, so in use this should be translated to the
   desired vertex center. */
module pyramid(x_pitch, y_pitch, z_pitch, bar_diameter, bar_fn)
{
  /* The length of the projection of the slanted bar in XY-plane */
  bar_xy = sqrt(pow(x_pitch/2, 2) + pow(y_pitch/2, 2));

  /* The 3D length of the slanted bar */
  bar = sqrt(pow(bar_xy, 2) + pow(z_pitch, 2));
  
  z_rot = asin((y_pitch/2) / bar_xy);
  xy_rot = acos(z_pitch / bar);
  rotate([0, xy_rot, z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, 0, 0]) rotate([0, xy_rot, 180-z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, y_pitch, 0]) rotate([0, xy_rot, 180+z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([0, y_pitch, 0]) rotate([0, xy_rot, -z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
}

/* Variation of a basic cylinder with conical widening ends. */
module pyramid_cylinder(r=0, h=0, $fn=12)
{
  ch = r/h * 4; // Autocalculate the cone section length for the joints to work
  cylinder(r=r, h=h, $fn=$fn);
  cylinder(r1=r*2, r2=r, h=h*ch, $fn=$fn);
  translate([0, 0, h*(1-ch)])
    cylinder(r1=r, r2=r*2, h=h*ch, $fn=$fn);
}

module box_bolt_pattern_lower(x, y, thickness, truss_xy_thickness, hole_r, clearance_r) {
  box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, false);
  translate([x, 0, 0])
    mirror([1, 0, 0])
      box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, false);
    cube([truss_xy_thickness, y, thickness]);
  translate([x-truss_xy_thickness, 0, 0])
    cube([truss_xy_thickness, y, thickness]);

}

module box_bolt_pattern_upper(x, y, z, thickness, truss_xy_thickness,
                              hole_r, hex_r, clearance_r) {
  translate([0, 0, z - thickness]) {
    box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, true);
    translate([x, 0, 0])
      mirror([1, 0, 0])
        box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, true);
  }
  translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
    intersection() {
      cube([truss_xy_thickness, y, clearance_r*2+thickness+truss_xy_thickness]);
      translate([truss_xy_thickness/2, 0, 0])
        rotate([0, -45, 0])
          cube([clearance_r*3, y, clearance_r*3]);
    }
  translate([x, 0, 0])
  mirror([1, 0, 0])
  translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
    intersection() {
      cube([truss_xy_thickness, y, clearance_r*2+thickness+truss_xy_thickness]);
      translate([truss_xy_thickness/2, 0, 0])
        rotate([0, -45, 0])
          cube([clearance_r*3, y, clearance_r*3]);
    }
}

module box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, supported) {
  for (offset = [0 , y - 2*clearance_r]) {
    intersection () {
      union () {
        translate([-clearance_r, clearance_r+offset, 0])
          difference() {
            union () {
              translate([0, 0, -clearance_r*3])
                cylinder(r=clearance_r, h=thickness+clearance_r*3);
              translate([0, -clearance_r, -clearance_r*3])
                cube([clearance_r, clearance_r*2, thickness+clearance_r*3]);
            }
            cylinder(r=hole_r, h=thickness);
          }        
      }
      union () {
        if (supported) {
          difference() {
            translate([0, clearance_r+offset, -clearance_r*2])
              cylinder(r1=0, r2=clearance_r*3, h=clearance_r*3);
            translate([-clearance_r, clearance_r+offset, -clearance_r*2])
              cylinder(r=hex_r, h=clearance_r*2, $fn=6);
          }
        }
        translate([0, clearance_r+offset, 0])
          cylinder(r=clearance_r*3, h=clearance_r*3);
      }
    }
  }
}

//pyramid_truss(180, 100, 30, 3, 2, 3.5, 5, 5, 5, 12, 0);
//multi_pyramid_truss(180, 100, 60, 4, 4, 3, 3.5, 5, 5, 5, 12);
//multi_pyramid_cube_truss(180, 100, 60, 4, 3, 2, 3.5, 5, 5, 5, 12);
tw = 0.55; // track width for testing
//pyramid_box_truss(70, 70, 70, 2, 2, 2, tw*6, tw*6, tw*6, tw*6, 1, 1, 12);
//pyramid_box_truss(70, 70, 30, 3, 4, 2, tw*6, tw*6, tw*6, tw*2, 1, 1, 12);