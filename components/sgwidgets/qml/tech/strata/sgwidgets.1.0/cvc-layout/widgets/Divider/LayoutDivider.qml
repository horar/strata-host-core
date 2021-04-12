import QtQuick 2.12

import "../../"

LayoutContainer {

    Item {

        Rectangle {
            id: dividerLine
            height: 1
            width: parent.width
            anchors {
                centerIn: parent
            }
            color: "black"
        }
    }
}

