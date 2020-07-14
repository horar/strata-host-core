import os
VALID_USERNAME = "test@test.com"
VALID_PASSWORD = "Strata12345"

LOGIC_GATE_CLASS_ID = "201"
ANIMATION_LATENCY = 0.2

__dirname = os.path.dirname(__file__)
RESULT_FILE = os.path.join(__dirname, 'results.txt')


def writeResults(totalFails, totalTests):
    '''
    Write <total successes>, <total tests> to the results file.
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
