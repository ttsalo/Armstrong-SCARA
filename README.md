Armstrong, the parallel SCARA 3D printer.

Current version is the A1. It's already capable of printing actual
objects, but is very much in the prototype/alpha stage.

NOTE! The STL files may be out of date at any given time. If you want to
reproduce this, use the SCAD files instead.

Concise contruction instructions:

1. Print plastic parts. You need:
 1 x arm11
 1 x arm12
 1 x arm22
 1 x arm21
 1 x z-carriage
 1 x z-end-bottom
 1 x z-end-top
 1 x z-end-support
 2 x circspline-spline
 2 x circspline-motor-mount
 2 x flexspline
 2 x wave-rotor
 4 x mendel-rod-clamp (from Prusa 2, not included here)
 1 x mendel-coupling (from Prusa 2, the Z rod to motor coupling, not included)

 Everything else except the flexsplines should print fine with 0.25 or 0.3 mm
 layer height. The flexspline should be printed with 0.2 layer height, 2.0
 W/T parameter, one perimeter, no extra perimeters. Retract minimum length
 should be set to 1 mm to force retraction when infilling the teeth. Slic3r
 normally does full infill for the teeth regardless of the infill solidity,
 this is fine.

2. Assemble the arms.
  2.1. Left arm, middle joint, from top down: M8x50 bolt, washer, 608
       bearing, arm11, 608 bearing, washer, arm21, washer, locking nut.
  2.2. Right arm, middle joint, from top down: M8x50 bolt, washer, arm22,
       washer, 608 bearing, arm12, 608 bearing, washer, locking nut.
  2.3. Final (end effector) joint, three times: M4x20 hex key bolt, 
       arm21, 4xwasher, 624 bearing, washer, nut. The 624 bearings should
       run smoothly in the groove of the arm22.

3. Mount arms onto the z-carriage.
  3.1. For each: M8x50 bolt, washer, 608 bearing, flexspline, arm11 or arm12,
       608 bearing, washer, z-carriage, washer, locking nut.

4. Tighten the nuts so that there is no play but the arms move without effort.

5. Insert six M4 nuts in the nut traps of the z-carriage.

6. Place the circsplines on top of the z-carriage (may require some fiddling
   or forcing into place) and check that they mesh with the flexsplines.

7. Mount NEMA17 motors in the motor mounts using M3x8 conical head (sunken)
   screws.

8. Assemble wave drivers. In each end: M4x20 bolt, washer, wave-driver,
   washer, 624 bearing, washer, wave-driver other screw hole, washer,
   locking nut. The wave driver length is critical. The included STLs
   have 52.75 mm total outside dimension. This should work fine at least
   initially. When the drives have been run for some time, wave drivers
   with larger dimensions may be needed (in 0.25 mm increments) to get
   rid of backlash. The drivers are for motors with 20 mm shafts with
   double flats. Other types of motors may need redesigned drivers.

9. Assemble the motor mounts into the z-carriage, 6xM4x20 bolts and washers
   are needed. The wave drivers should insert nicely into the flexsplines
   when the motors are rotated a bit by hand when inserting them.

10. Insert 4xLM8UU linear bearings into the z-carriage, use M3x20 screws
    and nuts for each.

11. Construct the frame. Anything L-shaped and at least 80 mm wide will do.
    Just mount the z-end parts with M8 bolts. If the L-part is sufficiently
    supported, the z-end-support part may be omitted. The height can be
    freely chosen.

12. Mount the 8 mm smooth rods with the bar clamps and M3x24 bolts, nuts
    and washers. Place the z-carriage at the same time and check that it
    travels freely on the rods.

13. Insert a M8 nut into the z-carriage and screw in a M8 threaded rod
    for the Z travel.

14. Mount the Z motor with M3x8 sunken head screws and attach it to the
    M8 threaded rod with the coupling.

15. Place the print bed in the frame. The print area is 200x120, with the
    nearest Y position being 82 mm from the centerline of the arm base
    joints.

16. Mount the extruder. The arms will accept a groove mount extruder
    with small diameter. Tested with J-Head Mk V-b. The mounting bolts
    have the standard 50 mm pattern. (M4 bolts)

17. Do the electrical connections and upload the Marlin SCARA firmware.

18. The printer should now be ready for use.
