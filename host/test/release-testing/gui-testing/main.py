'''
Main testing script. Assumes that Strata is open, visible, and maximized
'''
import unittest
import NewRegisterTests
import InvalidInputTests
import BoardTests
import FeedbackTests
import PasswordResetTests
import SystemInterface as cleanup
import GUIInterface.PlatformView as platform
import GUIInterface.General as general
import StrataNetworkInterface as strata

if __name__ == "__main__":

    #Wait for strata to start

    #Logout and remove cached login information if a user was previously logged in to Strata
    if platform.findPlatformView():
        cleanup.removeLoginInfo()
        platform.logout()

    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(BoardTests),
                                # unittest.defaultTestLoader.loadTestsFromModule(FeedbackTests),
                                # unittest.defaultTestLoader.loadTestsFromModule(NewRegisterTests),
                                # unittest.defaultTestLoader.loadTestsFromModule(InvalidInputTests),
                                # unittest.defaultTestLoader.loadTestsFromModule(PasswordResetTests)
                                ])

    runner = unittest.TextTestRunner(verbosity=2)

    runner.run(suite)

    #print("Errors\n" + str(result.errors) + "\nFaliures\n" + str(result.failures) + "\nSuccesses\n")
