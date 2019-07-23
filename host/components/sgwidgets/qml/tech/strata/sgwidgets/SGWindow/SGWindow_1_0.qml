import QtQuick.Window 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Window {
    id: window

    QtLabsSettings.Settings {
        category: "ApplicationWindow"

        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }
}
