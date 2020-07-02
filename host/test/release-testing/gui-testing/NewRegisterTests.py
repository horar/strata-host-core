import unittest
unittest.TestLoader.sortTestMethodsUsing = None

import GUIInterface.General as general
import GUIInterface.PlatformView as platform
import GUIInterface.Register as register
import SystemInterface as cleanup
import pyautogui


# NEW_USERNAME = "bep@bip.com"
NEW_PASSWORD = "Bepzipbip15"
NEW_FIRST_NAME = "First"
NEW_LAST_NAME = "Last"
NEW_COMPANY = "ON Semiconductor"
NEW_TITLE = "QA"

def logoutAndClean():
    platform.logout()
    cleanup.deleteLoggedInUser()


class RegisterNew(unittest.TestCase):
    '''
    Test registering a new user.
    '''
    def setUp(self) -> None:
        pyautogui.sleep(1)
        register.setToRegisterTab()
        #wait for animation
        pyautogui.sleep(1)

    def tearDown(self) -> None:

        cleanup.deleteLoggedInUser()

    def test_registernew(self):
        register.fillRegistration(NEW_FIRST_NAME, NEW_LAST_NAME, NEW_COMPANY, NEW_TITLE, NEW_PASSWORD)

        self.assertIsNotNone(register.findSubmitEnabled())

        general.clickAt(register.findSubmitEnabled())
        pyautogui.sleep(3)

        self.assertIsNotNone(register.findRegisterSuccess())

