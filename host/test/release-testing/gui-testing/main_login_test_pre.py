'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
import sys

import Common
from GUIInterface.StrataUI import *

if __name__ == "__main__":
    Common.initIntegratedTest(sys.argv)
    Common.awaitStrata()

    ui = StrataUI()
    ui.PressRememberMeCheckbox()
    Login(ui, Common.VALID_USERNAME, Common.VALID_PASSWORD)

    # Wait until user is logged in
    while not ui.OnPlatformView():
        pass
