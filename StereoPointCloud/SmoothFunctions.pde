float[][] smoothMap(PImage image, float[][] disparityMap) {
  println("Smoothing ...");
  float[][] smoothed = new float[image.height][image.width];
  for (int i = 0; i <  image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      smoothed[i][j] = smoothSimilar(image, disparityMap, j, i, 20, 2);
    }
  }

  return smoothed; //gaussianBlur(disparityMap, 5);
}


float smoothSimilar(PImage image, float[][] disparityMap, int x, int y, int window, int threshold) {
  float sum = 0;
  int n = 0;
  for (int i = max(0, y - window / 2); i < min(image.height, y + window / 2); i++) {
    for (int j = max(0, x - window / 2); j < min(image.width, x + window / 2); j++) {
      if (abs(disparityMap[y][x] - disparityMap[i][j]) <= threshold) {
        sum += disparityMap[i][j];
        n++;
      }
    }
  }

  return sum / n;
}
