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

import tech.strata.theme 1.0
import tech.strata.notification 1.0


ListView {
    model: sdsModel.notificationModel
    spacing: 10
    clip: true
    verticalLayoutDirection: ListView.BottomToTop
    interactive: false

    removeDisplaced: Transition {
        NumberAnimation {
            properties: "y"
            duration: 400
            easing.type: Easing.InOutQuad
        }

        // This verifies that the opacity is set to 1.0 when the add transition is interrupted
        NumberAnimation { property: "opacity"; to: 1.0 }
    }

    delegate: NotificationDelegate {
    }
}