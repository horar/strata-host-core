'''
Python script to run a test module. See Common.getCommandLineArguments for arguments.
Examples:
    Run all board tests:
        python runtest.py Tests.BoardTests --username "test@test.com" --password "Strata12345" --strataPath "(path to strata)" --hcsAddress "tcp://127.0.0.1:5563"
    Run specific test and log the result:
        python runtest.py Tests.InvalidInputTests.LoginInvalidTest --strataPath "(path to strata)" --resultsPath "results.txt"
'''
import sys
import subprocess
import StrataInterface as strata
import unittest

import Common
from GUITestResult import GUITestResult

if __name__ == "__main__":

    args = Common.getCommandLineArguments(sys.argv)
    if args.verbose:
        with Common.TestLogger() as logger:
            logger.setLevel("DEBUG")

    if args.strataPath:
        subprocess.Popen(args.strataPath)

    if not args.skipHcsBinding and args.hcsAddress:
        strata.bindToStrata(args.hcsAddress)
        
    if args.awaitStrata:
        Common.awaitStrata()

    tests = unittest.defaultTestLoader.loadTestsFromNames(args.testNames)
    runner = unittest.TextTestRunner(verbosity=2, descriptions=True, resultclass= GUITestResult)
    result = runner.run(tests)

    if args.resultsPath:
        if not args.appendResults:
            #write a blank file
            with open(args.resultsPath, "w") as resultFile:
                pass

        Common.writeResults(len(result.errors) + len(result.failures), result.testsRun, args.resultsPath)

