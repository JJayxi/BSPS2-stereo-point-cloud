PImage cropImage(PImage original, int x, int y, int w, int h) {
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  for (int i = 0; i < h; i++)
    for (int j = 0; j < w; j++)
      img.pixels[i * w + j] = original.get(x + j, y + i);

  img.updatePixels();
  return img;
}

PImage copy(PImage image) {
  PImage img = createImage(image.width, image.height, RGB);
  img.loadPixels();
  for (int i = 0; i < image.height; i++)
    for (int j = 0; j < image.width; j++)
      img.pixels[i * image.width + j] = image.get(j, i);

  img.updatePixels();
  return img;
}

PImage disparityMapToImage(float[][] map, float imageScale) {
  float colorScale = imageScale * 2;
  PImage image = createImage(map[0].length, map.length, RGB);

  image.loadPixels();
  for (int i = 0; i < image.height; i++) {
    for (int j = 0; j < image.width; j++) {
      if (Float.isNaN(map[i][j])) 
        image.pixels[i * image.width + j] = color(255, 0, 0);
      else {
        float val = map[i][j] * colorScale + 255;
        image.pixels[i * image.width + j] = color(val, val, val);
      }
    }
  }
  image.updatePixels();
  return image;
}
