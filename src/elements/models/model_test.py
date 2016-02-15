import argparse
import numpy as np
import cv2
import os

parser = argparse.ArgumentParser(description='Test all of the subsystems')
parser.add_argument('test_file', help='The file you want to run through')

args = parser.parse_args()

subsystems = ['resistor']

model_list = []

for subsystem in subsystems:
    model_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), subsystem, "model", "cascade.xml")

    assert(os.path.exists(model_file))

    classifier = cv2.CascadeClassifier(model_file)
    model_list.append(classifier)
    
img = cv2.imread(os.path.abspath(args.test_file))
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

results = []
for classifier in model_list:
    items = classifier.detectMultiScale(gray, 1.3, 5)

    for (x,y,w,h) in items:
        cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)      
    

cv2.imshow('img',img)
cv2.waitKey(0)
cv2.destroyAllWindows()