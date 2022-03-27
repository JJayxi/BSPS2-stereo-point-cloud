float[][] horizontalEdgeConvolution = {{1, 1, 1}, {0, 0, 0}, {-1, -1, -1}};
float[][] verticalEdgeConvolution = {{1, 0, -1}, {1, 0, -1}, {1, 0, -1}};

PImage edgeImage(PImage img) {
  float[][] hor = convolute(horizontalEdgeConvolution, img);
  float[][] ver = convolute(verticalEdgeConvolution, img);

  colorMode(HSB);

  PImage edges = createImage(img.width, img.height, RGB);
  edges.loadPixels();
  for (int j = 0; j < img.height; j++) {
    for (int i = 0; i < img.width; i++) {

      edges.pixels[j * img.width + i] = color((atan2(hor[j][i], ver[j][i]) + PI) / TWO_PI * 255, 255, abs(hor[j][i]) + abs(ver[j][i]));
    }
  }
  edges.updatePixels();
  colorMode(RGB);

  return edges;
}

float[][] edgeStrength(PImage img, boolean horizontal, boolean vertical) {
  if(horizontal && !vertical)return convolute(horizontalEdgeConvolution, img);
  if(vertical && !horizontal)return convolute(verticalEdgeConvolution, img);
  float[][] hor = convolute(horizontalEdgeConvolution, img);
  float[][] ver = convolute(verticalEdgeConvolution, img);
  
  float[][] strength = new float[img.height][img.width];
  for (int j = 0; j < img.height; j++)
    for (int i = 0; i < img.width; i++)
      strength[j][i] = sqrt(hor[j][i]*hor[j][i] + ver[j][i]*ver[j][i]); 
  
  return strength;
}

float[][] convolute(float[][] convolution, PImage img) {
  float[][] convoluted = new float[img.height][img.width];
  for (int j = 0; j < img.height; j++)
    for (int i = 0; i < img.width; i++)
      convoluted[j][i] = convolutePixel(convolution, img, i, j);

  return convoluted;
}

float convolutePixel(float[][] convolution, PImage img, int j, int i) {
  float sum = 0;
  for (int y = 0; y < convolution.length; y++) {
    for (int x = 0; x < convolution[0].length; x++) {
      sum += brightness(img.get(j + x - convolution.length / 2, i + y - convolution[0].length / 2)) * convolution[y][x];
    }
  }
  return sum;
}
