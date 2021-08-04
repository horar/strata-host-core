import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root

    border.color: "black"
    border.width: 1

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
            ],
            "notifications": [
            ]
        })

        Component.onCompleted: {
            let topLevelKeys = Object.keys(baseModel); // This contains "commands" / "notifications" arrays

            mainModel.modelAboutToBeReset()
            mainModel.clear();

            for (let i = 0; i < topLevelKeys.length; i++) {
                const topLevelType = topLevelKeys[i];
                const arrayOfCommandsOrNotifications = baseModel[topLevelType];
                let listOfCommandsOrNotifications = {
                    "name": topLevelType, // "commands" / "notifications"
                    "data": []
                }

                mainModel.append(listOfCommandsOrNotifications);

                for (let j = 0; j < arrayOfCommandsOrNotifications.length; j++) {
                    let commandsModel = mainModel.get(i).data;

                    let cmd = arrayOfCommandsOrNotifications[j];
                    let commandName;
                    let commandType;
                    let commandObject = {};

                    if (topLevelType === "commands") {
                        // If we are dealing with commands, then look for the "cmd" key
                        commandName = cmd["cmd"];
                        commandType = "cmd";
                    } else {
                        commandName = cmd["value"];
                        commandType = "value";
                    }

                    commandObject["type"] = commandType;
                    commandObject["name"] = commandName;
                    commandObject["payload"] = [];

                    commandsModel.append(commandObject);

                    const payload = cmd.hasOwnProperty("payload") ? cmd["payload"] : null;
                    let payloadPropertiesArray = [];

                    if (payload) {
                        let payloadProperties = Object.keys(payload);
                        let payloadModel = commandsModel.get(j).payload;
                        for (let k = 0; k < payloadProperties.length; k++) {
                            const key = payloadProperties[k];
                            const type = getType(payload[key]);
                            let payloadPropObject = {};
                            payloadPropObject["name"] = key;
                            payloadPropObject["type"] = type;
                            payloadPropObject["value"] = "";
                            payloadPropObject["array"] = [];
                            payloadPropObject["object"] = [];
                            payloadModel.append(payloadPropObject);

                            if (type === "array") {
                                generateArrayModel(payload[key], payloadModel.get(k).array);
                            } else if (type === "object") {
                                generateObjectModel(payload[key], payloadModel.get(k).object);
                            }
                        }
                    }
                }
            }

            mainModel.modelReset()
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
                        width: ListView.view.width

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
                            delegate: ColumnLayout {
                                id: payloadContainer

                                Layout.fillWidth: true
                                Layout.leftMargin: 10

                                property ListModel subArrayListModel: model.array
                                property ListModel subObjectListModel: model.object

                                RowLayout {
                                    Layout.preferredHeight: 35

                                    Text {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: 200
                                        text: model.name
                                        font.bold: true
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight

                                    }

                                    SGTextField {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Layout.maximumWidth: 175
                                        placeholderText: generatePlaceholder(model.type, model.value)
                                        selectByMouse: true
                                        visible: model.type !== "array" && model.type !== "object" && model.type !== "bool"
                                        contextMenuEnabled: true
                                        validator: RegExpValidator {
                                            regExp: {
                                                if (model.type === "int") {
                                                    return /^[0-9]+$/
                                                } else if (model.type === "double") {
                                                    return /^[0-9]+\.[0-9]+$/
                                                } else {
                                                    return /^.*$/
                                                }
                                            }
                                        }

                                        onTextChanged: {
                                            model.value = text
                                        }
                                    }

                                    SGSwitch {
                                        Layout.preferredWidth: 70
                                        checkedLabel: "True"
                                        uncheckedLabel: "False"
                                        visible: model.type === "bool"

                                        onToggled: {
                                            model.value = (checked ? "true" : "false")
                                        }
                                    }
                                }

                                Repeater {
                                    model: payloadContainer.subArrayListModel
                                    delegate: Component {
                                        Loader {
                                            sourceComponent: arrayStaticFieldComponent
                                            onStatusChanged: {
                                                if (status === Loader.Ready) {
                                                    item.modelData = Qt.binding(() => model)
                                                    item.modelIndex = index
                                                }
                                            }
                                        }
                                    }
                                }

                                Repeater {
                                    model: payloadContainer.subObjectListModel
                                    delegate: Component {
                                        Loader {
                                            sourceComponent: objectStaticFieldComponent
                                            onStatusChanged: {
                                                if (status === Loader.Ready) {
                                                    item.modelData = Qt.binding(() => model)
                                                    item.modelIndex = index
                                                }
                                            }
                                        }
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
                                            payload[payloadProp.name] = createJsonObjectFromArrayProperty(payloadProp.array, []);
                                        } else if (payloadProp.type === "object") {
                                            payload[payloadProp.name] = createJsonObjectFromObjectProperty(payloadProp.object, {});
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
                                    let command = { "cmd": model.name, "device_id": controlViewCreatorRoot.debugPlatform.deviceId }
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


    /********* COMPONENTS AND FUNCTIONS *********/

    Component {
        id: arrayStaticFieldComponent

        ColumnLayout {
            id: arrayColumnLayout
            Layout.leftMargin: 10

            property var modelData
            property ListModel subArrayListModel: modelData.array
            property ListModel subObjectListModel: modelData.object

            property int modelIndex: index

            RowLayout {
                Layout.preferredHeight: 30
                Layout.leftMargin: 10
                spacing: 5

                Text {
                    text: "[Index " + modelIndex  + "] Element type: " + modelData.type
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                SGTextField {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumWidth: 175
                    placeholderText: generatePlaceholder(modelData.type, modelData.value)
                    selectByMouse: true
                    visible: modelData.type !== "array" && modelData.type !== "object" && modelData.type !== "bool"
                    contextMenuEnabled: true
                    validator: RegExpValidator {
                        regExp: {
                            if (modelData.type === "int") {
                                return /^[0-9]+$/
                            } else if (modelData.type === "double") {
                                return /^[0-9]+\.[0-9]+$/
                            } else {
                                return /^.*$/
                            }
                        }
                    }

                    onTextChanged: {
                        modelData.value = text
                    }
                }

                SGSwitch {
                    Layout.preferredWidth: 70
                    checkedLabel: "True"
                    uncheckedLabel: "False"
                    visible: modelData.type === "bool"

                    onToggled: {
                        modelData.value = (checked ? "true" : "false")
                    }
                }
            }

            Repeater {
                model: arrayColumnLayout.subArrayListModel

                delegate: Component {
                    Loader {
                        Layout.leftMargin: 10
                        sourceComponent: arrayStaticFieldComponent

                        onStatusChanged: {
                            if (status === Loader.Ready) {
                                item.modelData = Qt.binding(() => model)
                                item.modelIndex = index
                            }
                        }
                    }
                }
            }

            Repeater {
                model: arrayColumnLayout.subObjectListModel
                delegate: Component {
                    Loader {
                        Layout.leftMargin: 10
                        sourceComponent: objectStaticFieldComponent

                        onStatusChanged: {
                            if (status === Loader.Ready) {
                                item.modelData = Qt.binding(() => model)
                                item.modelIndex = index
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: objectStaticFieldComponent

        ColumnLayout {
            id: objColumnLayout
            Layout.leftMargin: 10

            property var modelData
            property ListModel subArrayListModel: modelData.array
            property ListModel subObjectListModel: modelData.object

            property int modelIndex

            RowLayout {
                Layout.preferredHeight: 30
                Layout.leftMargin: 10
                spacing: 5

                Text {
                    text: modelData.key
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    elide: Text.ElideRight
                }

                SGTextField {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.maximumWidth: 175
                    placeholderText: generatePlaceholder(modelData.type, modelData.value)
                    selectByMouse: true
                    visible: modelData.type !== "array" && modelData.type !== "object" && modelData.type !== "bool"
                    contextMenuEnabled: true
                    validator: RegExpValidator {
                        regExp: {
                            if (modelData.type === "int") {
                                return /^[0-9]+$/
                            } else if (modelData.type === "double") {
                                return /^[0-9]+\.[0-9]+$/
                            } else {
                                return /^.*$/
                            }
                        }
                    }

                    onTextChanged: {
                        modelData.value = text
                    }
                }

                SGSwitch {
                    Layout.preferredWidth: 70
                    checkedLabel: "True"
                    uncheckedLabel: "False"
                    visible: modelData.type === "bool"

                    onToggled: {
                        modelData.value = (checked ? "true" : "false")
                    }
                }
            }

            Repeater {
                model: objColumnLayout.subArrayListModel

                delegate: Component {
                    Loader {
                        Layout.leftMargin: 10
                        sourceComponent: arrayStaticFieldComponent

                        onStatusChanged: {
                            if (status === Loader.Ready) {
                                item.modelData = Qt.binding(() => model)
                                item.modelIndex = index
                            }
                        }
                    }
                }
            }

            Repeater {
                model: objColumnLayout.subObjectListModel
                delegate: Component {
                    Loader {
                        Layout.leftMargin: 10
                        sourceComponent: objectStaticFieldComponent

                        onStatusChanged: {
                            if (status === Loader.Ready) {
                                item.modelData = Qt.binding(() => model)
                                item.modelIndex = index
                            }
                        }
                    }
                }
            }
        }
    }

    function generatePlaceholder(type, value) {
        if (type === "int") { return "0"; }
        else if (type === "string") { return "\"\""; }
        else if (type === "double") { return "0.00"; }
        else if (type === "bool") { return "false"; }
        return ""
    }

    function getType(value) {
        if (Array.isArray(value)) {
            return "array";
        } else if (typeof value === "object") {
            return "object";
        } else {
            return value;
        }
    }

    function generateArrayModel(arr, parentListModel) {
        for (let i = 0; i < arr.length; i++) {
            const type = getType(arr[i]);
            let obj = {"type": type, "array": [], "object": [], "value": ""};

            parentListModel.append(obj);

            if (type === "array") {
                generateArrayModel(arr[i], parentListModel.get(i).array)
            } else if (type === "object") {
                generateObjectModel(arr[i], parentListModel.get(i).object)
            }
        }
    }

    /**
    * This function takes an Object and transforms it into an array readable by our delegates
    **/
    function generateObjectModel(object, parentListModel) {
        let keys = Object.keys(object);
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i];
            const type = getType(object[key]);

            let obj = {"key": key, "type": type, "array": [], "object": [], "value": "" };

            parentListModel.append(obj);

            if (type === "array") {
                generateArrayModel(object[key], parentListModel.get(i).array)
            } else if (type === "object") {
                generateObjectModel(object[key], parentListModel.get(i).object)
            }
        }
    }

    function createJsonObjectFromArrayProperty(arrayModel, outputArr) {
        for (let m = 0; m < arrayModel.count; m++) {
            let arrayElement = arrayModel.get(m);

            if (arrayElement.type === "object") {
                outputArr.push(createJsonObjectFromObjectProperty(arrayElement.object, {}))
            } else if (arrayElement.type === "array") {
                outputArr.push(createJsonObjectFromArrayProperty(arrayElement.array, []))
            } else if (arrayElement.type === "bool") {
                outputArr.push((arrayElement.value === "true"))
            } else if (arrayElement.type === "int") {
                outputArr.push(parseInt(arrayElement.value))
            } else if (arrayElement.type === "double") {
                outputArr.push(parseFloat(arrayElement.value))
            } else {
                outputArr.push(arrayElement.value)
            }
        }
        return outputArr;
    }

    function createJsonObjectFromObjectProperty(objectModel, outputObj) {
        for (let i = 0; i < objectModel.count; i++) {
            let objectProperty = objectModel.get(i);

            // Recurse through array
            if (objectProperty.type === "array") {
                outputObj[objectProperty.key] = createJsonObjectFromArrayProperty(objectProperty.array, [])
            } else if (objectProperty.type === "object") {
                outputObj[objectProperty.key] = createJsonObjectFromObjectProperty(objectProperty.object, {})
            } else if (objectProperty.type === "bool") {
                outputObj[objectProperty.key] = (objectProperty.value === "true")
            } else if (objectProperty.type === "int") {
                outputObj[objectProperty.key] = parseInt(objectProperty.value)
            } else if (objectProperty.type === "double") {
                outputObj[objectProperty.key] = parseFloat(objectProperty.value)
            } else {
                outputObj[objectProperty.key] = objectProperty.value
            }
        }
        return outputObj;
    }
}
