import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: root.height
    color:"transparent"
    property alias ledColor: indicator.color

    Rectangle {
        id: indicator
        height: root.height
        width: root.height
        radius: root.width / 2

        anchors {
            horizontalCenter: root.horizontalCenter
            verticalCenter: root.verticalCenter
        }

        opacity: enabled ? 1.0 : 0.3

    }
}
