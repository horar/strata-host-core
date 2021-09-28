/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 1.0
import "components/"

Item {
    id: root
    anchors.fill: parent

    property real rectWidth: 450
    property real minWidth: 350
    property alias mainContainer: mainContainer

    MouseArea {
        id: mainContainer
        width: debugMenuWindow ? parent.width : Math.min(root.width, Math.max(rectWidth, minWidth))
        height: parent.height
        anchors.right: parent.right
        clip: true

        onClicked: {
            // capture all clicks so they don't propagate onto the control views below
            mouse.accepted = true
        }

        Rectangle {
            id: topBar
            width: parent.width
            height: 30
            anchors.top: parent.top
            color: "#444"

            RowLayout {
                anchors.fill: parent
                spacing: 5

                SGText {
                    text: "Debug Commands and Notifications"
                    alternativeColorEnabled: true
                    fontSizeMultiplier: 1.15
                    leftPadding: 5
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                SGControlViewIconButton {
                    id: openWindow
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/sign-in.svg"

                    onClicked:  {
                        debugMenuWindow = !debugMenuWindow
                    }
                }

                SGControlViewIconButton {
                    id: closeWindow
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/times.svg"

                    onClicked:  {
                        if (debugMenuWindow) {
                            debugMenuWindow = false
                        }
                        isDebugMenuOpen = false
                    }
                }
            }
        }

        Loader {
            id: debugLoader
            anchors {
                top: topBar.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            } 
            source: "qrc:/partial-views/control-view-creator/DebugMenu.qml"

            onVisibleChanged: {
                if (visible && active === false) {
                    active = true
                }
            }
        }

        Rectangle {
            // divider
            color: "black"
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            visible: debugMenuWindow === false
        }
    }

    Item {
        id: sideWall
        y: 0
        width: 4
        height: parent.height + 5
        enabled: true

        Binding {
            target: sideWall
            property: "x"
            value: root.width - mainContainer.width - sideWall.width
            when: mouseArea.drag.active === false
        }

        onXChanged: {
            if (mouseArea.drag.active) {
                rectWidth = parent.width - x
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: sideWall
        drag.target: sideWall
        drag.minimumY: 0
        drag.maximumY: 0
        drag.minimumX: 0
        drag.maximumX: (parent.width - 100)
        cursorShape: Qt.SplitHCursor
    }
}
