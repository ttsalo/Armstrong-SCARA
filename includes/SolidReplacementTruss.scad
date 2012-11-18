// Truss body w/rounded edges 
module round_rect( x, y, z, radius) // Rounds vertical/z axis edges
{
	linear_extrude(height=z,center=false, convexity=1, twist=0)
	{
		translate([radius,radius,0])
		minkowski()
		{
			square([x-2*radius,y-2*radius]);
			
			circle(radius, $fn = 20);
		}
	}
}

module arb_round_tri (x1, y1, x2, y2, x3, y3, radius, depth)
{
// Take an arbitrary triangle and radius the corners:
//
//		       C
//		       /\
//		 b  /    \  a
//		   /        \
//		 /______\
//	        A       c       B
//
// Point A = [x1,y1], Point C = [x2,y2], Point B = [x3,y3]
// Angle A = alpha, angle B = beta, angle C = gamma
//
// 1. Find angles of each corner of the triangle.
// 1a. Find distances between each set of two points.
	a = pow(pow(abs(x3-x2),2) + pow(abs(y3-y2),2),1/2);
	b = pow(pow(abs(x2-x1),2) + pow(abs(y2-y1),2),1/2);
	c = pow(pow(abs(x3-x1),2) + pow(abs(y3-y1),2),1/2);

	//echo(A = a, B = b, C = c);

// 1b. Use the law of cosines to find the angles.
	alpha = acos((pow(b,2) + pow(c,2) - pow(a,2))/(2*b*c));
	beta = acos((pow(a,2) + pow(c,2) - pow(b,2))/(2*a*c));
	gamma = acos((pow(a,2) + pow(b,2) - pow(c,2))/(2*a*b));
	
	//echo(Alpha = alpha, Beta = beta, Gamma = gamma);

// 2. Calculate the distance to the radii centers
// 2a. Bisect the angles, use a right triangle with the radius as one leg, the hyp. is the distance to center.
//
//		     90
//		      /\
//		    /    \ radius
//		  /        \
//		/______\
//	   A/2	     hyp     Center
//

	//echo( Radius = radius, Alpha_2 = alpha/2, SinAlpha_2 = sin(alpha/2) );
	
	a_hyp = radius/sin(alpha/2);
	b_hyp = radius/sin(beta/2);
	c_hyp = radius/sin(gamma/2);

	//echo(A_hyp = a_hyp, B_hyp = b_hyp, C_hyp = c_hyp);

// 3. Turn the slopes and distances to centers into x and y components.
// 3a. Find the angle the slope of each side makes with the x axis
	phi_a_1 = atan2( ( y2 - y1 ) , ( x2 - x1 ) );
	phi_a_2 = atan2( ( y3 - y1 ) , ( x3 - x1 ) );
	phi_a = ( phi_a_1 + phi_a_2 ) / 2 + ( ( abs( phi_a_1 - phi_a_2 ) < 180 ) ? 0 : 180 );
	phi_b_1 = atan2( ( y1 - y3 ) , ( x1 - x3 ) );
	phi_b_2 = atan2( ( y2 - y3 ) , ( x2 - x3 ) );
	phi_b = ( phi_b_1 + phi_b_2 ) / 2 + ( ( abs( phi_b_1 - phi_b_2 ) < 180 ) ? 0 : 180 );
	phi_c_1 = atan2( ( y1 - y2 ) , ( x1 - x2 ) );
	phi_c_2 = atan2( ( y3 - y2 ) , ( x3 - x2 ) );
	phi_c = ( phi_c_1 + phi_c_2 ) / 2 + ( ( abs( phi_c_1 - phi_c_2 ) < 180 ) ? 0 : -180 );
	
	//echo(		Phi_A_1 = phi_a_1, Phi_A_2 = phi_a_2,
	//		Phi_B_1 = phi_b_1, Phi_B_2 = phi_b_2,
	//		Phi_C_1 = phi_c_1, Phi_C_2 = phi_c_2);
	//echo(Phi_A = phi_a, Phi_B = phi_b, Phi_C = phi_c);
	
	a_dist_x = a_hyp * cos(phi_a);
	a_dist_y = a_hyp * sin(phi_a);
	b_dist_x = b_hyp * cos(phi_b);
	b_dist_y = b_hyp * sin(phi_b);
	c_dist_x = c_hyp * cos(phi_c);
	c_dist_y = c_hyp * sin(phi_c);
	//echo(	A_dist_x = a_dist_x, A_y = a_dist_y,
	//		B_dist_x = b_dist_x, B_dist_y = b_dist_y,
	//		C_dist_x = c_dist_x, C_dist_y = c_dist_y);
// 4. Add these components to original point coordinates to get new triangle points.
	a_x = x1 + a_dist_x;
	a_y = y1 + a_dist_y;
	b_x = x3 + b_dist_x;
	b_y = y3 + b_dist_y;
	c_x = x2 + c_dist_x;
	c_y = y2 + c_dist_y;
// 5. Create new triangle and add rounds
	linear_extrude(height=depth,center=false, convexity=1, twist=0)
	minkowski()
	{
		polygon(points=[[a_x,a_y],[b_x,b_y],[c_x,c_y]],
				paths=[[0,2,1]]);
		circle(radius, $fn = 20);
	}
}

// Cut a truss into a solid block.  Is this simpler geometry than creating one from unions?
module solid_truss(length, height, thickness, element_width, radius ) // length = x axis, height = y axis, thickness = z axis, element_width = width of struts
{
	// Calculated values
	segments = 2 * floor( length / height );
	segment_y = height - 2 * element_width;

	new_length = length - 2 * element_width;
	segment_x = new_length / ( segments + 1 );
	segment_spacing = element_width / sin( atan( segment_y / segment_x ) );
	new_segment_x = segment_x - segment_spacing;
	
	//echo(Segments = segments, Segment_X = segment_x, Segment_Y = segment_y, New_Segment_X = new_segment_x );

	difference()
	{
		// Truss Body
		// Rounded corners (in z axis)
		//round_rect( length, height, thickness, element_width);
		// Standard corners
		cube( size = [ length, height, thickness ] );	

		//echo(		X1 = element_width,					Y1 = element_width,
		//			X2 = element_width,					Y2 = segment_y + element_width,
		//			X3 = element_width + new_segment_x,		Y3 = segment_y + element_width,
		//			Radius = radius,	Depth = thickness );
		
		// Corner Cuts
		arb_round_tri(	x1 = element_width,					y1 = element_width,
					x2 = element_width,					y2 = segment_y + element_width,
					x3 = element_width + new_segment_x,		y3 = segment_y + element_width,
					radius = radius,	depth = thickness );
		
		arb_round_tri(	x1 = length - element_width,					y1 = element_width,
					x2 = length - element_width,					y2 = segment_y + element_width,
					x3 = length - ( element_width + new_segment_x ),	y3 = element_width,
					radius = radius,	depth = thickness );
		
		// Inside Cuts
		if( segments > 0)
		for( i = [1 : segments ])
		{
			translate( [ element_width, element_width, 0 ] )
			arb_round_tri(	x1 = i * segment_spacing  + ( i - 1 ) * new_segment_x,
						y1 = segment_y * ( 1 + pow( -1, i ) ) / 2,
						x2 = i * segment_spacing + i * new_segment_x,
						y2 = segment_y * ( 1 + pow( -1, i + 1 ) ) / 2,
						x3 = i * segment_spacing + ( i + 1 ) * new_segment_x,
						y3 = segment_y * ( 1 + pow( -1, i) ) / 2,
						radius = radius,	depth = thickness );
		}
	}
}

// Create a 3-D truss with an equilateral cross section: Height is defined by width ( height = width * sqrt(3) / 2 )
 // Length = X axis, Width = Y axis, Thickness = truss extrusion thickness, element_width = width of struts
module eql_truss(length, width, thickness, element_width)  // Length = X axis, Width = Y axis, Height = Diameter = element diameter
{
	translate( [ 0, thickness/2, thickness/2 ] )
	union()
	{
		translate( [ 0, -thickness/2, -thickness/2 ] )
		solid_truss( length, width, thickness, element_width, radius );

		translate( [ 0, ( width - thickness )/2, ( width - thickness )/2 * sqrt(3) ] )
		rotate( a = [ 60+180, 0, 0  ] ) // , v = [ length/2, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
		translate( [ 0, -thickness/2, -thickness/2 ] )
		solid_truss( length, width, thickness, element_width, radius );
	
		translate( [ 0, width - thickness, 0 ] )
		rotate( a = [ 120, 0, 0 ] ) // , v = [ 0, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
		translate( [ 0, -thickness/2, -thickness/2 ] )
		solid_truss( length, width, thickness, element_width, radius );
	}
}

// Create a 3-D truss with an isoceles cross section: Allows defining a length, width, and height, with both non-bottom sides symmetrical
 // Length = X axis, Width = Y axis, Height = Z axis, Thickness = truss extrusion thickness, element_width = width of struts
module isoc_truss( length, width, height, thickness, element_width, radius )
{
	// "left" and "right" sides are left and right in the "Right" view (Ctrl-7)
	inside_angle =  atan( ( height ) / ( (width )/2 ) );
	outside_angle = 180 - inside_angle;
	hyp_length = height / sin(inside_angle);

//echo(width, height);

	intersection()
	{
		// Crop all sides equally, and round outside corners
		//translate( [ length, 0, 0 ] )
		//rotate( [ 0, -90, 0 ] )
		//arb_round_tri( 0, 0, height , width/2, 0, width, 0.003, length );
		
		// Crop bottom and corners, leaving sides wider
		cube( size = [ length, width, height ] );
		
		union()
		{
			// Bottom Piece
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, width, thickness, element_width, radius);

			// Left Side (On the left in the "Right" view)
			translate( [ 0, ( width )/2, height ] )
			rotate( a = [ inside_angle + 180, 0, 0  ] ) // , v = [ length/2, radius, radius ] ) // Seems to ignore v = [...] parameter?
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, hyp_length, thickness, element_width, radius);
		
			// Right Side (On the right in the "Right" view)
			translate( [ 0, width, 0 ] )
			rotate( a = [ outside_angle, 0, 0 ] ) // , v = [ 0, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, hyp_length, thickness, element_width, radius );

			// Inside rounds
			difference()
			{
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, -element_width ] )
				arb_round_tri( 0, 0, height, width/2, 0, width, radius, element_width);
				
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, -element_width ] )
				arb_round_tri(	thickness, thickness,
							height - thickness, width/2,
							thickness, width-thickness,
							radius, element_width );
			}
			
			difference()
			{
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, - length] )
				arb_round_tri( 0, 0, height, width/2, 0, width, radius, element_width);
				
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, - length ] )
				arb_round_tri(	thickness, thickness,
							height - thickness, width/2,
							thickness, width-thickness,
							radius, element_width );
			}
		}
	}
}

// Create a 3-D truss with a right triangle cross section ( corner is along X axis, bottom is in X-Y plane, vertical is in X-Z plane )
 // Length = X axis, Width = Y axis, Height = Z axis, Thickness = truss extrusion thickness, element_width = width of struts
module corner_truss(length, width, height, thickness, element_width)
{
	bottom_angle = atan( height / width );
	hyp_length = height / sin(bottom_angle);
	//translate( [ 0, thickness/2, thickness/2 ] )

	intersection()
	{
		// Crop all sides equally, and round outside corners
		//translate( [ length, 0, 0 ] )
		//rotate( [ 0, -90, 0 ] )
		//arb_round_tri( 0, 0, height, 0, 0, width, 0.003, length );
		
		// Crop bottom, vertical side, and corners, leaving diagonal side wider
		cube( size = [ length, width, height ] );
		
		union()
		{
			// Bottom Piece
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, width, thickness, element_width, radius );
			
			// Vertical Piece
			translate( [ 0, 0, height ] )
			rotate( a = [ -90, 0, 0 ] ) // , v = [ 0, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, height, thickness, element_width, radius );
	
			 // Hypotenuse Piece
			translate( [ 0, width, 0 ] )
			rotate( a = [ 180 - bottom_angle, 0, 0 ] ) // , v = [ 0, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
			translate( [ 0, 0, -thickness/2 ] )
			solid_truss( length, hyp_length, thickness, element_width, radius );
			
			// Inside rounds
			difference()
			{
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, -element_width ] )
				arb_round_tri( 0, 0, height, 0, 0, width, radius, element_width);
				
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, -element_width ] )
				arb_round_tri(	element_width, element_width,
							height - thickness, element_width,
							element_width, width - thickness,
							radius, element_width );
			}
			
			difference()
			{
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, - length] )
				arb_round_tri( 0, 0, height, 0, 0, width, radius, element_width);
				
				rotate( [ 0, -90, 0 ] )
				translate( [ 0, 0, - length ] )
				arb_round_tri(	element_width, element_width,
							height - thickness, element_width,
							element_width, width - thickness,
							radius, element_width );
			}
		}
	}
}

// Combine 3-D trusses to achieve a box shape, with a given width with multiple segments instead of a single wide truss with corners
 // Length = X axis, Width = Y axis, Height = Z axis, Thickness = truss extrusion thickness, element_width = width of struts
module truss_platform(length, width, height, thickness, element_width, radius)
{
	// height = width/2*sqrt(3) -> new width = height * 2 / sqrt(3)
	segments = 2 * floor(width/height);
	seg_width = width/(segments + 1);

	//echo( Segments = segments );

	union()
	{	
		// Left corner truss (viewed in "Right" view)
		translate( [ length, 0, height ] )
		rotate( [ 0, 180, 0] )
		corner_truss( length, seg_width, height, thickness, element_width, radius );
		
		// Right corner truss (as seen from "Right" view)
		translate( [ length, width, 0 ] )
		rotate( [ 0, 0, 180 ] )
		corner_truss( length, seg_width, height, thickness, element_width, radius);
		
		if( segments > 0 )
		 for( i = [ 1 : segments ] )
		{
			translate( [ 0, ( seg_width ) * ( i - 1 ) + 2 * seg_width * ( 1 + pow( -1, i ) ) / 2, ( height ) * (1 + pow( -1, i ) ) / 2  ] )
			{
				rotate( a = [ 180 * (1 + pow( -1, i ) )/2, 0, 0 ] ) // , v = [ 0, diameter/2, diameter/2 ] ) // Seems to ignore v = [...] parameter?
				isoc_truss( length, seg_width*2, height, thickness, element_width, radius );
			}
		}
	}
}

// Creates an interlocking "keyed" attachment point with a triangle shaped key
module tri_key(x, y, z)
{
	linear_extrude( height = z )
	{
		polygon( points = [ [ 0, 0 ], [ x, 0 ], [x/2, y ] ], paths = [ [ 0, 1 , 2] ] );
	}
}

// Creates a triangular ridge that has a sloped face to allow slipping in one direction but not the other. 90 degrees is unsloped, smaller angles are shallower sides
// x = protruding distance ("overlap"), y = ridge height, z = ridge length,
module one_way_ridge(x, y, z)
{
	translate( [ 0, 0, y ] )
	rotate( [ -90, 0, -90 ] )
	linear_extrude( height = z )
	polygon( points = [ [ 0, 0], [ x, 0 ], [ 0, y ] ], paths = [ [ 0, 1, 2 ] ] );
}

// Mounting block with a "key" piece, block designed to constrain it from sliding vertically
module male_key_block( x, y, z, key_x, key_y, key_z )
{
	// Parameters  may need to be experimented with, especially if printed on different scales
	// If experimenting, remember to modify the corresponding female connector

	// Base thickness is the size of the block stabilizing both one end of the key, and the slot for the corresponding base on the female connector
	base_thickness = (z - key_z)/2;
	y_overlap = y / 3;
	
	lock_height = 1;
	lock_overlap = 0.5;	

	union()
	{
		// Key
		translate( [ (x - key_x)/2, 0, base_thickness ] )
		tri_key( key_x, key_y + y_overlap, key_z );
		
		difference()
		{
			// Base block, stabilizes key
			translate( [ 0, 0, key_z + base_thickness] )
			cube( size = [ x, y, base_thickness ] );
			
			// Cutout for corresponding locking ridge
			translate( [ -0.001, 0 , z ] )
			rotate( [ 180, 0, 0 ] )
			one_way_ridge( lock_overlap, lock_height, x + 0.002);
		}
		
		// Mounting Side Block, union() or superglue to your part
		translate( [ 0, key_y, 0 ] )
		cube( size = [ x, y - key_y, key_z + base_thickness ] );
				
		translate( [ 0, key_y, 0 ] )
		one_way_ridge( lock_overlap, lock_height, x);
	}
}

// Mounting block with a cutout for a matching keyed block, designed to constrain it from sliding vertically
module female_key_block( x, y, z, key_x, key_y, key_z )
{
	// Parameters  may need to be experimented with, especially if printed on different scales
	// If experimenting, remember to modify the corresponding female connector
	
	// Base thickness is the size of the block stabilizing both one end of the key, and the slot for the corresponding base on the female connector
	base_thickness = (z - key_z)/2;	
	
	lock_height = 1;
	lock_overlap = 0.5;

	difference()
	{
		union()
		{
			// Main body, forms base and key slot is cut into
			cube( size = [ x, y, z - base_thickness ] );	
			
			// Block connecting locking ridge to main body
			translate( [ 0, 0, z - base_thickness ] )
			cube( size = [ x, y - key_y, base_thickness ] );

			// Locking ridge
			translate( [ 0, y - key_y , z ] )
			rotate( [ 180, 0, 0 ] )
			one_way_ridge( lock_overlap, lock_height, x);
		}
		
		// Slot for key
		translate( [ ( x - key_x)/2, y - key_y, z - key_z - base_thickness ] )
		tri_key( key_x, y, key_z );
	
		// Cutout for corresponding lock ridge
		translate( [ -0.001, y, 0 ] )
		one_way_ridge( lock_overlap, lock_height, x + 0.002);
	}
}



// Example: "threaded rod" sized truss segment
max_length = 290 / 2;



width = 15;
height = 25;
thickness = 4;
element_width = 3;
radius = 1;

x = height;
y = x * 2/3;
z = width;
key_x = x * 2/3;
key_y = y * 2/3;
key_z =  z * 2/3;
lock_height = 1;

length = max_length - key_y;

fit_factor = 0.003; // To reduce overlap of male/female key shapes

union()
{
	// Truss body
	translate( [ -length/2, height/2, 0 ] )
	rotate( [90, 0, 0 ] )
	truss_platform( length, width, height, thickness, element_width, radius );
	
	// Male Locking connector, Left end of truss in "Right" view
	translate( [ length/2 + key_y , height/2, width ] )
	rotate( [ 0, 180, 90 ] )
	male_key_block( x, y, z, key_x - fit_factor, key_y - fit_factor, key_z - fit_factor);
	
	// Female Locking connector, Right end of truss in "Right" view
	translate( [ - length/2 + (y - key_y), -height/2, 0 ] )
	rotate( [ 0, 0, 90 ] )
	female_key_block( x, y, z, key_x + fit_factor, key_y + fit_factor, key_z + fit_factor);
}


// Dimensional References
//translate([ -max_length/2 + key_y - element_width, -5 - height/2, radius])
//rotate([0, 90, 0])
//cylinder(h = max_length, r = radius);

//translate([ -10, 0, radius])
//rotate([-90, 0, 0])
//cylinder(h = width, r = radius);

//translate([ -10, -10, 0])
//cylinder(h = height, r = radius);

//translate([ - key_y, -20, radius])
//rotate([0, 90, 0])
//cylinder(h = 141.4, r = radius);

// Axial elements for math checking 
//cyl_elem( 0, 0, 0, 50, 0, 0, 5 ); // +X
//cyl_elem( 0, 0, 0, -50, 0, 0, 5 ); // -X
//cyl_elem( 0, 0, 0, 0, 50, 0, 5 ); // +Y
//cyl_elem( 0, 0, 0, 0, -50, 0, 5 ); // -Y
//cyl_elem( 0, 0, 0, 0, 0, 50, 5 ); // +Z
//cyl_elem( 0, 0, 0, 0, 0, -50, 5 ); // -Z

//cyl_elem( 0, 0, 0, 50, 50, 0, 5 ); // +X +Y
//cyl_elem( 0, 0, 0, 50, -50, 0, 5 ); // +X -Y
//cyl_elem( 0, 0, 0, -50, 50, 0, 5 ); // -X +Y
//cyl_elem( 0, 0, 0, -50, -50, 0, 5 ); // -X -Y
//cyl_elem( 0, 0, 0, 50, 50, 50, 5 ); // +XYZ