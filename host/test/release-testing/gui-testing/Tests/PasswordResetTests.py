'''
Tests involving resetting user passwords.
'''
import unittest
import GUIInterface.Login as login
import GUIInterface.General as general
import Common

INVALID_USER = "bad@bad.com"

class PasswordResetInvalidTest(unittest.TestCase):
    '''
    Test resetting the password of a nonexistant user
    '''
    def setUp(self) -> None:
        with general.Latency(Common.ANIMATION_LATENCY):
            login.setToLoginTab()

    def tearDown(self) -> None:
        general.clickAt(login.findResetPasswordClose())

    def test_passwordResetInvalid(self):

        #assert on login page
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        general.clickAt(general.tryRepeat(login.findResetPassword))

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordInput))
        self.assertIsNotNone(login.findResetPasswordSubmitDisabled)

        general.inputTextAt(login.findResetPasswordInput(), INVALID_USER)

        self.assertIsNotNone(login.findResetPasswordSubmitEnabled())
        general.clickAt(login.findResetPasswordSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordFail))


class PasswordResetValidTest(unittest.TestCase):
    '''
    Test resetting the password of a valid user
    '''
    def setUp(self) -> None:
        with general.Latency(Common.ANIMATION_LATENCY):
            login.setToLoginTab()
    def tearDown(self) -> None:
        general.clickAt(login.findResetPasswordClose())

    def test_passwordResetValid(self):

        #Assert on login page
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        general.clickAt(general.tryRepeat(login.findResetPassword))

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordInput))
        self.assertIsNotNone(login.findResetPasswordSubmitDisabled)

        general.inputTextAt(login.findResetPasswordInput(), Common.VALID_USERNAME)

        self.assertIsNotNone(login.findResetPasswordSubmitEnabled())
        general.clickAt(login.findResetPasswordSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordSuccess))


