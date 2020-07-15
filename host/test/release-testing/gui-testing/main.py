'''
Main testing script. Assumes that Strata is open, visible, and maximized
'''
import unittest

import GUIInterface.PlatformView as platform
from Tests import InvalidInputTests, TestCommon, PasswordResetTests, NewRegisterTests, FeedbackTests, BoardTests
import StrataInterface as strata
import SystemInterface as cleanup

if __name__ == "__main__":
    #TODO: account for DPI giving different UI elements
    # if len(sys.argv) < 2:
    #     #TODO: Help message
    #     print("Invalid number of arguments")
    #     sys.exit(0)
    # else:
    #     strataPath = sys.argv[1]
    # if len(sys.argv) > 2:
    #     prop.LARGE_TEXT = sys.argv[2] == "100" or sys.argv[2] == "125"

    strata.bindToStrata()

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
    with open(TestCommon.RESULT_FILE, "w") as resultFile:
        pass

    TestCommon.writeResults(len(result.errors) + len(result.failures), result.testsRun)

    strata.cleanup()

    #exit(0)

    #print("Errors\n" + str(result.errors) + "\nFaliures\n" + str(result.failures) + "\nSuccesses\n")
