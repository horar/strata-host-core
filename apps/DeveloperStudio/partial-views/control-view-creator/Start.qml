/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

Rectangle {
    id: startContainer
    color: "#ccc"

    property alias openControlView: openControlView

    onVisibleChanged: {
        if(!visible) stack.state = "open"
    }

    ColumnLayout {
        anchors {
            fill: parent
            leftMargin: 20
            rightMargin: 20
        }

        ColumnLayout {
            Layout.fillWidth: true

            SGText {
                topPadding: 15
                Layout.alignment: Qt.AlignHCenter
                color: "#666"
                fontSizeMultiplier: 2
                text: "Welcome to Strata Control View Creator"
            }

            Rectangle {
                // divider line
                color: "#333"
                Layout.preferredHeight: 1
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.preferredHeight: 30
            Layout.fillWidth: true
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            Item {
                id: openArea
                width: 80
                height: width

                SGIcon {
                    id: openIcon
                    source: "qrc:/sgimages/folder-open-solid.svg"
                    width: 55
                    height: width
                    iconColor: openMouseArea.containsMouse || stack.state === "open" ? "#444" : "#aaa"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SGText {
                    id: openText
                    text: "Open"
                    fontSizeMode: Text.Fit
                    color: openIcon.iconColor
                    anchors {
                        top: openIcon.bottom
                        horizontalCenter: openIcon.horizontalCenter
                        topMargin: -5
                    }
                }

                Rectangle {
                   color: "#444"
                   radius: 5
                   height: 4
                   width: openArea.width
                   visible: stack.state === "open"
                   anchors {
                       top: openText.bottom
                       horizontalCenter: openText.horizontalCenter
                       topMargin: 5
                   }
                }

                MouseArea {
                    id: openMouseArea
                    anchors.fill: openArea
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: enabled
                    enabled: stack.state !== "open"

                    onClicked: {
                        stack.state = "open"
                    }
                }
            }

            Item {
                id: createArea
                width: 80
                height: width

                SGIcon {
                    id: createIcon
                    source: "qrc:/sgimages/folder-plus.svg"
                    width: 55
                    height: width
                    iconColor: createMouseArea.containsMouse || stack.state === "create"  ? "#444" : "#aaa"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SGText {
                    id: createText
                    text: "Create"
                    color: createIcon.iconColor
                    fontSizeMode: Text.Fit
                    anchors {
                        top: createIcon.bottom
                        horizontalCenter: createIcon.horizontalCenter
                        topMargin: -5
                    }
                }

                Rectangle {
                   color: "#444"
                   radius: 5
                   height: 4
                   width: createArea.width
                   visible: stack.state === "create"
                   anchors {
                       top: createText.bottom
                       horizontalCenter: createText.horizontalCenter
                       topMargin: 5
                   }
                }

                MouseArea {
                    id: createMouseArea
                    anchors.fill: createArea
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: enabled
                    enabled: stack.state !== "create"

                    onClicked: {
                        stack.state = "create"
                    }
                }
            }
        }

        StackLayout {
            id: stack
            Layout.alignment: Qt.AlignBottom
            Layout.fillHeight: true
            Layout.fillWidth: true

            state: "open"

            states: [
                State {
                    name: "open"
                    PropertyChanges {
                        target: stack
                        currentIndex: 0
                    }
                },
                State {
                    name: "create"
                    PropertyChanges {
                        target: stack
                        currentIndex: 1
                    }
                }
            ]

            OpenControlView {
                id: openControlView
            }

            NewControlView {
                id: newControlView
            }
        }
    }

    ConfirmClosePopup {
        id: startConfirmClosePopup
        parent: controlViewCreatorRoot
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        titleText: "You have unsaved changes in " + unsavedFileCount + " files."
        acceptButtonText: "Save all"

        property int unsavedFileCount
        property var callback

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                editor.openFilesModel.closeAll()
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                editor.openFilesModel.saveAll(true)
            }
            controlViewCreatorRoot.isConfirmCloseOpen = false
            if (closeReason !== confirmClosePopup.cancelCloseReason) {
                callback()
            }
        }
    }
}
