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