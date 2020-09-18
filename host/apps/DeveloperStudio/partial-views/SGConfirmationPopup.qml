import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "qrc:/partial-views"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

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
    property string acceptButtonColor: "#999"
    property string acceptButtonHoverColor: "#666"
    property string cancelButtonColor: "#999"
    property string cancelButtonHoverColor: "#666"

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

                SGIcon {
                    id: confirmTitleText
                    source: "qrc:/sgimages/times.svg"
                    iconColor: closeconfirmMouse.containsMouse ? "#eee" : "white"
                    height: 20
                    width: height

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

                    contentItem: Text {
                        text: acceptButton.text
                        font.pixelSize: 12
                        font.family: Fonts.franklinGothicBook
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        id: acceptBtnBg
                        implicitWidth: 100
                        implicitHeight: 40
                        color: acceptButtonColor
                    }

                    onClicked: {
                        root.close()
                    }

                    Accessible.onPressAction: function() {
                        clicked()
                    }

                    MouseArea {
                        id: acceptBtnCursor

                        hoverEnabled: true
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            acceptBtnBg.color = acceptButtonHoverColor
                        }

                        onExited: {
                            acceptBtnBg.color = acceptButtonColor
                        }
                    }
                }

                Button {
                    id: cancelButton
                    text: "Cancel"
                    visible: text !== ""

                    contentItem: Text {
                        text: cancelButton.text
                        font.pixelSize: 12
                        font.family: Fonts.franklinGothicBook
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        id: cancelBtnBg
                        implicitWidth: 100
                        implicitHeight: 40
                        color: cancelButtonColor
                    }

                    onClicked: {
                        root.close()
                    }

                    Accessible.onPressAction: function() {
                        clicked()
                    }

                    MouseArea {
                        id: cancelBtnCursor

                        hoverEnabled: true
                        anchors.fill: parent
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            cancelBtnBg.color = cancelButtonHoverColor
                        }

                        onExited: {
                            cancelBtnBg.color = cancelButtonColor
                        }
                    }
                }
            }
        }
    }
}
