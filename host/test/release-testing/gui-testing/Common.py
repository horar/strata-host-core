'''
Singleton module for constants and methods common across tests and mains
'''
import os
import sys
import uuid
import psutil
import time
import unittest
import subprocess
import argparse
import StrataInterface as strata

VALID_USERNAME = None

VALID_PASSWORD = None

DEFAULT_URL = None

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

ANIMATION_LATENCY = 0.2

__dirname = os.path.dirname(__file__)
RESULT_FILE = os.path.join(__dirname, 'results.txt')

def randomUsername():
    return str(uuid.uuid4()) + "@onsemi.com"

def writeResults(totalFails, totalTests):
    '''
    Write <total successes>,<total tests> to the results file.
    :param totalFails:
    :param totalTests:
    :return:
    '''
    prevSuccesses = 0
    prevTotal = 0

    if not os.path.exists(RESULT_FILE):
        f = open(RESULT_FILE, "w")
        f.close()

    with open(RESULT_FILE, "r") as resultsFile:
        results = resultsFile.read()
        if results != "":
            prevTotal, prevSuccesses = int(results.split(",")[0]), int(results.split(",")[1])
    newTotal = totalTests + prevTotal
    newSuccesses = (totalTests - totalFails) + prevSuccesses
    with open(RESULT_FILE, "w") as resultsFile:
        resultsFile.write(str(newSuccesses) + ","+ str(newTotal))
def initIntegratedTest(argv):
    '''
    This function should be used if running from the Test-GUI powershell script. Populate constants and exit with a message if the amount of arguments is incorrect.
    '''
    global VALID_PASSWORD
    global VALID_USERNAME
    global DEFAULT_URL

    if len(argv) < 4:
        print("Usage: <valid username> <valid password> <hcs tcp url>")
        sys.exit(0)
    VALID_USERNAME = argv[1]
    VALID_PASSWORD = argv[2]
    DEFAULT_URL = argv[3]

def runStandalone(argval):
    '''
    This function should be used if running a test standalone from the command line. Populate constants and run specified tests, or exit with a message if the amount of arguments is incorrect.
    :return:
    '''

    global VALID_PASSWORD
    global VALID_USERNAME
    global DEFAULT_URL
    parser = argparse.ArgumentParser(description="Run a test standalone.")
    parser.add_argument("testName", action="store")
    parser.add_argument("-u", action="store", type=str, help="Valid username", metavar="username")
    parser.add_argument("-p", action="store", type=str, help="Valid password", metavar="password")
    parser.add_argument("-a", action="store", type=str, help="HCS address (will override hcs with script hcs)", metavar="hcs address")
    parser.add_argument("-s", action="store", type=str, help="Path to Strata executable (will open strata)", metavar="strata path")
    args = parser.parse_args(argval[1:])

    if(args.testName == None):
        parser.print_help()
        sys.exit(0)

    VALID_USERNAME = args.u
    VALID_PASSWORD = args.p
    DEFAULT_URL = args.a

    if args.s:
        subprocess.Popen(args.s)
        if args.a:
            strata.bindToStrata(args.a)
        awaitStrata()

    tests = unittest.defaultTestLoader.loadTestsFromName(args.testName)
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(tests)


def processRunning(name):
    return name in (p.name() for p in psutil.process_iter())

def awaitStrata():

    while not processRunning("Strata Developer Studio.exe"):
        pass


    #wait for strata to load fully
    time.sleep(5)