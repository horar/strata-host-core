'''
Testing script to be ran under a disconnected network. Strata application must not be allowed to access the network for a successful test. Assumes Strata is open, visible, and maximized.
'''
import sys
import unittest

import Common
from Tests import NoNetworkTests

if __name__ == "__main__":
    Common.initIntegratedTest(sys.argv)
    Common.awaitStrata()

    suite = unittest.TestSuite([
        unittest.defaultTestLoader.loadTestsFromModule(NoNetworkTests),
    ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)
