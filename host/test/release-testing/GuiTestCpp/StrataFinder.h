#pragma once
#include <comdef.h>
#include <UIAutomation.h>
#include "StrataUI.h"

class StrataFinder
{
public:
    StrataFinder();
    StrataUI GetWindow();
    StrataUI GetWindow(HWND windowHandle);

private:
    IUIAutomation* automation;

    HRESULT initializeUIAutomation(IUIAutomation** ppAutomation);
};