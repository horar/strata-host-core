'''
Python script to run a test module.
'''
import sys
import subprocess
import StrataInterface as strata
import unittest

import Common

if __name__ == "__main__":
    args = Common.getCommandLineArguments(sys.argv)

    if args.strataPath:
        subprocess.Popen(args.strataPath)

    if args.hcsAddress:
        strata.bindToStrata(args.hcsAddress)

    Common.awaitStrata()

    tests = unittest.defaultTestLoader.loadTestsFromNames(args.testNames)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(tests)

    if args.resultsPath:
        if not args.appendResults:
            #write a blank file
            with open(args.resultsPath, "w") as resultFile:
                pass

        Common.writeResults(len(result.errors) + len(result.failures), result.testsRun, args.resultsPath)

