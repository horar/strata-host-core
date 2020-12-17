import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    id: payloadContainer

    Layout.fillWidth: true
    Layout.leftMargin: 20
    spacing: 5

    property ListModel subArrayListModel: model.array
    property ListModel subObjectListModel: model.object

    function changePropertyType(index, objectListModel, arrayListModel) {
        if (index === 4) {
            // static array
            if (arrayListModel.count === 0) {
                objectListModel.clear()
                arrayListModel.append({"type": generator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": arrayListModel})
                commandsListView.contentY += 50
            }
        } else if (index === 6) {
            // Object with known properties
            if (objectListModel.count === 0) {
                arrayListModel.clear()
                objectListModel.append({"key": "", "type": generator.TYPE_INT, "indexSelected": 0, "valid": true, "array": [], "object": [], "parent": objectListModel})
            }
        } else {
            arrayListModel.clear()
            objectListModel.clear()
        }

        return propertyType.items[index].value
    }

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
                regExp: /^(?!default)[a-z_][a-zA-Z0-9_]*/
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
                text = model.name
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

        TypeSelectorComboBox {
            id: propertyType
            Component.onCompleted: {
                if (indexSelected === -1) {
                    currentIndex = getIndexOfType(type)
                    indexSelected = currentIndex
                } else {
                    currentIndex = indexSelected
                }
            }

            onActivated: {
                type = changePropertyType(index, subObjectListModel, subArrayListModel)
                indexSelected = index
            }
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "array"
    *****************************************/
    Repeater {
        id: payloadArrayRepeater
        model: payloadContainer.subArrayListModel

        delegate: PayloadArrayPropertyDelegate {
            modelIndex: index
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "object"
    *****************************************/
    Repeater {
        id: payloadObjectRepeater
        model: payloadContainer.subObjectListModel

        delegate: PayloadObjectPropertyDelegate {
            modelIndex: index
        }
    }
}
