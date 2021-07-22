import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

RowLayout {
    id: root
    anchors {
        fill: parent
    }
    spacing: 10

    property color buttonColor: "#777"
    
    property var nameOfProject: SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
    Connections {
        target: treeModel
        onProjectDirectoryChanged: {
            let cMakeFile = treeModel.projectDirectory
            cMakeFile = SGUtilsCpp.urlToLocalFile(cMakeFile)
            cMakeFile = SGUtilsCpp.joinFilePath(cMakeFile, "CMakeLists.txt")
            if (SGUtilsCpp.isFile(cMakeFile) === true) {
                let content = SGUtilsCpp.readTextFileContent(cMakeFile)
                // Regex will parse the project name from CMakeLists.txt; "project(<project name to be captured>"
                let splitCondition = /project\s*\(\s*([a-zA-Z0-9_.-]*)\s*/ 
                let cMakeArr = content.match(splitCondition)
                nameOfProject = cMakeArr[1]
                if (nameOfProject === null) {
                    nameOfProject = SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
                }
            }
        }
    }

    Text {
        leftPadding: 5
        verticalAlignment: Text.AlignVCenter
        text: nameOfProject
        font.pointSize: 12
        font.bold: true
        font.capitalization: Font.AllUppercase
        color: "white"
        elide: Text.ElideRight
    }

    Item {
        Layout.preferredWidth: parent.width/8.5
        Layout.fillHeight: true

        Button {
            id: fileTreeButton
            anchors.fill: parent
            text: "Toggle File Tree"
            background: Rectangle {
                radius: 1.5
                color: fileTreemouseArea.containsMouse ? "lightgray": root.buttonColor
            }
            highlighted: true
            flat: true
            MouseArea {
                id: fileTreemouseArea
                anchors.fill: parent
                enabled: parent.enabled
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    sideBar.visible = !sideBar.visible
                }
            }
        }
    }

    Item {
        Layout.preferredWidth: parent.width/12
        Layout.fillHeight: true

        Button {
            anchors.fill: parent
            text: "Edit QRC"
            background: Rectangle {
                radius: 1.5
                color: enabled && editMouseArea.containsMouse ? "lightgray": root.buttonColor
            }
            highlighted: true
            flat: true
            enabled: editQRCEnabled

            MouseArea {
                id: editMouseArea
                anchors.fill: parent
                enabled: parent.enabled
                hoverEnabled: enabled
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                z: 3

                onClicked: {
                    var url = "file://" + SGUtilsCpp.urlToLocalFile(editor.fileTreeModel.url)
                    var filename = nameOfProject + ".qrc"
                    var filetype = "qrc"
                    var uid = "qrcUid"
                    editQRCEnabled = false
                    openFilesModel.addTab(filename, url, filetype, uid)
                }
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
        Layout.topMargin: 0
        Layout.preferredWidth: 350

        model: connectedPlatforms
        placeholderText: "Select a platform to connect to..."
        enabled: model.count > 0
        textRole: "verbose_name"
        boxColor: root.buttonColor
        textColor: "white"

        onCurrentIndexChanged: {
            let platform = connectedPlatforms.get(currentIndex);
            controlViewCreatorRoot.debugPlatform = {
                deviceId: platform.device_id,
                classId: platform.class_id
            };
        }
    }
}
