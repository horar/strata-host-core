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
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets


SGWidgets.SGButton {
    id: userMenuButton

    icon.source: "qrc:/sgimages/user.svg"
    padding: 2
    scaleToFit: true
    backgroundOnlyOnHovered: true

    onClicked: {
        if (popupMenu.opened === false) {
            popupMenu.open()
        }
    }

    SGWidgets.SGPopup {
        id: popupMenu
        x: -popupMenu.width + parent.width
        y: 0

        padding: 2
        position: Item.Bottom

        contentItem: Item {
            implicitHeight: logoutMenuItem.y + logoutMenuItem.height
            implicitWidth: Math.max(header.x + header.width, 200) + 4

            Row {
                id: header
                anchors {
                    top: parent.top
                    topMargin: 6
                    left: parent.left
                    leftMargin: 4
                }

                spacing: 6

                SGWidgets.SGIcon {
                    width: height
                    height: logoutText.contentHeight
                    anchors.verticalCenter: parent.verticalCenter

                    source: "qrc:/sgimages/user.svg"
                    iconColor: userMenuButton.palette.text
                }

                SGWidgets.SGText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var t = ""
                        t = prtModel.authenticator.firstname + " " + prtModel.authenticator.lastname
                        t += "\n" + prtModel.authenticator.username

                        return t
                    }
                }
            }

            Item {
                id: logoutMenuItem

                height: logoutRow.height + 12
                width: parent.width
                anchors {
                    top: header.bottom
                    topMargin: 6
                }

                Rectangle {
                    id: divider
                    height: 1
                    width: parent.width - 40
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }

                    color: "black"
                    opacity: 0.3
                }

                Rectangle {
                    id: bg
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: divider.bottom
                        topMargin: 1
                        bottom: parent.bottom
                    }

                    color: {
                        if (logoutMouseArea.containsPress) {
                            return userMenuButton.palette.highlight
                        } else if (logoutMouseArea.containsMouse) {
                            return Qt.lighter(userMenuButton.palette.highlight, 1.2)
                        }

                        return "transparent"
                    }
                }

                Row {
                    id: logoutRow
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 4
                    }

                    spacing: 6

                    SGWidgets.SGIcon {
                        width: height
                        height: logoutText.contentHeight
                        anchors.verticalCenter: parent.verticalCenter

                        source: "qrc:/sgimages/sign-out.svg"
                        iconColor: logoutMouseArea.containsMouse ? "white" : userMenuButton.palette.text
                    }

                    SGWidgets.SGText {
                        id: logoutText
                        anchors.verticalCenter: parent.verticalCenter

                        alternativeColorEnabled: logoutMouseArea.containsMouse
                        font.bold: logoutMouseArea.containsMouse
                        text: "Log Out"
                    }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        prtModel.authenticator.logout()
                        popupMenu.close()
                    }
                }
            }
        }
    }
}
