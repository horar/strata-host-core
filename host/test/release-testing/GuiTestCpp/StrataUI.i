%module StrataUI
%{
#include "StrataFinder.h"
#include "StrataUI.h"
%}

%include <windows.i>
%include "std_wstring.i"
%include "StrataUI.h"
%include "StrataFinder.h"

%init %{
	CoInitialize(NULL);
%}