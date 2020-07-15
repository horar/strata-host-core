'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
import GUIInterface.Login as login
import GUIInterface.General as general
import GUIInterface.PlatformView as platform

from Tests import TestCommon

if __name__ == "__main__":
    #set up Strata for the test by logging in
    login.login(TestCommon.VALID_USERNAME, TestCommon.VALID_PASSWORD)

    #Wait untill user is logged in
    general.tryRepeat(platform.findPlatformView)
