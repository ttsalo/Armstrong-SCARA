include <common.scad>;

module drive_assy() {
  translate([0, 0, assy_h]) rotate([0, 180, 0]) circspline_unit();
  flexspline_helix_2();
  flexspline_base();
}

/* Final arm rotation function in C:
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

//demo_arms();
//demo_reachable();

demo_whole();
