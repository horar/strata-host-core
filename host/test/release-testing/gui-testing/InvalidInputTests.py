import unittest
import GUIInterface.General as general
import GUIInterface.Login as login
import GUIInterface.Register as register
import pyautogui
import TestCommon

INVALID_USERNAME = "badusername"
INVALID_PASSWORD = "badpassword"


class LoginInvalidTest(unittest.TestCase):
    '''
    Test logging in with invalid username/password
    '''
    def setUp(self):

        with general.Latency(TestCommon.ANIMATION_LATENCY):
            login.setToLoginTab()
    def tearDown(self) -> None:
        general.deleteTextAt(login.findUsernameInput())

        with general.Latency(TestCommon.ANIMATION_LATENCY, 0):
            general.deleteTextAt(login.findPasswordInput())

    def test_login_submit(self):
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))
        general.inputTextAt(login.findUsernameInput(), INVALID_USERNAME)

        # assert that submit is disabled when only one field is filled.
        self.assertIsNotNone(login.findLoginSubmitDisabled())

        general.inputTextAt(login.findPasswordInput(), INVALID_PASSWORD)

        submitLocation = login.findLoginSubmitEnabled()
        # assert that submit is enabled when both fields are filled.
        self.assertIsNotNone(submitLocation)

        # Submit invalid username/password
        general.clickAt(submitLocation)

        self.assertIsNotNone(general.tryRepeat(login.findLoginError))

class RegisterExisting(unittest.TestCase):
    '''
    Test registering with an existing user.
    '''
    def setUp(self) -> None:

        with general.Latency(TestCommon.ANIMATION_LATENCY):
            register.setToRegisterTab()


    def tearDown(self) -> None:
        pass

    def test_registerexisting(self):
        #Assert that we are on the register page.
        self.assertIsNotNone(general.tryRepeat(register.findRegisterAgreeCheckbox))

        register.fillRegistration("Testy", "McTest", "ON Semiconductor", "Test Engineer", TestCommon.VALID_PASSWORD, TestCommon.VALID_USERNAME)
        general.clickAt(register.findSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(register.findUserAlreadyExists))