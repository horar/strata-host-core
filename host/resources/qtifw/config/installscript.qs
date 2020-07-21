var isSilent = (installer.value('isSilent') && installer.isInstaller());

function Controller()
{
    if (isSilent) {
        installer.autoRejectMessageBoxes();
        installer.setMessageBoxAutomaticAnswer("OverwriteTargetDirectory", QMessageBox.Yes);
        installer.setMessageBoxAutomaticAnswer("stopProcessesForUpdates", QMessageBox.Ignore);
        installer.installationFinished.connect(function () {
            gui.clickButton(buttons.NextButton);
        })
    }
    
    installer.setValue("add_start_menu_shortcut", "true");
    installer.setValue("add_desktop_shortcut", "false");
}

Controller.prototype.IntroductionPageCallback = function()
{
    if(installer.isInstaller()) {
        var widget = gui.currentPageWidget();
        if (widget != null) {
            widget.MessageLabel.setText("Welcome to the " + installer.value("Name") + " Setup Wizard.\n\n"
                                        + "This will install the following on your computer: \n"
                                        + "  1) Strata Developer Studio\n"
                                        + "  2) Microsoft VS 2017 Tools, Add-ONs and Extensions\n"
                                        + "  3) FTDI Driver\n\n"
                                        + "It is recommended that you close all other applications before continuing.\n\n"
                                        + "Click Next to continue, or Quit to exit Setup."
                                        );
        }
    }

    if (isSilent)
        gui.clickButton(buttons.NextButton);
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
    if (isSilent) {
        var widget = gui.currentPageWidget();

        // select the ui components
        widget.selectAll();
        //widget.selectComponent("com.onsemi.strata.devstudio");
        gui.clickButton(buttons.NextButton);
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
    //if (isSilent)
    //    gui.clickButton(buttons.CommitButton);
}

Controller.prototype.FinishedPageCallback = function () {
    var widget = gui.currentPageWidget();
    if (widget != null) {
        widget.MessageLabel.setText("ON Semiconductor\n\n"
                                    + "Thank you for using ON Semiconductor. If you have any questions or in need of support, please contact your local sales representative.\n\n"
                                    + "Copyright 2020\n\n"
                                    );
        if(installer.isInstaller() || installer.isUpdater()) {
            widget.RunItCheckBox.setChecked(false);        // does not works :/ must be done through component script later
        }
    }

    if (isSilent)
        gui.clickButton(buttons.FinishButton);
}
