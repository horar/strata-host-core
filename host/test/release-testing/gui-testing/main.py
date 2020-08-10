'''
Main testing script. Assumes that Strata is open, visible, and maximized
'''
import unittest

import GUIInterface.PlatformView as platform
from Tests import InvalidInputTests, PasswordResetTests, NewRegisterTests, FeedbackTests, BoardTests
import Common
import StrataInterface as strata
import SystemInterface as cleanup
import sys

if __name__ == "__main__":
    Common.populateConstants(sys.argv)


    strata.bindToStrata(Common.DEFAULT_URL)

    #Logout and remove cached login information if a user was previously logged in to Strata
    cleanup.removeLoginInfo()
    if platform.findPlatformView():
        platform.logout()

    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(BoardTests),
                                unittest.defaultTestLoader.loadTestsFromModule(FeedbackTests),
                                unittest.defaultTestLoader.loadTestsFromModule(NewRegisterTests),
                                unittest.defaultTestLoader.loadTestsFromModule(InvalidInputTests),
                                unittest.defaultTestLoader.loadTestsFromModule(PasswordResetTests)
                                ])
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    #Write a blank file
    with open(Common.RESULT_FILE, "w") as resultFile:
        pass

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)

    strata.cleanup()
