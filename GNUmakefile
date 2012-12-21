SHELL = /bin/sh

INCLUDES = common.scad configuration.scad

world: flexspline.stl circspline.stl circspline-spline.stl circspline-motor-mount.stl wave-rotor.stl arm11.stl arm12.stl arm21.stl arm22.stl z-carriage.stl z-end-bottom.stl z-end-top.stl z-end-support.stl

%.stl : %.scad $(INCLUDES)
	openscad -o $@ $<

# Extra dependencies
circspline-spline.stl: circspline.scad
circspline-motor-mount.stl: circspline.scad
arm11.stl: arm1.scad
arm12.stl: arm1.scad
arm21.stl: arm2.scad
arm22.stl: arm2.scad

