import QtQuick 2.0

Item {
    id: root
    height: 50
    width: lineThickness + 5
    property alias lineThickness: thicknessIndicator.width

    signal clicked (real thickness)

    Rectangle {
        id: thicknessIndicator
        color: "black"
        height: root.height
        anchors {
            horizontalCenter: root.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: root
        }

        onClicked: {
            root.clicked (root.lineThickness)
        }
    }
}
