'''
Tests involving creating a new user.
'''
import unittest
from GUIInterface.StrataUI import *
import time
import SystemInterface as cleanup
import Common

# NEW_USERNAME = "bep@bip.com"
NEW_PASSWORD = "Bepzipbip15"
NEW_FIRST_NAME = "First"
NEW_LAST_NAME = "Last"
NEW_COMPANY = "ON Semiconductor"
NEW_TITLE = "QA"



class RegisterNew(unittest.TestCase):
    '''
    Test registering a new user.
    '''
    def setUp(self) -> None:
        ui = StrataUI()
        ui.SetToTab(Common.REGISTER_TAB)

    def tearDown(self) -> None:

        ui = StrataUI()
        cleanup.closeAccount()
        Logout(ui)

    def test_registernew(self):
        ui = StrataUI()
        #Assert that on registration page
        self.assertTrue(ui.OnRegisterScreen())

        newUsername = Common.randomUsername()
        Register(ui, newUsername, NEW_PASSWORD, NEW_FIRST_NAME, NEW_LAST_NAME, NEW_TITLE, NEW_COMPANY)

        self.assertTrue(ui.AlertExists(Common.REGISTER_ALERT))

        ui.SetToLoginTab()
        Login(ui, newUsername, NEW_PASSWORD)

        self.assertTrue(ui.OnPlatformView())






