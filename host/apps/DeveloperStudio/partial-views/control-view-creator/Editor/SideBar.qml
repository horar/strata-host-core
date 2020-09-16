import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.2
import Qt.labs.folderlistmodel 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4

import tech.strata.sgwidgets 1.0

Rectangle {
    id: sideBarRoot
    color: "#777"

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 5
            leftMargin: 5
            rightMargin: 5
        }

        SGText {
            Layout.fillWidth: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            id: qrcFilesText
            text: "QRC Files:"
            fontSizeMultiplier: 1.5
            color: "white"
        }

        Rectangle {
            id: scrollView
            Layout.fillWidth: true
            Layout.preferredHeight: 600
            clip: true

            SGFileSystemModel {
                id: fileTreeView
                rootDirectory: SGUtilsCpp.urlToLocalFile(fileModel.projectDirectory)
            }

            TreeView {
                anchors.fill: parent
                rootIndex: fileTreeView.rootIndex
                model: fileTreeView
                alternatingRowColors: false
                backgroundVisible: false

                itemDelegate: Item {
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: "black"
                        elide: Text.ElideRight
                        text: styleData.value
                    }
                }

                TableViewColumn {
                    title: "Name"
                    role: "fileName"
                    width: 200
                }
            }

        }

        SGButton {
            id: newFileButton
            Layout.fillWidth: true
            Layout.topMargin: 20
            text: "New file..."

            onClicked: {
                newFileDialog.open()
            }
        }

        SGButton {
            id: existingFileButton
            Layout.fillWidth: true
            Layout.topMargin: 20
            text: "Add existing file to QRC..."
            onClicked: {
                existingFileDialog.open()
            }
        }

        FileDialog {
            id: existingFileDialog
            nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
            selectExisting: true
            selectMultiple: true
            folder: fileModel.projectDirectory

            onAccepted: {
                for (let i = 0; i < fileUrls.length; i++) {
                    fileModel.append(fileUrls[i])
                }
            }
        }

        FileDialog {
            id: newFileDialog
            nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
            selectExisting: false
            folder: fileModel.projectDirectory

            onAccepted: {
                fileModel.append(fileUrl);
                // Handle the case where user adds a new file to a different directory
                folder = fileModel.projectDirectory
            }

            onRejected: {
                folder = fileModel.projectDirectory
            }
        }
    }
}
