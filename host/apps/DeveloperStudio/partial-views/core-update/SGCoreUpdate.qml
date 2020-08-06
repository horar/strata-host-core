import QtQuick 2.12
import QtQuick.Controls 2.12
import QtWebEngine 1.6
import QtGraphicalEffects 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/core_update.js" as CoreUpdate

import tech.strata.CoreUpdate 1.0

Popup {
    id: coreUpdatePopup
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape

    onClosed: coreUpdatePopup.destroy()

    property string latest_version: ""
    property string current_version: ""
    property string error_string: ""

    CoreUpdate {
        id: updateObj
    }

    DropShadow {
        width: coreUpdatePopup.width
        height: coreUpdatePopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: coreUpdatePopup.background
        z: -1
        cached: true
    }

    Rectangle {
        id: popupContainer
        width: coreUpdatePopup.width
        height: coreUpdatePopup.height
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
                source: "qrc:/images/icons/times.svg"
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
                    onClicked: coreUpdatePopup.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Text {
        font.family: "Helvetica"
        font.pointSize: 18
        text: "\n\nNew update available\nCurrent:" + current_version + "\nLatest:" + latest_version + (error_string !== "" ? ("\nError:" + error_string) : "")
    }

    Column {
        topPadding: 120

        anchors {
            centerIn: parent
        }

        Button {
            text: "Update"
            width: popupContainer.width / 2

            onClicked: {
                updateObj.requestUpdateApplication()
                coreUpdatePopup.close()
            }
        }

        Button {
            text: "Ask again later"
            width: popupContainer.width / 2
            onClicked: {
                CoreUpdate.setUserNotificationMode("AskAgainLater")
                coreUpdatePopup.close()
            }
        }

        Button {
            text: "Don't ask again"
            width: popupContainer.width / 2
            onClicked: {
                CoreUpdate.setUserNotificationMode("DontAskAgain")
                coreUpdatePopup.close()
            }
        }
    }
}
