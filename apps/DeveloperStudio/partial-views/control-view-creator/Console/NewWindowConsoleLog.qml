import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    id: root
    width: 1000
    height: 200
    visible: true
    property alias consoleLogParent: resizeRect

    onClosing: {
        if(popupWindow) {
            popupWindow = false
        }
        isConsoleLogOpen = false
    }

    Item {
        id: resizeRect
        anchors.fill: parent
    }
}
