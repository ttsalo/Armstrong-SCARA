// Harmonic drive main parameters
press_angle = 40;
flex_teeth = 50;
teeth_diff = 2;

tol = 0.25; // generic tolerance used in some places
lh = 0.3; // layer height needed in a few places

// Main geometry
bearing_r = 22/2;
bearing_h = 7;
washer_h = 1;
bolthead_h = 4;
stepper_shaft_h = 20;
circ_drive_bearing_indent = 1;
flex_bearing_indent = 1;
drive_bearing_r = 13/2;
drive_bearing_h = 7;

// Flexspline dimensions
flex_inner_r = 25.4;
flex_h = 36;
flex_bottom_h = 2;
flex_bolthole_r = 6;
flex_bottom_tooth_h = 3; // The height of the straigth part of the bottom teeth
flex_wt = 0.81;
flex_lip = 1;
pitch = 197;
helix_twist = 5;

// Circspline dimensions
circ_h = 20;
circ_outer_r = 34;
circ_inner_r = 30;
circ_bottom_h = 4;
// Negative clearance cuts a bit from the top of the teeth
circ_tooth_clearance = -0.5;

// Wave driver dimensions
wave_radius = 52.75/2;
driver_h = 12;
driver_w = 10;
drive_bearing_spacing_r = wave_radius - drive_bearing_r;

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

// Circspline mount dimensions
circ_mount_r = circ_outer_r + 6;
circ_mount_h = 8;
circ_mount_1 = 45;
circ_mount_2 = 135;
circ_mount_3 = 225;

// Master arm height setting
main_arm1_height = 12;
main_arm2_height = 12;

// Arm 1st segment dimensions
arm_flex_base_bottom_h = 8;
arm_flex_base_h = 14;
arm_joint1_base_h = main_arm1_height;
arm_joint1_base_r = 15;
arm_joint1_bearing_indent = 7;
arm_large_bolthole_r=6;
arm_w = 30;
arm1_h = main_arm1_height;

// default length
length = 100;

// Truss generation parameters. The element width must be smaller than
// thickness to avoid the top becoming unprintable (triangle outlines
// over thin air)
truss_thickness = 3.5;
truss_width_coeff = 0.75;
truss_radius = 0.1;
truss_arm1 = 1.07; // Extra coefficient for arm1

carr_truss_thickness = 5;
carr_truss_width_coeff = 0.75;
carr_truss_radius = 0.1;

// Arm 2nd segment dimensions
arm2_h = main_arm2_height;
arm_separation = arm_joint1_base_h - arm_joint1_bearing_indent 
  + bearing_h + washer_h * 2;
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
arm_joint31_bearing_spacing = arm_joint3_hollow_r + arm_joint32_tube_wt 
  + arm_joint31_bearing_r;

echo(str("Arm final stage vertical separation: ", arm_separation));
echo(str("Arm final stage total height: ", arm_separation + 2 * arm2_h));

// Default arm lengths
arm1_length = 100;
arm2_length = 150;
arm_spacing = 75;
arm_base_maxrot = 90 - asin((circ_outer_r + arm_w/2) / arm_spacing);
arm_joint_maxrot = 150; // hand-tuned
echo(str("Arm base minimum rotation to clear other base: ", arm_base_maxrot));

// Z carriage dimensions
carr_floor = 1; // Carriage floor thickness.
carr_wt = 4; // Carriage wall thickness.
carr_truss_width = arm_spacing + bearing_r * 2 + 20; // 120;
carr_truss_depth = 15;
drive_h = assy_h + bearing_h + washer_h 
  + arm_flex_base_bottom_h; // Total length needed by the drive unit.
carr_truss_length = circ_outer_r + 1 + carr_wt + bearing_r + 10;
carr_rod_offset = -45;
carr_drive_offset = -40;
carr_top_support_thickness = 3;
carr_top_support_width = 14;
carr_top_support_length = 70;

// Z end dimensions
z_end_bottom_thickness = 7;
z_end_bottom_width = arm_spacing + 20;
z_end_bottom_length = 40;
z_end_top_length = 50;
z_end_bottom_height = 30;
z_end_rod_offset = 24; // rod center from vertical plate

