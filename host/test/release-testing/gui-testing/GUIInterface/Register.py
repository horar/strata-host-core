import GUIInterface.General as general
import pyautogui
import os
import uuid
import GUIInterface.ScreenProperties as prop

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')
def findRegister():
    '''
    Determine if on the register page
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return findRegisterAgreeCheckbox()
def findRegisterTabButton():
    '''
    Find register tab select
    :return: None if unable to find, coordnates of center otherwise.
    '''
    path = "TabBarRegisterBig.PNG" if prop.LARGE_TEXT else "TabBarRegister.PNG"
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, path), grayscale = True)
def findUserAlreadyExists():
    '''
    Find "user already exists" error message
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterAccountAlreadyExists.PNG"), confidence = 0.9, grayscale = True)
def findRegisterAgreeCheckbox():
    '''
    Find agree checkbox for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterAgreeCheckbox.PNG"), grayscale = True)
def findRegisterCompanyInput():
    '''
    Find company name input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterCompanyInput.PNG"), grayscale = True)
def findConfirmPasswordInput():
    '''
    Find confirm password input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterConfirmPasswordInput.PNG"), grayscale = True)
def findEmailInput():
    '''
    Find email input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterEmailInput.PNG"), grayscale = True)

def findFirstNameInput():
    '''
    Find first name input registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterFirstNameInput.PNG"), grayscale = True)
def findLastNameInput():
    '''
    Find last name input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterLastNameInput.PNG"), grayscale = True)
def findPasswordInput():
    '''
    Find password input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterPasswordInput.PNG"), grayscale = True)
def findSubmitDisabled():
    '''
    Find disabled submit button
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitDisabled.PNG"), grayscale = True)
def findSubmitEnabled():
    '''
    Find enabled submit button
    :return: None if unable to find, coordnates of center otherwise.
    '''

    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitEnabled.PNG"), grayscale = True)

def findTitleInput():
    '''
    Find title input for registration
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterTitleInput.PNG"), grayscale = True)
def findRegisterSuccess():
    '''
    Find registration successful popup
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterRegistrationSuccessful.PNG"), confidence = 0.95, grayscale = True)

def findNetworkError():
    '''
    Find network error popup
    :return: None if unable to find, coordnates of center otherwise.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterNetworkError.PNG"), grayscale = True)
def generateEmail():
    '''
    Create random email
    :return: a unique email
    '''
    return str(uuid.uuid4()) + "@" + str(uuid.uuid4()) + ".com"
def fillRegistration(firstName, lastName, company, title, password, email = None):
    '''
    Go through the steps of creating a user on the register tab.
    Assumes that the register tab is open and visible on the screen.

    :param firstName:
    :param lastName:
    :param company:
    :param title:
    :param password:
    :param email: If None, generates a unique random email.
    :return: The email used to create the user.
    '''

    if email is None:
        email = generateEmail()

    general.inputTextAt(findFirstNameInput(), firstName)
    general.inputTextAt(findLastNameInput(), lastName)
    general.inputTextAt(findRegisterCompanyInput(), company)
    general.inputTextAt(findEmailInput(), email)
    general.inputTextAt(findTitleInput(), title)
    general.inputTextAt(findPasswordInput(), password)
    general.inputTextAt(findConfirmPasswordInput(), password)

    #Get rid of validation box
    general.clickAt(general.findSplashLogo())

    general.clickAt(findRegisterAgreeCheckbox())

    return email

def setToRegisterTab():
    pyautogui.moveTo(general.tryRepeat(findRegisterTabButton))
    pyautogui.click()
