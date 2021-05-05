import QtQuick 2.12

import "../../"

LayoutContainer {
    id: dividerRoot

    property bool vertical: false
    property alias color: dividerLine.color
    property int thickness: 1 // "width" is a reserved word and ambiguous when vertical

    contentItem: Item {

        Rectangle {
            id: dividerLine
            height: dividerRoot.vertical ? parent.height : thickness
            width: dividerRoot.vertical ? thickness : parent.width
            anchors {
                centerIn: parent
            }
            color: "black"
        }
    }
}

