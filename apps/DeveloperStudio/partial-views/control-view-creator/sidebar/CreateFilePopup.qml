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
import tech.strata.theme 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: createFilePopup
    modal: true
    headerText: "Add New File to Qrc"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 300
    height: 280
    anchors.centerIn: Overlay.overlay

    property var viewState: "QML" // "QML" or "otherFileType"
    property bool fileAddRequested: false
    property string directoryPath: ""

    onClosed: {
        filenameReqsPopup.close()
        viewState = "QML"
        directoryPath = ""
        filenameInfobox.text = ""
        veEnabledFileCheckbox.checked = false
    }

    Connections {
        target: treeModel
        onFileCreated: {
            if (createFilePopup.fileAddRequested) {
                treeModel.addToQrc(index)
                openFilesModel.addTab(filename, filepath, filetype, uid)
                treeView.selectItem(index)
            }

            createFilePopup.fileAddRequested = false
        }
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width

        SGText {
            text: "Select File Type to Add:"
        }

        RowLayout {
            SGButton {
                id: qmlViewButton
                text: "QML"
                checkable: true
                checked: createFilePopup.viewState == "QML"

                onClicked: {
                    createFilePopup.viewState = "QML"
                }
            }

            SGButton {
                id: otherFileTypeViewButton
                text: "Other File Type"
                checkable: true
                checked: createFilePopup.viewState == "otherFileType"

                onClicked: {
                    createFilePopup.viewState = "otherFileType"
                }
            }
        }

        ColumnLayout {
            implicitWidth: parent.width
            Layout.preferredHeight: 200

            RowLayout {
                id: filenameRow
                spacing: 0
                Layout.fillWidth: true

                SGText {
                    text: "File Name: "
                }

                SGInfoBox {
                    id: filenameInfobox
                    text: ""
                    implicitWidth: 212
                    readOnly: false
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: "File Name"
                    selectionColor: Theme.palette.onsemiOrange

                    onAccepted: {
                        if (createFileButton.enabled) {
                            createFileButton.clicked()
                        }
                    }
                }
            }

            CheckBox {
                id: veEnabledFileCheckbox
                text: qsTr("Start with Visual Editor Enabled QML file")
                visible: createFilePopup.viewState === "QML"
                checked: false
                palette.highlight: Theme.palette.onsemiOrange
            }

            SGText {
                text: veEnabledFileCheckbox.checked ? "A Visual-Editor ready QML file will be created" : "A base QML file will be created"
                visible: createFilePopup.viewState === "QML"
            }

            Item { // filler to match veEnabledFileCheckbox size
                Layout.fillWidth: true
                Layout.preferredHeight: veEnabledFileCheckbox.height
                visible: createFilePopup.viewState === "otherFileType"
            }

            SGText {
                text: "An empty file will be created"
                visible: createFilePopup.viewState === "otherFileType"
            }

            SGButton {
                id: createFileButton
                text: "Create File"
                enabled: filenameReqsPopup.filenameValid

                onClicked: {
                    let url
                    if (createFilePopup.directoryPath) {
                        url = SGUtilsCpp.joinFilePath(createFilePopup.directoryPath, filenameInfobox.text)
                    } else {
                        url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filenameInfobox.text)
                    }
                    const path = SGUtilsCpp.urlToLocalFile(url)
                    createFilePopup.fileAddRequested = true

                    let success
                    if (createFilePopup.viewState === "QML") {
                        success = treeModel.createQmlFile(path, veEnabledFileCheckbox.checked)
                    } else if (createFilePopup.viewState === "otherFileType") {
                        success = treeModel.createEmptyFile(path)
                    }

                    if (!success) {
                        console.error("Could not create file:", path)
                    } else {
                        createFilePopup.close()
                    }
                }
            }
        }
    }

    Popup {
        id: filenameReqsPopup
        parent: filenameRow
        width: filenameRow.width
        visible: filenameInfobox.focus && !filenameValid && createFilePopup.visible
        closePolicy: Popup.NoAutoClose
        y: filenameRow.height - 1
        background: Rectangle {
            border.color: "#cccccc"
            color: "#eee"
        }

        // Required for all file types
        property bool filenameAndExtensionValid: {
            if (createFilePopup.viewState === "QML") {
                return filenameInfobox.text.match(/^[a-zA-Z0-9_]*\.?[a-zA-Z0-9_]*$/) // QML filenames must not contain anything but alphanumeric and underscores
            } else if (createFilePopup.viewState === "otherFileType") {
                return filenameInfobox.text.match(/^[a-zA-Z0-9](?:[a-zA-Z0-9 ._-]*[a-zA-Z0-9])?\.[a-z0-9_-]+$/)
            }
        }

        property bool fileDoesNotExist: {
            let url
            if (createFilePopup.directoryPath) {
                url = SGUtilsCpp.joinFilePath(createFilePopup.directoryPath, filenameInfobox.text)
            } else {
                url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filenameInfobox.text)
            }
            const path = SGUtilsCpp.urlToLocalFile(url)
            return !treeModel.containsPath(path)
        }

        // Required for QML files
        property bool qmlFileBeginWithUppercaseLetter: filenameInfobox.text.match(/^[A-Z]/) // begins with A-Z
        property bool qmlFileEndWithQmlExtension: filenameInfobox.text.match(/^.*\.(qml)$/) // end in .qml

        property bool filenameValid: {
            if (createFilePopup.viewState === "QML") {
                // QML file name/ext must be valid, not already exist, begin w Uppercase letter, end w qml extension
                return filenameAndExtensionValid && fileDoesNotExist && qmlFileBeginWithUppercaseLetter && qmlFileEndWithQmlExtension
            } else if (createFilePopup.viewState === "otherFileType") {
                // Other file types name/ext must be valid, not already exist
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
                iconColor: filenameReqsPopup.filenameAndExtensionValid ? Theme.palette.success : "#cccccc"
                height: 20
                width: height
            }

            Text {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                text: {
                    if (createFilePopup.viewState === "QML") {
                        return "Contains only alphanumeric characters or underscores"
                    } else if (createFilePopup.viewState === "otherFileType") {
                        return "File name and extension are valid"
                    }
                }
            }

            SGIcon {
                visible: createFilePopup.viewState === "QML"
                source: filenameReqsPopup.qmlFileBeginWithUppercaseLetter ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.qmlFileBeginWithUppercaseLetter ? Theme.palette.success : "#cccccc"
                height: 20
                width: height
            }

            Text {
                visible: createFilePopup.viewState === "QML"
                text: "Begins with uppercase letter"
                Layout.fillWidth: true
            }

            SGIcon {
                visible: createFilePopup.viewState === "QML"
                source: filenameReqsPopup.qmlFileEndWithQmlExtension ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.qmlFileEndWithQmlExtension ? Theme.palette.success : "#cccccc"
                height: 20
                width: height
            }

            Text {
                visible: createFilePopup.viewState === "QML"
                text: "File has .qml extension"
                Layout.fillWidth: true
            }

            SGIcon {
                source: filenameReqsPopup.fileDoesNotExist ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: filenameReqsPopup.fileDoesNotExist ? Theme.palette.success : "#cccccc"
                height: 20
                width: height
            }

            Text {
                text: "File does not already exist"
                Layout.fillWidth: true
            }
        }
    }
}
