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
        with general.Latency(TestCommon.ANIMATION_LATENCY):
            login.setToLoginTab()

    def tearDown(self) -> None:
        cleanup.removeLoginInfo()
        platform.logout()

    def test_feedback(self):
        #assert on login page
        self.assertIsNotNone(general.tryRepeat(login.findUsernameInput))

        login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)


        #findUserIcon can seize on something else before the page is fully loaded because of its confidence level.
        pyautogui.sleep(1)
        general.clickAt(platform.findUserIcon())
        general.clickAt(platform.findFeedbackButton())

        #Feedback should open and have submit disabled because nothing has been inputted.
        self.assertIsNotNone(general.tryRepeat(platform.findFeedbackInput))

        #Window should be static at this point, no need to repeat tries.
        self.assertIsNotNone(platform.findFeedbackSubmitDisabled())

        general.inputTextAt(platform.findFeedbackInput(), "this is a cool product")
        self.assertIsNotNone(platform.findFeedbackSubmitEnabled())

        general.clickAt(platform.findFeedbackSubmitEnabled())

        self.assertIsNotNone(general.tryRepeat(platform.findFeedbackSuccess))

        general.clickAt(platform.findFeedbackOk())

