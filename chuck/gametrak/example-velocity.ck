// To run:
// chuck example-basic-main.ck
GameTrak gt;
TetherVelocity.make(gt.left) @=> TetherVelocity v;
SinOsc one => Gain master => dac;
250 => int base => one.freq;

// The faster you move the left tether, the higher the pitch will be.
// velocity.ck clearly needs some smoothing and lowpass filtering
// applied.
spork ~ listenToVelocity();
fun void listenToVelocity() {
  while (true) {
    v.velocity*10 + base => one.freq;
    <<< "velocity:", v.velocity >>>;
    v => now;
  }
}

while (true) 1::minute => now;
