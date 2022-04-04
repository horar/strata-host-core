/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
var isSilent = false;

function isValueSet(val)
{
    return (installer.containsValue(val) && ((installer.value(val).toLowerCase() == "true") || (installer.value(val) == "1")));
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

    let performCleanup = isValueSet("performCleanup");
    if (performCleanup) {
        installer.setValue("performCleanup_internal","true");
    } else {
        installer.setValue("performCleanup_internal","false");
    }

    console.log("Is performCleanup set: " + performCleanup);

    // we already saved their values, so we can return them back to default now
    installer.setValue("isSilent", "false");
    installer.setValue("performCleanup", "false");

    installer.installationFinished.connect(Controller.prototype.InstallationPerformed);
    installer.uninstallationFinished.connect(Controller.prototype.InstallationPerformed);
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
            if (isSilent && isValueSet("performCleanup_internal") && (installer.isUninstaller() == false)) {
                let packageManagerRadioButton = widget.findChild("PackageManagerRadioButton");
                if (packageManagerRadioButton != null) {
                    packageManagerRadioButton.setChecked(true);
                } else {
                    console.log("Error: unable to acquire PackageManagerRadioButton");
                }
            }   
        }
    } else {
        console.log("Error: unable to find IntroductionPage widget");
    }

    if (isSilent) {
        gui.clickButton(buttons.NextButton, 1000);
    }
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
    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}

Controller.prototype.LicenseAgreementPageCallback = function ()
{
    console.log("[GUI] LicenseAgreementPageCallback entered");
    if (isSilent) {
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

Controller.prototype.InstallationPerformed = function ()
{
    console.log("InstallationPerformed entered");

    if (isSilent) {
        let widget = gui.pageById(QInstaller.PerformInstallation);
        let widget_cmp = gui.currentPageWidget();
        if (widget === widget_cmp) {
            console.log("InstallationPerformed clicking next button");
            gui.clickButton(buttons.NextButton, 2000);    // timer to avoid double clicking
        }
    }
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
    } else {
        console.log("Error: unable to find FinishedPage widget");
    }

    if (isSilent) {
        let restart_maintenance_tool = isValueSet("restartMaintenanceTool");
        if (restart_maintenance_tool) {
            installer.setValue("restartMaintenanceTool", "false");
            // Note: the main Controller() function is no longer called when restarting Maintenance Tool
            // but all variables defined in header under var XXX and through installer.setValue() remain
        }
        gui.clickButton(restart_maintenance_tool ? buttons.CommitButton : buttons.FinishButton);
    }
}

Controller.prototype.DynamicShortcutCheckBoxWidgetCallback = function()
{
    console.log("[GUI] DynamicShortcutCheckBoxWidgetCallback entered");
    if (isSilent) {
        gui.clickButton(buttons.NextButton);
    }
}
