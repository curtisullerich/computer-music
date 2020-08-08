public class Util {
  // Return a new builder for mapping a value. Typical use does not involve a
  // declared instance of a MapBuilder variable, and since MapBuilder is not
  // currently a public class, you can't actually instantiate an instance of
  // it outside this file.
  // Example: Util.map(mouseX).from(-1, 1).to(0, 1).clip().get() => gain.value;
  fun static MapBuilder map(float n) {
    MapBuilder m;
    n => m.value;
    return m;
  }

  // Rescales n from range 1 to range 2.
  fun static float mapSimple(float n, float start1, float stop1, float start2, float stop2, int clip) {
    ( ((n-start1)/(stop1-start1)) * (stop2-start2) ) + start2 => float scaled;
    if (!clip) { return scaled; }
    Math.max(start2, stop2) => float larger;
    Math.min(start2, stop2) => float smaller;
    if (scaled < smaller) { return smaller; }
    if (scaled > larger) { return larger; }
    return scaled;
  }
}

// A builder pattern for mapping a value from one range into another. The purpose
// is to have call sites be more easily read and understood than a map() function
// with a bunch of primitive literal parameters.
class MapBuilder {
  float value, start1, stop1, start2, stop2;
  false => int doClip;
  fun MapBuilder from(float start, float stop) {
    start => start1;
    stop => stop1;
    return this;
  }
  fun MapBuilder to(float start, float stop) {
    start => start2;
    stop => stop2;
    return this;
  }
  fun MapBuilder clip() {
    true => doClip;
  }
  fun float get() {
    return Util.mapSimple(value, start1, stop1, start2, stop2, doClip);
  }
}

