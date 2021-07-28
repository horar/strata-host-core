import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    id: arrayPropertyContainer

    Layout.leftMargin: 20
    spacing: 5

    property ListModel parentListModel: model.parent
    property ListModel subArrayListModel: model.array
    property ListModel subObjectListModel: model.object

    property int modelIndex

    RowLayout {
        id: arrayRowLayout
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
                    if (cmdNotifName.text !== "") {
                        unsavedChanges = true
                    }
                    parentListModel.remove(modelIndex)
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
            id: addItemToArrayButton
            Layout.preferredHeight: 25
            Layout.preferredWidth: 25
            hoverEnabled: true
            visible: modelIndex === parentListModel.count - 1

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
                    parentListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": parentListModel})
                    commandsListView.contentY += 40
                    unsavedChanges = true
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
