import QtQuick 2.12

import tech.strata.theme 1.0

Item {
    id: root
    height: column.height
    width: column.width

    property bool checked: false

    signal selected(string filter)

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.selected(model.filterName)
        }
    }

    Column {
        id: column
        spacing: 5

        Rectangle {
            id: iconBackground
            color: root.checked ? Theme.palette.green : "black"
            width: 75
            height: 75
            radius: width/2

            Image {
                id: icon
                anchors {
                    fill: parent
                }
                source: model.iconSource
                mipmap: true
            }
        }

        Text {
            text: model.text
            anchors {
                horizontalCenter: iconBackground.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            color: "#666"
        }
    }

    Connections {
        target: segmentFilterRow
        onSelected: {
            if (model.filterName !== filter) {
                root.checked = false
            } else if (root.checked) {
                root.checked = false
            } else {
                root.checked = true
            }
        }
    }
}
