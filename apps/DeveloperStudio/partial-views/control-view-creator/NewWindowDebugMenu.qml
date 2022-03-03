/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.3
import QtQuick.Controls 1.2

ApplicationWindow {
    id: root
    width: 450
    height: mainWindow.height
    minimumHeight: 200
    minimumWidth: 450

    visible: true
    property alias consoleLogParent: newWindowContainer

    onClosing: {
        if (debugMenuWindow) {
            debugMenuWindow = false
        }
        isDebugMenuOpen = false
    }

    Item {
        id: newWindowContainer
        anchors.fill: parent
    }
}
