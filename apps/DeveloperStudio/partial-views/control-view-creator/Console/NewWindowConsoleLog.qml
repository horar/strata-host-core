import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    id: root
    width: mainWindow.width
    height: 200
    minimumHeight: 130
    minimumWidth: 500

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
