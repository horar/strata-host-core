'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
import GUIInterface.Login as login
import GUIInterface.General as general
import GUIInterface.PlatformView as platform

import Common
import sys
import StrataInterface as strata

if __name__ == "__main__":
    Common.populateConstants(sys.argv)

    # strata.bindToStrata(Common.DEFAULT_URL)

    with general.Latency(5, 0):
        #set up Strata for the test by logging in
        login.login(Common.VALID_USERNAME, Common.VALID_PASSWORD)

    #Wait untill user is logged in
    general.tryRepeat(platform.findPlatformView)
    # strata.cleanup()