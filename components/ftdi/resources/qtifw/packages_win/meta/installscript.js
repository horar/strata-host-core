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

    // Install FTDI
    // status code 512 means succefull installaion
    // status code 2 means succefull installation with a device plugged in
    component.addElevatedOperation("Execute", "{2,512}", installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\FTDI\\dpinst-amd64.exe", "/S", "/SE", "/F");
}
