import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0

ProgramSettingsDelegate {
    id: delegate

    property string jlinkExePath

    content: Item {
        height: pathEdit.y + pathEdit.height

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

            onActiveEditingChanged: {
                if (activeEditing) {
                    setStateIsUnknown()
                } else {
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
                }

                onShowed: {
                    if (pathEdit.filePath.length === 0) {
                        pathEdit.filePath = searchJLinkExePath()
                    }

                    if (pathEdit.filePath.length > 0) {
                        validateWithDelayTimer.start()
                    }
                }
            }

            Binding {
                target: pathEdit
                property: "filePath"
                value: delegate.jlinkExePath
            }

            Binding {
                target: delegate
                property: "isSet"
                value: pathEdit.isValid
            }

            Timer {
                id: validateWithDelayTimer
                interval: 1000
                onTriggered: pathEdit.validateJlinkPath()
            }

            function validateJlinkPath() {
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
                } else {
                    pathEdit.setStateIsValid()
                }
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
