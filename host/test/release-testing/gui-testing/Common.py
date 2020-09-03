'''
Singleton module for constants and methods common across tests and mains
'''
import argparse
import os
import time
import uuid

import psutil

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

REGISTER_ALERT = "RegisterError"
LOGIN_ALERT = "LoginError"
RESET_PASSWORD_ALERT = "ResetPasswordAlert"

RESET_PASSWORD_OPEN_BUTTON = "Forgot Password"
RESET_PASSWORD_CLOSE_BUTTON = "ClosePopup"
RESET_PASSWORD_EDIT = "example@onsemi.com"
RESET_PASSWORD_SUBMIT_BUTTON = "Submit"

PLATFORM_CONTROLS_BUTTON = "Open Platform Controls"

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
            prevTotal, prevSuccesses = int(results.split(",")[0]), int(results.split(",")[1])

    newTotal = totalTests + prevTotal
    newSuccesses = (totalTests - totalFails) + prevSuccesses
    with open(path, "w") as resultsFile:
        resultsFile.write(str(newSuccesses) + "," + str(newTotal))


def getCommandLineArguments(argv):
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
    return parser.parse_args(argv[1:])

def processRunning(name):
    return name in (p.name() for p in psutil.process_iter())

def awaitStrata():
    while not processRunning("Strata Developer Studio.exe"):
        pass

    # wait for strata to load fully
    time.sleep(5)
