float[][] iterativeDisparityMap(PImage left, PImage right, int scale) {  
  PImage leftRescaled = copy(left);
  leftRescaled.resize(left.width / scale + 1, left.height / scale + 1);

  PImage rightRescaled = copy(right);
  rightRescaled.resize(right.width / scale + 1, right.height / scale + 1);

  println("Generating Base Map..");
  float[][] baseMap = generateDisparityMap(leftRescaled, rightRescaled, 7);
  baseMap = denoiseMap(leftRescaled, baseMap);
  baseMap = gaussianBlur(baseMap, scale);
  //baseMap = smoothMap(leftRescaled, baseMap);
  disparityMapToImage(baseMap, scale * 2).save("output/0basemap.png");

  println("Generating Disparity Map..");
  float[][] disparityMap = generateDisparityMap(left, right, baseMap, scale, 3);

  //disparityMap = denoiseMap(left, disparityMap, false, 50);

  //disparityMap = gaussianBlur(disparityMap, 4);

  //println("Correcting Disparity Map..");
  //disparityMap = disparityCorrection(left, disparityMap, 20);

  return disparityMap;
}
float[][] generateDisparityMap(PImage left, PImage right, float[][] baseMap, int baseMapScale, int window) {
  float[][] disparityMap = new float[left.height][left.width];

  for (int i = 0; i < left.height; i++) {
    if (i % 100 == 0)println("Row: " + i);
    for (int j = 0; j < disparityMap[i].length; j++) {
      int baseDisparity = (int)(j + baseMap[i / baseMapScale][j / baseMapScale] * baseMapScale);
      disparityMap[i][j] = pixelDisparity(left, right, j, i, baseDisparity - baseMapScale * 2, baseDisparity + baseMapScale * 2, window);
    }
  }

  return disparityMap;
}


float[][] generateDisparityMap(PImage left, PImage right, int window) {
  int maxDisparity = (left.width + left.height) / 2 / 5;

  float[][] disparityMap = new float[left.height][left.width];

  for (int i = 0; i < left.height; i++) {
    if (i % 100 == 0)println("Row: " + i);
    for (int j = 0; j < disparityMap[i].length; j++)
      disparityMap[i][j] = pixelDisparity(left, right, j, i, j - maxDisparity, j, window);
  }

  return disparityMap;
}

int pixelDisparity(PImage left, PImage right, int x, int y, int rangeMin, int rangeMax, int window) {
  int bestx = x, minCost = Integer.MAX_VALUE;
  for (int i = max(0, rangeMin); i < min(left.width, rangeMax); i++) {
    int cost = cost(left, right, x, i, y, window);
    if (cost < minCost) {
      minCost = cost;
      bestx = i;
    }
  }

  return bestx - x;
}


int cost(PImage left, PImage right, int xleft, int xright, int y, int window) {
  int sum = 0;

  for (int i = -window / 2; i <= window / 2; i++)
    for (int j = - window / 2; j <= window / 2; j++) {
      sum += colorDistance(left.get(xleft + j, y + i), right.get(xright + j, y + i));
    }

  return sum;
}
