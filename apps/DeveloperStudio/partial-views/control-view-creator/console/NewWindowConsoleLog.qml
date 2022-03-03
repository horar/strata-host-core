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
