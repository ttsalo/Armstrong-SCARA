/* Pyramid Space Truss by Tomi T. Salo <ttsalo@iki.fi> 2012 */

/* Regular rectangular truss composed of pyramid layers with
   alternating orientation.

   x_size, y_size, z_size: the total size of the structure

   x_segs, y_segs, z_segs: the number of segments in each dimension.
     z_segs should be divisible by two. If z_segs is 1, falls back to
     basic pyramid truss without the side lattices.

   slat_z_thickness: the vertical thickness of the rectangular bars

   slat_xy_thickness: the horizontal thickness of the rectangular bars

   slat_k_thickness: the horizontal thickness of the diagonal rectangular bars

   bar_diameter: the diameter of the vertical and slanted round bars

   crossbars1, crossbars2: each true or false depending on if crossbars are
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
        translate([slat_xy_thickness/2, slat_xy_thickness/2, z * 2 * z_pitch])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                             x_pitch, slat_xy_thickness, bar_diameter, 
			     bar_fn, 1, crossbars1, crossbars2);
        translate([slat_xy_thickness/2, 
		   y_size - slat_xy_thickness/2, z * 2 * z_pitch])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                             x_pitch, slat_xy_thickness, bar_diameter, 
			     bar_fn, 1, crossbars1, crossbars2);
        translate([slat_xy_thickness/2, slat_xy_thickness/2, z * 2 * z_pitch])
          rotate([0, 0, 90])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                             y_pitch, slat_xy_thickness, bar_diameter, 
			     bar_fn, 0, crossbars1, crossbars2);
        translate([x_size - slat_xy_thickness/2, 
		   slat_xy_thickness/2, z * 2 * z_pitch])
          rotate([0, 0, 90])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                             y_pitch, slat_xy_thickness, bar_diameter, 
			     bar_fn, 0, crossbars1, crossbars2);
      }
    }
  }
}

/* Multi-layer pyramid truss. Same as pyramid_truss but has several
   sections stacked on each other, with sections becoming one segment
   smaller each step up. */
module multi_pyramid_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                           slat_z_thickness, slat_xy_thickness, 
                           slat_k_thickness, bar_diameter, bar_fn)
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
                          slat_z_thickness, slat_xy_thickness, 
                          slat_k_thickness);
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
module truss_side_lattice(z_size, x_segs, x_pitch, slat_xy_thickness,
                          bar_diameter, bar_fn, 
                          cornerbars, crossbars1=0, crossbars2=0)
{
  /* Vertical bars */
  if (x_segs > 1 || cornerbars == 1) {
    for (x = [(cornerbars ? 0 : 1) : (cornerbars ? x_segs : x_segs - 1)]) {
     translate([x * x_pitch - slat_xy_thickness/2, -slat_xy_thickness/2])
       cube([slat_xy_thickness, slat_xy_thickness, z_size]); 
      //translate([x * x_pitch, 0, 0])
        //pyramid_cylinder(r=bar_diameter/2, h=z_size, $fn=bar_fn);
    }
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
                                                  z_size * z_size), 
                         $fn=bar_fn);
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

/* box_bolt_pattern_side(), box_bolt_pattern_lower() and
   box_bolt_pattern_upper() can be used to add bolt mount points in
   the trusses for bolting many trusses together.

   x, y, z: Truss dimensions
   thickness: Thickness of the bolt mount plate
   truss_xy_thickness: The thickness of the truss elements, used when 
     adding some support structure inside the truss.
   hole_r: Radius of the bolt hole
   hex_r: Radius of the hex nut trap inside the support cone for the 
     upper bolt mounts 
   clearance_r: Radius of clearance around the bolt, determines the 
     size of the plate
   near: Determines whether the side bolt mounts are added near the 
     Y=0 or at the far end
*/

module box_bolt_pattern_side(x, y, z, thickness, truss_xy_thickness, 
                             hole_r, clearance_r, near) {
  intersection() {
    translate([0, near ? thickness : y, 0])
      rotate([90, 0, 0]) {
        box_one_side_bolts(x, z, thickness, hole_r, 0, clearance_r, 
                           false, true);
        translate([x, 0, 0])
          mirror([1, 0, 0])
            box_one_side_bolts(x, z, thickness, hole_r, 0, clearance_r, 
                               false, true);
        cube([truss_xy_thickness, z, thickness]);
        translate([x-truss_xy_thickness, 0, 0])
          cube([truss_xy_thickness, z, thickness]);
    }
    /* Cut out the teardrop bits from negative Z values */
    translate([-clearance_r*2, 0, 0])
      cube([x+clearance_r*4, y, z]);
  }
}

module box_bolt_pattern_lower(x, y, thickness, truss_xy_thickness, 
                              hole_r, clearance_r) {
  box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, false, false);
  translate([x, 0, 0])
    mirror([1, 0, 0])
      box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, 
                         false, false);
  cube([truss_xy_thickness, y, thickness]);
  translate([x-truss_xy_thickness, 0, 0])
    cube([truss_xy_thickness, y, thickness]);
}

module box_bolt_pattern_upper(x, y, z, thickness, truss_xy_thickness,
                              hole_r, hex_r, clearance_r, layer_height) {
  translate([0, 0, z - thickness]) {
    box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                       true, false, layer_height);
    translate([x, 0, 0])
      mirror([1, 0, 0])
        box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                           true, false, layer_height);
  }
  translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
    intersection() {
      cube([truss_xy_thickness, y, 
            clearance_r*2+thickness+truss_xy_thickness]);
      translate([truss_xy_thickness/2, 0, 0])
        rotate([0, -45, 0])
          cube([clearance_r*3, y, clearance_r*3]);
    }
  translate([x, 0, 0])
    mirror([1, 0, 0])
      translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
        intersection() {
          cube([truss_xy_thickness, y, 
                clearance_r*2+thickness+truss_xy_thickness]);
          translate([truss_xy_thickness/2, 0, 0])
            rotate([0, -45, 0])
              cube([clearance_r*3, y, clearance_r*3]);
        }
}

module box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                          supported, teardrop, layer_height=0) {
  for (offset = [0 , y - 2*clearance_r]) {
    intersection () {
      union () {
        translate([-clearance_r, clearance_r+offset, 0])
          difference() {
            union () {
              translate([0, 0, -clearance_r*3]) {
                cylinder(r=clearance_r, h=thickness+clearance_r*3);
                
              }
              if (teardrop) {
                intersection() {
                  rotate([0, 0, -45]) translate([0, -clearance_r, 0])
                    cube([clearance_r*3, clearance_r*2, thickness]);
                  translate([-clearance_r, -clearance_r*4, 0])
                    cube([clearance_r*2, clearance_r*4, thickness]);
                }
              }
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
            translate([-clearance_r, clearance_r+offset, -clearance_r*2-layer_height])
              cylinder(r=hex_r, h=clearance_r*2, $fn=6);
          }
        }
        translate([0, clearance_r+offset, 0])
          cylinder(r=clearance_r*3, h=clearance_r*3);
      }
    }
  }
}

sw = 3.4; // slat width for testing
pyramid_box_truss(40, 40, 40, 3, 3, 2, sw, sw, sw, sw/2, 1, 1, 12);
