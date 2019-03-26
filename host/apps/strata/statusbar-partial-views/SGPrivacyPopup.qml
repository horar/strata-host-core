import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Fonts 1.0
import QtGraphicalEffects 1.0

Popup {
    id: profilePopup
    width: container.width * 0.8
    height: container.parent.windowHeight * 0.8
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    onClosed: profileStack.currentIndex=0

    DropShadow {
        width: profilePopup.width
        height: profilePopup.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: profilePopup.background
        z: -1
        cached: true
    }

    Item {
        id: popupContainer
        width: profilePopup.width
        height: profilePopup.height
        clip: true

        Image {
            id: background
            source: "qrc:/images/login-background.svg"
            height: 1080
            width: 1920
            x: (popupContainer.width - width)/2
            y: (popupContainer.height - height)/2
        }

        Rectangle {
            id: title
            height: 30
            width: popupContainer.width
            anchors {
                top: popupContainer.top
            }
            color: "lightgrey"

            Label {
                id: profileTitle
                anchors {
                    left: title.left
                    leftMargin: 10
                    verticalCenter: title.verticalCenter
                }
                text: "Privacy Policy"
                font {
                    family: Fonts.franklinGothicBold
                }
                color: "black"
            }

            Text {
                id: close_profile
                text: "\ue805"
                color: close_profile_hover.containsMouse ? "#eee" : "white"
                font {
                    family: Fonts.sgicons
                    pixelSize: 20
                }
                anchors {
                    right: title.right
                    verticalCenter: title.verticalCenter
                    rightMargin: 10
                }

                MouseArea {
                    id: close_profile_hover
                    anchors {
                        fill: close_profile
                    }
                    onClicked: profilePopup.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        StackLayout {
            id: profileStack
            anchors {
                top: title.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }
            currentIndex: 0

            SGPrivacyPolicy {
                id: privacyPolicy
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
