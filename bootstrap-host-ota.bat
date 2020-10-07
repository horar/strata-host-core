@echo off
REM
REM Simple build script for all 'host' targets
REM
REM Copyright (c) 2019-2020 Lubomir Carik (Lubomir.Carik@onsemi.com)
REM
REM Distributed under the MIT License (MIT) (See accompanying file LICENSE.txt
REM or copy at http://opensource.org/licenses/MIT)
REM

REM Notes:
REM - in PowerShell invoke: "set-executionpolicy remotesigned" and select 'All'
REM

setlocal

REM echo "======================================================================="
REM echo " Parsing arguments.."
REM echo "======================================================================="

set BUILD_ID=1
set BUILD_CLEANUP=0
set BOOTSTRAP_USAGE=0
set "BOOTSTRAP_ARGS_LIST=%*"
call :parse_loop
set BOOTSTRAP_ARGS_LIST=

IF %BOOTSTRAP_USAGE% NEQ 0 ( goto :usage )

echo "======================================================================="
echo " Preparing environment.."
echo "======================================================================="

echo Setting up environment for Qt usage..
set PATH=C:\dev\Qt\5.12.9\msvc2017_64\bin;%PATH%

echo Setting up environment for OpenSSL usage..
set PATH=C:\dev\Qt\Tools\OpenSSL\Win_x64\bin;%PATH%

echo Setting up environment for Qt IFW usage..
set PATH=C:\dev\Qt\Tools\QtInstallerFramework\3.2\bin;%PATH%

echo Setting up environment for 'JOM' usage..
set PATH="C:\dev\Qt\Tools\QtCreator\bin";%PATH%

echo Setting up environment for CMake usage..
set PATH="C:\Program Files\CMake\bin";%PATH%

echo Setting up 'x64 Native Tools Command Prompt for VS 2017'
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
REM call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=amd64

set BUILD_DIR=build-host-ota
set PACKAGES_DIR=packages
set PACKAGES_WIN_DIR=packages_win

set PKG_STRATA=%PACKAGES_DIR%\com.onsemi.strata\data
set PKG_STRATA_COMPONENTS=%PACKAGES_DIR%\com.onsemi.strata.components\data
set PKG_STRATA_COMPONENTS_VIEWS=%PKG_STRATA_COMPONENTS%\views
set PKG_STRATA_DS=%PACKAGES_DIR%\com.onsemi.strata.devstudio\data
set PKG_STRATA_HCS=%PACKAGES_DIR%\com.onsemi.strata.hcs\data
set PKG_STRATA_QT=%PACKAGES_DIR%\com.onsemi.strata.qt\data
set PKG_STRATA_VC_REDIST=%PACKAGES_WIN_DIR%\com.onsemi.strata.utils.common.vcredist\data
set PKG_STRATA_FTDI=%PACKAGES_WIN_DIR%\com.onsemi.strata.utils.ftdi\data

set SDS_BINARY=Strata Developer Studio.exe
set HCS_BINARY=hcs.exe
set SDS_BINARY_DIR=%PKG_STRATA_DS%\%SDS_BINARY%
set HCS_BINARY_DIR=%PKG_STRATA_HCS%\%HCS_BINARY%
set STRATA_DEPLOYMENT_DIR=..\deployment\Strata
set STRATA_RESOURCES_DIR=..\host\resources\qtifw
set STRATA_HCS_CONFIG_DIR=..\host\assets\config\hcs
set STRATA_CONFIG_XML=%STRATA_RESOURCES_DIR%\config\config.xml
set MQTT_DLL=Qt5Mqtt.dll
set MQTT_DLL_DIR=bin\%MQTT_DLL%
set CRYPTO_DLL=libcrypto-1_1-x64.dll
set CRYPTO_DLL_DIR=%OPENSSL_PATH%\%CRYPTO_DLL%
set CRYPTO_DLL_INVALID_DIR=%PKG_STRATA_DS%\%CRYPTO_DLL%
set SSL_DLL=libssl-1_1-x64.dll
set SSL_DLL_DIR=%OPENSSL_PATH%\%SSL_DLL%
set SSL_DLL_INVALID_DIR=%PKG_STRATA_DS%\%SSL_DLL%
set VCREDIST_BINARY=vc_redist.x64.exe
set STRATA_OFFLINE=strata-setup-offline
set STRATA_ONLINE=strata-setup-online
set STRATA_OFFLINE_BINARY=%STRATA_OFFLINE%.exe
set STRATA_ONLINE_BINARY=%STRATA_ONLINE%.exe
set STRATA_ONLINE_REPO_ROOT=pub
set STRATA_ONLINE_REPOSITORY=%STRATA_ONLINE_REPO_ROOT%\repository\demo

echo "-----------------------------------------------------------------------------"
echo " Build env. setup:"
echo "-----------------------------------------------------------------------------"

echo " Checking cmake..."
where cmake >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " cmake is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

cmake --version
echo "-----------------------------------------------------------------------------"

echo " Checking qmake..."
where qmake >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " qmake is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

qmake --version
echo "-----------------------------------------------------------------------------"

echo " Checking jom..."
where jom >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " jom is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

echo " Checking QtIFW binarycreator..."
where binarycreator >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " QtIFW's binarycreator is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

echo " Checking QtIFW repogen..."
where repogen >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " QtIFW's repogen is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

echo " Checking Qt windeployqt..."
where windeployqt >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Qt's windeployqt is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

echo " Checking signtool..."
where signtool >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " signtool is missing from path! Aborting."
    echo "======================================================================="
    Exit /B 1
)

echo " Checking OpenSSL..."
if not exist %OPENSSL_PATH% (
    echo "======================================================================="
    echo " Missing OpenSSL path: '%OPENSSL_PATH%', OpenSSL probably not installed"
    echo "======================================================================="
    Exit /B 1
)

echo "-----------------------------------------------------------------------------"
echo " Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git branch

echo "======================================================================="
echo " Updating Git submodules.."
echo "======================================================================="
echo git submodule update --init --recursive

echo "-----------------------------------------------------------------------------"
echo " Create a build folder.."
echo "-----------------------------------------------------------------------------"

REM in case not called from where is the script located, change working directory
cd %~dp0

REM if exist %BUILD_DIR% rd /s /q %BUILD_DIR%
if not exist %BUILD_DIR% md %BUILD_DIR%

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd %BUILD_DIR%

if exist %PACKAGES_DIR% rd /s /q %PACKAGES_DIR%
if not exist %PACKAGES_DIR% md %PACKAGES_DIR%

cmake -G "NMake Makefiles JOM" ^
    -DCMAKE_BUILD_TYPE=OTA ^
    -DWINDOWS_INSTALLER_BUILD:BOOL=1 ^
    -DAPPS_TOOLBOX=off ^
    -DAPPS_UTILS=off ^
    -DBUILD_TESTING=off ^
    ..\host

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to configure cmake build!"
    echo "======================================================================="
    Exit /B 4
)

echo "======================================================================="
echo " Compiling.."
echo "======================================================================="
cmake --build . -- -j %NUMBER_OF_PROCESSORS%
REM cmake --build . --config Debug

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to perform cmake build!"
    echo "======================================================================="
    Exit /B 5
)

if not exist "%SDS_BINARY_DIR%" (
    echo "======================================================================="
    echo " Missing %SDS_BINARY%, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

if not exist "%HCS_BINARY_DIR%" (
    echo "======================================================================="
    echo " Missing %HCS_BINARY%, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

echo "======================================================================="
echo " Preparing necessary files.."
echo "======================================================================="

REM copy various license files
xcopy %STRATA_DEPLOYMENT_DIR%\dependencies\strata %PKG_STRATA_DS% /E /Y

REM copy HCS config file
copy %STRATA_HCS_CONFIG_DIR%\hcs_prod.config %PKG_STRATA_HCS%\hcs.config

REM echo "Copying Qt Core\Components resources to %PKG_STRATA_COMPONENTS%"
REM xcopy bin\component-*.rcc %PKG_STRATA_COMPONENTS% /Y

echo "Copying Qml Views Resources to %PKG_STRATA_COMPONENTS_VIEWS%"
if not exist %PKG_STRATA_COMPONENTS_VIEWS% md %PKG_STRATA_COMPONENTS_VIEWS%
xcopy bin\views-*.rcc %PKG_STRATA_COMPONENTS_VIEWS% /Y

echo "-----------------------------------------------------------------------------"
echo " Preparing %SDS_BINARY% dependencies.."
echo "-----------------------------------------------------------------------------"

if not exist %STRATA_RESOURCES_DIR%\packages_win (
    echo "======================================================================="
    echo " Missing packages_win folder"
    echo "======================================================================="
    Exit /B 2
)

if exist %PACKAGES_WIN_DIR% rd /s /q %PACKAGES_WIN_DIR%
if not exist %PACKAGES_WIN_DIR% md %PACKAGES_WIN_DIR%
xcopy %STRATA_RESOURCES_DIR%\packages_win %PACKAGES_WIN_DIR% /E

if not exist %STRATA_DEPLOYMENT_DIR%\ftdi_driver_files (
    echo "======================================================================="
    echo " Missing ftdi_driver_files folder"
    echo "======================================================================="
    Exit /B 2
)

xcopy %STRATA_DEPLOYMENT_DIR%\ftdi_driver_files %PKG_STRATA_FTDI%\StrataUtils\FTDI /E

REM call windeployqt first to create necessary folder structure
windeployqt "%SDS_BINARY_DIR%" ^
    --release ^
    --force ^
    --no-translations ^
    --no-webkit2 ^
    --no-opengl-sw ^
    --no-angle ^
    --no-system-d3d-compiler ^
    --qmldir ..\host\apps\DeveloperStudio ^
    --qmldir ..\host\components ^
    --libdir %PKG_STRATA_QT% ^
    --plugindir %PKG_STRATA_QT%\plugins ^
    --verbose 1

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to windeployqt %SDS_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "-----------------------------------------------------------------------------"
echo " Preparing %HCS_BINARY% dependencies.."
echo "-----------------------------------------------------------------------------"

windeployqt "%HCS_BINARY_DIR%" ^
    --release ^
    --force ^
    --no-translations ^
    --no-webkit2 ^
    --no-opengl-sw ^
    --no-angle ^
    --no-system-d3d-compiler ^
    --libdir %PKG_STRATA_QT% ^
    --plugindir %PKG_STRATA_QT%\plugins ^
    --verbose 1

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to windeployqt %HCS_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

if not exist %PKG_STRATA_QT%\%VCREDIST_BINARY% (
    echo "======================================================================="
    echo " Missing %VCREDIST_BINARY%"
    echo "======================================================================="
    Exit /B 2
)

echo "Moving %VCREDIST_BINARY% to %PKG_STRATA_VC_REDIST%\StrataUtils\VC_REDIST"
move "%PKG_STRATA_QT%\%VCREDIST_BINARY%" "%PKG_STRATA_VC_REDIST%\StrataUtils\VC_REDIST\%VCREDIST_BINARY%"

REM Copy OpenSSL dlls to QT5 dir
if exist %CRYPTO_DLL_INVALID_DIR% (
    del %CRYPTO_DLL_INVALID_DIR%
)

if not exist %CRYPTO_DLL_DIR% (
    echo "======================================================================="
    echo " Missing %CRYPTO_DLL_DIR%, OpenSSL probably not installed"
    echo "======================================================================="
    Exit /B 2
)

echo "Moving %CRYPTO_DLL% to %PKG_STRATA_QT%"
copy "%CRYPTO_DLL_DIR%" "%PKG_STRATA_QT%\%CRYPTO_DLL%"

if exist %SSL_DLL_INVALID_DIR% (
    del %SSL_DLL_INVALID_DIR%
)

if not exist "%SSL_DLL_DIR%" (
    echo "======================================================================="
    echo " Missing %SSL_DLL_DIR%, OpenSSL probably not installed"
    echo "======================================================================="
    Exit /B 2
)

echo "Moving %SSL_DLL% to %PKG_STRATA_QT%"
copy "%SSL_DLL_DIR%" "%PKG_STRATA_QT%\%SSL_DLL%"

if not exist %MQTT_DLL_DIR% (
    echo "======================================================================="
    echo " Missing %MQTT_DLL%, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

REM Copy Mqtt dll to QT5 dir
echo "Copying %MQTT_DLL% to %PKG_STRATA_QT%"
copy "%MQTT_DLL_DIR%" "%PKG_STRATA_QT%\%MQTT_DLL%"

echo "======================================================================="
echo " Signing Binaries.."
echo "======================================================================="

set SIGNING_CERT="%STRATA_DEPLOYMENT_DIR%\sign\code_signing.pfx"
set SIGNING_PASS="P@ssw0rd!"
set SIGNING_TIMESTAMP_SERVER="http://rfc3161timestamp.globalsign.com/advanced"
set SIGNING_TIMESTAMP_ALG="SHA256"

echo "Cert: %SIGNING_CERT%"

echo "-----------------------------------------------------------------------------"
echo "Signing %SDS_BINARY%"
echo "-----------------------------------------------------------------------------"

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%SDS_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign %SDS_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "-----------------------------------------------------------------------------"
echo "Signing %HCS_BINARY%"
echo "-----------------------------------------------------------------------------"

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%HCS_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign %HCS_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "======================================================================="
echo " Preparing offline installer %STRATA_OFFLINE_BINARY%.."
echo "======================================================================="

binarycreator ^
    --verbose ^
    --offline-only ^
    -c %STRATA_CONFIG_XML% ^
    -p %PACKAGES_DIR% ^
    -p %PACKAGES_WIN_DIR% ^
    %STRATA_OFFLINE%

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to create offline installer %STRATA_OFFLINE_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "-----------------------------------------------------------------------------"
echo "Signing the offline installer %STRATA_OFFLINE_BINARY%"
echo "-----------------------------------------------------------------------------"
signtool sign ^
    /f %SIGNING_CERT% ^
    /p %SIGNING_PASS% ^
    /tr %SIGNING_TIMESTAMP_SERVER% ^
    /td %SIGNING_TIMESTAMP_ALG% ^
    %STRATA_OFFLINE_BINARY%
    
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign the offline installer %STRATA_OFFLINE_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)
    
REM echo "======================================================================="
REM echo " Preparing online installer %STRATA_ONLINE_BINARY%.."
REM echo "======================================================================="
REM 
REM binarycreator ^
REM     --verbose ^
REM     --online-only ^
REM     -c %STRATA_CONFIG_XML% ^
REM     -p %PACKAGES_DIR% ^
REM     -p %PACKAGES_WIN_DIR% ^
REM     %STRATA_ONLINE%
REM 
REM IF %ERRORLEVEL% NEQ 0 (
REM     echo "======================================================================="
REM     echo " Failed to create online installer %STRATA_ONLINE_BINARY%!"
REM     echo "======================================================================="
REM     Exit /B 3
REM )
REM 
REM echo "-----------------------------------------------------------------------------"
REM echo "Signing the online installer %STRATA_ONLINE_BINARY%"
REM echo "-----------------------------------------------------------------------------"
REM signtool sign ^
REM     /f %SIGNING_CERT% ^
REM     /p %SIGNING_PASS% ^
REM     /tr %SIGNING_TIMESTAMP_SERVER% ^
REM     /td %SIGNING_TIMESTAMP_ALG% ^
REM     %STRATA_ONLINE_BINARY%
REM     
REM IF %ERRORLEVEL% NEQ 0 (
REM     echo "======================================================================="
REM     echo " Failed to sign the online installer %STRATA_ONLINE_BINARY%!"
REM     echo "======================================================================="
REM     Exit /B 3
REM )

echo "======================================================================="
echo " Preparing online repository %STRATA_ONLINE_REPOSITORY%.."
echo "======================================================================="

if exist %STRATA_ONLINE_REPO_ROOT% rd /s /q %STRATA_ONLINE_REPO_ROOT%

repogen ^
    --update-new-components ^
    --verbose ^
    -p %PACKAGES_DIR% ^
    -p %PACKAGES_WIN_DIR% ^
    %STRATA_ONLINE_REPOSITORY%

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to create online repository %STRATA_ONLINE_REPOSITORY%!"
    echo "======================================================================="
    Exit /B 3
)

if %BUILD_CLEANUP% EQU 1 (
    echo "-----------------------------------------------------------------------------"
    echo " Cleaning build directory"
    echo "-----------------------------------------------------------------------------"
    for /F "delims=" %%i in ('dir /b') do (
        if NOT "%%i"=="%STRATA_OFFLINE_BINARY%" if NOT "%%i"=="%STRATA_ONLINE_BINARY%" if NOT "%%i"=="%STRATA_ONLINE_REPO_ROOT%" (
            rmdir "%%i" /s/q || del "%%i" /s/q
        )
    )
)

    
echo "======================================================================="
echo " OTA build finished"
echo "======================================================================="

exit /B 0

:parse_loop
for /F "tokens=1,* delims= " %%a in ("%BOOTSTRAP_ARGS_LIST%") do (
REM    echo "    Inner argument: {%%a}"
    call :parse_argument %%a
    set "BOOTSTRAP_ARGS_LIST=%%b"
    goto :parse_loop
)
exit /B 0

:parse_argument
REM called by :parse_loop and expects the arguments to either be:
REM 1. a single argument in %1
REM 2. an argument pair from the command line specified as '%1=%2'

set __local_ARG_FOUND=
if /I "%1"=="-c" (
    set BUILD_CLEANUP=1
    set __local_ARG_FOUND=1
)
if /I "%1"=="--cleanup" (
    set BUILD_CLEANUP=1
    set __local_ARG_FOUND=1
)
if /I "%1"=="-h" (
    set BOOTSTRAP_USAGE=1
    set __local_ARG_FOUND=1
)
if /I "%1"=="--help" (
    set BOOTSTRAP_USAGE=1
    set __local_ARG_FOUND=1
)
if /I "%1"=="-i" (
    set BUILD_ID=%2
    set __local_ARG_FOUND=1
)
if /I "%1"=="--buildid" (
    set BUILD_ID=%2
    set __local_ARG_FOUND=1
)

if "%__local_ARG_FOUND%" NEQ "1" (
    if "%2"=="" (
        echo " Invalid argument found : %1"
    ) else (
        echo " Invalid argument found : %1=%2"
    )
    set BOOTSTRAP_USAGE=1
)
set __local_ARG_FOUND=
exit /B 0

:usage
echo "Syntax:"
echo "     [-i=BUILD_ID] [-c] [-h]"
echo "Where:"
echo "     [-i | --buildid]: For build id"
echo "     [-c | --cleanup]: To leave only installer"
echo "     [-h | --help]: For this help"
echo "For example:"
echo "     bootstrap-host-ota.bat -i=999 --cleanup"
exit /B 0

endlocal
