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
    if (Component.prototype.isVCRedistInstalled() == false) {
        console.log("will install Microsoft Visual C++ 2017 X64 Additional Runtime libraries...");
        // status code 0 means succefull installaion
        // status code 1638 means VC already exist. Therefore, no need to show warnings.
        // status code 3010 means that the oporation is successful but a restart is required
        //component.addOperation("Execute", "{0,1638,3010}", installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\VC_REDIST\\vc_redist.x64.exe", "/install", "/quiet", "/norestart");

        // we need to do it like this to capture the exit code, so we know if we need to restart computer (it will be written in the vc_redist_out.txt)
        component.addElevatedOperation("Execute", "{0,1638,3010}", installer.value("TargetDir").split("/").join("\\") + "\\StrataUtils\\VC_REDIST\\run_vc_redist.bat");
    } else {
        console.log("Microsoft Visual C++ 2017 X64 Additional Runtime already installed");
    }
}

// Return 1 if a > b
// Return -1 if a < b
// Return 0 if a == b
function compare(a, b) {
    if (a === b) {
       return 0;
    }

    let a_components = a.split(".");
    let b_components = b.split(".");

    let len = Math.min(a_components.length, b_components.length);

    // loop while the components are equal
    for (let i = 0; i < len; i++) {
        // A bigger than B
        if (parseInt(a_components[i]) > parseInt(b_components[i])) {
            return 1;
        }

        // B bigger than A
        if (parseInt(a_components[i]) < parseInt(b_components[i])) {
            return -1;
        }
    }

    // If one's a prefix of the other, the longer one is greater.
    if (a_components.length > b_components.length) {
        return 1;
    }

    if (a_components.length < b_components.length) {
        return -1;
    }

    // Otherwise they are the same.
    return 0;
}

function getPowershellElement(str, element_name) {
    let res = [];
    let x = str.split('\r\n');
    let m = 0;
    for(let i = 0; i < x.length; i++){
        let n = x[i].indexOf(element_name);
        if (n == 0) {
            m = x[i].indexOf(": ", n + element_name.length);
            m += ": ".length;
            res.push(x[i].slice(m));
        } else if (m > 0) {
            if (x[i].charAt(0) == " ") {
                res[res.length-1] = res[res.length-1].concat(" " + x[i].slice(m));
            } else {
                m = 0;
            }
        }
    }

    return res;
}

function getWindowsDirectory()
{
    let windowsPath = installer.value("RootDir").split("/").join("\\") + "\\Windows";
    try {
        let windowsPathEnv = installer.environmentVariable("windir");
        if (windowsPathEnv !== "") {
            windowsPath = windowsPathEnv;
            console.log("detected Windows path: " + windowsPath);
        } else {
            console.log("unable to detect correct Windows path, trying default one: " + windowsPath);
        }
    } catch(e) {
        console.log("error while detecting correct Windows path, trying default one: " + windowsPath);
        console.log(e);
    }

    return windowsPath;
}

Component.prototype.isVCRedistInstalled = function()
{
    let programName = "Microsoft Visual C\\+\\+ 201[75](\\-\\d{4})? Redistributable \\(x64\\)";    // this is the correct program to be uninstalled
    let powerShellCommand = "(Get-ChildItem -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKLM:\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall, HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match '" + programName + "' })";
    let powershell64Location = getWindowsDirectory() + "\\SysNative\\WindowsPowerShell\\v1.0\\powershell.exe";
    if (installer.fileExists(powershell64Location) == false) {
        console.log("unable to locate 64bit powershell at " + powershell64Location);
        powershell64Location = "powershell.exe"; // use default one (32bit), which might not work as expected
    }

    console.log("executing powershell command '" + powerShellCommand + "'");
    // the installer is 32bit application :/ it will not find 64bit registry entries unless it is forced to open 64bit binary
    let isInstalled = installer.execute(powershell64Location, ["-command", powerShellCommand]);

    // the output of command is the first item, and the return code is the second
    // console.log("execution result code: " + isInstalled[1] + ", result: '" + isInstalled[0] + "'");

    if ((isInstalled[0] != null) && (isInstalled[0] != undefined) && (isInstalled[0] != "")) {
        let up_to_date = false;

        let display_name = getPowershellElement(isInstalled[0], 'DisplayName');
        let display_version = getPowershellElement(isInstalled[0], 'DisplayVersion');
        let uninstall_string = getPowershellElement(isInstalled[0], 'UninstallString');

        console.log("found DisplayName: '" + display_name + "', DisplayVersion: '" + display_version + "', UninstallString: '" + uninstall_string + "'");

        // we should not find multiple entries here, but just in case, check the highest
        if ((display_name.length != 0) && ((display_name.length == display_version.length) && (display_name.length == uninstall_string.length))) {
            for (let i = 0; i < display_version.length; i++) {

                let result = compare(display_version[i], component.value("Version").split('-')[0]);    // example "14.16.27033"

                if (result == 1) {
                    up_to_date = true;
                    console.log("program is newer version, DisplayVersion: '" + display_version[i] + "', MyVersion: '" + component.value("Version") + "'");
                } else if (result == 0) {
                    up_to_date = true;
                    console.log("program is the same version, DisplayVersion: '" + display_version[i] + "', MyVersion: '" + component.value("Version") + "'");
                } else {
                    console.log("program is older, will replace with new version if newer is not available, DisplayVersion: '" + display_version[i] + "', MyVersion: '" + component.value("Version") + "'");

                    // do not uninstall vcredist, it might cause issue, just let the updater do its job and hope it works correctly
                    //console.log("executing VCRedist uninstall command: '" + uninstall_string[i] + "'");
                    //let e = installer.execute(uninstall_string[i], ["/norestart", "/quiet"]);
                    //console.log(e);
                }
            }
        }

        return up_to_date;
    } else {
        console.log("program not found, will install new version");
        return false;
    }
}
