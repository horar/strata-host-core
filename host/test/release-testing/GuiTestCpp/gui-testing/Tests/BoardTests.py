'''
Tests involving logging in with boards attached or disconnected.
'''
import unittest

from GUIInterface.StrataUISingleton import finder
from GUIInterface.StrataUI import StrataUI
import GUIInterface.StrataUIHelper as macro
import time

import Common
import StrataInterface as strata

class LoginValidNoBoard(unittest.TestCase):
    '''
    Test logging in without a board attached.
    '''
    def setUp(self):
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)


    def tearDown(self) -> None:
        ui = finder.GetWindow()
        macro.Logout(ui)


    def test_login_submit(self):
        ui = finder.GetWindow()
        #assert on login page
        self.assertIsNotNone(ui.OnLoginScreen())

        macro.Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

        time.sleep(1)

        self.assertIsNotNone(ui.OnPlatformViewScreen())



class LoginValidWithBoard(unittest.TestCase):
    '''
    Test logging in with a board attached and disconnecting it when logged in.
    '''
    def setUp(self):
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)
    def tearDown(self) -> None:
        ui = finder.GetWindow()
        macro.Logout(ui)

    def test_login_with_board_and_disconnect(self):
        ui = finder.GetWindow()
        #assert on login page
        self.assertTrue(ui.OnLoginScreen())

        macro.Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

        time.sleep(1)

        strata.initPlatformList()

        strata.openPlatform(Common.LOGIC_GATE_CLASS_ID)

        self.assertTrue(ui.ConnectedPlatforms() > 0)

        strata.closePlatforms()

        time.sleep(1)

        self.assertTrue(ui.ConnectedPlatforms() == 0)

