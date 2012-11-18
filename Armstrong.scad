/* Armstrong SCARA robot (c) by Tomi T. Salo <ttsalo@iki.fi> 2012 */

use <parametric_involute_gear_v5.0.scad>;
use <SolidReplacementTruss.scad>;
use <lm8uu-holder-slim_double-vertical.scad>;

press_angle = 40;
flex_teeth = 50; // was 60, was 44
teeth_diff = 2;

circ_h = 20;
circ_outer_r = 34;
circ_inner_r = 30;
circ_bottom_h = 4;

tol = 0.25; // generic tolerance used in some places
lh = 0.3; // layer height needed in a few places

bearing_r = 22/2;
bearing_h = 7;
washer_h = 1;
bolthead_h = 4;
stepper_shaft_h = 20;
circ_drive_bearing_indent = 1;
flex_bearing_indent = 1;
drive_bearing_r = 13/2;
drive_bearing_h = 7;

flex_inner_r = 25.4;
flex_h = 36;
flex_bottom_h = 2;
flex_bolthole_r = 6;
flex_wt = 0.81;
flex_lip = 1;
pitch = 197; // 163; // was 225
helix_twist = 5;

// Flexspline inner radius when in full contact with the circular spline
// Testing with 60t 163p spline. Measured 51.5, but that doesn't give good contact.
// Previous size 53, but that produces too much resistance. Let's try 52 and 52.5.
wave_radius = 52.75/2;
driver_h = 12;
driver_w = 10;
drive_bearing_spacing_r = wave_radius - drive_bearing_r;

circ_tooth_clearance = -0.5; // Negative clearance cuts a bit from the top of the teeth

// The total height of the drive unit, excluding the motor and flexspline base.
assy_h = 50;
stepper_shaft_l = 20;

tooth_overlap = (flex_h + circ_h) - assy_h;

// Position of the middle of the tooth overlap section on the stepper shaft.
stepper_shaft_mid_rot = circ_h - tooth_overlap/2;

echo(str("Tooth overlap: ", tooth_overlap));
echo(str("Drive midpoint on stepper shaft: ", stepper_shaft_mid_rot));

red_r = teeth_diff/flex_teeth;
echo(str("Reduction ratio: 1/", flex_teeth/teeth_diff, " (", red_r, ")"));
echo(str("With 200x16 motor, arc minutes per microstep: ", 360*60/(200*16)*red_r));
echo(str("Linear resolution (mm) for 100 mm arm: ", sin(360/(200*16)*red_r) * 100));
echo(str("Torque (N) at 100 mm for 40 Ncm motor: ", 4/red_r));
echo(str("Linear speed equivalent to standard Prusa's 300 mm/s at 100 mm: ",
         300*80 * sin(360/(200*16)*red_r) * 100));

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

/* Arm mechanics:

   The drive input makes the flexspline and circular spline rotate in relation to each other.
   The circular spline resembles a normal outer gear of a planetary gearbox. The flexspline
   must have flexible walls extending from the base, to allow deformation of the gear ring,
   but must be stiff enough to transfer the rotation to the base. 

   In the first arm joint, either side can be fixed in place, since they just rotate in
   relation to each other. However, there is ample space in the flexspline cup for the
   bearings and fixture bolt, so without fancy large diameter bearings it's simpler to
   fix the circular spline, motor and input drive in place.

   The flexspline should be a replaceable part. It can have full height teeth along the outside
   which match the teeth in the arm base. These both are sandwiched between the bearings and
   form a package.

   The wave driver, circular spline and the motor are mounted above the driver base and the
   flexspline. The torque of the driver acts against these so they have to be ridigly mounted.
   Other flexing forces (which may be large if the driver drives an arm) act against the driver
   bearings and the bearing mount, so they have to be mounted well into the chassis. But this
   is an issue to solved with each specific design. Still, the basic driver should include 
   some sort of an reference design.

   Driver variants: The swing arm variant should have the arm coming out from the side, whereas
   the shaft output version can have the bearings arranged so that the driver sits on the inner 
   races. In this case the whole thing can be assembled into a cylinder, which is an efficient 
   way to tie the ends together.

*/

/* Arm kinematics:
   We know that the middle joints must be positioned onto a fixed radius 
   circle around the target point. Since the middle joints rotate in another
   circle around the base joint, the problem becomes an intersection of two
   circles.
   
   We can calculate the target position in polar coordinates first, with atan2 and
   distance calculation. From the distance, we can easily calculate the distance of
   the arm joint from the line to the target point, and from there, the rotation
   from the line to the target. Combining that with the polar angle of the target,
   we get the absolute rotation of the arm base joint.
*/

demo_mount = 16;
demo_rod1 = 45;
demo_rod2 = 65;
demo_rodh = 55;

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

circ_mount_r = circ_outer_r + 6;
circ_mount_h = 8;
circ_mount_1 = 45;
circ_mount_2 = 135;
circ_mount_3 = 225;

module circspline_mount(extra=0) {
  translate([0, circ_mount_r, 0]) cylinder(r=8+extra, h=circ_mount_h, $fn=16);
  translate([-8-extra, 0, 0]) cube([16+extra*2, circ_mount_r, circ_mount_h]);
}

module circspline_mount_void() {
  translate([0, circ_mount_r, 0]) cylinder(r=2, h=circ_mount_h, $fn=16);
}

// Circspline that mounts to the carriage.
module circspline_unit() {
  difference() {
    union() {
      circspline_helix();
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

module demo_mount_block() {
if (demo_mount) {
        difference() {
          translate([-demo_mount/2, -demo_mount/2, 0])
            cube([demo_mount, demo_rod2 + demo_mount, demo_mount]);
          cylinder(r=4, h=circ_h, $fn=20);
          translate([0, demo_rod1, 0]) cylinder(r=4, h=circ_h, $fn=20);
          translate([0, demo_rod2, 0]) cylinder(r=4, h=circ_h, $fn=20);
          translate([-demo_mount/2-1, demo_rodh, demo_mount/2]) 
            rotate([0, 90, 0]) cylinder(r=4, h=circ_h, $fn=20);
        }
  }
}

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

/* Arm design. The base arms have just a 12mm hole in the free joint end and a bearing
   indent on the top side. The next section has a 8mm hole with a short tower to make it
   stiffer. The section bolts through the bearings of the joint and can be installed either
   way around, with the idea being that the left and right sections are opposite so that
   they clear each other.
   The end joint is more interesting. Ideally it should have a large through hole to
   allow mounting tools. This requires a large diameter bearing, or some other setup.
   In the prototype phase a set of 624 bearings running in a groove could work nicely. 

   Extruder height issues. The depth of the tool mounting hole is very hard to make
   short enough for mounting a J-head MKVb (which has 30 mm from groove mount lower
   edge to near the heater block). With 12mm high arm1 (minimum to fit the slew bearings,
   which need 14mm total) this leaves only 8mm for the arm2 heights - not good.

   Alternatives: 
   - Design a groove mount lengthening adapter to allow mounting the extruder deeper in the pit.
   - Remove material from the lower arm2 to allow heater block to reside actually inside the pit
     and from top of upper arm2 to allow mounting the groove mount plate lower then the upper
     surface of the arm.

*/

// Master arm height setting
main_arm1_height = 12;
main_arm2_height = 12;

arm_flex_base_bottom_h = 3;
arm_flex_base_h = 8;
arm_joint1_base_h = main_arm1_height;
arm_joint1_base_r = 15;
arm_joint1_bearing_indent = 7;
arm_large_bolthole_r=6;
arm_w = 30;
arm2_h = main_arm2_height;
arm1_h = main_arm1_height;

module my_truss_platform(length, width, height, thickness, element_width, radius)
{
	segments = 2*floor(width/height)+1;
	seg_width = width/(segments+1);
    
	if (segments > 0)
		  for(i = [1 : segments])
		{
			translate([0, (seg_width)*(i-1)+2*seg_width*(1+pow(-1,i))/2, (height)*(1+pow(-1,i))/2])
			{
				rotate([180*(1+pow(-1, i))/2, 0, 0])
				isoc_truss(length, seg_width*2, height, thickness, element_width, radius);
			}
		}
}

length = 100;

// Truss generation parameters. The element width must be smaller than thickness to avoid the
// top becoming unprintable (triangle outlines over thin air)
truss_thickness = 3.5;
truss_width_coeff = 0.75;
truss_radius = 0.1;
truss_arm1 = 1.07; // Extra coefficient for arm1

//my_truss_platform( length, arm_w, arm_h, truss_thickness, truss_thickness*truss_width_coeff, truss_radius);
//corner_truss( length, arm_w, arm_h, 4, 3);

module arm1_dummy(length) {
  difference() {
    union() {
      cylinder(r=circ_outer_r, h=arm1_h, $fn=60);
      intersection() {
        cylinder(r=circ_outer_r, h=arm1_h+2, $fn=60);
        translate([0, -arm_w/2, 0])
          cube([length, arm_w, arm1_h+2]);
      }
    }
    translate([0, 0, arm_flex_base_bottom_h]) flexspline_gear(flex_h, -0.4, -0.4);
    cylinder(r=arm_large_bolthole_r, h=arm_flex_base_bottom_h + 1, $fn=24);
    
  }
}

module arm1(length, type, use_truss) {
  difference() {
    union() {
      difference() {
        // Use the arm full height for the flexspline base, but cut out material
        // from the backside where it's not needed (much) (disabled, made it too weak)
        cylinder(r=circ_outer_r, h=arm1_h, $fn=60);
        /* translate([0, -circ_outer_r * 1.5, arm_flex_base_h])
          rotate([0, -15, 0])
            cube([circ_outer_r * 2, circ_outer_r * 3, arm1_h]);
        translate([-circ_outer_r * 2, -circ_outer_r * 1.5, arm_flex_base_h])
          cube([circ_outer_r * 2, circ_outer_r * 3, arm1_h]); */
      }
      translate([0, -arm_w/2, 0])
        if (use_truss == 0) { cube([length, arm_w, arm1_h]); }
        else { my_truss_platform(length, arm_w, arm1_h, truss_thickness*truss_arm1, 
                                 truss_thickness*truss_width_coeff*truss_arm1, 
                                 truss_radius); }
      translate([length, 0, 0]) cylinder(r=arm_joint1_base_r, h=arm_joint1_base_h);
    }
    translate([0, 0, arm_flex_base_bottom_h]) flexspline_gear(flex_h, -0.6, -0.6);
    cylinder(r=arm_large_bolthole_r, h=arm_flex_base_bottom_h + 1, $fn=24);
    if (type == 1) {
      translate([length, 0, 0])
        cylinder(r=arm_large_bolthole_r, h=arm_joint1_base_h + 1, $fn=24);
      translate([length, 0, arm_joint1_base_h-arm_joint1_bearing_indent])
         cylinder(r=bearing_r+tol, h=arm_joint1_bearing_indent + 1);
    } else {
      translate([length, 0, arm_joint1_bearing_indent + lh])
        cylinder(r=arm_large_bolthole_r, h=arm_joint1_base_h + 1, $fn=24);
      translate([length, 0, 0])
         cylinder(r=bearing_r+tol, h=arm_joint1_bearing_indent);
    }
  }
}

arm_separation = arm_joint1_base_h - arm_joint1_bearing_indent + bearing_h + washer_h * 2;
echo(str("Arm final stage vertical separation: ", arm_separation));
echo(str("Arm final stage total height: ", arm_separation + 2 * arm2_h));

arm_bolthole_r=4;
arm_joint2_base_h = main_arm2_height;
arm_joint2_base_r = 15;
arm_joint3_hollow_r = 10;
arm_joint31_base_h = main_arm2_height;
arm_joint31_base_r = 15;
arm_joint31_bearing_r = 13/2;
arm_joint31_bearing_h = 5;
arm_joint31_bearing_clearance = 2;
arm_joint32_base_h = main_arm2_height;
arm_joint32_base_r = 15;
arm_joint32_tube_h_clearance = 1;
arm_joint32_tube_wt = 2;
arm_joint32_tube_groove_depth = 1;
arm_joint31_bearing_spacing = arm_joint3_hollow_r + arm_joint32_tube_wt + arm_joint31_bearing_r;

/* Joint3 type 1 is the bearing side, type 2 is the tube and groove they run in. */
module arm2(length, joint3_type, groovemount, use_truss) {
  difference() {
    union() {
      cylinder(r=arm_joint2_base_r, h=arm_joint2_base_h, $fn=30);
      translate([0, -arm_w/2, 0])
        if (use_truss == 1) {
          my_truss_platform(length, arm_w, arm2_h, truss_thickness, truss_thickness*truss_width_coeff, 
                            truss_radius); 
        } else {
          cube([length, arm_w, arm2_h]); 
        }
      if (joint3_type == 1) {
        translate([length, 0, 0]) cylinder(r=arm_joint31_base_r, h=arm_joint31_base_h, $fn=30);
        translate([length, 25, 0]) cylinder(r=6, h=arm_joint31_base_h, $fn=30);
        translate([length, -25, 0]) cylinder(r=6, h=arm_joint31_base_h, $fn=30);
        translate([length-6, -25, 0]) cube([12, 50, arm_joint31_base_h]);
        translate([length, 0, 0]) 
          for (i = [90 : 120 : 360]) {
            rotate(i, [0, 0, 1])
              translate([0, arm_joint31_bearing_spacing - tol, 0])
                union() {
                  cylinder(r = 8, h = arm_joint31_base_h);
                  translate([-8, -16, 0])
                    cube([16, 16, arm_joint31_base_h]);
                }
          }
      } else {
        translate([length, 0, 0]) cylinder(r=arm_joint32_base_r, h=arm_joint32_base_h);
        translate([length, 0, 0]) cylinder(r=arm_joint3_hollow_r + arm_joint32_tube_wt, 
                                           h=arm_joint31_base_h + arm_separation 
                                             - arm_joint32_tube_h_clearance, $fn=60);
        translate([length, 0, arm_joint31_base_h + arm_separation 
                              - arm_joint32_tube_h_clearance - arm_joint31_bearing_h * 2])
        difference() { // The slew bearing groove at the top of the tube, with printability cones
          union() {
            cylinder(r = arm_joint3_hollow_r + arm_joint32_tube_wt + arm_joint32_tube_groove_depth,
                     h = arm_joint31_bearing_h * 2);
            translate([0, 0, -arm_joint32_tube_groove_depth])
            cylinder(r1 = arm_joint3_hollow_r + arm_joint32_tube_wt,
                     r2 = arm_joint3_hollow_r + arm_joint32_tube_wt + arm_joint32_tube_groove_depth,
                     h = arm_joint32_tube_groove_depth);
          }
          translate([0, 0, arm_joint31_bearing_h / 2])
            difference() {
            cylinder(r = arm_joint3_hollow_r + arm_joint32_tube_wt + arm_joint32_tube_groove_depth,
                     h = arm_joint31_bearing_h + arm_joint32_tube_groove_depth);
            translate([0, 0, arm_joint31_bearing_h])
            cylinder(r1 = arm_joint3_hollow_r + arm_joint32_tube_wt,
                     r2 = arm_joint3_hollow_r + arm_joint32_tube_wt + arm_joint32_tube_groove_depth,
                     h = arm_joint32_tube_groove_depth);
            }
        }
      }
    }
    cylinder(r=arm_bolthole_r, h=arm_joint2_base_h+1, $fn=24);
    translate([length, 0, 0]) 
      if (joint3_type == 1) {
        translate([0, 0, groovemount * 4])
          cylinder(r=arm_joint3_hollow_r, h=arm_joint31_base_h + 1);
        cylinder(r=6, h=arm_joint31_base_h + 1);
        if (groovemount == 1) {
          translate([0, -6, 0])
            cube([arm_joint31_base_r * 2, 12, arm_joint31_base_h]);
          translate([0, -9, 4])
            cube([arm_joint31_base_r * 2, 18, arm_joint31_base_h]);
        }
        for (i = [90 : 120 : 360]) {
          rotate(i, [0, 0, 1])
            translate([0, arm_joint31_bearing_spacing - tol, 0])
              union() {
                cylinder(r = 2, h = arm_joint31_base_h, $fn=8); 
                translate([0, 0, arm_joint31_base_h - 4])
                  cylinder(r = 4, h = 5, $fn=16);
              }
          translate([0, 25, 0]) cylinder(r=2, h=arm_joint31_base_h, $fn=8);
          translate([0, -25, 0]) cylinder(r=2, h=arm_joint31_base_h, $fn=8);
        } 
      } else {
        cylinder(r=arm_joint3_hollow_r, h=arm_joint31_base_h + arm_separation);
      }
  }
}

module drive_assy() {
  translate([0, 0, assy_h]) rotate([0, 180, 0]) circspline_unit();
  flexspline_helix_2();
  flexspline_base();
}

arm1_length = 100;
arm2_length = 150;
arm_spacing = 75;
arm_base_maxrot = 90 - asin((circ_outer_r + arm_w/2) / arm_spacing);
arm_joint_maxrot = 150; // hand-tuned
echo(str("Arm base minimum rotation to clear other base: ", arm_base_maxrot));

/* Final arm rotation function:
   atan2(ypos, xpos) + // or -
    acos(
   (pow(arm1_length, 2) - pow(arm2_length, 2) + pow(dist(xpos, ypos), 2)) / (2 * dist(xpos, ypos))
   / arm1_length)

*/

function dist(x, y) = sqrt(pow(x, 2) + pow(y, 2));
function jointdeflbase(xpos, ypos) = (pow(arm1_length, 2) - pow(arm2_length, 2) + pow(dist(xpos, ypos), 2)) / (2 * dist(xpos, ypos));
function jointrot(xpos, ypos) = acos(jointdeflbase(xpos, ypos)/arm1_length);
function joint2rot(xpos, ypos) = acos((dist(xpos, ypos) - jointdeflbase(xpos, ypos))/arm2_length);
function arm11rot(xpos, ypos) = atan2(ypos, xpos) + jointrot(xpos, ypos);
function arm21rot(xpos, ypos) = -(jointrot(xpos, ypos) + joint2rot(xpos, ypos));
function arm12rot(xpos, ypos) = atan2(ypos, xpos) - jointrot(xpos, ypos);
function arm22rot(xpos, ypos) = jointrot(xpos, ypos) + joint2rot(xpos, ypos);

function arm11rotlegal(rot) = (rot % 360) < 180 || (rot % 360) > ((360-arm_base_maxrot) % 360);
function arm12rotlegal(rot) = (rot % 360) > 180 || (rot % 360) < arm_base_maxrot;

demo_trusses = 0;
range = 150;
xrange = 200;
xmin = 0;
xmax = xrange;
ymin = 82;
ymax = 202;

rrange = 120;
rmin = - rrange / 2;
rmax = rrange / 2;
dmin = 100;
dmax = 200;

module demo_arms() {
  xpos = 0;
  ypos = ymin + 0;

  /* Rectilinear coordinate animation */
  /* xpos = ($t < 0.25) ? (xmin + $t * 4 * (xmax - xmin)) : 
           (($t < 0.5) ? xmax : 
             (($t < 0.75) ? (xmin + (0.75 - $t) * 4 * (xmax - xmin)) : xmin));
  ypos = ($t < 0.25) ? ymin : 
           (($t < 0.5) ? (ymin + ($t - 0.25) * 4 * (ymax - ymin)) :
             (($t < 0.75) ? ymax : (ymin + (1 - $t) * 4 * (ymax - ymin)))); */
  /* Polar coordinate animation
  rpos = ($t < 0.25) ? (rmin + $t * 4 * (rmax - rmin)) : 
           (($t < 0.5) ? rmax : 
             (($t < 0.75) ? (rmin + (0.75 - $t) * 4 * (rmax - rmin)) : rmin));
  dpos = ($t < 0.25) ? dmin : 
           (($t < 0.5) ? (dmin + ($t - 0.25) * 4 * (dmax - dmin)) :
             (($t < 0.75) ? dmax : (dmin + (1 - $t) * 4 * (dmax - dmin)))); 
  xpos = sin(rpos) * dpos + arm_spacing / 2;
  ypos = cos(rpos) * dpos; */

  arm11r = arm11rot(xpos - xrange/2 + arm_spacing/2, ypos);
  arm12r = arm12rot(xpos - xrange/2 - arm_spacing/2, ypos);
  arm21r = arm21rot(xpos - xrange/2 + arm_spacing/2, ypos);
  arm22r = arm22rot(xpos - xrange/2 - arm_spacing/2, ypos);
  /* arm11r = -arm_base_maxrot;
  arm12r = arm_base_maxrot;
  arm21r = 0;
  arm22r = 0; */

  xpos_real = xpos - xrange/2 + arm_spacing/2;

  echo(str("Alt rot: ", atan2(ypos, xpos_real) + acos((pow(arm1_length, 2) - pow(arm2_length, 2) + pow(dist(xpos_real, ypos), 2)) / (2 * dist(xpos_real, ypos)) / arm1_length)));
  echo(str("Alt rot (rel): ", acos((pow(arm1_length, 2) - pow(arm2_length, 2) + pow(dist(xpos_real, ypos), 2)) / (2 * dist(xpos_real, ypos)) / arm1_length)));
  echo(str("Test: ", (pow(arm1_length, 2) - pow(arm2_length, 2) + pow(dist(xpos_real, ypos), 2))));
  echo(str("Test: ", (2 * dist(xpos_real, ypos))));
  echo(str("Test: ", arm1_length));

  echo(str("Target position: ", xpos, ", ", ypos));
  echo(str("Arm 1 relative: ", xpos - xrange/2 + arm_spacing/2, ", ", ypos));
  echo(str("Arm 2 relative: ", xpos - xrange/2 - arm_spacing/2, ", ", ypos));
  echo(str("Base rotations: ", arm11r - 90, ", ", arm12r - 90));
  echo(str("Joint rotations: ", arm21r, ", ", arm22r));
  echo(str("Effector rotations: ", arm11r + arm21r, ", ", arm12r + arm22r, ", total:",
           (arm11r + arm21r - arm12r - arm22r) % 360));
  echo(str("Base rotations legal: ", arm11rotlegal(arm11r), ", ", arm12rotlegal(arm12r)));

  translate([xrange/2 - arm_spacing/2, 0, 0]) rotate([0, 0, arm11r]) arm1(arm1_length, 1, demo_trusses);
  translate([xrange/2 + arm_spacing/2, 0, 0]) rotate([0, 0, arm12r]) arm1(arm1_length, 2, demo_trusses);
  translate([xrange/2 - arm_spacing/2, 0, 0]) rotate([0, 0, arm11r]) 
    translate([arm1_length, 0, arm_joint1_base_h - arm_joint1_bearing_indent + bearing_h + washer_h]) 
      rotate([0, 0, arm21r]) arm2(arm2_length, 1, demo_trusses);
  translate([xrange/2 + arm_spacing/2, 0, 0]) rotate([0, 0, arm12r]) translate([arm1_length, 0, -arm_joint2_base_h - washer_h]) 
    rotate([0, 0, arm22r]) arm2(arm2_length, 2, demo_trusses);

  // Build plate
  translate([xmin, ymin, -30]) color("darkkhaki") cube([xmax - xmin, ymax - ymin, 4]);
}

module demo_reachable() {
  for (x = [0 : 10 : 300]) {
    for (y = [-200 + arm_spacing / 2 : 10 : 200 + arm_spacing / 2]) {
        //echo(str("Arm rotations: ", arm21rot(x - arm_spacing, y), ", ", arm22rot(x, y)));
        //echo(str("Pos: ", x, ", ", y));
        //echo(str("Arm rotations: ", arm11rot(x, y - arm_spacing), ", ", arm12rot(x, y)));
        //echo(str("Arm rotations OK: ", arm11rotlegal(arm11rot(x, y - arm_spacing)), ", ", arm12rotlegal(arm12rot(x, y))));
        //echo(str("Joint deflections: ", jointdefl(x, y - arm_spacing), ", ", jointdefl(x, y)));
        if (arm21rot(x, y - arm_spacing) < 0 && arm22rot(x, y) > 0 &&
            arm21rot(x, y - arm_spacing) > -arm_joint_maxrot && arm22rot(x, y) < arm_joint_maxrot &&
            arm11rotlegal(arm11rot(x, y - arm_spacing)) && 
            arm12rotlegal(arm12rot(x, y)) &&
            ((arm11rot(x, y-arm_spacing) + arm21rot(x, y-arm_spacing) - arm12rot(x, y) - arm22rot(x, y)) > 180 
             || (arm11rot(x, y-arm_spacing) + arm21rot(x, y-arm_spacing) - arm12rot(x, y) - arm22rot(x, y)) < 0)  )
          {
          color("lime") translate([x, y, 0]) 
            if (x >= xmin && x <= xmax && y >= ymin && y <= ymax) {
              cube([6, 6, 7], center=true); } else { cube([4, 4, 5], center=true); }
        } else {
          color("red") translate([x, y, 0]) 
            if (x >= xmin && x <= xmax && y >= ymin && y <= ymax) {
              cube([6, 6, 7], center=true); } else { cube([4, 4, 5], center=true); }
        }
    }
  }
}

/* Arm rotation.
   Playing around with the parameters...
   125 mm arms with 75 mm spacing gives a 120 degrees wide sector of effector movement, with
   min distance from base midpoint of 100 and max distance of 200.
   100 mm first section, 160 mm second section, 75 mm spacing gives a 200x120 rectangular
   work area with arm angles quite reasonable all over it, with work area being from 100 to 
   220 mm away from base joint centerline. Finetuning: shifting the work area to 90-210 avoids
   the elbows almost straightening in the far corners, while allowing the arms to just clear the
   drive units at the near limit.
   Still more tuning: 100 and 150 mm arms allow the same work area, now from 82 to 202 mm.
 */
   

/* The carriage into which the arm drives bolt into. 
   Construction: 
   - The circspline and motor should mount onto a flange into which they are inserted from the top.
     The flange can be semicircular to save material, with mounting bolts at 45, 135 and 225 degrees.
   - The bottom should have a similar structure, but for bolting in the arms.
   - All the vertical structures should be roughly in the area between and behind the main arm pivots,
     to keep the arm travel are clear. The arm back travel extends to almost the point directly behind
     the pivot.
   - The LM8UU bearings and travel rods should be as close to arm mounts as possible. Since they need
     some spacing, they should be directly behind the pivot points and maybe a little to the side, if
     the arm travel allows this.

*/

carr_floor = 1; // Carriage floor thickness.
carr_wt = 3; // Carriage wall thickness.
carr_truss_width = arm_spacing + bearing_r * 2 + 4; // 120;
carr_truss_depth = 15;
drive_h = assy_h + bearing_h + washer_h + arm_flex_base_bottom_h; // Total length needed by the drive unit.
carr_truss_length = circ_outer_r + 1 + carr_wt + bearing_r + 2;
carr_rod_offset = -45;
carr_drive_offset = -40;
carr_top_support_thickness = 3;
carr_top_support_width = 14;
carr_top_support_length = 70;

module circspline_carr_mount() {
  translate([0, circ_mount_r, drive_h-8-8]) difference() { 
    intersection() {
      translate([0, 0, -circ_mount_h]) cylinder(r=8, h=circ_mount_h*2, $fn=16);
      translate([0, -12, -16])
        cylinder(r1=0, r2=30, h=24);
    }
    cylinder(r=2, h=circ_mount_h, $fn=16);
  }
}

module circspline_carr_mount_void() {
  translate([0, circ_mount_r, -circ_mount_h+drive_h-8-8])
    cylinder(r=4, h=circ_mount_h-lh, $fn=6);    
}

module arm_mount() {
  translate([0, 0, -carr_floor-carr_truss_depth])
    cylinder(r=4+carr_wt, h=carr_floor+carr_truss_depth);
  translate([0, 0, -carr_floor]) 
    cylinder(r=circ_outer_r+1+carr_wt, h=drive_h+carr_floor-8);
}

module arm_mount_2() {
  rotate([0, 0, -circ_mount_1]) circspline_carr_mount();
  rotate([0, 0, -circ_mount_2]) circspline_carr_mount();
  rotate([0, 0, -circ_mount_3]) circspline_carr_mount();
}

module arm_mount_void() {
  cylinder(r=bearing_r + 1, h=bearing_h + washer_h);
  difference() {
    translate([0, 0, -carr_floor]) {
      rotate([0, 0, 20]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt, drive_h+carr_floor]);
      rotate([0, 0, 90]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt, drive_h+carr_floor]);
      rotate([0, 0, 165]) cube([circ_outer_r+1+carr_wt, circ_outer_r+1+carr_wt, drive_h+carr_floor]);
    }
    translate([0, 0, -carr_floor])
      cylinder(r=bearing_r + 2, h=carr_floor);
      /* translate([circ_outer_r/2, -circ_outer_r/2, -circ_outer_r])
        cylinder(r1=0, r2=circ_outer_r*2, h=circ_outer_r*3); */
    translate([-circ_outer_r*0.5, -circ_outer_r*2.72, 0]) rotate([0, 0, -45]) rotate([0, -58, 0])
      cube([circ_outer_r*4, circ_outer_r*4, circ_outer_r*4]);      
  }
  translate([circ_outer_r*1+8, circ_outer_r*1+8, 0]) rotate([0, 0, -45])
    cube([circ_outer_r*4, circ_outer_r*4, circ_outer_r*4]);      
}

module arm_mount_void_2() {
  translate([0, 0, -carr_truss_depth-carr_floor-0.5])
    cylinder(r=4, h=carr_truss_depth+carr_floor+1);
  cylinder(r=circ_outer_r+1, h=drive_h+1);
  translate([0, 0, bearing_h+washer_h+arm_flex_base_bottom_h+assy_h]) 
  rotate([0, 180, 0]) {
    rotate([0, 0, circ_mount_1]) circspline_mount(extra=1);
    rotate([0, 0, circ_mount_2]) circspline_mount(extra=1);
    rotate([0, 0, circ_mount_3]) circspline_mount(extra=1);
  }
  rotate([0, 0, -circ_mount_1]) circspline_carr_mount_void();
  rotate([0, 0, -circ_mount_2]) circspline_carr_mount_void();
  rotate([0, 0, -circ_mount_3]) circspline_carr_mount_void();
}

module carriage(use_truss) {
  difference() {
    union() {
      difference() {
        union() {
          translate([-arm_spacing/2, 0, 0])
            arm_mount();
          translate([arm_spacing/2, 0, 0])
            mirror([-1, 0, 0]) arm_mount();
          translate([-carr_truss_width/2, bearing_r + 2 - carr_truss_length, -carr_floor])
            rotate([180, 0, 90])
              if (use_truss) {
                my_truss_platform(carr_truss_length, carr_truss_width, carr_truss_depth, 
                                  truss_thickness, truss_thickness*truss_width_coeff, truss_radius);
              } else {
                cube([carr_truss_length, carr_truss_width, carr_truss_depth]);
              }              
          translate([0, carr_drive_offset, -carr_floor-carr_truss_depth]) 
            cylinder(r=4 + carr_wt, h=carr_floor + carr_truss_depth);
          translate([0, carr_drive_offset, -carr_floor-carr_truss_depth]) 
            cylinder(r=15/2 + carr_wt, h=6.8+carr_wt, $fn=6);
          translate([-carr_top_support_width/2, -carr_top_support_length/2, 
                     bearing_h+washer_h+arm_flex_base_bottom_h+assy_h
                     -carr_top_support_thickness-circ_mount_h])
            cube([carr_top_support_width, carr_top_support_length, carr_top_support_thickness]);
        }
        translate([-arm_spacing/2, 0, 0])
          arm_mount_void();
        translate([arm_spacing/2, 0, 0])
          mirror([-1, 0, 0]) arm_mount_void();
      }
      translate([0, -(circ_outer_r + 1 + carr_wt) / 2, -carr_floor/2])
        cube([arm_spacing + bearing_r * 2 + 4, circ_outer_r + carr_wt + 1, carr_floor], center=true);
      translate([0, 0, -carr_floor/2])
        cube([arm_spacing + bearing_r * 2 + 4, (bearing_r + 2) * 2, carr_floor], center=true);
      translate([-arm_spacing/2, 0, 0])
        arm_mount_2();
      translate([arm_spacing/2, 0, 0])
        mirror([-1, 0, 0]) arm_mount_2();
      translate([-arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth])
        rotate([0, 0, 180]) mirror([-1, 0, 0]) lm8uu_holder_slim_double_vertical();
      translate([arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth])
        rotate([0, 0, 180]) lm8uu_holder_slim_double_vertical();
    }
    translate([-arm_spacing/2, 0, 0])
      arm_mount_void_2();
    translate([arm_spacing/2, 0, 0])
      mirror([-1, 0, 0]) arm_mount_void_2();
    translate([-arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth-1]) cylinder(r=15.4/2, h=200);
    translate([arm_spacing/2, carr_rod_offset, -carr_floor-carr_truss_depth-1]) cylinder(r=15.4/2, h=200);
    translate([0, carr_drive_offset, -carr_floor-carr_truss_depth+6.8]) 
      cylinder(r=4+tol, h=carr_floor + carr_truss_depth+2);
    translate([0, carr_drive_offset, -carr_floor-carr_truss_depth-1]) 
      cylinder(r=15/2, h=6.8-lh+1, $fn=6);
  }
  // translate([0, carr_drive_offset, 0]) color("blue") cylinder(r=4, h=100); // drive rod
}
 
z_end_bottom_thickness = 7;
z_end_bottom_width = arm_spacing + 20;
z_end_bottom_length = 40;
z_end_top_length = 50;
z_end_bottom_height = 30;
z_end_rod_offset = 24; // rod center from vertical plate

module z_end_bottom_clamp_bolts() {
  translate([0, -7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);
  translate([0, 7, 0]) rotate([0, 90, 0]) cylinder(r=1.5, h=20);  
}

module z_end_bottom() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_bottom_length, z_end_bottom_height]);
    }
    translate([-arm_spacing/2 + z_end_bottom_thickness, 
               z_end_bottom_thickness, z_end_bottom_thickness])
      cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, z_end_bottom_height]);
    translate([arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([-arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
   mirror([1, 0, 0])
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
   translate([18, 24, 0]) cylinder(r=4, h=20);
   translate([-18, 24, 0]) cylinder(r=4, h=20);
   translate([0, 10, -4]) rotate([90, 0, 0]) {
     translate([18, 24, 0]) cylinder(r=4, h=20);
     translate([-18, 24, 0]) cylinder(r=4, h=20);
   }
  }
}


module z_end_support() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_bottom_length, z_end_bottom_height]);
    }
    translate([-arm_spacing/2 + z_end_bottom_thickness, 
               z_end_bottom_thickness, z_end_bottom_thickness])
      cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, z_end_bottom_height]);
translate([18, 24, 0]) cylinder(r=4, h=20);
   translate([-18, 24, 0]) cylinder(r=4, h=20);
   translate([0, 10, -4]) rotate([90, 0, 0]) {
     translate([18, 24, 0]) cylinder(r=4, h=20);
     translate([-18, 24, 0]) cylinder(r=4, h=20);
   }
   }
  }


module z_end_top() {
  difference() {
    union() {
      translate([-arm_spacing/2, 0, 0])
        cube([arm_spacing, z_end_top_length, z_end_bottom_height]);
    }
    translate([-arm_spacing/2 + z_end_bottom_thickness, 
               z_end_bottom_thickness, z_end_bottom_thickness])
      cube([arm_spacing - z_end_bottom_thickness * 2, z_end_bottom_length, z_end_bottom_height]);
    translate([arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([-arm_spacing/2, z_end_rod_offset, 0])
      cylinder(r=4, h=50);
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
   mirror([1, 0, 0])
    translate([arm_spacing/2 - 10, z_end_rod_offset, 16])
      z_end_bottom_clamp_bolts();
   translate([0, 10, -4]) rotate([90, 0, 0]) {
     translate([18, 24, 0]) cylinder(r=4, h=20);
     translate([-18, 24, 0]) cylinder(r=4, h=20);
   }
   // NEMA17 screw holes
   translate([0, z_end_rod_offset - carr_rod_offset + carr_drive_offset, 0]) {
   for (i = [45 : 90 : 315]) {
      rotate(i, [0, 0, 1])
      translate([0, 21.8, 0])
      union() {
        cylinder(r = 1.5, h = z_end_bottom_thickness, $fn=8);
        translate([0, 0, z_end_bottom_thickness - 1.5])
          cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
      }
     cylinder(r = 12, h = z_end_bottom_thickness); // NEMA17 central hole
     }
    }
  }
}

module demo_whole() {
  demo_arms();
  translate([100, 0, -bearing_h-washer_h]) {
    carriage(0);
  }
  translate([100 + arm_spacing/2, 0, arm_flex_base_bottom_h]) {
   rotate([0, 0, -6.6 + 360/50/2])
    flexspline_helix_2();
   translate([0, 0, assy_h]) rotate([0, 180, 0]) circspline_unit();
  }
  translate([100 - arm_spacing/2, 0, arm_flex_base_bottom_h]) {
   rotate([0, 0, 132.516 + 360/50/2])
    flexspline_helix_2();
  }
}

//circspline();
//circspline_helix();
//circspline_unit();
//circspline_unit_spline();
//circspline_unit_motor_mount();
//flexspline_helix_2();
//flexspline_base();
//rotate([90, 0, 0]) 
//  wave_rotor();
//arm1_dummy(50);
//arm1(100, 1, 1);
//arm1(100, 2, 1);
//arm2(150, 1, 1, 1);
//translate([0, 50, 0]) 
//  arm2(150, 2, 0, 1);


// carriage(0);
/* translate([-arm_spacing/2, 0, bearing_h+washer_h]) rotate([0, 0, 90+135]) arm1(100, 0);
translate([-arm_spacing/2, 0, bearing_h+washer_h+arm_flex_base_bottom_h]) rotate([0, 0, 90]) flexspline();
translate([-arm_spacing/2, 0, bearing_h+washer_h+arm_flex_base_bottom_h+assy_h]) 
  rotate([0, 180, 0]) circspline_unit(); */
//translate([0, carr_rod_offset - z_end_rod_offset, -40])
// z_end_bottom();
// z_end_support();
//z_end_top();

//demo_arms();
//demo_reachable();

demo_whole();

//demo_mount_block();
//difference() {
//  drive_assy();
//  cube([100, 100, 100]);
//}