import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Popup {
    id: orderPopup
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    onOpened: webview.url = "https://www.onsemi.com/PowerSolutions/locateSalesSupport.do"

    onClosed: orderPopup.destroy()

    DropShadow {
        width: orderPopup.width
        height: orderPopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: orderPopup.background
        z: -1
        cached: true
    }

    Rectangle {
        id: popupContainer
        width: orderPopup.width
        height: orderPopup.height
        clip: true
        color: "white"

        Rectangle {
            id: title
            height: 30
            width: popupContainer.width
            anchors {
                top: popupContainer.top
            }
            color: "lightgrey"

            SGIcon {
                id: close
                source: "qrc:/sgimages/times.svg"
                iconColor: close_hover.containsMouse ? "#eee" : "white"
                height: 20
                width: height
                anchors {
                    right: title.right
                    verticalCenter: title.verticalCenter
                    rightMargin: 10
                }

                MouseArea {
                    id: close_hover
                    anchors {
                        fill: close
                    }
                    onClicked: orderPopup.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        WebEngineView {
            id: webview
            anchors {
                top: title.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }
            url: ""
        }
    }
}
