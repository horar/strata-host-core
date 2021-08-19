::=============================================================================
:: Copyright (c) 2018-2021 onsemi.
::
:: All rights reserved. This software and/or documentation is licensed by onsemi under
:: limited terms and conditions. The terms and conditions pertaining to the software and/or
:: documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
:: Terms and Conditions of Sale, Section 8 Software”).
::=============================================================================
@echo off
REM
REM Simple build script for all 'host' targets
REM Notes:
REM - in PowerShell invoke: "set-executionpolicy remotesigned" and select 'All'
REM

setlocal

echo "======================================================================="
echo " Preparing environment.."
echo "======================================================================="
echo Setting up environment for Qt usage..
set PATH=C:\dev\Qt\5.12.11\msvc2017_64\bin;%PATH%

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
echo "Build env. setup:"
echo "-----------------------------------------------------------------------------"
cmake --version
echo "-----------------------------------------------------------------------------"
qmake --version

echo "======================================================================="
echo " Preparing sandbox.."
echo "======================================================================="
REM rd /s /q build-host
if not exist build-host md build-host

echo "-----------------------------------------------------------------------------"
echo "Actual/local branch list.."
echo "-----------------------------------------------------------------------------"
git --no-pager branch

echo "======================================================================="
echo " Updating Git submodules.."
echo "======================================================================="
git submodule update --init --recursive

echo "======================================================================="
echo " Generating project.."
echo "======================================================================="
cd build-host
cmake -G "NMake Makefiles JOM" ^
	-DCMAKE_BUILD_TYPE=Debug ^
	..
REM cmake -G "Visual Studio 15 2017 Win64" ^
REM 	-T v141 ^
REM 	..

echo "======================================================================="
echo " Compiling.."
echo "======================================================================="
cmake --build . -- -j %NUMBER_OF_PROCESSORS%
REM cmake --build . --config Debug


endlocal
