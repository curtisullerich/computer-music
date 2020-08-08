// Processes the event stream of position changes from a GameTrak Tether and
// produces a parallel stream of velocity updates. A stream of velocity events
// can in turn be used in acceleration.ck.
//
// It would be nice if ChucK had a notion of data UGens alongside audio UGens so
// we could do things like tether => TetherVelocity v => Acceleration a => gain;
// Maybe UAnae can be used this way?
//
// TODO: This is very basic and the output is jittery. Applying a moving average
// filter on the stream of calculated values would likely help a lot.
public class TetherVelocity extends Event {
  Tether @ _tether; // Caller must set _tether or this instance will do nothing.
  Point _prev; // The last point received from the tether.
  time _timePrev; // The time of the last position update.

  // In units/second. This just uses whatever units Point reports, so the full
  // tetherable space is 2x2x1 "unit" currently.
  float velocity;

  // Since ChucK doesn't support constructor params, use this to get a new
  // instance.
  fun static TetherVelocity make(Tether t) {
    TetherVelocity v;
    t @=> v._tether;
    return v;
  }

  spork ~ _run();
  fun void _run() {
    while (true) {
      _tether => now;
      _tether.point.subtract(_prev) => float distanceMoved;
      (now - _timePrev) / 1::second => float secondsSince;
      if (secondsSince != 0) {
        _update(distanceMoved/secondsSince);
      }
      spork ~ _idle();
    }
  }

  // Waits 250 ms and declares velocity to be 0 if the position hasn't changed.
  fun void _idle() {
    250::ms => now;
    if (_timePrev <= now - 250::ms) { _update(0); }
  }

  fun void _update(float v) {
    v => velocity;
    _tether.point.copy() @=> _prev;
    now => _timePrev;
    broadcast();
  }
}
