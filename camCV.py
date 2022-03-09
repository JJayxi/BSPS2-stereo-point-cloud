import numpy as np
import cv2 as cv
left = cv.VideoCapture("/dev/video4")
#right = cv.VideoCapture("/dev/video0")
if not left.isOpened(): # or  not right.isOpened():
    print("Cannot open camera")
    exit()

while True:
    # Capture frame-by-frame
    retL, frameL = left.read()
    #retR, frameR = right.read()
    # if frame is read correctly ret is True
    if not retL: # or not retR:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    # Our operations on the frame come here
    grayL = cv.cvtColor(frameL, cv.COLOR_BGR2GRAY)
    #grayR = cv.cvtColor(frameR, cv.COLOR_BGR2GRAY)
    # Display the resulting frame
    cv.imshow('Left', grayL)
    #cv.imshow('Right', grayR)
    if cv.waitKey(1) == ord('q'):
        break
# When everything done, release the capture
#right.release()
left.release()
cv.destroyAllWindows()