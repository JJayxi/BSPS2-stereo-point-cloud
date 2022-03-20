float[][] disparity(PImage left, PImage right, int range, int windowX, int windowY) {
  float[][] disparityMap = new float[left.height][];
 //float[][] edgeStrength = edgeStrength(left);
  for (int i = 0; i < left.height; i++) {
    disparityMap[i] = rowDisparity(left, right, i, range, windowX, windowY);
    //disparityMap[i] = rowDisparityMonotone(left, right, i, range, windowX, windowY);
    //disparityMap[i] = rowDisparityEdges(left, right, edgeStrength[i], i, range, windowX, windowY);
    if (i % 50 == 0)println("Row: " + i);
  }

  return guassianBlur(disparityMap, 3);
}


/*
Computes the disparity of the points where the certainty and variance is high.
 
 Then computes the rest of the disparities, in a monotonical manner, meaning the order of the pixels remain 
 
 */
float[] rowDisparity(PImage left, PImage right, int y, int range, int windowX, int windowY) {
  float[] rowDisparity = new float[left.width];
  for (int i = 0; i < rowDisparity.length; i++) {
    rowDisparity[i] = disparityPoint(left, right, i, i - range, i + range, y, windowX, windowY, 30000, 600);
  }
  return rowDisparity;
}

float[] rowDisparityMonotone(PImage left, PImage right, int y, int range, int windowX, int windowY) {
  float[] rowDisparity = new float[left.width];
  float maxSsod = 900; //left.width * left.height * 100;
   rowDisparity[0] = disparityPoint(left, right, 0, 0, range, y, windowX, windowY, 30000, maxSsod);
   for (int i = 1; i < rowDisparity.length; i++) {
     if(rowDisparity[i - 1] != -128)
        rowDisparity[i] = disparityPoint(left, right, i, i + (int)rowDisparity[i - 1], i + range, y, windowX, windowY, 30000, maxSsod);
      else
        rowDisparity[i] = disparityPoint(left, right, i, i - range, i + range, y, windowX, windowY, 30000, maxSsod);
      
  }
 
  return rowDisparity;
}


float[] rowDisparityEdges(PImage left, PImage right, float[] edgeStrength, int y, int range, int windowX, int windowY) {
  float[] rowDisparity = new float[left.width];
  float maxSsod = 600; //left.width * left.height * 100;
   rowDisparity[0] = disparityPoint(left, right, 0, 0, range, y, windowX, windowY, 30000, maxSsod);
   for (int i = 1; i < rowDisparity.length; i++) {
     if(edgeStrength[i] > 50)
       rowDisparity[i] = disparityPoint(left, right, i, i - range, i + range, y, windowX, windowY, 30000, maxSsod);
     else
       rowDisparity[i] = -128;
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
    //if (abs(intensity(left, xleft, y) - intensity(right, i, y)) > 10)continue;
    float ssod = sumOfSquaredDifference(left, right, xleft, y, i, y, windowx, windowy);
    if (ssod < minValue) {
      minValue = ssod;
      minx = i;
    }
  }
  if (minValue == Float.MAX_VALUE)return -128;
  //if (minValue > maxSsod) return -128;
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
