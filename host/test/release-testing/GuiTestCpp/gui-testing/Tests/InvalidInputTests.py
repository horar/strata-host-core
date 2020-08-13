import unittest
from GUIInterface.StrataUISingleton import finder
import GUIInterface.StrataUIHelper as macro
import time
import Common

INVALID_USERNAME = "badusername"
INVALID_PASSWORD = "badpassword"


class LoginInvalidTest(unittest.TestCase):

    '''
    Test logging in with invalid username/password
    '''
    def setUp(self):
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)

    def tearDown(self) -> None:
        pass

    def test_login_submit(self):
        ui = finder.GetWindow()
        self.assertTrue(ui.OnLoginScreen())

        macro.Login(ui, "badusername", "badpassword")
        time.sleep(1)
        self.assertTrue(ui.AlertExists(Common.LOGIN_ALERT))

class RegisterExisting(unittest.TestCase):
    '''
    Test registering with an existing user.
    '''
    def setUp(self) -> None:
        ui = finder.GetWindow()
        ui.SetToTab(Common.REGISTER_TAB)


    def tearDown(self) -> None:
        pass

    def test_registerexisting(self):
        ui = finder.GetWindow()
        self.assertTrue(ui.OnRegisterScreen())

        macro.Register(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD, "Testy", "McTest", "Lead QA", "ON Semiconductor")
        time.sleep(1)
        self.assertTrue(ui.AlertExists(Common.REGISTER_ALERT))

