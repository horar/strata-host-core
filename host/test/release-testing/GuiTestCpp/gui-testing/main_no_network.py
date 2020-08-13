'''
Testing script to be ran under a disconnected network. Strata application must not be allowed to access the network for a successful test. Assumes Strata is open, visible, and maximized.
'''
from Tests import NoNetworkTests
import Common
import unittest
import sys
import StrataInterface as strata

if __name__ == "__main__":

    Common.populateConstants(sys.argv)
    Common.awaitStrata()
    # strata.bindToStrata(Common.DEFAULT_URL)


    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(NoNetworkTests),
                                ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)

    # strata.cleanup()