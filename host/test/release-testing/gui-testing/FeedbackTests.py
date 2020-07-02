import unittest
import GUIInterface.General as general
import GUIInterface.Login as login
import GUIInterface.PlatformView as platform
import TestCommon
import pyautogui
import SystemInterface as cleanup

class Feedback(unittest.TestCase):
    '''
    Test sending feedback
    '''
    def setUp(self) -> None:
        pyautogui.sleep(1)
        login.setToLoginTab()
        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)
        pyautogui.sleep(2)
    def tearDown(self) -> None:
        platform.logout()

        cleanup.removeLoginInfo()
        login.setToLoginTab()
        pyautogui.sleep(1)
        general.deleteTextAt(login.findUsernameInput())

    def test_feedback(self):
        platform.openFeedback()

        #Feedback should open and have submit disabled because nothing has been inputted.
        self.assertIsNotNone(platform.findFeedbackInput())
        self.assertIsNotNone(platform.findFeedbackSubmitDisabled())

        general.inputTextAt(platform.findFeedbackInput(), "this is a cool product")

        self.assertIsNotNone(platform.findFeedbackSubmitEnabled())

        general.clickAt(platform.findFeedbackSubmitEnabled())
        pyautogui.sleep(1)
        self.assertIsNotNone(platform.findFeedbackSuccess())

        general.clickAt(platform.findFeedbackOk())

