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
    installer.installationFinished.connect(this, Component.prototype.installationFinishedPageIsShown);

    if (installer.isInstaller())
        component.loaded.connect(this, Component.prototype.installerLoaded);
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();
}

function isRestartRequired()
{
    if(installer.fileExists(installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt")) {
        var exit_code = installer.readFile(installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt", "UTF-8");
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
        installer.performOperation("Delete", installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt");
        
        if(exit_code == "0 ")
            return true;

        return false;
    } else {
        console.log(installer.value("TargetDir") + "/StrataUtils/VC_REDIST/vc_redist_out.txt not found");
        return false;
    }
}

Component.prototype.installationFinishedPageIsShown = function()
{
    installer.setValue("RunProgram", installer.value("TargetDir") + "/Strata Developer Studio.exe"); // overwrite the RunProgram in case TargetDir changed (bug in QTIFW)

    if (installer.isInstaller() && (installer.status == QInstaller.Success)) {
        if (systemInfo.productType === "windows") {
            if(installer.value("add_start_menu_shortcut") == "true") {
                installer.performOperation("Mkdir", installer.value("StartMenuDir"));
                console.log("creating start menu directory: " + installer.value("StartMenuDir"));
                installer.performOperation("CreateShortcut", installer.value("TargetDir") + "/maintenancetool.exe", installer.value("StartMenuDir") + "/MaintenanceTool.lnk",
                    "workingDirectory=" + installer.value("TargetDir"), "iconPath=%SystemRoot%/system32/SHELL32.dll",
                    "iconId=2", "description=Open Maintenance Tool");
                console.log("creating start menu shortcut, from: " + installer.value("TargetDir") + "/maintenancetool.exe, to: " + installer.value("StartMenuDir") + "/MaintenanceTool.lnk");
            }
            if(installer.value("add_desktop_shortcut") == "true") {
                installer.performOperation("CreateShortcut", installer.value("TargetDir") + "/Strata Developer Studio.exe", installer.value("DesktopDir") + "/Strata Developer Studio.lnk",
                    "workingDirectory=" + installer.value("TargetDir"), "description=Open Strata Developer Studio");
				console.log("creating desktop shortcut, from: " + installer.value("TargetDir") + "/Strata Developer Studio.exe, to: " + installer.value("StartMenuDir") + "/Strata Developer Studio.lnk");
            }
        }

        if (isRestartRequired() == true) {
            console.log("showing restart question to user");
            // Print a message for Windows users to tell them to restart the host machine, immediately or later
            var restart_reply = QMessageBox.question("restart.question", "Installer", "Your computer needs to restart to complete your software installation. Do you wish to restart Now?", QMessageBox.Yes | QMessageBox.No);

            // User has selected 'yes' to restart
            if(restart_reply == QMessageBox.Yes) {
                console.log("User reply to restart computer: Yes, restarting computer (with 5 second delay)");
                installer.executeDetached("powershell", "shutdown /r /t 5", "");
                gui.clickButton(buttons.FinishButton);
            } else {
                console.log("User reply to restart computer: No");
            }
        } else
            console.log("restart not required");
    }
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

Component.prototype.desktopShortcutChanged = function (checked) {
    console.log("desktopShortcutChanged to : " + checked);
    if (checked)
        installer.setValue("add_desktop_shortcut", "true");
    else
        installer.setValue("add_desktop_shortcut", "false");
}

Component.prototype.startMenuShortcutChanged = function (checked) {
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