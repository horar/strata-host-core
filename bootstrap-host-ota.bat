@echo off

REM
REM Simple build script for all 'host' targets configured for OTA release (Windows)
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

REM echo =======================================================================
REM echo  Parsing arguments..
REM echo =======================================================================

set BUILD_ID=1
set BUILD_CLEANUP=0
set SKIP_TESTS=0
set USE_PROD_CONFIG=0
set USE_QA_CONFIG=0
set USE_DEV_CONFIG=0
set USE_DOCKER_CONFIG=0
set BOOTSTRAP_USAGE=0
set "BOOTSTRAP_ARGS_LIST=%*"
call :parse_loop
set BOOTSTRAP_ARGS_LIST=

IF %BOOTSTRAP_USAGE% NEQ 0 ( goto :usage )

echo =======================================================================
echo  Preparing environment..
echo =======================================================================

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

set BUILD_DIR=build-host-ota
set PACKAGES_DIR=packages
set PACKAGES_WIN_DIR=packages_win

set STRATA_COMPONENTS=components
set STRATA_DS=devstudio
set STRATA_HCS=hcs
set STRATA_QT=qt
set STRATA_VC_REDIST=vcredist
set STRATA_FTDI=ftdi

set MODULE_STRATA=com.onsemi.strata
set MODULE_STRATA_COMPONENTS=%MODULE_STRATA%.%STRATA_COMPONENTS%
set MODULE_STRATA_DS=%MODULE_STRATA%.%STRATA_DS%
set MODULE_STRATA_HCS=%MODULE_STRATA%.%STRATA_HCS%
set MODULE_STRATA_QT=%MODULE_STRATA%.%STRATA_QT%
set MODULE_STRATA_VC_REDIST=%MODULE_STRATA%.utils.common.%STRATA_VC_REDIST%
set MODULE_STRATA_FTDI=%MODULE_STRATA%.utils.%STRATA_FTDI%

set PKG_STRATA=%PACKAGES_DIR%\%MODULE_STRATA%\data
set PKG_STRATA_COMPONENTS=%PACKAGES_DIR%\%MODULE_STRATA_COMPONENTS%\data
set PKG_STRATA_COMPONENTS_COMMON=%PKG_STRATA_COMPONENTS%\imports\tech\strata\commoncpp
set PKG_STRATA_COMPONENTS_VIEWS=%PKG_STRATA_COMPONENTS%\views
set PKG_STRATA_DS=%PACKAGES_DIR%\%MODULE_STRATA_DS%\data
set PKG_STRATA_HCS=%PACKAGES_DIR%\%MODULE_STRATA_HCS%\data
set PKG_STRATA_QT=%PACKAGES_DIR%\%MODULE_STRATA_QT%\data
set PKG_STRATA_VC_REDIST=%PACKAGES_WIN_DIR%\%MODULE_STRATA_VC_REDIST%\data
set PKG_STRATA_FTDI=%PACKAGES_WIN_DIR%\%MODULE_STRATA_FTDI%\data

set SDS_BINARY=Strata Developer Studio.exe
set HCS_BINARY=hcs.exe
set SDS_BINARY_DIR=%PKG_STRATA_DS%\%SDS_BINARY%
set HCS_BINARY_DIR=%PKG_STRATA_HCS%\%HCS_BINARY%
set STRATA_DEPLOYMENT_DIR=..\deployment\Strata
set STRATA_RESOURCES_DIR=..\host\resources\qtifw
set STRATA_HCS_CONFIG_DIR=..\host\assets\config\hcs

set STRATA_HCS_CONFIG_FILE_PROD=hcs_prod.config
set STRATA_HCS_CONFIG_FILE_QA=hcs_qa.config
set STRATA_HCS_CONFIG_FILE_DEV=hcs_dev.config
set STRATA_HCS_CONFIG_FILE_DOCKER=hcs_docker.config
set STRATA_HCS_CONFIG_FILE=%STRATA_HCS_CONFIG_FILE_QA%

if %USE_PROD_CONFIG% EQU 1 (
    set STRATA_HCS_CONFIG_FILE=%STRATA_HCS_CONFIG_FILE_PROD%
) else if %USE_QA_CONFIG% EQU 1 (
    set STRATA_HCS_CONFIG_FILE=%STRATA_HCS_CONFIG_FILE_QA%
) else if %USE_DEV_CONFIG% EQU 1 (
    set STRATA_HCS_CONFIG_FILE=%STRATA_HCS_CONFIG_FILE_DEV%
) else if %USE_DOCKER_CONFIG% EQU 1 (
    set STRATA_HCS_CONFIG_FILE=%STRATA_HCS_CONFIG_FILE_DOCKER%
)

set STRATA_CONFIG_XML=%STRATA_RESOURCES_DIR%\config\config.xml
set MQTT_DLL=Qt5Mqtt.dll
set MQTT_DLL_DIR=bin\%MQTT_DLL%
set COMMON_CPP_DLL=component-commoncpp.dll
set CRYPTO_DLL=libcrypto-1_1-x64.dll
set CRYPTO_DLL_DIR_SDS=%PKG_STRATA_DS%\%CRYPTO_DLL%
set CRYPTO_DLL_DIR_HCS=%PKG_STRATA_HCS%\%CRYPTO_DLL%
set SSL_DLL=libssl-1_1-x64.dll
set SSL_DLL_DIR_SDS=%PKG_STRATA_DS%\%SSL_DLL%
set SSL_DLL_DIR_HCS=%PKG_STRATA_HCS%\%SSL_DLL%
set ZMQ_DLL=libzmq.dll
set ZMQ_DLL_DIR_SDS=%PKG_STRATA_DS%\%ZMQ_DLL%
set ZMQ_DLL_DIR_HCS=%PKG_STRATA_HCS%\%ZMQ_DLL%
set MSVCR_DLL=MSVCR100.dll
set MSVCR_DLL_DIR=%windir%\system32\%MSVCR_DLL%
set INSTALLERBASE_BINARY=installerbase.exe
set INSTALLERBASE_BINARY_DIR=%PKG_STRATA%\%INSTALLERBASE_BINARY%
set VCREDIST_BINARY=vc_redist.x64.exe
set STRATA_OFFLINE=strata-setup-offline
set STRATA_ONLINE=strata-setup-online
set STRATA_OFFLINE_BINARY=%STRATA_OFFLINE%.exe
set STRATA_ONLINE_BINARY=%STRATA_ONLINE%.exe
set STRATA_ONLINE_REPOSITORY=public\repository\demo

echo -----------------------------------------------------------------------------
echo  Build env. setup:
echo -----------------------------------------------------------------------------

echo  Checking cmake...
where cmake >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  cmake is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

cmake --version
echo -----------------------------------------------------------------------------

echo  Checking qmake...
where qmake >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  qmake is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

qmake --version
echo -----------------------------------------------------------------------------

echo  Checking jom...
where jom >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  jom is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

echo  Checking QtIFW binarycreator...
where binarycreator >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  QtIFW's binarycreator is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

echo  Checking QtIFW repogen...
where repogen >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  QtIFW's repogen is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

echo  Checking QtIFW installerbase...
where installerbase >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  QtIFW's installerbase is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

@for /f "tokens=* usebackq" %%f in (`where installerbase`) do @set "INSTALLERBASE_BINARY_ORIG_DIR=%%f"
echo   Detected location: %INSTALLERBASE_BINARY_ORIG_DIR%

echo  Checking Qt windeployqt...
where windeployqt >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Qt's windeployqt is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

echo  Checking signtool...
where signtool >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  signtool is missing from path! Aborting.
    echo =======================================================================
    Exit /B 1
)

echo -----------------------------------------------------------------------------
echo  Actual/local branch list..
echo -----------------------------------------------------------------------------
git branch

REM in case not called from where is the script located, change working directory
cd %~dp0

if %BUILD_CLEANUP% EQU 1 (
    if exist %BUILD_DIR% (
        echo -----------------------------------------------------------------------------
        echo  Cleaning build directory..
        echo -----------------------------------------------------------------------------
        rd /s /q %BUILD_DIR%
    )
)

echo -----------------------------------------------------------------------------
echo  Create a build folder..
echo -----------------------------------------------------------------------------
if not exist %BUILD_DIR% md %BUILD_DIR%

echo =======================================================================
echo  Generating project..
echo =======================================================================
cd %BUILD_DIR%

if exist %PACKAGES_DIR% rd /s /q %PACKAGES_DIR%
if not exist %PACKAGES_DIR% md %PACKAGES_DIR%

cmake -G "NMake Makefiles JOM" ^
    -DCMAKE_BUILD_TYPE=OTA ^
    -DWINDOWS_INSTALLER_BUILD:BOOL=1 ^
    -DAPPS_CORESW_HCS_CONFIG:STRING=%STRATA_HCS_CONFIG_FILE% ^
    -DAPPS_TOOLBOX=off ^
    -DAPPS_UTILS=off ^
    -DBUILD_TESTING=on ^
    ..\host

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to configure cmake build!
    echo =======================================================================
    Exit /B 4
)

echo =======================================================================
echo  Compiling..
echo =======================================================================
cmake --build . -- -j %NUMBER_OF_PROCESSORS%

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to perform cmake build!
    echo =======================================================================
    Exit /B 5
)

if not exist "%SDS_BINARY_DIR%" (
    echo =======================================================================
    echo  Missing %SDS_BINARY%, build probably failed
    echo =======================================================================
    Exit /B 2
)

if not exist "%HCS_BINARY_DIR%" (
    echo =======================================================================
    echo  Missing %HCS_BINARY%, build probably failed
    echo =======================================================================
    Exit /B 2
)

if %SKIP_TESTS% EQU 0 (
    echo =======================================================================
    echo  Starting Strata unit tests..
    echo =======================================================================

    ctest

    IF %ERRORLEVEL% NEQ 0 (
        echo =======================================================================
        echo  Unit tests failed!
        echo =======================================================================
        Exit /B 6
    )
)

echo =======================================================================
echo  Preparing necessary files..
echo =======================================================================

REM copy various license files
if not exist %PKG_STRATA% md %PKG_STRATA%

xcopy %STRATA_DEPLOYMENT_DIR%\dependencies\strata %PKG_STRATA% /E /Y

REM echo Copying Qt Core\Components resources to %PKG_STRATA_COMPONENTS%
REM xcopy bin\component-*.rcc %PKG_STRATA_COMPONENTS% /Y

echo Copying Qml Views Resources to %PKG_STRATA_COMPONENTS_VIEWS%
if not exist %PKG_STRATA_COMPONENTS_VIEWS% md %PKG_STRATA_COMPONENTS_VIEWS%
xcopy bin\views-*.rcc %PKG_STRATA_COMPONENTS_VIEWS% /Y

echo Copyting %INSTALLERBASE_BINARY_ORIG_DIR% to %INSTALLERBASE_BINARY_DIR%
copy "%INSTALLERBASE_BINARY_ORIG_DIR%" "%INSTALLERBASE_BINARY_DIR%"

echo -----------------------------------------------------------------------------
echo  Preparing %SDS_BINARY% dependencies..
echo -----------------------------------------------------------------------------

if not exist %STRATA_RESOURCES_DIR%\packages_win (
    echo =======================================================================
    echo  Missing packages_win folder
    echo =======================================================================
    Exit /B 2
)

if exist %PACKAGES_WIN_DIR% rd /s /q %PACKAGES_WIN_DIR%
if not exist %PACKAGES_WIN_DIR% md %PACKAGES_WIN_DIR%
xcopy %STRATA_RESOURCES_DIR%\packages_win %PACKAGES_WIN_DIR% /E

if not exist %STRATA_DEPLOYMENT_DIR%\ftdi_driver_files (
    echo =======================================================================
    echo  Missing ftdi_driver_files folder
    echo =======================================================================
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
    --dir %PKG_STRATA_QT%\qml ^
    --libdir %PKG_STRATA_QT% ^
    --plugindir %PKG_STRATA_QT%\plugins ^
    --verbose 1

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to windeployqt %SDS_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Sanitizing QtWebEngine location to %PKG_STRATA_QT%
echo -----------------------------------------------------------------------------

move "%PKG_STRATA_QT%\qml\QtWebEngineProcess.exe" "%PKG_STRATA_QT%"
move "%PKG_STRATA_QT%\qml\translations" "%PKG_STRATA_QT%"
move "%PKG_STRATA_QT%\qml\resources" "%PKG_STRATA_QT%"

echo -----------------------------------------------------------------------------
echo  Preparing %HCS_BINARY% dependencies..
echo -----------------------------------------------------------------------------

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
    echo =======================================================================
    echo  Failed to windeployqt %HCS_BINARY%!
    echo =======================================================================
    Exit /B 3
)

if not exist %PKG_STRATA_QT%\%VCREDIST_BINARY% (
    echo =======================================================================
    echo  Missing %VCREDIST_BINARY%
    echo =======================================================================
    Exit /B 2
)

echo Moving %VCREDIST_BINARY% to %PKG_STRATA_VC_REDIST%\StrataUtils\VC_REDIST
move "%PKG_STRATA_QT%\%VCREDIST_BINARY%" "%PKG_STRATA_VC_REDIST%\StrataUtils\VC_REDIST\%VCREDIST_BINARY%"

REM Copy OpenSSL dlls to QT5 dir
if not exist %CRYPTO_DLL_DIR_SDS% (
    echo =======================================================================
    echo  Missing %CRYPTO_DLL_DIR_SDS%, build probably failed
    echo =======================================================================
    Exit /B 2
)

echo Moving %CRYPTO_DLL% to %PKG_STRATA_QT%
move "%CRYPTO_DLL_DIR_SDS%" "%PKG_STRATA_QT%\%CRYPTO_DLL%"

if exist %CRYPTO_DLL_DIR_HCS% (
    del "%CRYPTO_DLL_DIR_HCS%"
)

if not exist "%SSL_DLL_DIR_SDS%" (
    echo =======================================================================
    echo  Missing %SSL_DLL_DIR_SDS%, build probably failed
    echo =======================================================================
    Exit /B 2
)

echo Moving %SSL_DLL% to %PKG_STRATA_QT%
move "%SSL_DLL_DIR_SDS%" "%PKG_STRATA_QT%\%SSL_DLL%"

if exist %SSL_DLL_DIR_HCS% (
    del "%SSL_DLL_DIR_HCS%"
)

if not exist "%ZMQ_DLL_DIR_SDS%" (
    echo =======================================================================
    echo  Missing %ZMQ_DLL_DIR_SDS%, build probably failed
    echo =======================================================================
    Exit /B 2
)

echo Moving %ZMQ_DLL% to %PKG_STRATA_QT%
move "%ZMQ_DLL_DIR_SDS%" "%PKG_STRATA_QT%\%ZMQ_DLL%"

if exist %ZMQ_DLL_DIR_HCS% (
    del "%ZMQ_DLL_DIR_HCS%"
)

if not exist %MQTT_DLL_DIR% (
    echo =======================================================================
    echo  Missing %MQTT_DLL%, build probably failed
    echo =======================================================================
    Exit /B 2
)

REM Copy Mqtt dll to QT5 dir
echo Copying %MQTT_DLL% to %PKG_STRATA_QT%
copy "%MQTT_DLL_DIR%" "%PKG_STRATA_QT%\%MQTT_DLL%"

if not exist %MSVCR_DLL_DIR% (
    echo =======================================================================
    echo  Missing %MSVCR_DLL%, vcredist 2010 probably not installed
    echo =======================================================================
    Exit /B 2
)

REM Copy Msvrc dll to QT5 dir
echo Copying %MSVCR_DLL% to %PKG_STRATA_QT%
copy "%MSVCR_DLL_DIR%" "%PKG_STRATA_QT%\%MSVCR_DLL%"

echo =======================================================================
echo  Signing Binaries..
echo =======================================================================

set SIGNING_CERT="%STRATA_DEPLOYMENT_DIR%\sign\code_signing.pfx"
set SIGNING_PASS="P@ssw0rd!"
set SIGNING_TIMESTAMP_SERVER="http://rfc3161timestamp.globalsign.com/advanced"
set SIGNING_TIMESTAMP_ALG="SHA256"

echo Cert: %SIGNING_CERT%

echo -----------------------------------------------------------------------------
echo Signing %SDS_BINARY%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%SDS_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %SDS_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %HCS_BINARY%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%HCS_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %HCS_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %CRYPTO_DLL%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%PKG_STRATA_QT%\%CRYPTO_DLL%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %CRYPTO_DLL%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %SSL_DLL%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%PKG_STRATA_QT%\%SSL_DLL%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %SSL_DLL%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %ZMQ_DLL%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%PKG_STRATA_QT%\%ZMQ_DLL%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %ZMQ_DLL%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %MQTT_DLL%
echo -----------------------------------------------------------------------------

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%PKG_STRATA_QT%\%MQTT_DLL%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %MQTT_DLL%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %COMMON_CPP_DLL%
echo -----------------------------------------------------------------------------

if not exist "%PKG_STRATA_COMPONENTS_COMMON%\%COMMON_CPP_DLL%" (
    echo =======================================================================
    echo  Missing %COMMON_CPP_DLL%, build probably failed
    echo =======================================================================
    Exit /B 2
)

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%PKG_STRATA_COMPONENTS_COMMON%\%COMMON_CPP_DLL%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %COMMON_CPP_DLL%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing %INSTALLERBASE_BINARY%
echo -----------------------------------------------------------------------------

if not exist "%INSTALLERBASE_BINARY_DIR%" (
    echo =======================================================================
    echo  Missing %INSTALLERBASE_BINARY%
    echo =======================================================================
    Exit /B 2
)

signtool sign /f %SIGNING_CERT% /p %SIGNING_PASS% /tr %SIGNING_TIMESTAMP_SERVER% /td %SIGNING_TIMESTAMP_ALG% "%INSTALLERBASE_BINARY_DIR%"
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign %INSTALLERBASE_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo =======================================================================
echo  Preparing offline installer %STRATA_OFFLINE_BINARY%..
echo =======================================================================

binarycreator ^
    --verbose ^
    --offline-only ^
    -c %STRATA_CONFIG_XML% ^
    -p %PACKAGES_DIR% ^
    -p %PACKAGES_WIN_DIR% ^
    %STRATA_OFFLINE_BINARY%

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create offline installer %STRATA_OFFLINE_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing the offline installer %STRATA_OFFLINE_BINARY%
echo -----------------------------------------------------------------------------
signtool sign ^
    /f %SIGNING_CERT% ^
    /p %SIGNING_PASS% ^
    /tr %SIGNING_TIMESTAMP_SERVER% ^
    /td %SIGNING_TIMESTAMP_ALG% ^
    %STRATA_OFFLINE_BINARY%

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign the offline installer %STRATA_OFFLINE_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo =======================================================================
echo  Preparing online installer %STRATA_ONLINE_BINARY%..
echo =======================================================================

binarycreator ^
    --verbose ^
    --online-only ^
    -c %STRATA_CONFIG_XML% ^
    -p %PACKAGES_DIR% ^
    -p %PACKAGES_WIN_DIR% ^
    %STRATA_ONLINE_BINARY%

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online installer %STRATA_ONLINE_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo Signing the online installer %STRATA_ONLINE_BINARY%
echo -----------------------------------------------------------------------------
signtool sign ^
    /f %SIGNING_CERT% ^
    /p %SIGNING_PASS% ^
    /tr %SIGNING_TIMESTAMP_SERVER% ^
    /td %SIGNING_TIMESTAMP_ALG% ^
    %STRATA_ONLINE_BINARY%

IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to sign the online installer %STRATA_ONLINE_BINARY%!
    echo =======================================================================
    Exit /B 3
)

echo =======================================================================
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%..
echo =======================================================================

if exist %STRATA_ONLINE_REPOSITORY% rd /s /q %STRATA_ONLINE_REPOSITORY%
if not exist %STRATA_ONLINE_REPOSITORY% md %STRATA_ONLINE_REPOSITORY%

repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA% %STRATA_ONLINE_REPOSITORY%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Updating online repository %STRATA_ONLINE_REPOSITORY%\Updates.xml..
echo -----------------------------------------------------------------------------

if not exist %STRATA_ONLINE_REPOSITORY%\Updates.xml (
    echo =======================================================================
    echo  Missing %STRATA_ONLINE_REPOSITORY%\Updates.xml, repogen probably failed
    echo =======================================================================
    Exit /B 2
)

SetLocal DisableDelayedExpansion
Set "SrcFile=%STRATA_ONLINE_REPOSITORY%\Updates.xml"
Copy /Y "%SrcFile%" "%SrcFile%.bak">Nul 2>&1||Exit /B
(   Set "Line="
    For /F "UseBackQ Delims=" %%A In ("%SrcFile%.bak") Do (
        SetLocal EnableDelayedExpansion
        If Defined Line Echo !Line!
        EndLocal
        Set "Line=%%A"))>"%SrcFile%"
del "%SrcFile%.bak"
EndLocal

(
echo  ^<RepositoryUpdate^>
echo   ^<Repository action="add" url="%STRATA_COMPONENTS%" displayname="Module %MODULE_STRATA_COMPONENTS%"/^>
echo   ^<Repository action="add" url="%STRATA_DS%" displayname="Module %MODULE_STRATA_DS%"/^>
echo   ^<Repository action="add" url="%STRATA_HCS%" displayname="Module %MODULE_STRATA_HCS%"/^>
echo   ^<Repository action="add" url="%STRATA_QT%" displayname="Module %MODULE_STRATA_QT%"/^>
echo   ^<Repository action="add" url="utils_%STRATA_VC_REDIST%" displayname="Module %MODULE_STRATA_VC_REDIST%"/^>
echo   ^<Repository action="add" url="utils_%STRATA_FTDI%" displayname="Module %MODULE_STRATA_FTDI%"/^>
echo  ^</RepositoryUpdate^>
echo ^</Updates^>
)>> %STRATA_ONLINE_REPOSITORY%\Updates.xml

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_COMPONENTS%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_COMPONENTS% %STRATA_ONLINE_REPOSITORY%\%STRATA_COMPONENTS%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_COMPONENTS%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_DS%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_DS% %STRATA_ONLINE_REPOSITORY%\%STRATA_DS%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_DS%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_HCS%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_HCS% %STRATA_ONLINE_REPOSITORY%\%STRATA_HCS%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_HCS%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_QT%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_QT% %STRATA_ONLINE_REPOSITORY%\%STRATA_QT%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\%STRATA_QT%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_VC_REDIST%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_VC_REDIST% %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_VC_REDIST%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_VC_REDIST%!
    echo =======================================================================
    Exit /B 3
)

echo -----------------------------------------------------------------------------
echo  Preparing online repository %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_FTDI%..
echo -----------------------------------------------------------------------------
repogen --verbose -p %PACKAGES_DIR% -p %PACKAGES_WIN_DIR% --include %MODULE_STRATA_FTDI% %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_FTDI%
IF %ERRORLEVEL% NEQ 0 (
    echo =======================================================================
    echo  Failed to create online repository %STRATA_ONLINE_REPOSITORY%\utils_%STRATA_FTDI%!
    echo =======================================================================
    Exit /B 3
)

echo =======================================================================
echo  OTA build finished
echo =======================================================================

exit /B 0

:parse_loop
for /F "tokens=1,* delims= " %%a in ("%BOOTSTRAP_ARGS_LIST%") do (
REM    echo     Inner argument: {%%a}
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
if /I "%1"=="-s" (
    set SKIP_TESTS=1
    set __local_ARG_FOUND=1
)
if /I "%1"=="--skiptests" (
    set SKIP_TESTS=1
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
if /I "%1"=="-f" (
    if "%2"=="PROD" (
        set USE_PROD_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="QA" (
        set USE_QA_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="DEV" (
        set USE_DEV_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="DOCKER" (
        set USE_DOCKER_CONFIG=1
        set __local_ARG_FOUND=1
    )
)
if /I "%1"=="--config" (
    if "%2"=="PROD" (
        set USE_PROD_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="QA" (
        set USE_QA_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="DEV" (
        set USE_DEV_CONFIG=1
        set __local_ARG_FOUND=1
    )
    if "%2"=="DOCKER" (
        set USE_DOCKER_CONFIG=1
    )
)

if "%__local_ARG_FOUND%" NEQ "1" (
    if "%2"=="" (
        echo  Invalid argument found : %1
    ) else (
        echo  Invalid argument found : %1=%2
    )
    set BOOTSTRAP_USAGE=1
)
set __local_ARG_FOUND=
exit /B 0

:usage
echo Syntax:
echo      [-i=^<BUILD_ID^>] [-f=PROD^|QA^|DEV^|DOCKER] [-c] [-s] [-h]
echo Where:
echo      [-i ^| --buildid]: For build id
echo      [-c ^| --cleanup]: To clean build folder before build
echo      [-s ^| --skiptests]: To skip tests after build
echo      [-f ^| --config]: To use selected HCS configuration: PROD^|QA^|DEV^|DOCKER (Default: QA)
echo      [-h ^| --help]: For this help
echo For example:
echo      bootstrap-host-ota.bat -i=999 -f=PROD --cleanup -s
exit /B 0

endlocal
