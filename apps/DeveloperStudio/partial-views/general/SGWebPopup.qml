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
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "./web-popup"

Popup {
    id: webPopup
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle {
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 1
            verticalOffset: 3
            samples: 30
            color: "#cc000000"
        }
    }

    property alias url: webview.url

    Rectangle {
        id: popupContainer
        width: webPopup.width
        height: webPopup.height
        clip: true
        color: "white"

        SGWebControls {
            id: webControls
        }

        SGWebView {
            id: webview

            anchors {
                top: webControls.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }
        }
    }
}
