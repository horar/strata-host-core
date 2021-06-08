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

    property var viewState: "QML"
    property bool fileCreateRequested: false

    onClosed: {
        viewState = "QML"
        qmlFilenameInfobox.text = ""
        otherFileTypeFilenameInfobox.text = ""
    }

    Connections {
        target: treeModel

        onFileCreated: {
            if (root.fileCreateRequested) {
                treeModel.addToQrc(index)
                openFilesModel.addTab(filename, filepath, filetype, uid)
                treeView.selectItem(index)
            }

            root.fileCreateRequested = false
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
                checked: root.viewState == "QML"

                onClicked: {
                    root.viewState = "QML"
                }
            }

            SGButton {
                id: otherFileTypeViewButton
                text: "Other File Type"
                checkable: true
                checked: root.viewState == "otherFileType"

                onClicked: {
                    root.viewState = "otherFileType"
                }
            }
        }

        ColumnLayout {
            id: qmlViewContainer
            visible: root.viewState === "QML"
            implicitWidth: parent.width
            implicitHeight: 200

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
                }

                SGText {
                    text: ".qml"
                }
            }

            CheckBox {
                id: veEnabledFileCheckbox
                text: qsTr("Start with Visual Editor Enabled QML file")
                checked: false
                padding: 0
            }

            SGText {
                text: veEnabledFileCheckbox.checked ? "A Visual-Editor ready QML file will be created" : "A base QML file will be created"
            }

            Item {
                id: qmlCreateFileButtonContainer
                implicitHeight: qmlCreateFileButton.implicitHeight
                implicitWidth: qmlCreateFileButton.implicitWidth

                SGButton {
                    id: qmlCreateFileButton
                    text: "Create file"
                    enabled: qmlFilenameInfobox.text !== ""

                    onClicked: {
                        const filename = qmlFilenameInfobox.text + ".qml"
                        const url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filename)
                        const path = SGUtilsCpp.urlToLocalFile(url)
                        const parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(url))
                        root.fileCreateRequested = true
                        const success = treeModel.createQmlFile(path, veEnabledFileCheckbox.checked)
                        if (!success) {
                            console.error("Could not create file:", path)
                        } else {
                            root.close()
                        }
                    }
                }

                MouseArea {
                    id: qmlCreateFileButtonTooltip
                    anchors.fill: qmlCreateFileButtonContainer

                    hoverEnabled: visible
                    enabled: visible
                    visible: qmlCreateFileButton.enabled === false

                    ToolTip {
                        visible: qmlCreateFileButtonTooltip.containsMouse
                        z: 1
                        text: {
                            var result = ""
                            if (qmlFilenameInfobox.text == "") {
                                result += (result === "" ? "" : "<br>")
                                result += "File name is empty"
                            }
                            return result
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: otherFileTypeViewContainer
            visible: root.viewState === "otherFileType"
            implicitWidth: parent.width
            implicitHeight: 200

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
                }
            }

            SGText {
                text: "An empty file will be created"
            }

            Item {
                id: otherFileTypeCreateFileButtonContainer
                implicitHeight: otherFileTypeCreateFileButton.implicitHeight
                implicitWidth: otherFileTypeCreateFileButton.implicitWidth

                SGButton {
                    id: otherFileTypeCreateFileButton
                    text: "Create file"
                    enabled: otherFileTypeFilenameInfobox.text !== ""

                    onClicked: {
                        const filename = otherFileTypeFilenameInfobox.text
                        const url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, filename)
                        const path = SGUtilsCpp.urlToLocalFile(url)
                        const parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(url))
                        root.fileCreateRequested = true
                        const success = treeModel.createEmptyFile(path, veEnabledFileCheckbox.checked)
                        if (!success) {
                            console.error("Could not create file:", path)
                        } else {
                            root.close()
                        }
                    }
                }

                MouseArea {
                    id: otherFileTypeCreateFileButtonTooltip
                    anchors.fill: otherFileTypeCreateFileButtonContainer
                    hoverEnabled: visible
                    enabled: visible
                    visible: otherFileTypeCreateFileButton.enabled === false

                    ToolTip {
                        visible: otherFileTypeCreateFileButtonTooltip.containsMouse
                        z: 1
                        text: {
                            var result = ""
                            if (otherFileTypeFilenameInfobox.text == "") {
                                result += (result === "" ? "" : "<br>")
                                result += "File name is empty"
                            }
                            return result
                        }
                    }
                }
            }
        }
    }
}
