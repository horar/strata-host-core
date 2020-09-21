import Common
import sys
from GUIInterface.StrataUI import *


INVALID_USERNAME = "badusername"
INVALID_PASSWORD = "badpassword"


class LoginInvalidTest(unittest.TestCase):
    '''
    Test logging in with invalid username/password
    '''

    def setUp(self):
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        pass

    def test_login_submit(self):
        ui = StrataUI()
        self.assertTrue(ui.OnLoginScreen())

        Login(ui, "badusername", "badpassword", self)
        self.assertTrue(ui.AlertExists(Common.LOGIN_INVALID_ALERT))


class RegisterExisting(unittest.TestCase):
    '''
    Test registering with an existing user.
    '''

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToRegisterTab()

    def tearDown(self) -> None:
        pass

    def test_registerexisting(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        self.assertTrue(ui.OnRegisterScreen())

        Register(ui, args.username, args.password, "Testy", "McTest", "ON Semiconductor", "Lead QA",
                 self)
        self.assertTrue(ui.AlertExists(Common.REGISTER_ALERT))
