public class Tether extends Event {
  // The ratio of the total z axis length before we get values from the GameTrak
  .032 => float DEADZONE;

  // min and max tether indices: 0-2 for left, 3-5 for right
  int _min; int _max;

  // TODO subscribing to a Tether is basically subscribing to a Point. It may be worthwhile later to allow subscribing to each axis individually.
  Point point;
  Point _prev;

  // Each tether (and button) initializes its own Hid because otherwise they
  // consume each others messages in their own shreds.
  Hid _hid;
  if(!_hid.openJoystick(/*device=*/0)) { me.exit(); }

  time _timePrev; // The time of the last successful update (not noise).

  // Get a new ready-to-use Tether from these factories.
  fun static Tether makeLeft() {
    Tether t;
    0 => t._min;
    2 => t._max;
    return t;
  }
  fun static Tether makeRight() {
    Tether t;
    3 => t._min;
    5 => t._max;
    return t;
  }

  spork ~ _run();
  fun void _run() {
    while (true) {
      _hid => now; // wait on HidIn as event
      0 => int updates;
      point.copy() @=> Point maybePrev;
      HidMsg msg;
      while (_hid.recv(msg)) {
        if (_updateAxes(msg)) {
          updates++;
        }
      }
      if (updates) {
        maybePrev @=> _prev;
        now => _timePrev;
        broadcast();
      }
    }
  }

  // Returns true if the event was significant enough to be called signal instead of noise.
  fun int _updateAxes(HidMsg msg) {
    if (!msg.isAxisMotion()) { return false; }
    if (msg.which < _min || msg.which > _max) { return false; }
    return _updateAxes(msg.which-_min, msg.axisPosition);
  }
  fun int _updateAxes(int xyz /* 012 maps to xyz */, float pos) {
    if (xyz == 0 && _isSignal(pos, _prev.x)) {
      pos => point.x;
    } else if (xyz == 1 && _isSignal(pos, _prev.y)) {
      pos => point.y;
    } else if (xyz == 2 && _isSignal(pos, _prev.z)) {
      _mapZ(pos) => point.z;
    } else {
      return false;
    }
    return true;
  }

  // The z axes map to [0,1], others map to [-1,1]
  fun float _mapZ(float pos) {
    1 - ((pos + 1) / 2) - DEADZONE => float ret;
    if (ret < 0) { return 0.; }
    return ret;
  }

  // Decides whether a tether axis position change is significant enough
  // to be called signal instead of noise.
  fun int _isSignal(float position, float prevPosition) {
    0.01 => float MIN; // arbitrary threshold to account for sensor noise
    return Math.fabs(position - prevPosition) > MIN;
  }
}
