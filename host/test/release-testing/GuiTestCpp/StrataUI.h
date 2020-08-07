#pragma once

#include <condition_variable>
#include <mutex>
#include <comdef.h>
#include <UIAutomation.h>



class StrataUI
{
public:
    /// <summary>
    /// Init StrataUI.
    /// </summary>
    /// <param name="initWindow">If true, try to find the Strata window. The window should be found
    /// before attempting to do any other UI action.</param> <returns></returns>
    StrataUI(bool initWindow);
    StrataUI(HWND windowHandle);

    /// <summary>
    /// Find the Strata window. NOTE: Window should be found before doing other UI tasks.
    /// </summary>
    /// <returns></returns>
    HRESULT FindStrataWindow();
    
    /// <summary>
    /// Find Strata window from process handle
    /// </summary>
    /// <param name="handle"></param>
    /// <returns></returns>
    HRESULT FindStrataWindow(HANDLE handle);

    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnLoginScreen();

    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnRegisterScreen();
    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on platform view, false otherwise</returns>
    bool OnPlatformViewScreen();

    /// <summary>
    /// Set ui to a given tab on the login/register page.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    HRESULT SetToTab(LPCWSTR name);

    /// <summary>
    /// Determine if a tab with the given name exists
    /// </summary>
    /// <param name="name"></param>
    /// <param name="tab"></param>
    /// <returns></returns>
    HRESULT FindTab(LPCWSTR name, IUIAutomationElement** tab);

    /// <summary>
    /// Set the text of an edit element
    /// </summary>
    /// <param name="editIdentifier">Name or default text of the element</param>
    /// <param name="text">Text to put in edit</param>
    /// <param name="useWindowContext">Look for the edit from the window level instead of the pane
    /// level</param> <param name="findByName">Treat editIdentifier as the name of the edit instead
    /// of the default text.</param> <returns></returns>
    HRESULT SetEditText(const LPCWSTR editIdentifier, const LPCWSTR text,
                        bool useWindowContext = false, bool findByName = false);

    /// <summary>
    /// Click the confirm checkbox on the Register page.
    /// </summary>
    /// <returns></returns>
    HRESULT PressConfirmCheckbox();

    /// <summary>
    /// Find login button and press it.
    /// </summary>
    /// <returns></returns>
    HRESULT PressLoginButton();
    /// <summary>
    /// Get the login button element
    /// </summary>
    /// <param name="login"></param>
    /// <returns></returns>
    HRESULT GetLoginButton(IUIAutomationElement** login);

    /// <summary>
    /// Determine if the login button is enabled.
    /// </summary>
    /// <returns></returns>
    bool LoginButtonEnabled();

    /// <summary>
    /// Locate the register button on the register page.
    /// </summary>
    /// <param name="registerSubmitButton"></param>
    /// <returns></returns>
    HRESULT GetRegisterButton(IUIAutomationElement** registerSubmitButton);

    /// <summary>
    /// Click the register button on the register page.
    /// </summary>
    /// <returns></returns>
    HRESULT PressRegisterButton();

    /// <summary>
    /// Determine if the register button is clicked.
    /// </summary>
    /// <returns></returns>
    bool RegsterButtonEnabled();

    /// <summary>
    /// Invoke the given button
    /// </summary>
    /// <param name="button"></param>
    /// <returns></returns>
    HRESULT PressButton(IUIAutomationElement* button);

    /// <summary>
    /// Find the button called buttonName and invoke it.
    /// </summary>
    /// <param name="buttonName"></param>
    /// <returns></returns>
    HRESULT PressButton(const LPCWSTR buttonName, bool useWindowContext = false);

    /// <summary>
    /// Determine if the given button is clickable.
    /// </summary>
    /// <param name="button"></param>
    /// <returns></returns>
    bool ButtonEnabled(IUIAutomationElement* button);

    /// <summary>
    /// Find the button with the given name and determine if it is clickable.
    /// </summary>
    /// <param name="buttonName"></param>
    /// <param name="useWindowContext"></param>
    /// <returns></returns>
    bool ButtonEnabled(const LPCWSTR buttonName, bool useWindowContext = false);

    /// <summary>
    /// Find the user icon button in the platform view.
    /// </summary>
    /// <param name="userIcon"></param>
    /// <returns></returns>
    HRESULT GetUserIcon(IUIAutomationElement** userIcon);

    /// <summary>
    /// Determine if the alert with the given name is visible.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    bool AlertExists(const LPCWSTR name);

    /// <summary>
    /// Determine if the alert with the given name and text is visible.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="alertText"></param>
    /// <param name="useWindowContext">Look from the strata window instead of the inner
    /// plane</param> <returns></returns>
    bool AlertExists(const LPCWSTR name, const LPCWSTR alertText, bool useWindowContext = false);

    /// <summary>
    /// Determine if the forgot password dialog is open on the login screen.
    /// </summary>
    /// <returns></returns>
    bool OnForgotPassword();

    /// <summary>
    /// Determine if the feedback dialog is open on the platform view.
    /// </summary>
    /// <returns></returns>
    bool OnFeedback();

    /// <summary>
    /// Determine if the feedback success dialog is open on the platform view.
    /// </summary>
    /// <returns></returns>
    bool OnFeedbackSuccess();

    void AwaitElement();

private:
    IUIAutomation* automation;
    IUIAutomationElement* window;

    /// <summary>
    /// Find window inside Strata window
    /// </summary>
    /// <param name="innerWindow"></param>
    /// <returns></returns>
    HRESULT findInnerWindow(IUIAutomationElement** innerWindow);

    /// <summary>
    /// Locate the lowest button with the given name. Useful if there are two identical buttons but
    /// the desired one is lower than the other.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="buttonName"></param>
    /// <param name="lowestButton"></param>
    /// <returns></returns>
    HRESULT buttonLowestHeuristic(IUIAutomationElement* pane, const LPCWSTR buttonName,
                                  IUIAutomationElement** lowestButton);
    /// <summary>
    /// Determine if the given pane has a specific number of buttons of the given buttonName and
    /// edits.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="buttonName"></param>
    /// <param name="numButtons"></param>
    /// <param name="numEdits"></param>
    /// <returns></returns>
    bool buttonEditHeuristic(IUIAutomationElement* pane, const LPCWSTR buttonName, int numButtons,
                             int numEdits);

    /// <summary>
    /// Locate edit by the given name.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="name"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findEditByName(IUIAutomationElement* pane, const LPCWSTR name,
                           IUIAutomationElement** element);

    /// <summary>
    /// Locate edit by the given default text.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="fullDescription"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findEdit(IUIAutomationElement* pane, const LPCWSTR fullDescription,
                     IUIAutomationElement** element);

    /// <summary>
    /// Find element by the given name and element type.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="name"></param>
    /// <param name="typeId"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findByNameAndType(IUIAutomationElement* pane, const LPCWSTR name, CONTROLTYPEID typeId,
                              IUIAutomationElement** element);

    /// <summary>
    /// Shorter initialization of a property condition.
    /// </summary>
    /// <param name="property"></param>
    /// <param name="value"></param>
    /// <returns></returns>
    IUIAutomationCondition* createPropertyCondition(PROPERTYID property, VARIANT value);
    /// <summary>
    /// Get the pane element of the Strata window.
    /// </summary>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT getPane(IUIAutomationElement** element);

    HRESULT initializeUIAutomation(IUIAutomation** ppAutomation);
};