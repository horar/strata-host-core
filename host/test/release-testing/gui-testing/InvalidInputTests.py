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
        pyautogui.sleep(1)
        login.setToLoginTab()
        pyautogui.sleep(1)

    def tearDown(self) -> None:
        general.deleteTextAt(login.findUsernameInput())
        # Wait for error to dissapear
        pyautogui.sleep(0.5)
        general.deleteTextAt(login.findPasswordInput())

    def test_login_submit(self):
        general.inputTextAt(login.findUsernameInput(), INVALID_USERNAME)

        # assert that submit is disabled when only one field is filled.
        self.assertIsNotNone(login.findLoginSubmitDisabled())

        general.inputTextAt(login.findPasswordInput(), INVALID_PASSWORD)

        submitLocation = login.findLoginSubmitEnabled()
        # assert that submit is enabled when both fields are filled.
        self.assertIsNotNone(submitLocation)

        # Submit invalid username/password
        general.clickAt(submitLocation)

        # Wait for network
        pyautogui.sleep(3)

        self.assertIsNotNone(login.findLoginError())

class RegisterExisting(unittest.TestCase):
    '''
    Test registering with an existing user.
    '''
    def setUp(self) -> None:
        pyautogui.sleep(1)
        register.setToRegisterTab()
        pyautogui.sleep(1)

    def tearDown(self) -> None:
        pass

    def test_registerexisting(self):
        register.fillRegistration("Testy", "McTest", "ON Semiconductor", "Test Engineer", TestCommon.VALID_PASSWORD, TestCommon.VALID_USERNAME)
        general.clickAt(register.findSubmitEnabled())
        pyautogui.sleep(3)
        self.assertIsNotNone(register.findUserAlreadyExists())