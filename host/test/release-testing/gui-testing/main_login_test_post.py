'''
Testing script to be run after logging into strata and closing it. Assumes Strata is open, visible, and maximized.
'''
import unittest
from Tests import StrataRestartTests
import Common
import sys
import StrataInterface as strata


if __name__ == "__main__":
    Common.populateConstants(sys.argv)
    Common.awaitStrata()
    #strata.bindToStrata(Common.DEFAULT_URL)


    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(StrataRestartTests),
                                ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)
    # strata.cleanup()

