import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: objectDelegateRoot

    implicitHeight: objectPropertyContainer.implicitHeight
    implicitWidth: objectPropertyContainer.implicitWidth
    Layout.leftMargin: 3
    Layout.bottomMargin: 3
    Layout.rightMargin: 3

    property int modelIndex
    property color parentColor

    color: {
        if (propertyType.currentIndex === 6 || propertyType.currentIndex === 4) {
            if(parentColor == "#ffffff") {
                return "#d3d3d3"
            }
            else return "#ffffff"
        }
        else {
            return parentColor
        }
    }

    ColumnLayout {
        id: objectPropertyContainer
        spacing: 5

        property ListModel parentListModel: model.parent
        property ListModel subArrayListModel: model.array
        property ListModel subObjectListModel: model.object

        RowLayout {
            id: objectRowLayout
            Layout.preferredHeight: 30
            Layout.leftMargin: 3
            Layout.rightMargin: 3
            Layout.fillHeight: true
            spacing: 5

            RoundButton {
                Layout.preferredHeight: 15
                Layout.preferredWidth: 15
                padding: 0
                hoverEnabled: true
                visible: objectPropertyContainer.parentListModel.count > 1

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
                        objectPropertyContainer.parentListModel.remove(modelIndex)
                    }
                }
            }

            TextField {
                id: propertyKey
                Layout.preferredWidth: 150
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
                    if (model.name === text) {
                        return
                    }
                    unsavedChanges = true

                    model.name = text
                    if (text.length > 0) {
                        model.valid = finishedModel.checkForDuplicateObjectPropertyNames(objectPropertyContainer.parentListModel, modelIndex)
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

                    type = payloadContainer.changePropertyType(index, objectPropertyContainer.subObjectListModel, objectPropertyContainer.subArrayListModel)
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
            model: objectPropertyContainer.subArrayListModel

            delegate: Component {
                Loader {
                    Layout.leftMargin: 20

                    source: "./PayloadArrayPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => objectDelegateRoot.color)
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
            model: objectPropertyContainer.subObjectListModel

            delegate: Component {
                Loader {
                    Layout.leftMargin: 20

                    source: "./PayloadObjectPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => objectDelegateRoot.color)
                        }
                    }
                }
            }
        }

        Button {
            id: addPropertyButton
            text: "Add Property To Object"
            Layout.alignment: Qt.AlignHCenter
            visible: modelIndex === objectPropertyContainer.parentListModel.count - 1

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
                    objectPropertyContainer.parentListModel.append({"name": "", "type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": objectPropertyContainer.parentListModel, "value":"0"})
                    commandsListView.contentY += 40
                }
            }
        }
    }
}
