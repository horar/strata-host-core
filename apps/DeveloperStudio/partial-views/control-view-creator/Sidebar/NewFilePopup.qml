import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: root
    modal: true
    visible: true
    headerText: "Add New File to Qrc"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 300
    height: 280
    anchors.centerIn: Overlay.overlay

    property var viewState: ""
    property bool fileCreateRequested: false

    onClosed: {
        viewState = ""
        qmlFilenameInfobox.text = ""
        otherFileTypeFilenameInfobox.text = ""
    }

    Connections {
        target: treeModel

        onFileAppeared: {
            if (root.fileCreateRequested) {
                treeModel.addToQrc(index)
            }

            root.fileCreateRequested = false
        }
    }

    contentItem: Item {
        id: column
        width: parent.width

        SGText {
            text: "Select File Type to Add:"
        }

        RowLayout {
            y: 20
            spacing: 5

            SGButton {
                text: "QML"
                onPressed: {
                    root.viewState = "QML"
                }
            }

            SGButton {
                text: "Other File Type"
                onPressed: {
                    root.viewState = "otherFileType"
                }
            }
        }

        Item {
            y: 70
            visible: root.viewState === "QML"
            Layout.fillWidth: true

            RowLayout {
                spacing: 0
                Layout.fillWidth: true

                SGText {
                    text: "File Name: "
                }

                SGInfoBox {
                    id: qmlFilenameInfobox
                    text: ""
                    implicitWidth: 175
                    readOnly: false
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: "filename"

                    onEditingFinished:{ }

                    onFocusChanged: { }
                }

                SGText {
                    text: ".qml"
                }
            }

            CheckBox {
                id: veEnabledFileCheckbox
                y: 40
                text: qsTr("Start with Visual Editor Enabled QML file")
                checked: false
                onCheckedChanged: { }
                padding: 0
            }

            SGText {
                y: 75
                text: veEnabledFileCheckbox.checked ? "A Visual-Editor ready QML file will be created" : "A base QML file will be created"
            }

            SGButton {
                id: qmlCreateFileButton
                y: 100
                text: "Create file"
                enabled: qmlFilenameInfobox.text !== ""
                
                onPressed: {
                    const filename = qmlFilenameInfobox.text + ".qml"
                    const url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filename)
                    const path = SGUtilsCpp.urlToLocalFile(url)
                    const parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(url))
                    root.fileCreateRequested = true
                    const success = treeModel.createQmlFile(path, veEnabledFileCheckbox.checked)
                    if (!success) {
                        console.error("Could not create file:", path)
                    } else {
                        openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                        root.close()
                    }
                }
            }

            MouseArea {
                id: qmlCreateFileButtonTooltip
                anchors.fill: parent
                hoverEnabled: true
                enabled: visible
                // visible: !qmlCreateFileButton.enabled
                visible: true

                ToolTip {
                    visible: true//qmlCreateFileButtonTooltip.containsMouse && !qmlCreateFileButton.enabled
                    text: {
                        var result = ""
                        if (qmlFilenameInfobox.text == "") {
                            result += (result === "" ? "" : "<br>")
                            result += "Project name is empty"
                        }
                        return result
                    }
                }
            }
        }

        Item {
            y: 70
            visible: root.viewState === "otherFileType"
            Layout.fillWidth: true

            RowLayout {
                spacing: 0
                Layout.fillWidth: true

                SGText {
                    text: "File Name: "
                }

                SGInfoBox {
                    id: otherFileTypeFilenameInfobox
                    text: ""
                    implicitWidth: 175
                    readOnly: false
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: "filename"

                    onEditingFinished:{ }

                    onFocusChanged: { }
                }
            }

            SGText {
                y: 75
                text: "An empty file will be created"
            }

            SGButton {
                id: otherFileTypeCreateFileButton
                y: 100
                text: "Create file"
                enabled: otherFileTypeFilenameInfobox.text !== ""
                
                onPressed: {
                    const filename = otherFileTypeFilenameInfobox.text
                    const url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filename)
                    const path = SGUtilsCpp.urlToLocalFile(url)
                    const parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(url))
                    root.fileCreateRequested = true
                    const success = treeModel.createEmptyFile(path, veEnabledFileCheckbox.checked)
                    if (!success) {
                        console.error("Could not create file:", path)
                    } else {
                        openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                        root.close()
                    }
                }
            }
        }
    }
}
