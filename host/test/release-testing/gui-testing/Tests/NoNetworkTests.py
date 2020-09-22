'''
Tests involving interacting with elements while not connected to the network
'''

import Common
import sys
from GUIInterface.StrataUI import *


class NoNetworkLogin(unittest.TestCase):
    '''
    Test logging in while disconnected from the network
    '''

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        ui = StrataUI()
        LogoutIfNeeded(ui)
    def test_no_network_login(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertTrue(ui.OnLoginScreen())

        Login(ui, args.username, args.password, self)

        self.assertTrue(ui.AlertExists(Common.NO_NETWORK_LOGIN_ALERT, maxSearchSeconds=20))


class NoNetworkRegister(unittest.TestCase):
    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToRegisterTab()

    def tearDown(self) -> None:
        pass

    def test_no_network_register(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on register page
        self.assertTrue(ui.OnRegisterScreen())

        Register(ui, args.username, args.password, "Testy", "McTest", "Lead QA", "ON Semiconductor",
                 self)

        ui.PressRegisterButton()
        self.assertTrue(ui.AlertExists(Common.NO_NETWORK_REGISTER_ALERT, maxSearchSeconds=20))
