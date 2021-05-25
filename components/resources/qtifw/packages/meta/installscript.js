function Component() {}

Component.prototype.beginInstallation = function()
{
    if (systemInfo.productType == "windows") {
        var target_dir = installer.value("TargetDir").split("/").join("\\");
        component.addStopProcessForUpdateRequest(target_dir + "\\Strata Developer Studio.exe");
    } else if (systemInfo.productType == "osx") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir") + "/Strata Developer Studio.app/Contents/MacOS/Strata Developer Studio");
    }

    // call default implementation
    component.beginInstallation();
}
