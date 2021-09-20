import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/partial-views"

SGStrataPopup {
    id: createFolderPopup
    modal: true
    headerText: "Create New Folder"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 300
    height: 200
    anchors.centerIn: Overlay.overlay

    property string folderPath: ""

    onClosed: {
        folderReqsPopup.close()
        folderPath = ""
        folderNameInfobox.text = ""
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width

        ColumnLayout {
            implicitWidth: parent.width
            Layout.preferredHeight: 200

            RowLayout {
                id: folderNameRow
                spacing: 0
                Layout.fillWidth: true

                SGText {
                    text: "Folder Name: "
                }

                SGInfoBox {
                    id: folderNameInfobox
                    text: ""
                    implicitWidth: 175
                    readOnly: false
                    enabled: true
                    contextMenuEnabled: true
                    placeholderText: "Folder Name"

                    onAccepted: {
                        if (createFolderButton.enabled) {
                            createFolderButton.clicked()
                        }
                    }
                }
            }

            SGText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: folderNameInfobox.text == "" ? "grey" : "black"

                text: {
                    if (createFolderPopup.folderPath) {
                        return "Full Path: " + SGUtilsCpp.urlToLocalFile(SGUtilsCpp.joinFilePath(createFolderPopup.folderPath, folderNameInfobox.text))
                    }
                    return "Full Path: " + SGUtilsCpp.urlToLocalFile(SGUtilsCpp.joinFilePath(treeModel.projectDirectory, folderNameInfobox.text))
                }
            }

            SGButton {
                id: createFolderButton
                text: "Create Folder"
                enabled: folderReqsPopup.folderValid && folderNameInfobox.text != ""

                onClicked: {
                    let url
                    if (createFolderPopup.folderPath) {
                        url = SGUtilsCpp.joinFilePath(createFolderPopup.folderPath, folderNameInfobox.text)
                    } else {
                        url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, folderNameInfobox.text)
                    }
                    const path = SGUtilsCpp.urlToLocalFile(url)
                    const success = treeModel.createNewFolder(path)
                    if (!success) {
                        console.error("Could not create folder:", path)
                    } else {
                        createFolderPopup.close()
                    }
                }
            }
        }
    }

    Popup {
        id: folderReqsPopup
        parent: folderNameRow
        width: folderNameRow.width
        visible: folderNameInfobox.focus && !folderValid && createFolderPopup.visible
        closePolicy: Popup.NoAutoClose
        y: folderNameRow.height - 1
        background: Rectangle {
            border.color: "#cccccc"
            color: "#eee"
        }

        property bool folderNameValid: {
            // Directory name must not be whitespace-only and must contain only alphanumeric/underscore/hyphen/space/period
            return folderNameInfobox.text.trim() && folderNameInfobox.text.match(/^[a-zA-Z0-9-_\. ]+$/)
        }

        property bool folderDoesNotExist: {
            let url
            if (createFolderPopup.folderPath) {
                url = SGUtilsCpp.joinFilePath(createFolderPopup.folderPath, folderNameInfobox.text)
            } else {
                url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, folderNameInfobox.text)
            }
            const path = SGUtilsCpp.urlToLocalFile(url)
            return folderNameInfobox.text == "" || !treeModel.containsPath(path)
        }

        property bool folderValid: folderNameValid && folderDoesNotExist

        GridLayout {
            id: requirementsGrid
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            width: folderReqsPopup.width - folderReqsPopup.padding * 2

            SGIcon {
                source: folderReqsPopup.folderNameValid ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: folderReqsPopup.folderNameValid ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                text: "Contains only alphanumeric characters, hyphens, periods, spaces, or underscores"
            }

            SGIcon {
                source: folderReqsPopup.folderDoesNotExist ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                iconColor: folderReqsPopup.folderDoesNotExist ? "#30c235" : "#cccccc"
                height: 20
                width: height
            }

            Text {
                text: "Folder does not already exist"
                Layout.fillWidth: true
            }
        }
    }
}
