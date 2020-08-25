import win32gui
from uiautomation import *
from functools import reduce

LOGIN_TAB = "Login"
REGISTER_TAB = "Register"

USERNAME_EDIT = "Username/Email"
PASSWORD_EDIT = "Password"

USER_ICON_BUTTON = "User Icon"
LOGOUT_BUTTON = "Log Out"

FEEDBACK_BUTTON = "Feedback"
FEEDBACK_SUBMIT_BUTTON = "Submit"
FEEDBACK_EDIT = "FeedbackEdit"
FEEDBACK_SUCCESS_OK_BUTTON = "OK"

FIRST_NAME_EDIT = "First Name"
LAST_NAME_EDIT = "Last Name"
COMPANY_EDIT = "Company"
TITLE_EDIT = "Title (Optional)"
EMAIL_EDIT = "Email"
REGISTER_PASSWORD_EDIT = "Password"
CONFIRM_PASSWORD_EDIT = "Confirm Password"

REGISTER_ALERT = "RegisterError"
LOGIN_ALERT = "LoginError"
RESET_PASSWORD_ALERT = "ResetPasswordAlert"

RESET_PASSWORD_OPEN_BUTTON = "Forgot Password"
RESET_PASSWORD_CLOSE_BUTTON = "ClosePopup"
RESET_PASSWORD_EDIT = "example@onsemi.com"
RESET_PASSWORD_SUBMIT_BUTTON = "Submit"

class StrataUI:
    def __init__(self):
        self.app = WindowControl(searchDepth = 1, Name="ON Semiconductor: Strata Developer Studio")
    def hasProperty(self, id, value):
        def compare(control: Control, depth: int):
            return control.GetPropertyValue(id) == value
        return compare
    def getAll(self, filter):
        children = self.app.GetChildren()
        elements = list(filter(filter, children))
        return elements

    def OnLoginScreen(self):
        passwordEdit = self.app.EditControl(Compare=self.hasProperty(PropertyId.FullDescriptionProperty, PASSWORD_EDIT))
        return passwordEdit.Exists()

    def OnRegisterScreen(self):
        firstNameEdit = self.app.EditControl(Compare = self.hasProperty(PropertyId.FullDescriptionProperty, FIRST_NAME_EDIT))
        return firstNameEdit.Exists()

    def OnPlatformView(self):
        userIcon = self.app.ButtonControl(Compare = self.hasProperty(PropertyId.NameProperty, USER_ICON_BUTTON))
        return userIcon.Exists()

    def SetEditText(self, editFullDescription, text):
        edit = self.app.EditControl(Compare= self.hasProperty(PropertyId.FullDescriptionProperty, editFullDescription))
        edit.GetValuePattern().SetValue(text)

    def PressButton(self, buttonName):
        button = self.app.ButtonControl(Compare = self.hasProperty(PropertyId.NameProperty, buttonName))
        button.GetInvokePattern().Invoke()

    def PressLoginButton(self):
        buttons = self.getAll(lambda control: control.GetPropertyValue(PropertyId.NameProperty, LOGIN_TAB))

        def lowestButton(button: Control, lowest: Control):
            currentRect = button.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            lowestRect = lowest.GetPropertyValue(PropertyId.BoundingRectangleProperty)
            return currentRect if currentRect.bottom < lowestRect.bottom else lowestRect

        loginButton = reduce(lowestButton, buttons)
        loginButton.GetInvokePattern().Invoke()


if __name__ == "__main__":
    ui = StrataUI()
    print(str(ui.OnRegisterScreen()))