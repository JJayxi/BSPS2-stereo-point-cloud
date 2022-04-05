import peasy.*;
PeasyCam cam;

void setup() {
  size(1400, 800);
  //cam = new PeasyCam(this, 100);
  //generateExportPCC();
  displayDisparity();
}

void draw() {
  //background(0);
  //renderPointCloud(pointCloud);
}

void generateExportPCC() {
  pointCloud = generatePointCloud("images/stereo5.jpg", 4, 5, 3);
  pointCloud = rescale(pointCloud, 4);
  export("cloud_noisy.ply", pointCloud);
  //pointCloud = rescale(pointCloud, 500);
}

void displayDisparity() {
  int scale = 3;
  PImage image = loadImage("images/stereo5.jpg");

  image.resize(image.width / scale, image.height / scale);

  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);

  float[][] disparityMap = iterativeDisparityMap(left, right, 2);

  PImage disparityImage = disparityMapToImage(disparityMap, scale);//findErrors(left, right, disparityMap, 100)
  PImage denoisedImage = disparityMapToImage(denoiseMap(left, disparityMap, 100), scale);
  //PImage edgeImage = edgeImage(left);
  image(disparityImage, 0, 0, left.width, left.height); 
  image(denoisedImage, left.width, 0, left.width, left.height);

  //disparityMap = disparityCorrection(left, disparityMap, 20);
  //PImage correctedDisparityMap = disparityMapToImage(disparityMap, scale * 2);
}
