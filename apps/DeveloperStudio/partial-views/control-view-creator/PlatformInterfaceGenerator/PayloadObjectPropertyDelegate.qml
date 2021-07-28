import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    id: objectPropertyContainer

    Layout.leftMargin: 20
    spacing: 5

    property ListModel parentListModel: model.parent
    property ListModel subArrayListModel: model.array
    property ListModel subObjectListModel: model.object
    property int modelIndex

    RowLayout {
        id: objectRowLayout
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
                    if (propertyKey.text !== "") {
                        unsavedChanges = true
                    }
                    parentListModel.remove(modelIndex)
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
                text = model.key
                forceActiveFocus()
            }

            onTextChanged: {
                if (model.key === text) {
                    return
                }
                unsavedChanges = true

                model.key = text
                if (text.length > 0) {
                    model.valid = finishedModel.checkForDuplicateObjectPropertyNames(parentListModel, modelIndex)
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
                if (indexSelected === index) {
                    return
                }
                unsavedChanges = true

                type = payloadContainer.changePropertyType(index, subObjectListModel, subArrayListModel)
                indexSelected = index
            }
        }

        RoundButton {
            id: addPropertyToObjectButton
            Layout.preferredHeight: 25
            Layout.preferredWidth: 25
            hoverEnabled: true
            visible: modelIndex === parentListModel.count - 1

            icon {
                source: "qrc:/sgimages/plus.svg"
                color: addPropToButtonMouseArea.containsMouse ? Qt.darker("green", 1.25) : "green"
                height: 20
                width: 20
                name: "add"
            }

            Accessible.name: "Add property to Object"
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
                    parentListModel.append({"key": "", "type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": parentListModel})
                    commandsListView.contentY += 40
                }
            }
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "array"
    *****************************************/
    Repeater {
        id: subArrayRepeater
        model: subArrayListModel

        delegate: Component {
            Loader {
                Layout.leftMargin: 20

                source: "./PayloadArrayPropertyDelegate.qml"
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.modelIndex = Qt.binding(() => index)
                    }
                }
            }
        }
    }

    /*****************************************
    * This Repeater corresponds to the elements in a property of type "object"
    *****************************************/
    Repeater {
        id: subObjectRepeater
        model: subObjectListModel

        delegate: Component {
            Loader {
                Layout.leftMargin: 20

                source: "./PayloadObjectPropertyDelegate.qml"
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.modelIndex = Qt.binding(() => index)
                    }
                }
            }
        }
    }
}
