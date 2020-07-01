'''
Operations for finding and manipulating login related UI elements.
'''
import pyautogui
import os

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

#Finding functions
def findLoginSubmitEnabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitEnabled.PNG"))
def findLoginSubmitDisabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitDisabled.PNG"))

def findLoginTabButton():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "TabBarLogin.PNG"), confidence = 0.5)

def findUsernameInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginUsernameInput.PNG"))
def findPasswordInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginPasswordInput.PNG"))

def findLoginButtonToolTip():
    pass

def findLoginError():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginInvalidUsernamePasswordError.PNG"))
#Manipulation functions
def setToLoginTab():
    pyautogui.moveTo(findLoginTabButton())
    pyautogui.click()



if __name__ == "__main__":
    findLoginTabButton()