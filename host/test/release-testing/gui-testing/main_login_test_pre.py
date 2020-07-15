'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
import GUIInterface.Login as login
import GUIInterface.General as general
import GUIInterface.PlatformView as platform

import Common
import sys

if __name__ == "__main__":
    Common.populateConstants(sys.argv)

    #set up Strata for the test by logging in
    login.login(Common.VALID_USERNAME, Common.VALID_PASSWORD)

    #Wait untill user is logged in
    general.tryRepeat(platform.findPlatformView)
