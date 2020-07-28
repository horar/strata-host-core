/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the FOO module of the Qt Toolkit.
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
****************************************************************************/


function Component()
{
    installer.installationFinished.connect(this, Component.prototype.installationFinished);
    installer.finishButtonClicked.connect(this, Component.prototype.finishButtonClicked);

    if (installer.isInstaller())
        component.loaded.connect(this, Component.prototype.installerLoaded);
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();
    
    component.addOperation("Mkdir", installer.value("StartMenuDir"));
                    
    var strata_mt_shortcut_dst = installer.value("StartMenuDir") + "\\Strata Maintenance Tool.lnk";
    var strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";
    var strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";

    component.addOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Maintenance Tool.exe", strata_mt_shortcut_dst,
                            "workingDirectory=" + installer.value("TargetDir"), "iconPath=%SystemRoot%/system32/SHELL32.dll",
                            "iconId=2", "description=Open Maintenance Tool");
                            
    component.addOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                            "workingDirectory=" + installer.value("TargetDir"), "description=Open Strata Developer Studio");

    component.addOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                            "workingDirectory=" + installer.value("TargetDir"), "description=Open Strata Developer Studio");
                            
    if(installer.isInstaller())
        uninstallPreviousStrataInstallation();
}

function isRestartRequired()
{
    var vc_redist_temp_file = installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt";
    if(installer.fileExists(vc_redist_temp_file)) {
        var exit_code = installer.readFile(vc_redist_temp_file, "UTF-8");
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
        installer.performOperation("Delete", vc_redist_temp_file);
        
        if(exit_code == "3010 ") {
            installer.setValue("restart_is_required", "true");
            return true;
        }

        installer.setValue("restart_is_required", "false");
        return false;
    } else {
        console.log(vc_redist_temp_file + " not found");
        installer.setValue("restart_is_required", "false");
        return false;
    }
}

Component.prototype.installationFinished = function()
{
    installer.setValue("RunProgram", installer.value("TargetDir") + "/Strata Developer Studio.exe"); // overwrite the RunProgram in case TargetDir changed (bug in QTIFW)

    if (installer.isInstaller() && (installer.status == QInstaller.Success)) {
        if (systemInfo.productType === "windows") {
            if(installer.value("add_start_menu_shortcut") !== "true") {
                var strata_mt_shortcut_dst = installer.value("StartMenuDir") + "\\Strata Maintenance Tool.lnk";
                var strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";

                installer.performOperation("Delete", strata_mt_shortcut_dst);
                installer.performOperation("Delete", strata_ds_shortcut_dst1);
                installer.performOperation("Rmdir", installer.value("StartMenuDir"));
            }
            if(installer.value("add_desktop_shortcut") !== "true") {
                var strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";

                installer.performOperation("Delete", strata_ds_shortcut_dst2);
            }
        }

        isRestartRequired();
    }
}

Component.prototype.finishButtonClicked = function()
{
    if ((installer.value("restart_is_required") ==  "true") && (installer.value("isSilent_internal") !== "true")) {
        console.log("showing restart question to user");
        // Print a message for Windows users to tell them to restart the host machine, immediately or later
        var restart_reply = QMessageBox.question("restart.question", "Installer", "Your computer needs to restart to complete your software installation. Do you wish to restart Now?", QMessageBox.Yes | QMessageBox.No);

        // User has selected 'yes' to restart
        if(restart_reply == QMessageBox.Yes) {
            var widget = gui.currentPageWidget();
            if (widget != null)
                widget.RunItCheckBox.setChecked(false);

            console.log("User reply to restart computer: Yes, restarting computer (with 5 second delay)");
            installer.executeDetached("powershell", "shutdown /r /t 5", "");
        } else {
            console.log("User reply to restart computer: No");
        }
    } else
        console.log("restart not required, terminating");
}

Component.prototype.installerLoaded = function () {
    try {
        if (installer.addWizardPage( component, "ShortcutCheckBoxWidget", QInstaller.StartMenuSelection )) {
            console.log("ShortcutCheckBoxWidget page added");
            var widget = gui.pageWidgetByObjectName("DynamicShortcutCheckBoxWidget");
            if (widget != null) {
                widget.desktopCheckBox.toggled.connect(this, Component.prototype.desktopShortcutChanged);
                widget.startMenuCheckBox.toggled.connect(this, Component.prototype.startMenuShortcutChanged);
            }
        } else
            console.log("ShortcutCheckBoxWidget page not added");
    } catch(e) {
        console.log(e);
    }
}

Component.prototype.desktopShortcutChanged = function (checked)
{
    console.log("desktopShortcutChanged to : " + checked);
    if (checked)
        installer.setValue("add_desktop_shortcut", "true");
    else
        installer.setValue("add_desktop_shortcut", "false");
}

Component.prototype.startMenuShortcutChanged = function (checked)
{
    console.log("startMenuShortcutChanged to : " + checked);
    if (checked) {
        installer.setValue("add_start_menu_shortcut", "true");
        installer.setValue("StartMenuDir", "ON Semiconductor");
        installer.setDefaultPageVisible(QInstaller.StartMenuSelection, true);
    } else {
        installer.setValue("add_start_menu_shortcut", "false");
        installer.setValue("StartMenuDir", "");
        installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
    }
}

// Return 1 if a > b
// Return -1 if a < b
// Return 0 if a == b
function compare(a, b) {
    if (a === b) {
       return 0;
    }

    var a_components = a.split(".");
    var b_components = b.split(".");

    var len = Math.min(a_components.length, b_components.length);

    // loop while the components are equal
    for (var i = 0; i < len; i++) {
        // A bigger than B
        if (parseInt(a_components[i]) > parseInt(b_components[i])) {
            return 1;
        }

        // B bigger than A
        if (parseInt(a_components[i]) < parseInt(b_components[i])) {
            return -1;
        }
    }

    // If one's a prefix of the other, the longer one is greater.
    if (a_components.length > b_components.length) {
        return 1;
    }

    if (a_components.length < b_components.length) {
        return -1;
    }

    // Otherwise they are the same.
    return 0;
}

function getPowershellElement(str, element_name) {
    var res = [];
    var x = str.split('\r\n');
    for(var i = 0; i < x.length; i++){
        var n = x[i].indexOf(element_name);
        if(n == 0) {
            var m = x[i].indexOf(": ", n + element_name.length);
            res.push(x[i].slice(m + ": ".length));
        }
    }
    return res;
}

function uninstallPreviousStrataInstallation()
{
    powerShellCommand = "(Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -eq '" + installer.value("Name") + "' })"

    console.log("executing powershell command '" + powerShellCommand + "'");
    // the installer is 32bit application :/ it will not find 64bit registry entries unless it is forced to open 64bit binary
    var isInstalled = installer.execute("C:\\Windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe", ["-command", powerShellCommand]);
    
    // the output of command is the first item, and the return code is the second
    // console.log("execution result code: " + isInstalled[1] + ", result: '" + isInstalled[0] + "'");
    
    if((isInstalled[0] != null) && (isInstalled[0] != undefined) && (isInstalled[0] != "")) {
        var up_to_date = false;
        
        var display_name = getPowershellElement(isInstalled[0], 'DisplayName');
        var display_version = getPowershellElement(isInstalled[0], 'DisplayVersion');
        var uninstall_string = getPowershellElement(isInstalled[0], 'UninstallString');
        
        console.log("found DisplayName: '" + display_name + "', DisplayVersion: '" + display_version + "', UninstallString: '" + uninstall_string + "'");

        // we should not find multiple entries here, but just in case, check the highest
        if ((display_name.length != 0) && (display_name.length == display_version.length && display_name.length == uninstall_string.length)) {
            var perform_uninstall = installer.value("isSilent_internal") == "true";
            if(perform_uninstall == false) {
                var uninstall_reply = QMessageBox.question("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected. Do you wish to uninstall?", QMessageBox.Yes | QMessageBox.No);

                // User has selected 'yes' to uninstall
                if(uninstall_reply == QMessageBox.Yes) {
                    perform_uninstall = true;
                    console.log("User reply to uninstall Strata: Yes");
                } else {
                    console.log("User reply to uninstall Strata: No");
                }
            }
            if(perform_uninstall) {
                for (var i = 0; i < display_version.length; i++) {
					console.log("executing Strata uninstall command: '" + uninstall_string[i] + "'");
					var e = installer.execute(uninstall_string[i], ["forceUninstall=true", "isSilent=true"]);
					console.log(e);
                }
            }
        }

        return up_to_date;
    } else {
        console.log("program not found, will install new version");
        return false;
    }
}
