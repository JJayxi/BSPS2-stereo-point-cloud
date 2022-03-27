float[][] findErrors(PImage left, PImage right, float[][] disparityMap, float threshold) {
  for (int i = 0; i < left.height; i++)
    for (int j = 0; j < left.width; j++) {
      color leftcol = left.get(j, i);
      color rightcol= right.get(j + (int)disparityMap[i][j], i);

      if (colorDistanceSquared(leftcol, rightcol) > threshold)
        disparityMap[i][j] = Float.NaN;
    }

  return disparityMap;
}

float colorDistanceSquared(color color1, color color2) {
  return pow(red(color1) - red(color2), 2) + pow(red(color1) - red(color2), 2) + pow(red(color1) - red(color2), 2);
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
