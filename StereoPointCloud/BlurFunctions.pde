float[][] gaussianBlur(float[][] map, int blurRadius) {
  float[][] gaussian = new float[map.length][map[0].length];
  for (int i = 0; i < map.length; i++) {
    for (int j = 0; j < map[0].length; j++) {
      gaussian[i][j] = average(map, j, i, blurRadius); //, 12 - 2 * blurRadius);
    }
  }

  return gaussian;
}

float average(float[][] map, int x, int y, int window) {
  int n = 0;
  window /= 2;
  float sum = 0;
  
  //println("___");
  for (int i = max(0, y - window); i < min(y + window, map.length); i++)
    for (int j = max(0, x - window); j < min(x + window, map[0].length); j++, n++)
        sum += map[i][j];
  
  return sum / n;
}

float relevantAverage(float[][] map, int x, int y, int window, float threshold) {
  window /= 2;
  window /= 2;
  float sum = 0;
  int n = 0;
  float avg  = average(map, x, y, window * 2);
  for (int i = max(0, y - window); i < min(y + window, map.length); i++)
    for (int j = max(0, x - window); j < min(x + window, map[0].length); j++) 
      if (!Float.isNaN(map[i][j]) && abs(map[i][j] - avg) < threshold) {
        sum += map[i][j];
        n++;
      } 

  return sum / n;
}
