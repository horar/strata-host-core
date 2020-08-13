#pragma once
#include "StrataFinder.h"

LPCWSTR WINDOW_NAME = L"ON Semiconductor: Strata Developer Studio";

StrataFinder::StrataFinder()
{
    initializeUIAutomation(&automation);

}

StrataUI StrataFinder::GetWindow()
{
    IUIAutomationElement* root;
    HRESULT res = automation->GetRootElement(&root);

    IUIAutomationCondition* condition;
    res = automation->CreatePropertyCondition(UIA_NamePropertyId, _variant_t(WINDOW_NAME), &condition);

    IUIAutomationElement* window;
    res = root->FindFirst(TreeScope_Children, condition, &window);

    return StrataUI(window, automation);
}

StrataUI StrataFinder::GetWindow(HWND process)
{
    IUIAutomationElement* window;
    automation->ElementFromHandle(process, &window);
    if (window == nullptr) {
        throw "window could not be found";
    }
    return StrataUI(window, automation);
}

HRESULT StrataFinder::initializeUIAutomation(IUIAutomation** ppAutomation)
{
        return CoCreateInstance(CLSID_CUIAutomation, NULL, CLSCTX_INPROC_SERVER, IID_IUIAutomation,
                                reinterpret_cast<void**>(ppAutomation));
    
}