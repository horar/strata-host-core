import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    id: root
    width: 1000
    height: 200
    minimumHeight: 121
    minimumWidth: 426

    visible: true
    property alias consoleLogParent: newWindowContainer

    onClosing: {
        if (popupWindow) {
            popupWindow = false
        }
        isConsoleLogOpen = false
    }

    Item {
        id: newWindowContainer
        anchors.fill: parent
    }
}
