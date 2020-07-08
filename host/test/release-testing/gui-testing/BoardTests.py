import unittest
import pyautogui
import GUIInterface.Login as login
import GUIInterface.PlatformView as platform
import GUIInterface.General as general
import SystemInterface as cleanup
import TestCommon
import logging
import StrataNetworkInterface as strata

__client = None
__strataId = None

def setUpModule():
    __client, __strataId = strata.connect(strata.DEFAULT_URL)

def tearDownModule():
    __client.close()


def closePlatforms():
    strata.closePlatforms(__client, __strataId)

def openLogicGates():
    strata.openPlatform(__client, TestCommon.LOGIC_GATE_CLASS_ID, __strataId)

class LoginValidNoBoard(unittest.TestCase):
    '''
    Test logging in without a board attached.
    '''
    def setUp(self):
        login.setToLoginTab()

        #Wait untill login appears
        general.tryRepeat(login.findUsernameInput)

    def tearDown(self) -> None:
        cleanup.removeLoginInfo()
        platform.logout()

    def test_login_submit(self):
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)
        self.assertIsNotNone(general.tryRepeat(platform.findPlatformView))



class LoginValidWithBoard(unittest.TestCase):
    '''
    Test logging in with a board attached and disconnecting it when logged in.
    '''
    def setUp(self):

        pyautogui.alert(text='Please plug in the Multifunction Logic Gates platform.', title='Important', button='OK')
        login.setToLoginTab()

    def tearDown(self) -> None:
        closePlatforms()
        cleanup.removeLoginInfo()
        platform.logout()

    def test_login_with_board_and_disconnect(self):

        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)

        openLogicGates()
        self.assertIsNotNone(general.tryRepeat(platform.findLogicGateView))

        pyautogui.alert(text='Please disconnect all platforms from system.', title='Important', button='OK')
        self.assertIsNotNone(general.tryRepeat(platform.findPlatformDisconnected))

