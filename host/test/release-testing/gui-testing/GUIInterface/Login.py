'''
Operations for finding and manipulating login related UI elements.
'''
import pyautogui
import os
import GUIInterface.General as general

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

#Finding functions
def findLoginSubmitEnabled():
    '''
    Find an enabled login button.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitEnabled.PNG"))
def findLoginSubmitDisabled():
    '''
    Find a disabled login button
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitDisabled.PNG"))

def findLoginTabButton():
    '''
    Find the login tab button.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "TabBarLogin.PNG"))

def findUsernameInput():
    '''
    Find the input for the user's username
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginUsernameInput.PNG"))

def findPasswordInput():
    '''
    Find the input for the user's password.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginPasswordInput.PNG"))

def findLoginButtonToolTip():
    pass

def findLoginError():
    '''
    Find the error that appears if invalid login information is given.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginInvalidUsernamePasswordError.PNG"))
#Manipulation functions

def setToLoginTab():
    '''
    Click on the login tab button.
    Assumes that login/register page is open and visible.
    :return:
    '''
    general.clickAt(findLoginTabButton())

def login(username, password):
    general.inputTextAt(findUsernameInput(), username)
    general.inputTextAt(findPasswordInput(), password)

    # Submit username/password
    general.clickAt(findLoginSubmitEnabled())


if __name__ == "__main__":
    findLoginTabButton()