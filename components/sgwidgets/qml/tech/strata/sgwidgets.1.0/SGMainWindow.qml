import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

import tech.strata.sgwidgets 1.0 as SGWidgets

ApplicationWindow {
    id: window

    flags: flags | Qt.WindowFullscreenButtonHint

    onClosing: {
        SGWidgets.SGDialogJS.destroyAllDialogs()
    }

    QtLabsSettings.Settings {
        id: settings
        category: "ApplicationWindow"

        property int x: window.x
        property int y: window.y
        property int width: window.width
        property int height: window.height

        property alias visibility: window.visibility
        property int desktopAvailableWidth
        property int desktopAvailableHeight

        Component.onDestruction: {
            desktopAvailableWidth = Screen.desktopAvailableWidth
            desktopAvailableHeight = Screen.desktopAvailableHeight
        }
    }

    Component.onCompleted: {
        var savedScreenLayout = (settings.desktopAvailableWidth === Screen.desktopAvailableWidth)
                && (settings.desktopAvailableHeight === Screen.desktopAvailableHeight)

        window.x = (savedScreenLayout) ? settings.x : Screen.width / 2 - window.width / 2
        window.y = (savedScreenLayout) ? settings.y : Screen.height / 2 - window.height / 2

        if (settings.visibility === Window.Maximized && savedScreenLayout) {
            window.showMaximized()
        }
    }
}
