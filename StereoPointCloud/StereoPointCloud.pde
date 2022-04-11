
void setup() {
  size(1400, 800);
  generateExportPCC();
  //displayDisparity();
}

void draw() {
  //background(0);
  //renderPointCloud(pointCloud);
}

void generateExportPCC() {
  pipeline("images/stereo5.jpg", 0.3, 3, "cloud2.ply");
}

void displayDisparity() {
  int scale = 2;
  PImage image = loadImage("images/stereo5.jpg");

  image.resize(image.width / scale, image.height / scale);

  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);

  float[][] disparityMap = iterativeDisparityMap(left, right, 2);

  PImage disparityImage = disparityMapToImage(disparityMap, scale);//findErrors(left, right, disparityMap, 100)
  float[][] denoised = smoothMap(left, denoiseMap(left, disparityMap));
  PImage denoisedImage = disparityMapToImage(denoised, scale);
  
  //PImage edgeImage = edgeImage(left);
  image(disparityImage, 0, 0, left.width, left.height); 
  image(denoisedImage, left.width, 0, left.width, left.height);

  //disparityMap = disparityCorrection(left, disparityMap, 20);
  //PImage correctedDisparityMap = disparityMapToImage(disparityMap, scale * 2);
}

void pipeline(String stereoImagePath, float camDistance, float focalLength, String pointCloudExportPath) {
  PImage image = loadImage(stereoImagePath);
  
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  float[][] disparityMap = iterativeDisparityMap(left, right, 2);
  float[][] denoisedMap = denoiseMap(left, disparityMap);
  float[][] smoothedMap = smoothMap(left, denoisedMap);
  
  ArrayList<Point> pointCloud = generatePointCloud(left, smoothedMap, camDistance, focalLength);
  export(pointCloudExportPath, pointCloud);
}
