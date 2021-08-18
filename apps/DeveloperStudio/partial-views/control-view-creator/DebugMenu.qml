import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants
import tech.strata.sgwidgets 0.9
import tech.strata.signals 1.0
import tech.strata.commoncpp 1.0

import "DebugMenu"

Rectangle {
    id: debugMenuRoot
    anchors.fill: parent

    property var json: ({})
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
        anchors {
            margins: 10
            fill: debugMenuRoot
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 35

            TabButton {
                text: "Notifications"
            }

            TabButton {
                text: "Commands"
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            border {
                width: 1
                color: "darkgrey"
            }
            color: "lightgrey"

            StackLayout {
                anchors {
                    fill: parent
                    margins: 1 // so border in parent Rectangle can be seen
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
                }
            }
        }
    }

    function updateAndCreatePayload(json) {
        if (Object.keys(json["payload"]).length === 0) {
            delete json["payload"]
        }
        if (json.hasOwnProperty("cmd")) {
            json.device_id = controlViewCreatorRoot.debugPlatform.deviceId
            coreInterface.sendCommand(JSON.stringify(json))
            console.log("DebugMenu - command sent:", JSON.stringify(json, null, 2))
        } else {
            let notification = {
                "notification": json
            }
            let wrapper = { "device_id": Constants.NULL_DEVICE_ID, "message": JSON.stringify(notification) }
            coreInterface.notification(JSON.stringify(wrapper))
            console.log("DebugMenu - notification sent:", JSON.stringify(json, null, 2))
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

