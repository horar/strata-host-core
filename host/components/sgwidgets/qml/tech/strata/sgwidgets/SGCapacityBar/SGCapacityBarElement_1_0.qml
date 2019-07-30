import QtQuick 2.12

Item {
    id: root
    objectName: "capacityBarElement"

    property real value: 0
    property real secondaryValue: 0
    property alias color: primaryElement.color
    property var capacityBar: null

    width: (root.value-capacityBar.minimumValue)/(capacityBar.maximumValue-capacityBar.minimumValue)*capacityBar.masterWidth
    height: capacityBar.height
    clip: true

    Rectangle {
        id: primaryElement
        color: "blue"
        width: root.width
        height: root.height
    }

    Rectangle {
        id: secondaryElement
        width: (root.secondaryValue-capacityBar.minimumValue)/(capacityBar.maximumValue-capacityBar.minimumValue)*capacityBar.masterWidth
        height: root.height
        anchors {
            left: root.left
        }
        color: Qt.lighter(root.color, 1.3)
    }
}
