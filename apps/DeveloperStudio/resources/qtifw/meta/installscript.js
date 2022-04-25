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
    // call default implementation to actually install the content
    component.createOperations();

    let home_dir = installer.value("HomeDir");
    let target_dir = installer.value("TargetDir");
    if (systemInfo.productType == "windows") {
        target_dir = target_dir.split("/").join("\\");
        
        let cleanup_file = target_dir + "\\cleanup_sds.bat";
        home_dir = home_dir.split("/").join("\\");
        let ini_dir = home_dir + "\\AppData\\Roaming\\onsemi";
        let config_dir = getProgramDataDirectory()+ "\\onsemi";

        let file_content = '@echo off\n';
        let target_file = target_dir + "\\Offer of Source.txt"; // Strata module is erased first
        file_content += 'IF EXIST "' + target_file + '" EXIT /b 0\n';
        target_file = ini_dir + "\\Strata Developer Studio.ini";
        file_content += 'IF EXIST "' + target_file + '" del /q "' + target_file + '"\n';
        target_file = ini_dir + "\\desktop.ini";                // erases hidden file in case it was created
        file_content += 'IF EXIST "' + target_file + '" del /q /a:h "' + target_file + '"\n';
        target_file = ini_dir + "\\Strata Developer Studio";    // erases all files inside
        file_content += 'IF EXIST "' + target_file + '" rd /s /q "' + target_file + '"\n';
        target_file = ini_dir;                                  // erases only if it was empty
        file_content += 'IF EXIST "' + target_file + '" rd /q "' + target_file + '"\n';

        target_file = config_dir + "\\desktop.ini";             // erases hidden file in case it was created
        file_content += 'IF EXIST "' + target_file + '" del /q /a:h "' + target_file + '"\n';
        target_file = config_dir;                               // erases only if it was empty
        file_content += 'IF EXIST "' + target_file + '" rd /q "' + target_file + '"\n';
        file_content += 'EXIT /b 0\n';

        component.addOperation("AppendFile", cleanup_file, file_content);
        component.addOperation("Execute", "cmd", ["/c", "echo", "nothing to do"], "UNDOEXECUTE", "cmd", ["/c", cleanup_file]);

        let onsemiConfigFolder = getProgramDataDirectory() + "\\onsemi";
        let sdsConfigFolder = onsemiConfigFolder + "\\Strata Developer Studio";
        component.addOperation("Mkdir", sdsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", target_dir + "\\sds.config", sdsConfigFolder + "\\sds.config");
        component.addOperation("Delete", target_dir + "\\sds.config");

        if (installer.value("add_start_menu_shortcut", "true") == "true") {
            let strata_ds_shortcut_dst1 = "";
            let start_menu_folder = installer.value("StartMenuDir_internal");
            if ((start_menu_folder != "") && (start_menu_folder.endsWith("\\") == false)) {
                start_menu_folder += "\\";
            }
            if (installer.value("add_public_shortcuts", "true") == "true") {
                strata_ds_shortcut_dst1 = installer.value("AllUsersStartMenuProgramsPath").split("/").join("\\") + "\\" + start_menu_folder + "Strata Developer Studio.lnk";
                // will point to public Start Menu in this case
                component.addElevatedOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                                               "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
            } else {
                strata_ds_shortcut_dst1 = installer.value("UserStartMenuProgramsPath").split("/").join("\\") + "\\" + start_menu_folder + "Strata Developer Studio.lnk";
                component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst1,
                                       "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
            }
            console.log("will add Start Menu shortcut to: " + strata_ds_shortcut_dst1);
        }
        if (installer.value("add_desktop_shortcut", "true") == "true") {
            let desktop_path = "";
            if (installer.value("add_public_shortcuts", "true") == "true") {
                desktop_path = getSpecialFolderLocation("CommonDesktopDirectory");
            } else {
                desktop_path = getSpecialFolderLocation("DesktopDirectory");
            }
            if (desktop_path == "") {
                desktop_path = installer.value("DesktopDir");   // fallback
            }

            let strata_ds_shortcut_dst2 = desktop_path.split("/").join("\\") + "\\Strata Developer Studio.lnk";
            // workaround for Parallels https://bugreports.qt.io/browse/QTIFW-1106
            if (strata_ds_shortcut_dst2.indexOf("\\\\Mac") == 0) {
                console.log("MAC shortcut detected on Windows: " + strata_ds_shortcut_dst2 + ", correcting..");
                try {
                    let public_desktop_path = getSpecialFolderLocation("CommonDesktopDirectory"); // usually "C:\Users\Public\Desktop", but can be different (i.e. non-english OS)
                    if (public_desktop_path !== "") {
                        strata_ds_shortcut_dst2 = public_desktop_path + "\\Strata Developer Studio.lnk";
                        component.addElevatedOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                        console.log("will add Desktop shortcut to: " + strata_ds_shortcut_dst2);
                    } else {
                        console.log("unable to detect correct Public Desktop path");
                    }
                } catch(e) {
                    console.log("unable to detect correct Public Desktop path");
                    console.log(e);
                }
            } else {
                if (installer.value("add_public_shortcuts", "true") == "true") {
                    // will point to public Desktop in this case
                    component.addElevatedOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                } else {
                    component.addOperation("CreateShortcut", target_dir + "\\Strata Developer Studio.exe", strata_ds_shortcut_dst2,
                                        "workingDirectory=" + target_dir, "description=Open Strata Developer Studio");
                }
                console.log("will add Desktop shortcut to: " + strata_ds_shortcut_dst2);
            }
        }
    } else if (systemInfo.productType == "osx") {
        let cleanup_file = target_dir + "/cleanup_sds.sh";
        let ini_dir = home_dir + "/.config/onsemi";
        let log_dir = home_dir + "/Library/Application Support/onsemi";

        let file_content = '';
        let target_file = target_dir + "/Offer of Source.txt";  // Strata module is erased first
        file_content += 'if [ -f "' + target_file + '" ]; then exit 0; fi\n';
        target_file = ini_dir + "/Strata Developer Studio.ini";
        file_content += 'if [ -f "' + target_file + '" ]; then rm -f "' + target_file + '"; fi\n';
        target_file = ini_dir + "/.DS_Store";                   // in case it was created
        file_content += 'if [ -f "' + target_file + '" ]; then rm -f "' + target_file + '"; fi\n';
        target_file = ini_dir;                                  // erases only if it was empty
        file_content += 'if [ -d "' + target_file + '" ]; then rm -f -d "' + target_file + '"; fi\n';

        target_file = log_dir + "/Strata Developer Studio";
        file_content += 'if [ -d "' + target_file + '" ]; then rm -f -r "' + target_file + '"; fi\n';
        target_file = log_dir + "/.DS_Store";                   // in case it was created
        file_content += 'if [ -f "' + target_file + '" ]; then rm -f "' + target_file + '"; fi\n';
        target_file = log_dir;                                  // erases only if it was empty
        file_content += 'if [ -d "' + target_file + '" ]; then rm -f -d "' + target_file + '"; fi\n';
        file_content += 'exit 0\n';

        component.addOperation("AppendFile", cleanup_file, file_content);
        component.addOperation("Execute", "echo", ["nothing to do"], "UNDOEXECUTE", "sh", [cleanup_file]);
    }
}

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

function getProgramDataDirectory()
{
    let programDataPath = installer.value("RootDir").split("/").join("\\") + "\\ProgramData";
    try {
        let programDataPathEnv = installer.environmentVariable("ProgramData");
        if (programDataPathEnv !== "") {
            programDataPath = programDataPathEnv;
            console.log("detected ProgramData path: " + programDataPath);
        } else {
            console.log("unable to detect correct ProgramData path, trying default one: " + programDataPath);
        }
    } catch(e) {
        console.log("error while detecting correct ProgramData path, trying default one: " + programDataPath);
        console.log(e);
    }

    return programDataPath;
}

function getSpecialFolderLocation(folder_name)
{
    var powerShellCommand = "[Environment]::GetFolderPath('" + folder_name + "')";
    
    console.log("executing powershell command '" + powerShellCommand + "'");
    var specialFolder = installer.execute("powershell.exe", ["-command", powerShellCommand]);

    // the output of command is the first item, and the return code is the second
    // console.log("execution result code: " + specialFolder[1] + ", result: '" + specialFolder[0] + "'");

    if ((specialFolder == null) || (specialFolder == undefined)) {
        console.log("Error: powershell command failed to execute");
        return "";
    }

    if ((specialFolder[0] == null) || (specialFolder[0] == undefined) || (specialFolder[0] == "")) {
        console.log("Error: powershell command failed to return valid output:", specialFolder);
        return "";
    }

    if ((specialFolder[1] == null) || (specialFolder[1] == undefined) || (specialFolder[1] != 0)) {
        console.log("Error: powershell command returned bad exit code:", specialFolder);
        return "";
    }

    var lines = specialFolder[0].split('\r\n');
    console.log("returning: " + lines[0]);
    return lines[0];
}
