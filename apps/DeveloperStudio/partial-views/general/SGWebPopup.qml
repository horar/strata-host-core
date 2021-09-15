import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "./WebPopup"

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
