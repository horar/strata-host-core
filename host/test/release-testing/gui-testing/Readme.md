#Overview
This is the powershell and accompanying python scripts for testing the Strata gui.

Do not touch the mouse or keyboard while the test suite is running. Make sure no application will open in front of Strata while the test suite is running, or erroneous results/inputs may be made.

This test suite assumes:
* Strata is installed
* The HCS is not running
* All user elements in Strata are visible on the screen at all times during the tests. 
* The "scaling" display setting is above 125% (some DPIs cause UI elements to change font size and confuse the test suite)
* The python script has full admin access.
* No user has logged in and exited Strata before running the test suite (the user, last_name, first_name, token, and usernamestore fields in Strata Developer Studio.ini in the \AppData\ON Semiconductor directory are empty).

Additionally, it is useful to set the authentication_server property in Strata Developer Studio.ini in the \AppData\ON Semiconductor directory to a test authentication server so erroneous users do not fill the database.

This test suite runs the following test cases:
* Logging in with a board connected
* Logging in with a board disconnected
* Sending user feedback
* Attempting to log in with invalid user information
* Attempting to create a new user with existing information
* Attempting to create a new user with new information
* Attempting to login/create a new user when the network is disconnected
* Attempting to reset the user's password, with invalid and valid usernames.
* Logging in, closing Strata, and reopening it.

The script will automatically clear login information and close accounts of new users it makes. However, it is possible that a test failure will make it impossible to get enough information to close an account.

#Adding/Modifying Tests

##Overview
All tests are contained in the "Tests" folder. Each test module may contain multiple test classes, and each test class may contain multiple test functions. 

Group tests by category by placing them in the appropriate module, and group tests that may be run without additional setup by class (each class sets up the test environment, runs tests alphabetically, and tears down the test environment).

The Test-GUI script runs tests in the following environments:
* Network enabled, user logged out previously
* Network disabled, user logged out previously
* Network enabled, user logged in previously

Place test modules into the appropriate main file's TestSuite constructor. Create new test environments by manipulating the environment in the Powershell script and then running the appropriate main file to run tests in that environment.

##Adding Images
The test suite uses image recognition to find and verify the operation of GUI elements. The images are placed in the "\GUIInterface\images" folder. It is recommended to convert images to grayscale as much as possible, as they occupy much less space than color images. The script "to_greyscale.py" automatically converts all images in the "/GUIInterface/images" folder to grayscale.

Image recognition tasks are split by category into:
* General
    * Images that are not unique to any other category
    * Additional utilities for manipulating the screen
* Login
    * Images and screen manipulations unique to the login screen
* PlatformView
    * Images and screen manipulations unique to the platform view
* Register
    * Images and screen manipulations unique to the register screen

Image finding code generally follows this format:
```buildoutcfg
return pyautogui.locateCenterOnScreen(os.path.join(__imagesPath, <image name>), grayscale = True)
```
With \<image name> replaced by the name of the image in the "images" folder.

For UI elements where it is not possible to capture a unique picture (such as the user icon), include a `confidence=<confidence rating>` argument to `locateCenterOnScreen()` to find multiple variations of the same picture.

##Troubleshooting
Because the test suite directly interprets the screen to verify and manipulate Strata, delays in animations or the network can cause erroneous inputs or test failures. 

For loading delay, use `tryRepeat()` in the General module to repeatedly look for the UI element. This may fail if using the previously mentioned `confidence` argument to `locateCenterOnScreen()`, as loading icons can be misinterpreted as other UI elements. In this case, use a hardcoded delay. 

For animation delay or network delay that cannot be solved by `tryRepeat()`, a hardcoded delay may be used. The `Latency` context in the General module may be used to apply a delay to the entry and exit of the context.  

**It is recommended to add a delay before and after setting up a test class.** This avoids errors from animations caused by previous tests.

###TODO: Accounting for Screen Differences
Different DPI ("Scaling" in the display settings) settings may cause UI elements to appear different enough to not be recognized. The solution is to detect what the DPI of the screen is, and substitute a different image when searching for UI elements. Currently, this functionality has not been implemented. 

A more stable but development heavy solution would be to directly interface with UI elements using a window messaging system such as Windows UI Automation or similar.

##Additional Functionality
Functions for interfacing with Strata through the HCS are placed in the StrataInterface singleton. **Run the `bindToStrata()` function as soon as possible if connecting to Strata**. The HCS port needs to be connected to before Strata starts fully. 

Functions for interfacing with other endpoints and .ini files are placed in the SystemInterface module.

