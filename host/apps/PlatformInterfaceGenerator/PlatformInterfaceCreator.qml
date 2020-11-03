import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import tech.strata.sgwidgets 1.0
import tech.strata.SGUtilsCpp 1.0

Rectangle {
    id: root

    readonly property var baseModel: ({
        "commands": [],
        "notifications": []
    });

    readonly property var templateCommand: ({
        "type": "cmd",
        "name": "",
        "valid": false,
        "payload": [],
        "editing": false
    });

    readonly property var templateNotification: ({
        "type": "value",
        "name": "",
        "valid": false,
        "payload": [
            templatePayload
        ],
        "editing": false
    });

    readonly property var templatePayload: ({
        "name": "", // The name of the property
        "type": "int", // Type of the property, "array", "int", "string", etc.
        "valid": false,
        "array": [] // This is only filled if the type == "array"
    });

    /**
      * This function creates the JSON object to output
     **/
    function createJsonObject() {
        let obj = {};

        for (let i = 0; i < finishedModel.count; i++) {
            let type = finishedModel.get(i);
            let commands = [];

            for(let j = 0; j < type.data.count; j++) {
                let command = type.data.get(j);
                let commandObj = {};
                commandObj[command.type] = command.name;

                if (command.payload.count === 0) {
                    commandObj["payload"] = null;
                    commands.push(commandObj);
                    continue;
                } else {
                    commandObj["payload"] = {};
                }

                for (let k = 0; k < command.payload.count; k++) {
                    let payloadProperty = command.payload.get(k);

                    if (payloadProperty.type !== "array") {
                        commandObj["payload"][payloadProperty.name] = payloadProperty.type;
                    } else {
                        let arrayElements = [];
                        for (let m = 0; m < payloadProperty.array.count; m++) {
                            let arrayElement = payloadProperty.array.get(m);
                            arrayElements.push(arrayElement.type)
                        }
                        commandObj["payload"][payloadProperty.name] = arrayElements;
                    }
                }
                commands.push(commandObj)
            }
            obj[type.name] = commands;
        }
        return obj;
    }

    ListModel {
        id: finishedModel

        Component.onCompleted: {
            let keys = Object.keys(baseModel);
            for (let i = 0; i < keys.length; i++) {
                let name = keys[i];
                let type = {
                    "name": name, // "commands" / "notifications"
                    "data": []
                }

                append(type)
            }
        }

        /**
          * This function checks if all fields are valid
         **/
        function checkForAllValid() {
            for (let i = 0; i < count; i++) {
                let commands = get(i).data;
                for (let k = 0; k < commands.count; k++) {
                    let valid = true;
                    if (commands.get(k).name === "") {
                        commands.setProperty(k, "valid", false)
                        console.error("Empty", i === 0 ? "command" : "notification", "name at index", k)
                        return false;
                    }

                    for (let j = 0; j < commands.count; j++) {
                        if (j !== k && commands.get(k).name === commands.get(j).name) {
                            commands.setProperty(j, "valid", false)
                            console.error("Duplicate", i === 0 ? "command" : "notification", "'" + commands.get(j).name + "' found")
                            return false;
                        }
                    }

                    if (!checkForDuplicatePropertyNames(i, k, true)) {
                        return false;
                    }
                }
            }
            return true;
        }

        /**
          * This function checks for valid and duplicate property names in a command / notification
         **/
        function checkForDuplicatePropertyNames(typeIndex, commandIndex, shortCircuit = false) {
            let commands = get(typeIndex).data;
            let payload = commands.get(commandIndex).payload;

            let allValid = true;
            for (let i = 0; i < payload.count; i++) {
                let valid = true;

                if (payload.get(i).name === "") {
                    payload.setProperty(i, "valid", false)
                    allValid = false;
                    if (shortCircuit) {
                        console.error("Empty payload name at index", i)
                        return false;
                    }

                    continue;
                }

                for (let j = 0; j < payload.count; j++) {
                    if (j !== i && payload.get(i).name === payload.get(j).name) {
                        valid = false;
                        allValid = false;
                        if (shortCircuit) {
                            console.error("Duplicate payload key '" + payload.get(j).name + "' found")
                            return false;
                        }
                        break;
                    }
                }
                payload.setProperty(i, "valid", valid)
            }
            return allValid;
        }

        /**
          * This function checks for duplicate ids in either the "commands" or "notifications" array. Note that there can be duplicates between the commands and notifications. E.g.) Commands can have a cmd with name "test" and so can the notifications
         **/
        function checkForDuplicateIds(index) {
            let commands = get(index).data;
            let allValid = true
            for (let i = 0; i < commands.count; i++) {
                let valid = true;
                for (let j = 0; j < commands.count; j++) {
                    if (j !== i && commands.get(i).name === commands.get(j).name) {
                        valid = false;
                        allValid = false;
                        break;
                    }
                }
                get(index).data.setProperty(i, "valid", valid)
            }

            return allValid;
        }
    }

    ColumnLayout {
        anchors.fill: parent

        AlertToast {
            id: alertToast
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.bottomMargin: 15
            Layout.alignment: Qt.AlignTop
            spacing: 5

            Button {
                text: "Select Output Folder"
                Layout.preferredWidth: 200
                Layout.preferredHeight: 30

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        outputFileDialog.open()
                    }
                }
            }

            TextField {
                id: outputFileText
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                placeholderText: "Output Folder Location"
            }
        }

        RowLayout {
            id: mainContainer

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 20

            Repeater {
                model: finishedModel

                /*****************************************
                  * This ListView corresponds to each command / notification
                 *****************************************/
                delegate: ColumnLayout {
                    id: commandColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property ListModel commandModel: model.data
                    property bool isCommand: index === 0

                    Text {
                        id: sectionTitle
                        Layout.fillWidth: true

                        text: model.name
                        font {
                            pixelSize: 16
                            capitalization: Font.Capitalize
                        }
                    }

                    /*****************************************
                    * This ListView corresponds to each command / notification
                    *****************************************/
                    ListView {
                        id: commandsListView
                        model: commandColumn.commandModel
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: contentHeight
                        Layout.preferredHeight: contentHeight

                        property var modelIndex: index

                        spacing: 10
                        clip: true

                        delegate: ColumnLayout {
                            id: commandsColumn

                            width: parent.width

                            property ListModel payloadModel: model.payload
                            property var modelIndex: index

                            RowLayout {
                                Layout.fillWidth: true

                                RoundButton {
                                    Layout.preferredHeight: 15
                                    Layout.preferredWidth: 15
                                    padding: 0
                                    hoverEnabled: true

                                    icon {
                                        source: "qrc:/sgimages/times.svg"
                                        color: removeCommandMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
                                        height: 7
                                        width: 7
                                        name: "Remove command"
                                    }

                                    MouseArea {
                                        id: removeCommandMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            commandColumn.commandModel.remove(index)
                                        }
                                    }
                                }

                                TextField {
                                    id: cmdNotifName
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30

                                    placeholderText: commandColumn.isCommand ? "Command name" : "Notification name"
                                    validator: RegExpValidator {
                                        regExp: /^(?!default|function)[a-z_][a-zA-Z0-9_]+/
                                    }

                                    background: Rectangle {
                                        border.color: {
                                            if (!model.valid) {
                                                border.width = 2
                                                return "#D10000";
                                            } else if (cmdNotifName.activeFocus) {
                                                border.width = 2
                                                return palette.highlight
                                            } else {
                                                border.width = 1
                                                return "lightgrey"
                                            }
                                        }
                                        border.width: 2
                                    }

                                    Component.onCompleted: {
                                        forceActiveFocus()
                                    }

                                    onTextChanged: {
                                        if (text.length > 0) {
                                            finishedModel.checkForDuplicateIds(commandsListView.modelIndex)
                                        } else {
                                            model.valid = false
                                        }

                                        model.name = text
                                    }
                                }
                            }

                            /*****************************************
                            * This Repeater corresponds to each property in the payload
                            *****************************************/
                            Repeater {
                                id: payloadRepeater
                                model: commandsColumn.payloadModel

                                delegate: ColumnLayout {
                                    id: payloadContainer

                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                    spacing: 5

                                    property ListModel payloadArrayModel: model.array

                                    RowLayout {
                                        id: propertyBox
                                        spacing: 5
                                        enabled: cmdNotifName.text.length > 0
                                        Layout.preferredHeight: 30

                                        RoundButton {
                                            Layout.preferredHeight: 15
                                            Layout.preferredWidth: 15
                                            padding: 0
                                            hoverEnabled: true

                                            icon {
                                                source: "qrc:/sgimages/times.svg"
                                                color: removePayloadPropertyMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
                                                height: 7
                                                width: 7
                                                name: "Remove property"
                                            }

                                            MouseArea {
                                                id: removePayloadPropertyMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                onClicked: {
                                                    payloadModel.remove(index)
                                                }
                                            }
                                        }

                                        TextField {
                                            id: propertyKey
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 30
                                            placeholderText: "Property key"
                                            validator: RegExpValidator {
                                                regExp: /^(?!default|function)[a-z_][a-zA-Z0-9_]*/
                                            }

                                            background: Rectangle {
                                                border.color: {
                                                    if (!model.valid) {
                                                        border.width = 2
                                                        return "#D10000";
                                                    } else if (propertyKey.activeFocus) {
                                                        border.width = 2
                                                        return palette.highlight
                                                    } else {
                                                        border.width = 1
                                                        return "lightgrey"
                                                    }
                                                }
                                                border.width: 2
                                            }

                                            Component.onCompleted: {
                                                forceActiveFocus()
                                            }

                                            onTextChanged: {
                                                if (text.length > 0) {
                                                    finishedModel.checkForDuplicatePropertyNames(commandsListView.modelIndex, commandsColumn.modelIndex)
                                                } else {
                                                    model.valid = false
                                                }

                                                model.name = text
                                            }
                                        }

                                        ComboBox {
                                            id: propertyType
                                            Layout.preferredWidth: 150
                                            Layout.preferredHeight: 30
                                            model: ["int", "double", "string", "bool", "array"]

                                            Component.onCompleted: {
                                                let idx = find(model.type);
                                                if (idx === -1) {
                                                    currentIndex = 0;
                                                } else {
                                                    currentIndex = idx
                                                }
                                            }

                                            onActivated: {
                                                if (index === 4) {
                                                    if (payloadContainer.payloadArrayModel.count == 0) {
                                                        payloadContainer.payloadArrayModel.append({"type": "int", "indexSelected": 0})
                                                        commandsListView.contentY += 50
                                                    }
                                                } else {
                                                    payloadContainer.payloadArrayModel.clear()
                                                }

                                                type = currentText // This refers to model.type, but since there is a naming conflict with this ComboBox, we have to use type
                                            }
                                        }
                                    }

                                    /*****************************************
                                  * This ListView corresponds to the elements in a property of type "array"
                                 *****************************************/
                                    Repeater {
                                        id: payloadArrayRepeater
                                        model: payloadContainer.payloadArrayModel

                                        delegate: RowLayout {
                                            id: rowLayout
                                            Layout.preferredHeight: 30
                                            Layout.leftMargin: 20
                                            Layout.fillHeight: true
                                            spacing: 5

                                            RoundButton {
                                                Layout.preferredHeight: 15
                                                Layout.preferredWidth: 15
                                                padding: 0
                                                hoverEnabled: true

                                                icon {
                                                    source: "qrc:/sgimages/times.svg"
                                                    color: removeItemMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
                                                    height: 7
                                                    width: 7
                                                    name: "add"
                                                }

                                                MouseArea {
                                                    id: removeItemMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                    onClicked: {
                                                        payloadContainer.payloadArrayModel.remove(index)
                                                    }
                                                }
                                            }

                                            Text {
                                                text: "[Index " + index  + "] Element type: "
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.preferredWidth: 150
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            ComboBox {
                                                id: arrayPropertyType
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 30
                                                z: 2
                                                model: ["int", "double", "string", "bool"]

                                                Component.onCompleted: {
                                                    currentIndex = indexSelected
                                                }

                                                onActivated: {
                                                    type = currentText
                                                    indexSelected = index
                                                }
                                            }

                                            RoundButton {
                                                Layout.preferredHeight: 25
                                                Layout.preferredWidth: 25
                                                hoverEnabled: true
                                                visible: index === payloadContainer.payloadArrayModel.count - 1

                                                icon {
                                                    source: "qrc:/sgimages/plus.svg"
                                                    color: addItemToArrayMouseArea.containsMouse ? Qt.darker("green", 1.25) : "green"
                                                    height: 20
                                                    width: 20
                                                    name: "add"
                                                }

                                                MouseArea {
                                                    id: addItemToArrayMouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                    onClicked: {
                                                        payloadContainer.payloadArrayModel.append({"type": "int", "indexSelected": 0})
                                                        commandsListView.contentY += 40
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Button {
                                id: addPropertyButton
                                text: "Add Payload Property"
                                Layout.alignment: Qt.AlignHCenter
                                visible: commandsListView.count > 0
                                enabled: cmdNotifName.text !== ""

                                onClicked: {
                                    commandsColumn.payloadModel.append(templatePayload)
                                    if (commandsColumn.modelIndex === commandsListView.count - 1) {
                                        commandsListView.contentY += 70
                                    }
                                }
                            }

                            Rectangle {
                                id: hDivider
                                Layout.preferredHeight: 1
                                Layout.fillWidth: true
                                Layout.topMargin: 10
                                visible: index !== commandsListView.count - 1
                                color: "black"
                            }
                        }
                    }

                    Button {
                        id: addCmdNotifButton
                        text: commandColumn.isCommand ? "Add command" : "Add notification"

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (commandColumn.isCommand) {
                                    commandColumn.commandModel.append(templateCommand)
                                    commandsListView.contentY += 110
                                } else {
                                    commandColumn.commandModel.append(templateNotification)
                                }
                            }
                        }
                    }

                    Item {
                        // filler
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }

            }
        }

        Button {
            id: generateButton

            Layout.fillWidth: true
            Layout.preferredHeight: 30

            enabled: outputFileText.text !== ""

            background: Rectangle {
                anchors.fill: parent
                color: {
                    if (!generateButton.enabled) {
                        return "lightgrey"
                    } else {
                        return generateButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                    }
                }
            }

            contentItem: Text {
                text: "Generate"
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: generateButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true

                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    let valid = finishedModel.checkForAllValid();
                    if (!valid) {
                        alertToast.text = "Not all fields are valid! Make sure your command / notification names are unique."
                        alertToast.textColor = "white"

                        alertToast.color = "#D10000"
                        alertToast.interval = 0
                        alertToast.show()
                        return
                    }

                    let jsonInputFilePath = SGUtilsCpp.joinFilePath(outputFileText.text, "platformInterface.json");

                    let jsonObject = createJsonObject();
                    let success = SGUtilsCpp.atomicWrite(jsonInputFilePath, JSON.stringify(jsonObject, null, 4));

                    let result = generator.generate(jsonInputFilePath, outputFileText.text);
                    if (!result) {
                        alertToast.text = "Generation Failed: " + generator.lastError
                        alertToast.textColor = "white"

                        alertToast.color = "#D10000"
                        alertToast.interval = 0
                    } else if (generator.lastError.length > 0) {
                        alertToast.text = "Generation Succeeded, but with warnings: " + generator.lastError
                        alertToast.textColor = "black"
                        alertToast.color = "#DFDF43"
                        alertToast.interval = 0
                    } else {
                        alertToast.textColor = "white"
                        alertToast.text = "Successfully generated PlatformInterface.qml"
                        alertToast.color = "green"
                        alertToast.interval = 4000
                    }
                    alertToast.show();
                }
            }
        }
    }

    FileDialog {
        id: outputFileDialog
        selectFolder: true
        selectExisting: true
        selectMultiple: false

        onAccepted: {
            outputFileText.text = SGUtilsCpp.urlToLocalFile(fileUrl)
        }
    }
}
