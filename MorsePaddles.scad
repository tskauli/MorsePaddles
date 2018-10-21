/*

           >>> COMPACT 3D-PRINTED PADDLES <<<


    Torbjørn Skauli, LA4ZCA (tskauli@gmail.com)

                  v1.0, July 2018


Iambic paddles designed for 3D-printing. The design is simple, but provides precise movement with adjustable force and travel. Design features include a printed rocker hinge, force adjustment by a sliding spring, travel adjustment using a modified screw, ergonomic grip and general simplicity and precision.

Materials:
- 3 printed parts
- 2 screws M3x5mm, cylinder head, with washers for adjustment if needed
- 1 screw M4x25mm, cylinder head, with washer and nut
- Compression spring, 6-8 mm in diameter
- Compression spring, 4-5 mm in diameter
- Cable with plug as required, up to 3.5 mm diameter
Note: Dimensions of screws, springs and cable can be changed in the code.

Assembly:

- First, prepare the 3D-printed parts by removing support material in the arm spring well and in the ends of the cable holes. Also remove any protuding edges and bumps by gently filing the surfaces.

- Place the large spring so that it is held between the paddles approximately in the middle of the spring well. Also place the small spring in the holes at the hinge. Temporarily slide the two paddles in place. Check the spring force on the paddles and adjust as desired by either moving the spring along the well or by bending the spring to change its length. Make sure that the small spring keeps the arms in place at the hinges during use.

- Remove 6-8 cm of the outer isolation (if present) of the cable and 1 cm of the inner isolation of each wire. Insert the cable from the back through the diagonal hole, and temporarily pull it out from the side "window". Insert the cable back into the other hole and press the cable bend into the window so that the outer isolation ends in the interior wiring well. This forms a strain relief.

- Prepare a 25 mm (XXcheck) M4 screw with cylindrical head by grinding the outer 10 mm to flatten two opposing sides. Preferably align the flattened screw end with the slot in the screw head.

- Enter two M3 screws with cylindrical heads into the paddle arms, with the heads facing inwards. Clamp the dot and dash wire ends under these screw heads.

- Enter the M4 screw from the bottom and clamp the ground wire underneath the washer. Tighten the screw firmly, while allowing a small amount of adjustment of the screw angle to set the travel distance.

- Place the spring between the paddles and slide them in place. Adjust travel by rotating the M4 screw. If the travel is asymmetric, it may be necessary to correct the difference by placing a washer under the head of one of the M3 screws in the paddle arms.


TODO
-conventional knob shape as option
-check spring slider diameter
-consider changing contact and/or spring arrangement to have side-accessible adjustment screws for travel and/or tension, with potential for smaller size
-keep in mind the possibility to replace wedge hinges with a vertical screw hinge, common to both arms

*/

//**************** main parameters of the design
wxbase=30;      // overall width, sets arm thickness etc.
lybase=40;      // length excl. knobs
hzbase=10;      // height of base under arms
dfinger=25;     // approx diameter of finger for curved knob
rround=1;       // radius of rounded edges on knob
hzarm=20;       // height of main part of arm
wallt=2;        // wall thikckness
wallmin=2;      // min wall thickness under cable holes

txknobmin=3;    // min. thickness of knob
yhinge=6.5;       // y position of hinge relative to back
dxwedge=4;      // height of hinge wedge
ahinginn=50;    // angles for inner and outer part of hinges
ahingout=80;
armsep=1.5;     // arm separation from all walls
dyarmrests=2;   // y width of resting and bounding surfaces for arms

minstroke=0.5;  // minimum stroke length (at full dia of center screw)
dstopper=1.5;   // diameter of stopper on top of hinge that keeps arm down
gap=0.1;        // gap for loose fit


//**************** parameters for non-printed parts
dscrew1=4;      // screw dia, also scales screw head height
dscrew2=3;      // screw dia, also scales screw head height
hscrhrel=2/3;   // screw head height and diam rel to diameter
dscrhrel=7/4;
dcable=4;       // cable diameter
dspring=9.5;    // spring diameter
dhingespring=5; // diameter of spring keeping hinge in place

//**************** parameters for rendering
cacc=4;         // accuracy of circles, multiplier for $fn. Use cacc=1 for dev/debug, =2-4 for final.
preview=0;      // =0 for print layout, =1 or =2 for 1- or 2-arm assembly preview, =3 for base only =4 for arms print layout
tol=0.025;      // general tolerance


hzwall=hzarm+armsep;                        // total height of walls
ycontact=lybase-1*dscrew1;                  // position of contact screw

wxarm=wxbase/2-wallt-armsep-hscrhrel*dscrew2-minstroke-dscrew1/2; // arm thickness is the remaining space after removing many contributions to total width
echo("Max length of contact screws in arms (mm):",wxarm);
echo("Min length of contact screw in base (mm):",hzbase-hscrhrel*dscrew1+armsep+hzarm/2+dscrew2*dscrhrel/2);
echo("Min length to flatten contact screw in base (mm):",dscrew2*dscrhrel);
wxknob=wxarm+wallt+armsep+hscrhrel*dscrew2;
dxknob=hscrhrel*dscrew2;                    // x offset toward center rel to main arm
hzknob=hzarm;                               // height of knobs
lyarm=lybase-wallt-armsep/2;                // knob spaced armsep/2 from base front

y0sprwell=yhinge-wallt-armsep+dxwedge*tan(ahingout/2);        // starting pos of spring channel
sprfloort=wallt;                            // thickness of floor underneath spring
sprlen=wxbase-2*(wallt+armsep+sprfloort);   // length of spring

dxtip=wxbase/4;                             // diameter of rounded tip with attachment hole
dytip=(wxbase-dxtip)/2;                     // length of tip ex rouned part
rtip=dxtip*sqrt(2)/2;                       // radius of tip
ycentip=lybase+dytip-rtip/sqrt(2);          // center of rounded tip

module teardropHole(lh,rh){ // Hole with 45-degree teardrop shape
    rotate([90,0,0])
    rotate([0,0,45])
    union(){
        cylinder(h=lh,r1=rh,r2=rh,$fn=8*cacc);
        cube([rh,rh,lh]);
    };
};
module wedge(a,wx,hz){ // Triangular block with right angle top
    linear_extrude(height=hz)
    polygon([[0,0],[wx,wx*tan(a/2)],[wx,-wx*tan(a/2)]]);
};
module cone45(dc){ // cone for stopper that keeps arm down, 45-degree slope
    rotate([180,0,0])
    cylinder(d1=dc,d2=0,h=dc*0.75,$fn=8*cacc);
};
module wedge_hinge(){    //wedge on wall for hinge, with cutout so that arm rests on top and bottom
    // cutout for stopper cone
    translate([0,0,hzwall])
    cone45(dstopper);
    // wedge with cutout, centered on the edge between cone and armrest,
    // to make arm better supported against up-down tilt
    difference(){
        wedge(a=ahinginn,wx=dxwedge,hz=hzwall);
        translate([-hzarm/2/sqrt(2),hzarm/2,hzarm/2+armsep-dstopper*0.75/2])
        rotate([90,0,0])
        cylinder(h=hzarm,d=hzarm,$fn=12*cacc);
    };
};
module base_add(){ // parts of base that add to shape
    // base plate
    translate([-wxbase/2,0,0])
    cube([wxbase,lybase,hzbase]);
    
    //tapered front
    dxtip=wxbase/4; // diameter of rounded tip with attachment hole
    dytip=(wxbase-dxtip)/2;
    rtip=dxtip*sqrt(2)/2;
    ycentip=lybase+dytip-rtip/sqrt(2);
    linear_extrude(height=hzbase)
    polygon([[-wxbase/2,lybase],[-dxtip/2,lybase+dytip],[dxtip/2,lybase+dytip],[wxbase/2,lybase]]);
    
    // rounded tip
    translate([0,ycentip,0])
    cylinder(r=rtip,h=hzbase,$fn=10*cacc);

    // walls
    translate([0,0,hzbase])
    difference(){
        translate([-wxbase/2,0,0])
        cube([wxbase,lybase,hzwall]);
        translate([-wxbase/2+wallt,wallt,0])
        cube([wxbase-2*wallt,lybase,hzwall]);
    }
    
    //wedge 1
    translate([wxbase/2-wallt-dxwedge,yhinge,hzbase])
    wedge_hinge();
    //wedge 2
    translate([-(wxbase/2-wallt-dxwedge),yhinge,hzbase])
    rotate([0,0,180])
    wedge_hinge();
    
    // bottom arm resting surface, height armsep above base top
    translate([0,yhinge,hzbase])
    cube([wxbase-2*wallt-2*dxwedge-2,dyarmrests,2*armsep],center=true);
    
    // front arm lower resting surface, normally with 2*gap airgap
    translate([-wxbase/2,lybase-dyarmrests,hzbase])
    cube([(wxbase-2*dscrew1)/2,dyarmrests,armsep-2*gap]);
    translate([wxbase/2,lybase,hzbase])
    rotate([0,0,180])
    cube([(wxbase-2*dscrew1)/2,dyarmrests,armsep-2*gap]);
    
    // outer end stops, 2mm wide
    translate([-(wxbase/2-wallt),lybase-dyarmrests,hzbase])
    cube([armsep,dyarmrests,hzwall]);
    translate([(wxbase/2-wallt)-armsep,lybase-dyarmrests,hzbase])
    cube([armsep,dyarmrests,hzwall]);
    
    // extra height for center screw stability
    translate([0,ycontact,hzbase])
    cylinder(d=dscrew1*dscrhrel*1.5,h=dscrew1/2,$fn=8*cacc);
    

};
module base_sub(){  // parts of base that cut away from shape
    
    // center contact screw hole with recess (20% enlarged)
    translate([0,ycontact,0])
    cylinder(d=dscrew1,h=hzbase*9,$fn=8*cacc);
    translate([0,ycontact,0])
    cylinder(d=dscrew1*dscrhrel*1.2,h=dscrew1*hscrhrel*1.2,$fn=8*cacc);
    
    // Front mounting screw hole with recess
    translate([0,ycentip,0])
    cylinder(d=dscrew1+gap,h=hzbase,$fn=8*cacc);
    translate([0,ycentip,wallt])
    cylinder(d=dscrew1*dscrhrel*1.2,h=hzbase,$fn=8*cacc);
    
    //cable holes
    translate([wxbase/2-dcable/4,(ycontact-2*dscrew1)/2,dcable/2+wallmin]){
        // cable hole 1
        rotate([0,0,-45])
        teardropHole(lh=wxbase*2,rh=dcable/2);
        // cable hole 2
        rotate([0,0,-45-90])
        teardropHole(lh=wxbase/sqrt(2),rh=dcable/2);
        //cable access opening
        cube([dcable,2*dcable,dcable],center=true);
        };

    // wire well
    wellw=wxbase/2; // wire well width and length
    translate([wellw/2,ycontact-2*dscrew1,wallt])
    rotate([0,0,180])
    cube([wellw,wellw,hzbase]);

    // Back mounting screw hole in well
    translate([0,ycontact-2*dscrew1-wellw/2,0])
    cylinder(d=dscrew1+gap,h=hzbase,$fn=8*cacc);
    
};
module base(){ // complete base part
    difference(){
        base_add();
        base_sub();
    };
};

module arm_add(){  // arm base shape, without knob
    
    // main arm
    cube([wxarm,lyarm,hzarm]);
    
    // extra material for supporting hinge spring
    translate([-dxknob,0,0])
    cube([dxknob,y0sprwell,hzarm]);
    
};
module arm_sub(){  // arm shaping
    // hinge groove
    translate([wxarm-dxwedge+armsep,yhinge-wallt-armsep,0])
    wedge(a=ahingout,wx=dxwedge,hz=hzarm);
    
    // hinge stopper cutout
    translate([wxarm-dxwedge+armsep,yhinge-wallt-armsep,hzarm])
    cone45(dstopper+2*gap);
    
    // tension spring channel
    translate([0,y0sprwell,(hzarm-dspring)/2])
    cube([wxarm-sprfloort,ycontact-y0sprwell-3*dscrew1,dspring]);
    
    // contact screw hole
    translate([-tol,ycontact-wallt-armsep,hzarm/2])
    rotate([0,0,90])
    teardropHole(lh=wxarm*2,rh=dscrew2/2-gap);

    // hole for spring keeping hinge in place
    translate([-dxknob-tol,yhinge-wallt-armsep,hzarm/2])
    rotate([0,0,90])
    teardropHole(lh=dxknob+wxarm-dxwedge+armsep-sprfloort+tol,rh=dhingespring/2);

    // space for center screw nut etc.
    translate([0,ycontact-wallt-armsep,0])
    rotate([0,45,0])
    cube([20,dscrew1*3,dscrew1*2],center=true);
    };
    
module knob_old(){ // old knob, without rounding
    
    difference(){

        // knob, to be shaped by subtraction
        translate([-dxknob,lyarm,0])
        cube([wxknob,dfinger,hzknob]);
        
      // shaping of knob
        translate([-dxknob+txknobmin+dfinger/2,lyarm+wallt+dfinger/2,dfinger/2+wallt])
        minkowski(){
            cube([tol,wxbase,wxbase]);
            sphere(r=dfinger/2,$fn=8*cacc);
        };
    };

};
module knob_curved(){ // finger-curved and rounded knob
    intersection(){ // cutting to outer shape
        minkowski(){ // rounding of edges
            
            // un-rounded knob shrunk by rounding radius
            difference(){ // shaping finger rest

                // knob, to be shaped by subtraction
                translate([-dxknob,lyarm,0])
                cube([wxknob-rround,dfinger-rround,hzknob-rround]);
                
              // shaping of knob
                translate([-dxknob+txknobmin+dfinger/2,lyarm+wallt+dfinger/2,dfinger/2+wallt])
                minkowski(){
                    cube([tol,wxbase,wxbase]);
                    sphere(r=dfinger/2,$fn=8*cacc);
                };
            };
            // rounding sphere
            sphere(r=rround,$fn=cacc*4);
        };
        // outer bound of knob
        translate([-dxknob,lyarm,0])
        cube([wxknob,dfinger,hzknob]);
    };

};
module arm(){ // Generate final shape according to preview and cacc settings
    difference(){
        union(){
            knob_curved();
            arm_add();
        };
        arm_sub();
    };
};
module springsupport1(){ // supporting peg inside spring (creates asymmetry in paddle force, needs revision)
    cylinder(d =dspring-gap,h=0.8,$fn=10*cacc);
    cylinder(d=dspring-4,h=sprlen-minstroke-dscrew1/2,$fn=10*cacc);
};
module build_all(){
    
    if(preview==1){
        base();
        translate([wxbase/2-wallt-armsep-wxarm,wallt+armsep,hzbase+armsep])
        arm();
    }
    else if (preview==2){
        base();
        translate([wxbase/2-wallt-armsep-wxarm,wallt+armsep,hzbase+armsep])
        arm();

        translate([-(wxbase/2-wallt-armsep-wxarm),wallt+armsep,hzbase+armsep])
        scale([-1,1,1])
        arm();
    }
    else if (preview==3){
        base();
    }
    else if (preview==4){
        translate([wxbase/2+wxknob+1,0,0])
        scale([-1,1,1])
        arm();
        
        translate([wxbase/2+2*wxknob+2,0,0])
        arm();
    }
    else{
        base();
        translate([wxbase/2+wxknob+1,0,0])
        scale([-1,1,1])
        arm();
        
        translate([wxbase/2+2*wxknob+2,0,0])
        arm();
        
//        translate([-wxbase,lybase+dspring,0])
//        springsupport1();
    };
};
build_all();


