PImage stereoImg, left, right;
PImage leftEdge, rightEdge;
PImage disparity;

int imgWidth, imgHeight;
ArrayList<Vector> pointCloud;
void setup() {
  size(960, 569, P3D);
  stereoImg = loadImage("images/stereo2.jpg");
  stereoImg.resize(stereoImg.width / 3, stereoImg.height / 3);
  imgWidth = stereoImg.width / 2;
  imgHeight = stereoImg.height;
  print(imgWidth + " / " + imgHeight);
  left = cutImage(stereoImg, 0, 0, imgWidth, stereoImg.height);
  right = cutImage(stereoImg, imgWidth, 0, imgWidth, stereoImg.height);

  leftEdge = edgeImage(left);
  rightEdge = edgeImage(right);
  disparity = toImage(disparity(left, right, 30, 8, 8));

  image(disparity, 0, 0);
  image(right, imgWidth, 0);
  
  pointCloud = generate3D(left, right, imgWidth, imgHeight, 1, 200);
}

void draw() {
  for(Vector v : pointCloud) {
    stroke(v.col);
    point(v.x, v.y, v.z);
  }
}


PImage cutImage(PImage original, int x, int y, int w, int h) {
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w; j++) {
      color c = original.get(x + j, y + i);
      img.pixels[i * w + j] = c; //color(0.299 * red(c) + 0.587 * green(c) + 0.114 * blue(c));
    }
  }
  img.updatePixels();
  return img;
}


ArrayList<Vector> generate3D(PImage left, PImage right, int imageWidth, int imageHeight, float focalLength, float camDistance) {
  ArrayList<Vector> points = new ArrayList<Vector>();

  int[][] disparityMap = disparity(left, right, 30, 5, 5);
  for (int i = 0; i < imageHeight; i++) {
    for (int j = 0; j < imageWidth; j++) {
      if (disparityMap[i][j] != -128) {
        Vector point = positionFromDisparity(disparityMap[i][j], j, i, imageWidth, imageHeight, focalLength, camDistance);
        point.col = left.get(j, i);
        points.add(point);
      }
    }
  }

  return points;
}

Vector positionFromDisparity(float disparity, float x, float y, int imageWidth, int imageHeight, float focalLength, float camDistance) {
  float xangle = atan((x / imageHeight / 2 - imageHeight / 2) / focalLength);
  float yangle = atan((y / imageHeight / 2 - imageHeight / 2) / focalLength);
  float depth  = disparityToDepth(disparity, focalLength, camDistance);
  Vector point = new Vector(sin(xangle) * depth, sin(yangle) * depth, cos(yangle) * depth);
  return point;
}

float disparityToDepth(float disparity, float focalLength, float camDistance) {
  return focalLength * camDistance / disparity;
}

PImage edgeImage(PImage img) {
  float[][] hor = convolute(horizontalEdge, img);
  float[][] ver = convolute(verticalEdge, img);

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

PImage toImage(int[][] map) {
  PImage img = createImage(map[0].length, map.length, RGB);
  img.loadPixels();
  for (int i = 0; i < img.height; i++) {
    for (int j = 0; j < img.width; j++) {
      img.pixels[i * img.width + j] = color(map[i][j] + 128, 0, 0);
    }
  }
  img.updatePixels();
  return img;
}

int[][] disparity(PImage left, PImage right, int range, int windowX, int windowY) {
  int[][] disparityMap = new int[left.height][];
  for (int i = 0; i < left.height; i++) {
    disparityMap[i] = rowDisparity(left, right, i, range, windowX, windowY);
    println("Row: " + i);
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
  for (int i = max(0, xleft - range); i < min(imgWidth, xleft + range); i++) {
    float ssod = sumOfSquaredDifference(left, right, xleft, y, i, y, windowx, windowy);
    if (ssod < minValue) {
      minValue = ssod;
      minx = i;
    }
  }
  if (minValue > 500) return -128;
  return minx - xleft;
}


float[][] horizontalEdge = {{1, 1, 1}, {0, 0, 0}, {-1, -1, -1}};
float[][] verticalEdge = {{1, 0, -1}, {1, 0, -1}, {1, 0, -1}};

float[][] convolute(float[][] convolution, PImage img) {
  float[][] convoluted = new float[img.height][img.width];
  for (int j = 0; j < img.height; j++) {
    for (int i = 0; i < img.width; i++) {
      convoluted[j][i] = convolutePixel(convolution, img, i, j);
    }
  }
  return convoluted;
}

float convolutePixel(float[][] convolution, PImage img, int j, int i) {
  float sum = 0;
  for (int y = 0; y < convolution.length; y++) {
    for (int x = 0; x < convolution[0].length; x++) {
      sum += (img.get(j + x - convolution.length, i + y - convolution[0].length / 2) & 0x0000FF) * convolution[y][x];
    }
  }
  return sum;
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

      //sum += Math.pow(red(left.get(xl + j, yl + i))  - red(right.get(xr + j, yr + i)), 2) * 0.299;
      //sum += Math.pow(green(left.get(xl + j, yl + i))- green(right.get(xr + j, yr + i)), 2) * 0.587;
      //sum += Math.pow(blue(left.get(xl + j, yl + i)) - blue(right.get(xr + j, yr + i)), 2) * 0.114;
    }

  return sum / (float)(windowWidth * windowHeight * 3);
}
