import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root

    readonly property var templatePayload: ({
                                                "name": "", // The name of the property
                                                "type": "int", // Type of the property, "array", "int", "string", etc.
                                                "array": [] // This is only filled if the type == "array"
                                            });

    ListModel {
        id: finishedModel
    }

    ListModel {
        id: payloadModel

        function convertModelToObject(listmodel) {
            let modelArr = [];
            for (let i = 0; i < listmodel.count; ++i) {
                let obj = {}
                obj["name"] = listmodel.get(i).name
                obj["type"] = listmodel.get(i).type
                if (obj["type"] === "array") {
                    let arr = [];
                    for (let j = 0; j < listmodel.get(i).array.count; ++j) {
                        let tmp = listmodel.get(i).array.get(j);
                        arr.push({"type": tmp.type, "indexSelected": tmp.indexSelected})
                    }
                    obj["array"] = arr;
                } else {
                    obj["array"] = []
                }

                modelArr.push(obj);
            }
            return modelArr;
        }
    }

    RowLayout {
        id: commandsContainer

        width: parent.width
        height: parent.height

        property bool editing: false
        property var editingIndex


        /*****************************************
          * This ListView corresponds to each command/notification
         *****************************************/
        ListView {
            id: commandsList
            model: finishedModel
            Layout.preferredWidth: 50
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            delegate: Rectangle {
                width: parent.width
                height: 50
                color: "lightgrey"
                border.color: model.editing ? "green" : "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        cmdNotifName.text = model.name
                        cmdNotifType.currentIndex = cmdNotifType.find(model.type)
                        model.editing = true
                        commandsContainer.editing = true
                        commandsContainer.editingIndex = index
                        payloadModel.clear()
                        payloadModel.append(payloadModel.convertModelToObject(model.payload))
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    Text {
                        text: "name: " + model.name
                        Layout.leftMargin: 5
                    }
                    Text {
                        text: "type: " + model.type
                    }
                }

                RoundButton {
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        margins: 5
                    }

                    height: 25
                    width: 25
                    hoverEnabled: true

                    icon {
                        source: "qrc:/sgimages/times.svg"
                        color: removeCommandMA.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
                        height: 25
                        width: 25
                        name: "Remove command / notification"
                    }

                    MouseArea {
                        id: removeCommandMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            finishedModel.remove(index)
                        }
                    }
                }

            }
        }

        ColumnLayout {
            id: commandColumn
            Layout.preferredWidth: 50
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                id: currentCmdNotif
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: 30

                property string name: cmdNotifName.text
                property string type: cmdNotifType.currentText

                TextField {
                    id: cmdNotifName
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    placeholderText: "Command name"
                    validator: RegExpValidator {
                        regExp: /^(?!default|function)[a-z][a-zA-Z0-9_]+/
                    }
                }

                ComboBox {
                    id: cmdNotifType
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 30
                    model: ["command", "notification"]
                }
            }


            /*****************************************
          * This ListView corresponds to each property in the payload
         *****************************************/
            ListView {
                id: cmdNotifRepeater
                model: payloadModel
                clip: true

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: contentHeight
                Layout.preferredHeight: contentHeight

                delegate: ColumnLayout {
                    id: payloadContainer

                    width: parent.width
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
                    ListView {
                        id: payloadArrayRepeater
                        model: payloadContainer.payloadArrayModel
                        spacing: 5

                        Layout.fillWidth: true
                        Layout.leftMargin: 50
                        Layout.bottomMargin: 5
                        Layout.preferredHeight: contentHeight//payloadContainer && payloadContainer.payloadArrayModel ? payloadContainer.payloadArrayModel.count * 40: 0
                        clip: true

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 300; }
                        }

                        Connections {
                            target: payloadContainer.payloadArrayModel
                            onCountChanged: {
                                payloadArrayRepeater.positionViewAtEnd()
                                payloadArrayRepeater.currentIndex = payloadContainer.payloadArrayModel.count - 1
                            }
                        }

                        delegate: Rectangle {
                            width: payloadArrayRepeater.width
                            height: 40
                            color: "transparent"
                            border.color: ListView.isCurrentItem ? "green" : "transparent"

                            Component.onCompleted: {
                                arrayPropertyType.currentIndex = model.indexSelected
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    payloadArrayRepeater.currentIndex = index
                                }
                            }

                            RowLayout {
                                id: rowLayout
                                height: 30
                                width: parent.width - 10
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 5

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

                                    onPressedChanged: {
                                        payloadArrayRepeater.currentIndex = index
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
                                        }
                                    }
                                }

                                RoundButton {
                                    Layout.preferredHeight: 25
                                    Layout.preferredWidth: 25
                                    hoverEnabled: true
                                    visible: payloadContainer.payloadArrayModel.count > 1

                                    icon {
                                        source: "qrc:/sgimages/times.svg"
                                        color: removeItemMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"

                                        height: 20
                                        width: 20
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
                            }
                        }
                    }
                }

                header: Button {
                    id: addPropertyButton
                    text: "Add Property"
                    Layout.alignment: Qt.AlignHCenter
                    enabled: cmdNotifName.text !== ""

                    onClicked: {
                        payloadModel.append(templatePayload)
                    }
                }
            }

            Button {
                id: addCmdNotifButton
                text: "Save"

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        let obj = {
                            "name": currentCmdNotif.name,
                            "type": currentCmdNotif.type,
                            "editing": false,
                            "payload": payloadModel.convertModelToObject(payloadModel)
                        };

                        if (commandsContainer.editing) {
                            finishedModel.set(commandsContainer.editingIndex, obj)
                            commandsContainer.editing = false
                            commandsContainer.editingIndex = null
                        } else {
                            finishedModel.append(obj);
                        }

                        payloadModel.clear()
                        payloadModel.append([templatePayload])

                        cmdNotifName.text = ""
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
