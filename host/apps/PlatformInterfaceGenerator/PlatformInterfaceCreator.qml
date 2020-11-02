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
        "payload": [],
        "editing": false
    });

    readonly property var templateNotification: ({
        "type": "value",
        "name": "",
        "payload": [],
        "editing": false
    });

    readonly property var templatePayload: ({
        "name": "", // The name of the property
        "type": "int", // Type of the property, "array", "int", "string", etc.
        "array": [] // This is only filled if the type == "array"
    });

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
                                        regExp: /^(?!default|function)[a-z][a-zA-Z0-9_]+/
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
                                                regExp: /^(?!default|function)[a-z][a-zA-Z0-9_]*/
                                            }

                                            Component.onCompleted: {
                                                text = model.name
                                            }

                                            onTextChanged: {
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
                                                text: index + 1 + ". Element type: "
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.preferredWidth: 120
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
                                text: "Add Property"
                                Layout.alignment: Qt.AlignHCenter
                                visible: commandsListView.count > 0
                                enabled: cmdNotifName.text !== ""

                                onClicked: {
                                    commandsColumn.payloadModel.append(templatePayload)
                                    commandsListView.contentY += 70
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
                        return "grey"
                    } else {
                        return generateButtonMouseArea.containsMouse ? Qt.darker("green", 1.5) : "green"
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
                    let result = generator.generate(inputFilePath, outputFilePath);
                    if (!result) {
                        alertToast.text = "Generation Failed: " + generator.lastError
                        alertToast.textColor = "white"

                        alertToast.color = "red"
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
