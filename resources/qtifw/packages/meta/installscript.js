/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
var isSilent = false;
var performCleanup = false;
var restart_is_required = false;
var is_command_line_instance = false;

function isValueSet(val)
{
    return (installer.containsValue(val) && ((installer.value(val).toLowerCase() == "true") || (installer.value(val) == "1")));
}

function Component()
{
    installer.installationFinished.connect(this, Component.prototype.onInstallationOrUpdateFinished);   // called after installation, update and adding/removing components
    installer.installationStarted.connect(this, Component.prototype.onInstallationStarted);
    // note: uninstallation events cannot be connected here, because Component is not created

    try {
        is_command_line_instance = installer.isCommandLineInstance();
        console.log("detected command line instance: " + is_command_line_instance);
    } catch(e) {
        console.log("unable detect if command line instance is being used, fallback to false");
        is_command_line_instance = false;
    }

    if (is_command_line_instance == false) {
        installer.finishButtonClicked.connect(this, Component.prototype.onFinishButtonClicked);
        if (installer.isInstaller() && (systemInfo.productType == "windows")) {
            component.loaded.connect(this, Component.prototype.addShortcutWidget);
            gui.pageById(QInstaller.StartMenuSelection).left.connect(this, Component.prototype.onStartMenuSelectionPageLeft);
        }
        gui.pageById(QInstaller.ComponentSelection).entered.connect(this, Component.prototype.onComponentSelectionPageEntered);
        gui.pageById(QInstaller.LicenseCheck).entered.connect(this, Component.prototype.onLicenseAgreementPageEntered);
        gui.pageById(QInstaller.InstallationFinished).entered.connect(this, Component.prototype.onFinishedPageEntered);
    }

    if (installer.isInstaller() && (systemInfo.productType == "windows")) {
        // do not use "StartMenuDir" directly, because it is overwritten later to full path
        installer.setValue("StartMenuDir_internal", "onsemi");
    }

    if (isValueSet("isSilent_internal")) {
        isSilent = true;
    }

    if (isValueSet("performCleanup_internal")) {
        performCleanup = true;
    }
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();

    if (systemInfo.productType == "windows") {
        let target_dir = installer.value("TargetDir").split("/").join("\\");

        let file_content = 'Set fso = WScript.CreateObject("Scripting.FileSystemObject")\n';
        file_content += 'Set shl = WScript.CreateObject("WScript.Shell")\n';
        file_content += 'maintenance_tool_name = WScript.Arguments.Item(0)\n';
        file_content += 'temp_folder = WScript.Arguments.Item(1)\n';
        file_content += 'installer_dat = WScript.Arguments.Item(2)\n';
        file_content += 'maintenance_tool_dat = WScript.Arguments.Item(3)\n\n';
        file_content += 'if StrComp(maintenance_tool_name, "empty") <> 0 then\n';
        file_content += '    Set objFolder = fso.GetFolder(temp_folder)\n';
        file_content += '    Set colFiles = objFolder.Files\n';
        file_content += '    for each objFile in colFiles\n';
        file_content += '        file_name = objFile.Name\n';
        file_content += '        if instr(file_name, maintenance_tool_name) <> 0 AND instr(file_name, ".lock") <> 0 then\n';
        file_content += '            while fso.FileExists(temp_folder & "\\" & file_name)\n';
        file_content += '                WScript.Sleep(1000)\n';
        file_content += '            wend\n';
        file_content += '            exit for\n';
        file_content += '        end if\n';
        file_content += '    next\n';
        file_content += '    WScript.Sleep(1000)\n';
        file_content += '    Set objFolder = fso.GetFolder(temp_folder)\n';
        file_content += '    Set colFiles = objFolder.Files\n';
        file_content += '    for each objFile in colFiles\n';
        file_content += '        file_name = objFile.Name\n';
        file_content += '        if instr(file_name, "deferredrename") <> 0 AND instr(file_name, ".vbs") <> 0 then\n';
        file_content += '            num = 0\n';
        file_content += '            while (num < 10 AND fso.FileExists(temp_folder & "\\" & file_name))\n';
        file_content += '                WScript.Sleep(1000)\n';
        file_content += '                num = num + 1\n';
        file_content += '            wend\n';
        file_content += '            exit for\n';
        file_content += '        end if\n';
        file_content += '    next\n';
        file_content += 'end if\n\n';
        file_content += 'WScript.Sleep(1000)\n\n';
        file_content += 'if fso.FileExists(installer_dat & ".new") then\n';
        file_content += '	shl.Run "icacls """ & installer_dat & ".new" & """ /inheritance:e", 0, True\n';
        file_content += 'end if\n';
        file_content += 'num = 0\n';
        file_content += 'while (num < 10 AND fso.FileExists(installer_dat) = False)\n';
        file_content += '    WScript.Sleep(1000)\n';
        file_content += '    num = num + 1\n';
        file_content += 'wend\n';
        file_content += 'shl.Run "icacls """ & installer_dat & """ /inheritance:e", 0, True\n\n';
        file_content += 'if fso.FileExists(maintenance_tool_dat & ".new") then\n';
        file_content += '	shl.Run "icacls """ & maintenance_tool_dat & ".new" & """ /inheritance:e", 0, True\n';
        file_content += 'end if\n';
        file_content += 'num = 0\n';
        file_content += 'while (num < 10 AND fso.FileExists(maintenance_tool_dat) = False)\n';
        file_content += '    WScript.Sleep(1000)\n';
        file_content += '    num = num + 1\n';
        file_content += 'wend\n';
        file_content += 'shl.Run "icacls """ & maintenance_tool_dat & """ /inheritance:e", 0, True\n';

        let script_file = target_dir + "\\" + "update_permissions.vbs";
        component.addOperation("AppendFile", script_file, file_content);

        if (installer.value("add_start_menu_shortcut", "true") == "true") {
            if (installer.value("add_start_menu_shortcut", "true") == "true") {
                let strata_mt_shortcut_dst = "";
                let start_menu_folder = installer.value("StartMenuDir_internal");
                if ((start_menu_folder != "") && (start_menu_folder.endsWith("\\") == false)) {
                    start_menu_folder += "\\";
                }
                if (installer.value("add_public_shortcuts", "true") == "true") {
                    strata_mt_shortcut_dst = installer.value("AllUsersStartMenuProgramsPath").split("/").join("\\") + "\\" + start_menu_folder + installer.value("MaintenanceToolName") + ".lnk";
                    // will point to public Start Menu in this case
                    component.addElevatedOperation("CreateShortcut", target_dir + "\\" + installer.value("MaintenanceToolName") + ".exe", strata_mt_shortcut_dst,
                                                "workingDirectory=" + target_dir, "description=Open Maintenance Tool");
                } else {
                    strata_mt_shortcut_dst = installer.value("UserStartMenuProgramsPath").split("/").join("\\") + "\\" + start_menu_folder + installer.value("MaintenanceToolName") + ".lnk";
                    component.addOperation("CreateShortcut", target_dir + "\\" + installer.value("MaintenanceToolName") + ".exe", strata_mt_shortcut_dst,
                                        "workingDirectory=" + target_dir, "description=Open Maintenance Tool");
                }
                console.log("will add Start Menu shortcut to: " + strata_mt_shortcut_dst);
            }
        }
    }
}

Component.prototype.onInstallationStarted = function()
{
    if (component.updateRequested() || component.installationRequested()) {
        if (systemInfo.productType == "windows") {
            let target_dir = installer.value("TargetDir").split("/").join("\\");
            component.installerbaseBinaryPath = target_dir + "\\installerbase.exe";
            installer.setInstallerBaseBinary(component.installerbaseBinaryPath);
        } else if (systemInfo.productType == "osx") {
            component.installerbaseBinaryPath = installer.value("TargetDir") + "/installerbase";
            installer.setInstallerBaseBinary(component.installerbaseBinaryPath);
        }
    }

    if (installer.isInstaller()) {
        if (uninstallPreviousStrataInstallation() == false) {
            installer.interrupt();
            return;
        }

        if (systemInfo.productType == "windows") {
            let gainedAdminRights = installer.gainAdminRights();
            // correct access rights to Strata config folder to avoid issues later
            let onsemiConfigFolder = getProgramDataDirectory() + "\\onsemi";
            if (installer.fileExists(onsemiConfigFolder) == false) {
                installer.execute("cmd", ["/c", "mkdir", onsemiConfigFolder]);
            }
            if (installer.fileExists(onsemiConfigFolder)) {
                console.log("changing access rights for Strata config folder: " + onsemiConfigFolder);
                installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/grant", "Users:(OI)(CI)(F)"]);
                installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/setowner", "Users"]);
            }

            // correct access rights to Strata folder to avoid issues later
            let target_dir = installer.value("TargetDir").split("/").join("\\");
            if (installer.fileExists(target_dir) == false) {
                installer.execute("cmd", ["/c", "mkdir", target_dir]);
            }
            if (installer.fileExists(target_dir)) {
                console.log("changing access rights for Strata folder: " + target_dir);
                installer.execute("cmd", ["/c", "icacls", target_dir, "/grant", "Users:(OI)(CI)(F)"]);
                installer.execute("cmd", ["/c", "icacls", target_dir, "/setowner", "Users"]);
            }

            if (gainedAdminRights) {
                installer.dropAdminRights();
            } else {
                console.log("Error: unable to elevate access rights");
            }
        }
    }
}

Component.prototype.onComponentSelectionPageEntered = function ()
{
    console.log("onComponentSelectionPageEntered");

    let widget = gui.pageById(QInstaller.ComponentSelection);
    if (widget != null) {
        if (isSilent) {
            // select the ui components
            if (performCleanup == true) {
                let componentsToClean = acquireCleanupOperations();
                for (let i = 0; i < componentsToClean.length; i++) {
                    console.log("removing: " + componentsToClean[i])
                    widget.deselectComponent(componentsToClean[i]);
                }
            } else if (installer.isInstaller()) {
                widget.selectAll();
                //widget.selectComponent("com.onsemi.strata.devstudio");
            }
        }
    } else {
        console.log("Error: unable to locate default page 'ComponentSelection'");
    }
}

Component.prototype.onLicenseAgreementPageEntered = function ()
{
    console.log("onLicenseAgreementPageEntered");

    if (isSilent && (installer.isUpdater() == false)) {
        let widget = gui.pageById(QInstaller.LicenseCheck);
        if (widget != null) {
            let licenseRadioButton = widget.findChild("AcceptLicenseRadioButton");
            if (licenseRadioButton != null) {
                // QTIFW version 3.2
                licenseRadioButton.setChecked(true);
            } else {
                let licenseCheckBox = widget.findChild("AcceptLicenseCheckBox");
                if (licenseCheckBox != null) {
                    // QTIFW version 4.1+
                    licenseCheckBox.setChecked(true);
                } else {
                    console.log("Error: unable to acquire checkbox 'AcceptLicenseCheckBox'");
                }
            }
        } else {
            console.log("Error: unable to locate default page 'LicenseCheck'");
        }
    }
}

Component.prototype.onFinishedPageEntered = function ()
{
    console.log("onFinishedPageEntered");

    let widget = gui.pageById(QInstaller.InstallationFinished);
    if (widget != null) {
        let runItCheckBox = widget.findChild("RunItCheckBox");
        if (runItCheckBox != null) {
            if ((installer.isUpdater() || installer.isPackageManager()) && (installer.status == QInstaller.Success) && isSilent && isComponentInstalled("com.onsemi.strata.devstudio")) {
                runItCheckBox.setChecked(true);
            } else {
                runItCheckBox.setChecked(false);
            }
        } else {
            console.log("Error: unable to acquire checkbox 'RunItCheckBox'");
        }

        if (installer.isInstaller() && (installer.status != QInstaller.Success)) {
            installer.setValue("TargetDir", "");    // prohibit writing log into destination directory
        }
    } else {
        console.log("Error: unable to locate default page 'InstallationFinished'");
    }

    if (isSilent) {
        if (installer.isUpdater() && (installer.status == QInstaller.Success) && (performCleanup == false)) {
            // after update, we can do cleanup if available
            let componentsToClean = acquireCleanupOperations();
            if (componentsToClean.length > 0) {
                // when it restarts, it retains all variables
                installer.setValue("restartMaintenanceTool", "true");
                installer.setValue("performCleanup_internal","true");   // set this since the Controller() is not called
            }
        }
    }
}

Component.prototype.onStartMenuSelectionPageLeft = function ()
{
    let widget = gui.pageById(QInstaller.StartMenuSelection);
    if (widget != null) {
        let lineEdit = widget.findChild("StartMenuPathLineEdit");
        if (lineEdit != null) {
            installer.setValue("StartMenuDir_internal", lineEdit.text.trim().split("/").join("\\"))
        } else {
            console.log("Error: unable to acquire line edit 'StartMenuPathLineEdit'");
        }
    } else {
        console.log("Error: unable to locate default page 'StartMenuSelection'");
    }
}

function isRestartRequired(strataUtilsFolder)
{
    let vc_redist_temp_file = strataUtilsFolder + "\\VC_REDIST\\vc_redist_out.txt";
    if (installer.fileExists(vc_redist_temp_file)) {
        let exit_code = installer.readFile(vc_redist_temp_file, "UTF-8").trim();
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
        installer.performOperation("Delete", vc_redist_temp_file);

        if (exit_code == "3010") {
            restart_is_required = true;
        } else {
            restart_is_required = false;
        }
    } else {
        restart_is_required = false;
    }
}

function isComponentInstalled(component_name)
{
    let component = installer.componentByName(component_name);
    if (component != null) {
        let installed = component.isInstalled();
        console.log("component '" + component_name + "' found and is installed: " + installed);
        return installed;
    }

    console.log("component '" + component_name + "' NOT found");
    return false;
}

function isComponentAvailable(component_name)
{
    // functions to check component state:
    // boolean installationRequested()
    // boolean uninstallationRequested()
    // boolean updateRequested()
    // boolean isInstalled()
    // boolean isUninstalled()

    let component = installer.componentByName(component_name);
    if (component != null) {
        let available = component.installationRequested() || component.updateRequested() || (component.isInstalled() && !component.uninstallationRequested());
        console.log("component '" + component_name + "' found and is available: " + available);
        return available;
    }

    console.log("component '" + component_name + "' NOT found");
    return false;
}

Component.prototype.onInstallationOrUpdateFinished = function()
{
    console.log("onInstallationOrUpdateFinished entered");

    let target_dir = installer.value("TargetDir");
    if (systemInfo.productType == "windows") {
        target_dir = target_dir.split("/").join("\\");
    }
    if (isComponentInstalled("com.onsemi.strata.devstudio")) {
        if (systemInfo.productType == "windows") {
            installer.setValue("RunProgram", target_dir + "\\Strata Developer Studio.exe");
        } else if (systemInfo.productType == "osx") {
            installer.setValue("RunProgram", target_dir + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
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

    if (systemInfo.productType == "windows") {
        // erase StrataUtils folder
        let strataUtilsFolder = target_dir + "\\StrataUtils";
        if (installer.fileExists(strataUtilsFolder)) {
            if (installer.status == QInstaller.Success) {
                isRestartRequired(strataUtilsFolder);   // call BEFORE erasing StrataUtils folder
            }
            console.log("erasing StrataUtils folder: " + strataUtilsFolder);
            installer.execute("cmd", ["/c", "rd", "/s", "/q", strataUtilsFolder]);
            if (installer.fileExists(strataUtilsFolder)) {
                console.log("unable to erase StrataUtils folder: " + strataUtilsFolder);
            }
        }

        if (installer.status == QInstaller.Success) {
            console.log("fixing permissions for .dat files which are missing inheritance due to the way QTIFW creates them");
            let script_file = target_dir + "\\" + "update_permissions.vbs";
            let installer_dat = target_dir + "\\" + "installer.dat";
            let maintenance_tool_dat = target_dir + "\\" + installer.value("MaintenanceToolName") + ".dat";
            let temp_location = QDesktopServices.storageLocation(QDesktopServices.TempLocation).split("/").join("\\");

            if (installer.isInstaller()) {
                let res = installer.executeDetached("cscript", [script_file, "empty", temp_location, installer_dat, maintenance_tool_dat]);
                console.log("result detached execution of cscript: ", res);
            } else {
                let res = installer.executeDetached("cscript", [script_file, installer.value("MaintenanceToolName"), temp_location, installer_dat, maintenance_tool_dat]);
                console.log("result detached execution of cscript: ", res);
            }
        }
    }

    if (is_command_line_instance && (installer.value("RunProgram") != "")) {
        console.log("Executing: " + installer.value("RunProgram"));
        installer.executeDetached(installer.value("RunProgram"));
    }
}

Component.prototype.onFinishButtonClicked = function()
{
    if (restart_is_required && isSilent == false) {
        console.log("showing restart question to user");
        // Print a message for Windows users to tell them to restart the host machine, immediately or later
        let restart_reply = QMessageBox.question("restart.question", "Installer", "Your computer needs to restart to complete your software installation. Do you wish to restart Now?", QMessageBox.Yes | QMessageBox.No);

        // User has selected 'yes' to restart
        if (restart_reply == QMessageBox.Yes) {
            let widget = gui.currentPageWidget();
            if (widget != null) {
                let runItCheckBox = widget.findChild("RunItCheckBox");
                if (runItCheckBox != null) {
                    runItCheckBox.setChecked(false);
                }
            }

            console.log("User reply to restart computer: Yes, restarting computer (with 5 second delay)");
            installer.execute("cmd", ["/c", "shutdown", "/r", "/t", "5"]);
        } else {
            console.log("User reply to restart computer: No");
        }
    } else {
        console.log("restart not required, terminating");
    }
}

Component.prototype.addShortcutWidget = function () {
    if (installer.addWizardPage( component, "ShortcutCheckBoxWidget", QInstaller.StartMenuSelection )) {
        console.log("ShortcutCheckBoxWidget page added");
        let widget = gui.pageByObjectName("DynamicShortcutCheckBoxWidget");
        if (widget != null) {
            let desktopCheckBox = widget.findChild("desktopCheckBox");
            if (desktopCheckBox != null) {
                desktopCheckBox.toggled.connect(this, Component.prototype.desktopShortcutChanged);
            } else {
                console.log("Unable to acquire desktopCheckBox");
            }
            let startMenuCheckBox = widget.findChild("startMenuCheckBox");
            if (startMenuCheckBox != null) {
                startMenuCheckBox.toggled.connect(this, Component.prototype.startMenuShortcutChanged);
            } else {
                console.log("Unable to acquire startMenuCheckBox");
            }
            let allUsersRadioButton = widget.findChild("allUsersRadioButton");
            if (allUsersRadioButton != null) {
                allUsersRadioButton.toggled.connect(this, Component.prototype.allUsersRadioButtonChanged);
            } else {
                console.log("Unable to acquire allUsersRadioButton");
            }
            widget.entered.connect(this, Component.prototype.ShortcutCheckBoxWidgetEntered);
        } else {
            console.log("Unable to acquire DynamicShortcutCheckBoxWidget");
        }
    } else {
        console.log("ShortcutCheckBoxWidget page not added");
    }
}

Component.prototype.ShortcutCheckBoxWidgetEntered = function () {
    console.log("ShortcutCheckBoxWidgetEntered");
    let widget = gui.pageWidgetByObjectName("DynamicShortcutCheckBoxWidget");
    if (widget != null) {
        let desktopCheckBox = widget.findChild("desktopCheckBox");
        if (desktopCheckBox != null) {
            if (isComponentAvailable("com.onsemi.strata.devstudio")) {
                desktopCheckBox.setEnabled(true);
                desktopCheckBox.setChecked(installer.value("add_desktop_shortcut", "true") == "true");
            } else {
                desktopCheckBox.setEnabled(false);
                desktopCheckBox.setChecked(false);
            }
        } else {
            console.log("Unable to acquire desktopCheckBox");
        }
        let startMenuCheckBox = widget.findChild("startMenuCheckBox");
        if (startMenuCheckBox != null) {
            startMenuCheckBox.setChecked(installer.value("add_start_menu_shortcut", "true") == "true");
        } else {
            console.log("Unable to acquire startMenuCheckBox");
        }
    } else {
        console.log("Unable to acquire DynamicShortcutCheckBoxWidget");
    }
}

Component.prototype.desktopShortcutChanged = function (checked)
{
    console.log("desktopShortcutChanged to : " + checked);
    if (checked) {
        installer.setValue("add_desktop_shortcut", "true");
    } else {
        installer.setValue("add_desktop_shortcut", "false");
    }
}

Component.prototype.startMenuShortcutChanged = function (checked)
{
    console.log("startMenuShortcutChanged to : " + checked);
    if (checked) {
        installer.setValue("add_start_menu_shortcut", "true");
        if (systemInfo.productType == "windows") {
            installer.setDefaultPageVisible(QInstaller.StartMenuSelection, true);
        }
    } else {
        installer.setValue("add_start_menu_shortcut", "false");
        if (systemInfo.productType == "windows") {
            installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
        }
    }
}

Component.prototype.allUsersRadioButtonChanged = function (checked)
{
    console.log("allUsersRadioButtonChanged to : " + checked);
    if (checked) {
        installer.setValue("add_public_shortcuts", "true");
    } else {
        installer.setValue("add_public_shortcuts", "false");
    }
}

// Return 1 if a > b
// Return -1 if a < b
// Return 0 if a == b
function compare(a, b) {
    if (a === b) {
       return 0;
    }

    let a_components = a.split(".");
    let b_components = b.split(".");

    let len = Math.min(a_components.length, b_components.length);

    // loop while the components are equal
    for (let i = 0; i < len; i++) {
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
    let res = [];
    let x = str.split('\r\n');
    for(let i = 0; i < x.length; i++){
        let n = x[i].indexOf(element_name);
        if (n == 0) {
            let m = x[i].indexOf(": ", n + element_name.length);
            res.push(x[i].slice(m + ": ".length));
        }
    }
    return res;
}

function getWindowsDirectory()
{
    let windowsPath = installer.value("RootDir").split("/").join("\\") + "\\Windows";
    let windowsPathEnv = installer.environmentVariable("windir");
    if (windowsPathEnv !== "") {
        windowsPath = windowsPathEnv;
        console.log("detected Windows path: " + windowsPath);
    } else {
        console.log("unable to detect correct Windows path, trying default one: " + windowsPath);
    }

    return windowsPath;
}

function validateCommandOutput(commandOutput)
{
    // the output of command is the first item, and the return code is the second
    // console.log("execution result code: " + commandOutput[1] + ", result: '" + commandOutput[0] + "'");
    if ((commandOutput == undefined) || (commandOutput == null)) {
        console.log("Error: powershell command failed to execute");
        return "";
    }

    if ((commandOutput[1] == undefined) || (commandOutput[1] == null) || (commandOutput[1] != 0)) {
        console.log("Error: powershell command returned bad exit code:", commandOutput);
        return "";
    }

    if ((commandOutput[0] == undefined) || (commandOutput[0] == null)) {
        return "";
    }

    // the output of command is the first item, and the return code is the second
    // console.log("execution result code: " + commandOutput[1] + ", result: '" + commandOutput[0] + "'");
    return commandOutput[0];
}

function executePowershell(powershell64Location, powerShellCommand)
{
    console.log("executing powershell command '" + powerShellCommand + "'");
    let powershellOutput = installer.execute(powershell64Location, ["-NoProfile", "-Command", powerShellCommand]);

    return validateCommandOutput(powershellOutput);
}

function executeFind()
{
    console.log("checking if '" + installer.value("MaintenanceToolName") + ".app' exists in " + installer.value("ApplicationsDirUser"));
    let findOutput = installer.execute("find", [installer.value("ApplicationsDirUser"), "-name", installer.value("MaintenanceToolName") + ".app"]);

    return validateCommandOutput(findOutput);
}

function showUninstallQuestion()
{
    let uninstall_reply = QMessageBox.warning("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected.\nIt will be uninstalled before proceeding.", QMessageBox.Ok | QMessageBox.Abort, QMessageBox.Ok);
    
    if (uninstall_reply == QMessageBox.Ok) {
        console.log("User reply to uninstall Strata: Ok");
        return true;
    } else {
        console.log("User reply to uninstall Strata: Abort");
        return false;
    }
}

function uninstallPreviousStrataInstallation()
{
    console.log("Checking for presence of old Strata...");
    if (systemInfo.productType == "windows") {
        let registryPaths = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall";
        let strataFilter = "$_.DisplayName -like 'Strata Developer Studio*' -or $_.DisplayName -eq '" + installer.value("Name") + "'";

        // Note: old Powershell 2.0 on Windows 7 needs the "[Environment]::Exit(0)", because it is waiting for input and not terminating
        let powerShellCommand = "(Get-ChildItem -ErrorAction SilentlyContinue -LiteralPath " + registryPaths + " | Get-ItemProperty | Where-Object {" + strataFilter + "}); [Environment]::Exit(0)";
        let powershell64Location = getWindowsDirectory() + "\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe";
        if (installer.fileExists(powershell64Location) == false) {
            console.log("unable to locate 64bit powershell at " + powershell64Location);
            powershell64Location = "powershell";    // use default one (32bit), which will not locate older Strata
        }

        // DO NOT ELEVATE access rights before calling this, if the admin user is different, this command will fail to find the old Strata installation in HKCU registry
        let registryData = executePowershell(powershell64Location, powerShellCommand);
        if (registryData == "") {
            console.log("old Strata not found");
            return true;
        }

        let display_name = getPowershellElement(registryData, 'DisplayName');
        let display_version = getPowershellElement(registryData, 'DisplayVersion');
        let uninstall_string = getPowershellElement(registryData, 'UninstallString');
    
        console.log("found DisplayName: '" + display_name + "', DisplayVersion: '" + display_version + "', UninstallString: '" + uninstall_string + "'");
    
        if (uninstall_string.length == 0) {
            console.log("unable to acquire uninstall string for old Strata");
            return true;
        }

        if ((is_command_line_instance == false) && (isSilent == false)) {
            if (showUninstallQuestion() == false) {
                return false;
            }
        }

        // we should not find multiple entries here, but just in case, uninstall all
        // also make sure to run with admin rights to not show multiple prompts each time
        let gainedAdminRights = installer.gainAdminRights();
        for (let i = 0; i < uninstall_string.length; i++) {
            let uninstall_binary = uninstall_string[i].split('"').join('');
            if (installer.fileExists(uninstall_binary)) {
                console.log("executing Strata uninstall binary: '" + uninstall_binary + "'");
                installer.performOperation("Execute", [uninstall_binary, "purge", "-c", "/SILENT", "showStandardError"]);
            } else {
                console.log("Error: unable to locate Strata uninstall binary: '" + uninstall_binary + "'");
            }
        }
        if (gainedAdminRights) {
            installer.dropAdminRights();
        } else {
            console.log("Error: unable to elevate access rights");
        }
    } else if (systemInfo.productType == "osx") {
        let findData = executeFind();

        if (findData == "") {
            console.log("old Strata not found");
            return true;
        }

        if ((is_command_line_instance == false) && (isSilent == false)) {
            if (showUninstallQuestion() == false) {
                return false;
            }
        }

        // we should not find multiple entries here, but just in case, uninstall all
        let maintenanceToolLocations = findData.split('\n');
        for (let i = 0; i < maintenanceToolLocations.length; i++) {
            if (maintenanceToolLocations[i] == "") {
                continue;
            }
            let maintenance_tool = maintenanceToolLocations[i] + "/Contents/MacOS/" + installer.value("MaintenanceToolName");
            if (installer.fileExists(maintenance_tool)) {
                console.log("executing Strata uninstall for: '" + maintenance_tool + "'");
                installer.performOperation("Execute", [maintenance_tool, "purge", "-c", "showStandardError"]);
            } else {
                console.log("Error: unable to execute Strata uninstall for: '" + maintenance_tool + "'");
            }
        }
    }
    return true;
}

function acquireCleanupOperations()
{
    console.log("acquireCleanupOperations entered");

    if (installer.isInstaller() || installer.isUninstaller()) {
        return [];
    }

    if (installer.fileExists(installer.value("TargetDir")) == false) {
        console.log("No TargetDir '" + installer.value("TargetDir") + "' found");
        return [];
    }

    let target_dir = installer.value("TargetDir") + "/";
    if (systemInfo.productType == "windows") {
        target_dir = target_dir.split("/").join("\\");
    }
    let cleanupFile = target_dir + "cleanup.txt";

    if (installer.fileExists(cleanupFile) == false) {
        console.log("No cleanup.txt file found");
        return [];
    }

    console.log("Found cleanup.txt: " + cleanupFile + ", parsing...");

    let content = installer.readFile(cleanupFile, "UTF-8");
    if (content == "") {
        console.log("Empty cleanup.txt, nothing to cleanup");
        return [];
    }

    let cleanupAvailable = false;
    let lines = content.split('\n');
    let componentsToClean = [];
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        if (line == "") {
            continue;
        }
        if (isComponentInstalled(line)) {
            cleanupAvailable = true;
            componentsToClean.push(line)
        }
    }
    
    console.log("Found " + componentsToClean.length + " components to cleanup");
    return componentsToClean;
}

function getProgramDataDirectory()
{
    let programDataPath = installer.value("RootDir").split("/").join("\\") + "\\ProgramData";
    let programDataPathEnv = installer.environmentVariable("ProgramData");
    if (programDataPathEnv !== "") {
        programDataPath = programDataPathEnv;
        console.log("detected ProgramData path: " + programDataPath);
    } else {
        console.log("unable to detect correct ProgramData path, trying default one: " + programDataPath);
    }

    return programDataPath;
}
