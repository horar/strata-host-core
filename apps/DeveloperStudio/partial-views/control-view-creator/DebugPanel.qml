import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "components/"

Item {
    id: root

    property bool debugVisible: false
    property alias mainContainer: mainContainer
    property real rectWidth: 450

    property url debugMenuSource: editor.fileTreeModel.debugMenuSource

    anchors.fill: parent

    onDebugMenuSourceChanged: {
        if (debugMenuSource) {
            debugVisible = true
        } else {
            debugVisible = false
        }
    }

    MouseArea {
        id: mainContainer
        width: debugMenuWindow ? parent.width : Math.min(root.width, rectWidth)
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
            anchors {
                top: topBar.bottom
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            } 

            onVisibleChanged: {
                if (visible) {
                    setSource("qrc:/partial-views/control-view-creator/DebugMenu.qml", {source: editor.fileTreeModel.debugMenuSource})
                } else {
                    setSource("")
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
