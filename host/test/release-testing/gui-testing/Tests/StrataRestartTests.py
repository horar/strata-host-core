'''
Tests to be ran after logging into Strata and closing it.
'''
import unittest
import GUIInterface.PlatformView as platform
import GUIInterface.General as general
import SystemInterface as cleanup

class StrataLoginPostRestartTest(unittest.TestCase):
    '''
    Test autologin after restarting strata when previously logging in.
    This test should only be run after logging in and restarting strata.
    '''
    def tearDown(self) -> None:
        cleanup.removeLoginInfo()
        platform.logout()
    def test_loginPostRestart(self):
        #Strata should start immediately in platform view
        self.assertIsNotNone(general.tryRepeat(platform.findPlatformView))
