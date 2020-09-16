import _ctypes
import unittest

from functools import reduce

from uiautomation import WindowControl, Control, PropertyId, ControlType, ButtonControl, ToggleState, CheckBoxControl, PatternId

from Common import STRATA_WINDOW, PASSWORD_EDIT, FIRST_NAME_EDIT, USER_ICON_BUTTON, FEEDBACK_SUCCESS_TEXT, LOGIN_TAB, \
    REGISTER_TAB, REMEMBER_ME_CHECKBOX, PLATFORM_CONTROLS_BUTTON, USERNAME_EDIT, EMAIL_EDIT, CONFIRM_PASSWORD_EDIT, \
    LAST_NAME_EDIT, COMPANY_EDIT, TITLE_EDIT, LOGOUT_BUTTON, TestLogger

class StrataUI:
    '''
    Class that wraps uiautomation into a more friendly procedural interface.
    '''

    def __init__(self):
        '''
        Init StrataUI. Expects strata to be already open.
        '''
        self.app = WindowControl(searchDepth=1, Name=STRATA_WINDOW)

    def __hasProperty(self, id, value):
        def compare(control: Control, depth: int):
            return control.GetPropertyValue(id) == value

        return compare

    def __findAll(self, node: Control, condition):
        matching = []
        child = node.GetFirstChildControl()
        while child:
            if condition(child):
                matching.append(child)
            matching = matching + self.__findAll(child, condition)
            child = child.GetNextSiblingControl()
        return matching

    def __existsCatchComError(self, control, maxSearchSeconds = 7, maxAttempts = 2):
        #Transitioning screens while checking for existance sometimes throws a COMError.
        for attempt in range(maxAttempts):
            try:
                return control.Exists(maxSearchSeconds=maxSearchSeconds)
            except _ctypes.COMError:
                pass
        return False



    def FindAll(self, condition):
        '''
        Find all elements that are approved by the function condition(control: Control)
        '''
        return self.__findAll(self.app, condition)

    def findButtonByHeight(self, name, comparison):
        '''
        Find the (lowest, highest, etc.) button by its name
        '''
        buttons = self.FindAll(
            lambda control: control.GetPropertyValue(PropertyId.NameProperty) == name and
                            (control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.ButtonControl or control.GetPropertyValue(PropertyId.ControlTypeProperty) == ControlType.CheckBoxControl))

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
        with TestLogger() as logger:
            logger.info("Locating login screen")

        passwordEdit = self.app.EditControl(
            Compare=self.__hasProperty(PropertyId.FullDescriptionProperty, PASSWORD_EDIT))

        return self.__existsCatchComError(passwordEdit)

    def OnRegisterScreen(self):
        '''
        True if on register screen
        '''
        with TestLogger() as logger:
            logger.info("Locating register screen")

        firstNameEdit = self.app.EditControl(
            Compare=self.__hasProperty(PropertyId.FullDescriptionProperty, FIRST_NAME_EDIT))

        return self.__existsCatchComError(firstNameEdit)

    def OnPlatformView(self):
        '''
        True if on platform view
        '''
        with TestLogger() as logger:
            logger.info("Locating platform view")

        userIcon = self.app.ButtonControl(Compare=self.__hasProperty(PropertyId.NameProperty, USER_ICON_BUTTON))

        return self.__existsCatchComError(userIcon)

    def OnFeedback(self):
        '''
        True if feedback window open
        '''
        with TestLogger() as logger:
            logger.info("Locating feedback")
        # find inner window
        feedbackWindow = self.app.WindowControl()

        return self.__existsCatchComError(feedbackWindow)

    def OnFeedbackSuccess(self):
        '''
        True if feedback success dialog open
        '''
        with TestLogger() as logger:
            logger.info("Locating feedback success dialog")

        successText = self.app.TextControl(Compare=self.__hasProperty(PropertyId.NameProperty, FEEDBACK_SUCCESS_TEXT))

        return self.__existsCatchComError(successText)
    def OnForgotPassword(self):
        '''
        True if forgot password dialog open
        '''
        with TestLogger() as logger:
            logger.info("Locating forgot password dialog")
        resetPasswordWindow = self.app.WindowControl()
        return self.__existsCatchComError(resetPasswordWindow)

    def SetEditText(self, editIdentifier, text, property=PropertyId.FullDescriptionProperty):
        '''
        Find an edit by a specific property and set its text
        '''
        with TestLogger() as logger:
            logger.info("Setting edit with identifier '" + str(editIdentifier) + "'" + " to " + "'" + text + "'")

        edit = self.app.EditControl(Compare=self.__hasProperty(property, editIdentifier))
        edit.GetValuePattern().SetValue(text)

    def GetEditText(self, editIdentifier, property=PropertyId.FullDescriptionProperty):
        '''
        Find an edit by a specific property and get its text
        '''
        with TestLogger() as logger:
            logger.info("Getting text from edit with identifier '" + str(editIdentifier) + "'")

        edit = self.app.EditControl(Compare=self.__hasProperty(property, editIdentifier))
        return edit.GetValuePattern().Value

    def PressLoginButton(self):
        '''
        Press the login submit button on the login view
        '''
        with TestLogger() as logger:
            logger.info("Pressing login button")
        button: ButtonControl = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c < l)
        button.GetPattern(PatternId.InvokePattern).Invoke()

    def PressRegisterButton(self):
        '''
        Press the register submit button on the register view
        '''
        with TestLogger() as logger:
            logger.info("Pressing register button")

        button: ButtonControl = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c < l)
        button.GetPattern(PatternId.InvokePattern).Invoke()

    def SetCheckbox(self, checkbox, setTicked):

        state = checkbox.GetTogglePattern().ToggleState
        if state == ToggleState.On and not setTicked:
            checkbox.GetTogglePattern().Toggle()
        elif state == ToggleState.Off and setTicked:
            checkbox.GetTogglePattern().Toggle()

    def PressRegisterConfirmCheckbox(self, setTicked=True):
        '''
        Set the confirm checkbox on the register view to ticked or unticked
        '''
        with TestLogger() as logger:
            logger.info("Setting register checkbox to " + str(setTicked))

        def registerCheckboxCompare(control:Control, depth):
            return control.GetPropertyValue(PropertyId.NameProperty) == ""

        confirm: CheckBoxControl = self.app.CheckBoxControl(Compare=registerCheckboxCompare)
        self.SetCheckbox(confirm, setTicked)

    def PressRememberMeCheckbox(self, setTicked=True):

        with TestLogger() as logger:
            logger.info("Setting remember me checkbox to " + str(setTicked))

        rememberMe: CheckBoxControl = self.app.CheckBoxControl(
            Compare=self.__hasProperty(PropertyId.NameProperty, REMEMBER_ME_CHECKBOX))
        self.SetCheckbox(rememberMe, setTicked)

    def PressButton(self, identifier, property=PropertyId.NameProperty):
        '''
        Find a button by a specific property and press it.
        '''
        with TestLogger() as logger:
            logger.info("Pressing button with identifier '" + identifier + "'")
        button = self.app.ButtonControl(Compare=self.__hasProperty(property, identifier))
        button.GetInvokePattern().Invoke()

    def SetToRegisterTab(self):
        '''
        Set to the register tab in the login/register view.
        '''
        with TestLogger() as logger:
            logger.info("Setting to register tab")
        button = self.findButtonByHeight(REGISTER_TAB, lambda c, l: c > l)

        #Button can be a checkbox or button due to qt wierdness
        button.GetPattern(PatternId.InvokePattern).Invoke()

    def SetToLoginTab(self):
        '''
        Set to the login tab in the login/register view.
        '''
        with TestLogger() as logger:
            logger.info("Setting to login tab")
        button = self.findButtonByHeight(LOGIN_TAB, lambda c, l: c > l)

        #Button can be a checkbox or button due to qt wierdness
        button.GetPattern(PatternId.InvokePattern).Invoke()

    def AlertExists(self, identifier, property=PropertyId.NameProperty, maxSearchSeconds = 7):
        '''
        Determine if an alert exists by a specific property
        '''
        with TestLogger() as logger:
            logger.info("Locating alert with identifier '" + str(identifier) + "'")
        alert = self.app.CustomControl(Compare=self.__hasProperty(PropertyId.NameProperty, identifier))
        return self.__existsCatchComError(alert, maxSearchSeconds)

    def ConnectedPlatforms(self):
        '''
        Get the number of platforms connected in the platform view. (only works on platform view).
        '''
        with TestLogger() as logger:
            logger.info("Finding number of connected platforms")

        def isPlatform(control: Control):
            return control.GetPropertyValue(
                PropertyId.NameProperty) == PLATFORM_CONTROLS_BUTTON and control.GetPropertyValue(
                PropertyId.ControlTypeProperty) == ControlType.ButtonControl

        platforms = self.FindAll(isPlatform)
        return len(platforms)


def SetAndVerifyEdit(ui, editFullDescription, text, test, property=PropertyId.FullDescriptionProperty):
    '''
    Set edit text and assert that the text has been set.
    '''
    ui.SetEditText(editFullDescription, text, property=property)
    test.assertEqual(ui.GetEditText(editFullDescription, property=property), text)


def Login(ui: StrataUI, username, password, test: unittest.TestCase = None):
    '''
    Login to strata from the login view using the given username and password, optionally asserting that the text has been set using the test case.
    '''
    setText = (
        lambda description, text: SetAndVerifyEdit(ui, description, text, test)) if test != None else ui.SetEditText

    setText(USERNAME_EDIT, username)
    setText(PASSWORD_EDIT, password)
    ui.PressLoginButton()


def Register(ui: StrataUI, username, password, firstName, lastName, company, title, test: unittest.TestCase = None):
    '''
    Register using the given information, optionally asserting that the text has been set using the test case.
    '''

    setText = (
        lambda description, text: SetAndVerifyEdit(ui, description, text, test)) if test != None else ui.SetEditText

    setText(EMAIL_EDIT, username)
    setText(PASSWORD_EDIT, password)
    setText(CONFIRM_PASSWORD_EDIT, password)
    setText(FIRST_NAME_EDIT, firstName)
    setText(LAST_NAME_EDIT, lastName)
    setText(COMPANY_EDIT, company)
    setText(TITLE_EDIT, title)
    ui.PressRegisterConfirmCheckbox(True)
    ui.PressRegisterButton()


def Logout(ui: StrataUI):
    '''
    Logout of strata from the platform view.
    '''
    ui.PressButton(USER_ICON_BUTTON)
    ui.PressButton(LOGOUT_BUTTON)

def LogoutIfNeeded(ui):
    if ui.OnPlatformView():
        Logout(ui)
