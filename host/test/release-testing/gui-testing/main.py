'''
Main testing script. Assumes that Strata is open, visible, and maximized
'''
import sys
import unittest

import Common
import StrataInterface as strata
from Tests import InvalidInputTests, PasswordResetTests, NewRegisterTests, FeedbackTests, BoardTests

if __name__ == "__main__":
    Common.initIntegratedTest(sys.argv)
    strata.bindToStrata(Common.DEFAULT_URL)

    Common.awaitStrata()

    suite = unittest.TestSuite([
        unittest.defaultTestLoader.loadTestsFromModule(BoardTests),
        unittest.defaultTestLoader.loadTestsFromModule(FeedbackTests),
        unittest.defaultTestLoader.loadTestsFromModule(NewRegisterTests),
        unittest.defaultTestLoader.loadTestsFromModule(InvalidInputTests),
        unittest.defaultTestLoader.loadTestsFromModule(PasswordResetTests)
    ])
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Write a blank file
    with open(Common.RESULT_FILE, "w") as resultFile:
        pass

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)
