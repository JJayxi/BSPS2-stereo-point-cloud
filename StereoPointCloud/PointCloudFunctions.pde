ArrayList<Point> pointCloud;

ArrayList<Point> generatePointCloud(String stereoImageFileName, float lensDistance, float focalLength, float scale) {
  PImage image = loadImage(stereoImageFileName);
  
  image.resize((int)(image.width / scale), (int)(image.height / scale));
  
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  float[][] disparityMap = iterativeDisparityMap(left, right, 5);
  ArrayList<Point> pointCloud = pointCloudFromDisparityMap(left, disparityMap, lensDistance, focalLength);

  return pointCloud;
}

ArrayList<Point> pointCloudFromDisparityMap(PImage image, float[][] disparityMap, float lensDistance, float focalLength) {
  ArrayList<Point> pointCloud = new ArrayList<Point>();
  for (int i = 0; i < disparityMap.length; i++)
    for (int j = 0; j < disparityMap[0].length; j++) 
      if (!Float.isNaN(disparityMap[i][j]))
        pointCloud.add(pointFromDisparity(image.get(j, i), disparityMap[i][j], j, i, image.width, image.height, lensDistance, focalLength));

  return pointCloud;
}

Point pointFromDisparity(color col, float disparity, float x, float y, float imageWidth, float imageHeight, float lensDistance, float focalLength) {
  //normalize position to center
  x = 2 * x / imageWidth - 1;
  y = 2 * y / imageHeight- 1;
  //find tangent of angle of that point on the image according to center of camera
  float xTan = x / focalLength;
  float yTan = y / focalLength;
  
  float depth = disparityToDepth(disparity, lensDistance, focalLength);
  
  return new Point(xTan * depth, yTan * depth, depth, col);
}

float disparityToDepth(float disparity, float lensDistance, float focalLength) {
  return focalLength * lensDistance / abs(disparity);
}

void renderPointCloud(ArrayList<Point> pointCloud) {
  strokeWeight(2);
  for (Point p : pointCloud) {
    stroke(p.col);
    point(p.x, p.y, -p.z);
  }
}

ArrayList<Point> rescale(ArrayList<Point> pointCloud, float scale) {
   for(Point p : pointCloud) {
     p.x *= scale;
     p.y *= scale;
     p.z *= scale;
   }
   
   return pointCloud;
}


class Point {
  float x, y, z;
  color col;

  Point(float x, float y, float z, color col) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.col = col;
  }
}
