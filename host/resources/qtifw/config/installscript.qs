var isSilent = (installer.value('isSilent') && installer.isInstaller());

function Controller()
{
    if (isSilent) {
        installer.autoRejectMessageBoxes();
        installer.installationFinished.connect(function () {
            gui.clickButton(buttons.NextButton);
        })
    }
}

Controller.prototype.IntroductionPageCallback = function()
{
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
        widget.deselectAll();
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
    if (isSilent)
        gui.clickButton(buttons.FinishButton);
}
