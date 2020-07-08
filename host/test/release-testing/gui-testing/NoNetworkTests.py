import unittest
import GUIInterface.Login as login
import GUIInterface.General as general
import GUIInterface.Register as register
import TestCommon
import pyautogui

class NoNetworkLogin(unittest.TestCase):
    def setUp(self) -> None:
        login.setToLoginTab()
    def tearDown(self) -> None:
        general.deleteTextAt(login.findUsernameInput())
        # Wait for error to dissapear
        pyautogui.sleep(0.5)
        general.deleteTextAt(login.findPasswordInput())

        pass
    def test_no_network_login(self):
        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)
        self.assertIsNotNone(general.tryRepeat(login.findNetworkError, 0.5, 10))

class NoNetworkRegister(unittest.TestCase):
    def setUp(self) -> None:
        register.setToRegisterTab()
    def tearDown(self) -> None:
        pass

    def test_no_network_register(self):
        self.assertIsNotNone(general.tryRepeat(register.findRegisterAgreeCheckbox))
        register.fillRegistration("Testy", "McTest", "ON Semiconductor", "Test Engineer", TestCommon.VALID_PASSWORD, TestCommon.VALID_USERNAME)
        general.clickAt(general.tryRepeat(register.findSubmitEnabled))
        self.assertIsNotNone(general.tryRepeat(register.findNetworkError, 0.5, 10))
