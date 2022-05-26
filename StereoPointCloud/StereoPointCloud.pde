
void setup() {
  size(1400, 800);
  generateExportPCC();
  //displayDisparity();
  //imagesForReport();
}

void imagesForReport() {
  int scale = 3;
  PImage image = loadImage("images/stereo5.png");

  image.resize(image.width / scale, image.height / scale);

  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  ///TO MAKE IMAGES FOR REPORT
  left.save("output/left.png");
  right.save("output/right.png");
  float[][] disparityMap = iterativeDisparityMap(left, right, 1);
  disparityMapToImage(disparityMap, scale).save("output/1unprocessed.png");
  float[][] denoisedMap = denoiseMap(left, disparityMap);
  disparityMapToImage(denoisedMap, scale).save("output/2denoised.png");
  float[][] smoothedMap = smoothMap(left, denoisedMap);
  disparityMapToImage(smoothedMap, scale).save("output/3smoothed.png");
}

void generateExportPCC() {
  pipeline("images/stereo5.png", 1, 2, "output/clouds/cloud5_orthographic.ply");
}

void displayDisparity() {
  int scale = 2;
  PImage image = loadImage("images/stereo5.png");

  image.resize(image.width / scale, image.height / scale);

  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  
  

  float[][] disparityMap = iterativeDisparityMap(left, right, 12);
  PImage disparityImage = disparityMapToImage(disparityMap, scale);
  disparityMap = denoiseMap(left, disparityMap);

  float[][] denoised = smoothMap(left, disparityMap);//smoothMap(left, denoiseMap(left, disparityMap));
  
  PImage denoisedImage = disparityMapToImage(denoised, scale);
  
  disparityImage.save("unsmoothed.png");
  denoisedImage.save("smoothed.png");
  
  //PImage edgeImage = edgeImage(left);
  image(disparityImage, 0, 0, left.width, left.height); 
  image(denoisedImage, left.width, 0, left.width, left.height);

  //disparityMap = disparityCorrection(left, disparityMap, 20);
  //PImage correctedDisparityMap = disparityMapToImage(disparityMap, scale * 2);
}

void pipeline(String stereoImagePath, float camDistance, float focalLength, String pointCloudExportPath) {
  PImage image = loadImage(stereoImagePath);
  //image.resize(image.width / 2, image.height / 2);
  
  PImage left = cropImage(image, 0, 0, image.width / 2, image.height);
  PImage right= cropImage(image, image.width / 2, 0, image.width / 2, image.height);
  
  float[][] disparityMap = iterativeDisparityMap(left, right, 2);
  float[][] denoisedMap = denoiseMap(left, disparityMap);
  float[][] smoothedMap = denoisedMap; //smoothMap(left, denoisedMap);
  
  ArrayList<Point> pointCloud = generatePointCloud(left, smoothedMap, camDistance, focalLength);
  export(pointCloudExportPath, pointCloud);
}
