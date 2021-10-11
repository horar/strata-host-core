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
    id: objectDelegateRoot
    implicitHeight: objectPropertyContainer.implicitHeight + 10
    implicitWidth: objectPropertyContainer.implicitWidth

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
        id: objectPropertyContainer
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
            id: objectRowLayout
            Layout.preferredHeight: 30

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

                        if (model.duplicate) {
                            model.name = "A" // use 'A' because the name can't be an uppercase. So this won't produce duplicates
                            functions.loopOverDuplicates(objectPropertyContainer.parentListModel, modelIndex)
                        }
                        if (!model.valid) {
                            functions.invalidCount--
                        }
                        objectPropertyContainer.parentListModel.remove(modelIndex)
                    }
                }
            }

            TextField {
                id: propertyKey
                Layout.preferredWidth: 150
                Layout.preferredHeight: 30
                Layout.fillWidth: true
                placeholderText: "Key"
                selectByMouse: true
                validator: RegExpValidator {
                    regExp: /^[a-z_][a-zA-Z0-9_]*/
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
                    if (model.name) {
                        text = model.name
                    } else {
                        model.valid = false
                        functions.invalidCount++
                    }
                    forceActiveFocus()
                }

                onTextChanged: {
                    if (model.name === text) {
                        return
                    }
                    unsavedChanges = true

                    model.name = text
                    functions.checkForValidKey(objectPropertyContainer.parentListModel, modelIndex, model.valid)
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
                    item.leftMargin = 15
                    item.rightMargin = 0
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
                    Layout.leftMargin: 10
                    Layout.fillWidth: true

                    source: "./PayloadArrayPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => objectDelegateRoot.color)
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
            model: objectPropertyContainer.subObjectListModel

            delegate: Component {
                Loader {
                    Layout.leftMargin: 10
                    Layout.fillWidth: true

                    source: "./PayloadObjectPropertyDelegate.qml"
                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            item.modelIndex = Qt.binding(() => index)
                            item.parentColor = Qt.binding(() => objectDelegateRoot.color)
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
            visible:  propertyType.currentIndex === 4 || propertyType.currentIndex === 6

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
                        objectPropertyContainer.subArrayListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": objectPropertyContainer.subArrayListModel, "value": "0", "keyword": false, "duplicate": false})
                    }
                    else {
                        objectPropertyContainer.subObjectListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": objectPropertyContainer.subObjectListModel, "value": "0", "keyword": false, "duplicate": false})
                    }
                    commandsListView.contentY += 40
                }
            }
        }
    }
}
