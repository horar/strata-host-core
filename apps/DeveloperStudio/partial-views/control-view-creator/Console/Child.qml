import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    id: root
    width: 500
    height: 200
    visible: true
    property real rectHeight : 200
    property alias consoleLogParent: resizeRect

    Rectangle {
        id: resizeRect
        anchors.fill: parent
        color: "red"
    }
}
