import peasy.*;
PeasyCam cam;

PImage stereoImg, left, right;
PImage leftEdge, rightEdge;
PImage disparity;

int imgWidth, imgHeight;
ArrayList<Vector> pointCloud;
void setup() {
  size(900, 900, P3D);
  cam = new PeasyCam(this, 100);
  stereoImg = loadImage("images/stereo6.jpg");  //https://vision.middlebury.edu/stereo/data/scenes2021/
  stereoImg.resize(stereoImg.width / 7 , stereoImg.height / 7);
  imgWidth = stereoImg.width / 2;
  imgHeight = stereoImg.height;
  print(imgWidth + " / " + imgHeight);
  left = cutImage(stereoImg, 0, 0, imgWidth, stereoImg.height);
  right = cutImage(stereoImg, imgWidth, 0, imgWidth, stereoImg.height);

  //leftEdge = edgeImage(left);
  //rightEdge = edgeImage(right);
  //disparity = toImage(disparity(left, right, 30, 5, 5));

  ///image(disparity, 0, 0);
  image(right, imgWidth, 0);

  pointCloud = generate3D(left, right, imgWidth, imgHeight, 1, 4);
}

void showPointCloud() {
  background(0);
  strokeWeight(2);
  for (Vector v : pointCloud) {
    stroke(v.col);
    point(v.x, v.y, -v.z);
  }
}

void draw() {
  showPointCloud();
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
