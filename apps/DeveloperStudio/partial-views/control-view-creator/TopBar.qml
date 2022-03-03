/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
                controlViewCreatorRoot.getProjectNameFromCmake()
                nameField.text = controlViewCreatorRoot.projectName
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
