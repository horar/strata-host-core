import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

import "components/"

Item {
    id: root

    property var debugVisible: false
    property alias mainContainer: mainContainer
    property alias sideWall: topWall
    property real rectWidth: 450

    property url debugMenuSource: editor.fileTreeModel.debugMenuSource
    onDebugMenuSourceChanged: debugMenuSource.toString() ? debugVisible = true : debugVisible = false

    anchors.fill: parent

    Rectangle {
        id: mainContainer
        width: Math.min(parent.width, rectWidth)
        height: parent.height
        anchors.right: parent.right
        color: "lightgrey"
        clip: true

        Rectangle {
            id: topBar
            width: parent.width
            height: 30
            anchors.top: parent.top
            color: "#444"

            RowLayout {
                anchors.fill: parent

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    SGText {
                        id: header
                        text: "Debug Commands and Notifications"
                        Layout.alignment: Qt.AlignCenter
                        color: "white"
                        fontSizeMultiplier: 1.15
                        leftPadding: 5
                    }
                }

                SGControlViewIconButton {
                    id: openWindow
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source:  "qrc:/sgimages/sign-in.svg"

                    onClicked:  {
                        debugMenuWindow = !debugMenuWindow
                    }
                }

                SGControlViewIconButton {
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    source: "qrc:/sgimages/times.svg"
                    Layout.alignment: Qt.AlignRight

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
            anchors.top: topBar.bottom
            width: parent.width
            height: parent.height - topBar.height
            source: root.debugMenuSource
        }
    }

    Item {
        id: topWall
        y: 0
        width: 4
        height: parent.height + 5
        enabled: true

        Binding {
            target: topWall
            property: "x"
            value: root.width - mainContainer.width - topWall.width
            when: mouseArea.drag.active === false

        }
        onXChanged: {
            if(mouseArea.drag.active) {
                rectWidth = parent.width - x
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: topWall
        drag.target: topWall
        drag.minimumY: 0
        drag.maximumY: 0
        drag.minimumX: 0
        drag.maximumX: (parent.width - 60)
        cursorShape: Qt.SplitHCursor
    }
}
