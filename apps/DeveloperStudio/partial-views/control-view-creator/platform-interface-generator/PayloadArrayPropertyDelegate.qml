/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: arrayDelegateRoot
    implicitHeight: arrayPropertyContainer.implicitHeight + 10
    implicitWidth: arrayPropertyContainer.implicitWidth

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
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 5
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }

        property ListModel parentListModel: model.parent
        property ListModel subArrayListModel: model.array
        property ListModel subObjectListModel: model.object

        RowLayout {
            id: arrayRowLayout
            Layout.preferredHeight: 30

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
                text: "[Index " + modelIndex + "] Type: "
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                Layout.preferredWidth: 150
                elide: Text.ElideRight
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

                    type = payloadContainer.changePropertyType(index, arrayPropertyContainer.subObjectListModel, arrayPropertyContainer.subArrayListModel)
                    indexSelected = index
                }
            }
        }

        Loader {
            sourceComponent: defaultValue; isBool: propertyType.currentIndex === 3
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            active: propertyType.currentIndex < 4 // not shown in some cases; array- and object-types
            visible: active

            property bool isBool

            onIsBoolChanged: {
                // reseting text, value, and checked to base states
                if (propertyType.currentIndex !== 3) {
                    model.value = "0"
                    item.text = "0"
                    item.checked = false
                } else {
                    model.value = "false"
                    model.checked = false
                }
            }

            onItemChanged: {
                if (item) {
                    item.leftMargin = 15
                    item.rightMargin = 0
                    item.text = model.value
                    item.checked = (model.value === "true") ? true : false
                    item.checkedChanged.connect(checkedChanged)
                    item.textChanged.connect(textChanged)
                }
            }

            function checkedChanged() {
                // with current API, all model.values are stored as strings, so the state of checked must be converted
                let value = item.checked
                model.value = value.toString()
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
                    Layout.leftMargin: 10
                    Layout.fillWidth: true

                    source: "./PayloadArrayPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => arrayDelegateRoot.color)
                            item.Layout.rightMargin = 0
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
                    Layout.leftMargin: 10
                    Layout.fillWidth: true

                    source: "./PayloadObjectPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => arrayDelegateRoot.color)
                            item.Layout.rightMargin = 0
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

