import GUIInterface.General as general
import pyautogui
import os

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

def findRegisterTabButton():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "TabBarRegister.PNG"), confidence = 0.5)

def findRegisterAgreeCheckbox():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterAgreeCheckbox.PNG"))
def findRegisterCompanyInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterCompanyInput.PNG"))
def findConfirmPasswordInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterConfirmPasswordInput.PNG"))
def findEmailInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterEmailInput.PNG"))
def findFirstNameInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterFirstName.PNG"))
def findLastNameInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterLastName.PNG"))
def findPasswordInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterPasswordInput.PNG"))
def findSubmitDisabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitDisabled.PNG"))
def findSubmitEnabled():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterSubmitEnabled.PNG"))

def findTitleInput():
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "RegisterTitleInput.PNG"))

def register(firstName, lastName, company, title, email, password):
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
    general.clickAt(findSubmitEnabled())


def setToRegisterTab():
    pyautogui.moveTo(findRegisterTabButton())
    pyautogui.click()
