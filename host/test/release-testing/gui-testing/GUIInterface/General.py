'''
Operations for general finding and manipulation
'''
import pyautogui
import os
__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findSplashscreen():
    '''
    Determine if Strata is open
    :return: None if unable to find.
    '''
    return pyautogui.locateOnScreen(os.path.join(__imagesPath, "StrataDeveloperStudioLoginBox.PNG"))
def findSplashLogo():
    '''
    Find logo for login/register screen
    :return: None if unable to find, coordnates of center of logo if able to find.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "SplashLogo.PNG"))


def deleteTextAt(location):
    '''
    Click on an input box at the given location and select and remove al text.
    :param location:
    :return:
    '''
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.hotkey('ctrl', 'a')
    pyautogui.press('backspace')

def inputTextAt(location, value):
    '''
    Click on an input box at the given location and input value.
    :param location:
    :param value:
    :return:
    '''
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.write(value)

def clickAt(location):
    '''
    Click a given location.
    :param location:
    :return:
    '''
    if location is not None:
        pyautogui.moveTo(location)
        pyautogui.click()
if __name__ == "__main__":
    findSplashscreen()