'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
from GUIInterface.StrataUI import *
import time
import Common
import sys
import StrataInterface as strata

if __name__ == "__main__":
    Common.populateConstants(sys.argv)
    Common.awaitStrata()

    # strata.bindToStrata(Common.DEFAULT_URL)
    ui = StrataUI()
    Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

    #Wait until user is logged in
    while not ui.OnPlatformView():
        pass



