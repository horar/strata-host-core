#pragma once
#include "CppUnitTest.h"
#include "StrataUI.h"
//#include <curl\curl.h>
#include <iomanip>
#include <comdef.h>
#include <UIAutomation.h>



#define ASSERT_S_OK(operation) Assert::IsTrue(operation == S_OK)

using namespace Microsoft::VisualStudio::CppUnitTestFramework;

const LPCWSTR USERNAME_EDIT = L"Username/Email";
const LPCWSTR PASSWORD_EDIT = L"Password";
const LPCWSTR LOGIN_ERROR_POPUP = L"LoginError";

const LPCWSTR FIRST_NAME_EDIT = L"First Name";
const LPCWSTR LAST_NAME_EDIT = L"Last Name";
const LPCWSTR COMPANY_EDIT = L"Company";
const LPCWSTR TITLE_EDIT = L"Title (Optional)";
const LPCWSTR EMAIL_EDIT = L"Email";
const LPCWSTR REGISTER_PASSWORD_EDIT = L"Password";
const LPCWSTR CONFIRM_PASSWORD_EDIT = L"Confirm Password";

namespace GuiTestCpp
{
/*TEST_CLASS(GuiTestCppNoNetwork)
{
      static void GetSetting(LPCWSTR tag, LPWSTR buffer, int bufferSz)
    {
        WCHAR filenameBuf[MAX_PATH];

        GetFullPathName(L"..\\settings.ini", MAX_PATH, filenameBuf, nullptr);
        GetPrivateProfileString(L"settings", tag, L"", buffer, bufferSz,
                                filenameBuf);
    }
public:
    TEST_CLASS_INITIALIZE(InitFirewall)
    {

        BSTR bstrRuleName = SysAllocString(L"TEMP_Block_Strata");
        BSTR bstrRuleApplication = SysAllocString(L"%programfiles%\\MyApplication.exe");
        BSTR bstrRuleLPorts = SysAllocString(L"4000");

    }
};*/

TEST_CLASS(GuiTestCpp)
{
public:
    /// <summary>
    /// Access setting in settings.ini
    /// </summary>
    /// <param name="tag"></param>
    /// <param name="buffer"></param>
    /// <param name="bufferSz"></param>
    static void GetSetting(LPCWSTR tag, LPWSTR buffer, int bufferSz)
    {
        WCHAR filenameBuf[MAX_PATH];

        GetFullPathNameW(L"..\\settings.ini", MAX_PATH, filenameBuf, nullptr);
        GetPrivateProfileStringW(L"settings", tag, L"", buffer, bufferSz, filenameBuf);
    }
    // static void CloseUser()
    //{
    //    WCHAR strataIniPath[MAX_PATH];

    //    GetSetting(L"strataIniPath", strataIniPath, MAX_PATH);

    //    WCHAR token[256];
    //    GetPrivateProfileString(L"Login", L"token", L"", token, 256, nullptr);

    //    WCHAR user[256];
    //    GetPrivateProfileString(L"Login", L"user", L"", user, 256, nullptr);

    //    WCHAR authServer[256];
    //    GetPrivateProfileString(L"Login", L"authServer", L"", authServer, 256, nullptr);

    //    if (wcslen(token) != 0 && wcslen(user) != 0 && wcslen(authServer) != 0) {
    //        char errbuf[CURL_ERROR_SIZE] = {
    //            0,
    //        };

    //        CURL* curl;
    //        curl = curl_easy_init();

    //        struct curl_slist* headers = NULL;

    //        if (curl) {
    //            curl_easy_setopt(curl, CURLOPT_URL, (char*)_bstr_t(authServer));

    //            curl_slist_append(headers, "Content-Type:application/json");
    //            curl_slist_append(headers, _bstr_t(lstrcatW(L"x-access-token:", token)));
    //

    //            curl_easy_setopt(curl, CURLOPT_HEADER, headers);

    //            char* json =
    //            _bstr_t(lstrcatW(
    //                lstrcatW(L"{\"username\":", user),
    //                 L"}"
    //            ));

    //            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json);
    //            curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errbuf);
    //
    //            CURLcode res = curl_easy_perform(curl);
    //            curl_slist_free_all(headers);

    //            if (res != CURLE_OK) {
    //                Logger::WriteMessage("Error closing user:");
    //                Logger::WriteMessage(errbuf);
    //            }
    //        }
    //    }
    //    else {
    //        Logger::WriteMessage("Could not find sufficient information to close user account.");
    //    }
    //}
    StrataUI ui = new StrataUI(false);
    TEST_CLASS_INITIALIZE(InitStrata)
    {
        /* In windows, this will init the winsock stuff */
        // curl_global_init(CURL_GLOBAL_ALL);

        STARTUPINFOW si;
        PROCESS_INFORMATION pi;

        // set the size of the structures
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));

        WCHAR openStrata[10];
        GetSetting(L"openStrata", openStrata, 10);

        if (wcscmp(openStrata, L"true") == 0) {
            WCHAR path[MAX_PATH];
            GetSetting(L"strataPath", path, MAX_PATH);

            // start the program up
            CreateProcessW(
                path,   // the path
                NULL,   // Command line
                NULL,   // Process handle not inheritable
                NULL,   // Thread handle not inheritable
                FALSE,  // Set handle inheritance to FALSE
                0,      // No creation flags
                NULL,   // Use parent's environment block
                NULL,   // Use parent's starting directory
                &si,    // Pointer to STARTUPINFO structure
                &pi     // Pointer to PROCESS_INFORMATION structure (removed extra parentheses)
            );
            Sleep(5000);
        }
    }

    //     TEST_METHOD(ValidRegisterTest)
    //     {
    //         ui.FindStrataWindow();
    //         ASSERT_S_OK(ui.SetToTab(L"Register"));
    //         Assert::IsTrue(ui.OnRegisterScreen());

    //         GUID guid;
    //         ASSERT_S_OK(CoCreateGuid(&guid));

    //         std::wstringstream stream;
    //         stream << std::hex << guid.Data1 << L"@" << std::hex << guid.Data2 << ".com";
    //         const LPWSTR username = const_cast<LPWSTR>(stream.str().c_str());
    //
    // ASSERT_S_OK(ui.SetEditText(FIRST_NAME_EDIT, L"New"));
    //         ASSERT_S_OK(ui.SetEditText(LAST_NAME_EDIT, L"User"));
    //         ASSERT_S_OK(ui.SetEditText(COMPANY_EDIT, L"ON Semiconductor"));
    //         ASSERT_S_OK(ui.SetEditText(TITLE_EDIT, L"Senior QA"));
    //         ASSERT_S_OK(ui.SetEditText(EMAIL_EDIT, username));
    //         ASSERT_S_OK(ui.SetEditText(REGISTER_PASSWORD_EDIT, L"Strata12345"));
    //         ASSERT_S_OK(ui.SetEditText(CONFIRM_PASSWORD_EDIT, L"Strata12345"));
    //         ASSERT_S_OK(ui.PressConfirmCheckbox());

    //         Assert::IsTrue(ui.RegsterButtonEnabled());

    //         //ASSERT_S_OK(ui.PressRegisterButton());

    //     }

    /// <summary>
    /// Test logging in with invalid credentials
    /// </summary>
    TEST_METHOD(InvalidLoginTest)
    {
        ui.FindStrataWindow();

        ASSERT_S_OK(ui.SetToTab(L"Login"));
        Assert::IsTrue(ui.OnLoginScreen());
        ASSERT_S_OK(ui.SetEditText(USERNAME_EDIT, L"badusername"));
        ASSERT_S_OK(ui.SetEditText(REGISTER_PASSWORD_EDIT, L"badpassword"));

        Assert::IsTrue(ui.LoginButtonEnabled());

        ASSERT_S_OK(ui.PressLoginButton());
        ui.AwaitElement();

        //Sleep(1000);

        Assert::IsTrue(ui.AlertExists(L"LoginError"));
    }

    /// <summary>
    /// Test registering with an existing user.
    /// </summary>
    TEST_METHOD(InvalidRegisterTest)
    {
        ui.FindStrataWindow();

        ASSERT_S_OK(ui.SetToTab(L"Register"));
        Assert::IsTrue(ui.OnRegisterScreen());

        ASSERT_S_OK(ui.SetEditText(FIRST_NAME_EDIT, L"Testy"));
        ASSERT_S_OK(ui.SetEditText(LAST_NAME_EDIT, L"McTest"));
        ASSERT_S_OK(ui.SetEditText(COMPANY_EDIT, L"ON Semiconductor"));
        ASSERT_S_OK(ui.SetEditText(TITLE_EDIT, L"Senior QA"));
        ASSERT_S_OK(ui.SetEditText(EMAIL_EDIT, L"test@test.com"));
        ASSERT_S_OK(ui.SetEditText(REGISTER_PASSWORD_EDIT, L"Strata12345"));
        ASSERT_S_OK(ui.SetEditText(CONFIRM_PASSWORD_EDIT, L"Strata12345"));
        ASSERT_S_OK(ui.PressConfirmCheckbox());

        Assert::IsTrue(ui.RegsterButtonEnabled());

        ASSERT_S_OK(ui.PressRegisterButton());

        Sleep(500);

        Assert::IsTrue(ui.AlertExists(L"RegisterError"));
    }

    /// <summary>
    /// Test resetting a password with an existant and nonexistant username.
    /// </summary>
    TEST_METHOD(ResetPasswordTest)
    {
        ui.FindStrataWindow();

        // Test nonexistant username
        ASSERT_S_OK(ui.SetToTab(L"Login"));
        Assert::IsTrue(ui.OnLoginScreen());

        ASSERT_S_OK(ui.PressButton(L"Forgot Password"));
        Assert::IsTrue(ui.OnForgotPassword());

        ASSERT_S_OK(ui.SetEditText(L"example@onsemi.com", L"bad@bad.com", true));

        Assert::IsTrue(ui.ButtonEnabled(L"Submit", true));
        ASSERT_S_OK(ui.PressButton(L"Submit", true));

        Sleep(500);

        Assert::IsTrue(
            ui.AlertExists(L"ResetPasswordAlert", L"No user found with email bad@bad.com", true));

        // Test existing username
        ASSERT_S_OK(ui.SetEditText(L"example@onsemi.com", L"test@test.com", true));
        Assert::IsTrue(ui.ButtonEnabled(L"Submit", true));
        ASSERT_S_OK(ui.PressButton(L"Submit", true));

        Sleep(700);

        Assert::IsTrue(ui.AlertExists(
            L"ResetPasswordAlert",
            L"Email with password reset instructions is being sent to test@test.com", true));

        ASSERT_S_OK(ui.PressButton(L"ClosePopup", true));
    }

    /// <summary>
    /// Test sending feedback.
    /// </summary>
    TEST_METHOD(FeedbackTest)
    {
        ui.FindStrataWindow();

        ASSERT_S_OK(ui.SetToTab(L"Login"));
        Assert::IsTrue(ui.OnLoginScreen());

        WCHAR filenameBuf[MAX_PATH];
        WCHAR usernameBuf[100];
        WCHAR passwordBuf[100];
        GetSetting(L"username", usernameBuf, 100);
        GetSetting(L"password", passwordBuf, 100);

        ASSERT_S_OK(ui.SetEditText(USERNAME_EDIT, usernameBuf));
        ASSERT_S_OK(ui.SetEditText(PASSWORD_EDIT, passwordBuf));

        ASSERT_S_OK(ui.PressLoginButton());

        Sleep(700);
        Assert::IsTrue(ui.OnPlatformViewScreen());

        ASSERT_S_OK(ui.PressButton(L"User Icon", true));
        ASSERT_S_OK(ui.PressButton(L"Feedback", true));
        Assert::IsTrue(ui.OnFeedback());

        ASSERT_S_OK(ui.SetEditText(L"FeedbackEdit", L"this is a cool product", true, true));

        Assert::IsTrue(ui.ButtonEnabled(L"Submit", true));
        ASSERT_S_OK(ui.PressButton(L"Submit", true));

        Sleep(500);

        Assert::IsTrue(ui.OnFeedbackSuccess());
        ASSERT_S_OK(ui.PressButton(L"OK", true));

        // Logout
        ASSERT_S_OK(ui.PressButton(L"User Icon", true));
        ASSERT_S_OK(ui.PressButton(L"Log Out", true));

        Assert::IsTrue(ui.OnLoginScreen());
    }
};

}  // namespace GuiTestCpp
