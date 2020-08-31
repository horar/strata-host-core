'''
Python script to run a test module.
Examples:
    Running a test module:
        python runtest.py "Tests.BoardTests" "test@test.com" "Strata12345" "tcp://127.0.0.1:5563"
    Running a specific test class:
        python runtest.py "Tests.BoardTests.LoginValidNoBoard" "test@test.com" "Strata12345" "tcp://127.0.0.1:5563"
    Running a specific test function:
        python runtest.py "Tests.PasswordResetTests.PasswordResetTest.test_passwordResetInvalid" "test@test.com" "Strata12345" "tcp://127.0.0.1:5563"

'''
import Common
import sys
if __name__ == "__main__":
    Common.runStandalone(sys.argv)