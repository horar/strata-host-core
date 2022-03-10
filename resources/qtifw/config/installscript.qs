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
var componentsToClean = [];

function isValueSet(val)
{
    return (installer.containsValue(val) && ((installer.value(val).toLowerCase() == "true") || (installer.value(val) == "1")));
}

function setProgramDataDirectory()
{
    let programDataShortcut = installer.value("RootDir").split("/").join("\\") + "\\ProgramData";
    console.log("default ProgramData path: " + programDataShortcut);
    try {
        let programDataFolder = installer.execute("cmd", ["/c", "echo", "%ProgramData%"]);
        // the output of command is the first item, and the return code is the second
        if ((programDataFolder != undefined) && (programDataFolder != null) && (programDataFolder[0] != undefined) && (programDataFolder[0] != null) && (programDataFolder[0] != "")) {
            programDataShortcut = programDataFolder[0].trim();
            console.log("detected ProgramData path: " + programDataShortcut);
        } else {
            console.log("unable to detect correct ProgramData path, trying default one: " + programDataShortcut);
        }
    } catch(e) {
        console.log("error while detecting correct ProgramData path, trying default one: " + programDataShortcut);
        console.log(e);
    }

    installer.setValue("ProgramDataDir", programDataShortcut);
}

function Controller()
{
    if (isValueSet("isSilent")) {
        isSilent = true;
        installer.setValue("isSilent_internal","true");
    } else {
        installer.setValue("isSilent_internal","false");
    }

    console.log("Is isSilent set: " + isSilent);

    installer.installationFinished.connect(Controller.prototype.InstallationPerformed);
    installer.uninstallationFinished.connect(Controller.prototype.InstallationPerformed);

    if (isSilent) {
        // do not use this or it will be impossible to cancel the installer
        //installer.autoRejectMessageBoxes();
        //installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
        //installer.setMessageBoxAutomaticAnswer("stopProcessesForUpdates", QMessageBox.Ignore);
    }

    try {
        let widget = gui.pageById(QInstaller.Introduction); // get the introduction wizard page
        if (widget != null) {
            widget.packageManagerCoreTypeChanged.connect(onPackageManagerCoreTypeChanged);
        }
    } catch(e) {
        console.log("Controller: unable to access gui: " + e);
    }

    if (isValueSet("performCleanup")) {
        performCleanup = true;
    }

    console.log("Is performCleanup set: " + performCleanup);

    // we already saved their values, so we can return them back to default now
    installer.setValue("isSilent", "false");
    installer.setValue("performCleanup", "false");

    if (systemInfo.productType == "windows") {
        setProgramDataDirectory();
    }
}

function onPackageManagerCoreTypeChanged()
{
    if (installer.isInstaller() == false) {
        if (installer.isUpdater()) {
            console.log("[GUI] Is Updater");
        } else if (installer.isPackageManager()) {
            console.log("[GUI] Is Package Manager");
        } else if (installer.isUninstaller()) {
            console.log("[GUI] Is Uninstaller");
        }
    }
}

Controller.prototype.IntroductionPageCallback = function()
{
    console.log("[GUI] IntroductionPageCallback entered");
    let widget = gui.currentPageWidget();
    if (widget != null) {
        if (installer.isInstaller()) {
            if (systemInfo.productType == "windows") {
                widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                        + "This will install the following on your computer: \n"
                                        + "  1) Strata Developer Studio\n"
                                        + "  2) Host Controller Service\n"
                                        + "  3) Libraries and Components\n"
                                        + "  4) Third-party Utilities\n\n"
                                        + "It is recommended that you close all other applications before continuing.\n\n"
                                        + "Click Next to continue, or Quit to exit Setup."
                                        );
            } else {
                widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                        + "This will install the following on your computer: \n"
                                        + "  1) Strata Developer Studio\n"
                                        + "  2) Host Controller Service\n"
                                        + "  3) Libraries and Components\n\n"
                                        + "It is recommended that you close all other applications before continuing.\n\n"
                                        + "Click Next to continue."
                                        );
            }
        } else {
            widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                    + "Please choose one of the available options, then click Next to continue.\n\n"
                                    + "It is recommended that you close all other applications before continuing.\n\n"
                                    );

            // in case the complete uninstallation is chosen, ignore cleanup
            if (isSilent && performCleanup && (installer.isUninstaller() == false)) {
                let packageManagerRadioButton = widget.findChild("PackageManagerRadioButton");
                if (packageManagerRadioButton != null) {
                    packageManagerRadioButton.setChecked(true);
                } else {
                    console.log("Error: unable to acquire PackageManagerRadioButton");
                }
            }   
        }
    }

    if (isSilent) {
        gui.clickButton(buttons.NextButton, 1000);
    }
}

function acquireCleanupOperations()
{
    console.log("acquireCleanupOperations entered");

    if (installer.isInstaller() || installer.isUninstaller()) {
        return;
    }

    if (installer.fileExists(installer.value("TargetDir")) == false) {
        console.log("No TargetDir '" + installer.value("TargetDir") + "' found");
        return;
    }

    let target_dir = installer.value("TargetDir") + "/";
    if (systemInfo.productType == "windows") {
        target_dir = target_dir.split("/").join("\\");
    }
    let cleanupFile = target_dir + "cleanup.txt";

    if (installer.fileExists(cleanupFile) == false) {
        console.log("No cleanup.txt file found");
        return;
    }

    console.log("Found cleanup.txt: " + cleanupFile + ", parsing...");

    let content = installer.readFile(cleanupFile, "UTF-8");
    if (content == "") {
        console.log("Empty cleanup.txt, nothing to cleanup");
        return;
    }

    let cleanupAvailable = false;
    let lines = content.split('\n');
    componentsToClean = [];
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
}

Controller.prototype.TargetDirectoryPageCallback = function ()
{
    console.log("[GUI] TargetDirectoryPageCallback entered");
    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.ComponentSelectionPageCallback = function ()
{
    console.log("[GUI] ComponentSelectionPageCallback entered");
    let widget = gui.currentPageWidget();
    if (widget != null) {
        if (isSilent) {
            // select the ui components
            if (performCleanup) {
                acquireCleanupOperations();
                for (let i = 0; i < componentsToClean.length; i++) {
                    widget.deselectComponent(componentsToClean[i]);
                }
            } else {
                widget.selectAll();
                //widget.selectComponent("com.onsemi.strata.devstudio");
            }
            gui.clickButton(buttons.NextButton);
        }
    }
}

Controller.prototype.LicenseAgreementPageCallback = function ()
{
    console.log("[GUI] LicenseAgreementPageCallback entered");
    if (isSilent) {
        let widget = gui.currentPageWidget();
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
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.StartMenuDirectoryPageCallback = function ()
{
    console.log("[GUI] StartMenuDirectoryPageCallback entered");
    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.ReadyForInstallationPageCallback = function ()
{
    console.log("[GUI] ReadyForInstallationPageCallback entered");
    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.PerformInstallationPageCallback = function ()
{
    console.log("[GUI] PerformInstallationPageCallback entered");
    //if (isSilent) {
    //    gui.clickButton(buttons.CommitButton);
    //}
}

function getProgramDataDirectory()
{
    let programDataShortcut = installer.value("RootDir").split("/").join("\\") + "\\ProgramData";
    console.log("default ProgramData path: " + programDataShortcut);
    try {
        let programDataFolder = installer.execute("cmd", ["/c", "echo", "%ProgramData%"]);
        // the output of command is the first item, and the return code is the second
        if ((programDataFolder != undefined) && (programDataFolder != null) && (programDataFolder[0] != undefined) && (programDataFolder[0] != null) && (programDataFolder[0] != "")) {
            programDataShortcut = programDataFolder[0].trim();
            console.log("detected ProgramData path: " + programDataShortcut);
        } else {
            console.log("unable to detect correct ProgramData path, trying default one: " + programDataShortcut);
        }
    } catch(e) {
        console.log("error while detecting correct ProgramData path, trying default one: " + programDataShortcut);
        console.log(e);
    }
    return programDataShortcut;
}

Controller.prototype.InstallationPerformed = function ()
{
    console.log("InstallationPerformed entered");

    if (installer.isInstaller() && (installer.status == QInstaller.Success)) {
        let home_dir = installer.value("HomeDir");
        if (systemInfo.productType == "windows") {
            home_dir = home_dir.split("/").join("\\");
            let prod_database = home_dir + "\\AppData\\Roaming\\onsemi\\Host Controller Service\\PROD\\strata_db.cblite2"
            if (installer.fileExists(prod_database)) {
                installer.execute("cmd", ["/c", "rd", "/s", "/q", prod_database]);  // erases all files inside
            }
        } else if (systemInfo.productType == "osx") {
            let prod_database = home_dir + "/Library/Application Support/onsemi/Host Controller Service/PROD/strata_db.cblite2"
            if (installer.fileExists(prod_database)) {
                installer.execute("rm", ["-r", prod_database]); // erases all files inside
            }
        }
    }
    if (installer.isUninstaller() && (installer.status == QInstaller.Success)) {
        let home_dir = installer.value("HomeDir");
        if (systemInfo.productType == "windows") {
            home_dir = home_dir.split("/").join("\\");

            let ini_dir = home_dir + "\\AppData\\Roaming\\onsemi";
            if (installer.fileExists(ini_dir + "\\Host Controller Service.ini")) {
                installer.execute("cmd", ["/c", "del", "/q", ini_dir + "\\Host Controller Service.ini"]);
            }
            if (installer.fileExists(ini_dir + "\\Strata Developer Studio.ini")) {
                installer.execute("cmd", ["/c", "del", "/q", ini_dir + "\\Strata Developer Studio.ini"]);
            }
            if (installer.fileExists(ini_dir + "\\desktop.ini")) {
                installer.execute("cmd", ["/c", "del", "/q", "/a:h", ini_dir + "\\desktop.ini"]);           // erases hidden file in case it was created
            }
            if (installer.fileExists(ini_dir + "\\Host Controller Service")) {
                installer.execute("cmd", ["/c", "rd", "/s", "/q", ini_dir + "\\Host Controller Service"]);  // erases all files inside
            }
            if (installer.fileExists(ini_dir + "\\Strata Developer Studio")) {
                installer.execute("cmd", ["/c", "rd", "/s", "/q", ini_dir + "\\Strata Developer Studio"]);  // erases all files inside
            }
            if (installer.fileExists(ini_dir)) {
                installer.execute("cmd", ["/c", "rd", "/q", ini_dir]);  // erases only if it was empty
            }

            let config_dir = getProgramDataDirectory()+ "\\onsemi";
            if (installer.fileExists(config_dir + "\\desktop.ini")) {
                installer.execute("cmd", ["/c", "del", "/q", "/a:h", config_dir + "\\desktop.ini"]);    // erases hidden file in case it was created
            }
            if (installer.fileExists(config_dir)) {
                installer.execute("cmd", ["/c", "rd", "/q", config_dir]);                               // erases only if it was empty
            }
        } else if (systemInfo.productType == "osx") {
            let ini_dir = home_dir + "/.config/onsemi";
            if (installer.fileExists(ini_dir + "/Host Controller Service.ini")) {
                installer.execute("rm", ["-f", ini_dir + "/Host Controller Service.ini"]);
            }
            if (installer.fileExists(ini_dir + "/Strata Developer Studio.ini")) {
                installer.execute("rm", ["-f", ini_dir + "/Strata Developer Studio.ini"]);
            }
            if (installer.fileExists(ini_dir + "/.DS_Store")) {
                installer.execute("rm", ["-f", ini_dir + "/.DS_Store"]);    // in case it was created
            }
            if (installer.fileExists(ini_dir)) {
                installer.execute("rm", ["-f", "-d", ini_dir]);             // erases only if it was empty
            }

            let log_dir = home_dir + "/Library/Application Support/onsemi";
            if (installer.fileExists(log_dir + "/Host Controller Service")) {
                installer.execute("rm", ["-f", "-r", log_dir + "/Host Controller Service"]);    // erases all files inside
            }
            if (installer.fileExists(log_dir + "/Strata Developer Studio")) {
                installer.execute("rm", ["-f", "-r", log_dir + "/Strata Developer Studio"]);    // erases all files inside
            }
            if (installer.fileExists(log_dir + "/.DS_Store")) {
                installer.execute("rm", ["-f", log_dir + "/.DS_Store"]);    // in case it was created
            }
            if (installer.fileExists(log_dir)) {
                installer.execute("rm", ["-f", "-d", log_dir]);             // erases only if it was empty
            }
        }
    }

    if (isSilent) {
        let widget = gui.pageById(QInstaller.PerformInstallation);
        let widget_cmp = gui.currentPageWidget();
        if (widget === widget_cmp) {
            console.log("InstallationPerformed clicking next button");
            gui.clickButton(buttons.NextButton, 2000);    // timer to avoid double clicking
        }
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

Controller.prototype.FinishedPageCallback = function ()
{
    console.log("[GUI] FinishedPageCallback entered");
    let widget = gui.currentPageWidget();
    if (widget != null) {
        widget.MessageLabel.setText("onsemi\n\n"
                                    + "Thank you for using onsemi. If you have any questions or in need of support, please contact your local sales representative.\n\n"
                                    + "Copyright " + (new Date().getFullYear()) + "\n\n"
                                    );
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

    let restart_maintenance_tool = false;
    if (isSilent) {
        if (installer.isUpdater() && (installer.status == QInstaller.Success) && (performCleanup == false)) {
            // after update, we can do cleanup if available
            acquireCleanupOperations();
            if (componentsToClean.length > 0) {
                performCleanup = true;  // when it restarts, it retains all variables
                restart_maintenance_tool = true;
            }
        }

        gui.clickButton(restart_maintenance_tool ? buttons.CommitButton : buttons.FinishButton);
    }
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

Controller.prototype.DynamicShortcutCheckBoxWidgetCallback = function()
{
    console.log("[GUI] DynamicShortcutCheckBoxWidgetCallback entered");
    let widget = gui.currentPageWidget();
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
        }
        let startMenuCheckBox = widget.findChild("startMenuCheckBox");
        if (startMenuCheckBox != null) {
            startMenuCheckBox.setChecked(installer.value("add_start_menu_shortcut", "true") == "true");
        }
    }

    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}
