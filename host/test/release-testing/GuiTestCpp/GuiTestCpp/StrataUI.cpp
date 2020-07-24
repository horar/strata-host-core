#pragma once
#include "pch.h"
#include <UIAutomation.h>
#include <comdef.h>
typedef bool (*ElementCheck)(IUIAutomationElement*);
//TODO: add a signal thing to make the awaitelement thing work
//class AwaitElementStructureChangedHandler : IUIAutomationStructureChangedEventHandler {
//public:
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
//private:
//    ElementCheck correctElement;
//};
/// <summary>
/// Wrapper class around UIA for accessing Strata UI elements. 
/// This class was designed such that a user does not have to directly use UIA to manipulate the UI (not that there can't be public functions that do so). 
/// This is because the UIA api tends to be verbose and requires heavy knowledge of UIA-specific constants and structures, and it is hard to find a "simple" set of examples of how to use all of them.
/// This also makes it easier to port this class to other languages (e.g. python) later.
/// 
/// Try to expose string inputs as char* and convert internalliy.
/// </summary>
class StrataUI {
public:
    /// <summary>
    /// Init StrataUI. 
    /// </summary>
    /// <param name="initWindow">If true, try to find the Strata window. The window should be found before attempting to do any other UI action.</param>
    /// <returns></returns>
    StrataUI(bool initWindow) {
        this->initializeUIAutomation(&automation);
        if (initWindow) {
            FindStrataWindow();
        }
    }

    /// <summary>
    /// Find the Strata window. NOTE: Window should be found before doing other UI tasks.
    /// </summary>
    /// <returns></returns>
    HRESULT FindStrataWindow() {
        IUIAutomationElement* root;
        automation->GetRootElement(&root);

        IUIAutomationCondition* condition = createPropertyCondition(UIA_NamePropertyId, WINDOW_NAME);

        return root->FindFirst(TreeScope_Children, condition, &window);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnLoginScreen() {
        return buttonEditHeuristic("Login", 2, 2);
    }
    /// <summary>
    /// 
    /// </summary>
    /// <returns>true if on the login screen, false otherwise</returns>
    bool OnRegisterScreen() {
        return buttonEditHeuristic("Register", 2, 7);
    }
    /// <summary>
    /// 
    /// </summary>
    /// <returns>true if on platform view, false otherwise</returns>
    bool OnPlatformViewScreen() {

        IUIAutomationElement* userIcon;
        return GetUserIcon(&userIcon) == S_OK && userIcon != nullptr;
    }

    HRESULT SetToTab(char* name) {
        IUIAutomationElement* tab;

        HRESULT result = FindTab(name, &tab);
        if (result == S_OK) {
            PressButton(tab);
        }
        return result;
    }

    HRESULT FindTab(char* name, IUIAutomationElement** tab) {
        IUIAutomationElement* pane;
        getPane(&pane);


        IUIAutomationCondition* checkboxOrButton;
        automation->CreateOrCondition(
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_CheckBoxControlTypeId)),
            &checkboxOrButton
        );

        IUIAutomationCondition* controlTypeAndName;
        automation->CreateAndCondition(
            createPropertyCondition(UIA_NamePropertyId, _variant_t(name)),
            checkboxOrButton,
            &controlTypeAndName
        );
        
        return pane->FindFirst(TreeScope_Descendants, controlTypeAndName, tab);
        
       
    }

    /// <summary>
    /// Set the text of an edit element
    /// </summary>
    /// <param name="editFullDescription">The FullDescription (default text) of the element</param>
    /// <param name="text">Text to input</param>
    /// <returns></returns>
    HRESULT SetEditText(const char* editFullDescription, const char* text) {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElement* edit;
        HRESULT result = findEdit(editFullDescription, pane, &edit);

        if (result == S_OK) {
            IUIAutomationValuePattern* valuePattern;
            edit->GetCurrentPatternAs(UIA_ValuePatternId, __uuidof(IUIAutomationValuePattern), ((void**)&valuePattern));
            return valuePattern->SetValue(_bstr_t(text));
        }
        return result;
    }
    HRESULT PressConfirmCheckbox() {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElement* checkbox;
        findByNameAndType("", UIA_CheckBoxControlTypeId, pane, &checkbox);

        PressButton(checkbox);
    }
    /// <summary>
    /// Find login button and press it.
    /// </summary>
    /// <returns></returns>
    HRESULT PressLoginButton() {
        IUIAutomationElement* loginButton;
        HRESULT result = GetLoginButton(&loginButton);
        if (result == S_OK) {
            return PressButton(loginButton);
        }
        return result;
    }
    HRESULT PressRegisterButton() {
        IUIAutomationElement* loginButton;
        HRESULT result = GetLoginButton(&loginButton);
        if (result == S_OK) {
            return PressButton(loginButton);
        }
        return result;
    }
    /// <summary>
    /// Get the login button element
    /// </summary>
    /// <param name="login"></param>
    /// <returns></returns>
    HRESULT GetLoginButton(IUIAutomationElement** login) {
        IUIAutomationElement* pane;
        getPane(&pane);


        //Login tab button and submit button are differentiable by a difference in their class name (login tab has "QQuickButton" while login submit has "QQuickButton_<numbers>" 
        //Not sure how stable this is as the register buttons do not have this. Might want to differentiate by position if this becomes an issue.
        IUIAutomationCondition* classNameCondition = createPropertyCondition(UIA_ClassNamePropertyId, _variant_t("QQuickButton"));


        IUIAutomationCondition* notClassName;
        automation->CreateNotCondition(classNameCondition, &notClassName);

        IUIAutomationCondition* conditions[] = {
            createPropertyCondition(UIA_NamePropertyId, _variant_t("Login")),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
            notClassName

        };
        IUIAutomationCondition* loginButtonCondition;
        automation->CreateAndConditionFromNativeArray(conditions, 3, &loginButtonCondition);

        return pane->FindFirst(TreeScope_Descendants, loginButtonCondition, login);

    }

    HRESULT GetRegisterButton(IUIAutomationElement** registerSubmitButton) {
        buttonLowestHeuristic("Register", registerSubmitButton);
    }
    
    HRESULT PressRegisterButton() {
        IUIAutomationElement* registerButton;
        GetRegisterButton(&registerButton);

        PressButton(registerButton);
    }

    /// <summary>
    /// Invoke the given button
    /// </summary>
    /// <param name="button"></param>
    /// <returns></returns>
    HRESULT PressButton(IUIAutomationElement* button) {
        IUIAutomationInvokePattern* invokePattern;
        button->GetCurrentPatternAs(UIA_InvokePatternId, __uuidof(IUIAutomationInvokePattern), (void**)&invokePattern);
        return invokePattern->Invoke();

    }
    /// <summary>
    /// Find the button called buttonName and invoke it.
    /// </summary>
    /// <param name="buttonName"></param>
    /// <returns></returns>
    HRESULT PressButton(const char* buttonName) {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElement* button;
        HRESULT result = findByNameAndType(buttonName, UIA_ButtonControlTypeId, pane, &button);

        if (result == S_OK) {
            IUIAutomationInvokePattern* invokePattern;
            button->GetCurrentPatternAs(UIA_InvokePatternId, __uuidof(IUIAutomationInvokePattern), (void**)&invokePattern);
            return invokePattern->Invoke();
        }
        return result;
    }

    /// <summary>
    /// Find the user icon button in the platform view.
    /// </summary>
    /// <param name="userIcon"></param>
    /// <returns></returns>
    HRESULT GetUserIcon(IUIAutomationElement** userIcon) {
        IUIAutomationElement* pane;
        getPane(&pane);


        return findByNameAndType("User Icon", UIA_ButtonControlTypeId, pane, userIcon);
    }

   
    bool ErrorPopupExists(const char* name) {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElement* element;

        return findByNameAndType(name, UIA_CustomControlTypeId, pane, &element) == S_OK && element != nullptr;

    }
private:
    IUIAutomation* automation;
    IUIAutomationElement* window;

    const _variant_t WINDOW_NAME = "ON Semiconductor: Strata Developer Studio";
    HRESULT buttonLowestHeuristic(const char* buttonName, IUIAutomationElement** lowestButton) {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationCondition* nameAndType;
        automation->CreateAndCondition(
            createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName)),
            createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_ButtonControlTypeId)),
            &nameAndType
        );

        IUIAutomationElementArray* buttons;
        pane->FindAll(TreeScope_Descendants, nameAndType, &buttons);
          
        
        int len;
        buttons->get_Length(&len);
        if (len == 0) {
            *lowestButton = nullptr;
            return S_OK;
        }

        //Find lowest button
        else {
            int lowestValue = MAXINT32;
            IUIAutomationElement* currentLowest;
            IUIAutomationElement* button;

            buttons->GetElement(0, &currentLowest);
            for (int i = 1; i < len; i++) {
                buttons->GetElement(i, &button);

                _variant_t rect;
                button->GetCurrentPropertyValue(UIA_BoundingRectanglePropertyId, &rect);
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
    bool buttonEditHeuristic(const char* buttonName, int numButtons, int numEdits) {
        IUIAutomationElement* pane;
        getPane(&pane);

        IUIAutomationElementArray* buttons;
        pane->FindAll(TreeScope_Descendants, createPropertyCondition(UIA_NamePropertyId, _variant_t(buttonName)), &buttons);

        IUIAutomationElementArray* edits;
        pane->FindAll(TreeScope_Descendants, createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_EditControlTypeId)), &edits);

        int buttonsLen;
        buttons->get_Length(&buttonsLen);

        int editsLen;
        buttons->get_Length(&editsLen);

        return buttonsLen == numButtons && editsLen == numEdits;

    }
    HRESULT findEdit(const char* fullDescription, IUIAutomationElement* pane, IUIAutomationElement** element) {
        IUIAutomationAndCondition* andCondition;
        automation->CreateAndCondition(createPropertyCondition(UIA_FullDescriptionPropertyId, _variant_t(fullDescription)), createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_EditControlTypeId)), (IUIAutomationCondition**)&andCondition);
        return pane->FindFirst(TreeScope_Descendants, andCondition, element);

    }
    HRESULT findByNameAndType(const char* name, CONTROLTYPEID typeId, IUIAutomationElement* pane, IUIAutomationElement** element) {

        IUIAutomationAndCondition* andCondition;
        automation->CreateAndCondition(createPropertyCondition(UIA_NamePropertyId, _variant_t(name)), createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(typeId)), (IUIAutomationCondition**)&andCondition);
        return pane->FindFirst(TreeScope_Descendants, andCondition, element);

    }
    IUIAutomationCondition* createPropertyCondition(PROPERTYID property, VARIANT value) {
        IUIAutomationPropertyCondition* condition;
        
        automation->CreatePropertyCondition(property, value, (IUIAutomationCondition**)&condition);
        return (IUIAutomationCondition*)condition;
    }

    HRESULT getPane(IUIAutomationElement** element) {
        return window->FindFirst(TreeScope_Children, createPropertyCondition(UIA_ControlTypePropertyId, _variant_t(UIA_PaneControlTypeId)), element);
    }

    HRESULT initializeUIAutomation(IUIAutomation** ppAutomation)
    {
        return CoCreateInstance(CLSID_CUIAutomation, NULL,
            CLSCTX_INPROC_SERVER, IID_IUIAutomation,
            reinterpret_cast<void**>(ppAutomation));
    }


};