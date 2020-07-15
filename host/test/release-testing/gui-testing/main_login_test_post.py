'''
Testing script to be run after logging into strata and closing it. Assumes Strata is open, visible, and maximized.
'''
import unittest
from Tests import TestCommon, StrataRestartTests

if __name__ == "__main__":

    suite = unittest.TestSuite([
                                unittest.defaultTestLoader.loadTestsFromModule(StrataRestartTests),
                                ])

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    TestCommon.writeResults(len(result.errors) + len(result.failures), result.testsRun)

