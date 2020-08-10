'''
Singleton module for constants and methods common across tests and mains
'''
import os
import sys
import json

VALID_USERNAME = None

VALID_PASSWORD = None

DEFAULT_URL = None


LOGIC_GATE_CLASS_ID = "201"

ANIMATION_LATENCY = 0.2

__dirname = os.path.dirname(__file__)
RESULT_FILE = os.path.join(__dirname, 'results.txt')

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
