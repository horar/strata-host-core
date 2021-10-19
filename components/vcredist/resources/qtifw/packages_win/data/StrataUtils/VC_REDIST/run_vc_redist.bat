::=============================================================================
:: Copyright (c) 2018-2021 onsemi.
::
:: All rights reserved. This software and/or documentation is licensed by onsemi under
:: limited terms and conditions. The terms and conditions pertaining to the software and/or
:: documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
:: Terms and Conditions of Sale, Section 8 Software”).
::=============================================================================
rem Move to the directory where is the batch file
cd %~dp0

rem Delete previous output if present
if exist vc_redist_out.txt del vc_redist_out.txt

rem Launch vc_redist.x64.exe /install /quiet /norestart
vc_redist.x64.exe /install /quiet /norestart
set /A error_level=%ERRORLEVEL%

rem Write the return value to a file
echo|set /p=%error_level% > vc_redist_out.txt
exit %error_level%