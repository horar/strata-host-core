/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: renameFilePopup
    modal: true
    headerText: "Rename " + renameType
    closePolicy: Popup.CloseOnEscape
    focus: true
    implicitWidth: 300
    anchors.centerIn: Overlay.overlay

    property var renameType: "File" // "File" or "Folder"
    property var modelIndex
    property string uid: ""
    property string fileName: ""
    property string fileBaseName: ""
    property string fileExtension: ""
    property string directoryPath: ""

    onFileNameChanged: {
        if (fileName !== "") {
            fileBaseName = SGUtilsCpp.fileBaseName(fileName)
            newFilenameInfobox.text = fileBaseName
        }
    }

    onClosed: {
        filenameReqsPopup.close()
        fileName = ""
        fileBaseName = ""
        fileExtension = ""
        directoryPath = ""
        uid = ""
        newFilenameInfobox.text = ""
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width
        height: 150

        SGText {
            text: "Renaming <i>" + fileName + "</i><br><br>to <i>" + newFilenameInfobox.text + (fileExtension === "" ? "" : ("." + fileExtension)) + "</i>"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        RowLayout {
            id: newFilenameRow
            spacing: 0
            Layout.fillWidth: true

            SGText {
                text: "New " + renameType + " Name: "
            }

            SGInfoBox {
                id: newFilenameInfobox
                implicitWidth: renameType === "File" ? 180 : 165
                readOnly: false
                enabled: true
                contextMenuEnabled: true

                onAccepted: {
                    if (renameFileButton.enabled) {
                        renameFileButton.clicked()
                    }
                }
            }
        }

        SGButton {
            id: renameFileButton
            text: "Rename " + renameType
            enabled: filenameReqsPopup.filenameValid && newFilenameInfobox.text !== fileBaseName

            onClicked: {
                let parentDir
                if (directoryPath) {
                    parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(directoryPath))
                } else {
                    parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(treeModel.projectDirectory))
                }

                const newFileName = newFilenameInfobox.text + (fileExtension === "" ? "" : ("." + fileExtension))
                const url = SGUtilsCpp.joinFilePath(parentDir, newFileName)

                treeModel.stopWatchingPath(parentDir)

                const success = treeModel.renameFile(modelIndex, newFileName)
                if (success) {
                    if (openFilesModel.hasTab(uid)) {
                        openFilesModel.updateTab(uid, newFileName, url, fileExtension)
                    } else if (renameType === "Folder") {
                        handleRenameForOpenFiles(treeModel.getNode(modelIndex))
                    }
                }

                treeModel.startWatchingPath(parentDir)

                if (!success) {
                    console.error("Could not rename file:", SGUtilsCpp.urlToLocalFile(url))
                } else {
                    renameFilePopup.close()
                }
            }
        }
    }

    Popup {
        id: filenameReqsPopup
        parent: newFilenameRow
        width: newFilenameRow.width
        visible: newFilenameInfobox.focus && !filenameValid && renameFilePopup.visible
        closePolicy: Popup.NoAutoClose
        y: newFilenameRow.height - 1
        background: Rectangle {
            border.color: "#cccccc"
            color: "#eee"
        }

        // Required for all file types
        property bool filenameAndExtensionValid: {
            if (renameFilePopup.renameType === "File" && renameFilePopup.fileExtension === "qml") {
                // QML filenames must not contain anything but alphanumeric and underscores
                return newFilenameInfobox.text.match(/^[a-zA-Z0-9_]+$/)
            } else {
                // Other file types/folders name must be valid, not already exist
                return newFilenameInfobox.text.match(/^[a-zA-Z0-9-_\. ]+$/)
            }
        }

        property bool fileDoesNotExist: {
            let parentDir
            if (renameFilePopup.directoryPath) {
                parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(renameFilePopup.directoryPath))
            } else {
                parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(treeModel.projectDirectory))
            }

            const newFileName = newFilenameInfobox.text + (renameFilePopup.fileExtension === "" ? "" : ("." + renameFilePopup.fileExtension))
            const path = SGUtilsCpp.joinFilePath(parentDir, newFileName)
            return !treeModel.containsPath(path)
        }

        // Required for QML files
        property bool qmlFileBeginWithUppercaseLetter: newFilenameInfobox.text.match(/^[A-Z]/) // begins with A-Z

        property bool filenameValid: {
            if (renameFilePopup.renameType === "File" && renameFilePopup.fileExtension === "qml") {
                // QML file name/ext must be valid, not already exist, begin w Uppercase letter
                return filenameAndExtensionValid && fileDoesNotExist && qmlFileBeginWithUppercaseLetter
            } else {
                // Other file types/folders name/ext must be valid, not already exist
                return filenameAndExtensionValid && fileDoesNotExist
            }
        }

        GridLayout {
            id: requirementsGrid
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            width: filenameReqsPopup.width - filenameReqsPopup.padding * 2

            SGIcon {
                source: filenameReqsPopup.filenameAndExtensionValid ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.filenameAndExtensionValid ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                text: {
                    if (renameFilePopup.renameType === "File" && renameFilePopup.fileExtension === "qml") {
                        return "Contains only alphanumeric characters or underscores"
                    } else {
                        return renameFilePopup.renameType + " name is valid"
                    }
                }
            }

            SGIcon {
                visible: renameFilePopup.renameType === "File" && renameFilePopup.fileExtension === "qml"
                source: filenameReqsPopup.qmlFileBeginWithUppercaseLetter ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.qmlFileBeginWithUppercaseLetter ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                visible: renameFilePopup.renameType === "File" && renameFilePopup.fileExtension === "qml"
                text: "Begins with uppercase letter"
                Layout.fillWidth: true
            }

            SGIcon {
                source: filenameReqsPopup.fileDoesNotExist ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.fileDoesNotExist ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                text: renameFilePopup.renameType + " does not already exist"
                Layout.fillWidth: true
            }
        }
    }

    /**
      * This function handles when directories are renamed.
      * The purpose is to make sure that all open tabs that are underneath the directory are updated
     **/
    function handleRenameForOpenFiles(node) {
        for (let i = 0; i < node.childCount(); i++) {
            let childNode = node.childNode(i);
            if (childNode.isDir) {
                handleRenameForOpenFiles(childNode)
            } else if (openFilesModel.hasTab(childNode.uid)) {
                openFilesModel.updateTab(childNode.uid, childNode.filename, childNode.filepath, childNode.filetype)
            }
        }
    }
}
