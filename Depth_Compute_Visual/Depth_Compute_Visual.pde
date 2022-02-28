PVector camPos, camDirection;
float camDist, camDepth, camsWidth;
float featureLeft, featureRight;


void setup() {
  size(600, 600); 
  camPos = new PVector(300, 500);
  camDirection = new PVector(0, -1);
  camDist = 150;
  camsWidth = 80;
  camDepth = 50;
  featureLeft = 0.53;
  featureRight = 0.24;
}

PVector trigComp(PVector pos, float angle, float dist) {
  return new PVector(pos.x + cos(angle) * dist, pos.y + sin(angle) * dist);
}


void draw() {
  background (44);
  camDist = 159;
  camsWidth = 84;
  camDepth = 67;
  featureLeft = 0.92;
  featureRight = 0.33;

  //cams
  stroke(255);
  strokeWeight(3);

  float angle = atan2(camDirection.y, camDirection.x);
  PVector 
    leftCamL  = trigComp(camPos, angle - PI / 2, camDist / 2 + camsWidth), 
    leftCamR  = trigComp(camPos, angle - PI / 2, camDist / 2), 
    rightCamL = trigComp(camPos, angle + PI / 2, camDist / 2), 
    rightCamR = trigComp(camPos, angle + PI / 2, camDist / 2 + camsWidth);

  line(leftCamL.x, leftCamL.y, leftCamR.x, leftCamR.y);
  line(rightCamL.x, rightCamL.y, rightCamR.x, rightCamR.y);
  //point cams
  stroke(230, 30, 30);
  noFill();
  PVector
    leftCamPoint  = trigComp(trigComp(camPos, angle - PI / 2, camDist / 2 + camsWidth / 2), angle + PI, camDepth), 
    rightCamPoint = trigComp(trigComp(camPos, angle + PI / 2, camDist / 2 + camsWidth / 2), angle + PI, camDepth);
  ellipse(leftCamPoint.x, leftCamPoint.y, 30, 30);
  ellipse(rightCamPoint.x, rightCamPoint.y, 30, 30);
  
  //featurePos
  stroke(#AB2AF2);
  PVector 
  featureLeftPos  = new PVector(lerp(leftCamL.x, leftCamR.x, featureLeft), lerp(leftCamL.y, leftCamR.y, featureLeft)),
  featureRightPos = new PVector(lerp(rightCamL.x, rightCamR.x, featureRight), lerp(rightCamL.y, rightCamR.y, featureRight));
  ellipse(featureLeftPos.x , featureLeftPos.y , 10, 10);
  ellipse(featureRightPos.x, featureRightPos.y, 10, 10);
  //view lines
  
  strokeWeight(1);
  stroke(150);
  PVector leftFeatureDir  = PVector.sub(featureLeftPos,  leftCamPoint );
  PVector rightFeatureDir = PVector.sub(featureRightPos, rightCamPoint);
  leftFeatureDir.setMag(1);
  rightFeatureDir.setMag(1);
  line(leftCamPoint.x, leftCamPoint.y, leftCamPoint.x + leftFeatureDir.x * 2 * width, leftCamPoint.y + leftFeatureDir.y * 2 * width);
  line(rightCamPoint.x, rightCamPoint.y, rightCamPoint.x + rightFeatureDir.x * 2 * width, rightCamPoint.y + rightFeatureDir.y * 2 * width);
  
  /////solve intersection
  //find function representing view lines
  //For left view line : tan2(leftFeatureDir ) * (x - leftCamPoint.x) + leftCamPoint.y
  //For right view line: tan2(rightFeatureDir) * (x - rightCamPoint.x) + rightCamPoint.y
  // solve: tan2(leftFeatureDir ) * (x - leftCamPoint.x ) + leftCamPoint.y = tan2(rightFeatureDir) * (x - rightCamPoint.x) + rightCamPoint.y
  float leftSlope =leftFeatureDir.y / leftFeatureDir.x, rightSlope = rightFeatureDir.y / rightFeatureDir.x;
  float xIntersection = (-rightSlope * rightCamPoint.x + rightCamPoint.y  + leftSlope * leftCamPoint.x - leftCamPoint.y)/(leftSlope - rightSlope);
  float yIntersection = leftSlope * (xIntersection -  leftCamPoint.x ) + leftCamPoint.y;
  
  noStroke();
  fill(250, 50, 50);
  ellipse(xIntersection, yIntersection, 10, 10);
}
