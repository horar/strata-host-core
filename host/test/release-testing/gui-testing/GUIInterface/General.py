'''
Operations for general finding and manipulation
'''
import pyautogui
import os

__dirname = os.path.dirname(__file__)
__imagesPath = os.path.join(__dirname, 'images')

class Latency():
    '''
    Context class to wait a certain number of seconds when entering and exiting the context.
    '''
    def __init__(self, inSeconds, outSeconds = None):
        self.inSeconds = inSeconds

        if outSeconds:
            self.outSeconds = outSeconds
        else:
            self.outSeconds = inSeconds

    def __enter__(self):
        pyautogui.sleep(self.inSeconds)
    def __exit__(self, exc_type, exc_val, exc_tb):
        pyautogui.sleep(self.outSeconds)


def findSplashscreen():
    '''
    Determine if Strata is open
    :return: None if unable to find.
    '''
    return pyautogui.locateOnScreen(os.path.join(__imagesPath, "StrataDeveloperStudioLoginBox.PNG"), grayscale = True)
def findSplashLogo():
    '''
    Find logo for login/register screen
    :return: None if unable to find, coordnates of center of logo if able to find.
    '''
    return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, "SplashLogo.PNG"), grayscale = True)
def deleteTextAt(location):
    '''
    Click on an input box at the given location and select and remove al text.
    :param location:
    :return: the location went to.
    '''
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.hotkey('ctrl', 'a')
    pyautogui.press('backspace')
    return location

def inputTextAt(location, value):
    '''
    Click on an input box at the given location and input value.
    :param location:
    :param value:
    :return: the location written to.
    '''
    pyautogui.moveTo(location)
    pyautogui.click()
    pyautogui.write(value)
    return location

def clickAt(location):
    '''
    Click a given location.
    :param location:
    :return: The location clicked on.
    '''
    if location is not None:
        pyautogui.moveTo(location)
        pyautogui.click()
    return location

def tryRepeat(f, delay=0.2, maxAttempts=10):
    '''
    Attempt f at a period delay for maxAttempts attempts until f returns a value that is not None.
    :param f: The function to attempt
    :param delay: How long to wait between attempts
    :param maxAttempts: How many attempts to do.
    :return: None if None was returned maxAttempts times, the result of f otherwise.
    '''
    for i in range(0, maxAttempts):
        result = f()
        if result is not None:
            return result
        pyautogui.sleep(delay)
    return None



if __name__ == "__main__":
    findSplashscreen()