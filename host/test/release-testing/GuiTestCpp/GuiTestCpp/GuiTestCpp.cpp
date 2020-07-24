#include "pch.h"
#include "CppUnitTest.h"
#include "StrataUI.cpp"
#define ASSERT_S_OK(operation) Assert::IsTrue(operation == S_OK)

using namespace Microsoft::VisualStudio::CppUnitTestFramework;
const char* USERNAME_EDIT = "Username/Email";
const char* PASSWORD_EDIT = "Password";
const char* LOGIN_ERROR_POPUP = "LoginError";

const char* FIRST_NAME_EDIT = "First Name";
const char* LAST_NAME_EDIT = "Last Name";
const char* COMPANY_EDIT = "Company";
const char* TITLE_EDIT = "Title (Optional)";
const char* EMAIL_EDIT = "Email";
const char* PASSWORD_EDIT = "Password";
const char* CONFIRM_PASSWORD_EDIT = "Confirm Password";

namespace GuiTestCpp
{
	TEST_CLASS(GuiTestCpp)
	{
	public:
		StrataUI ui = new StrataUI(true);
		TEST_METHOD(InvalidLoginTest)
		{
			ASSERT_S_OK(ui.SetToTab("Login"));
			Assert::IsTrue(ui.OnLoginScreen());
			ASSERT_S_OK(ui.SetEditText(USERNAME_EDIT, "badusername"));
			ASSERT_S_OK(ui.SetEditText(PASSWORD_EDIT, "badpassword"));
			ASSERT_S_OK(ui.PressLoginButton());

			Sleep(500);

			Assert::IsTrue(ui.ErrorPopupExists("LoginError"));

			//Cleanup
			ASSERT_S_OK(ui.SetEditText(USERNAME_EDIT, ""));
			ASSERT_S_OK(ui.SetEditText(PASSWORD_EDIT, ""));

		}
		TEST_METHOD(InvalidRegisterTest)
		{
			ASSERT_S_OK(ui.SetToTab("Register"));
			Assert::IsTrue(ui.OnRegisterScreen());
			
			ASSERT_S_OK(ui.SetEditText(FIRST_NAME_EDIT, "Testy"));
			ASSERT_S_OK(ui.SetEditText(LAST_NAME_EDIT, "McTest"));
			ASSERT_S_OK(ui.SetEditText(COMPANY_EDIT, "ON Semiconductor"));
			ASSERT_S_OK(ui.SetEditText(TITLE_EDIT, "Senior QA"));
			ASSERT_S_OK(ui.SetEditText(EMAIL_EDIT, "test@test.com"));
			ASSERT_S_OK(ui.SetEditText(PASSWORD_EDIT, "Strata12345"));
			ASSERT_S_OK(ui.SetEditText(CONFIRM_PASSWORD_EDIT, "Strata12345"));
			ASSERT_S_OK(ui.PressConfirmCheckbox());

			ASSERT_S_OK(ui.PressRegisterButton());

			Sleep(500);

			

		}
	};

}
