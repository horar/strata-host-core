// Emacs mode hint: -*- mode: JavaScript -*-

function Controller() {
    gui.setSilent(true);

    installer.autoRejectMessageBoxes();
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.FinishButton);
    })
}

function cancelInstaller(message)
{
    // skip all pages and go directly to finished page
    installer.setDefaultPageVisible(QInstaller.Introduction, false);
    installer.setDefaultPageVisible(QInstaller.TargetDirectory, false);
    installer.setDefaultPageVisible(QInstaller.ComponentSelection, false);
    installer.setDefaultPageVisible(QInstaller.ReadyForInstallation, false);
    installer.setDefaultPageVisible(QInstaller.StartMenuSelection, false);
    installer.setDefaultPageVisible(QInstaller.PerformInstallation, false);
    installer.setDefaultPageVisible(QInstaller.LicenseCheck, false);
}

Controller.prototype.WelcomePageCallback = function() {
    // click delay here because the next button is initially disabled for ~1 second
    gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.CredentialsPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
    var widget = gui.currentPageWidget();
    var button = widget.findChild("PackageManagerRadioButton");
    button.setChecked(true);

    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function()
{
    gui.currentPageWidget().TargetDirectoryLineEdit.setText(installer.value("HomeDir") + "/On Semiconductor");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    var widget = gui.currentPageWidget();

    //widget.deselectAll();

    // if (installer.value("os") == "win") { }
    // if (installer.value("os") == "win") {
    // }

    widget.selectComponent("tech.spyglass.strata.views.view1");
    //widget.selectComponent("qt.55.gcc_64");
    //widget.selectComponent("qt.55.qtquickcontrols");

    // widget.deselectComponent("qt.tools.qtcreator");
    // widget.deselectComponent("qt.55.qt3d");
    // widget.deselectComponent("qt.55.qtcanvas3d");
    // widget.deselectComponent("qt.55.qtlocation");
    // widget.deselectComponent("qt.55.qtquick1");
    // widget.deselectComponent("qt.55.qtscript");
    // widget.deselectComponent("qt.55.qtwebengine");
    // widget.deselectComponent("qt.extras");
    // widget.deselectComponent("qt.tools.doc");
    // widget.deselectComponent("qt.tools.examples");

    if (gui.isButtonEnabled(buttons.NextButton) == false) {
        //gui.clickButton(buttons.CancelButton);
        //abortInstaller();
        cancelInstaller();
        return;
    }
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
console.log("====> Ready for installation");
    gui.clickButton(buttons.NextButton);
}

// LC added
Controller.prototype.PerformInstallationPageCallback = function() {
console.log("====> Perform installation")
//    log("PerformInstallationPageCallback");
    gui.clickButton(buttons.CommitButton);
}
// LC end

Controller.prototype.FinishedPageCallback = function() {
var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm;
//if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
//    checkBoxForm.launchQtCreatorCheckBox.checked = false;
//}
console.log("====> Finished");
    gui.clickButton(buttons.FinishButton);//, 3000);
}

//Controller.prototype.RestartPageCallback = function() {
//console.log("====> Restart");
//    //gui.clickButton(buttons.FinishButton);//, 3000);
//    gui.clickButton(buttons.CancelButton, 3000);
//}
