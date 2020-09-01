'''
Tests involving resetting user passwords.
'''

import Common
from GUIInterface.StrataUI import *

INVALID_USER = "bad@bad.com"


class PasswordResetTest(unittest.TestCase):
    '''
    Test resetting the password of a nonexistant user
    '''

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToLoginTab()
        ui.PressButton(Common.RESET_PASSWORD_OPEN_BUTTON)

    def tearDown(self) -> None:
        ui = StrataUI()
        ui.PressButton(Common.RESET_PASSWORD_CLOSE_BUTTON)

    def doTest(self, username):
        ui = StrataUI()
        self.assertTrue(ui.OnForgotPassword())

        ui.SetEditText(Common.RESET_PASSWORD_EDIT, username)

        ui.PressButton(Common.RESET_PASSWORD_SUBMIT_BUTTON)

        time.sleep(1)

        self.assertTrue(ui.AlertExists(Common.RESET_PASSWORD_ALERT))

    def test_passwordResetInvalid(self):
        self.doTest(INVALID_USER)

    def test_passwordResetValid(self):
        self.doTest(Common.VALID_USERNAME)
