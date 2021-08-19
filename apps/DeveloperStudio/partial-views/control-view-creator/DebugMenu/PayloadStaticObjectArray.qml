import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

ColumnLayout {
    id: root
    width: parent.width
    property alias name: labelText.text
    property alias value: listView.model
    property bool isArray: true
    property string payloadIndex: ""

    ColumnLayout {
        id: column
        Layout.fillWidth: true
        Layout.leftMargin: 10
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 50

            SGText {
                id: labelText
                font.bold: true
                fontSizeMultiplier: 1.2
                Layout.fillWidth: true
            }

            Item {
                Layout.preferredWidth: 10
            }
        }

        Repeater {
            id: listView
            Layout.minimumWidth: 300
            Layout.minimumHeight: 100

            property var payload: ({})

            onPayloadChanged: {
                payload[labelText.text] = isArray ? [] : {}
            }

            delegate: RowLayout {
                id: inputRow
                width: listView.width
                height: 30

                Loader {
                    id: inputLoader
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    sourceComponent: modelData.type !== "bool" ? textInputComponent : textSwitchComponent

                    Component {
                        id: textInputComponent
                        PayloadInput {
                            width: inputLoader.width
                            name: modelData.hasOwnProperty("name") ? modelData.name : `index: ${index}`
                            type: modelData.type
                            value: createTextValue(modelData.value, modelData.type)

                            onValueChanged: {
                                const keyIndex = isArray ? parseInt(name.split(":")[1].trim()) : name
                                let textVal;
                                switch(modelData.type) {
                                    case "int": textVal = Number(value)
                                    break;
                                    case "double": textVal = Number(value)
                                    break;
                                    default: textVal = value
                                }
                                listView.payload[labelText.text][keyIndex] = isJson(value) ? JSON.parse(value) : textVal
                                debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                            }

                            function isJson(str) {
                                try {
                                    return JSON.parse(str);
                                } catch (e) {
                                    return false;
                                }
                            }

                            function createTextValue(value, type) {
                                if (Array.isArray(value)) {
                                    const retVal = type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC ? [] : {}
                                    if (Array.isArray(retVal)) {
                                        for (let i = 0; i < value.length; i++) {
                                            retVal[i] = createTextValue(value[i].value, value[i].type)
                                        }
                                    } else {
                                        for (let i = 0;i < value.length; i++) {
                                            retVal[value[i].name] = createTextValue(value[i].value, value[i].type)
                                        }
                                    }
                                    return JSON.stringify(retVal)
                                } else {
                                    switch(type) {
                                        case "int": return Number(value)
                                        case "double": return Number(value)
                                        default: return value
                                    }
                                }
                            }
                        }
                    }

                    Component {
                        id: textSwitchComponent

                        PayloadSwitch {
                            width: inputLoader.width
                            name: modelData.hasOwnProperty("name") ? modelData.name : `index: ${index}`
                            value: modelData.value

                            onValueChanged: {
                                const keyIndex = isArray ? parseInt(name.split(":")[1].trim()) : name
                                listView.payload[labelText.text][keyIndex] = value
                                debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                            }
                        }
                    }

                    /*
                        SGSwitch {
                            id: textSwitch
                            width: 50
                            height: 35
                            checkedLabel: "true"
                            uncheckedLabel: "false"
                            onCheckedChanged: {
                                const keyIndex = isArray ? parseInt(labelName.text.split(":")[1].trim()) : labelName.text
                                listView.payload[labelText.text][keyIndex] = checked
                                debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)

                            }
                        }
                      */
                }
            }
        }

        Item {
            Layout.preferredHeight: 10
        }
    }

    IntValidator {
        id: intValid
    }

    DoubleValidator {
        id: doubleValid
    }
}
