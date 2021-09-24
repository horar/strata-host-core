/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    id: wind
    visible: true
    width: 640
    height: 480
    title: qsTr("SGDrawerMenu")

    SGDrawerMenu {
        id: sgDrawerMenu

        drawerMenuItems: Item {

            SGDrawerMenuItem {
                label: "Users"
                icon:"icons/users-solid.svg"
                contentDrawerWidth: 250
                drawerContent: Text {
                    text: "<b>Users</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            SGDrawerMenuItem {
                label: "Chat"
                icon:"icons/comments-solid.svg"
                drawerColor: "lightsalmon"
                drawerContent: Text {
                    text: "<b>Chat</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            SGDrawerMenuItem {
                label: "Help"
                icon:"icons/question-circle-solid.svg"
                drawerColor: "burlywood"
                contentDrawerWidth: 400
                drawerContent: Text {
                    text: "<b>Help</b>"
                    font {
                        pixelSize: 50
                    }
                    color: "#fff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
