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

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
    id: payloadDelegateRoot
    Layout.preferredHeight: payloadContainer.implicitHeight + 10
    Layout.fillWidth: true
    Layout.leftMargin: 10

    color: "transparent"

    property var selectedIndex: propertyType.currentIndex

    onSelectedIndexChanged: {
        if (propertyType.currentIndex === 4 || propertyType.currentIndex === 6) {
            if (color !== "#ffffff") {
                return color = "#ffffff"
            }
            return color
        }
        return color
    }

    ColumnLayout {
        id: payloadContainer
        spacing: 5
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 5
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }

        property ListModel subArrayListModel: model.array
        property ListModel subObjectListModel: model.object

        function changePropertyType(index, objectListModel, arrayListModel) {
            if (index === 4) {
                // static array
                if (arrayListModel.count === 0) {
                    objectListModel.clear()
                    arrayListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": arrayListModel, "value": "0", "keyword": false, "duplicate": false})
                    commandsListView.contentY += 50
                }
            } else if (index === 6) {
                // Object with known properties
                if (objectListModel.count === 0) {
                    arrayListModel.clear()
                    objectListModel.append({"name": "", "type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "valid": true, "array": [], "object": [], "parent": objectListModel, "value": "0", "keyword": false, "duplicate": false})
                }
            } else {
                arrayListModel.clear()
                objectListModel.clear()
            }

            return propertyType.items[index].value
        }

        RowLayout {
            id: propertyBox
            enabled: cmdNotifName.text.length > 0
            Layout.preferredHeight: 30
            Layout.fillWidth: true

            spacing: 5

            RoundButton {
                Layout.preferredHeight: 15
                Layout.preferredWidth: 15
                padding: 0
                hoverEnabled: true

                icon {
                    source: "qrc:/sgimages/times.svg"
                    color: removePayloadPropertyMouseArea.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.25) : Theme.palette.onsemiOrange
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
                        if (propertyKey.text !== "") {
                            unsavedChanges = true
                        }

                        let commands = finishedModel.get(commandsListView.modelIndex).data
                        let payload = commands.get(commandsColumn.modelIndex).payload
                        if (model.duplicate) {
                            model.name = "A" // use 'A' because the name can't be an uppercase. So this won't produce duplicates
                            functions.loopOverDuplicates(payload, index)
                        }
                        if (!model.valid) {
                            functions.invalidCount--
                        }
                        functions.checkAllValidArrayObject(payload.get(index), true)
                        payloadModel.remove(index)
                    }
                }
            }

            TextField {
                id: propertyKey
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                selectByMouse: true
                persistentSelection: true // must deselect manually
                placeholderText: "Property key"
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
                    text = model.name
                    if (!text) {
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
                    let commands = finishedModel.get(commandsListView.modelIndex).data
                    let payload = commands.get(commandsColumn.modelIndex).payload
                    functions.checkForValidKey(payload, index, model.valid)
                }

                onActiveFocusChanged: {
                    if (activeFocus === false && (contextMenuPopupLoader.item == null || contextMenuPopupLoader.item.visible === false)) {
                        propertyKey.deselect()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.RightButton

                    onClicked: {
                        propertyKey.forceActiveFocus()
                    }

                    onReleased: {
                        if (containsMouse) {
                            contextMenuPopupLoader.active = true
                            contextMenuPopupLoader.item.popup(null)
                        }
                    }
                }

                Loader {
                    id: contextMenuPopupLoader
                    active: false
                    sourceComponent: SGContextMenuEditActions {
                        textEditor: propertyKey
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

                    type = payloadContainer.changePropertyType(index, payloadContainer.subObjectListModel, payloadContainer.subArrayListModel)
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
                    item.leftMargin = 20
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
            id: payloadArrayRepeater
            model: payloadContainer.subArrayListModel

            delegate: PayloadArrayPropertyDelegate {
                modelIndex: index
                parentColor: payloadDelegateRoot.color
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
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
                parentColor: payloadDelegateRoot.color
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
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
                        payloadContainer.subArrayListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": payloadContainer.subArrayListModel, "value": "0", "keyword": false, "duplicate": false})
                    } else {
                        payloadContainer.subObjectListModel.append({"type": sdsModel.platformInterfaceGenerator.TYPE_INT, "indexSelected": 0, "array": [], "object": [], "parent": payloadContainer.subObjectListModel, "value": "0", "keyword": false, "duplicate": false})
                    }
                    commandsListView.contentY += 40
                }
            }
        }
    }
}
