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
    headerBgColor: Theme.palette.onsemiDark
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
            linkColor: "#545960"
            fontSizeMultiplier: 1.25
            font.family: Fonts.franklinGothicBook

            onLinkActivated: { Qt.openUrlExternally(sdsModel.urls.privacyPolicyUrl)}
        }
    }

    footer: Item {
        implicitHeight: buttonRow.height + 20

        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 100

            Rectangle {
                id: logOutButton
                height: 25
                width: acceptButton.width
                radius: 20
                border.width: 1
                border.color: Theme.palette.onsemiDark
                color: mouse.containsMouse ? Theme.palette.onsemiDark : "transparent"

                SGWidgets.SGText {
                    text: qsTr("Log Out")
                    color: mouse.containsMouse ? Theme.palette.white :  Theme.palette.onsemiDark
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        policyDialog.reject()
                    }
                }
            }
 
            Rectangle {
                id: acceptButton
                height: 25
                width: acceptText.implicitWidth + 40
                radius: 20
                color: mouseAccept.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.1) : Theme.palette.onsemiOrange

                SGWidgets.SGText {
                    id: acceptText
                    text: qsTr("Accept")
                    color: Theme.palette.white
                    anchors.centerIn: parent
                    font.bold: true
                }

                MouseArea {
                    id: mouseAccept
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        console.log("Updating privacy policy consent!")
                        let data = {
                            "consent_privacy_policy": true
                        };
                        LoginUtils.update_profile(NavigationControl.context.user_id, data)
                        policyDialog.accept()
                    }
                }
            }
        }
    }
}
