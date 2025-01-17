/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

ColumnLayout {
    id: root
    width: parent.width

    property alias name: labelText.text
    property bool isArray: true

    Component.onCompleted: {
        update()
    }

    ColumnLayout {
        id: column
        width: root.width

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.leftMargin: 10
            Layout.rightMargin: 10
        }

        Repeater {
            id: listView
            model: listModel
            Layout.fillWidth: true
            Layout.minimumHeight: 75
            Layout.leftMargin: 10

            delegate:  RowLayout {
                id: delegateRow

                function setType(type) {
                    model.type = type
                }

                function setValue(value) {
                    model.value = value
                }

                Rectangle {
                    id: remove
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    Layout.leftMargin: 10
                    color: Theme.palette.error

                    SGIcon {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        source: "qrc:/sgimages/times.svg"
                        iconColor: "white"
                    }

                    MouseArea {
                        anchors.fill: remove

                        onClicked: {
                            let forwardDeclaration = root.update // must save reference to 'root' as after remove(), this no longer exists
                            listModel.remove(model.index)
                            forwardDeclaration()
                        }
                    }
                }

                SGTextField {
                    id: nameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    visible: !root.isArray
                    placeholderText: "key name here"
                    text: model.key
                    palette.highlight: Theme.palette.onsemiOrange

                    onTextChanged: {
                        if (text !== model.key) {
                            model.key = text
                            root.update()
                        }
                    }
                }

                SGComboBox {
                    id: comboBox
                    Layout.preferredWidth: 75
                    Layout.preferredHeight: 30
                    model: [
                        `${sdsModel.platformInterfaceGenerator.TYPE_INT}`,
                        `${sdsModel.platformInterfaceGenerator.TYPE_BOOL}`,
                        `${sdsModel.platformInterfaceGenerator.TYPE_STRING}`,
                        `${sdsModel.platformInterfaceGenerator.TYPE_DOUBLE}`,
                    ]

                    onCurrentTextChanged: {
                        delegateRow.setType(currentText)
                        if (currentText === sdsModel.platformInterfaceGenerator.TYPE_BOOL) {
                            delegateRow.setValue(valueBool.checked.toString())
                            valueField.visible = false
                            valueBool.visible = true
                        } else {
                            delegateRow.setValue(valueField.text)
                            switch(comboBox.currentText) {
                                case sdsModel.platformInterfaceGenerator.TYPE_INT:
                                    valueField.text = "0"
                                    break
                                case sdsModel.platformInterfaceGenerator.TYPE_STRING:
                                    valueField.text = "string"
                                    break
                                case sdsModel.platformInterfaceGenerator.TYPE_DOUBLE:
                                    valueField.text = "0.0"
                                    break
                            }
                            valueField.visible = true
                            valueBool.visible = false
                            valueField.forceActiveFocus()
                        }
                        root.update()
                    }
                }

                SGText {
                    font.bold: true
                    text: "value"
                }

                SGTextField {
                    id: valueField
                    clip: true
                    focus: true
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 30
                    text: model.value
                    palette.highlight: Theme.palette.onsemiOrange

                    placeholderText: {
                        switch(comboBox.currentText) {
                            case sdsModel.platformInterfaceGenerator.TYPE_INT: return 0
                            case sdsModel.platformInterfaceGenerator.TYPE_STRING: return "Your String Here"
                            case sdsModel.platformInterfaceGenerator.TYPE_DOUBLE: return 0.00
                            default: return ""
                        }
                    }

                    validator: switch(comboBox.currentText) {
                               case sdsModel.platformInterfaceGenerator.TYPE_INT: return intValid
                               case sdsModel.platformInterfaceGenerator.TYPE_DOUBLE: return doubleValid
                               default: return null
                               }

                    onTextChanged: {
                        if (text !== "" && text !== model.value) {
                            model.value = text

                            if (visible) {
                                root.update()
                            }
                        }
                    }
                }

                SGSwitch {
                    id: valueBool
                    checkedLabel: "true"
                    uncheckedLabel: "false"
                    checked: false
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 30
                    grooveFillColor: Theme.palette.highlight

                    onCheckedChanged: {
                        model.value = checked.toString()
                        if (visible) {
                            root.update()
                        }
                    }
                }
            }
        }

        SGButton {
            id: addPayloadProperty
            text: "Add Property"
            Layout.preferredWidth: 200
            Layout.preferredHeight: 30
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                listModel.append({type: sdsModel.platformInterfaceGenerator.TYPE_INT, value: "0", key: "key"})
            }
        }
    }

    ListModel {
        id: listModel
    }

    IntValidator {
        id: intValid
        locale: "C"
    }

    DoubleValidator {
        id: doubleValid
        locale: "C"
    }

    function update() {
        let payload = {}
        payload[root.name] = isArray ? [] : {}

        for (let i = 0; i < listModel.count; i++) {
            let object = listModel.get(i)
            let value
            switch(object.type) {
                case sdsModel.platformInterfaceGenerator.TYPE_INT:
                case sdsModel.platformInterfaceGenerator.TYPE_DOUBLE:
                    value = Number(object.value)
                    if (isNaN(value)) {
                        console.warn("Unable to parse the input value '" + object.value + "'")
                        value = 0
                    }
                    break
                case sdsModel.platformInterfaceGenerator.TYPE_STRING:
                    value = object.value
                    break
                case sdsModel.platformInterfaceGenerator.TYPE_BOOL:
                    value = (object.value === "true")
                    break
            }

            if (isArray) {
                payload[root.name].push(value)
            } else {
                payload[root.name][object.key] = value
            }
        }

        debugDelegateRoot.updatePartialPayload(payload)
    }
}
