var isSilent = false;

function isValueSet(val)
{
    return ((installer.containsValue(val) == true) && ((installer.value(val).toLowerCase() == "true") || (installer.value(val) == "1")));
}

function Controller()
{
    if (isValueSet("isSilent") == true) {
        isSilent = true;
        installer.setValue("isSilent_internal","true");
    } else {
        installer.setValue("isSilent_internal","false");
    }

    console.log("Is isSilent set: " + isSilent);

    if (isSilent == true) {
        installer.installationFinished.connect(Controller.prototype.InstallationPerformed);
        installer.uninstallationFinished.connect(Controller.prototype.InstallationPerformed);

        // do not use this or it will be impossible to cancel the installer
        //installer.autoRejectMessageBoxes();
        //installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
        //installer.setMessageBoxAutomaticAnswer("stopProcessesForUpdates", QMessageBox.Ignore);
    }

    try {
        var widget = gui.pageById(QInstaller.Introduction); // get the introduction wizard page
        if (widget != null) {
            widget.packageManagerCoreTypeChanged.connect(onPackageManagerCoreTypeChanged);
        }
    } catch(e) {
        console.log("Controller: unable to access gui: " + e);
    }

    // we already saved their values, so we can return them back to default now
    installer.setValue("isSilent", "false");
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

    if (isSilent == true) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.WelcomePageCallback = function ()
{
    console.log("[GUI] WelcomePageCallback entered");
    if (isSilent == true) {
        gui.clickButton(buttons.NextButton, 3000);
    }
}

Controller.prototype.TargetDirectoryPageCallback = function ()
{
    console.log("[GUI] TargetDirectoryPageCallback entered");
    if (isSilent == true) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.ComponentSelectionPageCallback = function ()
{
    console.log("[GUI] ComponentSelectionPageCallback entered");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        if (isSilent == true) {
            // select the ui components
            widget.selectAll();
            //widget.selectComponent("com.onsemi.strata.devstudio");
            gui.clickButton(buttons.NextButton);
        }
    }
}

Controller.prototype.LicenseAgreementPageCallback = function ()
{
    console.log("[GUI] LicenseAgreementPageCallback entered");
    if (isSilent == true) {
        var widget = gui.currentPageWidget();
        if (widget != null) {
            var licenseCheckBox = widget.findChild("AcceptLicenseCheckBox");
            if (licenseCheckBox != null) {
                licenseCheckBox.setChecked(true);
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
    if (isSilent == true) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.PerformInstallationPageCallback = function ()
{
    console.log("[GUI] PerformInstallationPageCallback entered");
    //if (isSilent == true) {
    //    gui.clickButton(buttons.CommitButton);
    //}
}

Controller.prototype.InstallationPerformed = function ()
{
    console.log("InstallationPerformed entered");
    if (isSilent == true) {
        var widget = gui.pageById(QInstaller.PerformInstallation);
        var widget_cmp = gui.currentPageWidget();
        if (widget === widget_cmp) {
            console.log("InstallationPerformed clicking next button");
            gui.clickButton(buttons.NextButton, 2000);    // timer to avoid double clicking
        }
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

Controller.prototype.FinishedPageCallback = function ()
{
    console.log("[GUI] FinishedPageCallback entered");
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.MessageLabel.setText("ON Semiconductor\n\n"
                                    + "Thank you for using ON Semiconductor. If you have any questions or in need of support, please contact your local sales representative.\n\n"
                                    + "Copyright " + (new Date().getFullYear()) + "\n\n"
                                    );
        var runItCheckBox = widget.findChild("RunItCheckBox");
        if (runItCheckBox != null) {
            if ((installer.isUpdater() == true) && (installer.status == QInstaller.Success) && (isSilent == true) && (isComponentInstalled("com.onsemi.strata.devstudio") == true)) {
                runItCheckBox.setChecked(true);
            } else {
                runItCheckBox.setChecked(false);
            }
        }

        if ((installer.isInstaller() == true) && (installer.status != QInstaller.Success))
            installer.setValue("TargetDir", "");    // prohibit writing log into destination directory
    }

    if (isSilent == true) {
        gui.clickButton(buttons.FinishButton);
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

    if (isSilent == true) {
        gui.clickButton(buttons.NextButton);
    }
}
