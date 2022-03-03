/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Window {
    id: window

    property bool destroyOnClose: false

    Component.onCompleted: {
        SGWidgets.SGDialogJS.openedDialogs.push(window)
    }

    onClosing: {
        close.accepted = false
        if (destroyOnClose) {
            SGWidgets.SGDialogJS.destroyComponent(window)
        }
    }
}
