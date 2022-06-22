ArrayList<Point> pointCloud;

ArrayList<Point> generatePointCloud(PImage image, float[][] disparityMap, float lensDistance, float focalLength) {
  return pointCloudFromDisparityMap(image, disparityMap, lensDistance, focalLength); 
}

ArrayList<Point> generatePointCloud(String stereoImageFileName, float lensDistance, float focalLength, float scale) {
  PImage image = loadImage(stereoImageFileName);
  
  image.resize((int)(image.width / scale), (int)(image.height / scale));
  
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  float[][] disparityMap = iterativeDisparityMap(left, right, 2); //findErrors(left, right, iterativeDisparityMap(left, right, 3), 70);
  ArrayList<Point> pointCloud = pointCloudFromDisparityMap(left, disparityMap, lensDistance, focalLength);
  
  pointCloud = rescale(pointCloud, 20);
  
  return pointCloud;
}

ArrayList<Point> pointCloudFromDisparityMap(PImage image, float[][] disparityMap, float lensDistance, float focalLength) {
  ArrayList<Point> pointCloud = new ArrayList<Point>();
  for (int i = 0; i < disparityMap.length; i++)
    for (int j = 0; j < disparityMap[0].length; j++) 
      if (random(100) < 84 && !Float.isNaN(disparityMap[i][j]) && (disparityMap[i][j] < -19 && disparityMap[i][j] > -image.width*0.1))
        pointCloud.add(pointFromDisparity(image, disparityMap[i][j], j, i, lensDistance, focalLength));

  return pointCloud;
}

Point pointFromDisparity(PImage image, float disparity, int x, int y, float lensDistance, float focalLength) {
  //normalize position to center
  float nx = 2 * (float)x / (float)image.width  - 1;
  float ny = 2 * (float)y / (float)image.height - 1;
  //find tangent of angle
  float xTan = nx / focalLength;
  float yTan = ny / focalLength * (image.height / (float)image.width);
  //compute depth
  float depth = disparityToDepth(disparity / image.width, lensDistance, focalLength);
  //return new Point(x, y, depth, image.get(x, y));
  return new Point(
    xTan * (depth + focalLength),
    -yTan *  (depth + focalLength),
    -depth,
    image.get(x, y));
}

float disparityToDepth(float disparity, float lensDistance, float focalLength) {
  return -focalLength * lensDistance / disparity - focalLength;
}

void renderPointCloud(ArrayList<Point> pointCloud) {
  strokeWeight(2);
  for (Point p : pointCloud) {
    stroke(p.col);
    point(p.x, p.y, p.z);
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

void export(String path, ArrayList<Point> pointCloud) {
  String s = "";
  s+= "ply\n";
  s+= "format ascii 1.0\n";
  s+= "element vertex " + pointCloud.size() +"\n";
  s+="property float32 x\nproperty float32 y\nproperty float32 z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nend_header\n";
  String[] sa = new String[pointCloud.size() + 1];
  sa[0] = s;
  int i = 1; 
  for(Point p : pointCloud) {
    sa[i] = p.x + " " + p.y + " " + p.z + " " + (int)red(p.col) + " " + (int)green(p.col) + " " + (int)blue(p.col);
    i++;
    if(i % 100000 == 0)println(i + " points");
  }
  println("Exported " + pointCloud.size() + " points");
  saveStrings(path, sa);
  println("Exported file");
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
