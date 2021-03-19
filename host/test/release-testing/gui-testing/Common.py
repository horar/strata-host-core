'''
Singleton module for constants and methods common across tests and mains
'''
import argparse
import os
import time
import uuid
import psutil
import logging
import sys

class TestLogger:
    def __enter__(self):

        self.logger = logging.getLogger(COMMON_LOGGER)

        #Unittest replaces sys.stdout after initializing, so re-add it to the logger
        self.streamHandler = logging.StreamHandler(sys.stdout)

        formatter = logging.Formatter('\t%(message)s')
        self.streamHandler.setFormatter(formatter)

        self.logger.addHandler(self.streamHandler)

        return self.logger

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.logger.removeHandler(self.streamHandler)


#Key for logger object
COMMON_LOGGER = "unittestlogger"

STRATA_WINDOW = "ON Semiconductor: Strata Developer Studio"
LOGIN_TAB = "Login"
REGISTER_TAB = "Register"

USERNAME_EDIT = "Username/Email"
PASSWORD_EDIT = "Password"
REMEMBER_ME_CHECKBOX = "Remember Me"

USER_ICON_BUTTON = "User Icon"
LOGOUT_BUTTON = "Log Out"

FEEDBACK_BUTTON = "Feedback"
FEEDBACK_SUBMIT_BUTTON = "Submit"
FEEDBACK_EDIT = "FeedbackEdit"
FEEDBACK_SUCCESS_OK_BUTTON = "OK"
FEEDBACK_SUCCESS_TEXT = "Submit Feedback Success"
FEEDBACK_BUG_BUTTON = "Bug"

FIRST_NAME_EDIT = "First Name"
LAST_NAME_EDIT = "Last Name"
COMPANY_EDIT = "Company"
TITLE_EDIT = "Title (Optional)"
EMAIL_EDIT = "Email"
REGISTER_PASSWORD_EDIT = "Password"
CONFIRM_PASSWORD_EDIT = "Confirm Password"

REGISTER_ALERT = "Account already exists for this email address"
LOGIN_INVALID_ALERT = "Username and/or password is incorrect"
FEEDBACK_SUBMIT_SUCCESS_ALERT = "Feedback successfully submitted!"
NO_NETWORK_LOGIN_ALERT = "Connection to authentication server failed"
NO_NETWORK_REGISTER_ALERT = "Connection to registration server failed"

def forgotPasswordValidAlert(name):
    return "Email with password reset instructions is being sent to " + name

def forgotPasswordInvalidAlert(name):
    return "No user found with email " + name

def registerSuccessAlert(name):
    return "Account successfully registered to " + name + "!"

RESET_PASSWORD_OPEN_BUTTON = "Forgot Password"
RESET_PASSWORD_CLOSE_BUTTON = "ClosePopup"
RESET_PASSWORD_EDIT = "example@onsemi.com"
RESET_PASSWORD_SUBMIT_BUTTON = "Submit"

PLATFORM_CONTROLS_BUTTON = "Open Hardware Controls"

STRATA_PROCESS = "Strata Developer Studio.exe"
LOGIC_GATE_CLASS_ID = "201"

def randomUsername():
    return str(uuid.uuid4()) + "@onsemi.com"


def writeResults(totalFails, totalTests, path):
    '''
    Write <total successes>,<total tests> to the results file.
    :param totalFails:
    :param totalTests:
    :return:
    '''
    prevSuccesses = 0
    prevTotal = 0

    if not os.path.exists(path):
        f = open(path, "w")
        f.close()

    with open(path, "r") as resultsFile:
        results = resultsFile.read()
        if results != "":
            prevSuccesses, prevTotal = int(results.split(",")[0]), int(results.split(",")[1])

    newTotal = totalTests + prevTotal
    newSuccesses = (totalTests - totalFails) + prevSuccesses
    with open(path, "w") as resultsFile:
        resultsFile.write(str(newSuccesses) + "," + str(newTotal))



def getCommandLineArguments(argv):
    '''
    Get arguments from argv.
    Arguments are:
    testNames: A list of tests in the format Tests.<test module>.[test class].[test function]
    username: valid username
    password: valid password
    hcsAddress: HCS tcp address
    strataPath: Path to strata executable
    strataIni: Path to strata ini file
    resultsPath: Path to a results file
    appendResults: If resultsPath is set, append results to that file rather than creating a new file
    verbose: If verbose is set, output extra logging messages to stdout.
    '''
    parser = argparse.ArgumentParser(description="Run a test or tests.")
    parser.add_argument("testNames", nargs='*', type=str, help="Unittest modules or test classes")
    parser.add_argument("--username", action="store", type=str, help="Valid username", metavar="username")
    parser.add_argument("--password", action="store", type=str, help="Valid password", metavar="password")
    parser.add_argument("--hcsAddress", action="store", type=str, help="HCS address (will override hcs with script hcs)",
                        metavar="hcs address")
    parser.add_argument("--strataPath", action="store", type=str, help="Path to Strata executable (will open strata)",
                        metavar="strata path")
    parser.add_argument("--strataIni", action="store", type=str, help="Path to Strata ini", metavar="strata ini path")
    parser.add_argument("--resultsPath", action="store", type=str, help="Specify that a results file should be written to with the given path", metavar="results file path")
    parser.add_argument("--appendResults", action="store_true", help = "Append results to result file instead of making a new one.")
    parser.add_argument("--verbose", action="store_true", help= "Output logging messages to stdout")
    return parser.parse_args(argv[1:])

def processRunning(name):
    return name in (p.name() for p in psutil.process_iter())

def awaitStrata():
    while not processRunning("Strata Developer Studio.exe"):
        pass

    # wait for strata to load fully
    time.sleep(5)
