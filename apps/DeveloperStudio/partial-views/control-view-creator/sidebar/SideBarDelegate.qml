/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: itemContainer
    anchors.verticalCenter: parent.verticalCenter

    Text {
        id: itemFilename
        text: styleData.value
        width: inQrcIcon.x - x - 10
        height: 15
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 10
        color: "black"
        elide: Text.ElideRight
    }

    SGIcon {
        id: inQrcIcon
        height: 15
        width: 15
        visible: model && !model.isDir && model.inQrc

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }

        iconColor: "green"
        source: "qrc:/sgimages/check-circle.svg"

        MouseArea {
            id: toolTipMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        ToolTip {
            id: toolTip
            x: inQrcIcon.width + 5
            y: (inQrcIcon.height - height) / 2
            visible: toolTipMouse.containsMouse
            delay: 300
            text: "This file is in the project’s QRC resource file"
        }
    }

    Loader {
        id: contextMenu
        source: {
            if (!model) {
                return ""
            } else if (model.isDir) {
                return "./FolderContextMenu.qml"
            } else {
                return "./FileContextMenu.qml"
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: {
            if (model.filename !== "") {
                if (mouse.button === Qt.RightButton) {
                    treeView.selectItem(styleData.index)
                    contextMenu.item.popup()
                } else if (mouse.button === Qt.LeftButton) {
                    treeView.selectItem(styleData.index)
                    if (!model.isDir) {
                        if (openFilesModel.hasTab(model.uid)) {
                            openFilesModel.currentId = model.uid
                        } else {
                            openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                        }
                    } else {
                        if (!treeView.isExpanded(styleData.index)) {
                            treeView.expand(styleData.index)
                        } else {
                            treeView.collapse(styleData.index)
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: openFilesModel

        onCurrentIndexChanged: {
            if (visible && openFilesModel.currentId === model.uid) {
                treeView.selectItem(styleData.index);
            }

            if (openFilesModel.currentId.length === 0 && treeView.selection.currentIndex.valid) {
                // No files are selected
                treeView.selection.clearCurrentIndex()
            }
        }
    }
}
