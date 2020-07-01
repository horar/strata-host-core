'''
Operations for general finding and manipulation
'''
import pyautogui
import os
__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findSplashscreen():
    return pyautogui.locateOnScreen(os.path.join(__imagesPath, "StrataDeveloperStudioLoginBox.PNG"))
def findSplashLogo():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "SplashLogo.PNG"))


def deleteTextAt(location):
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.hotkey('ctrl', 'a')
    pyautogui.press('backspace')

def inputTextAt(location, value):
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.write(value)

def clickAt(location):
    pyautogui.moveTo(location)
    pyautogui.click()

if __name__ == "__main__":
    findSplashscreen()