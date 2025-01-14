/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0

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
                    color: removeObjectFromPayloadMouseArea.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.25) : Theme.palette.onsemiOrange
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

                        let payload = objectPropertyContainer.parentListModel
                        if (model.duplicate) {
                            model.name = "A" // use 'A' because the name can't be an uppercase. So this won't produce duplicates
                            functions.loopOverDuplicates(payload, modelIndex)
                        }
                        if (!model.valid) {
                            functions.invalidCount--
                        }
                        functions.checkAllValidArrayObject(payload.get(modelIndex), true)
                        payload.remove(modelIndex)
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
                palette.highlight: Theme.palette.onsemiOrange

                validator: RegExpValidator {
                    regExp: /^[a-z_][a-zA-Z0-9_]*/
                }

                background: Rectangle {
                    border.color: {
                        if (!model.valid) {
                            return Theme.palette.error
                        } else if (propertyKey.activeFocus) {
                            return Theme.palette.onsemiOrange
                        } else {
                            return Theme.palette.lightGray
                        }
                    }

                    border.width: (!model.valid || propertyKey.activeFocus) ? 2 : 1
                    color: model.valid ? Theme.palette.white : Qt.lighter(Theme.palette.error, 2.35)
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

            property bool isBool: propertyType.currentIndex === 3
            property string modelType: model.type

            onIsBoolChanged: {
                // reseting text, value, and checked to base states
                if (propertyType.currentIndex !== 3) {
                    model.value = "0"
                    if (item) {
                        item.text = "0"
                        item.checked = false
                    }
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
                    validateModelType(false)
                }
            }

            onModelTypeChanged: {
                if (item) {
                    validateModelType(true)
                }
            }

            function validateModelType(resetValue) {
                switch (modelType) {
                case sdsModel.platformInterfaceGenerator.TYPE_INT:
                    if (resetValue) {
                        item.text = "0"
                    }
                    item.validator = intValid
                    break
                case sdsModel.platformInterfaceGenerator.TYPE_DOUBLE:
                    if (resetValue) {
                        item.text = "0"
                    }
                    item.validator = doubleValid
                    break
                default:
                    item.validator = null
                    break
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

            IntValidator {
                id: intValid
                locale: "C"
            }

            DoubleValidator {
                id: doubleValid
                locale: "C"
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
