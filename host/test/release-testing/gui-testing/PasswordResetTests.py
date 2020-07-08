import unittest
import GUIInterface.Login as login
import GUIInterface.General as general
import TestCommon
class PasswordResetInvalidTest(unittest.TestCase):
    def setUp(self) -> None:
        login.setToLoginTab()

    def tearDown(self) -> None:
        general.clickAt(login.findResetPasswordClose())

    def test_passwordResetInvalid(self):
        general.clickAt(general.tryRepeat(login.findResetPassword))

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordInput))
        self.assertIsNotNone(login.findResetPasswordSubmitDisabled)

        general.inputTextAt(login.findResetPasswordInput(), "bad@bad.com")

        self.assertIsNotNone(login.findResetPasswordSubmitEnabled())
        general.clickAt(login.findResetPasswordSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordFail))


class PasswordResetValidTest(unittest.TestCase):
    def setUp(self) -> None:
        login.setToLoginTab()
    def tearDown(self) -> None:
        general.clickAt(login.findResetPasswordClose())
    def test_passwordResetValid(self):
        general.clickAt(general.tryRepeat(login.findResetPassword))

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordInput))
        self.assertIsNotNone(login.findResetPasswordSubmitDisabled)

        general.inputTextAt(login.findResetPasswordInput(), TestCommon.VALID_USERNAME)

        self.assertIsNotNone(login.findResetPasswordSubmitEnabled())
        general.clickAt(login.findResetPasswordSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(login.findResetPasswordSuccess))


