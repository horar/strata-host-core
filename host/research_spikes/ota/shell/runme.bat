@echo off
REM
REM Sample build setup script for M$ Windows
REM
REM http://doc.qt.io/qtinstallerframework/ifw-overview.html
REM
REM
REM config file:
REM http://doc.qt.io/qtinstallerframework/ifw-globalconfig.html
REM
REM package:
REM http://doc.qt.io/qtinstallerframework/ifw-component-description.html
REM
REM
REM (c) 2019, Lubomir Carik
REM

echo Entering setup folder...
cd setup

del /F *.exe

echo Generating offline installer...
binarycreator.exe --offline-only -c config\config.xml -p packages sds-setup.exe
echo ...done

echo Generating online installer...
binarycreator.exe --online-only  -c config\config.xml -p packages sds-setup-online.exe
echo ...done

rd /s pub\repository\demo
echo Generating repository, update new components...
repogen.exe --update-new-components -p packages pub/repository/demo
echo ...done

echo Finished...
cd ..
