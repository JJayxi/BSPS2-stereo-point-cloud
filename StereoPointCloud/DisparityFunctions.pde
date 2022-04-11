float[][] iterativeDisparityMap(PImage left, PImage right, int scale) {  
  PImage leftRescaled = copy(left);
  leftRescaled.resize(left.width / scale + 1, left.height / scale + 1);
  
  PImage rightRescaled = copy(right);
  rightRescaled.resize(right.width / scale + 1, right.height / scale + 1);
  
  println("Generating Base Map..");
  float[][] baseMap = generateDisparityMap(leftRescaled, rightRescaled, 6);
  baseMap = denoiseMap(leftRescaled, baseMap, false, 6);
  baseMap = gaussianBlur(baseMap, scale); 
  
  println("Generating Disparity Map..");
  float[][] disparityMap = generateDisparityMap(left, right, baseMap, scale, 4);
  
  //disparityMap = denoiseMap(left, disparityMap, false, 50);
  
  //disparityMap = gaussianBlur(disparityMap, 4);
  
  //println("Correcting Disparity Map..");
  //disparityMap = disparityCorrection(left, disparityMap, 20);
  
  return disparityMap;
}
float[][] generateDisparityMap(PImage left, PImage right, float[][] baseMap, int baseMapScale, int window) {
  float maxDisparity = 0.13 * (left.width + left.height) / 2; //13% of image size
  float[][] disparityMap = new float[left.height][];
  
  for(int i = 0; i < left.height; i++) {
    if (i % 50 == 0)println("Row: " + i);
    disparityMap[i] = rowDisparity(left, right, i, baseMap[i / baseMapScale], baseMapScale, maxDisparity, window); 
  }
  
  return disparityMap;
}


float[][] generateDisparityMap(PImage left, PImage right, int window) {
  float maxDisparity = 0.05 * (left.width + left.height) / 2; //13% of image size
  
  float[][] disparityMap = new float[left.height][];
  
  for(int i = 0; i < left.height; i++) {
    if (i % 50 == 0)println("Row: " + i);
    disparityMap[i] = rowDisparity(left, right, i, maxDisparity, window); 
  }
  
  return disparityMap;
}


float[] rowDisparity(PImage left, PImage right, int y, float[] baseDisparity, int baseMapScale, float maxDisparity, int window) {
  float[] disparityRow = new float[left.width];
  for(int i = 0; i < disparityRow.length; i++) {
    if(Float.isNaN(baseDisparity[i / baseMapScale])) {
      disparityRow[i] = pointDisparity(left, right, i, y, i - maxDisparity, i, window);
    } else {
      float bestBaseDisparity = i + baseDisparity[i / baseMapScale] * baseMapScale;
      disparityRow[i] = pointDisparity(left, right, i, y, bestBaseDisparity - baseMapScale, bestBaseDisparity + baseMapScale, window);
    }
  }
  
  return disparityRow;
}



float[] rowDisparity(PImage left, PImage right, int y, float maxDisparity, int window) {
  float[] disparityRow = new float[left.width];
  
  for(int i = 0; i < disparityRow.length; i++)
     disparityRow[i] = pointDisparity(left, right, i, y,  i - maxDisparity, i, window);
  
  return disparityRow;
}

float pointDisparity(PImage left, PImage right, int x, int y, float minbestx, float maxbestx, int window) {
  float bestx = x;
  float minCost = Float.MAX_VALUE;
  //println("Min: " + minbestx + " / Max: " + maxbestx);
  for(int i = floor(max(0, minbestx)); i <= ceil(min(left.width, maxbestx)); i++) {
     float cost = sumOfSquaredDifference(left, right, x, i, y, window);
     if (cost < minCost) {
       minCost = cost;
       bestx = i;
     }
  }
  
  return bestx - x;
}


float sumOfSquaredDifference(PImage left, PImage right, int xleft, int xright, int y, int window) {
  int sum = 0;

  for (int i = -window / 2; i <= window / 2; i++)
    for (int j = - window / 2; j <= window / 2; j++) {
      int diff;
      diff = (left.get(xleft + j, y + i) >> 16 & 0xFF) - (right.get(xright + j, y + i) >> 16 & 0xFF);
      sum += diff * diff;

      diff = (left.get(xleft + j, y + i) >> 8 & 0xFF) - (right.get(xright + j, y + i) >> 8 & 0xFF);
      sum += diff * diff;

      diff = (left.get(xleft + j, y + i) & 0xFF) - (right.get(xright + j, y + i) & 0xFF);
      sum += diff * diff;
    }

  return sum / (window * window * 3);
}
