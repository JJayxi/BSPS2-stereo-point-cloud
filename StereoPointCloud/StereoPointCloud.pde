import peasy.*;
PeasyCam cam;

void setup() {
  size(900, 900, P3D);
  //cam = new PeasyCam(this, 100);
  //Distance between pictures is 30cm and focal length is 43mm
  //pointCloud = generatePointCloud("images/stereo6.jpg", 30, 0.43, 4);
  //pointCloud = rescale(pointCloud, 200);
  
  testIterativeDisparityMap();
}

void draw() {
  //background(0);
  //renderPointCloud(pointCloud);
}


void testIterativeDisparityMap() {
  int scale = 3;
  PImage image = loadImage("images/stereo6.jpg");
  
  image.resize(image.width / scale, image.height / scale);
  
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  int scale2 = 3;
  
  PImage leftRescaled = copy(left);
  leftRescaled.resize(ceil(left.width / scale2), ceil(left.height / scale2));
  
  PImage rightRescaled = copy(right);
  rightRescaled.resize(ceil(right.width / scale2), ceil(right.height / scale2));
  
  float[][] baseMap = generateDisparityMap(leftRescaled, rightRescaled, 7); 
  
  PImage baseMapImage = disparityMapToImage(baseMap, scale * scale2);
  image(baseMapImage, 0, 0, left.width, left.height);
  
  left.resize(left.width / scale2 * scale2 - 1, left.height / scale2 * scale2 - 1);
  right.resize(right.width / scale2 * scale2 - 1, right.height / scale2 * scale2 - 1);
  
  float[][] disparityMap = generateDisparityMap(left, right, baseMap, scale2, 4);
  PImage mapImage = disparityMapToImage(disparityMap, scale);
  image(mapImage, 0, left.height, left.width, left.height);
  
}
