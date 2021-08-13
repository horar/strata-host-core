import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    Layout.preferredHeight: objectPropertyContainer.implicitHeight
    Layout.preferredWidth: objectPropertyContainer.implicitWidth
    Layout.leftMargin: 20
    property var indexIs: 0
    color: "pink"

    property int modelIndex

    ColumnLayout {
        id: objectPropertyContainer

       // anchors.fill: parent
        //Layout.leftMargin: 20
        spacing: 5

        property ListModel parentListModel: model.parent
        property ListModel subArrayListModel: model.array
        property ListModel subObjectListModel: model.object

        RowLayout {
            id: objectRowLayout
            // anchors.fill: parent
            Layout.preferredHeight: 30
            Layout.leftMargin: 20
            //Layout.fillHeight: true
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

                    type = payloadContainer.changePropertyType(index, objectPropertyContainer.subObjectListModel, objectPropertyContainer.subArrayListModel)
                    indexSelected = index
                   // indexIs = index

                }
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
                        }
                    }
                }
            }
        }

        Button {
            id: addPropertyButton
            text: "Add Item To Object"
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
                    objectPropertyContainer.parentListModel.append({"key": "", "type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": objectPropertyContainer.parentListModel})
                    commandsListView.contentY += 40
                }
            }
        }
    }
}
