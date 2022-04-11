float[][] findErrors(PImage left, PImage right, float[][] disparityMap, float threshold) {
  for (int i = 0; i < left.height; i++)
    for (int j = 0; j < left.width; j++) {
      color leftcol = left.get(j, i);
      color rightcol= right.get(j + (int)disparityMap[i][j], i);

      if (colorDistance(leftcol, rightcol) > threshold)
        disparityMap[i][j] = Float.NaN;
    }

  return disparityMap;
}

int colorDistance(color color1, color color2) {
  int sum = 0, diff = 0;
  //red
  diff = (color1 >> 16 & 0xFF) - (color2 >> 16 & 0xFF);
  sum += diff * diff;
  //green
  diff = (color1 >> 8 & 0xFF) - (color2 >> 8 & 0xFF);
  sum += diff * diff;
  //blue
  diff = (color1 & 0xFF) - (color2 & 0xFF);
  sum += diff * diff;
  return sum;
}

float[][] disparityCorrection(PImage image, float[][] disparityMap, float threshold) {
  float[][] verticalEdge = edgeStrength(image, true, true);

  for (int i = 0; i < image.height; i++) {
    disparityMap[i] = correctRow(verticalEdge[i], disparityMap[i], threshold);
  }

  return disparityMap;
}

float[] correctRow(float[] edgeStrengthRow, float[] disparityRow, float threshold) {
  int sectionStart = 0, i = 0;
  float startAverage = 0, endAverage = 0, sectionAverage = 0;
  int minSectionLength = 30;
  while (i < disparityRow.length) {
    while (i < disparityRow.length && abs(edgeStrengthRow[i]) < threshold) {
      sectionAverage += disparityRow[i];
      i++;
    }
    if(i == disparityRow.length)break;
    if(i - sectionStart > minSectionLength) {
      sectionAverage /= i - sectionStart;
      for(int j = sectionStart; j < sectionStart + 5; j++) {
        startAverage += disparityRow[j] / minSectionLength;
      }
      
      for(int j = i - 5; j <= i; j++) {
        endAverage += disparityRow[j] / minSectionLength;
      }
      
      for(int j = sectionStart; j <= i; j++) {
        disparityRow[j] = map(j, sectionStart, i, startAverage, endAverage);
      }
    }
    startAverage = 0;
    endAverage = 0;
    sectionStart = i;
    i++;
  }

  return disparityRow;
}
