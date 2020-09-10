'''
Tests involving the feedback system.
'''

import Common
import sys
from GUIInterface.StrataUI import *

class Feedback(unittest.TestCase):

    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        ui = StrataUI()
        Logout(ui)

    def test_feedback(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertTrue(ui.OnLoginScreen())
        Login(ui, args.username, args.password, self)

        self.assertTrue(ui.OnPlatformView())

        ui.PressButton(Common.USER_ICON_BUTTON)
        ui.PressButton(Common.FEEDBACK_BUTTON)

        # Feedback should open and have submit disabled because nothing has been inputted.
        self.assertTrue(ui.OnFeedback())

        ui.PressButton(Common.FEEDBACK_BUG_BUTTON)
        ui.SetEditText(Common.FEEDBACK_EDIT, "this is a cool product", property=PropertyId.NameProperty)

        ui.PressButton(Common.FEEDBACK_SUBMIT_BUTTON)

        self.assertTrue(ui.AlertExists(Common.FEEDBACK_SUBMIT_SUCCESS_ALERT))

