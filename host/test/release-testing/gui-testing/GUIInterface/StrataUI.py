import win32gui
from uiautomation import *
from Common import *
from functools import reduce
import unittest

class StrataUI:
    def __init__(self):
        self.app = WindowControl(searchDepth = 1, Name="ON Semiconductor: Strata Developer Studio")
    def hasProperty(self, id, value):
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
        return self.__findAll(self.app, f)

    def findButtonByHeight(self, name, comparison):
        buttons = self.FindAll(lambda control: control.GetPropertyValue(PropertyId.NameProperty) == name and control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.ButtonControl)

        def lowestButton(button: Control, lowest: Control):
            currentRect = button.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            lowestRect = lowest.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            return button if comparison(currentRect[0], lowestRect[0]) else lowest

        button = reduce(lowestButton, buttons)
        return button

    def OnLoginScreen(self):
        passwordEdit = self.app.EditControl(Compare=self.hasProperty(PropertyId.FullDescriptionProperty, PASSWORD_EDIT))
        return passwordEdit.Exists()

    def OnRegisterScreen(self):
        firstNameEdit = self.app.EditControl(Compare = self.hasProperty(PropertyId.FullDescriptionProperty, FIRST_NAME_EDIT))
        return firstNameEdit.Exists()

    def OnPlatformView(self):
        userIcon = self.app.ButtonControl(Compare = self.hasProperty(PropertyId.NameProperty, USER_ICON_BUTTON))
        return userIcon.Exists()

    def OnFeedback(self):
        #find inner window
        feedbackWindow = self.app.WindowControl()
        return feedbackWindow.Exists()

    def OnFeedbackSuccess(self):
        successText = self.app.TextControl(Compare=self.hasProperty(PropertyId.NameProperty, FEEDBACK_SUCCESS_TEXT))
        return successText.Exists()

    def OnForgotPassword(self):
        resetPasswordWindow = self.app.WindowControl()
        return resetPasswordWindow.Exists()

    def SetEditText(self, editIdentifier, text, property = PropertyId.FullDescriptionProperty):
        edit = self.app.EditControl(Compare = self.hasProperty(property, editIdentifier))
        edit.GetValuePattern().SetValue(text)

    def GetEditText(self, editFullDescription):
        edit = self.app.EditControl(Compare = self.hasProperty(PropertyId.FullDescriptionProperty, editFullDescription))
        return edit.GetValuePattern().Value

    def PressLoginButton(self):
        button: ButtonControl = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c < l)
        button.GetInvokePattern().Invoke()

    def PressRegisterButton(self):
        button: ButtonControl = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c < l)
        button.GetInvokePattern().Invoke()

    def PressRegisterConfirmCheckbox(self, setTicked = True):
        confirm: CheckBoxControl = self.app.CheckBoxControl()
        state = confirm.GetTogglePattern().ToggleState
        if state == ToggleState.On and not setTicked:
            confirm.GetTogglePattern().Toggle()
        elif state == ToggleState.Off and setTicked:
            confirm.GetTogglePattern().Toggle()

    def PressButtonByName(self, name):
        button = self.app.ButtonControl(Compare = self.hasProperty(PropertyId.NameProperty, name))
        button.GetInvokePattern().Invoke()

    def SetToRegisterTab(self):
        button = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c > l)
        button.GetInvokePattern().Invoke()

    def SetToLoginTab(self):
        button = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c > l)
        button.GetInvokePattern().Invoke()

    def AlertExists(self, name):
        alert = self.app.CustomControl(Compare = self.hasProperty(PropertyId.NameProperty, name))
        return alert.Exists()

    def ConnectedPlatforms(self):
        def isPlatform(control:Control):
            return control.GetPropertyValue(PropertyId.NameProperty) == PLATFORM_CONTROLS_BUTTON and control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.ButtonControl
        platforms = self.FindAll(isPlatform)
        return len(platforms)



def SetAndVerifyEdit(ui, editFullDescription, text, test):
    ui.SetEditText(editFullDescription, text)
    test.assertEqual(ui.GetEditText(editFullDescription), text)

def Login(ui: StrataUI, username, password, test: unittest.TestCase = None):
    setText = (lambda description, text: SetAndVerifyEdit(ui, description, text, test)) if test != None else ui.SetEditText

    setText(USERNAME_EDIT, username)
    setText(PASSWORD_EDIT, password)
    ui.PressLoginButton()

def Register(ui: StrataUI, username, password, firstName, lastName, company, title, test: unittest.TestCase = None):
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
    ui.PressButtonByName(USER_ICON_BUTTON)
    ui.PressButtonByName(LOGOUT_BUTTON)



if __name__ == "__main__":
    ui = StrataUI()
    print(str(ui.OnRegisterScreen()))