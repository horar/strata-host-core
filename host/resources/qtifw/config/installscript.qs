function Controller()
{
    try {
        if(installer.isCommandLineInstance() == false) {
            var widget = gui.pageById(QInstaller.Introduction); // get the introduction wizard page
            if (widget != null) {
                widget.packageManagerCoreTypeChanged.connect(onPackageManagerCoreTypeChanged);
            }
        }
    } catch(e) {
        console.log("Controller: unable to access gui: " + e);
    }
}

onPackageManagerCoreTypeChanged = function()
{
    console.log("[GUI] Is Updater: " + installer.isUpdater());
    console.log("[GUI] Is Uninstaller: " + installer.isUninstaller());
    console.log("[GUI] Is Package Manager: " + installer.isPackageManager());
}

Controller.prototype.IntroductionPageCallback = function()
{
    console.log("[GUI] IntroductionPageCallback entered");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        if (installer.isInstaller() == true) {
            if (systemInfo.productType == "windows") {
                widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                        + "This will install the following on your computer: \n"
                                        + "  1) Strata Developer Studio\n"
                                        + "  2) Host Controller Service\n"
                                        + "  3) Microsoft VS 2017 Tools, Add-ONs and Extensions\n"
                                        + "  4) FTDI Driver\n\n"
                                        + "It is recommended that you close all other applications before continuing.\n\n"
                                        + "Click Next to continue, or Quit to exit Setup."
                                        );
            } else {
                widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                        + "This will install the following on your computer: \n"
                                        + "  1) Strata Developer Studio\n"
                                        + "  2) Host Controller Service\n\n"
                                        + "It is recommended that you close all other applications before continuing.\n\n"
                                        + "Click Next to continue."
                                        );
            }
        } else {
            widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                    + "Please choose one of the available options, then click Next to continue.\n\n"
                                    + "It is recommended that you close all other applications before continuing.\n\n"
                                    );
        }
    }
}

Controller.prototype.WelcomePageCallback = function ()
{
    console.log("[GUI] WelcomePageCallback entered");
}

Controller.prototype.TargetDirectoryPageCallback = function ()
{
    console.log("[GUI] TargetDirectoryPageCallback entered");
}

Controller.prototype.ComponentSelectionPageCallback = function ()
{
    console.log("[GUI] ComponentSelectionPageCallback entered");
}

Controller.prototype.LicenseAgreementPageCallback = function ()
{
    console.log("[GUI] LicenseAgreementPageCallback entered");
}

Controller.prototype.StartMenuDirectoryPageCallback = function ()
{
    console.log("[GUI] StartMenuDirectoryPageCallback entered");
}

Controller.prototype.ReadyForInstallationPageCallback = function ()
{
    console.log("[GUI] ReadyForInstallationPageCallback entered");
}

Controller.prototype.PerformInstallationPageCallback = function ()
{
    console.log("[GUI] PerformInstallationPageCallback entered");
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

Controller.prototype.FinishedPageCallback = function ()
{
    console.log("[GUI] FinishedPageCallback entered");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.MessageLabel.setText("ON Semiconductor\n\n"
                                    + "Thank you for using ON Semiconductor. If you have any questions or in need of support, please contact your local sales representative.\n\n"
                                    + "Copyright " + (new Date().getFullYear()) + "\n\n"
                                    );
        if (((installer.isInstaller() == true) || (installer.isUpdater() == true) || (installer.isPackageManager() == true)) && (installer.status == QInstaller.Success)) {
            var runItCheckBox = widget.findChild("RunItCheckBox");
            if ((runItCheckBox != null) && isComponentInstalled("com.onsemi.strata.devstudio") == true) {
                runItCheckBox.setChecked(startSDS);
            }
        }
        if ((installer.isInstaller() == true) && (installer.status != QInstaller.Success))
            installer.setValue("TargetDir", "");    // prohibit writing log into destination directory
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

    var component = installer.componentByName(component_name);
    if (component != null) {
        var available = component.installationRequested() || component.updateRequested() || (component.isInstalled() && !component.uninstallationRequested());
        console.log("component '" + component_name + "' found and is available: " + available);
        return available;
    }

    console.log("component '" + component_name + "' NOT found");
    return false;
}

Controller.prototype.DynamicShortcutCheckBoxWidgetCallback = function()
{
    console.log("[GUI] DynamicShortcutCheckBoxWidgetCallback entered");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        var desktopCheckBox = widget.findChild("desktopCheckBox");
        if (desktopCheckBox != null) {
            if (isComponentAvailable("com.onsemi.strata.devstudio") == true) {
                desktopCheckBox.setEnabled(true);
                desktopCheckBox.setChecked(installer.value("add_desktop_shortcut", "true") == "true");
            } else {
                desktopCheckBox.setEnabled(false);
                desktopCheckBox.setChecked(false);
            }
        }
        var startMenuCheckBox = widget.findChild("startMenuCheckBox");
        if (startMenuCheckBox != null) {
            startMenuCheckBox.setChecked(installer.value("add_start_menu_shortcut", "true") == "true");
        }
    }
}
