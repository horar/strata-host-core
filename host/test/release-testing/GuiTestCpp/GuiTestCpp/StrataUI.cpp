#pragma once
#include "pch.h"
#include <UIAutomation.h>
#include <comdef.h>

#define COMBINE1(X, Y) X##Y  // helper macro
#define COMBINE(X, Y) COMBINE1(X, Y)
#define CHECK_OK(statement)                    \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        return COMBINE(hr, __LINE__);          \
    }
#define CHECK_OK_OUTPUT(statement, setNull)    \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        *setNull = nullptr;                    \
        return COMBINE(hr, __LINE__);          \
    }

#define CHECK_OK_BOOL(statement)               \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        return false;                          \
    }
const LPCWSTR WINDOW_NAME = L"ON Semiconductor: Strata Developer Studio";

typedef bool (*ElementCheck)(IUIAutomationElement*);
// TODO: add a signal thing to make the awaitelement thing work
// class AwaitElementStructureChangedHandler : IUIAutomationStructureChangedEventHandler {
// public:
//    AwaitElementStructureChangedHandler(ElementCheck check) {
//        this->correctElement = check;
//    }
//    HRESULT HandleStructureChangedEvent(
//        IUIAutomationElement* sender,
//        StructureChangeType changeType,
//        SAFEARRAY* runtimeId
//    ) {
//        if(correctElement()
//    }
// private:
//    ElementCheck correctElement;
//};
/// <summary>
/// Wrapper class around UIA for accessing Strata UI elements.
/// This class was designed such that a user does not have to directly use UIA to manipulate the UI
/// (not that there can't be public functions that do so).
///
/// Expose string inputs as LPCWSTR
/// </summary>
class StrataUI
{
public:
    /// <summary>
    /// Init StrataUI.
    /// </summary>
    /// <param name="initWindow">If true, try to find the Strata window. The window should be found
    /// before attempting to do any other UI action.</param> <returns></returns>
    StrataUI(bool initWindow)
    {
        this->initializeUIAutomation(&automation);
        if (initWindow) {
            FindStrataWindow();
        }
    }
    StrataUI(HWND windowHandle)
    {
        this->initializeUIAutomation(&automation);
        automation->ElementFromHandle(windowHandle, &window);
    }

    /// <summary>
    /// Find the Strata window. NOTE: Window should be found before doing other UI tasks.
    /// </summary>
    /// <returns></returns>
    HRESULT FindStrataWindow()
    {
        IUIAutomationElement* root;
        CHECK_OK(automation->GetRootElement(&root));

        IUIAutomationCondition* condition =
            createPropertyCondition(UIA_NamePropertyId, _variant_t(WINDOW_NAME));

        return root->FindFirst(TreeScope_Children, condition, &window);
    }
    /// <summary>
    /// Find Strata window from process handle
    /// </summary>
    /// <param name="handle"></param>
    /// <returns></returns>
    HRESULT FindStrataWindow(HANDLE handle)
    {
        return automation->ElementFromHandle(handle, &window);
    }

    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnLoginScreen()
    {
        IUIAutomationElement* pane;
        getPane(&pane);

        return buttonEditHeuristic(pane, L"Login", 2, 2);
    }
    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnRegisterScreen()
    {
        IUIAutomationElement* pane;
        getPane(&pane);

        return buttonEditHeuristic(pane, L"Register", 2, 7);
    }
    /// <summary>
    ///
    /// </summary>
    /// <returns>true if on platform view, false otherwise</returns>
    bool OnPlatformViewScreen()
    {
        IUIAutomationElement* userIcon;
        return GetUserIcon(&userIcon) == S_OK && userIcon != nullptr;
    }

    /// <summary>
    /// Set ui to a given tab on the login/register page.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    HRESULT SetToTab(LPCWSTR name)
    {
        IUIAutomationElement* tab;

        HRESULT result = FindTab(name, &tab);
        if (result == S_OK) {
            PressButton(tab);
        }
        return result;
    }

    /// <summary>
    /// Determine if a tab with the given name exists
    /// </summary>
    /// <param name="name"></param>
    /// <param name="tab"></param>
    /// <returns></returns>
    HRESULT FindTab(LPCWSTR name, IUIAutomationElement** tab)
    {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationCondition* checkboxOrButton;
        CHECK_OK_OUTPUT(automation->CreateOrCondition(
                            createPropertyCondition(UIA_ControlTypePropertyId,
                                                    _variant_t(UIA_ButtonControlTypeId)),
                            createPropertyCondition(UIA_ControlTypePropertyId,
                                                    _variant_t(UIA_CheckBoxControlTypeId)),
                            &checkboxOrButton),
                        tab);

        IUIAutomationCondition* controlTypeAndName;
        CHECK_OK_OUTPUT(automation->CreateAndCondition(
                            createPropertyCondition(UIA_NamePropertyId, _variant_t(name)),
                            checkboxOrButton, &controlTypeAndName),
                        tab);

        return pane->FindFirst(TreeScope_Descendants, controlTypeAndName, tab);
    }

    /// <summary>
    /// Set the text of an edit element
    /// </summary>
    /// <param name="editIdentifier">Name or default text of the element</param>
    /// <param name="text">Text to put in edit</param>
    /// <param name="useWindowContext">Look for the edit from the window level instead of the pane
    /// level</param> <param name="findByName">Treat editIdentifier as the name of the edit instead
    /// of the default text.</param> <returns></returns>
    HRESULT SetEditText(const LPCWSTR editIdentifier, const LPCWSTR text,
                        bool useWindowContext = false, bool findByName = false)
    {
        IUIAutomationElement* context;
        if (useWindowContext) {
            context = window;
        } else {
            getPane(&context);
        }

        IUIAutomationElement* edit;
        if (findByName) {
            CHECK_OK(findEditByName(context, editIdentifier, &edit));
        } else {
            CHECK_OK(findEdit(context, editIdentifier, &edit));
        }

        IUIAutomationValuePattern* valuePattern;
        CHECK_OK(edit->GetCurrentPatternAs(UIA_ValuePatternId, __uuidof(IUIAutomationValuePattern),
                                           ((void**)&valuePattern)));
        return valuePattern->SetValue(_bstr_t(text));
    }

    /// <summary>
    /// Click the confirm checkbox on the Register page.
    /// </summary>
    /// <returns></returns>
    HRESULT PressConfirmCheckbox()
    {
        IUIAutomationElement* pane;
        CHECK_OK(getPane(&pane));

        IUIAutomationElement* checkbox;
        CHECK_OK(findByNameAndType(pane, L"", UIA_CheckBoxControlTypeId, &checkbox));

        return PressButton(checkbox);
    }

    /// <summary>
    /// Find login button and press it.
    /// </summary>
    /// <returns></returns>
    HRESULT PressLoginButton()
    {
        IUIAutomationElement* loginButton;
        CHECK_OK(GetLoginButton(&loginButton));
        return PressButton(loginButton);
    }
    /// <summary>
    /// Get the login button element
    /// </summary>
    /// <param name="login"></param>
    /// <returns></returns>
    HRESULT GetLoginButton(IUIAutomationElement** login)
    {
        IUIAutomationElement* pane;
        getPane(&pane);

        // Login tab button and submit button are differentiable by a difference in their class name
        // (login tab has "QQuickButton" while login submit has "QQuickButton_<numbers>" Not sure how
        // stable this is as the register buttons do not have this. Might want to differentiate by
        // position if this becomes an issue.
        IUIAutomationCondition* classNameCondition =
            createPropertyCondition(UIA_ClassNamePropertyId, _variant_t("QQuickButton"));

        IUIAutomationCondition* notClassName;
        CHECK_OK(automation->CreateNotCondition(classNameCondition, &notClassName));

        IUIAutomationCondition* conditions[] = {
            createPropertyCondition(UIA_NamePropertyId, _variant_t("Login")),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
            notClassName

        };
        IUIAutomationCondition* loginButtonCondition;
        CHECK_OK(
            automation->CreateAndConditionFromNativeArray(conditions, 3, &loginButtonCondition));

        return pane->FindFirst(TreeScope_Descendants, loginButtonCondition, login);
    }

    /// <summary>
    /// Determine if the login button is enabled.
    /// </summary>
    /// <returns></returns>
    bool LoginButtonEnabled()
    {
        IUIAutomationElement* loginButton;
        GetLoginButton(&loginButton);

        return ButtonEnabled(loginButton);
    }

    /// <summary>
    /// Locate the register button on the register page.
    /// </summary>
    /// <param name="registerSubmitButton"></param>
    /// <returns></returns>
    HRESULT GetRegisterButton(IUIAutomationElement** registerSubmitButton)
    {
        IUIAutomationElement* pane;
        CHECK_OK(getPane(&pane));
        return buttonLowestHeuristic(pane, L"Register", registerSubmitButton);
    }

    /// <summary>
    /// Click the register button on the register page.
    /// </summary>
    /// <returns></returns>
    HRESULT PressRegisterButton()
    {
        IUIAutomationElement* registerButton;
        CHECK_OK(GetRegisterButton(&registerButton));

        return PressButton(registerButton);
    }

    /// <summary>
    /// Determine if the register button is clicked.
    /// </summary>
    /// <returns></returns>
    bool RegsterButtonEnabled()
    {
        IUIAutomationElement* registerButton;
        GetRegisterButton(&registerButton);

        return ButtonEnabled(registerButton);
    }
    /// <summary>
    /// Invoke the given button
    /// </summary>
    /// <param name="button"></param>
    /// <returns></returns>
    HRESULT PressButton(IUIAutomationElement* button)
    {
        IUIAutomationInvokePattern* invokePattern;
        CHECK_OK(button->GetCurrentPatternAs(
            UIA_InvokePatternId, __uuidof(IUIAutomationInvokePattern), (void**)&invokePattern));
        return invokePattern->Invoke();
    }
    /// <summary>
    /// Find the button called buttonName and invoke it.
    /// </summary>
    /// <param name="buttonName"></param>
    /// <returns></returns>
    HRESULT PressButton(const LPCWSTR buttonName, bool useWindowContext = false)
    {
        IUIAutomationElement* context;
        if (useWindowContext) {
            context = window;
        } else {
            CHECK_OK(getPane(&context));
        }

        IUIAutomationElement* button;
        CHECK_OK(findByNameAndType(context, buttonName, UIA_ButtonControlTypeId, &button));

        return PressButton(button);
    }

    /// <summary>
    /// Determine if the given button is clickable.
    /// </summary>
    /// <param name="button"></param>
    /// <returns></returns>
    bool ButtonEnabled(IUIAutomationElement* button)
    {
        _variant_t enabled;
        button->GetCurrentPropertyValue(UIA_IsEnabledPropertyId, &enabled);

        return enabled.boolVal;
    }

    /// <summary>
    /// Find the button with the given name and determine if it is clickable.
    /// </summary>
    /// <param name="buttonName"></param>
    /// <param name="useWindowContext"></param>
    /// <returns></returns>
    bool ButtonEnabled(const LPCWSTR buttonName, bool useWindowContext = false)
    {
        IUIAutomationElement* context;

        if (useWindowContext) {
            context = window;

        } else {
            getPane(&context);
        }

        IUIAutomationElement* button;
        findByNameAndType(context, buttonName, UIA_ButtonControlTypeId, &button);

        return ButtonEnabled(button);
    }

    /// <summary>
    /// Find the user icon button in the platform view.
    /// </summary>
    /// <param name="userIcon"></param>
    /// <returns></returns>
    HRESULT GetUserIcon(IUIAutomationElement** userIcon)
    {
        return findByNameAndType(window, L"User Icon", UIA_ButtonControlTypeId, userIcon);
    }

    /// <summary>
    /// Determine if the alert with the given name is visible.
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    bool AlertExists(const LPCWSTR name)
    {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElement* element;

        return findByNameAndType(pane, name, UIA_CustomControlTypeId, &element) == S_OK &&
               element != nullptr;
    }

    /// <summary>
    /// Determine if the alert with the given name and text is visible.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="alertText"></param>
    /// <param name="useWindowContext">Look from the strata window instead of the inner
    /// plane</param> <returns></returns>
    bool AlertExists(const LPCWSTR name, const LPCWSTR alertText, bool useWindowContext = false)
    {
        IUIAutomationElement* context;
        if (useWindowContext) {
            context = window;
        } else {
            getPane(&context);
        }

        IUIAutomationCondition* conditions[] = {
            createPropertyCondition(UIA_NamePropertyId, _variant_t(name)),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_CustomControlTypeId)),
            createPropertyCondition(UIA_FullDescriptionPropertyId, _variant_t(alertText))};

        IUIAutomationCondition* existsCondition;
        automation->CreateAndConditionFromNativeArray(conditions, 3, &existsCondition);

        IUIAutomationElement* alert;

        context->FindFirst(TreeScope_Descendants, existsCondition, &alert);

        return alert != nullptr;
    }

    /// <summary>
    /// Determine if the forgot password dialog is open on the login screen.
    /// </summary>
    /// <returns></returns>
    bool OnForgotPassword()
    {
        IUIAutomationElement* forgotPassword;
        CHECK_OK_BOOL(findInnerWindow(&forgotPassword));

        return forgotPassword != nullptr;
    }

    /// <summary>
    /// Determine if the feedback dialog is open on the platform view.
    /// </summary>
    /// <returns></returns>
    bool OnFeedback()
    {
        IUIAutomationElement* feedbackWindow;
        CHECK_OK_BOOL(findInnerWindow(&feedbackWindow));
        return feedbackWindow != nullptr;
    }

    /// <summary>
    /// Determine if the feedback success dialog is open on the platform view.
    /// </summary>
    /// <returns></returns>
    bool OnFeedbackSuccess()
    {
        IUIAutomationElement* feedbackSuccessText;
        CHECK_OK_BOOL(findByNameAndType(window, L"Submit Feedback Success", UIA_TextControlTypeId,
                                        &feedbackSuccessText));

        return feedbackSuccessText != nullptr;
    }

private:
    IUIAutomation* automation;
    IUIAutomationElement* window;

    /// <summary>
    /// Find window inside Strata window
    /// </summary>
    /// <param name="innerWindow"></param>
    /// <returns></returns>
    HRESULT findInnerWindow(IUIAutomationElement** innerWindow)
    {
        return findByNameAndType(window, L"", UIA_WindowControlTypeId, innerWindow);
    }

    /// <summary>
    /// Locate the lowest button with the given name. Useful if there are two identical buttons but the desired one is lower than the other.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="buttonName"></param>
    /// <param name="lowestButton"></param>
    /// <returns></returns>
    HRESULT buttonLowestHeuristic(IUIAutomationElement* pane, const LPCWSTR buttonName,
                                  IUIAutomationElement** lowestButton)
    {
        IUIAutomationCondition* nameAndType;
        CHECK_OK_OUTPUT(automation->CreateAndCondition(
                            createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName)),
                            createPropertyCondition(UIA_ControlTypePropertyId,
                                                    _variant_t(UIA_ButtonControlTypeId)),
                            &nameAndType),
                        lowestButton);

        IUIAutomationElementArray* buttons;
        CHECK_OK_OUTPUT(pane->FindAll(TreeScope_Descendants, nameAndType, &buttons), lowestButton);

        int len;
        CHECK_OK_OUTPUT(buttons->get_Length(&len), lowestButton);
        if (len == 0) {
            *lowestButton = nullptr;
            return S_OK;
        }

        // Find lowest button
        else {
            int lowestValue = MAXINT32;

            IUIAutomationElement* currentLowest;
            buttons->GetElement(0, &currentLowest);

            IUIAutomationElement* button;

            for (int i = 1; i < len; i++) {
                CHECK_OK_OUTPUT(buttons->GetElement(i, &button), 
                    lowestButton);

                _variant_t rect;
                CHECK_OK_OUTPUT(
                    button->GetCurrentPropertyValue(UIA_BoundingRectanglePropertyId, &rect),
                    lowestButton);
                PINT rectValues = (PINT)rect.parray->pvData;

                if (rectValues[0] < lowestValue) {
                    currentLowest = button;
                    lowestValue = rectValues[0];
                }
            }
            *lowestButton = currentLowest;
            return S_OK;
        }
    }

    /// <summary>
    /// Determine if the given pane has a specific number of buttons of the given buttonName and edits.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="buttonName"></param>
    /// <param name="numButtons"></param>
    /// <param name="numEdits"></param>
    /// <returns></returns>
    bool buttonEditHeuristic(IUIAutomationElement* pane, const LPCWSTR buttonName, int numButtons,
                             int numEdits)
    {
        IUIAutomationElementArray* buttons;
        pane->FindAll(TreeScope_Descendants,
                      createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName)),
                      &buttons);

        IUIAutomationElementArray* edits;
        pane->FindAll(
            TreeScope_Descendants,
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_EditControlTypeId)),
            &edits);

        int buttonsLen;
        buttons->get_Length(&buttonsLen);

        int editsLen;
        edits->get_Length(&editsLen);

        return buttonsLen == numButtons && editsLen == numEdits;
    }

    /// <summary>
    /// Locate edit by the given name.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="name"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findEditByName(IUIAutomationElement* pane, const LPCWSTR name,
                           IUIAutomationElement** element)
    {
        return findByNameAndType(pane, name, UIA_EditControlTypeId, element);
    }

    /// <summary>
    /// Locate edit by the given default text.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="fullDescription"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findEdit(IUIAutomationElement* pane, const LPCWSTR fullDescription,
                     IUIAutomationElement** element)
    {
        IUIAutomationAndCondition* andCondition;

        automation->CreateAndCondition(
            createPropertyCondition(UIA_FullDescriptionPropertyId, _variant_t(fullDescription)),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_EditControlTypeId)),
            (IUIAutomationCondition**)&andCondition);

        return pane->FindFirst(TreeScope_Descendants, andCondition, element);
    }

    /// <summary>
    /// Find element by the given name and element type.
    /// </summary>
    /// <param name="pane"></param>
    /// <param name="name"></param>
    /// <param name="typeId"></param>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT findByNameAndType(IUIAutomationElement* pane, const LPCWSTR name, CONTROLTYPEID typeId,
                              IUIAutomationElement** element)
    {
        IUIAutomationAndCondition* andCondition;
        automation->CreateAndCondition(
            createPropertyCondition(UIA_NamePropertyId, _variant_t(name)),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(typeId)),
            (IUIAutomationCondition**)&andCondition);
        return pane->FindFirst(TreeScope_Descendants, andCondition, element);
    }

    /// <summary>
    /// Shorter initialization of a property condition.
    /// </summary>
    /// <param name="property"></param>
    /// <param name="value"></param>
    /// <returns></returns>
    IUIAutomationCondition* createPropertyCondition(PROPERTYID property, VARIANT value)
    {
        IUIAutomationPropertyCondition* condition;

        automation->CreatePropertyCondition(property, value, (IUIAutomationCondition**)&condition);
        return (IUIAutomationCondition*)condition;
    }

    /// <summary>
    /// Get the pane element of the Strata window.
    /// </summary>
    /// <param name="element"></param>
    /// <returns></returns>
    HRESULT getPane(IUIAutomationElement** element)
    {
        return window->FindFirst(
            TreeScope_Children,
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_PaneControlTypeId)),
            element);
    }

    HRESULT initializeUIAutomation(IUIAutomation** ppAutomation)
    {
        return CoCreateInstance(CLSID_CUIAutomation, NULL, CLSCTX_INPROC_SERVER, IID_IUIAutomation,
                                reinterpret_cast<void**>(ppAutomation));
    }
};