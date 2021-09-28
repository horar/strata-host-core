/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.notifications 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/restclient.js" as Rest
import "qrc:/js/constants.js" as Constants
import "qrc:/js/platform_selection.js" as PlatformSelection

Item {
    id: root

    Rectangle {
        id: commandBar
        visible: false
        width: parent.width
        height: flow.height
        color: "lightgrey"
        anchors {
            bottom: parent.bottom
        }

        // Buttons for event simulation
        Flow {
            id: flow
            anchors {
                left: commandBar.left
                right: commandBar.right
            }
            layoutDirection: Qt.RightToLeft
            spacing: 2

            Button {
                text: "Log Viewer App"

                onClicked: {
                    var errMessage = sdsModel.openLogViewer()
                    if (errMessage !== "") {
                        SGWidgets.SGDialogJS.showMessageDialog(
                            ApplicationWindow.window,
                            SGWidgets.SGMessageDialog.Error,
                            qsTr("Log Viewer can't be opened."),
                            errMessage)
                    }
                }
            }

            Button {
                text: "Platform List Controls"

                onClicked: {
                    localPlatformListDialog.setVisible(true)
                    localPlatformListDialog.raise()
                }
            }

            SGLocalPlatformListPopup {
                id: localPlatformListDialog
            }

            Button {
                text: "Reset Window Size"
                onClicked: mainWindow.resetWindowSize()
            }

            Button {
                text: "Login as Guest"
                onClicked: {
                    if (NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE) {
                        Notifications.currentUser = Constants.GUEST_USER_ID
                        NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                    }
                }
            }

            CheckBox {
                id: alwaysLogin
                text: "Always Login as Guest"
                onCheckedChanged: {
                    if (checked && NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE && sdsModel.hcsConnected) {
                        Notifications.currentUser = Constants.GUEST_USER_ID
                        NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                    }
                }

                QtLabsSettings.Settings {
                    id: settings
                    category: "Login"
                    property alias loginAsGuest: alwaysLogin.checked
                }

                Connections {
                    target: sdsModel
                    onHcsConnectedChanged: {
                        if (sdsModel.hcsConnected && alwaysLogin.checked) {
                            NavigationControl.updateState(NavigationControl.events.CONNECTION_ESTABLISHED_EVENT)
                            Notifications.currentUser = Constants.GUEST_USER_ID
                            NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                        }
                    }
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Log level:")
                }

                SGWidgets.SGLogLevelSelector {
                }
            }
        }
    }

    MouseArea {
        id: debugCloser
        visible: commandBar.visible
        anchors {
            left: commandBar.left
            right: commandBar.right
            bottom: commandBar.top
            bottomMargin: 40
            top: parent.top
        }
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                commandBar.visible = false
            }
        }
    }

    Rectangle {
        id: debugButton
        enabled: false
        height: 30
        width: 70
        visible: debugMouse.containsMouse
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: "#666"

        Text {
            text: qsTr("DEBUG")
            anchors.centerIn: debugButton
            color: "white"
        }
    }

    MouseArea {
        id: debugMouse
        visible: !commandBar.visible
        anchors {
            fill: debugButton
        }
        hoverEnabled: !commandBar.visible
        onClicked: {
            commandBar.visible = true
        }
    }

    SGQmlErrorListButton {
        id: qmlErrorListButton

        visible: qmlErrorModel.count !== 0
        text: qsTr("%1 QML warnings").arg(qmlErrorModel.count)
        checked: qmlErrorListPopUp.visible

        onCheckedChanged: checked ? qmlErrorListPopUp.open() : qmlErrorListPopUp.close()

        ListModel {
            id: qmlErrorModel
        }

        Connections {
            target: sdsModel
            onNotifyQmlError: {
                if (sdsModel.qtLogger.visualEditorReloading === false) {
                    qmlErrorModel.append({"data" : notifyQmlError})
                }
            }
        }
    }

    SGQmlErrorListPopUp {
        id: qmlErrorListPopUp
        topMargin: 32
        leftMargin: 32
        anchors.centerIn: ApplicationWindow.overlay
        title: qmlErrorListButton.text
        qmlErrorListModel: qmlErrorModel
    }
}
