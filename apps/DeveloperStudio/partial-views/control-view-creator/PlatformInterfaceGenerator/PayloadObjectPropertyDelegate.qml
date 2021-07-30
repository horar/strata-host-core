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
            visible: parentListModel.count > 1

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
                    parentListModel.remove(modelIndex)
                }
            }
        }

        TextField {
            id: propertyKey
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            placeholderText: "Key"
            selectByMouse: true
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
                text = model.name
                forceActiveFocus()
            }

            onTextChanged: {
                model.name = text

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
                type = payloadContainer.changePropertyType(index, subObjectListModel, subArrayListModel)
                indexSelected = index
            }
        }
    }

    Loader {
        sourceComponent: defaultValue
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        active: propertyType.currentIndex < 4 // not shown in some cases; array- and object-types
        visible: active

        onItemChanged: {
            if (item) {
                item.leftMargin = 20 * 2
                item.rightMargin = 30
                item.text = model.value
                item.textChanged.connect(textChanged)
            }
        }

        function textChanged() {
            model.value = item.text
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

    Button {
        id: addPropertyButton
        text: "Add Item To Array"
        Layout.alignment: Qt.AlignHCenter
        visible: modelIndex === parentListModel.count - 1

        Accessible.name: addPropertyButton.text
        Accessible.role: Accessible.Button
        Accessible.onPressAction: {
            addPropertyButtonMouseArea.clicked()
        }

        MouseArea {
            id: addPropertyButtonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                parentListModel.append({"key": "", "type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": parentListModel})
                commandsListView.contentY += 40
            }
        }
    }
}

