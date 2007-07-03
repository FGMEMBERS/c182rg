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
    };

    wow    = getprop("/gear/gear[0]/wow");
    if(handle or !wow){
      original_gearDown(handle ? 1 : -1);
    } else {
# In the presumably-rare situation where the gear handle
# is up, but there is weight on the wheels, we need to
# notice when the weight comes off.   Let's do this with a
# timer, because some FDMs write to the "wow" property once
# per frame, even if its value hasn't changed, making it
# inefficient to attach a listener.
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
