# squatswitch.nas by Ron Jensen (GLP 2.0)
# Implement c182rg landing gear, including squat switch and
# other gear-related stuff

original_gearDown = controls.gearDown;

# Implement gear functionality.
gearFncy = func {
    handle = getprop("/controls/gear/gear-handle-down");
    if (!getprop("/gear/serviceable")) {
      # don't move the actual gear up or down now ...
      settimer(gearFncy, 0.2);		# ... but check back soon
      return;
    }

    # In v1.9 there is an FDM bug where the wow property isn't set properly
    # if the aircraft is reset using the location-in-air menu. Therefore
    # we need to use gear compression instead. We don't use the nosewheel,
    # as it can come off the ground when taxiing or during the take-off roll.
    # wow    = getprop("/gear/gear[0]/wow");
    var wow = getprop("/gear/gear[1]/compression-norm") > 0.001;

    if(handle or !wow){
      original_gearDown(handle ? 1 : -1);
    } else {
      # In the rare situation where the gear handle is up but there is
      # weight on the wheels, we need to notice when the weight eventually
      # comes off. The FDM writes to "wow" and "compression-norm" once
      # per frame, even if the value hasn't changed. This makes a listener
      # inefficient, so we use a timer instead. 
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

# Rebind gearToggle to use our *new* version of gearDown:
controls.gearToggle = func { 
  controls.gearDown(getprop("/controls/gear/gear-handle-down") > 0 ? -1 : 1); 
}
