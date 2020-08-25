'''
Tests involving interacting with elements while not connected to the network
'''
import unittest
from GUIInterface.StrataUISingleton import finder
import GUIInterface.StrataUIHelper as macro
import time
import Common

class NoNetworkLogin(unittest.TestCase):
    '''
    Test logging in while disconnected from the network
    '''
    def setUp(self) -> None:
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)
    def tearDown(self) -> None:
        ui = finder.GetWindow()
        #If the network failed to disable the user might be logged in.
        if ui.OnPlatformViewScreen():
            macro.Logout(ui)

    def test_no_network_login(self):
        ui = finder.GetWindow()
        #assert on login page
        self.assertTrue(ui.OnLoginScreen())

        macro.Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

        time.sleep(10)
        self.assertTrue(ui.AlertExists(Common.LOGIN_ALERT))


class NoNetworkRegister(unittest.TestCase):
    def setUp(self) -> None:
        ui = finder.GetWindow()
        ui.SetToTab(Common.REGISTER_TAB)


    def tearDown(self) -> None:
        pass
    def test_no_network_register(self):
        ui = finder.GetWindow()
        #assert on register page
        self.assertTrue(ui.OnRegisterScreen())

        macro.Register(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD, "Testy", "McTest", "Lead QA", "ON Semiconductor")

        ui.PressRegisterButton()

        time.sleep(10)
        self.assertTrue(ui.AlertExists(Common.REGISTER_ALERT))
