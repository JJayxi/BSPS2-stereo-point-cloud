import peasy.*;
PeasyCam cam;

PImage stereoImg, left, right;
PImage leftEdge, rightEdge;
PImage disparity;

int imgWidth, imgHeight;
ArrayList<Vector> pointCloud;
void setup() {
  size(900, 900, P3D);
  //cam = new PeasyCam(this, 100);
  stereoImg = loadImage("images/stereo3.jpg");
  stereoImg.resize(stereoImg.width, stereoImg.height);
  imgWidth = stereoImg.width / 2;
  imgHeight = stereoImg.height;
  print(imgWidth + " / " + imgHeight);
  left = cutImage(stereoImg, 0, 0, imgWidth, stereoImg.height);
  right = cutImage(stereoImg, imgWidth, 0, imgWidth, stereoImg.height);

  //leftEdge = edgeImage(left);
  //rightEdge = edgeImage(right);
  disparity = toImage(disparity(left, right, 30, 5, 5));

  image(disparity, 0, 0);
  image(right, imgWidth, 0);

  //pointCloud = generate3D(left, right, imgWidth, imgHeight, 1, 300);
}

void showPointCloud() {
  background(0);
  strokeWeight(5);
  for (Vector v : pointCloud) {
    stroke(v.col);
    point(v.x, v.y, -v.z);
  }
}

void draw() {

  //left = cutImage(stereoImg, 0, 0, imgWidth, stereoImg.height);
  //right = cutImage(stereoImg, imgWidth, 0, imgWidth, stereoImg.height);

  //image(left, 0, 0);
  //image(right, imgWidth, 0);
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
  float xangle = atan((x / (imageHeight / 2) - 1) / focalLength);
  float yangle = atan((y / (imageHeight / 2) - 1) / focalLength);
  float depth  = disparityToDepth(disparity, focalLength, camDistance) + 500;
  Vector point = new Vector(tan(xangle) * depth, tan(yangle) * depth, depth - 500);
  return point;
}

float disparityToDepth(float disparity, float focalLength, float camDistance) {
  return focalLength * camDistance / abs(disparity);
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
  //if(variance(left, xleft, y, windowx, windowy) < 80000)return -128;

  for (int i = max(0, xleft - range); i < min(imgWidth, xleft + range); i++) {
    float ssod = sumOfSquaredDifference(left, right, xleft, y, i, y, windowx, windowy);
    if (ssod < minValue) {
      minValue = ssod;
      minx = i;
    }
  }
  if (minValue > 800) return -128;
  return minx - xleft;
}

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
      sum += (img.get(j + x - convolution.length / 2, i + y - convolution[0].length / 2) & 0x0000FF) * convolution[y][x];
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
    }

  return sum / (float)(windowWidth * windowHeight * 3);
}
