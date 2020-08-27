'''
Singleton module for constants and methods common across tests and mains
'''
import os
import sys
import uuid
import psutil
import time

VALID_USERNAME = None

VALID_PASSWORD = None

DEFAULT_URL = None

LOGIN_TAB = "Login"
REGISTER_TAB = "Register"

USERNAME_EDIT = "Username/Email"
PASSWORD_EDIT = "Password"

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
            prevSuccesses, prevTotal = int(results.split(",")[0]), int(results.split(",")[1])
    newTotal = totalTests + prevTotal
    newSuccesses = (totalTests - totalFails) + prevSuccesses
    with open(RESULT_FILE, "w") as resultsFile:
        resultsFile.write(str(newTotal) + ","+ str(newSuccesses))

def populateConstants(argv):
    '''
    Check for the correct number of arguments in argv and populate TestCommon.VALID_PASSWORD and TestCommon.VALID_USERNAME.
    Exits if invalid number of arguments supplied.
    :return:
    '''

    global VALID_PASSWORD
    global VALID_USERNAME
    global DEFAULT_URL
    if len(argv) < 4:
        print("Usage: <valid username> <valid password> <hcs tcp url>")
        sys.exit(0)
    else:
        VALID_USERNAME = argv[1]
        VALID_PASSWORD = argv[2]
        DEFAULT_URL = argv[3]

def processRunning(name):
    return name in (p.name() for p in psutil.process_iter())

def awaitStrata():
    while not processRunning("Strata Developer Studio.exe"):
        pass
    time.sleep(5)