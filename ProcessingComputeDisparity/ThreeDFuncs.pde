ArrayList<Vector> generate3D(PImage left, PImage right, int imageWidth, int imageHeight, float focalLength, float camDistance) {
  ArrayList<Vector> points = new ArrayList<Vector>();

  float[][] disparityMap = disparity(left, right, 20, 6, 6);
  for (int i = 0; i < imageHeight; i++) {
    for (int j = 0; j < imageWidth; j++) {
      if (disparityMap[i][j] != -128) {
        Vector point = positionFromDisparity(disparityMap[i][j], j, i, imageWidth, imageHeight, focalLength, camDistance);
        if(point.z < 200) {
          point.col = left.get(j, i);
          points.add(point);
        }
      }
    }
  }

  return points;
}

Vector positionFromDisparity(float disparity, float x, float y, int imageWidth, int imageHeight, float focalLength, float camDistance) {
  float xangle = atan((x / (imageHeight / 2) - 1) / focalLength);
  float yangle = atan((y / (imageHeight / 2) - 1) / focalLength);
  float depth  = disparityToDepth(disparity, focalLength, camDistance);
  Vector point = new Vector(tan(xangle) * depth, tan(yangle) * depth, depth);
  point.scale(200);
  //point.z -= 500;
  return point;
}

float disparityToDepth(float disparity, float focalLength, float camDistance) {
  return focalLength * camDistance / (abs(disparity));
}
