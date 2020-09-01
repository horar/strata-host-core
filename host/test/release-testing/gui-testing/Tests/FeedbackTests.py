'''
Tests involving the feedback system.
'''
import unittest

import Common
from GUIInterface.StrataUI import *
import time

class Feedback(unittest.TestCase):

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        ui = StrataUI()
        Logout(ui)

    def test_feedback(self):
        ui = StrataUI()
        #assert on login page
        self.assertTrue(ui.OnLoginScreen())
        Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD, self)

        self.assertTrue(ui.OnPlatformView())

        ui.PressButton(Common.USER_ICON_BUTTON)
        ui.PressButton(Common.FEEDBACK_BUTTON)

        #Feedback should open and have submit disabled because nothing has been inputted.
        self.assertTrue(ui.OnFeedback())

        ui.PressButton(FEEDBACK_BUG_BUTTON)
        ui.SetEditText(FEEDBACK_EDIT, "this is a cool product", property=PropertyId.NameProperty)

        ui.PressButton(FEEDBACK_SUBMIT_BUTTON)

        time.sleep(1)

        self.assertTrue(ui.OnFeedbackSuccess())

        ui.PressButton(FEEDBACK_SUCCESS_OK_BUTTON)



