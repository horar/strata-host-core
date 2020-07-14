This is the powershell and accompanying python scripts for testing the Strata gui.

Do not touch the mouse or keyboard while the test suite is running. Make sure no application will open in front of Strata while the test suite is running, or erroneous results/inputs may be made.

There are a number of assumptions that this test suite has:
* Strata is installed
* The HCS is not running
* All user elements in Strata are visible on the screen at all times during the tests. 
* The "scaling" display setting is above 125% (some DPIs cause UI elements to change font size and confuse the test suite)
* The python script has full admin access.
* No user has logged in and exited Strata before running the test suite (the user, last_name, first_name, token, and usernamestore fields in Strata Developer Studio.ini in the \AppData\ON Semiconductor directory are empty).

Additionally, it is useful to set the authentication_server property in Strata Developer Studio.ini in the AppData\ON Semiconductor directory to a test authentication server so erroneous users do not fill the database.

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

The script will automatically clear login information and close accounts of new users it makes. However, it is possible that a test faliure will make it impossible to get enough information to close an account.
