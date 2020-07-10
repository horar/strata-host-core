'''
Operations for finding and manipulating login related UI elements.
'''
import pyautogui
import os
import GUIInterface.General as general
import GUIInterface.ScreenProperties as prop

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')


#Finding functions
def findLoginSubmitEnabled():
    '''
    Find an enabled login button.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitEnabled.PNG"), grayscale = True)
def findLoginSubmitDisabled():
    '''
    Find a disabled login button
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginSubmitDisabled.PNG"), grayscale = True)

def findLoginTabButton():
    '''
    Find the login tab button.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "TabBarLoginBig.PNG" if prop.LARGE_TEXT else "TabBarLogin.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)

def findUsernameInput():
    '''
    Find the input for the user's username
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginUsernameInput.PNG"), grayscale = True)

def findPasswordInput():
    '''
    Find the input for the user's password.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginPasswordInput.PNG"), grayscale = True)


def findResetPassword():
    '''
    Find the forgot password button..
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "LoginForgotPasswordBig.PNG" if prop.LARGE_TEXT else "LoginForgotPassword.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)

def findResetPasswordInput():
    '''
    Find the input for the reset password username.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordInput.PNG"), grayscale = True)

def findResetPasswordSubmitDisabled():
    '''
    Find the submit button in the reset password dialog, disabled.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordSubmitDisabled.PNG"), grayscale = True)

def findResetPasswordSubmitEnabled():
    '''
    Find the submit button in the reset password dialog, enabled.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordSubmitEnabled.PNG"), grayscale = True)

def findResetPasswordSuccess():
    '''
    Find the reset password success tooltip.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordSuccess.PNG"), grayscale = True)

def findResetPasswordFail():
    '''
    Find the reset password fail tooltip
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordFail.PNG"), grayscale = True)

def findResetPasswordClose():
    '''
    Find the reset password dialog close button.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginResetPasswordClose.PNG"), grayscale = True)

def findLoginError():
    '''
    Find the error that appears if invalid login information is given.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginInvalidUsernamePasswordError.PNG"), grayscale = True)
def findNetworkError():
    '''
    Find the error that appears if the network is not connected.
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "LoginNetworkError.PNG"), grayscale = True)

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