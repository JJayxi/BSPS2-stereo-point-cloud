float[][] denoiseMap(PImage image, float[][] disparityMap) {
  println("Denoising high frequency..");
  float[][] denoisedMap = denoiseMap(image, disparityMap, false, 10);
  println("Denoising low frequency..");
  denoisedMap = denoiseMap(image, denoisedMap, true, 5);
  denoisedMap = denoiseMap(image, denoisedMap, false, 10);
 
  return denoisedMap;
}

float[][] denoiseMap(PImage image, float[][] disparityMap, boolean low, int n) {
  
  boolean[][] validityMap;
  float[][] denoisedMap = new float[image.height][image.width];
  for (int i = 0; i < n; i++) {
    validityMap = validMap(image, disparityMap, low);
    disparityMap = denoiseStep(image, denoisedMap, disparityMap, validityMap);
  }
  return disparityMap;
}

float[][] denoiseStep(PImage image, float[][] denoisedMap, float[][] disparityMap, boolean[][] validityMap) {

  for (int i = 0; i <  image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      if (!validityMap[i][j])denoisedMap[i][j] = denoisePixel(image, disparityMap, validityMap, j, i);
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
      float colDist = colorDistance(image.get(j, i), image.get(x, y));
      if (validityMap[i][j] && colDist < minColorDist) {
        bestDisparity = disparityMap[i][j];
        minColorDist = colDist;
      }
    }
  }

  return bestDisparity;
}

boolean[][] validMap(PImage image, float[][] disparityMap, boolean low) {
  boolean[][] valid = new boolean[image.height][image.width];
  for (int i = 0; i <  image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      valid[i][j] = pixelValid(image, disparityMap, low, j, i);
    }
  }

  return valid;
}

boolean pixelPossible(PImage image, float[][] disparityMap, int radius, int threshold, int x, int y) {
  float a = 0;
  int n = (int)(radius * TWO_PI);
  float da = TWO_PI / n;
  int counter = 0;
  for (int i = 0; i < n; i++) {
    int k = x + (int)(cos(a) * radius);
    int l = y + (int)(sin(a) * radius);
    if (k < 0 || k >= image.width || l < 0 || l >= image.height) {
      continue;
    } else {
      if (abs(disparityMap[y][x] - disparityMap[l][k]) <= threshold) {
        counter++;
      }
      
      if(counter >= 0.1*n)return true;
    }
    a += da;
  }



  return false;
}

boolean pixelValid(PImage image, float[][] disparityMap, boolean low, int x, int y) {
  int count = 0;
  if (low && !pixelPossible(image, disparityMap, 20, 1, x, y))return false;
  for (int i = max(0, y - 1); i < min(image.height, y + 2); i++) {
    for (int j = max(0, x - 1); j < min(image.width, x + 2); j++) {
      if (abs(disparityMap[i][j] - disparityMap[y][x]) < 1)count++;
      if (count >= 5)return true;
    }
  }
  return false;
}
