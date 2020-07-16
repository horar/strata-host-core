/**************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Installer Framework.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
**************************************************************************/

function Component()
{
    // only show for windows
    if( systemInfo.productType !== "windows" ) {
        installer.componentByName(component.name).setValue("Virtual", "true");
    }
}

Component.prototype.createOperationsForArchive = function (archive) 
{
    // set the extraction location to be under StrataUtils
    Component.prototype.extractionLocation = installer.value("TargetDir") + "/StrataUtils";

    // Extract the archive into a custom path 
    component.addOperation("Extract", archive, Component.prototype.extractionLocation);
}

Component.prototype.createOperations = function()
{
    // call default implementation
    component.createOperations();

    // Install Microsoft Visual C++ 2017 X64 Additional Runtime
	// TODO: maybe we can check for new version present
    if(Component.prototype.isInstalledWindowsProgram("Windows Driver Package - FTDI CDM Driver Package") == false)  {
        console.log("installing FTDI CDM Drivers...");
        // status code 512 means succefull installaion
        // status code 2 means succefull installation with a device plugged in
        component.addElevatedOperation("Execute", "{2,512}", Component.prototype.extractionLocation + "/FTDI/dpinst-amd64.exe", "/S", "/SE", "/F");
    } else {
        console.log("FTDI CDM Drivers already installed");
    }
}

Component.prototype.isInstalledWindowsProgram = function(programName)   {
    // check the registry for the installed program then return true if found, and false otherwise
    powerShellCommand = "(reg query HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall /v DisplayName /s /reg:64 | findstr /c:'" + programName + "') -or "
    powerShellCommand+= "(reg query HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall /v DisplayName /s /reg:32 | findstr /c:'" + programName + "') -or "
    powerShellCommand+= "(reg query HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall /v DisplayName /s | findstr /c:'" + programName + "')"
    isInstalled = installer.execute("powershell", ["-command", powerShellCommand]);
    if(isInstalled[0].includes("True"))    {
        return true;
    }
    else   {
        return false;
    }
}
