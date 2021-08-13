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
                    Layout.preferredWidth: 35
                    fontSizeMultiplier: 1.2
                    text: modelData.hasOwnProperty("name") ? modelData.name : index
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
                            const keyIndex = isArray ? parseInt(labelName.text) : labelName.text
                            listView.payload[labelText.text][keyIndex] = isJson(text) ? JSON.parse(text) : text
                            debugDelegateRoot.updatePartialPayload(listView.payload, payloadIndex)
                        }

                        validator: RegExpValidator {
                            regExp: {
                                switch(modelData.type) {
                                    case "int": return /^([1-9][0-9]*)|^([0])$/
                                    case "string": return /[0-9A-Za-z_]*/
                                    case "double": return /(([1-9][0-9]*)|(^([0])))[.]\d{0,2}/
                                }
                            }
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
                                return value
                            }
                        }
                    }
                }
            }
        }
    }
}
