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
			if(installer.value("add_start_menu_shortcut") == "true") {
				var strata_mt_shortcut_dst = installer.value("StartMenuDir") + "\\Strata Maintenance Tool.lnk";
				var strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";

				installer.performOperation("Delete", strata_mt_shortcut_dst);
				installer.performOperation("Delete", strata_ds_shortcut_dst1);
				installer.performOperation("Rmdir", installer.value("StartMenuDir"));
			}
			if(installer.value("add_desktop_shortcut") == "true") {
				var strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";

				installer.performOperation("Delete", strata_ds_shortcut_dst2);
			}
        }

        isRestartRequired();
    }
}

Component.prototype.finishButtonClicked = function()
{
    if ((installer.value("restart_is_required") ==  "true") && (installer.value('isSilent') !== "true")) {
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
        console.log("restart not required");
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
