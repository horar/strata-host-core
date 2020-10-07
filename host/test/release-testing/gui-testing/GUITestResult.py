import unittest

class GUITestResult(unittest.TextTestResult):
    def startTest(self, test: unittest.case.TestCase) -> None:
        unittest.TestResult.startTest(self, test)
        self.stream.writeln("Starting test: " + self.getDescription(test))
        self.stream.flush()

    def addSuccess(self, test: unittest.case.TestCase) -> None:
        unittest.TestResult.addSuccess(self, test)
        self.stream.writeln("PASS\n")