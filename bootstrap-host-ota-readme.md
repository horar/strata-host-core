## Description

The bootstrap-host-ota.bat (Windows) and bootstrap-host-ota.sh (MacOS) are simple automated build scripts,
that will allow developers to quickly create a Strata OTA installer for the branch they are currently in.

## Environment Setup

A standard development environment for building Strata with "Qt Installer Framework" is required.

The simplest way to set up the basic configuration is to install Hello Strata.
And then install the "Qt Installer Framework" component (version 3.2) through Qt Maintenance Tool.
It also must be added to PATH ( paths could be slightly different):

* Windows:
    * Qt Installer Framework `C:\Qt\Tools\QtInstallerFramework\3.2\bin`
* Mac:
    * Qt Installer Framework `~/Qt/Tools/QtInstallerFramework/3.2/bin`

For a more advanced guide installing the whole enviroment step by step, you can follow the following guide:

* Install Qt by following the installation guides:
    * Windows: https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/601391105/Install+Qt+VS+2017+on+Windows
    * Mac: https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/557252650/Qt+Xcode+install+guide+MacOS
* Install Qt Installer Framework. **Version 3.2**
* Environment variables:
    * Windows:
        * Make sure to have the following in the PATH ( paths could be slightly different):
            1. Qt `C:\Qt\5.12.4\msvc2017_64\bin`
            2. Qt Creator `C:\Qt\Tools\QtCreator\bin`
            3. Qt Installer Framework `C:\Qt\Tools\QtInstallerFramework\3.2\bin`
            4. `signtool` `C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64`
        * Visual Studio Build Tools `VCINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC`
        * Qt `Qt_DIR=C:\Qt\5.12.4\msvc2017_64\lib\cmake\Qt5`
    * Mac:
        * Make sure to have the following in the PATH ( paths could be slightly different):
            1. Qt `~/Qt/5.12.4/clang_64/bin`
            2. Qt Installer Framework `~/Qt/Tools/QtInstallerFramework/3.2/bin`

## Building Strata OTA on Windows / MacOS

To run the script you can use standard terminal present in both OS (Command Prompt - Windows, Terminal - MacOS)

* Windows:
    * `bootstrap-host-ota.bat`
* Mac:
    * `./bootstrap-host-ota.sh`

For usage and other info please run:

* Windows:
    * `bootstrap-host-ota.bat -h`
* Mac:
    * `./bootstrap-host-ota.sh -h`

By default the output folder called `build-host-ota` is located in this folder where scripts are placed.

Once the script starts, you will see the step updates as well as all the output of the commands processed.
It typically takes 10 (MacOS) - 15 (Windows) minutes to get the installer outputted in the build folder.

The output after succesfull build will contain:

* Windows:
    * Offline Installer `strata-setup-offline.exe`
    * Online Installer  `strata-setup-online.exe`
* Mac:
    * Offline Installer `strata-setup-offline.app`
    * Online Installer  `strata-setup-online.app`
* Both:
    * Online Repo       `public/repository/demo/`

The Windows build script will also sign all outputed .exe and .dll files using Window's signtool, so please make sure you have it installed.

## Offline Installer Testing

To test the offline installer, install the generated offline installer on your desired testing machine and test as needed.

## Online Installer Testing

To test the online installer using the generated online installer, first you'll need to deploy a simple http file server.
There you will have to copy content of the generated Online Repo ( for example http://127.0.0.1/strata ).
Once that is done, during the installation, you will have to specify this repository in configuration (Settings - Repositories - Add).
Then you can install on your desired testing machine and test as needed.

## Automate Strata Installation

To install Strata in unattended mode run following command as an administrator to avoid installation permission prompts.

* Windows:
    * `strata-setup-offline.exe install --accept-licenses --confirm-command`
* Mac:
    * `./strata-setup-offline.app/Contents/MacOS/strata-setup-offline install --accept-licenses --confirm-command`

## Additional Strata Arguments

Here are some of the most usefull arguments that can be used with Installer and Maintenance Tool
* `-?, -h, --help`
    * Displays help.
* `-d, --verbose`
    * Verbose mode. Prints out more information.

If Installer application is executed, it will be by default in [GUI] installer mode.
If Maintenance Tool is executed, it will be by default in [GUI] package manager mode.
It is possible to use the following settings to preselect other modes in Maintenance Tool:
* `--su, --start-updater`
    * [GUI] Start Maintenance Tool in updater mode.
* `--sm, --start-package-manager`
    * [GUI] Start Maintenance Tool in package manager mode.
* `--sr, --start-uninstaller`
    * [GUI] Start Maintenance Tool in uninstaller mode.

For unnatended installation, it is necessary to use CLI mode instead of GUI mode:
* `in, install`
    * [CLI] Install the default package set.
* `ch, check-updates`
    * [CLI] Show information about available updates (xml format).
* `up, update`
    * [CLI] Install all available updates.
* `pr, purge`
    * [CLI] Uninstall all packages and remove the program directory.

And it can be combined with automatic accepting of messages / licenses and installation directory (if needed):
* `--accept-messages`
    * [CLI] Accepts all message queries without user input.
* `--accept-licenses`
    * [CLI] Accepts all licenses without user input.
* `--confirm-command`
    * [CLI] Do not ask user to start installation / update / uninstallation.
* `-t, --root <directory>`
    * [CLI] Set the installation root directory.

Note that as of QTIFW 4.0 controller scripts in `installscript.qs` are not executed in [CLI] mode
