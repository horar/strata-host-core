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
        }
        gui.pageById(QInstaller.ComponentSelection).entered.connect(this, Component.prototype.onComponentSelectionPageEntered);
        gui.pageById(QInstaller.LicenseCheck).entered.connect(this, Component.prototype.onLicenseAgreementPageEntered);
        gui.pageById(QInstaller.InstallationFinished).entered.connect(this, Component.prototype.onFinishedPageEntered);
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

    if (installer.isInstaller()) {
        uninstallPreviousStrataInstallation();
    }

    if ((systemInfo.productType == "windows") && (installer.value("add_start_menu_shortcut", "true") == "true")) {
        let target_dir = installer.value("TargetDir").split("/").join("\\");
        let strata_mt_shortcut_dst = installer.value("StartMenuDir").split("/").join("\\") + "\\" + installer.value("MaintenanceToolName") + ".lnk";
        component.addOperation("CreateShortcut", target_dir + "\\" + installer.value("MaintenanceToolName") + ".exe", strata_mt_shortcut_dst,
                                "workingDirectory=" + target_dir, "description=Open Maintenance Tool");
        console.log("will add Start Menu shortcut to: " + strata_mt_shortcut_dst);
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

    if ((systemInfo.productType == "windows") && installer.isInstaller()) {
        if (installer.gainAdminRights()) {
            // correct access rights to Strata config folder to avoid issues later
            let onsemiConfigFolder = getProgramDataDirectory() + "\\onsemi";
            try {
                if (installer.fileExists(onsemiConfigFolder) == false) {
                    installer.execute("cmd", ["/c", "mkdir", onsemiConfigFolder]);
                }
                if (installer.fileExists(onsemiConfigFolder)) {
                    console.log("changing access rights for Strata config folder: " + onsemiConfigFolder);
                    installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/grant", "Users:(OI)(CI)(F)"]);
                    installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/setowner", "Users"]);
                }
            } catch(e) {
                console.log("unable to change access rights for Strata config folder");
                console.log(e);
            }

            // correct access rights to Strata folder to avoid issues later
            let target_dir = installer.value("TargetDir").split("/").join("\\");
            try {
                if (installer.fileExists(target_dir) == false) {
                    installer.execute("cmd", ["/c", "mkdir", target_dir]);
                }
                if (installer.fileExists(target_dir)) {
                    console.log("changing access rights for Strata folder: " + target_dir);
                    installer.execute("cmd", ["/c", "icacls", target_dir, "/grant", "Users:(OI)(CI)(F)"]);
                    installer.execute("cmd", ["/c", "icacls", target_dir, "/setowner", "Users"]);
                }
            } catch(e) {
                console.log("unable to change access rights for Strata folder");
                console.log(e);
            }
            installer.dropAdminRights();
        } else {
            console.log("unable to elevate access rights");
            installer.interrupt();
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
                }
            }
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
        }

        if (installer.isInstaller() && (installer.status != QInstaller.Success))
            installer.setValue("TargetDir", "");    // prohibit writing log into destination directory
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

function isRestartRequired()
{
    let vc_redist_temp_file = installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\VC_REDIST\\vc_redist_out.txt";
    if (installer.fileExists(vc_redist_temp_file)) {
        let exit_code = installer.readFile(vc_redist_temp_file, "UTF-8");
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime return code: '" + exit_code + "'");
        installer.performOperation("Delete", vc_redist_temp_file);

        if (exit_code == "3010 ") {
            restart_is_required = true;
            return;
        }

        restart_is_required = false;
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

Component.prototype.onInstallationOrUpdateFinished = function()
{
    console.log("onInstallationOrUpdateFinished entered");

    let target_dir = installer.value("TargetDir");
    if (systemInfo.productType == "windows") {
        target_dir = target_dir.split("/").join("\\");
    }
    if (isComponentInstalled("com.onsemi.strata.devstudio") && (installer.isInstaller() || installer.isUpdater() || installer.isPackageManager())) {
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
        if ((installer.isInstaller() || installer.isUpdater() || installer.isPackageManager()) && (installer.status == QInstaller.Success)) {
            isRestartRequired();
        }

        // erase StrataUtils folder
        let strataUtilsFolder = target_dir + "\\StrataUtils";
        if (installer.fileExists(strataUtilsFolder)) {
            try {
                console.log("erasing StrataUtils folder: " + strataUtilsFolder);
                installer.execute("cmd", ["/c", "rd", "/s", "/q", strataUtilsFolder]);
                if (installer.fileExists(strataUtilsFolder)) {
                    console.log("unable to erase StrataUtils folder: " + strataUtilsFolder);
                }
            } catch(e) {
                console.log("unable to erase StrataUtils folder: " + strataUtilsFolder);
                console.log(e);
            }
        }

        if (installer.status == QInstaller.Success) {
            console.log("fixing permissions for .dat files");
            // always run after installation to fix files which refuse inheritance
            let installer_dat = target_dir + "\\" + "installer.dat";
            let maintenance_tool_dat = target_dir + "\\" + installer.value("MaintenanceToolName") + ".dat";
            if (installer.isInstaller()) {
                if (installer.fileExists(installer_dat))
                    installer.execute("cmd", ["/c", "icacls", installer_dat, "/grant", "Users:F"]);
                if (installer.fileExists(installer_dat + ".new"))
                    installer.execute("cmd", ["/c", "icacls", installer_dat + ".new", "/grant", "Users:F"]);
                if (installer.fileExists(maintenance_tool_dat))
                    installer.execute("cmd", ["/c", "icacls", maintenance_tool_dat, "/grant", "Users:F"]);
                if (installer.fileExists(maintenance_tool_dat + ".new"))
                    installer.execute("cmd", ["/c", "icacls", maintenance_tool_dat + ".new", "/grant", "Users:F"]);
            } else {
                let temp_location = QDesktopServices.storageLocation(QDesktopServices.TempLocation).split("/").join("\\");
                let temp_file = temp_location + "\\" + "fix_permissions.bat";
                installer.execute("cmd", ["/c", "echo @echo off>", temp_file]);
                installer.execute("cmd", ["/c", "echo :loop>>", temp_file]);
                installer.execute("cmd", ["/c", "echo set fileExist=>>", temp_file]);
                installer.execute("cmd", ["/c", 'echo dir %1 /b /a-d ^>nul 2^>^&1 >>', temp_file]);
                installer.execute("cmd", ["/c", "echo IF errorlevel 1 (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     set fileExist=0 >>", temp_file]);
                installer.execute("cmd", ["/c", "echo ) ELSE (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     set fileExist=1 >>", temp_file]);
                installer.execute("cmd", ["/c", "echo )>>", temp_file]);
                installer.execute("cmd", ["/c", "echo IF %fileExist% EQU 1 (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     timeout /t 5 /nobreak ^>nul>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     goto loop>>", temp_file]);
                installer.execute("cmd", ["/c", "echo ) ELSE (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     timeout /t 2 /nobreak ^>nul>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     IF EXIST %2 (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         ECHO granting %2 permissions>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         icacls %2 /grant Users:F>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     ) ELSE (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         ECHO file %2 does not exists>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     )>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     IF EXIST %3 (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         ECHO granting %3 permissions>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         icacls %3 /grant Users:F>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     ) ELSE (>>", temp_file]);
                installer.execute("cmd", ["/c", "echo         ECHO file %3 does not exists>>", temp_file]);
                installer.execute("cmd", ["/c", "echo     )>>", temp_file]);
                installer.execute("cmd", ["/c", "echo )>>", temp_file]);
                console.log("starting detached process " + temp_file);
                let maintenance_tool_lock = installer.value("MaintenanceToolName") + "*.lock";
                installer.executeDetached("cmd", ["/c", temp_file, maintenance_tool_lock, installer_dat, maintenance_tool_dat], temp_location);
            }
        }
    }

    if(is_command_line_instance && (installer.value("RunProgram") != "")) {
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
            let widget = gui.pageWidgetByObjectName("DynamicShortcutCheckBoxWidget");
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
                widget.entered.connect(this, Component.prototype.ShortcutCheckBoxWidgetEntered);
            } else {
                console.log("Unable to acquire DynamicShortcutCheckBoxWidget");
            }
        } else {
            console.log("ShortcutCheckBoxWidget page not added");
        }
    } catch(e) {
        console.log("ShortcutCheckBoxWidget page not added");
        console.log(e);
    }
}

Component.prototype.ShortcutCheckBoxWidgetEntered = function () {
    let widget = gui.pageWidgetByObjectName("DynamicShortcutCheckBoxWidget");
    if (widget != null) {
        let desktopCheckBox = widget.findChild("desktopCheckBox");
        if (desktopCheckBox != null) {
            if (Component.prototype.isComponentAvailable("com.onsemi.strata.devstudio")) {
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
        installer.setValue("StartMenuDir", "onsemi");
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

function uninstallPreviousStrataInstallation()
{
    if (systemInfo.productType == "windows") {
        powerShellCommand = "(Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like 'Strata Developer Studio*' -or $_.DisplayName -eq '" + installer.value("Name") + "' })"
        console.log("executing powershell command '" + powerShellCommand + "'");
        // the installer is 32bit application :/ it will not find 64bit registry entries unless it is forced to open 64bit binary
        let isInstalled = installer.execute("C:\\Windows\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe", ["-command", powerShellCommand]);

        // the output of command is the first item, and the return code is the second
        // console.log("execution result code: " + isInstalled[1] + ", result: '" + isInstalled[0] + "'");

        if ((isInstalled[0] != null) && (isInstalled[0] != undefined) && (isInstalled[0] != "")) {
            let display_name = getPowershellElement(isInstalled[0], 'DisplayName');
            let display_version = getPowershellElement(isInstalled[0], 'DisplayVersion');
            let uninstall_string = getPowershellElement(isInstalled[0], 'UninstallString');

            console.log("found DisplayName: '" + display_name + "', DisplayVersion: '" + display_version + "', UninstallString: '" + uninstall_string + "'");

            if ((display_name.length != 0) && ((display_name.length == display_version.length) && (display_name.length == uninstall_string.length))) {
                if ((is_command_line_instance == false) && (isSilent == false)) {
                    let uninstall_reply = QMessageBox.warning("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected.\nIt will be uninstalled before proceeding.", QMessageBox.Ok | QMessageBox.Abort, QMessageBox.Ok);

                    if (uninstall_reply == QMessageBox.Ok) {
                        console.log("User reply to uninstall Strata: Ok");
                    } else {
                        console.log("User reply to uninstall Strata: Abort");
                        installer.interrupt();
                        return false;
                    }
                }

                // we should not find multiple entries here, but just in case, uninstall all
                for (let i = 0; i < display_version.length; i++) {
                    console.log("executing Strata uninstall command: '" + uninstall_string[i] + "'");
                    let res = installer.execute(uninstall_string[i], ["isSilent=true", "--start-uninstaller"]);
                    console.log("result: " + res);
                }
            }
        } else {
            console.log("old program not found, will install new version");
        }
    } else if (systemInfo.productType == "osx") {
        console.log("checking if '" + installer.value("MaintenanceToolName") + ".app' exists in " + installer.value("ApplicationsDirX64"));
        let isInstalled = installer.execute("find", [installer.value("ApplicationsDirX64"), "-name", installer.value("MaintenanceToolName") + ".app"]);

        // the output of command is the first item, and the return code is the second
        // console.log("execution result code: " + isInstalled[1] + ", result: '" + isInstalled[0] + "'");

        if ((isInstalled[0] != null) && (isInstalled[0] != undefined) && (isInstalled[0] != "")) {
            if ((is_command_line_instance == false) && (isSilent == false)) {
                let uninstall_reply = QMessageBox.warning("uninstall.question", "Installer", "Previous " + installer.value("Name") + " installation detected.\nIt will be uninstalled before proceeding.", QMessageBox.Ok | QMessageBox.Abort, QMessageBox.Ok);

                if (uninstall_reply == QMessageBox.Ok) {
                    console.log("User reply to uninstall Strata: Ok");
                } else {
                    console.log("User reply to uninstall Strata: Abort");
                    installer.interrupt();
                    return false;
                }
            }

            // we should not find multiple entries here, but just in case, uninstall all
            let installed_stratas = isInstalled[0].split('\n');
            for (let i = 0; i < installed_stratas.length; i++) {
                if (installed_stratas[i] == "") {
                    continue;
                }
                console.log("executing Strata uninstall for: '" + installed_stratas[i] + "'");
                let res = installer.execute(installed_stratas[i] + "/Contents/MacOS/" + installer.value("MaintenanceToolName"), ["isSilent=true", "--start-uninstaller"]);
                console.log("result: " + res);
            }
        } else {
            console.log("old program not found, will install new version");
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
    try {
        let programDataPathEnv = installer.environmentVariable("ProgramData");
        if (programDataPathEnv !== "") {
            programDataPath = programDataPathEnv;
            console.log("detected ProgramData path: " + programDataPath);
        } else {
            console.log("unable to detect correct ProgramData path, trying default one: " + programDataPath);
        }
    } catch(e) {
        console.log("error while detecting correct ProgramData path, trying default one: " + programDataPath);
        console.log(e);
    }

    return programDataPath;
}
