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

    ColumnLayout {
        id: column
        Layout.fillWidth: true
        Layout.leftMargin: 10

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.fillWidth: true
            Layout.rightMargin: 10
            Layout.topMargin: 10
            elide: Text.ElideRight
        }

        Repeater {
            id: listView
            Layout.minimumWidth: 300
            Layout.minimumHeight: 100

            property var payload: isArray ? [] : {}

            delegate: RowLayout {
                id: inputRow
                width: listView.width
                height: 30

                Loader {
                    id: inputLoader
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    sourceComponent: modelData.type !== "bool" ? textInputComponent : textSwitchComponent
                    Layout.bottomMargin: 5

                    Component {
                        id: textInputComponent

                        PayloadInput {
                            name: modelData.hasOwnProperty("name") ? modelData.name : `index: ${index}`
                            type: modelData.type
                            value: createTextValue(modelData.value, modelData.type)

                            Component.onCompleted: {
                                update()
                                initialized = true
                            }

                            onValueChanged: {
                                if (initialized) {
                                    update()
                                }
                            }

                            function update() {
                                const keyIndex = isArray ? parseInt(name.split(":")[1].trim()) : name
                                let textVal;
                                switch(modelData.type) {
                                    case "int":
                                        textVal = Number(value)
                                        break
                                    case "double":
                                        textVal = Number(value)
                                        break
                                    default: textVal = value
                                }
                                listView.payload[keyIndex] = isJson(value) ? JSON.parse(value) : textVal
                                root.update()
                            }

                            function isJson(str) {
                                try {
                                    JSON.parse(str)
                                    return true
                                } catch (e) {
                                    return false
                                }
                            }

                            function createTextValue(value, type) {
                                if (Array.isArray(value)) {
                                    const retVal = type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC ? [] : {}
                                    if (Array.isArray(retVal)) {
                                        for (let i = 0; i < value.length; i++) {
                                            retVal[i] = JSON.parse(createTextValue(value[i].value, value[i].type))
                                        }
                                    } else {
                                        for (let i = 0;i < value.length; i++) {
                                            retVal[value[i].name] = JSON.parse(createTextValue(value[i].value, value[i].type))
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
                            name: modelData.hasOwnProperty("name") ? modelData.name : `index: ${index}`
                            value: modelData.value

                            Component.onCompleted: {
                                update()
                                initialized = true
                            }

                            onValueChanged: {
                                if (initialized) {
                                    update()
                                }
                            }

                            function update() {
                                const keyIndex = isArray ? parseInt(name.split(":")[1].trim()) : name
                                listView.payload[keyIndex] = value
                                root.update()
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

    function update() {
        let payload = {}
        payload[root.name] = listView.payload
        debugDelegateRoot.updatePartialPayload(payload)
    }
}
