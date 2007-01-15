# squatswitch.nas version 0.1 by Ron Jensen (GLP 2.0)
# Implement a squat switch by watching left main gear weight on wheels 

gearwowlistener=nil;

GearDownListen = func {
    handle = getprop("controls/gear/gear-handle-down");
    gear   = getprop("controls/gear/gear-down");
    if (gear != handle){
        if(handle==1){
            setprop("controls/gear/gear-down", 1);
            gear=1; #make sure gearwowlistener is removed
        }
        if(handle==0){
            wow=getprop("gear/gear[1]/wow");
            if( wow == 1 ){
                if (gearwowlistener != nil ){ #avoid recursion
                    gearwowlistener  = setlistener("gear/gear[1]/wow", GearWowListen );
                }
            }
            if( wow == 0 ){
                setprop("controls/gear/gear-down", 0);
                gear=0; #make sure gearwowlistener is removed
            }
        }
    }
    if (gear == handle){
        if(gearwowlistener){
            removelister(gearlistener);
            gearwowlistener=nil;
        }
    }
}
 

GearWowListen = func {
    GearDownListen(); # wow has changes so revist squat logic
}
 
init = func {
    setlistener("controls/gear/gear-handle-down", GearDownListen );
}

init();
