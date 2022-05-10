/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
function Component()
{
    installer.installationFinished.connect(this, Component.prototype.onInstallationOrUpdateFinished);   // called after installation, update and adding/removing components
}

Component.prototype.createOperations = function()
{
    // call default implementation
    component.createOperations();

    let home_dir = installer.value("HomeDir");
    let target_dir = installer.value("TargetDir");
    if( systemInfo.productType == "windows" ) {
        home_dir = home_dir.split("/").join("\\");
        target_dir = target_dir.split("/").join("\\");
        let cleanup_file = target_dir + "\\cleanup_hcs.bat";
        let ini_dir = home_dir + "\\AppData\\Roaming\\onsemi";
        let config_dir = getProgramDataDirectory() + "\\onsemi";

        let file_content = '@echo off\n';
        let target_file = target_dir + "\\Offer of Source.txt"; // Strata module is erased first
        file_content += 'IF EXIST "' + target_file + '" EXIT /b 0\n';
        target_file = ini_dir + "\\Host Controller Service.ini";
        file_content += 'IF EXIST "' + target_file + '" del /q "' + target_file + '"\n';
        target_file = ini_dir + "\\desktop.ini";                // erases hidden file in case it was created
        file_content += 'IF EXIST "' + target_file + '" del /q /a:h "' + target_file + '"\n';
        target_file = ini_dir + "\\Host Controller Service";    // erases all files inside
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
        
        let hcsConfigFolder = config_dir + "\\HCS";
        component.addOperation("Mkdir", hcsConfigFolder);
        // Do not use Move, because it will fail with error if file was deleted
        component.addOperation("Copy", target_dir + "\\hcs.config", hcsConfigFolder + "\\hcs.config");
        component.addOperation("Delete", target_dir + "\\hcs.config");
    } else if (systemInfo.productType == "osx") {
        let cleanup_file = target_dir + "/cleanup_hcs.sh";
        let ini_dir = home_dir + "/.config/onsemi";
        let log_dir = home_dir + "/Library/Application Support/onsemi";

        let file_content = '';
        let target_file = target_dir + "/Offer of Source.txt";  // Strata module is erased first
        file_content += 'if [ -f "' + target_file + '" ]; then exit 0; fi\n';
        target_file = ini_dir + "/Host Controller Service.ini";
        file_content += 'if [ -f "' + target_file + '" ]; then rm -f "' + target_file + '"; fi\n';
        target_file = ini_dir + "/.DS_Store";                   // in case it was created
        file_content += 'if [ -f "' + target_file + '" ]; then rm -f "' + target_file + '"; fi\n';
        target_file = ini_dir;                                  // erases only if it was empty
        file_content += 'if [ -d "' + target_file + '" ]; then rm -f -d "' + target_file + '"; fi\n';

        target_file = log_dir + "/Host Controller Service";
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

Component.prototype.onInstallationOrUpdateFinished = function()
{
    console.log("onInstallationOrUpdateFinished entered - HCS");

    if (installer.isInstaller() && (installer.status == QInstaller.Success)) {
        let home_dir = installer.value("HomeDir");
        if (systemInfo.productType == "windows") {
            home_dir = home_dir.split("/").join("\\");
            let prod_database = home_dir + "\\AppData\\Roaming\\onsemi\\Host Controller Service\\PROD\\strata_db.cblite2"
            if (installer.fileExists(prod_database)) {
                installer.execute("cmd", ["/c", "rd", "/s", "/q", prod_database]);  // erases all files inside
            }
        } else if (systemInfo.productType == "osx") {
            let prod_database = home_dir + "/Library/Application Support/onsemi/Host Controller Service/PROD/strata_db.cblite2"
            if (installer.fileExists(prod_database)) {
                installer.execute("rm", ["-r", prod_database]); // erases all files inside
            }
        }
    }
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
