module teardrop (r=4.5,h=20,alpha=45,teardropcorner=0,fulldrop=false){		// tear drop hole for top-centering
											// use teardropcorner=1 for bottom horizontal corners
	render()
	translate([-h/2,0,0])
		rotate([-270,0+(teardropcorner*180),90])
			difference(){
				linear_extrude(height=h){
					circle(r, $fn=24);
					polygon(points=[[0,0],[r*cos(alpha),r*sin(alpha)],[0,r/sin(alpha)],[-r*cos(alpha),r*sin(alpha)]], paths=[[0,1,2,3]]);
				}
				if(fulldrop==false) 
					translate([0,(r/sin(alpha))/2+r,h/2]) cube([2*r+2,r/sin(alpha),h+2],center=true);
			}
}

//teardrop(4.5,22,fulldrop=true);



module teardropcentering (r=4.5,h=20,alpha=45){				// tear drop hole for top-centering
	centering_offset_factor = 1.1;
	render()
	translate([-h/2,0,0])
		rotate([-270,0,90])
			difference(){
				linear_extrude(height=h){
					circle(r, $fn=24);
					polygon(points=[[0,0],[r*cos(alpha),r*sin(alpha)],[0,r/sin(alpha)],[-r*cos(alpha),r*sin(alpha)]], paths=[[0,1,2,3]]);
				}
				translate([0,(r/sin(alpha))/2+r*centering_offset_factor,h/2]) cube([2*r+2,r/sin(alpha),h+2],center=true);
			}
}

//teardropcentering();



module teardropcentering_half (r=4.5,h=20, bottom=0,alpha=45){				// tear drop hole for top-centering
																// upper half (bottom=0) or bottom half (bottom=1)
	centering_offset_factor = 1.2;
	render()
	translate([-h/2,0,0])
		rotate([-270,0,90])
			difference(){
				linear_extrude(height=h){
					circle(r, $fn=24);
					polygon(points=[[0,0],[r*cos(alpha),r*sin(alpha)],[0,r/sin(alpha)],[-r*cos(alpha),r*sin(alpha)]], paths=[[0,1,2,3]]);
				}
				translate([0,(r/sin(alpha))/2+r*centering_offset_factor,h/2]) cube([2*r+2,r/sin(alpha),h+2],center=true);
				translate([0,-(r*centering_offset_factor)/2-0.5+bottom*(r*centering_offset_factor+1),h/2]) cube([2*r+2,r*centering_offset_factor+1,h+2],center=true);
			}
}

//teardropcentering_half(bottom=0);


module polyhole(d,h){
	n = max(round(2 * d),3);
	cylinder(h = h, r = (d / 2) / cos (180 / n), $fn = n, center=true);
}



module roundcorner(radius,edge_length){
	render()
	translate([0,0,-1])
		difference(){
			translate([-1,-1,0]) cube(size = [radius+1,radius+1,edge_length+2], center = false);
			translate(v = [radius,radius,-1]) cylinder(h = edge_length+4, r=radius, center=false);
		}
}

//roundcorner(5,5);



module roundcorner_tear(radius,edge_length){
	render()
	difference(){
		translate([-1,-1,-1]) cube(size = [edge_length+2, radius+1, radius+1], center = false);
		translate([(edge_length+4)/2-2, radius, radius])
			teardrop(radius, edge_length+4,teardropcorner=1);
	}
}

//roundcorner_tear(8,20);



module nut_trap(nut_wrench_size,trap_height,vertical=true, clearance=0.2){		// M3 wrench size = 5.5
	cornerdiameter =  (((nut_wrench_size)/2)+clearance) / cos(180/6);
	rotate([0,vertical*90,0])
		cylinder(h = trap_height, r = cornerdiameter, center=true, $fn = 6);
}



module nut_slot(nut_wrench_size,nut_height, nut_elevation,vertical=false, clearance=0.2){		// M3 wrench size = 5.5
	cornerdiameter =  (((nut_wrench_size)/2)+clearance) / cos(180/6);
	slot_height = nut_height+2*clearance;
	slot_width = nut_wrench_size+2*clearance;
	rotate([0,vertical*270,0]){
		cylinder(h = slot_height, r = cornerdiameter, center=true, $fn = 6);
		translate([0,-slot_width/2,-slot_height/2]) cube([nut_elevation+1,slot_width,slot_height]);
	}
}

//nut_slot(5.5,3,4,1);



module barbell (x1,x2,r1,r2,r3,r4) 
{
	x3=triangulate (x1,x2,r1+r3,r2+r3);
	x4=triangulate (x2,x1,r2+r4,r1+r4);
	render()
	difference ()
	{
		union()
		{
			translate(x1)
			circle (r=r1);
			translate(x2)
			circle(r=r2);
			polygon (points=[x1,x3,x2,x4]);
		}
		
		translate(x3)
		circle(r=r3,$fa=5);
		translate(x4)
		circle(r=r4,$fa=5);
	}
}

function triangulate (point1, point2, length1, length2) = 
point1 + 
length1*rotated(
atan2(point2[1]-point1[1],point2[0]-point1[0])+
angle(distance(point1,point2),length1,length2));

function distance(point1,point2)=
sqrt((point1[0]-point2[0])*(point1[0]-point2[0])+
(point1[1]-point2[1])*(point1[1]-point2[1]));

function angle(a,b,c) = acos((a*a+b*b-c*c)/(2*a*b)); 

function rotated(a)=[cos(a),sin(a),0];