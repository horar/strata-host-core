function Component() {}

Component.prototype.beginInstallation = function()
{
    if (systemInfo.productType == "windows") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "\\Strata Developer Studio.exe");
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "\\hcs.exe");
    } else if (systemInfo.productType == "osx") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/hcs");
    }

    // call default implementation
    component.beginInstallation();
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();

    if (systemInfo.productType == "windows") {
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
        var sdsConfigFolder = onsemiConfigFolder + "\\Strata Developer Studio";
        component.addOperation("Mkdir", sdsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", installer.value("TargetDir").split("/").join("\\") + "\\sds.config", sdsConfigFolder + "\\sds.config");
        component.addOperation("Delete", installer.value("TargetDir").split("/").join("\\") + "\\sds.config");

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

        var target_dir = installer.value("TargetDir").split("/").join("\\");
        if (installer.value("add_start_menu_shortcut", "true") == "true") {
            var strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";
            component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                                    "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
            console.log("will add Start Menu shortcut to: " + strata_ds_shortcut_dst1);
        }
        if (installer.value("add_desktop_shortcut", "true") == "true", "true") {
            var valid_shortcut = true;
            var strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";

            // workaround for Parallels https://bugreports.qt.io/browse/QTIFW-1106
            if (strata_ds_shortcut_dst2.indexOf("\\\\Mac") == 0) {
                console.log("MAC shortcut detected on Windows: " + strata_ds_shortcut_dst2 + ", correcting..");
                try {
                    var desktopFolder = installer.execute("cmd", ["/c", "echo", "%Public%\\Desktop"]);
                    // the output of command is the first item, and the return code is the second
                    if ((desktopFolder != undefined) && (desktopFolder != null) && (desktopFolder[0] != undefined) && (desktopFolder[0] != null) && (desktopFolder[0] != "")) {
                        strata_ds_shortcut_dst2 = desktopFolder[0].trim() + "\\Strata Developer Studio.lnk";
                        console.log("new desktop shortcut: " + strata_ds_shortcut_dst2);
                    } else {
                        console.log("unable to detect correct Desktop path");
                        valid_shortcut = false;
                    }
                } catch(e) {
                    console.log("unable to detect correct Desktop path");
                    console.log(e);
                    valid_shortcut = false;
                }
            }
            if (valid_shortcut == true) {
                component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                console.log("will add Desktop shortcut to: " + strata_ds_shortcut_dst2);
            }
        }
     }
}
