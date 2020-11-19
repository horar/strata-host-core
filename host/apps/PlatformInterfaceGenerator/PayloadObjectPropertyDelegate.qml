import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

RowLayout {
    id: objectRowLayout
    Layout.preferredHeight: 30
    Layout.leftMargin: 20
    Layout.fillHeight: true
    spacing: 5

    property int modelIndex

    RoundButton {
        Layout.preferredHeight: 15
        Layout.preferredWidth: 15
        padding: 0
        hoverEnabled: true

        icon {
            source: "qrc:/sgimages/times.svg"
            color: removeObjectFromPayloadMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
            height: 7
            width: 7
            name: "add"
        }

        Accessible.name: "Remove property from object in payload"
        Accessible.role: Accessible.Button
        Accessible.onPressAction: {
            removeObjectFromPayloadMouseArea.clicked()
        }

        MouseArea {
            id: removeObjectFromPayloadMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                payloadContainer.payloadObjectModel.remove(modelIndex)
            }
        }
    }

    TextField {
        id: propertyKey
        Layout.preferredWidth: 150
        Layout.preferredHeight: 30
        placeholderText: "Key"
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
            model.key = text

            if (text.length > 0) {
                model.valid = finishedModel.checkForDuplicateObjectPropertyNames(payloadContainer.payloadObjectModel, modelIndex)
            } else {
                model.valid = false
            }
        }
    }

    ComboBox {
        id: objectPropertyType
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        z: 2
        model: ["int", "double", "string", "bool"]

        Component.onCompleted: {
            currentIndex = indexSelected
        }

        onActivated: {
            type = currentText
            indexSelected = modelIndex
        }
    }

    RoundButton {
        id: addPropertyToObjectButton
        Layout.preferredHeight: 25
        Layout.preferredWidth: 25
        hoverEnabled: true
        visible: modelIndex === payloadContainer.payloadObjectModel.count - 1

        icon {
            source: "qrc:/sgimages/plus.svg"
            color: addPropToButtonMouseArea.containsMouse ? Qt.darker("green", 1.25) : "green"
            height: 20
            width: 20
            name: "add"
        }

        Accessible.name: "Add item to array"
        Accessible.role: Accessible.Button
        Accessible.onPressAction: {
            addPropToButtonMouseArea.clicked()
        }

        MouseArea {
            id: addPropToButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                payloadContainer.payloadObjectModel.append({"key": "", "type": "int", "indexSelected": 0})
                commandsListView.contentY += 40
            }
        }
    }
}

