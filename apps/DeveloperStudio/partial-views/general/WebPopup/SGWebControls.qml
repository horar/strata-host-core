import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: title
    height: 40
    width: popupContainer.width
    anchors {
        top: popupContainer.top
    }
    color: "lightgrey"

    RowLayout{
        id: row
        anchors {
            left: title.left
            verticalCenter: title.verticalCenter
            leftMargin: 10
        }

        SGIcon {
            id: back
            enabled: webview.canGoBack
            source: "qrc:/partial-views/distribution-portal/images/arrow-circle-right.svg"
            iconColor: back_hover.containsMouse ? "#eee" : "white"
            rotation: 180
            height: 30
            width: height
            Layout.alignment: Qt.AlignLeft
            opacity: webview.canGoBack ? 1 : 0.25

            MouseArea {
                id: back_hover
                anchors {
                    fill: back
                }

                onClicked: webview.goBack()
                hoverEnabled: webview.canGoBack
                cursorShape: Qt.PointingHandCursor
            }
        }

        SGIcon {
            id: forward
            enabled: webview.canGoForward
            source: "qrc:/partial-views/distribution-portal/images/arrow-circle-right.svg"
            iconColor: forward_hover.containsMouse ? "#eee" : "white"
            height: 30
            width: height
            Layout.alignment: Qt.AlignRight
            opacity: webview.canGoForward ? 1 : 0.25

            MouseArea {
                id: forward_hover
                anchors {
                    fill: forward
                }

                onClicked: webview.goForward()
                hoverEnabled: webview.canGoForward
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    SGIcon {
        id: close
        source: "qrc:/sgimages/times.svg"
        iconColor: close_hover.containsMouse ? "#eee" : "white"
        height: 25
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
            onClicked: webPopup.close()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
