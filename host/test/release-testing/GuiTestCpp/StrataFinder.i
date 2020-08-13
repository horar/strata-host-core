%module StrataUI
%{
#include "StrataFinder.h"
#include "StrataUI.h"
%}

%include <windows.i>
%include "StrataFinder.h"
%include "StrataUI.h"


%init %{
  CoInitialize(NULL);
%}

