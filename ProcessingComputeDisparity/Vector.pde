public class Vector {
  float x, y, z; 
  color col;
  Vector(float x, float y, float z) {
    this.x = x; 
    this.y = y; 
    this.z = z;
  }
  
  void scale(float r) {
    x *= r;
    y *= r;
    z *= r;
  }
}
