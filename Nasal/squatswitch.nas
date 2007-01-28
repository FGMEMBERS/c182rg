# squatswitch.nas by Ron Jensen (GLP 2.0)
# Implement a squat switch 

original_gearDown = controls.gearDown;
    svc    = 1;		# assume the best for now

# Implement gear functionality.
# Check the relevant variables and act accordingly.
gearFncy = func {
    if ( svc == 0 ) {return};
    
    handle = getprop("/controls/gear/gear-handle-down");

#+ Should work, but doesn't work above 200 AGL:
#    wow    = getprop("/gear/gear[0]/wow");
#+ The following is a kludge.  It is a workaround.
#+ Evidently the JSB FDM only does wow calculations
#+ below 200 feet, so if the aircraft is initially located
#+ or relocated to an airborne position, wow will probably
#+ be wrong.
#+ We hope this situation is temporary.
    wow     = (getprop("/gear/gear[0]/compression-norm") > 0.001);

    if(handle==1 or !wow){
      original_gearDown( (handle == 1 ? 1 : -1) );
    } else {
# In the presumably-rare situation where the gear handle
# is up, but there is weight on the wheels, we need to
# notice when the weight comes off.
# Let's do this with a timer, because:
# a) It is observed that some FDMs write to the wow property once
#  per frame, even if its value hasn't changed, so for efficiency
#  reasons let's not listen to it unless we need to, and
# b) There are nasty interactions (segmentation faults) between
#  removable listeners and the "reset" routine used to implement
#  the location-in-air popup.  In contrast, the timer removes itself
#  cleanly.
      settimer(gearFncy, 0.2);
    }
}

# This is the main entry point, called by UI routines.
# This definition replaces the trivial default gearDown
# routine defined in controls.nas.
# Calling gearDown(0) doesn't move the handle;
# it just calls gearFncy.
controls.gearDown = func {
    if (arg[0] < 0) {
	setprop("/controls/gear/gear-handle-down", 0);
    } elsif (arg[0] > 0) {
	setprop("/controls/gear/gear-handle-down", 1);
    }
    gearFncy();
}

controls.gearToggle = func { controls.gearDown(getprop("/controls/gear/gear-handle-down") > 0 ? -1 : 1); }

