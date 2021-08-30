import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: arrayDelegateRoot

    implicitHeight: arrayPropertyContainer.implicitHeight
    implicitWidth: arrayPropertyContainer.implicitWidth
    Layout.leftMargin: 3
    Layout.bottomMargin: 3
    Layout.rightMargin: 5

    property int modelIndex
    property color parentColor

    color: {
        if (propertyType.currentIndex === 6 || propertyType.currentIndex === 4) {
            if (parentColor == "#efefef") {
                return "#ffffff"
            }
            return "#efefef"
        }
        return parentColor
    }

    ColumnLayout {
        id: arrayPropertyContainer
        spacing: 5

        property ListModel parentListModel: model.parent
        property ListModel subArrayListModel: model.array
        property ListModel subObjectListModel: model.object

        RowLayout {
            id: arrayRowLayout
            Layout.preferredHeight: 30
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            Layout.fillHeight: true
            spacing: 5

            RoundButton {
                Layout.preferredHeight: 15
                Layout.preferredWidth: 15
                padding: 0
                hoverEnabled: true
                visible: arrayPropertyContainer.parentListModel.count > 1

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
                        if (cmdNotifName.text !== "") {
                            unsavedChanges = true
                        }
                        arrayPropertyContainer.parentListModel.remove(modelIndex)
                    }
                }
            }


            Text {
                text: "[Index " + modelIndex + "] Element type: "
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 150
                verticalAlignment: Text.AlignVCenter
            }

            TypeSelectorComboBox {
                id: propertyType
                Layout.topMargin: 2

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

                    type = payloadContainer.changePropertyType(index, arrayPropertyContainer.subObjectListModel, arrayPropertyContainer.subArrayListModel)
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
            model: arrayPropertyContainer.subArrayListModel

            delegate: Component {
                Loader {
                    Layout.leftMargin: 20

                    source: "./PayloadArrayPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => arrayDelegateRoot.color)
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
            model: arrayPropertyContainer.subObjectListModel

            delegate: Component {
                Loader {
                    Layout.leftMargin: 20

                    source: "./PayloadObjectPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => arrayDelegateRoot.color)
                        }
                    }
                }
            }
        }

        Button {
            id: addPropertyButton
            text: (propertyType.currentIndex === 4) ? "Add Item To Array" : "Add Item To Object"
            Layout.alignment: Qt.AlignHCenter
            visible: propertyType.currentIndex === 4 || propertyType.currentIndex === 6

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
                    if (propertyType.currentIndex === 4) {
                        arrayPropertyContainer.subArrayListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": arrayPropertyContainer.subArrayListModel, "value": "0"})
                    } else {
                        arrayPropertyContainer.subObjectListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": arrayPropertyContainer.subObjectListModel, "value": "0"})
                    }
                    commandsListView.contentY += 40
                }
            }
        }
    }
}

