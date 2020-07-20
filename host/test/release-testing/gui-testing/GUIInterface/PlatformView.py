import GUIInterface.General as general
import pyautogui
import os
import GUIInterface.ScreenProperties as prop

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findPlatformView():
    '''
    Determine if Strata is at the platform list.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "PlatformViewFilterBig.PNG" if prop.LARGE_TEXT else "PlatformViewFilter.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)
def findUserIcon():
    '''
    Find the user settings icon.
    :return: None if unable to find, coordnates of center otherwise.
    '''

    #Use a lower confidence because the user icon could have a different letter. We are mainly looking for a round shape.
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewUser.PNG"), grayscale = True, confidence = .5)

def findLogout():
    '''
    Find the logout button. Assumes that the user's icon has been clicked on.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "PlatformViewLogoutBig.PNG" if prop.LARGE_TEXT else "PlatformViewLogout.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)

def findPlatformConnected():
    '''
    Determines if the Multipurpose Logic Gate view is open.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewPlatformConnected.PNG"), grayscale = True)

def findFeedbackButton():
    '''
    Find feedback button. Assumes that the user's icon has been clicked on.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "PlatformViewFeedbackBig.PNG" if prop.LARGE_TEXT else "PlatformViewFeedback.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)

def findFeedbackInput():
    '''
    Find feedback input field. Assumes feedback button has been clicked on.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackInput.PNG"), grayscale = True)

def findFeedbackSubmitEnabled():
    '''
    Find enabled feedback submit button. Assumes feedback button has been clicked on.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackSubmitEnabled.PNG"), confidence=0.9, grayscale = True)
def findFeedbackSubmitDisabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewFeedbackSubmitDisabled.PNG"), confidence = 0.9, grayscale = True)

def findFeedbackSuccess():
    '''
    Find feedback success window.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "PlatformViewFeedbackSuccessBig.PNG" if prop.LARGE_TEXT else "PlatformViewFeedbackSuccess.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)
def findFeedbackOk():
    '''
    Find the "Ok" button on a feedback success window.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "PlatformViewFeedbackOkBig.PNG" if prop.LARGE_TEXT else "PlatformViewFeedbackOk.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)

def findPlatformDisconnected():
    '''
    Find platform disconnected view
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewDisconnected.PNG"), grayscale = True)

def findPlatformList():
    '''
    Find if the platform list is populated by at least one element.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "PlatformViewPlatform.PNG"), grayscale = True)

def openFeedback():
    '''
    Open feedback. Assumes that the platform view is open and visible.
    :return:
    '''
    general.clickAt(findUserIcon())
    general.clickAt(findFeedbackButton())


def logout():
    '''
    Logout user. Assumes that the platform view is open and visible.
    :return:
    '''
    general.clickAt(findUserIcon())
    general.clickAt(findLogout())

    #Wait for start screen animation to play
    pyautogui.sleep(0.2)



if __name__ == "__main__":
    pyautogui.sleep(5)
    pyautogui.moveTo(findUserIcon())