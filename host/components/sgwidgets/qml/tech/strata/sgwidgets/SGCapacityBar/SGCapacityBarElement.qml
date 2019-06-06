import QtQuick 2.12

Item {
    id: root

    property real value: 0
    property real secondaryValue: 0
    property alias color: primaryElement.color

    width: (root.value-masterMinimumValue)/(masterMaximumValue-masterMinimumValue)*masterWidth
    height: parent.height
    clip: true

    Rectangle {
        id: primaryElement
        color: "blue"
        width: root.width -1
        height: root.height
    }

    Rectangle {
        id: secondaryElement
        width: (root.secondaryValue-masterMinimumValue)/(masterMaximumValue-masterMinimumValue)*masterWidth
        height: root.height
        anchors {
            left: root.left
        }
        color: Qt.lighter(root.color, 1.3)
    }
}
