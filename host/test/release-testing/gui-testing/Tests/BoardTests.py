'''
Tests involving logging in with boards attached or disconnected.
'''

import Common
import StrataInterface as strata
import sys
from GUIInterface.StrataUI import *

class LoginValidNoBoard(unittest.TestCase):
    '''
    Test logging in without a board attached.
    '''

    def setUp(self):
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        ui = StrataUI()
        Logout(ui)

    def test_login_submit(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertIsNotNone(ui.OnLoginScreen())

        Login(ui, args.username, args.password, self)

        self.assertTrue(ui.OnPlatformView())


class LoginValidWithBoard(unittest.TestCase):
    '''
    Test logging in with a board attached and disconnecting it when logged in.
    '''

    def setUp(self):
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        ui = StrataUI()
        LogoutIfNeeded(ui)

    def test_login_with_board_and_disconnect(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertTrue(ui.OnLoginScreen())

        Login(ui, args.username, args.password, self)
        self.assertTrue(ui.OnPlatformView())

        strata.initPlatformList()

        strata.openPlatform(Common.LOGIC_GATE_CLASS_ID)

        self.assertTrue(ui.ConnectedPlatforms() > 0)

        strata.closePlatforms()

        self.assertTrue(ui.ConnectedPlatforms() == 0)
