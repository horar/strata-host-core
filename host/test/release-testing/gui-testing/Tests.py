import unittest
import GUIInterface.General as general
import GUIInterface.Login as login
import GUIInterface.PlatformView as platform
import GUIInterface.Register as register
import pyautogui
import time
import http

INVALID_USERNAME = "badusername"
INVALID_PASSWORD = "badpassword"

VALID_USERNAME = "test@test.com"
VALID_PASSWORD = "Strata12345"

NEW_USERNAME = "bep@bip.com"
NEW_PASSWORD = "Bepzipbip15"
NEW_FIRST_NAME = "Bep"
NEW_LAST_NAME = "Zip"
NEW_COMPANY = "ON Semiconductor"
NEW_TITLE = "Vice Manager"


class StartupTest(unittest.TestCase):
        def test_splashpage(self):
                self.assertIsNotNone(general.findSplashscreen())

class RegisterNew(unittest.TestCase):
        def setUp(self) -> None:
                general.clickAt(register.findRegisterTabButton())
        def tearDown(self) -> None:
                platform.logout()


class LoginValidNoBoard(unittest.TestCase):
        def setUp(self):
                pyautogui.alert(text='Please disconnect all platforms from system.', title='Important', button='OK')
                login.setToLoginTab()

        def tearDown(self) -> None:
                platform.logout()

        def test_login_submit(self):
                general.inputTextAt(login.findUsernameInput(), VALID_USERNAME)

                #assert that submit is disabled when only one field is filled.
                self.assertIsNotNone(login.findLoginSubmitDisabled())

                general.inputTextAt(login.findPasswordInput(), VALID_PASSWORD)

                submitLocation = login.findLoginSubmitEnabled()
                #assert that submit is enabled when both fields are filled.
                self.assertIsNotNone(submitLocation)

                #Submit invalid username/password
                general.clickAt(submitLocation)

                #Wait for network
                time.sleep(1)

                self.assertIsNotNone(platform.findPlatformView())

class LoginValidWithBoard(unittest.TestCase):
        def setUp(self):
                pyautogui.alert(text='Please plug in the Multifunction Logic Gates platform.', title='Important', button='OK')

                login.setToLoginTab()

        def tearDown(self) -> None:
                platform.logout()

        def test_login_submit(self):
                general.inputTextAt(login.findUsernameInput(), VALID_USERNAME)

                #assert that submit is disabled when only one field is filled.
                self.assertIsNotNone(login.findLoginSubmitDisabled())

                general.inputTextAt(login.findPasswordInput(), VALID_PASSWORD)

                submitLocation = login.findLoginSubmitEnabled()
                #assert that submit is enabled when both fields are filled.
                self.assertIsNotNone(submitLocation)

                #Submit invalid username/password
                general.clickAt(submitLocation)

                #Wait for network
                time.sleep(1)

                self.assertIsNotNone(platform.findLogicGateView())


class LoginSubmitAndValidateInvalidTest(unittest.TestCase):
        def setUp(self):
                login.setToLoginTab()

        def tearDown(self) -> None:
                general.deleteTextAt(login.findUsernameInput())
                #Wait for error to dissapear
                time.sleep(0.5)
                general.deleteTextAt(login.findPasswordInput())

        def test_login_submit(self):
                general.inputTextAt(login.findUsernameInput(), INVALID_USERNAME)

                #assert that submit is disabled when only one field is filled.
                self.assertIsNotNone(login.findLoginSubmitDisabled())

                general.inputTextAt(login.findPasswordInput(), INVALID_PASSWORD)

                submitLocation = login.findLoginSubmitEnabled()
                #assert that submit is enabled when both fields are filled.
                self.assertIsNotNone(submitLocation)

                #Submit invalid username/password
                general.clickAt(submitLocation)

                #Wait for network
                time.sleep(1)

                self.assertIsNotNone(login.findLoginError())



