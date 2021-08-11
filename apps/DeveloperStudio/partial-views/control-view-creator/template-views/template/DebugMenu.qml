import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "qrc:/js/constants.js" as Constants
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.commoncpp 1.0

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

    Component.onCompleted: {
        const jsonObject = JSON.parse(SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(editor.fileTreeModel.debugMenuSource.toString().split("DebugMenu.qml")[0]+"platformInterface.json")))
        createBaseModel(jsonObject)
    }

    ListModel {
        id: mainModel
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
                        spacing: 5

                        property ListModel payloadListModel: model.payload

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
                                        visible: model.type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC && model.type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC && model.type !== "bool"
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
                                        text: model.value

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
                                        if (payloadProp.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                                            payload[payloadProp.name] = createJsonObjectFromArrayProperty(payloadProp.array);
                                        } else if (payloadProp.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                                            payload[payloadProp.name] = createJsonObjectFromObjectProperty(payloadProp.object);
                                        } else if (payloadProp.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC) {
                                            payload[payloadProp.name] = []
                                        } else if (payloadProp.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC) {
                                            payload[payloadProp.name] = {}
                                        } else {
                                            payload[payloadProp.name] = getTypedValue(payloadProp.type, payloadProp.value)
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
                                    console.log("NOTIFICATION", JSON.stringify(notification, null, 2))
                                    coreInterface.notification(JSON.stringify(wrapper))
                                } else {
                                    let command = { "cmd": model.name, "device_id": controlViewCreatorRoot.debugPlatform.deviceId }
                                    if (payload) {
                                        command["payload"] = payload;
                                    }
                                    console.log("COMMAND", JSON.stringify(command, null, 2))
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
                    visible: modelData.type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC && modelData.type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC && modelData.type !== "bool"
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
                    text: modelData.value

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
                    text: modelData.name
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
                    visible: modelData.type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC && modelData.type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC && modelData.type !== "bool"
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
                    text: modelData.value

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

    function generateArrayModel(arr, parentListModel) {
        for (let i = 0; i < arr.length; i++) {
            const type = arr[i].type
            let obj = {"type": type, "array": [], "object": [], "value": ""};

            if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                    type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                obj["value"] = String(arr[i].value)
            }

            parentListModel.append(obj);

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModel(arr[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModel(arr[i].value, parentListModel.get(i).object)
            }
        }
    }

    /**
    * This function takes an Object and transforms it into an array readable by our delegates
    **/
    function generateObjectModel(object, parentListModel) {
        for (let i = 0; i < object.length; i++) {
            const type = object[i].type
            let obj = {"name": object[i].name, "type": type, "array": [], "object": [], "value": "" };

            if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                    type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                obj["value"] = String(object[i].value)
            }

            parentListModel.append(obj);

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModel(object[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModel(object[i].value, parentListModel.get(i).object)
            }
        }
    }

    function createJsonObjectFromArrayProperty(model) {
        let outputArr = []
        for (let m = 0; m < model.count; m++) {
            let arrayElement = model.get(m)
            let value

            if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                value = createJsonObjectFromArrayProperty(arrayElement.array)
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                value = createJsonObjectFromArrayProperty(arrayElement.object)
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC) {
                value = []
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC) {
                value = {}
            } else {
                value = getTypedValue(arrayElement.type, arrayElement.value)
            }
            outputArr.push(value)
        }
        return outputArr
    }

    function createJsonObjectFromObjectProperty(objectModel) {
        let outputObj = {}
        for (let i = 0; i < objectModel.count; i++) {
            let objectProperty = objectModel.get(i);

            // Recurse through array
            if (objectProperty.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                outputObj[objectProperty.name] = createJsonObjectFromArrayProperty(objectProperty.array)
            } else if (objectProperty.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                outputObj[objectProperty.name] = createJsonObjectFromObjectProperty(objectProperty.object)
            } else if (objectProperty.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC) {
                outputObj[objectProperty.name] = []
            } else if (objectProperty.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC) {
                outputObj[objectProperty.name] = {}
            } else {
                outputObj[objectProperty.name] = getTypedValue(objectProperty.type, objectProperty.value)
            }
        }
        return outputObj;
    }

    /**
      * Convert string values to typed values
     **/
    function getTypedValue (type, value) {
        switch (type) {
            case "int":
                return parseInt(value)
            case "double":
                return parseFloat(value)
            case "bool":
                if (value === "false") {
                    return false
                } else {
                    return true
                }
            default: // case "string"
                return value
        }
    }


    function createBaseModel(jsonObject) {
        let topLevelKeys = Object.keys(jsonObject); // This contains "commands" / "notifications" arrays

        mainModel.modelAboutToBeReset()
        mainModel.clear();

        for (let i = 0; i < topLevelKeys.length; i++) {
            const topLevelType = topLevelKeys[i];
            const arrayOfCommandsOrNotifications = jsonObject[topLevelType];
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
                    let payloadModel = commandsModel.get(j).payload;
                    for (let k = 0; k < payload.length; k++) {
                        const payloadProperty = payload[k]
                        const type = payloadProperty.type

                        let payloadPropObject = {}
                        payloadPropObject["name"] = payloadProperty.name
                        payloadPropObject["type"] = type
                        payloadPropObject["array"] = []
                        payloadPropObject["object"] = []

                        if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                                type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                            payloadPropObject["value"] = String(payloadProperty.value)
                        } else {
                            payloadPropObject["value"] = ""
                        }

                        payloadModel.append(payloadPropObject)

                        if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                            generateArrayModel(payloadProperty.value, payloadModel.get(k).array)
                        } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                            generateObjectModel(payloadProperty.value, payloadModel.get(k).object)
                        }
                    }
                }
            }
        }

        mainModel.modelReset()
    }

    Connections {
        target: Signals

        onPlatformInterfaceUpdate: {
            createBaseModel(json)
        }
    }
}
