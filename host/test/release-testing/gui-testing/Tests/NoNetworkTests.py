'''
Tests involving interacting with elements while not connected to the network
'''
import unittest
from GUIInterface.StrataUI import *
import time
import Common

class NoNetworkLogin(unittest.TestCase):
    '''
    Test logging in while disconnected from the network
    '''
    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToLoginTab()
    def tearDown(self) -> None:
        ui = StrataUI()
        #If the network failed to disable the user might be logged in.
        if ui.OnPlatformView():
            Logout(ui)

    def test_no_network_login(self):
        ui = StrataUI()
        #assert on login page
        self.assertTrue(ui.OnLoginScreen())

        Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD, self)

        time.sleep(10)
        self.assertTrue(ui.AlertExists(Common.LOGIN_ALERT))


class NoNetworkRegister(unittest.TestCase):
    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToRegisterTab()


    def tearDown(self) -> None:
        pass
    def test_no_network_register(self):
        ui = StrataUI()
        #assert on register page
        self.assertTrue(ui.OnRegisterScreen())

        Register(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD, "Testy", "McTest", "Lead QA", "ON Semiconductor", self)

        ui.PressRegisterButton()

        time.sleep(10)
        self.assertTrue(ui.AlertExists(Common.REGISTER_ALERT))
