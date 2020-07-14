'''
Testing script to be run after logging into strata and closing it. Assumes Strata is open, visible, and maximized.
'''
import unittest
import StrataRestartTests
import TestCommon

if __name__ == "__main__":

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(unittest.defaultTestLoader.loadTestsFromModule(StrataRestartTests))

    TestCommon.writeResults(len(result.errors) + len(result.failures), result.testsRun)

