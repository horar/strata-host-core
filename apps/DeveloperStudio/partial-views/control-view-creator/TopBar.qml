import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import "qrc:/js/constants.js" as Constants

RowLayout {
    spacing: 10

    Text {
        id: nameField
        Layout.leftMargin: 5
        font.bold: true
        color: "white"
        elide: Text.ElideRight
        Layout.maximumWidth: 300

        Connections {
            target: treeModel
            onProjectDirectoryChanged: {
                let cMakeFile = treeModel.projectDirectory
                cMakeFile = SGUtilsCpp.urlToLocalFile(cMakeFile)
                cMakeFile = SGUtilsCpp.joinFilePath(cMakeFile, "CMakeLists.txt")

                if (SGUtilsCpp.isFile(cMakeFile)) {
                    const content = SGUtilsCpp.readTextFileContent(cMakeFile)
                    // Regex will parse the project name from CMakeLists.txt; "project(<project name to be captured>"
                    const splitCondition = /project\s*\(\s*([a-zA-Z0-9_.-]*)\s*$/m
                    const cMakeArr = content.match(splitCondition)
                    
                    if (cMakeArr === null || cMakeArr.length < 2) {
                        console.warn("Could not determine project name from CMakeLists.txt")
                        nameField.text = SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
                    } else {
                        nameField.text = cMakeArr[1]
                    }
                } else {
                    console.warn("Unable to open CMakeLists.txt")
                    nameField.text = SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
                }
            }
        }
    }

    Rectangle {
        // divider
        color: "#999"
        Layout.leftMargin: 5
        implicitWidth: 1
        implicitHeight: parent.height - 4
    }

    Button {
        Layout.fillHeight: true
        text: "Toggle File Tree"
        highlighted: true
        flat: true
        background: Rectangle {
            color: fileTreemouseArea.containsMouse ? "#888": "transparent"
        }

        MouseArea {
            id: fileTreemouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                sideBar.visible = !sideBar.visible
            }
        }
    }

    Button {
        Layout.fillHeight: true
        text: "Edit QRC"
        highlighted: true
        flat: true
        enabled: editQRCEnabled
        background: Rectangle {
            color: enabled && editMouseArea.containsMouse ? "#888": "transparent"
        }

        MouseArea {
            id: editMouseArea
            anchors.fill: parent
            hoverEnabled: enabled
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                let url = editor.fileTreeModel.url
                let filename = SGUtilsCpp.fileName(editor.fileTreeModel.url)
                let filetype = "qrc"
                let uid = "qrcUid"
                editQRCEnabled = !(openFilesModel.addTab(filename, url, filetype, uid))
            }
        }
    }

    Item {
        // space filler
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    SGComboBox {
        Layout.fillHeight: true
        Layout.preferredWidth: 350
        model: connectedPlatforms
        placeholderText: "Select a platform to connect to..."
        enabled: model.count > 0
        textRole: "verbose_name"
        boxColor: "transparent"
        textColor: "white"
        popupBackground.color: "#B3B3B3"

        onCurrentIndexChanged: {
            if (currentIndex === -1) {
                controlViewCreatorRoot.debugPlatform = {
                    device_id: Constants.NULL_DEVICE_ID,
                    class_id: ""
                }
            } else {
                let platform = connectedPlatforms.get(currentIndex)
                controlViewCreatorRoot.debugPlatform = {
                    device_id: platform.device_id,
                    class_id: platform.class_id
                }
            }
        }
    }
}
