import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants

Rectangle {
    id: root
    Text {
        id: header
        text: "Debug Commands and Notifications"
        font.bold: true
        font.pointSize: 18
        anchors {
            top: parent.top
            bottomMargin: 20
        }
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    ListModel {
        id: mainModel

        property var baseModel: ({
            "commands": [
                {"cmd":"my_cmd_simple","payload":{"dac":"double","io":"bool"}},
                {"cmd":"my_cmd_simple_periodic_update","payload":{"interval":"int","run_count":"int","run_state":"bool"}},
                {"cmd":"my_cmd_i2c","payload":null},
            ],
            "notifications": [
                {"payload":{"adc_read":"double","io_read":"bool","random_float":"double","random_float_array":["double"],"random_increment":["int","int"],"toggle_bool":"bool"},"value":"my_cmd_simple_periodic"},
            ]
        })

        Component.onCompleted: {
            let keys = Object.keys(baseModel);
            for (let j = 0; j < keys.length; j++) {
                let name = keys[j];
                let data = [];
                let commands = baseModel[name];
                for (let i = 0; i < commands.length; i++) {
                    let commandType = (name === "commands" ? "cmd" : "value");
                    let commandName = commands[i][commandType];
                    let payloadPropertyArr = [];

                    if (commands[i].hasOwnProperty("payload") && commands[i]["payload"]) {
                        let payload = commands[i]["payload"];
                        let payloadKeys = Object.keys(payload);

                        for (let key of payloadKeys) {
                            let type = getType(payload[key])
                            let arr = [];
                            if (type === "array") {
                                for (let subType of payload[key]) {
                                    arr.push({ "type": getType(subType) })
                                }
                            }

                            payloadPropertyArr.push({ "name": key, "type": type, "array": arr, "value": ""})
                        }
                    }

                    data.push({ "name": commandName, "type": commandType, "payload": payloadPropertyArr })
                }
                let type = {
                    "name": name,
                    "data": data
                }
                append(type)
            }
        }
    }
    ColumnLayout {
        id: columnContainer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: header.bottom
            margins: 5
        }

        spacing: 10

        Repeater {
            model: mainModel
            delegate: ColumnLayout {
                id: notificationCommandColumn
                Layout.fillHeight: true
                Layout.fillWidth: true
                property ListModel commandsModel: model.data

                Text {
                    font.pointSize: 16
                    font.bold: true
                    text: (model.name === "commands" ? "Commands" : "Notifications")
                }
                ListView {
                    id: mainListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 5
                    Layout.bottomMargin: 10
                    clip: true
                    spacing: 10
                    model: commandsModel
                    delegate: ColumnLayout {
                        width: parent.width

                        property ListModel payloadListModel: model.payload
                        spacing: 5

                        Rectangle {
                            Layout.preferredHeight: 1
                            Layout.fillWidth: true
                            Layout.rightMargin: 2
                            Layout.leftMargin: 2
                            Layout.alignment: Qt.AlignHCenter
                            color: "black"
                        }

                        Text {
                            font.pointSize: 14
                            font.bold: true
                            text: model.name
                        }

                        Repeater {
                            model: payloadListModel
                            delegate: RowLayout {
                                Layout.preferredHeight: 35

                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: model.name
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                }

                                TextField {
                                    id: payloadValueTextField
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 200
                                    text: placeholderText
                                    placeholderText: generatePlaceholder(model.type, model.array)

                                    selectByMouse: true
                                    Component.onCompleted: {
                                        model.value = text
                                    }
                                    onTextEdited: {
                                        model.value = text
                                    }
                                }
                            }
                        }
                        Button {
                            text: "Send " + (model.type === "cmd" ? "Command" : "Notification")
                            onClicked: {
                                let payloadArr = model.payload;
                                let payload = null;
                                if (payloadArr.count > 0) {
                                    payload = {}
                                    for (let i = 0; i < payloadArr.count; i++) {
                                        let payloadProp = payloadArr.get(i);
                                        if (payloadProp.type === "array") {
                                            if (payloadProp.value === "") {
                                                payload[payloadProp.name] = [];
                                            } else {
                                                payload[payloadProp.name] = JSON.parse(payloadProp.value)
                                            }
                                        } else if (payloadProp.type === "bool") {
                                            payload[payloadProp.name] = (payloadProp.value === "true");
                                        } else if (payloadProp.type === "int") {
                                            payload[payloadProp.name] = parseInt(payloadProp.value);
                                        } else if (payloadProp.type === "double") {
                                            payload[payloadProp.name] = parseFloat(payloadProp.value);
                                        } else {
                                            payload[payloadProp.name] = payloadProp.value
                                        }
                                    }
                                }
                                if (model.type === "value") {
                                    let notification = {
                                        "notification": {
                                            "value": model.name,
                                            "payload": payload
                                        }
                                    }
                                    let wrapper = { "device_id": Constants.NULL_DEVICE_ID, "message": JSON.stringify(notification) }
                                    coreInterface.notification(JSON.stringify(wrapper))
                                } else {
                                    let command = { "cmd": model.name, "device_id": Constants.NULL_DEVICE_ID }
                                    if (payload) {
                                        command["payload"] = payload;
                                    }
                                    coreInterface.sendCommand(JSON.stringify(command))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function generatePlaceholder(type, value) {
        if (type === "array") {
            let placeholder = "["
            for (let i = 0; i < value.count; i++) {
                let subType = getType(value.get(i).type);
                let arr = []
                if (subType === "array") {
                    arr = value.get(i)
                }
                placeholder += generatePlaceholder(subType, arr) + (i !== value.count - 1 ? "," : "")
            }
            placeholder += "]"
            return placeholder
        }
        else if (type === "int") { return "0"; }
        else if (type === "string") { return "\"\""; }
        else if (type === "double") { return "0.00"; }
        else if (type === "bool") { return "false"; }
        return ""
    }

    function getType(value) {
        if (Array.isArray(value)) {
            return "array"
        } else {
            return value
        }
    }
}
