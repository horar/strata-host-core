import unittest
import GUIInterface.General as general
import GUIInterface.PlatformView as platform
import GUIInterface.Register as register
import GUIInterface.Login as login
import SystemInterface as cleanup
import pyautogui
import TestCommon


# NEW_USERNAME = "bep@bip.com"
NEW_PASSWORD = "Bepzipbip15"
NEW_FIRST_NAME = "First"
NEW_LAST_NAME = "Last"
NEW_COMPANY = "ON Semiconductor"
NEW_TITLE = "QA"



class RegisterNew(unittest.TestCase):
    '''
    Test registering a new user.
    '''
    def setUp(self) -> None:
        with general.Latency(TestCommon.ANIMATION_LATENCY):
            register.setToRegisterTab()
    def tearDown(self) -> None:
        cleanup.deleteLoggedInUser()
        platform.logout()
    def test_registernew(self):
        self.assertIsNotNone(general.tryRepeat(register.findRegisterAgreeCheckbox))
        newUsername = register.fillRegistration(NEW_FIRST_NAME, NEW_LAST_NAME, NEW_COMPANY, NEW_TITLE, NEW_PASSWORD)

        self.assertIsNotNone(register.findSubmitEnabled())

        general.clickAt(register.findSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(register.findRegisterSuccess))

        login.setToLoginTab()
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))
        login.login(newUsername, NEW_PASSWORD)

        with general.Latency(1, 0):
            self.assertIsNotNone(platform.findUserIcon())


