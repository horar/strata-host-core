/*
 * Copyright (c) 2018-2021 onsemi.
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
        var programDataShortcut = installer.value("RootDir").split("/").join("\\") + "ProgramData";
        console.log("default ProgramData path: " + programDataShortcut);
        try {
            var programDataFolder = installer.execute("cmd", ["/c", "echo", "%ProgramData%"]);
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
        var onsemiConfigFolder = programDataShortcut + "\\onsemi";
        var hcsConfigFolder = onsemiConfigFolder + "\\Strata Developer Studio\\HCS";
        component.addOperation("Mkdir", hcsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config", hcsConfigFolder + "\\hcs.config");
        component.addOperation("Delete", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config");

        if (installer.isInstaller() == true) {
            try {
                if (installer.gainAdminRights() == true) {
                    if (installer.fileExists(onsemiConfigFolder) == true) {
                        console.log("changing access rights for Strata config folder: " + onsemiConfigFolder);
                        installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/grant", "Users:(OI)(CI)(F)"]);
                        installer.execute("cmd", ["/c", "icacls", onsemiConfigFolder, "/setowner", "Users"]);
                    }
                    // do not drop admin rights in this function, will break installer
                    //installer.dropAdminRights();
                }
            } catch(e) {
                console.log("unable to change access rights for Strata config folder");
                console.log(e);
            }
        }
    }
}

Component.prototype.beginInstallation = function()
{
    if (systemInfo.productType == "windows") {
        var target_dir = installer.value("TargetDir").split("/").join("\\");
        component.addStopProcessForUpdateRequest(target_dir + "\\Strata Developer Studio.exe");
        component.addStopProcessForUpdateRequest(target_dir + "\\hcs.exe");
    } else if (systemInfo.productType == "osx") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/hcs");
    }

    // call default implementation
    component.beginInstallation();
}
