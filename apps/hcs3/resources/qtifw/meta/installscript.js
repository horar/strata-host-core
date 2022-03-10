/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
function Component() {}

Component.prototype.createOperations = function()
{
    // call default implementation
    component.createOperations();

    if( systemInfo.productType == "windows" ) {
        let onsemiConfigFolder = installer.value("ProgramDataDir") + "\\onsemi";
        let hcsConfigFolder = onsemiConfigFolder + "\\HCS";
        component.addOperation("Mkdir", hcsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config", hcsConfigFolder + "\\hcs.config");
        component.addOperation("Delete", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config");
    }
}

Component.prototype.beginInstallation = function()
{
    if (systemInfo.productType == "windows") {
        let target_dir = installer.value("TargetDir").split("/").join("\\");
        component.addStopProcessForUpdateRequest(target_dir + "\\Strata Developer Studio.exe");
        component.addStopProcessForUpdateRequest(target_dir + "\\hcs.exe");
    } else if (systemInfo.productType == "osx") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/hcs");
    }

    // call default implementation
    component.beginInstallation();
}
