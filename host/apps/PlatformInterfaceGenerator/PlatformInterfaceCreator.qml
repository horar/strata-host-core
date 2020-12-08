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

    function generatePlatformInterface() {
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
            debugMenuGenerator.generate(jsonInputFilePath, outputFileText.text);
        } else {
            alertToast.textColor = "white"
            alertToast.text = "Successfully generated PlatformInterface.qml"
            alertToast.color = "green"
            alertToast.interval = 4000
            debugMenuGenerator.generate(jsonInputFilePath, outputFileText.text);
        }
        alertToast.show();
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
            Layout.preferredHeight: 30
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
}
