import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    id: payloadContainer

    Layout.fillWidth: true
    Layout.leftMargin: 20
    spacing: 5

    property ListModel payloadArrayModel: model.array
    property ListModel payloadObjectModel: model.object

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
            model: ["int", "double", "string", "bool", "array", "object"]

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
                    if (payloadContainer.payloadArrayModel.count === 0) {
                        payloadContainer.payloadObjectModel.clear()
                        payloadContainer.payloadArrayModel.append({"type": "int", "indexSelected": 0})
                        commandsListView.contentY += 50
                    }
                } else if (index === 5) {
                    if (payloadContainer.payloadObjectModel.count === 0) {
                        payloadContainer.payloadArrayModel.clear()
                        payloadContainer.payloadObjectModel.append({"key": "", "type": "int", "indexSelected": 0, "valid": true})
                    }
                } else {
                    payloadContainer.payloadArrayModel.clear()
                    payloadContainer.payloadObjectModel.clear()
                }

                type = currentText // This refers to model.type, but since there is a naming conflict with this ComboBox, we have to use type
            }
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "array"
    *****************************************/
    Repeater {
        id: payloadArrayRepeater
        model: payloadContainer.payloadArrayModel

        delegate: PayloadArrayPropertyDelegate {
            modelIndex: index
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "object"
    *****************************************/
    Repeater {
        id: payloadObjectRepeater
        model: payloadContainer.payloadObjectModel

        delegate: PayloadObjectPropertyDelegate {
            modelIndex: index
        }
    }
}
