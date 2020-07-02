import unittest
import NewRegisterTests
import InvalidInputTests
import BoardTests
import FeedbackTests

if __name__ == "__main__":
    suite = unittest.TestSuite([unittest.defaultTestLoader.loadTestsFromModule(BoardTests),
                                unittest.defaultTestLoader.loadTestsFromModule(FeedbackTests),
                                unittest.defaultTestLoader.loadTestsFromModule(NewRegisterTests),
                                unittest.defaultTestLoader.loadTestsFromModule(InvalidInputTests),
                                ])
    def successHandler(test):
        print("Test " + test.id() + " successful")

    result = unittest.TestResult()
    result.addSuccess(successHandler)
    suite.run(result)
    print("Errors\n" + str(result.errors) + "\nFaliures\n" + str(result.failures) + "\nSuccesses\n")
