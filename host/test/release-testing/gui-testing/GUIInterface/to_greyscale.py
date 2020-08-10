'''
Utility to convert all the images in the "images" folder to greyscale.
'''
import cv2
import os

for filename in os.listdir("images"):
    if filename.endswith(".PNG"):
        colorImage = cv2.imread(os.path.join("images", filename))
        greyImage = cv2.cvtColor(colorImage, cv2.COLOR_BGR2GRAY)
        cv2.imwrite(os.path.join("images", filename), greyImage)
