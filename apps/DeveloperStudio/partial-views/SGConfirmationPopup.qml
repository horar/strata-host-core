/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "qrc:/partial-views"
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Popup {
    id: root
    width: 500
    height: confirmationContainer.height
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    modal: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property alias titleText: confirmTitle.text
    property alias popupText: confirmText.text
    property var defaultButtons: [
        {
            buttonText: acceptButtonText,
            buttonColor: acceptButtonColor,
            buttonHoverColor: acceptButtonHoverColor,
            closeReason: root.acceptCloseReason
        },
        {
            buttonText: cancelButtonText,
            buttonColor: cancelButtonColor,
            buttonHoverColor: cancelButtonHoverColor,
            closeReason: root.cancelCloseReason
        }
    ]
    property var buttons: defaultButtons
    property string acceptButtonText: "Accept"
    property string cancelButtonText: "Cancel"
    property color acceptButtonColor: "#999"
    property color acceptButtonHoverColor: "#666"
    property color cancelButtonColor: "#999"
    property color cancelButtonHoverColor: "#666"

    readonly property int cancelCloseReason: 0
    readonly property int acceptCloseReason: 1

    signal popupClosed(int closeReason);

    onPopupClosed: {
        close();
    }

    DropShadow {
        width: root.width
        height: root.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: root.background
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
                        right: confirmTitleText.left
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
                        onClicked: {
                            root.popupClosed(root.cancelCloseReason)
                            close()
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Row {
                width: confirmationContainer.width - 10
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Text {
                    id: confirmText
                    color: "black"
                    text: "Are you sure you would like to continue?"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Row {
                id: row1
                spacing: 20
                anchors {
                    horizontalCenter: column2.horizontalCenter
                }

                Repeater {
                    id: buttonRepeater
                    model: buttons

                    delegate: Button {
                        id: delegateRoot
                        text: modelData.buttonText

                        contentItem: Text {
                            text: delegateRoot.text
                            font.pixelSize: 12
                            font.family: Fonts.franklinGothicBook
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            id: btnBg
                            implicitWidth: 100
                            implicitHeight: 40
                            color: modelData.buttonColor
                        }

                        onClicked: {
                            root.popupClosed(modelData.closeReason)
                        }

                        Accessible.onPressAction: function() {
                            clicked()
                        }

                        MouseArea {
                            id: btnCursor

                            hoverEnabled: true
                            anchors.fill: parent
                            onPressed:  mouse.accepted = false
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                btnBg.color = modelData.buttonHoverColor
                            }

                            onExited: {
                                btnBg.color = modelData.buttonColor
                            }
                        }
                    }
                }
            }
        }
    }
}
