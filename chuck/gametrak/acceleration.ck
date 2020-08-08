// Processes the event stream of velocity changes from TetherVelocity and
// produces a parallel stream of acceleration updates.
//
// Note: all caveats about jitter etc from velocity.ck apply here, but
// magnified. This class is mainly a proof of concept and logical
// extension of velocity tracking.
public class Acceleration extends Event {
  TetherVelocity @ _velocity;
  float _prev;
  time _timePrev; // The time of the last velocity update.

  // Assuming velocity is in units/second, this is units/second/second.
  float acceleration;

  // Since ChucK doesn't support constructor params, use this to get a new
  // instance.
  fun static Acceleration make(TetherVelocity v) {
    Acceleration a;
    v @=> a._velocity;
    return a;
  }

  spork ~ _run();
  fun void _run() {
    while (true) {
      _velocity => now;

      _velocity.velocity - _prev => float delta;
      (now - _timePrev) / 1::second => float sSince;
      delta/sSince => acceleration;
      // <<< "acceleration", acceleration>>>;

      _velocity.velocity => _prev;
      now => _timePrev;
      broadcast();
    }
  }
}
