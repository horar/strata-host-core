function Component() {}

Component.prototype.beginInstallation = function()
{
    if (systemInfo.productType == "windows") {
        component.addStopProcessForUpdateRequest(installer.value("TargetDir").split("/").join("\\") + "\\Strata Developer Studio.exe");
        component.addStopProcessForUpdateRequest(installer.value("TargetDir").split("/").join("\\") + "\\hcs.exe");
    }

    // call default implementation
    component.beginInstallation();
}
