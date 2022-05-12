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
import tech.strata.fonts 1.0
import tech.strata.signals 1.0

import "qrc:/partial-views/control-view-creator"
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/login_utilities.js" as LoginUtils

SGWidgets.SGDialog {
    id: policyDialog

    title: "Privacy Policy Update"
    headerBgColor: Theme.palette.highlight
    closePolicy: Dialog.NoAutoClose
    modal: true
    focus: true

    Item { 
        implicitWidth: Math.max(implicitHeaderWidth, 400)
        implicitHeight: 100

        SGWidgets.SGText {
            width: parent.width
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            textFormat: Text.StyledText
            text: "We respect your privacy and won\’t share your information with outside parties without your consent. " + 
                "To learn more about the onsemi privacy policy, click <a href='" + sdsModel.urls.privacyPolicyUrl + "'>here</a>." +
                "<br> <br>" +
                "You can learn more about how we handle your personal data and your rights by reviewing our <a href='" + 
                sdsModel.urls.privacyPolicyUrl + "'>privacy policy</a>." 
// "onsemi has updated our <a href='" + sdsModel.urls.privacyPolicyUrl + "'>Privacy Policy</a>. Please read these documents carefully as the changes affect your legal rights. By clicking on Accept, you accept these updates."
            linkColor: "#545960"
            fontSizeMultiplier: 1.25
            font.family: Fonts.franklinGothicBook

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
                text: "Log Out"
                onClicked: {
                    logout()
                    policyDialog.accept()
                }
            }

            SGWidgets.SGButton {
                text: "Accept"
                onClicked: policyDialog.accept()
                color: Theme.palette.success
            }
        }
    }

    function logout() {
        sdsModel.coreInterface.unregisterClient();
        // controlViewCreatorLoader.active = false
        Signals.logout()
        PlatformFilters.clearActiveFilters()
        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
        LoginUtils.logout()
        PlatformSelection.logout()
    }
}
