import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

RowLayout {
    spacing: 10

    Text {
        Layout.leftMargin: 5
        text: SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
        font.bold: true
        color: "white"
        elide: Text.ElideRight
        Layout.maximumWidth: 300
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
                editQRCEnabled = false
                openFilesModel.addTab(filename, url, filetype, uid)
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

        onCurrentIndexChanged: {
            let platform = connectedPlatforms.get(currentIndex)
            controlViewCreatorRoot.debugPlatform = {
                deviceId: platform.device_id,
                classId: platform.class_id
            }
        }
    }
}
