'''
Set up Strata to test opening Strata after closing a logged in session. Assumes Strata is open, visible, and maximized.
'''
import sys

import Common
from GUIInterface.StrataUI import *

if __name__ == "__main__":
    Common.awaitStrata()
    args = Common.getCommandLineArguments(sys.argv)

    ui = StrataUI()
    ui.PressRememberMeCheckbox()
    Login(ui, args.username, args.password)

    # Wait until user is logged in
    while not ui.OnPlatformView():
        pass
