'''
Testing script to be ran under a disconnected network. Strata application must not be allowed to access the network for a successful test. Assumes Strata is open, visible, and maximized.
'''
from Tests import NoNetworkTests, TestCommon
import unittest

if __name__ == "__main__":
    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(NoNetworkTests),
                                ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    TestCommon.writeResults(len(result.errors) + len(result.failures), result.testsRun)

