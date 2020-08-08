// A point in Cartesian space indexed by x,y,z.
//
// This implementation currently assumes actual Cartesian space, but its
// intended use is with a GameTrak tether, which reports positional
// values in a hybrid Cartesian/polar system.
//
// TODO: Support returning raw xyz, Cartesian xyz, and spherical rθφ.
public class Point {
  // TODO could measure the actual angle to convert this to radians
  float x; // properly, the azimuth ratio projected on x axis
  float y; // properly, the azimuth ratio projected on y axis
  float z; // actually r, not z

  // Returns a deep copy of this Point (to make passing by value easier).
  fun Point copy() {
    Point t; x => t.x; y => t.y; z => t.z;
    return t;
  }

  // Finds the distance between two points, assuming Cartesian coordinates.
  fun float subtract(Point other) {
    // TODO these aren't strictly cartesian coordinates
    return Math.sqrt(Math.pow(x-other.x, 2) +
                     Math.pow(y-other.y, 2) +
                     Math.pow(z-other.z, 2));
  }

  // Azimuth ratio (rotation around z axis in radians.
  // 0 is toward the button. pi/2 is hard right, -pi/2 is hard left.
  fun float azimuth() {
    // TODO this assumes Cartesian coordinates.
    return Math.atan2(x, -1*y);
  }
}
