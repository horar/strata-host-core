'''
Tests involving resetting user passwords.
'''
import unittest
from GUIInterface.StrataUISingleton import finder
import time
import Common

INVALID_USER = "bad@bad.com"

class PasswordResetTest(unittest.TestCase):
    '''
    Test resetting the password of a nonexistant user
    '''
    def setUp(self) -> None:
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)
        ui.PressButton(Common.RESET_PASSWORD_OPEN_BUTTON)

    def tearDown(self) -> None:
        ui = finder.GetWindow()
        ui.PressButton(Common.RESET_PASSWORD_CLOSE_BUTTON)

    def doTest(self, username):
        ui = finder.GetWindow()
        self.assertTrue(ui.OnForgotPassword())

        ui.SetEditText(Common.RESET_PASSWORD_EDIT, username)

        ui.PressButton(Common.RESET_PASSWORD_SUBMIT_BUTTON)

        time.sleep(1)

        self.assertTrue(ui.AlertExists(Common.RESET_PASSWORD_ALERT))

    def test_passwordResetInvalid(self):
        self.doTest(INVALID_USER)

    def test_passwordResetValid(self):
        self.doTest(Common.VALID_USERNAME)




