'''
Tests involving the feedback system.
'''
import unittest

import Common
from GUIInterface.StrataUISingleton import finder
import GUIInterface.StrataUIHelper as macro
import time

class Feedback(unittest.TestCase):

    def setUp(self) -> None:
        ui = finder.GetWindow()
        ui.SetToTab(Common.LOGIN_TAB)


    def tearDown(self) -> None:
        ui = finder.GetWindow()
        macro.Logout(ui)

    def test_feedback(self):
        ui = finder.GetWindow()
        #assert on login page
        self.assertTrue(ui.OnLoginScreen())
        macro.Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

        time.sleep(1)

        ui.PressButton(Common.USER_ICON_BUTTON)
        ui.PressButton(Common.FEEDBACK_BUTTON)

        #Feedback should open and have submit disabled because nothing has been inputted.
        self.assertTrue(ui.OnFeedback())

        ui.SetEditText(Common.FEEDBACK_EDIT, "this is a cool product", True)

        ui.PressButton(Common.FEEDBACK_SUBMIT_BUTTON)

        time.sleep(1)

        self.assertTrue(ui.OnFeedbackSuccess())

        ui.PressButton(Common.FEEDBACK_SUCCESS_OK_BUTTON)



