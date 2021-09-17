import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: createDirectoryPopup
    modal: true
    headerText: "Create New Directory"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 300
    height: 200
    anchors.centerIn: Overlay.overlay

    property string directoryPath: ""

    onClosed: {
        directoryReqsPopup.close()
        directoryPath = ""
        directoryNameInfobox.text = ""
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width

        ColumnLayout {
            implicitWidth: parent.width
            Layout.preferredHeight: 200

            RowLayout {
                id: directoryNameRow
                spacing: 0
                Layout.fillWidth: true

                SGText {
                    text: "Directory Name: "
                }

                SGInfoBox {
                    id: directoryNameInfobox
                    text: ""
                    implicitWidth: 175
                    readOnly: false
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: "Directory Name"

                    onAccepted: {
                        if (createDirectoryButton.enabled) {
                            createDirectoryButton.clicked()
                        }
                    }
                }
            }

            SGText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: directoryNameInfobox.text == "" ? "grey" : "black"

                text: {
                    if (createDirectoryPopup.directoryPath) {
                        return "Full Path: " + SGUtilsCpp.urlToLocalFile(SGUtilsCpp.joinFilePath(createDirectoryPopup.directoryPath, directoryNameInfobox.text))
                    }
                    return "Full Path: " + SGUtilsCpp.urlToLocalFile(SGUtilsCpp.joinFilePath(treeModel.projectDirectory, directoryNameInfobox.text))
                }
            }

            SGButton {
                id: createDirectoryButton
                text: "Create Directory"
                enabled: directoryReqsPopup.directoryValid && directoryNameInfobox.text != ""

                onClicked: {
                    let url
                    if (createDirectoryPopup.directoryPath) {
                        url = SGUtilsCpp.joinFilePath(createDirectoryPopup.directoryPath, directoryNameInfobox.text)
                    } else {
                        url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, directoryNameInfobox.text)
                    }
                    const path = SGUtilsCpp.urlToLocalFile(url)
                    const success = treeModel.createNewDirectory(path)
                    if (!success) {
                        console.error("Could not create directory:", path)
                    } else {
                        createDirectoryPopup.close()
                    }
                }
            }
        }
    }

    Popup {
        id: directoryReqsPopup
        parent: directoryNameRow
        width: directoryNameRow.width
        visible: directoryNameInfobox.focus && !directoryValid && createDirectoryPopup.visible
        closePolicy: Popup.NoAutoClose
        y: directoryNameRow.height - 1
        background: Rectangle {
            border.color: "#cccccc"
            color: "#eee"
        }

        property bool directoryNameValid: {
            return directoryNameInfobox.text.match(/^[a-zA-Z0-9_]*\.?[a-zA-Z0-9_]*$/) // Directory name must not contain anything but alphanumeric and underscores
        }

        property bool directoryDoesNotExist: {
            let url
            if (createDirectoryPopup.directoryPath) {
                url = SGUtilsCpp.joinFilePath(createDirectoryPopup.directoryPath, directoryNameInfobox.text)
            } else {
                url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, directoryNameInfobox.text)
            }
            const path = SGUtilsCpp.urlToLocalFile(url)
            return !treeModel.containsPath(path)
        }

        property bool directoryValid: directoryNameValid && directoryDoesNotExist

        GridLayout {
            id: requirementsGrid
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            width: directoryReqsPopup.width - directoryReqsPopup.padding * 2

            SGIcon {
                source: directoryReqsPopup.directoryNameValid ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: directoryReqsPopup.directoryNameValid ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                text: "Contains only alphanumeric characters or underscores"
            }

            SGIcon {
                source: directoryReqsPopup.directoryDoesNotExist ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: directoryReqsPopup.directoryDoesNotExist ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                text: "Directory does not already exist"
                Layout.fillWidth: true
            }
        }
    }
}
