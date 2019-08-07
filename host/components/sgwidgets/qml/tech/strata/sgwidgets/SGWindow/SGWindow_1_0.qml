import QtQuick 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Window {
    id: window

    QtLabsSettings.Settings {
        id: settings
        category: "ApplicationWindow"

        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height

        property int desktopAvailableWidth
        property int desktopAvailableHeight
    }

    Component.onCompleted: {
        var savedScreenLayout = (settings.desktopAvailableWidth === Screen.desktopAvailableWidth)
                && (settings.desktopAvailableHeight === Screen.desktopAvailableHeight)

        window.x = (savedScreenLayout) ? settings.x : Screen.width / 2 - window.width / 2
        window.y = (savedScreenLayout) ? settings.y : Screen.height / 2 - window.height / 2
    }
    Component.onDestruction: {
        settings.desktopAvailableWidth = Screen.desktopAvailableWidth
        settings.desktopAvailableHeight = Screen.desktopAvailableHeight
    }
}
