
float[][] guassianBlur(float[][] map, int blurRadius) {
  float[][] gaussian = new float[map.length][map[0].length];
  for (int i = 0; i < map.length; i++) {
    for (int j = 0; j < map[0].length; j++) {
      gaussian[i][j] = relevantAverage (map, j, i, blurRadius, blurRadius);
      if(Float.isNaN(gaussian[i][j]))gaussian[i][j] = -128;
    }
  }

  return gaussian;
}

float relevantAverage(float[][] map, int x, int y, int windowX, int windowY) {
  windowX /= 2;
  windowY /= 2;
  float sum = 0;
  int n = 0;
  float avg  = average(map, x, y, windowX * 2, windowY * 2);
  for (int i = max(0, y - windowY); i < min(y + windowY, map.length); i++) { //
    for (int j = max(0, x - windowX); j < min(x + windowX, map[0].length); j++) {//
      
      if (map[i][j] != -128 && abs(map[i][j] - avg) < 4) {
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
      if(map[i][j] != -128) {
        sum += map[i][j];
        n++;
      }
    }
  }
  
  return sum / n;
}
