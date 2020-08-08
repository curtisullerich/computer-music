// To run:
// chuck example-basic-main.ck
GameTrak gt;
TetherVelocity.make(gt.left) @=> TetherVelocity v;
Acceleration.make(v) @=> Acceleration a;
SinOsc one => Gain master => dac;
SinOsc two => master;
250 => int base => one.freq => two.freq;

// You can listen to any event from the device and update all values when any
// single parameter changes. This is convenient when you want continuous (rather
// than discrete) monitoring/mapping of many parameters.
spork ~ listenToGametrak();
fun void listenToGametrak() {
  while (true) {
    gt.right.point.z*100 + base => one.freq;
    (gt.right.point.y+1)/2 => one.gain;
    // Put the event monitor at the bottom of the loop so the initial state of
    // the parameters is read before touching the device.
    gt => now;
  }
}

// Or you can listen for changes on a single tether or button.
spork ~ listenToLeft();
fun void listenToLeft() {
  gt.left @=> Tether tether;
  gt.left.point @=> Point left;
  while (true) {
    left.z*100 + base => two.freq;
    (left.y+1)/2 => two.gain;
    tether => now;
  }
}

// Since this only broadcasts messages when the button receives changes, you can
// use it as a trigger, as opposed to continuous monitoring.
spork ~ listenToButton();
fun void listenToButton() {
  gt.button @=> Button button;
  while (true) {
    // Monitor events at the top of the loop so the body won't execute until you
    // actually touch the button.
    button => now;
    if (button.down) {
      0 => master.gain;
      <<< "button down", "" >>>;
    } else {
      1 => master.gain;
      <<< "button up", "" >>>;
    }
  }
}

while (true) 1::minute => now;
