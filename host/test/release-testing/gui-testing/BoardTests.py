import unittest
import pyautogui
import GUIInterface.Login as login
import GUIInterface.PlatformView as platform
import GUIInterface.General as general

import time
import SystemInterface as cleanup
import TestCommon

class LoginValidNoBoard(unittest.TestCase):
    '''
    Test logging in without a board attached.
    '''
    def setUp(self):
        pyautogui.sleep(1)
        pyautogui.alert(text='Please disconnect all platforms from system.', title='Important', button='OK')
        login.setToLoginTab()

    def tearDown(self) -> None:
        platform.logout()
        cleanup.removeLoginInfo()
        pyautogui.sleep(3)
        general.deleteTextAt(login.findUsernameInput())

    def test_login_submit(self):
        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)


        # Wait for network
        time.sleep(3)

        self.assertIsNotNone(platform.findPlatformView())


class LoginValidWithBoard(unittest.TestCase):
    '''
    Test logging in with a board attached
    '''
    def setUp(self):
        pyautogui.sleep(1)
        pyautogui.alert(text='Please plug in the Multifunction Logic Gates platform.', title='Important', button='OK')

        login.setToLoginTab()

    def tearDown(self) -> None:
        platform.logout()
        cleanup.removeLoginInfo()
        pyautogui.sleep(3)

        general.deleteTextAt(login.findUsernameInput())

    def test_login_submit(self):
        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)

        # Wait for network
        pyautogui.sleep(3)

        self.assertIsNotNone(platform.findLogicGateView())
