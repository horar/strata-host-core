function Component() {}

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
