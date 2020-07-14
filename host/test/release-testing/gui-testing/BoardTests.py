'''
Tests involving logging in with boards attached or disconnected.
'''
import unittest
import GUIInterface.Login as login
import GUIInterface.PlatformView as platform
import GUIInterface.General as general
import SystemInterface as cleanup
import TestCommon
import StrataInterface as strata



class LoginValidNoBoard(unittest.TestCase):
    '''
    Test logging in without a board attached.
    '''
    def setUp(self):
        with general.Latency(TestCommon.ANIMATION_LATENCY):
            login.setToLoginTab()

    def tearDown(self) -> None:
        cleanup.removeLoginInfo()
        platform.logout()

    def test_login_submit(self):

        #assert on login page
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)
        self.assertIsNotNone(general.tryRepeat(platform.findPlatformView))



class LoginValidWithBoard(unittest.TestCase):
    '''
    Test logging in with a board attached and disconnecting it when logged in.
    '''
    def setUp(self):
        with general.Latency(TestCommon.ANIMATION_LATENCY):
            login.setToLoginTab()
    def tearDown(self) -> None:
        cleanup.removeLoginInfo()
        platform.logout()

    def test_login_with_board_and_disconnect(self):

        #assert on login page
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)

        strata.initPlatformList()

        strata.openPlatform(TestCommon.LOGIC_GATE_CLASS_ID)
        self.assertIsNotNone(general.tryRepeat(platform.findLogicGateView))

        strata.closePlatforms()
        self.assertIsNotNone(general.tryRepeat(platform.findPlatformDisconnected))

