// Monitors the state of a GameTrak tether controller and exposes it via
// the fields left, right, and button. left and right are Tethers which
// expose a point (x,y,z) and azimuth.
public class GameTrak extends Event {
  // left, right, and button each wrap an Hid. These are the GameTrak-relevantHidMsg fields:
  // axisPosition/scaled_axis_position (scale=1, apparently)
  // deviceNum
  // deviceType
  // fdata (float data, aliased to axisPosition)
  // idata (integer/boolean data, aliased to buttonUp/buttonDown)
  // which (0-5 for axes)
  // isAxisMotion()/is_axis_motion()
  // isButtonDown()/is_button_down()
  // isButtonUp()/is_button_up()
  Tether.makeLeft() @=> Tether left;
  Tether.makeRight() @=> Tether right;
  Button button;

  // Broadcast this object's event whenever a component of the GameTrak changes.
  // If a user doesn't care about all of the GameTrak's controls, they can
  // subscribe to left/right/button individually instead of to this instance.
  spork ~ runLeft();   fun void runLeft()   { while (true) { left   => now; broadcast(); } }
  spork ~ runRight();  fun void runRight()  { while (true) { right  => now; broadcast(); } }
  spork ~ runButton(); fun void runButton() { while (true) { button => now; broadcast(); } }
}
