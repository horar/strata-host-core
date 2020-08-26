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

        time.sleep(1)

        ui.PressButtonByName(Common.USER_ICON_BUTTON)
        ui.PressButtonByName(Common.FEEDBACK_BUTTON)

        #Feedback should open and have submit disabled because nothing has been inputted.
        self.assertTrue(ui.OnFeedback())

        ui.SetEditText(FEEDBACK_EDIT, "this is a cool product")

        ui.PressButtonByName(FEEDBACK_SUBMIT_BUTTON)

        time.sleep(1)

        self.assertTrue(ui.OnFeedbackSuccess())

        ui.PressButtonByName(FEEDBACK_SUCCESS_OK_BUTTON)



