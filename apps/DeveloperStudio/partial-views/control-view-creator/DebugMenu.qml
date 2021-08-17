import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants
import tech.strata.sgwidgets 0.9
import tech.strata.signals 1.0
import tech.strata.commoncpp 1.0

import "./DebugMenu"

Rectangle {
    id: debugMenuRoot
    anchors.fill: parent

    property var json: ({})
    property url source
    property string errorString

    Component.onCompleted: {
        init()
    }

    function init() {
        errorString = ""
        if (source !== "") {
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

    Connections {
        target: editor.fileTreeModel

        onFileChanged: {
            if (source === path) {
                init()
            }
        }
    }

    ColumnLayout {
        visible: !errorLayout.visible
        spacing: 0
        anchors {
            margins: 10
            fill: debugMenuRoot
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            spacing: 0

            TabButton {
                text: "Notifications"
                background: Rectangle {
                    color: tabBar.currentIndex === 0 ? "lightGrey" : mouseNotifArea.containsMouse ? "grey" : "transparent"
                    MouseArea {
                        id: mouseNotifArea
                        hoverEnabled: true
                        anchors.fill: parent

                        onClicked: {
                            tabBar.currentIndex = 0
                        }
                    }
                }
            }

            TabButton {
                text: "Commands"
                background: Rectangle {
                    color: tabBar.currentIndex === 1 ? "lightGrey" : mouseCommandArea.containsMouse ? "grey" : "transparent"
                    MouseArea {
                        id: mouseCommandArea
                        hoverEnabled: true
                        anchors.fill: parent

                        onClicked: {
                            tabBar.currentIndex = 1
                        }
                    }
                }
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

    ColumnLayout {
        id: errorLayout
        visible: debugMenuRoot.errorString.length > 0
        anchors.fill: debugMenuRoot

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        SGIcon {
            id: errorIcon
            source: "qrc:/sgimages/exclamation-circle.svg"
            Layout.preferredWidth: 50
            height: Layout.preferredWidth
            iconColor: "grey"
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.preferredHeight: 10
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            Text {
               text: errorString
               font.pixelSize: 13 * 1.1
               wrapMode: Text.WordWrap
               anchors.centerIn: parent
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
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
        if (jsonObject.hasOwnProperty("commands") && jsonObject.commands.length > 0) {
            for (let i = 0; i < jsonObject.commands.length; i++) {
                if (jsonObject.commands[i].hasOwnProperty("payload")) {
                    if (Array.isArray(jsonObject.commands[i].payload) === false) {
                        errorString = "Deprecated platformInterface.json API detected, import to PIG tool and regenerate to update API"
                    }
                    return
                }
            }
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
        }
        errorString = "Could not parse platformInterface.json - must contain notifications or commands"
    }
}

