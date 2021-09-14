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

    property alias url: webview.url

    DropShadow {
        width: webPopup.width
        height: webPopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: webPopup.background
        cached: true
    }

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
