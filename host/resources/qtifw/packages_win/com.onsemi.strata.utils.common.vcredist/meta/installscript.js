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
	
	installer.installationFinished.connect(this, Component.prototype.restartRequired);
}

Component.prototype.createOperations = function()
{
    // call default implementation
    component.createOperations();

    // Install Microsoft Visual C++ 2017 X64 Additional Runtime
	// TODO: maybe we can check for new version present
    if(Component.prototype.isInstalledWindowsProgram("Microsoft Visual C++ 2017 X64 Additional Runtime") == false) {
        console.log("installing Microsoft Visual C++ 2017 X64 Additional Runtime libraries...");
        // status code 0 means succefull installaion
        // status code 1638 means VC already exist. Therefore, no need to show warnings.
        // status code 3010 means that the oporation is successful but a restart is required
        //component.addOperation("Execute", "{0,1638,3010}", installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist.x64.exe", "/install", "/quiet", "/norestart");
		component.addElevatedOperation("Execute", "{0,1638,3010}", installer.value("TargetDir") + "/StrataUtils/VC_REDIST/run_vc_redist.bat");
    } else {
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime already installed");
    }
}

Component.prototype.restartRequired = function()
{
	if(installer.fileExists(installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt")) {
		var exit_code = installer.readFile(installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt", "UTF-8");
		console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
		if(exit_code == "3010 ") {
			installer.setValue("restart_required", "true");
			console.log("restart is required");	// TODO
		}
		installer.performOperation("Delete", installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt");
	} else {
		console.log("vc_redist_out.txt not found");
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
