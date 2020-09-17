# GUI Test Suite
This test suite verifies gui functionality on a pre-built Strata executable. It may be ran standalone using runtest.py or as part of the release testing suite using Test-GUI.ps1.

# Standalone Testing
The tests contained in the Tests folder may be ran using the command `python runtest.py`. 
```
usage: runtest.py 
[-h] 
[--username username] 
[--password password] 
[--hcsAddress hcs address] 
[--strataPath strata path] 
[--strataIni strata ini path] 
[--resultsPath results file path] 
[--appendResults] 
[--verbose] 
[testNames [testNames ...]]

Run a test or tests.

positional arguments:
  testNames             Unittest modules or test classes

optional arguments:
  -h, --help            show this help message and exit
  --username username   Valid username
  --password password   Valid password
  --hcsAddress hcs address
                        HCS address (will override hcs with script hcs)
  --strataPath strata path
                        Path to Strata executable (will open strata)
  --strataIni strata ini path
                        Path to Strata ini
  --resultsPath results file path
                        Specify that a results file should be written to with the given path
  --appendResults       Append results to result file instead of making a new one.
  --verbose             Output logging messages to stdout

```   


# Test Development
## Overview
This is a step-by-step guide for creating a GUI test for a new QML element. More information on test development using UI Automation may be found [here](https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/1173749769/Automated+GUI+Testing+Using+Windows+UI+Automation+Framework).

## Enable Accessibility for the QML Element

 When creating a new QML element, [Accessible](https://doc.qt.io/qt-5/qml-qtquick-accessible.html) properties must be set in order for the element to be visible to UI Automation. At a minimum, the [role](https://doc.qt.io/qt-5/qml-qtquick-accessible.html#role-prop) property must be set to the most appropriate element type for the QML element. Setting a [name](https://doc.qt.io/qt-5/qml-qtquick-accessible.html#name-prop) and appropriate handlers are also beneficial for locating and manipulating the element. 

Example code: 
```
Rectangle {
    ...
    function clickAction() {
        ...
    }
    MouseArea {
        ...
        onClick: clickAction()
    }
    Accessible.name = "myCustomButton"
    Accessibile.role = Accessible.Button
    Accessible.onPressAction: clickAction()
}
```
### Existing Qt Elements

Built-in elements such as the Button class should already have Accessible properties set. However, action handlers such as onPressAction may not call onClick. In this case, onPressAction must be manually set to the appropriate action.
```
Button {
    ...
    function clickAction() {
        ...
    }
    onClick: clickAction()
    Accessible.onPressAction: clickAction()
}
```
## Verify UI Accessibility
[Inspect.exe](https://docs.microsoft.com/en-us/windows/win32/winauto/inspect-objects)  may be used to verify that the elements under test are accessible to UI Automation and behave as expected when actions are performed on them. It is also useful for creating strategies to access elements that may be insdistinguishable by type or name from other elements.

## Implement UI Automation Wrapper
The test suite offers the StrataUI class to procedurally access the UI without directly interfacing with the uiautomation library. However, some elements may require multiple steps to locate on the ui. In this case, StrataUI may be extended with the appropriate logic for locating the element. `findButtonByHeight` and `FindAll` can be useful in locating specific elements that are difficult to distinguish from each other.

## Implement Test
All tests are contained in the "Tests" folder and are categorized by the functionality they test. All test functions are contained in a `TestCase` extending class and are prefixed by `test_`. Command line parameters may be accessed through `Common.getCommandLineArguments`. Logging should be performed through the common logging environment `Common.TestLogger`. 

All tests should be assumed to start and end on the login/register screen, unless executed after logging into Strata and restarting.


Example:
```python
'''
In module Tests/MyTestModule.py
'''
import unittest
import Common
import sys
from GUIInterface.StrataUI import *

class TestClass(unittest.TestCase):
    def setUp():
        #place initialization here (switching to a different view, etc.)

    def tearDown():
        #place cleanup here (switching back to the login view, etc.)
    
    def test_functionality():
        #Do test here

        #Access UI
        ui = StrataUI()
    
        #Get command line parameters
        args = Common.getCommandLineArguments(sys.argv)
        
        #Do tests
        ...

```

## Add Test to Test Suite
Tests may be added to the Test-GUI.ps1 script by modifying the variables `$BasicTests`, `$NoNetworkTests`, and `$StrataRestartTests` to run the test normally, with no network connected, and after a user has logged in and restarted Strata. Test resolution can be done to the function level, for example: `Tests.MyTestModule.TestClass.test_functionality` will run the test `test_functionality` specifically, while `Tests.MyTestModule` will run all test classes and functions contained in `MyTestModule`.

