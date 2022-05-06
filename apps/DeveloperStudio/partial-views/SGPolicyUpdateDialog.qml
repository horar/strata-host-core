/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

SGWidgets.SGDialog {
    id: policyDialog

    title: "Privacy Policy Update"
    headerBgColor: Theme.palette.warning
    closePolicy: Dialog.NoAutoClose

    Item { 
        implicitWidth: Math.max(implicitHeaderWidth, 400)
        implicitHeight: 100

        Text {
            width: parent.width
            anchors.centerIn: parent
            // anchors { 
            //     verticalCenter: parent.verticalCenter
            //     horizontalCenter: parent.horizontalCenter 
            // }
            wrapMode: Text.Wrap
            text: "onsemi has updated our <a href='" + sdsModel.urls.privacyPolicyUrl + "'>Privacy Policy</a>. Please read these documents as the changes affect your legal rights. By clicking on Agree, you accept these updates."
            font.bold: true
            linkColor: "#545960"

            onLinkActivated: { Qt.openUrlExternally(sdsModel.urls.privacyPolicyUrl)}
        }
    }

    footer: Item {
        implicitHeight: buttonRow.height + 10

        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 89

            SGWidgets.SGButton {
                text: "Cancel"
                onClicked: {
                    logout()
                    policyDialog.accept()
                }
            }

            SGWidgets.SGButton {
                text: "Agree"
                onClicked: policyDialog.accept()
            }
        }
    }

    function logout() {
        sdsModel.coreInterface.unregisterClient();
        controlViewCreatorLoader.active = false
        Signals.logout()
        PlatformFilters.clearActiveFilters()
        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
        LoginUtils.logout()
        PlatformSelection.logout()
    }
}
