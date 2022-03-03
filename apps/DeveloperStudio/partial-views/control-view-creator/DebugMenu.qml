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
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants
import tech.strata.sgwidgets 0.9
import tech.strata.signals 1.0
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0

import "debug-menu"

Rectangle {
    id: debugMenuRoot
    anchors.fill: parent

    property var json: ({
                            "notifications": [],
                            "commands": []
                        })
    property url source: editor.fileTreeModel.debugMenuSource
    property string errorString: "No platformInterface.json detected in project" // default state is no pi.json found

    function init() {
        errorString = ""
        if (source.toString() !== "") {
            try {
                const localFile = SGUtilsCpp.urlToLocalFile(source)
                const jsonObject = JSON.parse(SGUtilsCpp.readTextFileContent(localFile))

                checkAPI(jsonObject)
                if (errorString !== "") {
                    return
                }
                debugMenuRoot.json = jsonObject
            } catch (e) {
                errorString = "platformInterface.json contains invalid JSON and could not be parsed"
            }
        } else {
            errorString = "No platformInterface.json detected in project"
        }
    }

    onSourceChanged: {
        // re-init if platformInterface.json is deleted or if project changes
        init()
    }

    Connections {
        target: editor.fileTreeModel

        onFileChanged: {
            // re-init upon changes to platformInterface.json (e.g. PIG generation etc)
            if (source === path) {
                init()
            }
        }
    }

    ColumnLayout {
        visible: !errorLayout.visible
        spacing: -1
        anchors {
            fill: debugMenuRoot
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            spacing: 0

            TabButton {
                background: Rectangle {
                    id: backGroundRectNotif
                    height: 35
                    color: tabBar.currentIndex === 0 ? Theme.palette.lightGray : mouseNotifArea.containsMouse ? Theme.palette.gray: Theme.palette.darkGray

                    MouseArea {
                        id: mouseNotifArea
                        hoverEnabled: true
                        anchors.fill: parent

                        onClicked: {
                            tabBar.currentIndex = 0
                        }
                    }

                    Text {
                        id: notifText
                        text: "Notifications"
                        anchors.centerIn: backGroundRectNotif
                        color: tabBar.currentIndex === 0 ? "black" : "lightgrey"
                    }

                    Rectangle {
                        width: notifText.width
                        height: 2
                        radius: height/2
                        color: Theme.palette.darkGray
                        visible: tabBar.currentIndex === 0
                        anchors.top: notifText.bottom
                        anchors.horizontalCenter: backGroundRectNotif.horizontalCenter
                    }
                }
            }

            TabButton {
                background: Rectangle {
                    id: backGroundRectCommand
                    height: 35
                    color: tabBar.currentIndex === 1 ? Theme.palette.lightGray : mouseCommandArea.containsMouse ? Theme.palette.gray: Theme.palette.darkGray

                    MouseArea {
                        id: mouseCommandArea
                        hoverEnabled: true
                        anchors.fill: parent

                        onClicked: {
                            tabBar.currentIndex = 1
                        }
                    }

                    Text {
                        id: commandText
                        text: "Commands"
                        anchors.centerIn: backGroundRectCommand
                        color: tabBar.currentIndex === 1 ? "black" : "lightgrey"
                    }

                    Rectangle {
                        width: commandText.width
                        height: 2
                        radius: height/2
                        color: Theme.palette.darkGray
                        visible: tabBar.currentIndex === 1
                        anchors.top: commandText.bottom
                        anchors.horizontalCenter: backGroundRectCommand.horizontalCenter
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "lightgrey"

            StackLayout {
                anchors {
                    fill: parent
                    topMargin: 5
                }
                currentIndex: tabBar.currentIndex

                SGAccordion {
                    id: notifications
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    exclusive: false

                    property var jsonModel: debugMenuRoot.json["notifications"]

                    accordionItems: Column {
                        width: notifications.width

                        Repeater {
                            model: notifications.jsonModel

                            delegate: SGAccordionItem {
                                id: notification
                                title: modelData.value
                                open: false
                                visible: true

                                contents: DebugDelegate {
                                    type: "Notification"
                                    payload: modelData.payload
                                    name: notification.title
                                }

                                onOpenChanged: {
                                    if (open) {
                                        notification.openContent.start()
                                    } else {
                                        notification.closeContent.start()
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "No notifications found in platformInterface.json"
                        visible: notifications.jsonModel && notifications.jsonModel.length === 0
                        anchors {
                            centerIn: parent
                        }
                        width: parent.width
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGAccordion {
                    id: commands
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    exclusive: false

                    property var jsonModel: debugMenuRoot.json["commands"]

                    accordionItems: Column {
                        width: commands.width

                        Repeater {
                            model: commands.jsonModel

                            delegate: SGAccordionItem {
                                id: command
                                title: modelData.cmd
                                open: false
                                visible: true

                                contents: DebugDelegate {
                                    type: "Command"
                                    payload: modelData.payload
                                    name: command.title
                                }

                                onOpenChanged: {
                                    if (open) {
                                        command.openContent.start()
                                    } else {
                                        command.closeContent.start()
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "No commands found in platformInterface.json"
                        visible: commands.jsonModel && commands.jsonModel.length === 0
                        anchors {
                            centerIn: parent
                        }
                        width: parent.width
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: errorLayout
        visible: debugMenuRoot.errorString.length > 0
        anchors.centerIn: debugMenuRoot
        width: debugMenuRoot.width
        spacing: 10

        SGIcon {
            id: errorIcon
            source: "qrc:/sgimages/exclamation-circle.svg"
            Layout.preferredWidth: 50
            Layout.preferredHeight: Layout.preferredWidth
            iconColor: "grey"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: errorString
            font.pixelSize: 13 * 1.1
            wrapMode: Text.Wrap
            Layout.margins: 10
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }

    function updateAndCreatePayload(json) {
        if (Object.keys(json["payload"]).length === 0) {
            delete json["payload"]
        }
        if (json.hasOwnProperty("cmd")) {
            console.log("DebugMenu - sending command:", JSON.stringify(json, null, 2))
            coreInterface.sendNotification("platform_message", {"device_id": controlViewCreatorRoot.debugPlatform.device_id, "message": JSON.stringify(json)})
        } else {
            let notification = {
                "notification": json
            }
            let wrapper = { "device_id": Constants.NULL_DEVICE_ID, "message": JSON.stringify(notification) }
            console.log("DebugMenu - sending notification:", JSON.stringify(json, null, 2))
            coreInterface.notification(JSON.stringify(wrapper))
        }
    }

    function checkAPI(jsonObject) {
        errorString = ""
        let commandsFound = false
        let notificationsFound = false
        if (jsonObject.hasOwnProperty("commands") && jsonObject.commands.length > 0) {
            for (let i = 0; i < jsonObject.commands.length; i++) {
                if (jsonObject.commands[i].hasOwnProperty("payload")) {
                    if (Array.isArray(jsonObject.commands[i].payload) === false) {
                        errorString = "Deprecated platformInterface.json API detected, import to PIG tool and regenerate to update API"
                    }
                    return
                }
            }
            commandsFound = true
        }

        if (jsonObject.hasOwnProperty("notifications") && jsonObject.notifications.length > 0) {
            for (let j = 0; j < jsonObject.notifications.length; j++) {
                if (jsonObject.notifications[j].hasOwnProperty("payload")) {
                    if (Array.isArray(jsonObject.notifications[j].payload) === false) {
                        errorString = "Deprecated platformInterface.json API detected, import to PIG tool and regenerate to update API"
                    }
                    return
                }
            }
            notificationsFound = true
        }

        if (notificationsFound === false && commandsFound === false) {
            errorString = "Could not parse platformInterface.json - must contain notifications or commands"
        }
    }
}

