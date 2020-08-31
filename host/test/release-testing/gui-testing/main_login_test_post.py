'''
Testing script to be run after logging into strata and closing it. Assumes Strata is open, visible, and maximized.
'''
import unittest
from Tests import StrataRestartTests
import Common
import sys

if __name__ == "__main__":
    Common.initIntegratedTest(sys.argv)
    Common.awaitStrata()

    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(StrataRestartTests),
                                ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    Common.writeResults(len(result.errors) + len(result.failures), result.testsRun)

