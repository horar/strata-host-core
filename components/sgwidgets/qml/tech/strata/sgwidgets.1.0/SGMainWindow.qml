/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

import tech.strata.sgwidgets 1.0 as SGWidgets

ApplicationWindow {
    id: window

    width: settings.width
    height: settings.height

    flags: Qt.Window | Qt.WindowFullscreenButtonHint

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
    Rectangle {
        color: "lightgrey"
        opacity: 1
        anchors {
            top: parent.top
            left: parent.left
        }
    }

    Component.onCompleted: {
        // bug present in following few lines reported here: https://jira.onsemi.com/browse/CS-1914
        var savedScreenLayout = (settings.desktopAvailableWidth === Screen.desktopAvailableWidth)
            && (settings.desktopAvailableHeight === Screen.desktopAvailableHeight)

        window.x = (savedScreenLayout) ? settings.x : Screen.width / 2 - window.width / 2
        window.y = (savedScreenLayout) ? settings.y : Screen.height / 2 - window.height / 2

        if (settings.visibility === Window.Maximized && savedScreenLayout) {
            window.showMaximized()
        }
    }
}
