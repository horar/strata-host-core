'''
Main testing script. Assumes that Strata is open, visible, and maximized
'''
import sys
import unittest

import BoardTests
import FeedbackTests
import GUIInterface.PlatformView as platform
import GUIInterface.ScreenProperties as prop
import InvalidInputTests
import NewRegisterTests
import PasswordResetTests
import StrataInterface as strata
import SystemInterface as cleanup

if __name__ == "__main__":
    strataPath = None
    if len(sys.argv) < 2:
        #TODO: Help message
        print("Invalid number of arguments")
        sys.exit(0)
    else:
        strataPath = sys.argv[1]
    if len(sys.argv) > 2:
        prop.LARGE_TEXT = sys.argv[2] == "100" or sys.argv[2] == "125"

    strata.bindToStrata(strataPath)

    #Logout and remove cached login information if a user was previously logged in to Strata
    if platform.findPlatformView():
        cleanup.removeLoginInfo()
        platform.logout()

    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(BoardTests),
                                unittest.defaultTestLoader.loadTestsFromModule(FeedbackTests),
                                unittest.defaultTestLoader.loadTestsFromModule(NewRegisterTests),
                                unittest.defaultTestLoader.loadTestsFromModule(InvalidInputTests),
                                unittest.defaultTestLoader.loadTestsFromModule(PasswordResetTests)
                                ])

    runner = unittest.TextTestRunner(verbosity=2)

    runner.run(suite)
    strata.cleanup()
    #exit(0)

    #print("Errors\n" + str(result.errors) + "\nFaliures\n" + str(result.failures) + "\nSuccesses\n")
