import GUIInterface.General as general
import pyautogui
import os

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findPlatformView():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewLogo.PNG"))
def findUserIcon():
    #Use a lower confidence because the user icon could have a different letter. We are mainly looking for a round shape.
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewUser.PNG"), grayscale = True, confidence = .5)
def findLogout():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewLogout.PNG"))
def findLogicGateView():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformLogicGateView.PNG"))

def findFeedbackButton():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedback.PNG"))

def findFeebackInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackInput.PNG"))

def findFeedbackSubmitEnabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackSubmitEnabled.PNG"))

def findFeedbackSuccess():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackSuccess.PNG"))

def findFeedbackOk():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackOk.PNG"))

def openFeedback():
    general.clickAt(findUserIcon())
    general.clickAt(findFeedbackButton())


def logout():
    general.clickAt(findUserIcon())
    general.clickAt(findLogout())

if __name__ == "__main__":
    pyautogui.sleep(5)
    pyautogui.moveTo(findUserIcon())