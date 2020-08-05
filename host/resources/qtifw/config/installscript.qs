var isSilent = false;
var startSDS = false;
var forcePackageManager = false;
var forceUpdate = false;
var forceUninstall = false;
var delayStart = 0;

function Controller()
{    
    if(installer.containsValue("isSilent") && ((installer.value("isSilent").toLowerCase() == "true") || (installer.value("isSilent") == "1"))) {
        isSilent = true;
        installer.setValue("isSilent_internal","true");
    } else
        installer.setValue("isSilent_internal","false");    // must be always overwritten, so it is ignored in persistency
    
    if(installer.containsValue("startSDS") && ((installer.value("startSDS").toLowerCase() == "true") || (installer.value("startSDS") == "1"))) {
        startSDS = true;
    }
    
    if(installer.containsValue("forcePackageManager") && ((installer.value("forcePackageManager").toLowerCase() == "true") || (installer.value("forcePackageManager") == "1"))) {
        forcePackageManager = true;
    }
    
    if(installer.containsValue("forceUpdate") && ((installer.value("forceUpdate").toLowerCase() == "true") || (installer.value("forceUpdate") == "1"))) {
        forceUpdate = true;
    }
    
    if(installer.containsValue("forceUninstall") && ((installer.value("forceUninstall").toLowerCase() == "true") || (installer.value("forceUninstall") == "1"))) {
        forceUninstall = true;
    }
    
    console.log("Is forcePackageManager set: " + forcePackageManager);
    console.log("Is forceUpdate set: " + forceUpdate);
    console.log("Is forceUninstall set: " + forceUninstall);
    console.log("Is isSilent set: " + isSilent);

    if (isSilent) {
        if(!installer.isInstaller()) {
            if(!forcePackageManager && !forceUpdate && !forceUninstall) {
                isSilent = false;
                installer.setValue("isSilent_internal","false");
                console.log("disabling isSilent");
            }
        }
    }

    if (isSilent) {
        installer.installationFinished.connect(function () {
            gui.clickButton(buttons.NextButton);
        })
                
        installer.updateFinished.connect(function () {
            gui.clickButton(buttons.NextButton);
        })
        
        installer.uninstallationFinished.connect(function () {
            gui.clickButton(buttons.NextButton);
        })

        // do not use this or it will be impossible to cancel the installer
        //installer.autoRejectMessageBoxes();
        //installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
        //installer.setMessageBoxAutomaticAnswer("stopProcessesForUpdates", QMessageBox.Ignore);

    }
    
    var widget = gui.pageById(QInstaller.Introduction); // get the introduction wizard page
    if (widget != null)
        widget.packageManagerCoreTypeChanged.connect(onPackageManagerCoreTypeChanged);

    if(installer.containsValue("delayStart") && installer.value("delayStart") != "0") {
        console.log("delayStart: " + installer.value("delayStart"));
        delayStart = parseInt(installer.value("delayStart")) || 0;
        if(delayStart < 0)
            delayStart = 0;
    }

    // restore all custom variables to defaults, because they are persistent through Strata Maintenance Tool.ini
    if(installer.isInstaller()) {
        // keep these as they were set unless it is installer
        installer.setValue("add_start_menu_shortcut", "true");
        installer.setValue("add_desktop_shortcut", "true");
    }
    installer.setValue("restart_is_required", "false");
    
    // we already saved their values, so we can return them back to default now
    installer.setValue("isSilent", "false");
    installer.setValue("forcePackageManager", "false");
    installer.setValue("forceUpdate", "false");
    installer.setValue("forceUninstall", "false");
    
    installer.setValue("delayStart", "0");
}

onPackageManagerCoreTypeChanged = function()
{
    console.log("Is Updater: " + installer.isUpdater());
    console.log("Is Uninstaller: " + installer.isUninstaller());
    console.log("Is Package Manager: " + installer.isPackageManager());
}

Controller.prototype.IntroductionPageCallback = function()
{
    var widget = gui.currentPageWidget();
    if (widget != null) {
        if(installer.isInstaller()) {
            widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                    + "This will install the following on your computer: \n"
                                    + "  1) Strata Developer Studio\n"
                                    + "  2) Microsoft VS 2017 Tools, Add-ONs and Extensions\n"
                                    + "  3) FTDI Driver\n\n"
                                    + "It is recommended that you close all other applications before continuing.\n\n"
                                    + "Click Next to continue, or Quit to exit Setup."
                                    );
        } else {
            widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                    + "Please choose one of the available options, then click Next to continue.\n\n"
                                    + "It is recommended that you close all other applications before continuing.\n\n"
                                    );
            var packageManagerRadioButton = widget.findChild("PackageManagerRadioButton");
            var updaterRadioButton = widget.findChild("UpdaterRadioButton");
            var uninstallerRadioButton = widget.findChild("UninstallerRadioButton");

            if(forcePackageManager && (packageManagerRadioButton != null)) {
                packageManagerRadioButton.show();
                packageManagerRadioButton.setChecked(true);
                if(updaterRadioButton != null)
                    updaterRadioButton.hide();
                if(uninstallerRadioButton != null)
                    uninstallerRadioButton.hide();
            }
            if(forceUpdate && (updaterRadioButton != null)) {
                updaterRadioButton.show();
                updaterRadioButton.setChecked(true);
                if(packageManagerRadioButton != null)
                    packageManagerRadioButton.hide();
                if(uninstallerRadioButton != null)
                    uninstallerRadioButton.hide();
            }
            if(forceUninstall && (uninstallerRadioButton != null)) {
                uninstallerRadioButton.show();
                uninstallerRadioButton.setChecked(true);
                if(packageManagerRadioButton != null)
                    packageManagerRadioButton.hide();
                if(updaterRadioButton != null)
                    updaterRadioButton.hide();
            }
        }
    }

    if (isSilent) {
        if(delayStart == 0)
            gui.clickButton(buttons.NextButton);
        else
            gui.clickButton(buttons.NextButton, delayStart);
    }
}

Controller.prototype.WelcomePageCallback = function () {
    if (isSilent)
        gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.TargetDirectoryPageCallback = function () {
    if (isSilent)
        gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function () {
    var widget = gui.currentPageWidget();
    if (widget != null) {
        if (isSilent) {
            // select the ui components
            widget.selectAll();
            //widget.selectComponent("com.onsemi.strata.devstudio");
            gui.clickButton(buttons.NextButton);
        }
    }
}

Controller.prototype.LicenseAgreementPageCallback = function () {
    if (isSilent) {
        gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.StartMenuDirectoryPageCallback = function () {
    if (isSilent)
        gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function () {
    if (isSilent)
        gui.clickButton(buttons.NextButton);
}

Controller.prototype.PerformInstallationPageCallback = function () {
    if (isSilent)
        gui.clickButton(buttons.CommitButton);
}

Controller.prototype.FinishedPageCallback = function () {
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.MessageLabel.setText("ON Semiconductor\n\n"
                                    + "Thank you for using ON Semiconductor. If you have any questions or in need of support, please contact your local sales representative.\n\n"
                                    + "Copyright 2020\n\n"
                                    );
        if(installer.isInstaller() || installer.isUpdater() || installer.isPackageManager()) {
            if(installer.containsValue("RunProgram") && (installer.value("RunProgram") != ""))
                widget.RunItCheckBox.setChecked(startSDS);
        }
    }

    if (isSilent)
        gui.clickButton(buttons.FinishButton);
}

Controller.prototype.DynamicShortcutCheckBoxWidgetCallback = function()
{
    console.log("DynamicShortcutCheckBoxWidgetCallback called");
    
    var install_SDS = true;
    var component = installer.componentByName("com.onsemi.strata.devstudio");
    if(component != null) {
        console.log("component com.onsemi.strata.devstudio found, installation requested: " + component.installationRequested());
        if (!component.installationRequested())
            install_SDS = false;
    } else {
        console.log("component com.onsemi.strata.devstudio NOT found");
    }

	var widget = gui.currentPageWidget();
	if (widget != null) {
		var desktopCheckBox = widget.findChild("desktopCheckBox");
		if(desktopCheckBox != null) {
			if(install_SDS == true) {
				desktopCheckBox.show();
				desktopCheckBox.setChecked(installer.value("add_desktop_shortcut") == "true");
			} else {
				desktopCheckBox.hide();
				desktopCheckBox.setChecked(installer.value("add_desktop_shortcut") == "false");
			}
		}
		var startMenuCheckBox = widget.findChild("startMenuCheckBox");
		if(startMenuCheckBox != null)
			startMenuCheckBox.setChecked(installer.value("add_start_menu_shortcut") == "true");
	}

    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}

