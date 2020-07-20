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

echo "-----------------------------------------------------------------------------"
echo " Build env. setup:"
echo "-----------------------------------------------------------------------------"
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version
echo "-----------------------------------------------------------------------------"
echo " Checking QtIFW binarycreator..."
binarycreator --help >nul 2>&1 && (
    echo "QtIFW's binarycreator found"
) || (
    echo "QtIFW's binarycreator is missing from path! Aborting."
    Exit /B 1
)

REM echo " Checking QtIFW repogen..."
REM repogen --help >nul 2>&1 && (
REM     echo "QtIFW's repogen found"
REM ) || (
REM     echo "QtIFW's repogen is missing from path! Aborting."
REM     Exit /B 1
REM )
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
REM rd /s /q build-ota
if not exist build-ota md build-ota

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd build-ota

rd /s /q packages
if not exist packages md packages

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
cmake --build .
REM cmake --build . --config Debug

if not exist "packages\com.onsemi.strata.devstudio\data\Strata Developer Studio.exe" (
    echo "======================================================================="
    echo " Missing Strata Developer Studio.exe, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

if not exist "packages\com.onsemi.strata.hcs\data\hcs.exe" (
    echo "======================================================================="
    echo " Missing hcs.exe, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

REM copy various license files
xcopy ..\..\deployment\Strata\dependencies\strata packages\com.onsemi.strata.devstudio\data /E

REM copy mqtt dll
REM move packages\com.onsemi.strata.qt\data\vc_redist.x64.exe packages_win\com.onsemi.strata.utils.common.vcredist\data\StrataUtils\VC_REDIST\

REM echo "Copying Qt Core\Components resources to packages\com.onsemi.strata.components\data"
REM xcopy bin\component-*.rcc packages\com.onsemi.strata.components\data

echo "Copying Qml Views Resources to packages\com.onsemi.strata.components\data\views"
if not exist packages\com.onsemi.strata.components\data\views md packages\com.onsemi.strata.components\data\views
xcopy bin\views-*.rcc packages\com.onsemi.strata.components\data\views

if not exist "bin\Qt5Mqtt.dll" (
    echo "======================================================================="
    echo " Missing Qt5Mqtt.dll, build probably failed"
    echo "======================================================================="
    Exit /B 2
)

echo "Copying QtMqtt dll to main dir"
copy bin\Qt5Mqtt.dll packages\com.onsemi.strata.devstudio\data

if not exist ..\resources\qtifw\packages_win (
    echo "======================================================================="
    echo " Missing packages_win folder"
    echo "======================================================================="
    Exit /B 2
)

rd /s /q packages_win
md packages_win
xcopy ..\resources\qtifw\packages_win packages_win /E

if not exist ..\..\deployment\Strata\ftdi_driver_files (
    echo "======================================================================="
    echo " Missing ftdi_driver_files folder"
    echo "======================================================================="
    Exit /B 2
)

xcopy ..\..\deployment\Strata\ftdi_driver_files packages_win\com.onsemi.strata.utils.ftdi\data\StrataUtils\FTDI /E

REM -------------------------------------------------------------------------
REM [LC] WIP
REM -------------------------------------------------------------------------
REM    --no-compiler-runtime ^ // we need vc_redist exe
windeployqt "packages\com.onsemi.strata.devstudio\data\Strata Developer Studio.exe" ^
    --release ^
    --force ^
    --no-translations ^
    --no-webkit2 ^
    --no-opengl-sw ^
    --no-angle ^
    --no-system-d3d-compiler ^
    --qmldir ..\apps\DeveloperStudio ^
    --qmldir ..\components ^
    --libdir packages\com.onsemi.strata.qt\data ^
    --plugindir packages\com.onsemi.strata.qt\data\plugins ^
    --verbose 1

windeployqt "packages\com.onsemi.strata.hcs\data\hcs.exe" ^
    --release ^
    --force ^
    --no-translations ^
    --no-webkit2 ^
    --no-opengl-sw ^
    --no-angle ^
    --no-system-d3d-compiler ^
    --libdir packages\com.onsemi.strata.qt\data ^
    --plugindir packages\com.onsemi.strata.qt\data\plugins ^
    --verbose 1

if not exist packages\com.onsemi.strata.qt\data\vc_redist.x64.exe (
    echo "======================================================================="
    echo " Missing vc_redist.x64.exe"
    echo "======================================================================="
    Exit /B 2
)

move packages\com.onsemi.strata.qt\data\vc_redist.x64.exe packages_win\com.onsemi.strata.utils.common.vcredist\data\StrataUtils\VC_REDIST\

binarycreator ^
    --verbose ^
    --offline-only ^
    -c ..\resources\qtifw\config\config.xml ^
    -p .\packages ^
    -p .\packages_win ^
    strata-setup-offline


REM    binarycreator ^
REM        --verbose ^
REM        --online-only ^
REM        -c ..\resources\qtifw\config\config.xml ^
REM        -p .\packages ^
REM     -p .\packages_win ^
REM        strata-setup-online

REM    repogen ^
REM        --update-new-components ^
REM        -p .\packages pub\repository\demo

endlocal
