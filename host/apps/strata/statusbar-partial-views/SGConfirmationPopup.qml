import QtQuick 2.9
import QtQuick.Controls 2.3
import Fonts 1.0
import QtGraphicalEffects 1.0

Popup {
    id: root
    width: 400
    height: confirmationContainer.height
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    modal: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property alias titleText: confirmTitle.text
    property alias acceptButtonText: acceptButton.text
    property alias cancelButtonText: cancelButton.text
    property alias popupText: confirmText.text
    property alias acceptButton: acceptButton
    property alias cancelButton: cancelButton

    DropShadow {
        width: root.width
        height: root.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: root.background
        z: -1
        cached: true
    }

    Rectangle {
        id: confirmationContainer
        width: root.width
        height: childrenRect.height + column2.spacing

        Column {
            id: column2
            spacing: 20
            anchors {
                left: confirmationContainer.left
                right: confirmationContainer.right
            }

            Rectangle {
                id: confirmTitleBox
                height: 30
                width: confirmationContainer.width
                color: "lightgrey"

                Label {
                    id: confirmTitle
                    anchors {
                        left: confirmTitleBox.left
                        leftMargin: 10
                        verticalCenter: confirmTitleBox.verticalCenter
                        verticalCenterOffset: 2
                    }
                    text: "Confirmation Message"
                    color: "black"
                }

                Text {
                    id: confirmTitleText
                    text: "\ue805"
                    color: closeconfirmMouse.containsMouse ? "#eee" : "white"
                    font {
                        family: Fonts.sgicons
                        pixelSize: 20
                    }
                    anchors {
                        right: confirmTitleBox.right
                        verticalCenter: confirmTitleBox.verticalCenter
                        rightMargin: 10
                    }

                    MouseArea {
                        id: closeconfirmMouse
                        anchors {
                            fill: confirmTitleText
                        }
                        onClicked: root.close()
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Row {
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Text {
                    id: confirmText
                    color: "black"
                    text: "Are you sure you would like to continue?"
                }
            }

            Row {
                id: row1
                spacing: 20
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Button {
                    id: acceptButton
                    text: "Accept"
                    onClicked: {
                        root.close()
                    }
                }

                Button {
                    id: cancelButton
                    text: "Cancel"
                    visible: text !== ""
                    onClicked: {
                        root.close()
                    }
                }
            }
        }
    }
}
