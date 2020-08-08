public class Button extends Event {
  0 => int down;
  time timeUpdated;

  // Get a separate Hid for each instance so they don't consume each other's
  // messages.
  Hid _hid;
  if(!_hid.openJoystick(/*device=*/0)) { me.exit(); }

  spork ~ _run();
  fun void _run() {
    while (true) {
      _hid => now;
      0 => int updates;
      HidMsg msg;
      while (_hid.recv(msg)) {
        if (_updateButton(msg)) {
          updates++;
        }
      }
      if (updates) {
        now => timeUpdated;
        broadcast();
      }
    }
  }

  fun int _updateButton(HidMsg msg) {
    if (msg.isButtonDown()) {
      true => down;
      return true;
    } else if (msg.isButtonUp()) {
      false => down;
      return true;
    }
    return false;
  }
}
