'''
Tests involving resetting user passwords.
'''

import Common
import sys
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

    def doTest(self, username, alertName):
        ui = StrataUI()
        self.assertTrue(ui.OnForgotPassword())

        SetAndVerifyEdit(ui, Common.RESET_PASSWORD_EDIT, username, self)

        ui.PressButton(Common.RESET_PASSWORD_SUBMIT_BUTTON)

        self.assertTrue(ui.AlertExists(alertName))

    def test_passwordResetInvalid(self):
        self.doTest(INVALID_USER, Common.forgotPasswordInvalidAlert(INVALID_USER))

    def test_passwordResetValid(self):
        args = Common.getCommandLineArguments(sys.argv)
        self.doTest(args.username, Common.forgotPasswordValidAlert(args.username))
