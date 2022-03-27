import peasy.*;
PeasyCam cam;

void setup() {
  size(1000, 1000, P3D);
  //cam = new PeasyCam(this, 100);
  //Distance between pictures is 6cm and focal length is 43mm
  //pointCloud = generatePointCloud("images/stereo4.jpg", 5, 2.3, 5);
  //pointCloud = rescale(pointCloud, 500);
  
  displayDisparity();
  
}

void draw() {
  //background(0);
  //renderPointCloud(pointCloud);
}


void displayDisparity() {
  int scale = 3;
  PImage image = loadImage("images/stereo4.jpg");
  
  image.resize(image.width / scale, image.height / scale);
    
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  float[][] disparityMap = iterativeDisparityMap(left, right, 3);
  
  PImage disparityImage = disparityMapToImage(disparityMap, scale);//findErrors(left, right, disparityMap, 100)
  //PImage edgeImage = edgeImage(left);
  image(left, 0, 0, left.width, left.height); 
  image(disparityImage, 0, left.height, left.width, left.height);
    
  //disparityMap = disparityCorrection(left, disparityMap, 20);
  //PImage correctedDisparityMap = disparityMapToImage(disparityMap, scale * 2);
  
}
