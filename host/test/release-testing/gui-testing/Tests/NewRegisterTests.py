'''
Tests involving creating a new user.
'''

import Common
import SystemInterface as cleanup
import sys
from GUIInterface.StrataUI import *

NEW_PASSWORD = "Bepzipbip15"
NEW_FIRST_NAME = "First"
NEW_LAST_NAME = "Last"
NEW_COMPANY = "ON Semiconductor"
NEW_TITLE = "QA"


class RegisterNew(unittest.TestCase):
    '''
    Test registering a new user.
    '''

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToRegisterTab()

    def tearDown(self) -> None:
        ui = StrataUI()

        if ui.OnPlatformView():
            args = Common.getCommandLineArguments(sys.argv)
            cleanup.closeAccount(args.strataIni)
            Logout(ui)

    def test_registernew(self):
        ui = StrataUI()

        # Assert that on registration page
        self.assertTrue(ui.OnRegisterScreen())

        newUsername = Common.randomUsername()
        Register(ui, newUsername, NEW_PASSWORD, NEW_FIRST_NAME, NEW_LAST_NAME, NEW_TITLE, NEW_COMPANY, self)

        self.assertTrue(ui.AlertExists(Common.registerSuccessAlert(newUsername), maxSearchSeconds=20))

        ui.SetToLoginTab()
        Login(ui, newUsername, NEW_PASSWORD, self)

        self.assertTrue(ui.OnPlatformView())
