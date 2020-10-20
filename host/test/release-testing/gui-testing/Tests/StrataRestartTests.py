'''
Tests to be ran after logging into Strata and closing it.
'''
from GUIInterface.StrataUI import *


class StrataLoginPostRestartTest(unittest.TestCase):
    '''
    Test autologin after restarting strata when previously logging in.
    This test should only be run after logging in and restarting strata.
    '''

    def tearDown(self) -> None:
        ui = StrataUI()
        LogoutIfNeeded(ui)

    def test_loginPostRestart(self):
        ui = StrataUI()
        self.assertTrue(ui.OnPlatformView())
