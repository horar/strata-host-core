var restart_is_required = true;

function Component()
{
    installer.installationFinished.connect(this, Component.prototype.onInstallationOrUpdateFinished);    // called after installation, update and adding/removing components
    installer.installationStarted.connect(this, Component.prototype.onInstallationStarted);

    if(installer.isCommandLineInstance() == false) {
        installer.finishButtonClicked.connect(this, Component.prototype.onFinishButtonClicked);
        if ((installer.isInstaller() == true) && (systemInfo.productType == "windows")) {
            component.loaded.connect(this, Component.prototype.addShortcutWidget);
        }
    }
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();

    if ((systemInfo.productType == "windows") && (installer.value("add_start_menu_shortcut", "true") == "true")) {
        var target_dir = installer.value("TargetDir").split("/").join("\\");
        var strata_mt_shortcut_dst = installer.value("StartMenuDir").split("/").join("\\") + "\\Strata Maintenance Tool.lnk";
        component.addOperation("CreateShortcut", target_dir + "\\Strata Maintenance Tool.exe", strata_mt_shortcut_dst,
                                "workingDirectory=" + target_dir, "description=Open Maintenance Tool");
        console.log("will add Start Menu shortcut to: " + strata_mt_shortcut_dst);
    }

    if (installer.isInstaller() == true) {
        uninstallPreviousStrataInstallation();
    }
}

Component.prototype.onInstallationStarted = function()
{
    if ((component.updateRequested() == true) || (component.installationRequested() == true)) {
        if (systemInfo.productType == "windows") {
            component.installerbaseBinaryPath = installer.value("TargetDir") + "\\installerbase.exe";
            component.installerbaseBinaryPath = component.installerbaseBinaryPath.split("/").join("\\");
            installer.setInstallerBaseBinary(component.installerbaseBinaryPath);
        } else if (systemInfo.productType == "osx") {
            component.installerbaseBinaryPath = installer.value("TargetDir") + "/installerbase";
            installer.setInstallerBaseBinary(component.installerbaseBinaryPath);
        }
    }
}

function isRestartRequired()
{
    var vc_redist_temp_file = installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\VC_REDIST\\vc_redist_out.txt";
    if (installer.fileExists(vc_redist_temp_file) == true) {
        var exit_code = installer.readFile(vc_redist_temp_file, "UTF-8");
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
        installer.performOperation("Delete", vc_redist_temp_file);

        if (exit_code == "3010 ") {
            restart_is_required = true;
            return true;
        }

        restart_is_required = false;
        return false;
    } else {
        restart_is_required = false;
        return false;
    }
}

function isComponentInstalled(component_name)
{
    var component = installer.componentByName(component_name);
    if (component != null) {
        var installed = component.isInstalled();
        console.log("component '" + component_name + "' found and is installed: " + installed);
        return installed;
    }

    console.log("component '" + component_name + "' NOT found");
    return false;
}

Component.prototype.onInstallationOrUpdateFinished = function()
{
    console.log("onInstallationOrUpdateFinished entered");

    if (isComponentInstalled("com.onsemi.strata.devstudio") && ((installer.isInstaller() == true) || (installer.isUpdater() == true) || (installer.isPackageManager() == true))) {
        if (systemInfo.productType == "windows") {
            installer.setValue("RunProgram", installer.value("TargetDir").split("/").join("\\") + "\\Strata Developer Studio.exe");
        } else if (systemInfo.productType == "osx") {
            installer.setValue("RunProgram", installer.value("TargetDir") + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
        } else {
            installer.setValue("RunProgram", "");
        }

        installer.setValue("RunProgramArguments", "");
        installer.setValue("RunProgramDescription", "Launch %1 Developer Studio"); // QTIFW bug, will report warning if we are missing the %1, where the productName() is placed
    } else {
        installer.setValue("RunProgram", "");
        installer.setValue("RunProgramArguments", "");
        installer.setValue("RunProgramDescription", "");
    }

    console.log("RunProgram: " + installer.value("RunProgram"));
    if ((systemInfo.productType == "windows") && ((installer.isInstaller() == true) || (installer.isUpdater() == true) || (installer.isPackageManager() == true)) && (installer.status == QInstaller.Success)) {
        isRestartRequired();
    }

    // erase StrataUtils folder
    var strataUtilsFolder = installer.value("TargetDir") + "\\StrataUtils";
    strataUtilsFolder = strataUtilsFolder.split("/").join("\\");
    if ((systemInfo.productType == "windows") && (installer.fileExists(strataUtilsFolder) == true)) {
        try {
            console.log("erasing StrataUtils folder: " + strataUtilsFolder);
            installer.execute("cmd", ["/c", "rd", "/s", "/q", strataUtilsFolder]);
            if (installer.fileExists(strataUtilsFolder) == true) {
                if (installer.gainAdminRights() == true) {    // needed when it is in Program Files directory on Win10
                    console.log("gained admin rights, executing cmd in admin mode");
                    installer.execute("cmd", ["/c", "rd", "/s", "/q", strataUtilsFolder]);
                    installer.dropAdminRights();
                }
            }
        } catch(e) {
            console.log("unable to erase StrataUtils folder: " + strataUtilsFolder);
            console.log(e);
        }
    }
}

Component.prototype.onFinishButtonClicked = function()
{
    if (restart_is_required == true) {
        console.log("showing restart question to user");
        // Print a message for Windows users to tell them to restart the host machine, immediately or later
        var restart_reply = QMessageBox.question("restart.question", "Installer", "Your computer needs to restart to complete your software installation. Do you wish to restart Now?", QMessageBox.Yes | QMessageBox.No);

        // User has selected 'yes' to restart
        if (restart_reply == QMessageBox.Yes) {
            var widget = gui.currentPageWidget();
            if (widget != null) {
                var runItCheckBox = widget.findChild("RunItCheckBox");
                if (runItCheckBox != null) {
                    runItCheckBox.setChecked(false);
                }
            }

            console.log("User reply to restart computer: Yes, restarting computer (with 5 second delay)");
            installer.executeDetached("powershell", "shutdown /r /t 5", "");
        } else {
            console.log("User reply to restart computer: No");
        }
    } else {
        console.log("restart not required, terminating");
    }
}

Component.prototype.addShortcutWidget = function () {
    try {
        if (installer.addWizardPage( component, "ShortcutCheckBoxWidget", QInstaller.StartMenuSelection )) {
            console.log("ShortcutCheckBoxWidget page added");
            var widget = gui.pageWidgetByObjectName("DynamicShortcutCheckBoxWidget");
            if (widget != null) {
                var desktopCheckBox = widget.findChild("desktopCheckBox");
                if (desktopCheckBox != null) {
                    desktopCheckBox.toggled.connect(this, Component.prototype.desktopShortcutChanged);
                }
                var startMenuCheckBox = widget.findChild("startMenuCheckBox");
                if (startMenuCheckBox != null) {
                    startMenuCheckBox.toggled.connect(this, Component.prototype.startMenuShortcutChanged);
                }
            }
        } else {
            console.log("ShortcutCheckBoxWidget page not added");
        }
    } catch(e) {
        console.log("ShortcutCheckBoxWidget page not added");
        console.log(e);
    }
}

Component.prototype.desktopShortcutChanged = function (checked)
{
    console.log("desktopShortcutChanged to : " + checked);
    if (checked == true) {
        installer.setValue("add_desktop_shortcut", "true");
    } else {
        installer.setValue("add_desktop_shortcut", "false");
    }
}

Component.prototype.startMenuShortcutChanged = function (checked)
{
    console.log("startMenuShortcutChanged to : " + checked);
    if (checked == true) {
        installer.setValue("add_start_menu_shortcut", "true");
        installer.setValue("StartMenuDir", "ON Semiconductor");
        if (systemInfo.productType == "windows") {
            installer.setDefaultPageVisible(QInstaller.StartMenuSelection, true);
        }
    } else {
        installer.setValue("add_start_menu_shortcut", "false");
        installer.setValue("StartMenuDir", "");
        if (systemInfo.productType == "windows") {
            installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
        }
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
        if (n == 0) {
            var m = x[i].indexOf(": ", n + element_name.length);
            res.push(x[i].slice(m + ": ".length));
        }
    }
    return res;
}

function uninstallPreviousStrataInstallation()
{
    if (systemInfo.productType == "windows") {
        powerShellCommand = "(Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like 'Strata Developer Studio*' -or $_.DisplayName -eq '" + installer.value("Name") + "' })"
        console.log("executing powershell command '" + powerShellCommand + "'");
        // the installer is 32bit application :/ it will not find 64bit registry entries unless it is forced to open 64bit binary
        var isInstalled = installer.execute("C:\\Windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe", ["-command", powerShellCommand]);

        // the output of command is the first item, and the return code is the second
        // console.log("execution result code: " + isInstalled[1] + ", result: '" + isInstalled[0] + "'");

        if ((isInstalled[0] != null) && (isInstalled[0] != undefined) && (isInstalled[0] != "")) {
            var up_to_date = false;

            var display_name = getPowershellElement(isInstalled[0], 'DisplayName');
            var display_version = getPowershellElement(isInstalled[0], 'DisplayVersion');
            var uninstall_string = getPowershellElement(isInstalled[0], 'UninstallString');

            console.log("found DisplayName: '" + display_name + "', DisplayVersion: '" + display_version + "', UninstallString: '" + uninstall_string + "'");

            // we should not find multiple entries here, but just in case, check the highest
            if ((display_name.length != 0) && ((display_name.length == display_version.length) && (display_name.length == uninstall_string.length))) {
                var perform_uninstall = false;
                var uninstall_reply = QMessageBox.question("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected. Do you wish to uninstall?", QMessageBox.Yes | QMessageBox.No, QMessageBox.Yes);

                // User has selected 'yes' to uninstall
                if (uninstall_reply == QMessageBox.Yes) {
                    perform_uninstall = true;
                    console.log("User reply to uninstall Strata: Yes");
                } else {
                    console.log("User reply to uninstall Strata: No");
                }
                if (perform_uninstall == true) {
                    for (var i = 0; i < display_version.length; i++) {
                        console.log("executing Strata uninstall command: '" + uninstall_string[i] + "'");
                        var e = installer.execute(uninstall_string[i], ["purge"]);
                        console.log(e);
                    }
                }
            }

            return up_to_date;
        } else {
            console.log("program not found, will install new version");
            return false;
        }
    } else if (systemInfo.productType == "osx") {
        var maintenance_tool = installer.value("TargetDir") + "/" + installer.value("MaintenanceToolName") + ".app";
        console.log("checking if '" + maintenance_tool + "' exists");
        if (installer.fileExists(maintenance_tool) == true) {
            var perform_uninstall = false;
            var uninstall_reply = QMessageBox.question("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected. Do you wish to uninstall?", QMessageBox.Yes | QMessageBox.No, QMessageBox.Yes);

            // User has selected 'yes' to uninstall
            if (uninstall_reply == QMessageBox.Yes) {
                perform_uninstall = true;
                console.log("User reply to uninstall Strata: Yes");
            } else {
                console.log("User reply to uninstall Strata: No");
            }
            if (perform_uninstall == true) {
                console.log("executing Strata uninstall");
                installer.execute(installer.value("TargetDir") + "/" + installer.value("MaintenanceToolName") + ".app/Contents/MacOS/" + installer.value("MaintenanceToolName"), ["purge"]);
            }
        } else {
            console.log("program not found, will install new version");
            return false;
        }
    }
}
