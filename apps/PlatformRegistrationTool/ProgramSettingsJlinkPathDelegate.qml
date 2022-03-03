/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.theme 1.0

ProgramSettingsDelegate {
    id: delegate

    property string jlinkExePath
    property QtObject jlinkConnector
    property bool validationInProgress: false

    content: Item {
        height: pathEdit.y + pathEdit.height

        Connections {
            target: jlinkConnector
            enabled: validationInProgress

            onCheckHostVersionProcessFinished: {
                delegate.isBusy = false
                delegate.validationInProgress = false

                if (exitedNormally) {
                    var info = jlinkConnector.latestOutputInfo()

                    console.log("info", JSON.stringify(info))

                    if (info.hasOwnProperty("lib_version") && info.hasOwnProperty("commander_version")) {
                        pathEdit.commanderVersion = info["commander_version"]
                        pathEdit.libVersion = info["lib_version"]
                        pathEdit.setStateIsValid()
                    } else {
                       pathEdit.setStateIsInvalid('Cannot determine version')
                    }
                } else {
                     pathEdit.setStateIsInvalid('Validation process failed')
                }
            }
        }

        SGWidgets.SGFilePicker {
            id: pathEdit
            width: parent.width

            label: "SEGGER J-Link Commander executable (JLink.exe)"
            placeholderText: "Enter path..."
            inputValidation: false
            dialogLabel: "Select JLink Commander executable"
            dialogSelectExisting: true
            showValidationResultIcon: false
            contextMenuEnabled: true
            focus: true

            property string commanderVersion
            property string libVersion

            onActiveEditingChanged: {
                if (activeEditing) {
                    setStateIsUnknown()
                    delegate.isBusy = false
                    pathEdit.commanderVersion = ""
                    pathEdit.libVersion = ""
                } else {
                    delegate.isBusy = true
                    validateJlinkPath()
                }
            }

            onFilePathChanged: {
                delegate.jlinkExePath = filePath
            }

            Connections {
                target: delegate

                onAboutToShow: {
                    pathEdit.setStateIsUnknown()
                    pathEdit.commanderVersion = ""
                    pathEdit.libVersion = ""
                }

                onShowed: {
                    pathEdit.textFieldActiveEditingEnabled = false

                    if (pathEdit.filePath.length === 0) {
                        pathEdit.filePath = searchJLinkExePath()
                    } else  {
                        pathEdit.filePath = delegate.jlinkExePath
                    }

                    pathEdit.textFieldActiveEditingEnabled = true

                    if (pathEdit.filePath.length > 0) {
                        delegate.isBusy = true
                        validateWithDelayTimer.start()
                    }
                }
            }

            Binding {
                target: delegate
                property: "isSet"
                value: pathEdit.isValid
            }

            Timer {
                id: validateWithDelayTimer
                interval: 500
                onTriggered: {
                    pathEdit.validateJlinkPath()
                }
            }

            Row {
                x: pathEdit.textFieldX
                y: pathEdit.textFieldY + pathEdit.textFieldHeight + 2

                spacing: 4
                SGWidgets.SGTag {
                    color: TangoTheme.palette.chocolate1
                    text: {
                        if (pathEdit.commanderVersion.length) {
                            return "commander " + pathEdit.commanderVersion
                        }

                        return ""
                    }
                }

                SGWidgets.SGTag {
                    color: TangoTheme.palette.chocolate1
                    text: {
                        if (pathEdit.libVersion.length) {
                            return "library " + pathEdit.libVersion
                        }

                        return ""
                    }
                }
            }

            function validateJlinkPath() {
                delegate.validationInProgress = true

                var error = ""
                if (filePath.length === 0) {
                    error = "JLink Commander is required"
                } else if (!CommonCpp.SGUtilsCpp.isFile(filePath)) {
                    error = "JLink Commander is not a valid file"
                } else if(!CommonCpp.SGUtilsCpp.isExecutable(filePath)) {
                    error = "JLink Commander is not executable"
                }

                if (error.length) {
                    pathEdit.setStateIsInvalid(error)
                    delegate.isBusy = false
                    validationInProgress = false
                    return
                }

                jlinkConnector.exePath = filePath
                jlinkConnector.checkHostVersion()
            }
        }
    }

    function searchJLinkExePath() {
        var standardPathList = QtLabsPlatform.StandardPaths.standardLocations(
                    QtLabsPlatform.StandardPaths.ApplicationsLocation)

        if (Qt.platform.os == "windows") {
            standardPathList.push("file:///C:/Program Files (x86)")
        }

        var pathList = []

        for (var i =0 ; i < standardPathList.length; ++i) {
            var path = CommonCpp.SGUtilsCpp.urlToLocalFile(standardPathList[i])
            pathList.push(path)

            path = CommonCpp.SGUtilsCpp.joinFilePath(path, "SEGGER/JLink")
            pathList.push(path)
        }

        if (Qt.platform.os === "windows") {
            var exeName = "JLink"
        } else {
            exeName = "JLinkExe"
        }

        console.log(Logger.prtCategory, "exeName", exeName)
        console.log(Logger.prtCategory, "pathList", JSON.stringify(pathList))

        var url = QtLabsPlatform.StandardPaths.findExecutable(exeName, pathList)
        if (url && url.toString().length > 0) {
            url = CommonCpp.SGUtilsCpp.urlToLocalFile(url)
            console.log(Logger.prtCategory, "JLink exe path", url)
            return url
        } else {
            console.log(Logger.prtCategory, "JLink exe path could not be found")
        }

        return ""
    }
}
