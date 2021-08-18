import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

ColumnLayout {
    id: root
    width: parent.width
    property alias name: labelText.text
    property alias value: listView.model
    property bool isArray: true
    property string payloadIndex: ""

    ColumnLayout {
        id: column
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 50

            Item {
                Layout.preferredWidth: 10
            }

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

        ListView {
            id: listView
            Layout.preferredWidth: 300
            Layout.minimumHeight: contentHeight
            Layout.leftMargin: 20
            clip: true
            spacing: 5

            property var payload: ({})

            onPayloadChanged: {
                payload[labelText.text] = isArray ? [] : {}
            }

            delegate: RowLayout {
                width: listView.width
                height: 30

                SGText {
                    id: labelName
                    font.bold: true
                    Layout.minimumWidth: 100
                    Layout.maximumWidth: 100
                    fontSizeMultiplier: 1.2
                    elide: Text.ElideRight
                    text: modelData.hasOwnProperty("name") ? modelData.name : `index: ${index}`
                }

                SGText {
                    id: typeName
                    Layout.minimumWidth: 50
                    Layout.maximumWidth: 50
                    fontSizeMultiplier: 1.2
                    text: modelData.type
                }

                Rectangle {
                    id: textInputBorder
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    border.color: Theme.palette.lightGray
                    border.width: 1
                    radius: 5

                    SGTextInput {
                        id: textInput
                        anchors.fill: textInputBorder
                        verticalAlignment: Text.AlignVCenter
                        anchors.leftMargin: 5
                        fontSizeMultiplier: 1.2
                        clip: true
                        text: createTextValue(modelData.value, modelData.type)

                        onTextChanged: {
                            const keyIndex = isArray ? parseInt(labelName.text.split(":")[1].trim()) : labelName.text
                            let textVal;
                            switch(modelData.type) {
                                case "int": textVal = Number(text)
                                break;
                                case "double": textVal = Number(text)
                                break;
                                case "bool": textVal = Boolean(text)
                                break;
                                default: textVal = text
                            }
                            listView.payload[labelText.text][keyIndex] = isJson(text) ? JSON.parse(text) : textVal
                            debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                        }

                        validator: switch(modelData.type) {
                            case "int": return intValid
                            case "double": return doubleValid
                        }

                        focus: true

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
                                    case "bool": return Boolean(value)
                                    default: return value
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IntValidator {
        id: intValid
    }

    DoubleValidator {
        id: doubleValid
    }
}
