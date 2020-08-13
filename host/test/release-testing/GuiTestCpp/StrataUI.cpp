#pragma once
#include "StrataUI.h"
#include <UIAutomation.h>
#include <comdef.h>

#define COMBINE1(X, Y) X##Y  // helper macro
#define COMBINE(X, Y) COMBINE1(X, Y)
#define CHECK_OK(statement)                    \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        printf("%s: failed with %x\n", __FUNCTION__, COMBINE(hr, __LINE__));                                \
        return COMBINE(hr, __LINE__);          \
    }
#define CHECK_OK_OUTPUT(statement, setNull)    \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        printf("%s: failed with %x\n", __FUNCTION__, COMBINE(hr, __LINE__));                                \
        *setNull = nullptr;                    \
        return COMBINE(hr, __LINE__);          \
    }

#define CHECK_OK_BOOL(statement)               \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        printf("%s: failed with %x\n", __FUNCTION__, COMBINE(hr, __LINE__));                                \
        return false;                          \
    }
#define CHECK_OK_NORETURN(statement)           \
    HRESULT COMBINE(hr, __LINE__) = statement; \
    if (FAILED(COMBINE(hr, __LINE__))) {       \
        printf("%s: failed with %x\n", __FUNCTION__, COMBINE(hr, __LINE__));                                \
    }
#define CHECK_NULL(statement) \
    if (statement == nullptr) { \
        printf("%s: is null\n", #statement); \
        throw E_POINTER; \
    }

#define CHECK_NULL_BOOL(statement)                \
    if (statement == nullptr) {              \
        printf("%s: is null\n", #statement); \
        throw false;                    \
    }

std::condition_variable cv;
std::mutex m;
bool elementAdded = false;

class EventHandler : public IUIAutomationStructureChangedEventHandler
{
private:
    LONG _refCount;

public:
    // Constructor.
    EventHandler() : _refCount(1)
    {
    }

    // IUnknown methods.
    ULONG STDMETHODCALLTYPE AddRef()
    {
        ULONG ret = InterlockedIncrement(&_refCount);
        return ret;
    }

    ULONG STDMETHODCALLTYPE Release()
    {
        ULONG ret = InterlockedDecrement(&_refCount);
        if (ret == 0) {
            delete this;
            return 0;
        }
        return ret;
    }

    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** ppInterface)
    {
        if (riid == __uuidof(IUnknown))
            *ppInterface = static_cast<IUIAutomationStructureChangedEventHandler*>(this);
        else if (riid == __uuidof(IUIAutomationStructureChangedEventHandler))
            *ppInterface = static_cast<IUIAutomationStructureChangedEventHandler*>(this);
        else {
            *ppInterface = NULL;
            return E_NOINTERFACE;
        }
        this->AddRef();
        return S_OK;
    }

    // IUIAutomationStructureChangedEventHandler methods
    HRESULT STDMETHODCALLTYPE HandleStructureChangedEvent(IUIAutomationElement* pSender,
                                                          StructureChangeType changeType,
                                                          SAFEARRAY* pRuntimeID)
    {
        if (changeType == StructureChangeType_ChildAdded) {
            std::unique_lock<std::mutex> lk(m);
            elementAdded = true;
            lk.unlock();
        }

        return S_OK;
    }
};
/// <summary>
/// Wrapper class around UIA for accessing Strata UI elements.
/// This class was designed such that a user does not have to directly use UIA to manipulate the UI
/// (not that there can't be public functions that do so).
///
/// Expose string inputs as wstring. wstring allows for easy interfacing with Python.
/// </summary>
/// <summary>
/// Init StrataUI.
/// </summary>
/// <param name="initWindow">If true, try to find the Strata window. The window should be found
/// before attempting to do any other UI action.</param> <returns></returns>
StrataUI::StrataUI(IUIAutomationElement* window, IUIAutomation* automation)
{
    this->window = window;
    this->automation = automation;
}
//StrataUI::StrataUI(HWND windowHandle)
//{
//    CHECK_OK_NORETURN(this->initializeUIAutomation(&automation));
//    automation->ElementFromHandle(windowHandle, &window);
//}

/// <summary>
/// Find the Strata window. NOTE: Window should be found before doing other UI tasks.
/// </summary>
/// <returns></returns>
//HRESULT StrataUI::FindStrataWindow()
//{
//    CHECK_NULL(automation)
//
//    IUIAutomationElement* root;
//    CHECK_OK(automation->GetRootElement(&root));
//
//    CHECK_NULL(root);
//
//    IUIAutomationCondition* condition =
//        createPropertyCondition(UIA_NamePropertyId, _variant_t(WINDOW_NAME.c_str()));
//
//    return root->FindFirst(TreeScope_Children, condition, &window);
//}
/// <summary>
/// Find Strata window from process handle
/// </summary>
/// <param name="handle"></param>
/// <returns></returns>
//HRESULT StrataUI::FindStrataWindow(HANDLE handle)
//{
//    CHECK_NULL(automation);
//    return automation->ElementFromHandle(handle, &window);
//}

/// <summary>
///
/// </summary>
/// <returns>true if on the login screen, false otherwise</returns>
bool StrataUI::OnLoginScreen()
{

    return buttonEditHeuristic(window, L"Login", 2, 2);
}
/// <summary>
///
/// </summary>
/// <returns>true if on the login screen, false otherwise</returns>
bool StrataUI::OnRegisterScreen()
{

    return buttonEditHeuristic(window, L"Register", 2, 7);
}
/// <summary>
///
/// </summary>
/// <returns>true if on platform view, false otherwise</returns>
bool StrataUI::OnPlatformViewScreen()
{
    IUIAutomationElement* userIcon;
    return GetUserIcon(&userIcon) == S_OK && userIcon != nullptr;
}

/// <summary>
/// Set ui to a given tab on the login/register page.
/// </summary>
/// <param name="name"></param>
/// <returns></returns>
HRESULT StrataUI::SetToTab(std::wstring name)
{
    IUIAutomationElement* tab;

    HRESULT result = FindTab(name, &tab);
    CHECK_NULL(tab);
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
HRESULT StrataUI::FindTab(std::wstring name, IUIAutomationElement** tab)
{
    IUIAutomationCondition* checkboxOrButton;
    CHECK_OK_OUTPUT(
        automation->CreateOrCondition(
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
            createPropertyCondition(UIA_ControlTypePropertyId,
                                    _variant_t(UIA_CheckBoxControlTypeId)),
            &checkboxOrButton),
        tab);

    IUIAutomationCondition* controlTypeAndName;
    CHECK_OK_OUTPUT(automation->CreateAndCondition(
                        createPropertyCondition(UIA_NamePropertyId, _variant_t(name.c_str())),
                        checkboxOrButton, &controlTypeAndName),
                    tab);

    return window->FindFirst(TreeScope_Descendants, controlTypeAndName, tab);
}

/// <summary>
/// Set the text of an edit element
/// </summary>
/// <param name="editIdentifier">Name or default text of the element</param>
/// <param name="text">Text to put in edit</param>
/// <param name="useWindowContext">Look for the edit from the window level instead of the pane
/// level</param> <param name="findByName">Treat editIdentifier as the name of the edit instead
/// of the default text.</param> <returns></returns>
HRESULT StrataUI::SetEditText(std::wstring editIdentifier, std::wstring text,
                              bool findByName)
{   

    IUIAutomationElement* edit;
    if (findByName) {
        CHECK_OK(findEditByName(window, editIdentifier, &edit));
    } else {
        CHECK_OK(findEdit(window, editIdentifier, &edit));
    }

    IUIAutomationValuePattern* valuePattern;
    CHECK_OK(edit->GetCurrentPatternAs(UIA_ValuePatternId, __uuidof(IUIAutomationValuePattern),
                                       ((void**)&valuePattern)));
    return valuePattern->SetValue(_bstr_t(text.c_str()));
}

/// <summary>
/// Click the confirm checkbox on the Register page.
/// </summary>
/// <returns></returns>
HRESULT StrataUI::PressConfirmCheckbox()
{

    IUIAutomationElement* checkbox;
    CHECK_OK(findByNameAndType(window, L"", UIA_CheckBoxControlTypeId, &checkbox));

    return PressButton(checkbox);
}

/// <summary>
/// Find login button and press it.
/// </summary>
/// <returns></returns>
HRESULT StrataUI::PressLoginButton()
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
HRESULT StrataUI::GetLoginButton(IUIAutomationElement** login)
{

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
    CHECK_OK(automation->CreateAndConditionFromNativeArray(conditions, 3, &loginButtonCondition));

    return window->FindFirst(TreeScope_Descendants, loginButtonCondition, login);
}

/// <summary>
/// Determine if the login button is enabled.
/// </summary>
/// <returns></returns>
bool StrataUI::LoginButtonEnabled()
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
HRESULT StrataUI::GetRegisterButton(IUIAutomationElement** registerSubmitButton)
{

    return buttonLowestHeuristic(window, L"Register", registerSubmitButton);
}

/// <summary>
/// Click the register button on the register page.
/// </summary>
/// <returns></returns>
HRESULT StrataUI::PressRegisterButton()
{
    IUIAutomationElement* registerButton;
    CHECK_OK(GetRegisterButton(&registerButton));

    CHECK_NULL(registerButton);

    return PressButton(registerButton);
}

/// <summary>
/// Determine if the register button is clicked.
/// </summary>
/// <returns></returns>
bool StrataUI::RegsterButtonEnabled()
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
HRESULT StrataUI::PressButton(IUIAutomationElement* button)
{
    CHECK_NULL(button);
    IUIAutomationInvokePattern* invokePattern;
    CHECK_OK(button->GetCurrentPatternAs(UIA_InvokePatternId, __uuidof(IUIAutomationInvokePattern),
                                         (void**)&invokePattern));
    return invokePattern->Invoke();
}
/// <summary>
/// Find the button called buttonName and invoke it.
/// </summary>
/// <param name="buttonName"></param>
/// <returns></returns>
HRESULT StrataUI::PressButton(std::wstring buttonName)
{    
    IUIAutomationElement* button;
    CHECK_OK(findByNameAndType(window, buttonName, UIA_ButtonControlTypeId, &button));

    return PressButton(button);
}

int StrataUI::ConnectedPlatforms()
{
    CHECK_NULL(window);
    IUIAutomationElementArray* elements;
    findAllByNameAndType(window, L"Open Platform Controls", UIA_ButtonControlTypeId, &elements);

    int len;
    elements->get_Length(&len);

    return len;
}

/// <summary>
/// Determine if the given button is clickable.
/// </summary>
/// <param name="button"></param>
/// <returns></returns>
bool StrataUI::ButtonEnabled(IUIAutomationElement* button)
{
    CHECK_NULL_BOOL(button);

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
bool StrataUI::ButtonEnabled(std::wstring buttonName)
{

    IUIAutomationElement* button;
    findByNameAndType(window, buttonName, UIA_ButtonControlTypeId, &button);

    return ButtonEnabled(button);
}

/// <summary>
/// Find the user icon button in the platform view.
/// </summary>
/// <param name="userIcon"></param>
/// <returns></returns>
HRESULT StrataUI::GetUserIcon(IUIAutomationElement** userIcon)
{
    return findByNameAndType(window, L"User Icon", UIA_ButtonControlTypeId, userIcon);
}

/// <summary>
/// Determine if the alert with the given name is visible.
/// </summary>
/// <param name="name"></param>
/// <returns></returns>
bool StrataUI::AlertExists(std::wstring name)
{
    IUIAutomationElement* element;

    return findByNameAndType(window, name, UIA_CustomControlTypeId, &element) == S_OK &&
           element != nullptr;
}

/// <summary>
/// Determine if the alert with the given name and text is visible.
/// </summary>
/// <param name="name"></param>
/// <param name="alertText"></param>
/// <param name="useWindowContext">Look from the strata window instead of the inner
/// plane</param> <returns></returns>
bool StrataUI::AlertExists(std::wstring name, std::wstring alertText)
{
    IUIAutomationElement* context;
    context = window;
   
    IUIAutomationCondition* conditions[] = {
        createPropertyCondition(UIA_NamePropertyId, _variant_t(name.c_str())),
        createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_CustomControlTypeId)),
        createPropertyCondition(UIA_FullDescriptionPropertyId, _variant_t(alertText.c_str()))};

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
bool StrataUI::OnForgotPassword()
{
    IUIAutomationElement* forgotPassword;
    CHECK_OK_BOOL(findInnerWindow(&forgotPassword));

    return forgotPassword != nullptr;
}

/// <summary>
/// Determine if the feedback dialog is open on the platform view.
/// </summary>
/// <returns></returns>
bool StrataUI::OnFeedback()
{
    IUIAutomationElement* feedbackWindow;
    CHECK_OK_BOOL(findInnerWindow(&feedbackWindow));
    return feedbackWindow != nullptr;
}

/// <summary>
/// Determine if the feedback success dialog is open on the platform view.
/// </summary>
/// <returns></returns>
bool StrataUI::OnFeedbackSuccess()
{
    IUIAutomationElement* feedbackSuccessText;
    CHECK_OK_BOOL(findByNameAndType(window, L"Submit Feedback Success", UIA_TextControlTypeId,
                                    &feedbackSuccessText));

    return feedbackSuccessText != nullptr;
}

void StrataUI::AwaitElement()
{
    EventHandler* handler = new EventHandler();
    automation->AddStructureChangedEventHandler(
        window, TreeScope_Descendants, NULL, (IUIAutomationStructureChangedEventHandler*)handler);
    {
        std::unique_lock<std::mutex> lck(m);
        cv.wait(lck, [] { return elementAdded; });
        elementAdded = false;
    }
    automation->RemoveStructureChangedEventHandler(
        window, (IUIAutomationStructureChangedEventHandler*)handler);
}

/// <summary>
/// Find window inside Strata window
/// </summary>
/// <param name="innerWindow"></param>
/// <returns></returns>
HRESULT StrataUI::findInnerWindow(IUIAutomationElement** innerWindow)
{
    CHECK_NULL(window);
    return findByNameAndType(window, L"", UIA_WindowControlTypeId, innerWindow);
}

/// <summary>
/// Locate the lowest button with the given name. Useful if there are two identical buttons but the
/// desired one is lower than the other.
/// </summary>
/// <param name="pane"></param>
/// <param name="buttonName"></param>
/// <param name="lowestButton"></param>
/// <returns></returns>
HRESULT StrataUI::buttonLowestHeuristic(IUIAutomationElement* pane, std::wstring buttonName,
                                        IUIAutomationElement** lowestButton)
{
    CHECK_NULL(automation);
    
    IUIAutomationCondition* nameAndType;
    CHECK_OK_OUTPUT(
        automation->CreateAndCondition(
            createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName.c_str())),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
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
            CHECK_OK_OUTPUT(buttons->GetElement(i, &button), lowestButton);

            _variant_t rect;
            CHECK_OK_OUTPUT(button->GetCurrentPropertyValue(UIA_BoundingRectanglePropertyId, &rect),
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
bool StrataUI::buttonEditHeuristic(IUIAutomationElement* pane, std::wstring buttonName,
                                   int numButtons, int numEdits)
{
    IUIAutomationElementArray* buttons;
    pane->FindAll(TreeScope_Descendants,
                  createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName.c_str())), &buttons);

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
HRESULT StrataUI::findEditByName(IUIAutomationElement* pane, std::wstring name,
                                 IUIAutomationElement** element)
{
    CHECK_NULL(automation);
    return findByNameAndType(pane, name, UIA_EditControlTypeId, element);
}

/// <summary>
/// Locate edit by the given default text.
/// </summary>
/// <param name="pane"></param>
/// <param name="fullDescription"></param>
/// <param name="element"></param>
/// <returns></returns>
HRESULT StrataUI::findEdit(IUIAutomationElement* pane, std::wstring fullDescription,
                           IUIAutomationElement** element)
{
    IUIAutomationAndCondition* andCondition;
    CHECK_NULL(automation);

    automation->CreateAndCondition(
        createPropertyCondition(UIA_FullDescriptionPropertyId, _variant_t(fullDescription.c_str())),
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
HRESULT StrataUI::findByNameAndType(IUIAutomationElement* pane, std::wstring name,
                                    CONTROLTYPEID typeId, IUIAutomationElement** element)
{
    CHECK_NULL(automation);

    IUIAutomationAndCondition* andCondition;
    automation->CreateAndCondition(
        createPropertyCondition(UIA_NamePropertyId, _variant_t(name.c_str())),
        createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(typeId)),
        (IUIAutomationCondition**)&andCondition);
    return pane->FindFirst(TreeScope_Descendants, andCondition, element);
}

HRESULT StrataUI::findAllByNameAndType(IUIAutomationElement* pane, std::wstring name,
                                    CONTROLTYPEID typeId, IUIAutomationElementArray** elements)
{
    CHECK_NULL(automation);

    IUIAutomationAndCondition* andCondition;
    automation->CreateAndCondition(
        createPropertyCondition(UIA_NamePropertyId, _variant_t(name.c_str())),
        createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(typeId)),
        (IUIAutomationCondition**)&andCondition);
    return pane->FindAll(TreeScope_Descendants, andCondition, elements);
}


/// <summary>
/// Shorter initialization of a property condition.
/// </summary>
/// <param name="property"></param>
/// <param name="value"></param>
/// <returns></returns>
IUIAutomationCondition* StrataUI::createPropertyCondition(PROPERTYID property, VARIANT value)
{
    IUIAutomationPropertyCondition* condition;

    automation->CreatePropertyCondition(property, value, (IUIAutomationCondition**)&condition);
    return (IUIAutomationCondition*)condition;
}



//HRESULT StrataUI::initializeUIAutomation(IUIAutomation** ppAutomation)
//{
//    return CoCreateInstance(CLSID_CUIAutomation, NULL, CLSCTX_INPROC_SERVER, IID_IUIAutomation,
//                            reinterpret_cast<void**>(ppAutomation));
//}
