/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
function Component() {}

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

Component.prototype.createOperations = function()
{
    // call default implementation to actually install the content
    component.createOperations();

    if (systemInfo.productType == "windows") {
        let onsemiConfigFolder = installer.value("ProgramDataDir") + "\\onsemi";
        let sdsConfigFolder = onsemiConfigFolder + "\\Strata Developer Studio";
        component.addOperation("Mkdir", sdsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", installer.value("TargetDir").split("/").join("\\") + "\\sds.config", sdsConfigFolder + "\\sds.config");
        component.addOperation("Delete", installer.value("TargetDir").split("/").join("\\") + "\\sds.config");

        let target_dir = installer.value("TargetDir").split("/").join("\\");
        if (installer.value("add_start_menu_shortcut", "true") == "true") {
            let strata_ds_shortcut_dst1 = installer.value("StartMenuDir") + "\\Strata Developer Studio.lnk";
            component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                                    "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
            console.log("will add Start Menu shortcut to: " + strata_ds_shortcut_dst1);
        }
        if (installer.value("add_desktop_shortcut", "true") == "true", "true") {
            let strata_ds_shortcut_dst2 = installer.value("DesktopDir") + "\\Strata Developer Studio.lnk";
            // workaround for Parallels https://bugreports.qt.io/browse/QTIFW-1106
            if (strata_ds_shortcut_dst2.indexOf("\\\\Mac") == 0) {
                console.log("MAC shortcut detected on Windows: " + strata_ds_shortcut_dst2 + ", correcting..");
                try {
                    let desktopFolder = installer.execute("cmd", ["/c", "echo", "%Public%\\Desktop"]);
                    // the output of command is the first item, and the return code is the second
                    if ((desktopFolder != undefined) && (desktopFolder != null) && (desktopFolder[0] != undefined) && (desktopFolder[0] != null) && (desktopFolder[0] != "")) {
                        strata_ds_shortcut_dst2 = desktopFolder[0].trim() + "\\Strata Developer Studio.lnk";
                        component.addElevatedOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                        console.log("will add Desktop shortcut to: " + strata_ds_shortcut_dst2);
                    } else {
                        console.log("unable to detect correct Desktop path");
                    }
                } catch(e) {
                    console.log("unable to detect correct Desktop path");
                    console.log(e);
                }
            } else {
                component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                console.log("will add Desktop shortcut to: " + strata_ds_shortcut_dst2);
            }
        }
    }
}
