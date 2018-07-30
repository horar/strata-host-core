import QtQuick 2.9

Rectangle {
    id: root

    property real value: 0
    property real minimumValue: masterMinimumValue
    property real maximumValue: masterMaximumValue
    property real capacityBarWidth: masterWidth

    color: "blue"
    width: (root.value-root.minimumValue)/(root.maximumValue-root.minimumValue)*capacityBarWidth
    height: parent.height
}

