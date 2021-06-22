import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color: "#ccc"

    property alias tabs: tabModel

    ColumnLayout {
        width: 150
        spacing: 0

        Repeater {
            id: tabView
            model: tabModel

            delegate: Item {
                id: delegate
                width: 150
                height: 20

                Rectangle {
                    id: tabItem
                    anchors.fill: delegate
                    color:mouseArea.containsMouse ? "#aaa" : "#ccc"

                    SGText {
                        anchors.centerIn: tabItem
                        text: model.text
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: tabItem
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            settingsStack.currentIndex = model.index
                        }
                    }
                }
            }
        }
        Item {
            Layout.preferredHeight: 10
            Layout.fillWidth: true
        }
    }
    ListModel {
        id: tabModel
    }
}
