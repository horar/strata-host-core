import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import Qt.labs.folderlistmodel 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: sideBarRoot
    color: "#777"

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: treeViewContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 600
            color: "white"

            TreeView {
                id: treeView
                model: treeModel
                backgroundVisible: false
                alternatingRowColors: false
                width: parent.width
                height: parent.height

                rowDelegate: Rectangle {
                    height: 25
                    color: (visible && openFilesModel.currentId === model.uid) ? "#CCCCCC" : "transparent"
                }

                itemDelegate: Item {
                    Text {
                        id: itemText
                        width: parent.width - 22
                        anchors.verticalCenter: parent.verticalCenter
                        text: styleData.value
                        elide: Text.ElideRight
                        font.pointSize: 10
                        color: "black"
                    }

                    SGIcon {
                        height: 15
                        width: 15
                        visible: model && !model.isDir

                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 5
                        }

                        iconColor: model && model.inQrc ? "green" : "red"
                        source: model && model.inQrc ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (!model.isDir) {
                                if (openFilesModel.hasTab(model.uid)) {
                                    openFilesModel.currentId = model.uid
                                } else {
                                    openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                                }
                            }
                        }
                    }
                }

                TableViewColumn {
                    title: "Project Files"
                    role: "filename"
                    width: 250
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

//        FileDialog {
//            id: existingFileDialog
//            nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
//            selectExisting: true
//            selectMultiple: true
//            folder: fileModel.projectDirectory

//            onAccepted: {
//                for (let i = 0; i < fileUrls.length; i++) {
//                    fileModel.append(fileUrls[i])
//                }
//            }
//        }

//        FileDialog {
//            id: newFileDialog
//            nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
//            selectExisting: false
//            folder: fileModel.projectDirectory

//            onAccepted: {
//                fileModel.append(fileUrl);
//                // Handle the case where user adds a new file to a different directory
//                folder = fileModel.projectDirectory
//            }

//            onRejected: {
//                folder = fileModel.projectDirectory
//            }
//        }
    }
}
