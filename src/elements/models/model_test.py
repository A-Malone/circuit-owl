import argparse
import numpy as np
import cv2

parser = argparse.ArgumentParser(description='Test all of the subsystems')
parser.add_argument('test_file', help='The file you want to run through')

args = parser.parse_args()

subsystems = ['resistor']

model_list = []

for subsystem in subsystems:
    model_file = os.path.join(os.path.abspath(__file__), subsystem, "model", "cascade.xml")

    classifier = cv2.CascadeClassifier('model_file')
    model_list += classifier
    
img = cv2.imread(os.path.abspath(args.test_file))
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

items = []
for classifier in model_list:
    items += classifier.detectMultiScale(gray, 1.3, 5)

for (x,y,w,h) in items:
    cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
    roi_gray = gray[y:y+h, x:x+w]
    roi_color = img[y:y+h, x:x+w]
    eyes = eye_cascade.detectMultiScale(roi_gray)
    for (ex,ey,ew,eh) in eyes:
        cv2.rectangle(roi_color,(ex,ey),(ex+ew,ey+eh),(0,255,0),2)

cv2.imshow('img',img)
cv2.waitKey(0)
cv2.destroyAllWindows()