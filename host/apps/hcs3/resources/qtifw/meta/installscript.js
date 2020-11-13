function Component() {}

Component.prototype.createOperations = function()
{
    // call default implementation
    component.createOperations();

    if( systemInfo.productType == "windows" ) {
        var programDataShortcut = installer.value("RootDir").split("/").join("\\") + "ProgramData\\ON Semiconductor\\Strata Developer Studio\\HCS";
        console.log("default ProgramData path: " + programDataShortcut);
        try {
            var programDataFolder = installer.execute("cmd", ["/c", "echo", "%ProgramData%"]);
            // the output of command is the first item, and the return code is the second
            if ((programDataFolder != undefined) && (programDataFolder != null) && (programDataFolder[0] != undefined) && (programDataFolder[0] != null) && (programDataFolder[0] != "")) {
                programDataShortcut = programDataFolder[0].trim() + "\\ON Semiconductor\\Strata Developer Studio\\HCS";
                console.log("detected ProgramData path: " + programDataShortcut);
            } else {
                console.log("unable to detect correct ProgramData path, trying default one: " + programDataShortcut);
            }
        } catch(e) {
            console.log("unable to detect correct ProgramData path, trying default one: " + programDataShortcut);
            console.log(e);
        }

        component.addOperation("Mkdir", programDataShortcut);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config", programDataShortcut + "\\hcs.config");
        component.addOperation("Delete", installer.value("TargetDir").split("/").join("\\") + "\\hcs.config");
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
