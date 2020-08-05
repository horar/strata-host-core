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

echo "======================================================================="
echo " Preparing environment.."
echo "======================================================================="
echo Setting up environment for Qt usage..
set PATH=C:\dev\Qt\5.12.6\msvc2017_64\bin;%PATH%

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

set BUILD_DIR=build-ota
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
set STRATA_DEPLOYMENT_DIR=..\..\deployment\Strata
set STRATA_RESOURCES_DIR=..\resources\qtifw
set STRATA_CONFIG_XML=%STRATA_RESOURCES_DIR%\config\config.xml
set MQTT_DLL=Qt5Mqtt.dll
set MQTT_DLL_DIR=bin\%MQTT_DLL%
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
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version
echo "-----------------------------------------------------------------------------"

echo " Checking QtIFW binarycreator..."
where binarycreator >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo "QtIFW's binarycreator found"
) ELSE (
    echo "QtIFW's binarycreator is missing from path! Aborting."
    Exit /B 1
)

echo " Checking QtIFW repogen..."
where repogen >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo "QtIFW's repogen found"
) ELSE (
    echo "QtIFW's repogen is missing from path! Aborting."
    Exit /B 1
)

echo " Checking signtool..."
where signtool >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo "signtool found"
) ELSE (
    echo "signtool is missing from path! Aborting."
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
    ..
    
REM    -DAPPS_CORESW=on ^
REM    -DAPPS_CORECOMPONENTS=on ^
REM    -DAPPS_TOOLBOX=off ^
REM    -DAPPS_UTILS=off ^
REM    -DAPPS_VIEWS=on ^
REM    -DBUILD_DONT_CLEAN_EXTERNAL=on ^
REM    -DBUILD_EXAMPLES=off ^
REM    -DBUILD_TESTING=off ^
REM cmake -G "Visual Studio 15 2017 Win64" ^
REM     -T v141 ^
REM     ..\

echo "======================================================================="
echo " Compiling.."
echo "======================================================================="
cmake --build . -- -j %NUMBER_OF_PROCESSORS%
REM cmake --build . --config Debug

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
echo " Copying necessary files.."
echo "======================================================================="

REM copy various license files
xcopy %STRATA_DEPLOYMENT_DIR%\dependencies\strata %PKG_STRATA_DS% /E /Y

REM copy HCS config file (should not we use host\apps\hcs3\files\conf\hcs.config ? and why there are two of them and both in git?)
copy %STRATA_DEPLOYMENT_DIR%\config\hcs\hcs.config %PKG_STRATA_HCS%

REM echo "Copying Qt Core\Components resources to %PKG_STRATA_COMPONENTS%"
REM xcopy bin\component-*.rcc %PKG_STRATA_COMPONENTS% /Y

echo "Copying Qml Views Resources to %PKG_STRATA_COMPONENTS_VIEWS%"
if not exist %PKG_STRATA_COMPONENTS_VIEWS% md %PKG_STRATA_COMPONENTS_VIEWS%
xcopy bin\views-*.rcc %PKG_STRATA_COMPONENTS_VIEWS% /Y

if not exist %MQTT_DLL_DIR% (
    echo "======================================================================="
    echo " Missing %MQTT_DLL%, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

echo "Copying %MQTT_DLL% to main dir"
copy %MQTT_DLL_DIR% %PKG_STRATA_DS%

if not exist %STRATA_RESOURCES_DIR%\packages_win (
    echo "======================================================================="
    echo " Missing packages_win folder"
    echo "======================================================================="
    Exit /B 2
)

rd /s /q %PACKAGES_WIN_DIR%
md %PACKAGES_WIN_DIR%
xcopy %STRATA_RESOURCES_DIR%\packages_win %PACKAGES_WIN_DIR% /E

if not exist %STRATA_DEPLOYMENT_DIR%\ftdi_driver_files (
    echo "======================================================================="
    echo " Missing ftdi_driver_files folder"
    echo "======================================================================="
    Exit /B 2
)

xcopy %STRATA_DEPLOYMENT_DIR%\ftdi_driver_files %PKG_STRATA_FTDI%\StrataUtils\FTDI /E

REM -------------------------------------------------------------------------
REM [LC] WIP
REM -------------------------------------------------------------------------
REM    --no-compiler-runtime ^ // we need vc_redist exe

echo "-----------------------------------------------------------------------------"
echo " Preparing %SDS_BINARY% dependencies.."
echo "-----------------------------------------------------------------------------"

windeployqt "%SDS_BINARY_DIR%" ^
    --release ^
    --force ^
    --no-translations ^
    --no-webkit2 ^
    --no-opengl-sw ^
    --no-angle ^
    --no-system-d3d-compiler ^
    --qmldir ..\apps\DeveloperStudio ^
    --qmldir ..\components ^
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

move %PKG_STRATA_QT%\%VCREDIST_BINARY% %PKG_STRATA_VC_REDIST%\StrataUtils\VC_REDIST\

echo "======================================================================="
echo " Signing Binaries.."
echo "======================================================================="

set SIGNING_CERT=%STRATA_DEPLOYMENT_DIR%\sign\code_signing.p12
set SIGNING_PASS="P@ssw0rd!"

echo "Cert: %SIGNING_CERT%"

echo "-----------------------------------------------------------------------------"
echo "Signing %SDS_BINARY%"
echo "-----------------------------------------------------------------------------"

signtool sign -f "%SIGNING_CERT%" -p %SIGNING_PASS% "%SDS_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign %SDS_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "-----------------------------------------------------------------------------"
echo "Signing %HCS_BINARY%"
echo "-----------------------------------------------------------------------------"

signtool sign -f "%SIGNING_CERT%" -p %SIGNING_PASS% "%HCS_BINARY_DIR%"
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
    -f "%SIGNING_CERT%" ^
    -p %SIGNING_PASS% ^
    %STRATA_OFFLINE_BINARY%
	
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign the offline installer %STRATA_OFFLINE_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)
	
echo "======================================================================="
echo " Preparing online installer %STRATA_ONLINE_BINARY%.."
echo "======================================================================="

binarycreator ^
    --verbose ^
    --online-only ^
    -c %STRATA_CONFIG_XML% ^
    -p %PACKAGES_DIR% ^
    -p %PACKAGES_WIN_DIR% ^
    %STRATA_ONLINE%

IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to create online installer %STRATA_ONLINE_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

echo "-----------------------------------------------------------------------------"
echo "Signing the online installer %STRATA_ONLINE_BINARY%"
echo "-----------------------------------------------------------------------------"
signtool sign ^
    -f "%SIGNING_CERT%" ^
    -p %SIGNING_PASS% ^
    %STRATA_ONLINE_BINARY%
	
IF %ERRORLEVEL% NEQ 0 (
    echo "======================================================================="
    echo " Failed to sign the online installer %STRATA_ONLINE_BINARY%!"
    echo "======================================================================="
    Exit /B 3
)

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
	
echo "======================================================================="
echo " OTA build finished"
echo "======================================================================="

endlocal
