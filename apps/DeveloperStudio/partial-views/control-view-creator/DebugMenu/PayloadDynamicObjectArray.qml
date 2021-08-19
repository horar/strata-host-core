import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

ColumnLayout {
    id: root
    width: parent.width
    property alias name: labelText.text
    property bool isArray: true
    property string payloadIndex: ""
    property var value: ({})

    ColumnLayout {
        id: column
        width: root.width

        RowLayout {
            id: titleRow

            Item {
                Layout.preferredWidth: 10
            }

            SGText {
                id: labelText
                font.bold: true
                fontSizeMultiplier: 1.2
                Layout.preferredWidth: 100
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Repeater {
            id: listView
            model: listModel
            Layout.fillWidth: true
            Layout.minimumHeight: 75
            Layout.leftMargin: 10

            property var payload: ({})

            onPayloadChanged: {
                payload[root.name] = isArray ? [] : {}
                debugDelegateRoot.updatePartialPayload(payload, payloadIndex)
            }

            delegate: ColumnLayout {
                id: delegateColumn
                Layout.fillWidth: true
                Layout.preferredHeight: 75

                RowLayout {
                    Item {
                        Layout.preferredWidth: 10
                    }

                    Rectangle {
                        id: errorBoundary
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        color: "red"
                        SGIcon {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            source: "qrc:/sgimages/times.svg"
                            iconColor: "white"
                        }

                        MouseArea {
                            anchors.fill: errorBoundary

                            onClicked: {
                                let deletedIndex = isArray ? model.index : nameField.text
                                if (isArray) {
                                    listView.payload[root.name].splice(deletedIndex, 1)
                                } else {
                                    delete listView.payload[root.name][deletedIndex]
                                }
                                listModel.remove(model.index)
                            }
                        }
                    }

                    SGTextField {
                        id: nameField
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 30
                        visible: !root.isArray
                        placeholderText: "key"
                    }

                    SGComboBox {
                        id: comboBox
                        model: [
                            `${sdsModel.platformInterfaceGenerator.TYPE_INT}`,
                            `${sdsModel.platformInterfaceGenerator.TYPE_BOOL}`,
                            `${sdsModel.platformInterfaceGenerator.TYPE_STRING}`,
                            `${sdsModel.platformInterfaceGenerator.TYPE_DOUBLE}`,
                        ]
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                    }

                    SGText {
                        font.bold: true
                        text: "value"
                    }

                    Loader {
                        id: loader
                        active: true
                        sourceComponent: comboBox.currentIndex !== 1 ? inputComponent : switchComponent
                        Layout.fillWidth: true
                        Layout.rightMargin: 10

                        Component {
                            id: inputComponent

                            SGTextField {
                                width: loader.width
                                clip: true
                                readOnly: isArray ? false : nameField.length < 1
                                placeholderText: {
                                     switch(comboBox.currentText) {
                                            case "int": return 0
                                            case "string": return ""
                                            case "double": return 0.00
                                    }
                                }

                                validator: switch(comboBox.currentText) {
                                    case "int": return intValid
                                    case "double": return doubleValid
                                }
                                focus: true

                                onTextChanged: {
                                    let value
                                    let newIndex = isArray ? model.index : nameField.text
                                    switch(comboBox.currentText) {
                                           case "int": value = parseInt(text)
                                               break;
                                           case "string": value = text
                                               break;
                                           case "double": value = parseFloat(text)
                                               break;
                                    }
                                    listView.payload[root.name][newIndex] = value
                                    root.value = value
                                    debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                                }
                            }
                        }

                        Component {
                            id: switchComponent

                            SGSwitch {
                                width: 100
                                height: 30
                                checkedLabel: "true"
                                uncheckedLabel: "false"

                                onCheckedChanged: {
                                    let newIndex = isArray ? model.index : nameField.text
                                    listView.payload[root.name][newIndex] = checked
                                    root.value = value
                                    debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 10
                    }
                }
            }
        }

        SGButton {
            id: addPayloadProperty
            text: "Add Property"
            Layout.preferredWidth: 200
            Layout.preferredHeight: 30
            Layout.leftMargin: 50

            onClicked: {
                listModel.append({"name": "", "type": "", "value": null, "payloadIndex": root.payloadIndex})
            }
        }
    }

    ListModel {
        id: listModel
    }

    IntValidator {
        id: intValid
    }

    DoubleValidator {
        id: doubleValid
    }
}
