'''
Tests to be ran after logging into Strata and closing it.
'''
import unittest
from GUIInterface.StrataUISingleton import finder
import GUIInterface.StrataUIHelper as macro
import time
import SystemInterface as cleanup

class StrataLoginPostRestartTest(unittest.TestCase):
    '''
    Test autologin after restarting strata when previously logging in.
    This test should only be run after logging in and restarting strata.
    '''
    def tearDown(self) -> None:
        ui = finder.GetWindow()
        macro.Logout(ui)

    def test_loginPostRestart(self):
        ui = finder.GetWindow()
        self.assertTrue(ui.OnPlatformViewScreen())
