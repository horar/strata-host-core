/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "platform-settings"
import "../"

Rectangle {
    id: platformSettings
    color: "#ddd"
    anchors {
        fill: parent
    }

    property alias softwareManagement: softwareManagement

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 30

        SoftwareManagement {
            id: softwareManagement
        }

        FirmwareManagement {
            id: firmwareManagement
        }

        // Todo: determine notification UX, to be implemented in CS-880 - re-use warningPop?
//        CheckBox {
//            id: reminderCheck
//            text: "Notify me when newer versions of firmware or controls are available"
//        }

        Item {
            // fills extra space
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    SGConfirmationPopup {
        id: warningPop
        cancelButtonText: "Cancel"
        acceptButtonText: "OK"
        titleText: "Warning"
        popupText: "Older firmware versions may be incompatible with the<br>installed software version. Are you sure you want to continue?"

        property Item callback: null

        onPopupClosed: {
            if (closeReason === warningPop.acceptCloseReason) {
                warningPop.callback.callback()
            }
        }
    }
}
