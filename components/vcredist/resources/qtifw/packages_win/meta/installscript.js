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

    // Install Microsoft Visual C++ 2017 X64 Additional Runtime
    // status code 0 means succefull installaion
    // status code 1638 means VC already exist. Therefore, no need to show warnings.
    // status code 3010 means that the oporation is successful but a restart is required

    // we need to do it like this to capture the exit code, so we know if we need to restart computer (it will be written in the vc_redist_out.txt)
    component.addElevatedOperation("Execute", "{0,1638,3010}", installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\VC_REDIST\\run_vc_redist.bat");
}
