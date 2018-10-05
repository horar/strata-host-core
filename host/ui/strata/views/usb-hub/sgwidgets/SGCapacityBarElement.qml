import QtQuick 2.9

Rectangle {
    id: root

    property real value: 0

    color: "blue"
    width: (root.value-masterMinimumValue)/(masterMaximumValue-masterMinimumValue)*masterWidth
    height: parent.height
}

