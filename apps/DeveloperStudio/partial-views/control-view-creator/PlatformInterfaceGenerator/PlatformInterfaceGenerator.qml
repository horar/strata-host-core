import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
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
        "type": sdsModel.platformInterfaceGenerator.TYPE_INT, // Type of the property, "array", "int", "string", etc.
        "indexSelected": 0,
        "valid": false,
        "array": [], // This is only filled if the type == "array"
        "object": []
    });

    property string inputFilePath

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
            // First loop through each command / notification and make sure there are no duplicate commands / notification names
            // Then recursively go through each property to ensure that there are no duplicate object property names
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

                // If the payload property is an object, check to make sure there are no duplicate keys in that object
                if (valid && payload.get(i).type === "object") {
                    let objectPropertiesModel = payload.get(i).object;
                    for (let k = 0; k < objectPropertiesModel.count; k++) {
                        let tmpValid = checkForDuplicateObjectPropertyNames(objectPropertiesModel, k)
                        if (!tmpValid) {
                            valid = false
                            allValid = false
                            objectPropertiesModel.setProperty(k, "valid", false)

                            console.error("Duplicate or empty property key in payload property '" + payload.get(i).name + "' found")

                            if (shortCircuit) {
                                return false
                            }
                        }
                    }
                } else if (valid && payload.get(i).type === "array") {
                    if (!checkForArrayValid(payload.get(i).array)) {
                        valid = false
                        allValid = false

                        console.error("Duplicate or empty property key in payload property '" + payload.get(i).name + "' found")

                        if (shortCircuit) {
                            return false
                        }
                    }
                }

                payload.setProperty(i, "valid", valid)
            }
            return allValid;
        }

        /**
          * This function checks for duplicate keys in a give payload property that is of 'object' type
         **/
        function checkForDuplicateObjectPropertyNames(objectPropertiesModel, index) {
            let key = objectPropertiesModel.get(index).key

            if (key === "") {
                return false
            }

            for (let i = 0; i < objectPropertiesModel.count; i++) {
                if (i !== index) {
                    let item = objectPropertiesModel.get(i);
                    if (item.key === key) {
                        return false;
                    }
                }
            }

            // Now recurse through any children that are objects or arrays
            for (let j = 0; j < objectPropertiesModel.count; j++) {
                let item = objectPropertiesModel.get(j);

                if (item.type === "array") {
                    for (let k = 0; k < item.array.count; k++) {
                        if (item.array.get(k).type === "array") {
                            if (!checkForArrayValid(item.array.get(k).array)) {
                                return false
                            }
                        } else if (item.array.get(k).type === "object") {
                            let subObject = item.array.get(k).object;
                            for (let m = 0; m < subObject.count; m++) {
                                if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                                    return false;
                                }
                            }
                        }
                    }
                } else if (item.type === "object") {
                    for (let k = 0; k < item.object.count; k++) {
                        if (item.object.get(k).type === "array") {
                            if (!checkForArrayValid(item.object.get(k).array)) {
                                return false
                            }
                        } else if (item.object.get(k).type === "object") {
                            let subObject = item.object.get(k).object;
                            for (let m = 0; m < subObject.count; m++) {
                                if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                                    return false;
                                }
                            }
                        }
                    }
                }
            }

            return true;
        }

        function checkForArrayValid(arrayModel) {
            for (let i = 0; i < arrayModel.count; i++) {
                if (arrayModel.get(i).type === "array") {
                    if (!checkForArrayValid(arrayModel.get(i).array)) {
                        return false
                    }
                } else if (arrayModel.get(i).type === "object") {
                    let subObject = arrayModel.get(i).object;
                    for (let m = 0; m < subObject.count; m++) {
                        if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                            return false;
                        }
                    }
                }
            }

            return true
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

    SGConfirmationDialog {
        id: confirmOverwriteDialog
        acceptButtonText: "Overwrite"
        rejectButtonText: "Cancel"
        title: "PlatformInterface.qml already exists"
        text: "The output destination folder already contains 'PlatformInterface.qml'. Are you sure you want to overwrite this file?"

        onAccepted: {
            generatePlatformInterface();
        }
    }

    SGConfirmationDialog {
        id: confirmDeleteInProgress
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        title: "About to lose in progress work"
        text: "You currently have unsaved changes. If you continue, you will lose all progress made. Do you want to continue?"

        onAccepted: {
            let fileText = SGUtilsCpp.readTextFileContent(inputFilePath)
            try {
                const jsonObject = JSON.parse(fileText)
                createModelFromJson(jsonObject)
            } catch (e) {
                console.error(e)
                alertToast.text = "Failed to parse input JSON file: " + e
                alertToast.textColor = "white"
                alertToast.color = "#D10000"
                alertToast.interval = 0
                alertToast.show()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        AlertToast {
            id: alertToast
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Platform Interface Generator"
            padding: 0
            font {
                bold: true
                pointSize: 24
            }
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: hLine
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            color: "black"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: 900
            Layout.preferredHeight: 30
            Layout.bottomMargin: 15
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Button {
                id: importJsonFileButton
                Layout.preferredHeight: 30

                icon {
                    source: "qrc:/sgimages/file-import.svg"
                    color: importJsonMouseArea.containsMouse ? Qt.darker("grey", 1.25) : "grey"
                    name: "Import JSON file"
                }

                text: "Import"
                display: Button.TextBesideIcon
                hoverEnabled: true

                Accessible.name: "Open file dialog for importing a JSON file"
                Accessible.role: Accessible.Button
                Accessible.onPressAction: {
                    importJsonMouseArea.clicked()
                }

                MouseArea {
                    id: importJsonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        inputFileDialog.open()
                    }
                }
            }

            Button {
                id: selectOutFolderButton
                text: "Select Output Folder"
                Layout.preferredWidth: 200
                Layout.preferredHeight: 30

                Accessible.name: selectOutFolderButton.text
                Accessible.role: Accessible.Button
                Accessible.onPressAction: {
                    selectOutFolderMouseArea.clicked()
                }

                MouseArea {
                    id: selectOutFolderMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        outputFileDialog.open()
                    }
                }
            }

            SGTextField {
                id: outputFileText
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                placeholderText: "Output Folder Location"
                contextMenuEnabled: true
            }
        }

        RowLayout {
            id: mainContainer

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 20

            Repeater {
                model: finishedModel

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

                        delegate: CommandNotificationDelegate {}
                    }

                    Button {
                        id: addCmdNotifButton
                        text: commandColumn.isCommand ? "Add command" : "Add notification"

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        Accessible.name: addCmdNotifButton.text
                        Accessible.role: Accessible.Button
                        Accessible.onPressAction: {
                            addCmdNotifMouseArea.clicked()
                        }

                        MouseArea {
                            id: addCmdNotifMouseArea
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
            Layout.maximumWidth: 600
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignHCenter

            text: "Generate"
            enabled: outputFileText.text !== ""

            Accessible.name: generateButton.text
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                generateButtonMouseArea.clicked()
            }

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

                    // If the file already exists, prompt a popup confirming they want to overwrite
                    let fileName = SGUtilsCpp.joinFilePath(outputFileText.text, "PlatformInterface.qml")
                    if (SGUtilsCpp.isFile(fileName)) {
                        confirmOverwriteDialog.open()
                        return
                    }

                    generatePlatformInterface()
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

    FileDialog {
        id: inputFileDialog
        selectFolder: false
        selectExisting: true
        selectMultiple: false
        nameFilters: ["*.json"]

        onAccepted: {
            inputFilePath = SGUtilsCpp.urlToLocalFile(fileUrl)
            if (!hasMadeChanges()) {
                let fileText = SGUtilsCpp.readTextFileContent(inputFilePath)
                try {
                    const jsonObject = JSON.parse(fileText)
                    createModelFromJson(jsonObject)
                } catch (e) {
                    console.error(e)
                    alertToast.text = "Failed to parse input JSON file: " + e
                    alertToast.textColor = "white"
                    alertToast.color = "#D10000"
                    alertToast.interval = 0
                    alertToast.show()
                }
            } else {
                confirmDeleteInProgress.open()
            }
        }
    }

    /**
      * This function checks to see if either the commands or notifications has been populated
     **/
    function hasMadeChanges() {
        for (let i = 0; i < finishedModel.count; i++) {
            if (finishedModel.get(i).data.count > 0) {
                return true
            }
        }

        return false
    }

    /**
      * This function creates the model from a JSON object (used when importing a JSON file)
     **/
    function createModelFromJson(jsonObject) {
        let topLevelKeys = Object.keys(jsonObject); // This contains "commands" / "notifications" arrays

        finishedModel.modelAboutToBeReset()
        finishedModel.clear();

        for (let i = 0; i < topLevelKeys.length; i++) {
            const topLevelType = topLevelKeys[i];
            const arrayOfCommandsOrNotifications = jsonObject[topLevelType];
            let listOfCommandsOrNotifications = {
                "name": topLevelType, // "commands" / "notifications"
                "data": []
            }

            finishedModel.append(listOfCommandsOrNotifications);

            for (let j = 0; j < arrayOfCommandsOrNotifications.length; j++) {
                let commandsModel = finishedModel.get(i).data;

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
                commandObject["valid"] = true;
                commandObject["payload"] = [];
                commandObject["editing"] = false;

                commandsModel.append(commandObject);

                const payload = cmd.hasOwnProperty("payload") ? cmd["payload"] : null;
                let payloadPropertiesArray = [];

                if (payload) {
                    let payloadProperties = Object.keys(payload);
                    let payloadModel = commandsModel.get(j).payload;
                    for (let k = 0; k < payloadProperties.length; k++) {

                        const key = payloadProperties[k];
                        const type = getType(payload[key]);
                        let payloadPropObject = Object.assign({}, templatePayload);
                        payloadPropObject["name"] = key;
                        payloadPropObject["type"] = type;
                        payloadPropObject["valid"] = true;
                        payloadPropObject["indexSelected"] = -1;

                        payloadModel.append(payloadPropObject);

                        let propertyArray = [];
                        let propertyObject = [];

                        if (type === "array") {
                            generateArrayModel(payload[key], payloadModel.get(k).array);
                        } else if (type === "object") {
                            generateObjectModel(payload[key], payloadModel.get(k).object);
                        }
                    }
                }
            }
        }

        finishedModel.modelReset()
    }

    /**
      * This function takes an Array and transforms it into an array readable by our delegates
     **/
    function generateArrayModel(arr, parentListModel) {
        for (let i = 0; i < arr.length; i++) {
            const type = getType(arr[i]);
            let obj = {"type": type, "indexSelected": -1, "array": [], "object": [], "parent": parentListModel};

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

            let obj = {"key": key, "type": type, "indexSelected": -1, "valid": true, "array": [], "object": [], "parent": parentListModel};
            parentListModel.append(obj);

            if (type === "array") {
                generateArrayModel(object[key], parentListModel.get(i).array)
            } else if (type === "object") {
                generateObjectModel(object[key], parentListModel.get(i).object)
            }
        }
    }

    /**
      * This function returns the type of an item
     **/
    function getType(item) {
        if (Array.isArray(item)) {
            return "array";
        } else if (typeof item === "object") {
            return "object";
        } else {
            return item;
        }
    }

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

                    if (payloadProperty.type === "array") {
                        commandObj["payload"][payloadProperty.name] = createJsonObjectFromArrayProperty(payloadProperty.array, []);
                    } else if (payloadProperty.type === "object") {
                        commandObj["payload"][payloadProperty.name] = createJsonObjectFromObjectProperty(payloadProperty.object, {});
                    } else {
                        commandObj["payload"][payloadProperty.name] = payloadProperty.type;
                    }
                }
                commands.push(commandObj)
            }
            obj[type.name] = commands;
        }
        return obj;
    }

    function createJsonObjectFromArrayProperty(arrayModel, outputArr) {
        for (let m = 0; m < arrayModel.count; m++) {
            let arrayElement = arrayModel.get(m);

            if (arrayElement.type === "object") {
                outputArr.push(createJsonObjectFromObjectProperty(arrayElement.object, {}))
            } else if (arrayElement.type === "array") {
                outputArr.push(createJsonObjectFromArrayProperty(arrayElement.array, []))
            } else {
                outputArr.push(arrayElement.type)
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
            } else {
                outputObj[objectProperty.key] = objectProperty.type
            }
        }
        return outputObj;
    }

    function generatePlatformInterface() {
        let jsonInputFilePath = SGUtilsCpp.joinFilePath(outputFileText.text, "platformInterface.json");

        let jsonObject = createJsonObject();
        let success = SGUtilsCpp.atomicWrite(jsonInputFilePath, JSON.stringify(jsonObject, null, 4));
        let result = sdsModel.platformInterfaceGenerator.generate(jsonInputFilePath, outputFileText.text);
        if (!result) {
            alertToast.text = "Generation Failed: " + sdsModel.platformInterfaceGenerator.lastError
            alertToast.textColor = "white"

            alertToast.color = "#D10000"
            alertToast.interval = 0
        } else if (sdsModel.platformInterfaceGenerator.lastError.length > 0) {
            alertToast.text = "Generation Succeeded, but with warnings: " + sdsModel.platformInterfaceGenerator.lastError
            alertToast.textColor = "black"
            alertToast.color = "#DFDF43"
            alertToast.interval = 0
            sdsModel.debugMenuGenerator.generate(jsonInputFilePath, outputFileText.text);
        } else {
            alertToast.textColor = "white"
            alertToast.text = "Successfully generated PlatformInterface.qml"
            alertToast.color = "green"
            alertToast.interval = 4000
            sdsModel.debugMenuGenerator.generate(jsonInputFilePath, outputFileText.text);
        }
        alertToast.show();
    }
}
