import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
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

            Accessible.name: "Remove payload property"
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                removePayloadPropertyMouseArea.clicked()
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
                model.name = text

                if (text.length > 0) {
                    finishedModel.checkForDuplicatePropertyNames(commandsListView.modelIndex, commandsColumn.modelIndex)
                } else {
                    model.valid = false
                }
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

                Accessible.name: "Remove item from array"
                Accessible.role: Accessible.Button
                Accessible.onPressAction: {
                    removeItemMouseArea.clicked()
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
                id: addItemToArrayButton
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

                Accessible.name: "Add item to array"
                Accessible.role: Accessible.Button
                Accessible.onPressAction: {
                    addItemToArrayMouseArea.clicked()
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
