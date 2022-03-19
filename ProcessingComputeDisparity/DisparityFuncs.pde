float[][] disparity(PImage left, PImage right, int range, int windowX, int windowY) {
  float[][] disparityMap = new float[left.height][];
  for (int i = 0; i < left.height; i++) {
    disparityMap[i] = rowDisparity(left, right, i, range, windowX, windowY);
    if (i % 50 == 0)println("Row: " + i);
  }

  return guassianBlur(disparityMap, 2);
}

float[][] guassianBlur(float[][] map, int blurRadius) {
  float[][] guassian = new float[map.length][map[0].length];
  for (int i = 0; i < map.length; i++) {
    for (int j = 0; j < map[0].length; j++) {
      guassian[i][j] = relevantAverage(map, j, i, blurRadius, blurRadius);
    }
  }

  return guassian;
}

float relevantAverage(float[][] map, int x, int y, int windowX, int windowY) {
  windowX /= 2;
  windowY /= 2;
  float sum = 0;
  int n = 0;
  
  for (int i = max(0, y - windowY); i < min(y + windowY, map.length); i++) { //
    for (int j = max(0, x - windowX); j < min(x + windowX, map[0].length); j++) {//
      
      if (map[i][j] != -128 && abs(map[i][j] - average(map, j, i, windowX * 2, windowY * 2)) < 40) {
        sum += map[i][j];
        n++;
      }
    }
  }
  return sum / n;
}


float average(float[][] map, int x, int y, int windowX, int windowY) {
  windowX /= 2;
  windowY /= 2;
  float sum = 0;
  int n = 0;
  //println("___");
  for (int i = max(0, y - windowY); i < min(y + windowY, map.length); i++) { //
    for (int j = max(0, x - windowX); j < min(x + windowX, map[0].length); j++) {//
      //println("Wx: " + j + " / Wy: " + i);
      sum += map[i][j];
      n++;
    }
  }
  
  return sum / n;
}

/*
Computes the disparity of the points where the certainty and variance is high.
 
 Then computes the rest of the disparities, in a monotonical manner, meaning the order of the pixels remain 
 
 */
float[] rowDisparity(PImage left, PImage right, int y, int range, int windowX, int windowY) {
  float[] rowDisparity = new float[imgWidth];
  for (int i = 0; i < rowDisparity.length; i++) {
    rowDisparity[i] = disparityPoint(left, right, i, i - range, i + range, y, windowX, windowY, 30000, 600);
  }
  return rowDisparity;
}


/*
Computes the disparity at a specific point. Searches on the other image form xmin to xmax
 */
int disparityPoint(PImage left, PImage right, int xleft, int xmin, int xmax, int y, int windowx, int windowy, float minVariance, float maxSsod) {
  int minx = xleft;
  float minValue = Float.MAX_VALUE;
  //if(variance(left, xleft, y, windowx, windowy) < minVariance)return -128;

  for (int i = max(0, xmin); i < min(imgWidth, xmax); i++) {
    if (abs(intensity(left, xleft, y) - intensity(right, i, y)) > 15)continue;
    float ssod = sumOfSquaredDifference(left, right, xleft, y, i, y, windowx, windowy);
    if (ssod < minValue) {
      minValue = ssod;
      minx = i;
    }
  }
  if (minValue == Float.MAX_VALUE)return -128;
  if (minValue > maxSsod) return -128;
  return minx - xleft;
}



float sumOfSquaredDifference(PImage left, PImage right, int xl, int yl, int xr, int yr, int windowWidth, int windowHeight) {
  int sum = 0;

  for (int i = -windowHeight / 2; i <= windowHeight / 2; i++)
    for (int j = - windowHeight / 2; j <= windowWidth / 2; j++) {
      //sum += Math.pow(left.get(xl + j, yl + i) & 0x0000FF - right.get(xr + j, yr + i) & 0x0000FF, 2);
      int diff;
      diff = (left.get(xl + j, yl + i)  >> 16 & 0xFF)  - (right.get(xr + j, yr + i) >> 16 & 0xFF);
      sum += diff * diff;

      diff = (left.get(xl + j, yl + i)  >> 8 & 0xFF)  - (right.get(xr + j, yr + i) >> 8 & 0xFF);
      sum += diff * diff;

      diff = (left.get(xl + j, yl + i) & 0xFF)  - (right.get(xr + j, yr + i) & 0xFF);
      sum += diff * diff;
    }

  return sum / (float)(windowWidth * windowHeight * 3);
}
