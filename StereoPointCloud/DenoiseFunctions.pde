float[][] denoiseMap(PImage image, float[][] disparityMap, int n) {
  println("Denoising..");
  boolean[][] validityMap;
  float[][] denoisedMap = new float[image.height][image.width];
  for(int i = 0; i < n; i++) {
    validityMap = validMap(image, disparityMap);
    disparityMap = denoiseStep(image, denoisedMap, disparityMap, validityMap);
    if(i % 10 == 0)println("Pass " + (i));
  }
  return disparityMap;
}

float[][] denoiseStep(PImage image, float[][] denoisedMap, float[][] disparityMap, boolean[][] validityMap) {

  for (int i = 0; i <  image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      if(!validityMap[i][j])denoisedMap[i][j] = denoisePixel(image, disparityMap, validityMap, j, i);
      else denoisedMap[i][j] = disparityMap[i][j];
    }
  }
  
  return denoisedMap;
}

float denoisePixel(PImage image, float[][] disparityMap, boolean[][] validityMap, int x, int y) {
  float bestDisparity = disparityMap[y][x];
  float minColorDist = Float.MAX_VALUE;
  for (int i = max(0, y - 1); i < min(image.height, y + 2); i++) {
    for (int j = max(0, x - 1); j < min(image.width, x + 2); j++) {
      float colDist = colorDistanceSquared(image.get(j, i), image.get(x, y));
      if(validityMap[i][j] && colDist < minColorDist) {
         bestDisparity = disparityMap[i][j];
         minColorDist = colDist;
      }
    }
  }
  
  return bestDisparity;
}

boolean[][] validMap(PImage image, float[][] disparityMap) {
boolean[][] valid = new boolean[image.height][image.width];
  for (int i = 0; i <  image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      valid[i][j] = pixelValid(image, disparityMap, j, i);
    }
  }
  
  return valid;
}

boolean pixelValid(PImage image, float[][] disparityMap, int x, int y) {
  int count = 0;
  for (int i = max(0, y - 1); i < min(image.height, y + 2); i++) {
    for (int j = max(0, x - 1); j < min(image.width, x + 2); j++) {
      if(abs(disparityMap[i][j] - disparityMap[y][x]) < 2)count++;
      if(count >= 5)return true;
    }
  }
  return false;
}
