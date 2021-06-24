import QtQuick 2.12

import "../../"

LayoutContainer {
    id: dividerRoot

    property int orientation: Qt.Horizontal
    property alias color: dividerLine.color
    property int thickness: 1 // "width" is a reserved word and ambiguous when vertical

    contentItem: Item {

        Rectangle {
            id: dividerLine
            height: dividerRoot.orientation === Qt.Horizontal ? thickness : parent.height
            width: dividerRoot.orientation === Qt.Horizontal ? parent.width : thickness
            anchors {
                centerIn: parent
            }
            color: "black"
        }
    }
}

