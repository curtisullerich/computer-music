// Applies moving average smoothing to any pushed inputs. The latest value
// based on everything pushed so far is available via peek().
//
// This is optimized for implementation simplicity for now:
//  - hard-codes the window size to 4 values, mostly because ChucK arrays don't
//    support pushFront or popFront, only << (pushBack) and popBack.
//  - recomputes the average every time you peek() instead of maintaining a
//    sum
//  - doesn't return a proper average until the window is filled, so the
//    first 3 values will be too small.
class Smoother {
  // TODO some inputs are really large. should I use a lowpass filter?
  float values[4];
  4 => int window;
  0 => int slot;

  fun float push(float val) {
    val => values[slot];
    (slot+1) % window => slot;
    return peek();
  }

  // TODO instead of a pointwise average, calculate the average over the last
  // 20 milliseconds or something
  fun float peek() {
    0 => float s;
    for (0 => int i; i < window; i++) {
      s+values[i]=>s;
    }
    return s/window;
  }
}
