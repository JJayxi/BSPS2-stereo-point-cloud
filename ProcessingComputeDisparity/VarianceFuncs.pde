float variance(PImage img, int x, int y, int windowX, int windowY) {
  int sumr = 0, sumg = 0, sumb = 0;
  for (int j = 0; j < windowY; j++) {
    for (int i = 0; i < windowX; i++) {
      sumr += img.get(i + x - windowX / 2, j + y - windowY / 2) >> 16 & 0xFF;
      sumg += img.get(i + x - windowX / 2, j + y - windowY / 2) >> 8 & 0xFF;
      sumb += img.get(i + x - windowX / 2, j + y - windowY / 2) & 0xFF;
    }
  }

  sumr /= windowX * windowY;
  sumg /= windowX * windowY;
  sumb /= windowX * windowY;

  float variancer = 0, varianceg = 0, varianceb = 0;
  for (int j = 0; j < windowY; j++) {
    for (int i = 0; i < windowX; i++) {
      float diff;
      diff = sumr - img.get(i + x - windowX / 2, j + y - windowY / 2) >> 16 & 0xFF;
      variancer += diff * diff;
      diff = sumg - img.get(i + x - windowX / 2, j + y - windowY / 2) >> 8 & 0xFF;
      varianceg += diff * diff;
      diff = sumb - img.get(i + x - windowX / 2, j + y - windowY / 2) & 0xFF;
      varianceb += diff * diff;
    }
  }

  return (variancer + varianceg + varianceb) / (windowX * windowY);
}
