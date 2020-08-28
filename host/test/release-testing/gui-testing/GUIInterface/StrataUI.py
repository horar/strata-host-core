import win32gui
from uiautomation import *
from Common import *
from functools import reduce
import unittest

class StrataUI:
    '''
    Class that wraps uiautomation into a more friendly procedural interface.
    '''
    def __init__(self):
        '''
        Init StrataUI. Expects strata to be already open.
        '''
        self.app = WindowControl(searchDepth = 1, Name = STRATA_WINDOW)

    def __hasProperty(self, id, value):
        def compare(control: Control, depth: int):
            return control.GetPropertyValue(id) == value
        return compare

    def __findAll(self, node: Control, f):
        matching = []
        child = node.GetFirstChildControl()
        while child:
            if f(child):
                matching.append(child)
            matching = matching + self.__findAll(child, f)
            child = child.GetNextSiblingControl()
        return matching

    def FindAll(self, f):
        '''
        Find all elements that are approved by the function f(control: Control)
        '''
        return self.__findAll(self.app, f)

    def findButtonByHeight(self, name, comparison):
        '''
        Find the (lowest, highest, etc.) button by its name
        '''
        buttons = self.FindAll(lambda control: control.GetPropertyValue(PropertyId.NameProperty) == name and control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.ButtonControl)

        def lowestButton(button: Control, lowest: Control):
            currentRect = button.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            lowestRect = lowest.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            return button if comparison(currentRect[0], lowestRect[0]) else lowest

        button = reduce(lowestButton, buttons)
        return button

    def OnLoginScreen(self):
        '''
        True if on login screen
        '''
        passwordEdit = self.app.EditControl(Compare=self.__hasProperty(PropertyId.FullDescriptionProperty, PASSWORD_EDIT))
        return passwordEdit.Exists()

    def OnRegisterScreen(self):
        '''
        True if on register screen
        '''
        firstNameEdit = self.app.EditControl(Compare = self.__hasProperty(PropertyId.FullDescriptionProperty, FIRST_NAME_EDIT))
        return firstNameEdit.Exists()

    def OnPlatformView(self):
        '''
        True if on platform view
        '''
        userIcon = self.app.ButtonControl(Compare = self.__hasProperty(PropertyId.NameProperty, USER_ICON_BUTTON))
        return userIcon.Exists()

    def OnFeedback(self):
        '''
        True if feedback window open
        '''

        #find inner window
        feedbackWindow = self.app.WindowControl()
        return feedbackWindow.Exists()

    def OnFeedbackSuccess(self):
        '''
        True if feedback success dialog open
        '''
        successText = self.app.TextControl(Compare=self.__hasProperty(PropertyId.NameProperty, FEEDBACK_SUCCESS_TEXT))
        return successText.Exists()

    def OnForgotPassword(self):
        '''
        True if forgot password dialog open
        '''
        resetPasswordWindow = self.app.WindowControl()
        return resetPasswordWindow.Exists()

    def SetEditText(self, editIdentifier, text, property = PropertyId.FullDescriptionProperty):
        '''
        Find an edit by a specific property and set its text
        '''
        edit = self.app.EditControl(Compare = self.__hasProperty(property, editIdentifier))
        edit.GetValuePattern().SetValue(text)

    def GetEditText(self, editIdentifier, property = PropertyId.FullDescriptionProperty):
        '''
        Find an edit by a specific property and get its text
        '''
        edit = self.app.EditControl(Compare = self.__hasProperty(property, editIdentifier))
        return edit.GetValuePattern().Value

    def PressLoginButton(self):
        '''
        Press the login submit button on the login view
        '''
        button: ButtonControl = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c < l)
        button.GetInvokePattern().Invoke()

    def PressRegisterButton(self):
        '''
        Press the register submit button on the register view
        '''
        button: ButtonControl = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c < l)
        button.GetInvokePattern().Invoke()
    def SetCheckbox(self, checkbox, setTicked):
        state = checkbox.GetTogglePattern().ToggleState
        if state == ToggleState.On and not setTicked:
            checkbox.GetTogglePattern().Toggle()
        elif state == ToggleState.Off and setTicked:
            checkbox.GetTogglePattern().Toggle()

    def PressRegisterConfirmCheckbox(self, setTicked = True):
        '''
        Set the confirm checkbox on the register view to ticked or unticked
        '''
        confirm: CheckBoxControl = self.app.CheckBoxControl()
        self.SetCheckbox(confirm, setTicked)

    def PressRememberMeCheckbox(self, setTicked = True):
        rememberMe: CheckBoxControl = self.app.CheckBoxControl(Compare=self.__hasProperty(PropertyId.NameProperty, REMEMBER_ME_CHECKBOX))
        self.SetCheckbox(rememberMe, setTicked)

    def PressButton(self, identifier, property=PropertyId.NameProperty):
        '''
        Find a button by a specific property and press it.
        '''
        button = self.app.ButtonControl(Compare = self.__hasProperty(property, identifier))
        button.GetInvokePattern().Invoke()

    def SetToRegisterTab(self):
        '''
        Set to the register tab in the login/register view.
        '''
        button = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c > l)
        button.GetInvokePattern().Invoke()

    def SetToLoginTab(self):
        '''
        Set to the login tab in the login/register view.
        '''
        button = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c > l)
        button.GetInvokePattern().Invoke()

    def AlertExists(self, identifier, property = PropertyId.NameProperty):
        '''
        Determine if an alert exists by a specific property
        '''
        alert = self.app.CustomControl(Compare = self.__hasProperty(PropertyId.NameProperty, identifier))
        return alert.Exists()

    def ConnectedPlatforms(self):
        '''
        Get the number of platforms connected in the platform view. (only works on platform view).
        '''
        def isPlatform(control:Control):
            return control.GetPropertyValue(PropertyId.NameProperty) == PLATFORM_CONTROLS_BUTTON and control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.ButtonControl
        platforms = self.FindAll(isPlatform)
        return len(platforms)



def SetAndVerifyEdit(ui, editFullDescription, text, test):
    '''
    Set edit text and assert that the text has been set.
    '''
    ui.SetEditText(editFullDescription, text)
    test.assertEqual(ui.GetEditText(editFullDescription), text)

def Login(ui: StrataUI, username, password, test: unittest.TestCase = None):
    '''
    Login to strata from the login view using the given username and password, optionally asserting that the text has been set using the test case.
    '''
    setText = (lambda description, text: SetAndVerifyEdit(ui, description, text, test)) if test != None else ui.SetEditText

    setText(USERNAME_EDIT, username)
    setText(PASSWORD_EDIT, password)
    ui.PressLoginButton()

def Register(ui: StrataUI, username, password, firstName, lastName, company, title, test: unittest.TestCase = None):
    '''
    Register using the given information, optionally asserting that the text has been set using the test case.
    '''

    setText = (lambda description, text: SetAndVerifyEdit(ui, description, text, test)) if test != None else ui.SetEditText

    setText(EMAIL_EDIT, username)
    setText(PASSWORD_EDIT, password)
    setText(CONFIRM_PASSWORD_EDIT, password)
    setText(FIRST_NAME_EDIT, firstName)
    setText(LAST_NAME_EDIT, lastName)
    setText(COMPANY_EDIT, company)
    setText(TITLE_EDIT, title)
    ui.PressRegisterConfirmCheckbox()
    ui.PressRegisterButton()

def Logout(ui: StrataUI):
    '''
    Logout of strata from the platform view.
    '''
    ui.PressButton(USER_ICON_BUTTON)
    ui.PressButton(LOGOUT_BUTTON)



if __name__ == "__main__":
    ui = StrataUI()
    print(str(ui.OnRegisterScreen()))