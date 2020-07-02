import GUIInterface.General as general
import pyautogui
import os
import uuid

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findRegisterTabButton():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "TabBarRegister.PNG"))
def findUserAlreadyExists():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterAccountAlreadyExists.PNG"), confidence = 0.9)
def findRegisterAgreeCheckbox():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterAgreeCheckbox.PNG"))
def findRegisterCompanyInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterCompanyInput.PNG"))
def findConfirmPasswordInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterConfirmPasswordInput.PNG"))
def findEmailInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterEmailInput.PNG"))
def findFirstNameInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterFirstNameInput.PNG"))
def findLastNameInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterLastNameInput.PNG"))
def findPasswordInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterPasswordInput.PNG"))
def findSubmitDisabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitDisabled.PNG"))
def findSubmitEnabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitEnabled.PNG"))

def findTitleInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterTitleInput.PNG"))
def findRegisterSuccess():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterRegistrationSuccessful.PNG"), confidence = 0.95)
def generateEmail():
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
    pyautogui.moveTo(findRegisterTabButton())
    pyautogui.click()
