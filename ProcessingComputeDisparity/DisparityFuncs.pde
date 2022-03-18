int[][] disparity(PImage left, PImage right, int range, int windowX, int windowY) {
  int[][] disparityMap = new int[left.height][];
  for (int i = 0; i < left.height; i++) {
    disparityMap[i] = rowDisparity(left, right, i, range, windowX, windowY);
    if (i % 50 == 0)println("Row: " + i);
  }

  return disparityMap;
}

int[] rowDisparity(PImage left, PImage right, int y, int range, int windowX, int windowY) {
  int[] rowDisparity = new int[imgWidth];
  for (int i = 0; i < rowDisparity.length; i++) {
    rowDisparity[i] = disparityPoint(left, right, i, y, range, windowX, windowY);
  }
  return rowDisparity;
}


int disparityPoint(PImage left, PImage right, int xleft, int y, int range, int windowx, int windowy) {
  int minx = xleft;
  float minValue = Float.MAX_VALUE;
  if(variance(left, xleft, y, windowx, windowy) < 40000)return -128;

  for (int i = max(0, xleft - range); i < min(imgWidth, xleft + range); i++) {
    float ssod = sumOfSquaredDifference(left, right, xleft, y, i, y, windowx, windowy);
    if (ssod < minValue) {
      minValue = ssod;
      minx = i;
    }
  }
  if (minValue > 900) return -128;
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
